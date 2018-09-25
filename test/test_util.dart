import 'dart:io';

import 'package:rpi_gpio/gpio.dart';
import 'package:test/test.dart';

/// Shared GPIO instance
Gpio gpio;

expectThrows(f()) {
  try {
    f();
    fail('expected exception');
  } on GpioException {
    // Expected... fall through
  }
}

int get nowMillis => new DateTime.now().millisecondsSinceEpoch;

/// Return [true] if this is running on a Raspberry Pi.
bool get isRaspberryPi {
  if (Platform.isLinux) {
    try {
      return new File('/etc/os-release')
          .readAsLinesSync()
          .contains('ID=raspbian');
    } on FileSystemException catch (_) {
      // fall through
    }
  }
  return false;
}
