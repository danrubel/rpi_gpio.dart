import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/rpi_hardware.dart' deferred as rpi;

/// Read current values for pins 0 - 7
main() async {

  if (isRaspberryPi) {
    // Initialize the underlying hardware library
    await rpi.loadLibrary();
    Gpio.hardware = new rpi.RpiHardware();
  } else {
    // Mock the hardware when testing
    print('>>> initializing mock hardware');
    Gpio.hardware = new MockHardware();
  }

  for (int pinNum = 0; pinNum < 8; ++pinNum) {
    print('${pin(pinNum, Mode.input).value} => ${pin(pinNum, Mode.input).description}');
  }
}

/// Simulate hardware when testing.
class MockHardware implements GpioHardware {

  /// Simulate all pins return value of 1 (high).
  int digitalRead(int pinNum) => 1;

  /// Called to set pin in input mode.
  void pinMode(int pinNum, int mode) {}

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
