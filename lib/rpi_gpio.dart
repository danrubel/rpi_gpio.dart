import 'dart:async';

import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/src/rpi_gpio_impl.dart';
import 'package:rpi_gpio/src/rpi_gpio_isolate.dart';

export 'package:rpi_gpio/src/rpi_gpio_impl.dart';

/// Instantiate a new GPIO manager.
/// By default, you cannot allocate the I2C or SPI pins as GPIO pins.
/// If you want to use the I2C pins as GPIO pins, pass `i2c: false`.
/// If you want to use the SPI pins as GPIO pins, pass `spi: false`.
///
/// If there is an unrecoverable error and onError is not `null`,
/// then onError will be called with a [GpioException].
// ignore: non_constant_identifier_names
Future<RpiGpio> initialize_RpiGpio({
  bool i2c = true,
  bool spi = true,
  bool eeprom = true,
  bool uart = true,
  Completer<GpioException>? onError,
}) =>
    RpiGpio.init(
      i2c: i2c,
      spi: spi,
      eeprom: eeprom,
      uart: uart,
      onError: onError,
      isolateEntryPoint: isolateMain,
    );
