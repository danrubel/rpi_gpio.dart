import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/rpi_hardware.dart' deferred as rpi;

/// Read current values for pins 0 - 7
main() {

  if (isRaspberryPi) {
    // Initialize the underlying hardware library
    rpi.loadLibrary();
    Gpio.hardware = new rpi.RpiHardware();
  } else {
    // Mock the hardware when testing
    Gpio.hardware = new MockHardware();
  }

  var gpio = Gpio.instance;
  for (int pinNum = 0; pinNum < 8; ++pinNum) {
    var pin = gpio.pin(pinNum, input);
    print('${pin.value} => ${pin.description}');
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
