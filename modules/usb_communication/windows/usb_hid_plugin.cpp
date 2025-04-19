#include <windows.h>
#include <setupapi.h>
#include <devguid.h>
#include <iostream>
#include <string>
#include <algorithm>
#include <cctype>
#include "apdu_commands.h"

#pragma comment(lib, "setupapi.lib")

#define FILE_DEVICE_USB 0x00000022
#define IOCTL_WRITE_USB CTL_CODE(FILE_DEVICE_USB, 0x0001, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define IOCTL_READ_USB CTL_CODE(FILE_DEVICE_USB, 0x0002, METHOD_BUFFERED, FILE_ANY_ACCESS)

const GUID MY_USB_GUID = {0xA5DCBF10L, 0x6530, 0x11D2, {0x90, 0x1f, 0x00, 0xc0, 0x4f, 0xb9, 0x51, 0xed}};

// Helper function to convert wide string to narrow string
std::string WideToNarrow(const WCHAR* str) {
    if (!str) return std::string();
    int size_needed = WideCharToMultiByte(CP_UTF8, 0, str, -1, NULL, 0, NULL, NULL);
    std::string strTo(size_needed, 0);
    WideCharToMultiByte(CP_UTF8, 0, str, -1, &strTo[0], size_needed, NULL, NULL);
    if (!strTo.empty() && strTo.back() == 0) strTo.pop_back(); // Remove the null terminator
    return strTo;
}

extern "C" __declspec(dllexport) bool FindUsbDevice(const char* vid, const char* pid, char* devicePath, DWORD devicePathSize) {
    // Use SetupDiGetClassDevsW explicitly because UNICODE is defined
    HDEVINFO deviceInfo = SetupDiGetClassDevsW(&MY_USB_GUID, NULL, NULL, DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);
    if (deviceInfo == INVALID_HANDLE_VALUE) {
        return false;
    }

    SP_DEVICE_INTERFACE_DATA interfaceData;
    interfaceData.cbSize = sizeof(SP_DEVICE_INTERFACE_DATA);

    bool foundDevice = false;

    for (DWORD i = 0; SetupDiEnumDeviceInterfaces(deviceInfo, NULL, &MY_USB_GUID, i, &interfaceData); i++) {
        DWORD requiredSize = 0;
        // Use SetupDiGetDeviceInterfaceDetailW explicitly
        SetupDiGetDeviceInterfaceDetailW(deviceInfo, &interfaceData, NULL, 0, &requiredSize, NULL);

        // Note: MSDN indicates detailData should be allocated based on requiredSize.
        // The DevicePath field is a WCHAR array within this structure.
        PSP_DEVICE_INTERFACE_DETAIL_DATA_W detailData = (PSP_DEVICE_INTERFACE_DETAIL_DATA_W)malloc(requiredSize);
        if (!detailData) {
            continue; // Allocation failed
        }
        detailData->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA_W);

        // Use SetupDiGetDeviceInterfaceDetailW explicitly
        if (SetupDiGetDeviceInterfaceDetailW(deviceInfo, &interfaceData, detailData, requiredSize, NULL, NULL)) {
            // detailData->DevicePath is WCHAR* because UNICODE is defined
            std::string device = WideToNarrow(detailData->DevicePath);
            std::string vid_lower = std::string(vid);
            std::string pid_lower = std::string(pid);

            // Lambda for safe lowercase transformation
            auto tolower_safe = [](unsigned char c) { return static_cast<char>(std::tolower(c)); };

            // Transform the converted narrow string safely
            std::transform(device.begin(), device.end(), device.begin(), tolower_safe);
            std::transform(vid_lower.begin(), vid_lower.end(), vid_lower.begin(), tolower_safe);
            std::transform(pid_lower.begin(), pid_lower.end(), pid_lower.begin(), tolower_safe);

            if (device.find("vid_" + vid_lower) != std::string::npos && device.find("pid_" + pid_lower) != std::string::npos) {
                // Copy the *converted* narrow string to the output buffer
                strncpy_s(devicePath, devicePathSize, device.c_str(), _TRUNCATE);
                foundDevice = true;
                free(detailData);
                break;
            }
        }
        free(detailData);
    }

    SetupDiDestroyDeviceInfoList(deviceInfo);
    return foundDevice;
}

