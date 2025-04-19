class PIVConstants {
  static const String DEFAULT_PIN = '123456';
  static const String DEFAULT_PUK = '12345678';
  static const String DEFAULT_MANAGEMENT_KEY =
      'FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF';

  // Application IDs
  static const List<int> PIV_AID = [
    0xA0,
    0x00,
    0x00,
    0x03,
    0x08,
    0x00,
    0x00,
    0x10,
    0x00,
    0x01,
    0x00,
  ];

  // Command Instructions
  static const int INS_VERIFY = 0x20;
  static const int INS_CHANGE_REFERENCE = 0x24;
  static const int INS_RESET_RETRY = 0x2C;
  static const int INS_GENERATE_ASYMMETRIC = 0x47;
  static const int INS_AUTHENTICATE = 0x87;
  static const int INS_GET_DATA = 0xCB;
  static const int INS_PUT_DATA = 0xDB;

  // Key references
  static const int KEY_REF_PIV_PIN = 0x80;
  static const int KEY_REF_PUK = 0x81;
  static const int KEY_REF_MANAGEMENT = 0x9B;

  // Algorithm IDs
  static const int ALG_3DES = 0x03;
  static const int ALG_RSA_2048 = 0x07;
  static const int ALG_ECC_256 = 0x11;

  // Status words
  static const int SW_SUCCESS = 0x9000;
  static const int SW_AUTH_FAILED = 0x6300;
  static const int SW_WRONG_LENGTH = 0x6700;
  static const int SW_SECURITY_CONDITION = 0x6982;
  static const int SW_AUTH_METHOD_BLOCKED = 0x6983;
  static const int SW_COMMAND_NOT_ALLOWED = 0x6986;
  static const int SW_INCORRECT_PARAM = 0x6A80;
  static const int SW_NOT_FOUND = 0x6A82;
  static const int SW_INCORRECT_P1P2 = 0x6A86;
  static const int SW_INS_NOT_SUPPORTED = 0x6D00;
  static const int SW_CLA_NOT_SUPPORTED = 0x6E00;
}
