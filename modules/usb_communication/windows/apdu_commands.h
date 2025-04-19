#pragma once

#include <windows.h>

// APDU Command Constants
#define APDU_CLA_DEFAULT       0x00
#define APDU_INS_VERIFY       0x20
#define APDU_INS_CHANGE_PIN   0x24

// PIN-specific P1/P2 parameters
#define APDU_P1_DEFAULT       0x00
#define APDU_P2_PIN          0x80
#define APDU_P2_PUK          0x81

// Status Words
#define SW_SUCCESS           0x9000
#define SW_AUTH_FAILED       0x6300
#define SW_WRONG_LENGTH      0x6700
#define SW_PIN_BLOCKED       0x6983
#define SW_PIN_INVALID       0x6984

// PIN constraints
#define MIN_PIN_LENGTH       4
#define MAX_PIN_LENGTH       8
#define MAX_PIN_TRIES        3

// Error codes
#define ERR_PIN_TOO_SHORT    -1
#define ERR_PIN_TOO_LONG     -2
#define ERR_PIN_INVALID      -3
#define ERR_PIN_BLOCKED      -4
#define ERR_COMMUNICATION    -5

// APDU response structure
struct APDUResponse {
    BYTE sw1;
    BYTE sw2;
    BYTE* data;
    DWORD dataLength;
    int remainingTries;
};

// Function declarations
int verifyPin(HANDLE handle, const char* pin);
int changePin(HANDLE handle, const char* oldPin, const char* newPin);
int getPinRetries(HANDLE handle);
APDUResponse sendAPDU(HANDLE handle, BYTE cla, BYTE ins, BYTE p1, BYTE p2, BYTE* data, DWORD dataLen, DWORD expectedLength);