library rpi_hardware;

import 'dart:isolate';

import 'package:rpi_gpio/rpi_gpio.dart';

import 'dart-ext:rpi_gpio_ext';

/// [RpiHardware] provides synchronous access to the underlying wiringPi
/// library on the Raspberry Pi hardware.
class RpiHardware implements GpioHardware {
  RpiHardware() {
    if (!isRaspberryPi) throw 'only works on Raspberry Pi';
  }

  @override
  int digitalRead(int pinNum) native "digitalRead";

  @override
  void digitalWrite(int pinNum, int value) native "digitalWrite";

  @override
  void disableAllInterrupts() native "disableAllInterrupts";

  @override
  int enableInterrupt(int pinNum) native "enableInterrupt";

  @override
  void initInterrupts(SendPort port) native "initInterrupts";

  @override
  void pinMode(int pinNum, int mode) native "pinMode";

  @override
  void pullUpDnControl(int pinNum, int pud) native "pullUpDnControl";

  @override
  void pwmWrite(int pinNum, int pulseWidth) native "pwmWrite";
}
