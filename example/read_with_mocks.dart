import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/gpio_pins.dart';
import 'package:rpi_gpio/rpi_gpio.dart' show isRaspberryPi, RpiGPIO;
import 'package:rpi_gpio/wiringpi_gpio.dart' deferred as rpi;

/// Read current values for pins 0 - 7
main() async {
  if (isRaspberryPi) {
    // Initialize the underlying hardware library
    await rpi.loadLibrary();
    Gpio.hardware = new rpi.WiringPiGPIO();
  } else {
    // Mock the hardware when testing
    print('>>> initializing mock hardware');
    Gpio.hardware = new MockHardware();
  }

  for (int pinNum = 0; pinNum < 8; ++pinNum) {
    var p = pin(pinNum, Mode.input);
    print('${p.value} => ${p.description}');
  }
}

/// Simulate hardware when testing.
class MockHardware implements RpiGPIO {
  /// Simulate all pins return value of 1 (high).
  @override
  bool getPin(int pin) => true;

  @override
  void setMode(int pin, Mode mode) {}

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
