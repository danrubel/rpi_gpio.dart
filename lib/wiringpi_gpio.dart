library wiringpi_gpio;

import 'dart:isolate';

import 'package:rpi_gpio/rpi_gpio.dart';

import 'dart-ext:rpi_gpio_ext';

/// [WiringPiGPIO] provides synchronous access to the underlying wiringPi
/// library on the Raspberry Pi hardware.
class WiringPiGPIO implements RpiGPIO {
  WiringPiGPIO() {
    if (!isRaspberryPi) throw 'only works on Raspberry Pi';
  }

  @override
  int get pins => 20;

  @override
  String description(int pinNum) {
    var buf = new StringBuffer('Pin $pinNum (BMC_GPIO ');
    var gpioNum = _gpioNum(pinNum);
    buf.write(gpioNum is int ? gpioNum : '??');
    buf.write(', Phys ');
    var physNum = this._physNum(pinNum);
    buf.write(physNum is int ? physNum : '??');
    String suffix;
    if (pinNum >= 0 && pinNum <= _descriptionSuffix.length) {
      suffix = _descriptionSuffix[pinNum];
    }
    if (suffix != null) {
      buf.write(', ');
      buf.write(suffix);
    }
    buf.write(')');
    return buf.toString();
  }

  @override
  void disableAllInterrupts() native "disableAllInterrupts";

  @override
  bool getPin(int pinNum) => _digitalRead(pinNum) != 0;

  @override
  void initInterrupts(SendPort port) native "initInterrupts";

  @override
  void setMode(int pin, Mode mode) {
    if (mode == Mode.other) throw 'Cannot set any pin to Mode.other';
    _pinMode(pin, mode.index);
  }

  @override
  void setPin(int pinNum, bool value) {
    _digitalWrite(pinNum, value ? 1 : 0);
  }

  @override
  void setPull(int pinNum, Pull pull) {
    _setPull(pinNum, pull.index);
  }

  @override
  void setPulseWidth(int pinNum, int pulseWidth) native "setPulseWidth";

  @override
  void setTrigger(int pinNum, Trigger trigger) {
    _setTrigger(pinNum, trigger.index);
  }

  // ========== WiringPi Specific API ======================

  int _digitalRead(int pinNum) native "digitalRead";

  void _digitalWrite(int pinNum, int value) native "digitalWrite";

  int _gpioNum(int pinNum) native "wpiPinToGpio";

  void _pinMode(int pinNum, int mode) native "pinMode";

  int _physNum(int pinNum) {
    if (_gpioToPhysNum == null) {
      _gpioToPhysNum = <int, int>{};
      for (int physNum = 0; physNum < 64; ++physNum) {
        int gpioNum = _physPinToGpio(physNum);
        if (gpioNum != -1) {
          _gpioToPhysNum[gpioNum] = physNum;
        }
      }
    }
    while (_physNumList.length <= pinNum) {
      _physNumList.add(_gpioToPhysNum[_gpioNum(_physNumList.length)]);
    }
    return _physNumList[pinNum];
  }

  int _physPinToGpio(int pinNum) native "physPinToGpio";

  void _setPull(int pinNum, int pull) native "setPull";

  int _setTrigger(int pinNum, int trigger) native "setTrigger";
}

/// Indexed by pin number, these strings represent the additional capability
/// of a given GPIO pin and are used to build human readable description
/// of known Raspberry Pi rev 2 GPIO pins.
/// See http://wiringpi.com/pins/special-pin-functions/
const List<String> _descriptionSuffix = const [
  null,
  'PWM',
  null,
  null,
  null,
  null,
  null,
  'Clock',
  'I2C SDA0/1',
  'I2C SCL0/1',
  'SPI CE0',
  'SPI CE1',
  'SPI MOSI',
  'SPI MISO',
  'SPI SCLK',
  'UART TxD, Console',
  'UART RxD, Console',
];

/// Indexed by BCM_GPIO, these are the corresponding physical pin #
/// or `null` if not initialized yet.
Map<int, int> _gpioToPhysNum;

/// Indexed by pin number, these are the corresponding physical pin #.
List<int> _physNumList = [];
