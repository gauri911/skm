#pragma once

#ifdef __cplusplus
extern "C" {
#endif

__declspec(dllexport) const char* FindDevice(const char* vendorId, const char* productId);
__declspec(dllexport) int OpenDevice(const char* path);
__declspec(dllexport) int CloseDevice(int handle);
__declspec(dllexport) int WriteData(int handle, const unsigned char* data, int length);
__declspec(dllexport) int ReadData(int handle, unsigned char* buffer, int length);
__declspec(dllexport) int ChangePin(const char* oldPin, const char* newPin);
__declspec(dllexport) int SetDeviceTimeout(int handle, int timeoutMs);
__declspec(dllexport) int IsDeviceConnected(int handle);
__declspec(dllexport) const char* GetDeviceInfo(int handle);

#ifdef __cplusplus
}
#endif 