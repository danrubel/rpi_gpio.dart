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
  bool getPin(int pinNum) => digitalRead(pinNum) != 0;

  @override
  void setMode(int pin, Mode mode) {
    if (mode == Mode.other) throw 'Cannot set any pin to Mode.other';
    pinMode(pin, mode.index);
  }

  @override
  void setPin(int pinNum, bool value) {
    digitalWrite(pinNum, value ? 1 : 0);
  }

  @override
  void setPull(int pinNum, Pull pull) {
    _setPull(pinNum, pull.index);
  }

  void _setPull(int pinNum, int pull) native "setPull";

  @override
  void setTrigger(int pinNum, Trigger trigger) {
    _setTrigger(pinNum, trigger.index);
  }

  int _setTrigger(int pinNum, int trigger) native "setTrigger";

  // ========== WiringPi Specific API ======================

  int digitalRead(int pinNum) native "digitalRead";

  void digitalWrite(int pinNum, int value) native "digitalWrite";

  @override
  void disableAllInterrupts() native "disableAllInterrupts";

  @override
  int gpioNum(int pinNum) native "wpiPinToGpio";

  @override
  void initInterrupts(SendPort port) native "initInterrupts";

  void pinMode(int pinNum, int mode) native "pinMode";

  @override
  int physPinToGpio(int pinNum) native "physPinToGpio";

  @override
  void pwmWrite(int pinNum, int pulseWidth) native "pwmWrite";
}
