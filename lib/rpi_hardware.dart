library rpi_hardware;

import 'package:rpi_gpio/rpi_gpio.dart';

import 'dart-ext:rpi_gpio_ext';

/// [RpiHardware] provides synchronous access to the underlying wiringPi
/// library on the Raspberry Pi hardware.
class RpiHardware implements GpioHardware {
  RpiHardware() {
    if (!isRaspberryPi) throw 'only works on Raspberry Pi';
  }

  @override
  int digitalRead(int pin) native "digitalRead";

  @override
  void digitalWrite(int pin, int value) native "digitalWrite";

  @override
  void pinMode(int pin, int mode) native "pinMode";

  @override
  void pullUpDnControl(int pin, int pud) native "pullUpDnControl";

  @override
  void pwmWrite(int pin, int pulseWidth) native "pwmWrite";
}
