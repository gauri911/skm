#include <windows.h>
#include <setupapi.h>
#include <devguid.h>
#include <iostream>
#include <string>
#include <algorithm>
#include <cctype>

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

extern "C" __declspec(dllexport) int changePin(const char* oldPin, const char* newPin) {
    // Implementation for changing PIN on the FIDO key.
    // Add specific logic for communicating with the FIDO device
    // and sending the necessary commands for changing the PIN.

    // Example code logic (pseudo-implementation):
    // 1. Validate old PIN
    // 2. Encrypt and send new PIN
    // Return 0 for success, non-zero for failure
    return 0; // Temporary placeholder for success
}
