/// Mapping from physical pin on RPi model 2 and 3 to BCM GPIO.
const physToBcmGpioRPi2 = <int>[
  -1, //     0
  -1, -1, // 1, 2
  02, -1,
  03, -1,
  04, 14,
  -1, 15,
  17, 18,
  27, -1,
  22, 23,
  -1, 24,
  10, -1,
  09, 25,
  11, 08,
  -1, 07, // 25, 26

// B+

  00, 01, // 27, 28
  05, -1,
  06, 12,
  13, -1,
  19, 16,
  26, 20,
  -1, 21, // 39, 40

// the P5 connector on the Rev 2 boards:

  -1, -1,
  -1, -1,
  -1, -1,
  -1, -1,
  -1, -1,
  28, 29,
  30, 31,
  -1, -1,
  -1, -1,
  -1, -1,
  -1, -1,
];

const physI2CPins = <int>[
  3, // I2C SDA
  5, // I2C SCL
];

const physSpiPins = <int>[
  19, // SPI0 MOSI
  21, // SPI0 MISO
  23, // SPI0 SCLK
  24, // SPI0 CS0
  26, // SPI0 CS1
];

const physEepromPins = <int>[
  27, // Reserved
  28, // Reserved
];

const physUartPins = <int>[
  8, // Uart Tx
  10, // Uart Rx
];
