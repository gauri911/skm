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
std::string WideToNarrow(const wchar_t* str) {
    if (!str) return std::string();
    int size_needed = WideCharToMultiByte(CP_UTF8, 0, str, -1, NULL, 0, NULL, NULL);
    std::string strTo(size_needed, 0);
    WideCharToMultiByte(CP_UTF8, 0, str, -1, &strTo[0], size_needed, NULL, NULL);
    if (!strTo.empty() && strTo.back() == 0) strTo.pop_back(); // Remove the null terminator
    return strTo;
}

// Helper function for case-insensitive string conversion
std::string ToLower(const std::string& str) {
    std::string result = str;
    std::transform(result.begin(), result.end(), result.begin(),
                  [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
    return result;
}

extern "C" __declspec(dllexport) bool FindUsbDevice(const char* vid, const char* pid, char* devicePath, DWORD devicePathSize) {
    HDEVINFO deviceInfo = SetupDiGetClassDevs(&MY_USB_GUID, NULL, NULL, DIGCF_PRESENT | DIGCF_DEVICEINTERFACE);
    if (deviceInfo == INVALID_HANDLE_VALUE) {
        return false;
    }

    SP_DEVICE_INTERFACE_DATA interfaceData;
    interfaceData.cbSize = sizeof(SP_DEVICE_INTERFACE_DATA);

    bool foundDevice = false;

    for (DWORD i = 0; SetupDiEnumDeviceInterfaces(deviceInfo, NULL, &MY_USB_GUID, i, &interfaceData); i++) {
        DWORD requiredSize = 0;
        SetupDiGetDeviceInterfaceDetail(deviceInfo, &interfaceData, NULL, 0, &requiredSize, NULL);

        PSP_DEVICE_INTERFACE_DETAIL_DATA detailData = (PSP_DEVICE_INTERFACE_DETAIL_DATA)malloc(requiredSize);
        detailData->cbSize = sizeof(SP_DEVICE_INTERFACE_DETAIL_DATA);

        if (SetupDiGetDeviceInterfaceDetail(deviceInfo, &interfaceData, detailData, requiredSize, NULL, NULL)) {
            std::string device = ToLower(WideToNarrow(detailData->DevicePath));
            std::string vid_lower = ToLower(std::string(vid));
            std::string pid_lower = ToLower(std::string(pid));

            if (device.find("vid_" + vid_lower) != std::string::npos && device.find("pid_" + pid_lower) != std::string::npos) {
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
            IOCTL_WRITE_USB, // Use the defined IOCTL code here
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
            IOCTL_READ_USB, // Replace with the appropriate IOCTL code for reading
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