extern "C" __declspec(dllexport) HANDLE OpenDeviceByPath(const char* path) {
    // Use CreateFileA as path is narrow
    HANDLE handle = CreateFileA(
            path,
            GENERIC_READ | GENERIC_WRITE,
            FILE_SHARE_READ | FILE_SHARE_WRITE,
            NULL,
            OPEN_EXISTING,
            FILE_ATTRIBUTE_NORMAL,
            NULL
    );

    if (handle == INVALID_HANDLE_VALUE) {
        std::cerr << "Failed to open device at path: " << path << " with error: " << GetLastError() << std::endl;
    } else {
        std::cout << "Successfully opened device at path: " << path << std::endl;
    }

    return handle;
}

extern "C" __declspec(dllexport) int WriteDevice(HANDLE handle, BYTE* buffer, DWORD bufferSize, DWORD* bytesWritten) {
    DWORD error;
    BOOL success = DeviceIoControl(
            handle,
            IOCTL_WRITE_USB,
            buffer,
            bufferSize,
            NULL,
            0,
            bytesWritten,
            NULL
    );

    if (!success) {
        error = GetLastError();
        std::cerr << "Failed to write to device with error code: " << error << std::endl;
        return error;
    }

    return -1; // Success
}

extern "C" __declspec(dllexport) int ReadDevice(HANDLE handle, BYTE* buffer, DWORD bufferSize, DWORD* bytesRead) {
    BOOL success = DeviceIoControl(
            handle,
            IOCTL_READ_USB,
            NULL,
            0,
            buffer,
            bufferSize,
            bytesRead,
            NULL
    );

    if (!success) {
        DWORD error = GetLastError();
        std::cerr << "Failed to read from device with error code: " << error << std::endl;
        return error;
    }

    return -1; // Success
}

extern "C" __declspec(dllexport) void CloseDevice(HANDLE handle) {
    if (handle != INVALID_HANDLE_VALUE) {
        CloseHandle(handle);
        std::cout << "Device handle closed." << std::endl;
    }
}

// Helper function to send APDU commands to the device
APDUResponse sendAPDU(HANDLE handle, BYTE cla, BYTE ins, BYTE p1, BYTE p2, BYTE* data, DWORD dataLen, DWORD expectedLength) {
    APDUResponse response = {0};
    
    // Prepare command APDU
    DWORD cmdLength = 4 + (data ? dataLen : 0);  // Header + data length
    BYTE* cmdApdu = new BYTE[cmdLength];
    cmdApdu[0] = cla;
    cmdApdu[1] = ins;
    cmdApdu[2] = p1;
    cmdApdu[3] = p2;
    
    if (data && dataLen > 0) {
        memcpy(cmdApdu + 4, data, dataLen);
    }

    // Send command
    DWORD bytesWritten;
    WriteDevice(handle, cmdApdu, cmdLength, &bytesWritten);
    delete[] cmdApdu;

    // Read response
    DWORD respLength = expectedLength + 2; // Expected data + SW1/SW2
    BYTE* respBuffer = new BYTE[respLength];
    DWORD bytesRead;
    
    ReadDevice(handle, respBuffer, respLength, &bytesRead);
    
    if (bytesRead >= 2) {
        response.sw1 = respBuffer[bytesRead - 2];
        response.sw2 = respBuffer[bytesRead - 1];
        
        // Extract data if any
        if (bytesRead > 2) {
            response.dataLength = bytesRead - 2;
            response.data = new BYTE[response.dataLength];
            memcpy(response.data, respBuffer, response.dataLength);
        }
    }
    
    delete[] respBuffer;
    return response;
}

