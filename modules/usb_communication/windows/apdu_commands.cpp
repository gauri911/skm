#include "apdu_commands.h"
#include <string>
#include <memory>
#include <iostream>
#include <iomanip>
#include <sstream>

std::vector<BYTE> pinToBytes(const char* pin) {
    if (!pin) return std::vector<BYTE>();
    return std::vector<BYTE>(pin, pin + strlen(pin));
}

void logAPDU(const char* prefix, const std::vector<BYTE>& data) {
    std::stringstream ss;
    ss << prefix << ": ";
    for (BYTE b : data) {
        ss << std::hex << std::setw(2) << std::setfill('0') << static_cast<int>(b) << " ";
    }
    std::cout << ss.str() << std::endl;
}

APDUResponse sendAPDU(HANDLE handle, BYTE cla, BYTE ins, BYTE p1, BYTE p2, 
    const std::vector<BYTE>& data, DWORD expectedLength) {
    
    if (!handle) {
        return {0x6F, 0x00, std::vector<BYTE>(), 0, -1};
    }

    std::vector<BYTE> apduCommand;
    apduCommand.reserve(5 + data.size() + (expectedLength > 0 ? 1 : 0));
    
    // Build APDU header
    apduCommand.push_back(cla);
    apduCommand.push_back(ins);
    apduCommand.push_back(p1);
    apduCommand.push_back(p2);

    // Add data length and data if present
    if (!data.empty()) {
        if (data.size() > 255) {
            return {0x6F, 0x00, std::vector<BYTE>(), 0, -1};
        }
        apduCommand.push_back(static_cast<BYTE>(data.size()));
        apduCommand.insert(apduCommand.end(), data.begin(), data.end());
    }

    if (expectedLength > 0) {
        apduCommand.push_back(static_cast<BYTE>(expectedLength));
    }

    logAPDU("Send", apduCommand);

    DWORD bytesWritten = 0;
    if (WriteDevice(handle, apduCommand.data(), apduCommand.size(), &bytesWritten) == -1) {
        return {0x6F, 0x00, std::vector<BYTE>(), 0, -1};
    }

    if (bytesWritten != apduCommand.size()) {
        return {0x6F, 0x00, std::vector<BYTE>(), 0, -1};
    }

    std::vector<BYTE> responseBuffer(expectedLength + 2);
    DWORD bytesRead = 0;
    
    if (ReadDevice(handle, responseBuffer.data(), responseBuffer.size(), &bytesRead) == -1) {
        return {0x6F, 0x00, std::vector<BYTE>(), 0, -1};
    }

    logAPDU("Recv", std::vector<BYTE>(responseBuffer.begin(), 
            responseBuffer.begin() + bytesRead));

    APDUResponse response = {0x6F, 0x00, std::vector<BYTE>(), 0, -1};
    
    if (bytesRead >= 2) {
        response.sw1 = responseBuffer[bytesRead - 2];
        response.sw2 = responseBuffer[bytesRead - 1];
        response.dataLength = bytesRead - 2;
        
        if (response.dataLength > 0) {
            response.data.assign(responseBuffer.begin(), 
                               responseBuffer.begin() + response.dataLength);
        }
        
        if (response.sw1 == 0x63 && (response.sw2 & 0xF0) == 0xC0) {
            response.remainingTries = response.sw2 & 0x0F;
        } else {
            response.remainingTries = -1;
        }
    }
    
    return response;
}

int verifyPin(HANDLE handle, const char* pin) {
    if (!handle || !pin) {
        return ERR_PIN_INVALID;
    }
    
    size_t pinLen = strlen(pin);
    if (pinLen < MIN_PIN_LENGTH || pinLen > MAX_PIN_LENGTH) {
        return ERR_PIN_INVALID;
    }

    std::vector<BYTE> pinData = pinToBytes(pin);
    if (pinData.empty()) {
        return ERR_PIN_INVALID;
    }
    
    APDUResponse response = sendAPDU(
        handle,
        APDU_CLA_DEFAULT,
        APDU_INS_VERIFY,
        APDU_P1_DEFAULT,
        APDU_P2_PIN,
        pinData,
        0
    );

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
    if (!handle || !oldPin || !newPin) {
        return ERR_PIN_INVALID;
    }

    size_t oldPinLen = strlen(oldPin);
    size_t newPinLen = strlen(newPin);

    if (oldPinLen < MIN_PIN_LENGTH || oldPinLen > MAX_PIN_LENGTH ||
        newPinLen < MIN_PIN_LENGTH || newPinLen > MAX_PIN_LENGTH) {
        return ERR_PIN_INVALID;
    }

    // Combine old and new PINs
    std::vector<BYTE> pinData;
    pinData.reserve(oldPinLen + newPinLen);
    pinData.insert(pinData.end(), oldPin, oldPin + oldPinLen);
    pinData.insert(pinData.end(), newPin, newPin + newPinLen);

    APDUResponse response = sendAPDU(
        handle,
        APDU_CLA_DEFAULT,
        APDU_INS_CHANGE_PIN,
        APDU_P1_DEFAULT,
        APDU_P2_PIN,
        pinData,
        0
    );

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
    if (!handle) {
        return ERR_INVALID_HANDLE;
    }

    APDUResponse response = sendAPDU(
        handle,
        APDU_CLA_DEFAULT,
        APDU_INS_VERIFY,
        APDU_P1_DEFAULT,
        APDU_P2_PIN,
        std::vector<BYTE>(),
        0
    );

    if (response.remainingTries >= 0) {
        return response.remainingTries;
    }
    return ERR_COMMUNICATION;
}
