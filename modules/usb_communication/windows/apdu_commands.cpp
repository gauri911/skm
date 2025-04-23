#include "apdu_commands.h"
#include <vector>
#include <string>
#include <memory>
#include <iostream>

// Helper function to convert PIN to byte array
std::vector<BYTE> pinToBytes(const char* pin) {
    return std::vector<BYTE>(pin, pin + strlen(pin));
}

APDUResponse sendAPDU(HANDLE handle, BYTE cla, BYTE ins, BYTE p1, BYTE p2, 
                     BYTE* data, DWORD dataLen, DWORD expectedLength) {
    std::vector<BYTE> apduCommand;
    
    // Build APDU header
    apduCommand.push_back(cla);
    apduCommand.push_back(ins);
    apduCommand.push_back(p1);
    apduCommand.push_back(p2);
    
    // Add data length and data if present
    if (data && dataLen > 0) {
        apduCommand.push_back(static_cast<BYTE>(dataLen));
        apduCommand.insert(apduCommand.end(), data, data + dataLen);
    }
    
    // Add expected length if needed
    if (expectedLength > 0) {
        apduCommand.push_back(static_cast<BYTE>(expectedLength));
    }

    // Allocate buffer for response
    std::vector<BYTE> responseBuffer(expectedLength + 2); // +2 for status words
    DWORD bytesWritten = 0, bytesRead = 0;

    // Send command
    if (WriteDevice(handle, apduCommand.data(), apduCommand.size(), &bytesWritten) != -1) {
        return {0x6F, 0x00, nullptr, 0, -1}; // Communication error
    }

    // Read response
    if (ReadDevice(handle, responseBuffer.data(), responseBuffer.size(), &bytesRead) != -1) {
        return {0x6F, 0x00, nullptr, 0, -1}; // Communication error
    }

    // Parse response
    APDUResponse response;
    if (bytesRead >= 2) {
        response.sw1 = responseBuffer[bytesRead - 2];
        response.sw2 = responseBuffer[bytesRead - 1];
        response.dataLength = bytesRead - 2;
        if (response.dataLength > 0) {
            response.data = new BYTE[response.dataLength];
            memcpy(response.data, responseBuffer.data(), response.dataLength);
        } else {
            response.data = nullptr;
        }
        
        // Calculate remaining tries if authentication failed
        if (response.sw1 == 0x63 && (response.sw2 & 0xF0) == 0xC0) {
            response.remainingTries = response.sw2 & 0x0F;
        } else {
            response.remainingTries = -1;
        }
    } else {
        response = {0x6F, 0x00, nullptr, 0, -1}; // Invalid response
    }

    return response;
}

int verifyPin(HANDLE handle, const char* pin) {
    if (!pin) return ERR_PIN_INVALID;
    
    size_t pinLen = strlen(pin);
    if (pinLen < MIN_PIN_LENGTH) return ERR_PIN_TOO_SHORT;
    if (pinLen > MAX_PIN_LENGTH) return ERR_PIN_TOO_LONG;

    // Convert PIN to bytes
    std::vector<BYTE> pinData = pinToBytes(pin);
    
    // Send VERIFY command
    APDUResponse response = sendAPDU(
        handle,
        APDU_CLA_DEFAULT,
        APDU_INS_VERIFY,
        APDU_P1_DEFAULT,
        APDU_P2_PIN,
        pinData.data(),
        pinData.size(),
        0
    );

    // Handle response
    uint16_t sw = (response.sw1 << 8) | response.sw2;
    switch (sw) {
        case SW_SUCCESS:
            return 0;
        case SW_PIN_BLOCKED:
            return ERR_PIN_BLOCKED;
        case SW_AUTH_FAILED:
            return response.remainingTries;
        default:
            return ERR_COMMUNICATION;
    }
}

int changePin(HANDLE handle, const char* oldPin, const char* newPin) {
    if (!oldPin || !newPin) return ERR_PIN_INVALID;
    
    // Validate PIN lengths
    size_t oldPinLen = strlen(oldPin);
    size_t newPinLen = strlen(newPin);
    
    if (oldPinLen < MIN_PIN_LENGTH || newPinLen < MIN_PIN_LENGTH) return ERR_PIN_TOO_SHORT;
    if (oldPinLen > MAX_PIN_LENGTH || newPinLen > MAX_PIN_LENGTH) return ERR_PIN_TOO_LONG;

    // Verify old PIN first
    int verifyResult = verifyPin(handle, oldPin);
    if (verifyResult < 0) return verifyResult;

    // Prepare combined old + new PIN data
    std::vector<BYTE> pinData;
    auto oldPinBytes = pinToBytes(oldPin);
    auto newPinBytes = pinToBytes(newPin);
    pinData.insert(pinData.end(), oldPinBytes.begin(), oldPinBytes.end());
    pinData.insert(pinData.end(), newPinBytes.begin(), newPinBytes.end());

    // Send CHANGE REFERENCE DATA command
    APDUResponse response = sendAPDU(
        handle,
        APDU_CLA_DEFAULT,
        APDU_INS_CHANGE_PIN,
        APDU_P1_DEFAULT,
        APDU_P2_PIN,
        pinData.data(),
        pinData.size(),
        0
    );

    // Handle response
    uint16_t sw = (response.sw1 << 8) | response.sw2;
    switch (sw) {
        case SW_SUCCESS:
            return 0;
        case SW_PIN_BLOCKED:
            return ERR_PIN_BLOCKED;
        case SW_AUTH_FAILED:
            return response.remainingTries;
        default:
            return ERR_COMMUNICATION;
    }
}

int getPinRetries(HANDLE handle) {
    // Send VERIFY command with empty data to get remaining tries
    APDUResponse response = sendAPDU(
        handle,
        APDU_CLA_DEFAULT,
        APDU_INS_VERIFY,
        APDU_P1_DEFAULT,
        APDU_P2_PIN,
        nullptr,
        0,
        0
    );

    if (response.remainingTries >= 0) {
        return response.remainingTries;
    }
    return ERR_COMMUNICATION;
}