// Implementation of verifyPin function
int verifyPin(HANDLE handle, const char* pin) {
    if (!pin) return ERR_PIN_INVALID;
    
    size_t pinLen = strlen(pin);
    if (pinLen < MIN_PIN_LENGTH) return ERR_PIN_TOO_SHORT;
    if (pinLen > MAX_PIN_LENGTH) return ERR_PIN_TOO_LONG;

    // Convert PIN to bytes
    BYTE* pinData = new BYTE[pinLen];
    for (size_t i = 0; i < pinLen; i++) {
        if (!isdigit(pin[i])) {
            delete[] pinData;
            return ERR_PIN_INVALID;
        }
        pinData[i] = pin[i] - '0';
    }

    // Send verify PIN command
    APDUResponse resp = sendAPDU(handle, APDU_CLA_DEFAULT, APDU_INS_VERIFY, 
                                APDU_P1_DEFAULT, APDU_P2_PIN, 
                                pinData, (DWORD)pinLen, 0);
    
    delete[] pinData;

    // Parse response
    WORD sw = (resp.sw1 << 8) | resp.sw2;
    if (sw == SW_SUCCESS) return MAX_PIN_TRIES;
    if (sw == SW_PIN_BLOCKED) return ERR_PIN_BLOCKED;
    if ((sw & 0xFFF0) == 0x63C0) {
        return (sw & 0x000F); // Return remaining tries
    }
    return ERR_PIN_INVALID;
}

// Implementation of changePin function
int changePin(HANDLE handle, const char* oldPin, const char* newPin) {
    if (!oldPin || !newPin) return ERR_PIN_INVALID;
    
    size_t oldPinLen = strlen(oldPin);
    size_t newPinLen = strlen(newPin);
    
    if (oldPinLen < MIN_PIN_LENGTH || newPinLen < MIN_PIN_LENGTH) return ERR_PIN_TOO_SHORT;
    if (oldPinLen > MAX_PIN_LENGTH || newPinLen > MAX_PIN_LENGTH) return ERR_PIN_TOO_LONG;

    // Verify old PIN first
    int verifyResult = verifyPin(handle, oldPin);
    if (verifyResult < 0) return verifyResult;

    // Prepare change PIN data: old PIN + new PIN
    BYTE* pinData = new BYTE[oldPinLen + newPinLen];
    
    for (size_t i = 0; i < oldPinLen; i++) {
        if (!isdigit(oldPin[i])) {
            delete[] pinData;
            return ERR_PIN_INVALID;
        }
        pinData[i] = oldPin[i] - '0';
    }
    
    for (size_t i = 0; i < newPinLen; i++) {
        if (!isdigit(newPin[i])) {
            delete[] pinData;
            return ERR_PIN_INVALID;
        }
        pinData[oldPinLen + i] = newPin[i] - '0';
    }

    // Send change PIN command
    APDUResponse resp = sendAPDU(handle, APDU_CLA_DEFAULT, APDU_INS_CHANGE_PIN,
                                APDU_P1_DEFAULT, APDU_P2_PIN,
                                pinData, (DWORD)(oldPinLen + newPinLen), 0);
    
    delete[] pinData;

    // Parse response
    WORD sw = (resp.sw1 << 8) | resp.sw2;
    if (sw == SW_SUCCESS) return MAX_PIN_TRIES;
    if (sw == SW_PIN_BLOCKED) return ERR_PIN_BLOCKED;
    if ((sw & 0xFFF0) == 0x63C0) {
        return (sw & 0x000F); // Return remaining tries
    }
    return ERR_PIN_INVALID;
}

