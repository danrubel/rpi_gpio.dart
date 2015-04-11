library test.hardware.blink;

import 'dart:async';

import 'package:rpi_gpio/rpi_hardware.dart';
import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/rpi_isolate.dart';
import 'dart:isolate';

/// Drive a motor connected to a DRV8833 circuit which in turn is connected
/// to pins 1 and 2. Vary the motor speed using pulse width modulation.
/// Since the RPi only has one hardware pin capable of pwm,
/// we must simulate pwm in software for the other pin using [GpioClient].
/// GPIO 1 (BMC_GPIO 18, Physical Pin 12) uses hardware pwm.
/// GPIO 2 (BMC_GPIO 27, Physical Pin 13) uses software pwm.
main() async {
  GpioClient client = new GpioClient();
  await client.spawn(_runGpioServer);
  Gpio.hardware = client;
  var gpio = Gpio.instance;

  var pin1 = gpio.pin(1, pulsed);
  var pin2 = gpio.pin(2, pulsed);

  var speed1 = 64;
  var speed2 = 128;
  var speed3 = 512;
  var speed4 = 1024;

  pin1.pulseWidth = speed1;
  await _delay(2000);
  pin1.pulseWidth = speed2;
  await _delay(2000);
  pin1.pulseWidth = speed3;
  await _delay(2000);
  pin1.pulseWidth = speed4;
  await _delay(2000);
  pin1.pulseWidth = speed3;
  await _delay(2000);
  pin1.pulseWidth = speed2;
  await _delay(2000);
  pin1.pulseWidth = speed1;
  await _delay(2000);
  pin1.pulseWidth = 0;

  await _delay(2000);

  pin2.pulseWidth = speed1;
  await _delay(2000);
  pin2.pulseWidth = speed2;
  await _delay(2000);
  pin2.pulseWidth = speed3;
  await _delay(2000);
  pin2.pulseWidth = speed4;
  await _delay(2000);
  pin2.pulseWidth = speed3;
  await _delay(2000);
  pin2.pulseWidth = speed2;
  await _delay(2000);
  pin2.pulseWidth = speed1;
  await _delay(2000);
  pin2.pulseWidth = 0;

  pin1.mode = input;
  pin2.mode = input;

  client.stop();
}

Future _delay(int milliseconds) async {
  await new Future.delayed(new Duration(milliseconds: milliseconds));
}

/// Run the [_GpioServer] which interacts directly with the hardware
/// and provids/simulates PWM for pins other than pin 1.
Future _runGpioServer(SendPort sendPort) async {
  new GpioServer(new RpiHardware(), sendPort).run();
}