// Implementation of getPinRetries function
int getPinRetries(HANDLE handle) {
    // Send get PIN tries command (using verify PIN with empty data)
    APDUResponse resp = sendAPDU(handle, APDU_CLA_DEFAULT, APDU_INS_VERIFY,
                                APDU_P1_DEFAULT, APDU_P2_PIN,
                                nullptr, 0, 0);

    // Parse response
    WORD sw = (resp.sw1 << 8) | resp.sw2;
    if (sw == SW_PIN_BLOCKED) return 0;
    if ((sw & 0xFFF0) == 0x63C0) {
        return (sw & 0x000F); // Return remaining tries
    }
    return MAX_PIN_TRIES; // PIN is not blocked and no error
}

extern "C" __declspec(dllexport) int changePin(const char* oldPin, const char* newPin) {
    // Find the connected device
    char devicePath[256];
    if (!FindUsbDevice("096e", "0850", devicePath, sizeof(devicePath))) {
        return ERR_COMMUNICATION;
    }

    // Open the device
    HANDLE handle = OpenDeviceByPath(devicePath);
    if (handle == INVALID_HANDLE_VALUE) {
        return ERR_COMMUNICATION;
    }

    // Change PIN using APDU commands
    int result = changePin(handle, oldPin, newPin);

    // Close device
    CloseDevice(handle);
    return result;
}

extern "C" __declspec(dllexport) int verifyUserPin(const char* pin) {
    char devicePath[256];
    if (!FindUsbDevice("096e", "0850", devicePath, sizeof(devicePath))) {
        return ERR_COMMUNICATION;
    }

    HANDLE handle = OpenDeviceByPath(devicePath);
    if (handle == INVALID_HANDLE_VALUE) {
        return ERR_COMMUNICATION;
    }

    int result = verifyPin(handle, pin);
    CloseDevice(handle);
    return result;
}

extern "C" __declspec(dllexport) int getRemainingPinTries() {
    char devicePath[256];
    if (!FindUsbDevice("096e", "0850", devicePath, sizeof(devicePath))) {
        return ERR_COMMUNICATION;
    }

    HANDLE handle = OpenDeviceByPath(devicePath);
    if (handle == INVALID_HANDLE_VALUE) {
        return ERR_COMMUNICATION;
    }

    int result = getPinRetries(handle);
    CloseDevice(handle);
    return result;
}

extern "C" __declspec(dllexport) int changePuk(const char* oldPuk, const char* newPuk) {
    char devicePath[256];
    if (!FindUsbDevice("096e", "0850", devicePath, sizeof(devicePath))) {
        return ERR_COMMUNICATION;
    }

    HANDLE handle = OpenDeviceByPath(devicePath);
    if (handle == INVALID_HANDLE_VALUE) {
        return ERR_COMMUNICATION;
    }

    // TODO: Implement the actual PUK change logic
    // For now, return success
    CloseDevice(handle);
    return 0;
}

extern "C" __declspec(dllexport) int changeManagementKey(const char* oldKey, const char* newKey) {
    char devicePath[256];
    if (!FindUsbDevice("096e", "0850", devicePath, sizeof(devicePath))) {
        return ERR_COMMUNICATION;
    }

    HANDLE handle = OpenDeviceByPath(devicePath);
    if (handle == INVALID_HANDLE_VALUE) {
        return ERR_COMMUNICATION;
    }

    // TODO: Implement the actual management key change logic
    // For now, return success
    CloseDevice(handle);
    return 0;
}

extern "C" __declspec(dllexport) int resetToDefaultPin() {
    char devicePath[256];
    if (!FindUsbDevice("096e", "0850", devicePath, sizeof(devicePath))) {
        return ERR_COMMUNICATION;
    }

    HANDLE handle = OpenDeviceByPath(devicePath);
    if (handle == INVALID_HANDLE_VALUE) {
        return ERR_COMMUNICATION;
    }

    // TODO: Implement the actual PIN reset logic
    // For now, return success
    CloseDevice(handle);
    return 0;
}
