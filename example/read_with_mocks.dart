import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/gpio_pins.dart';
import 'package:rpi_gpio/rpi_gpio.dart' show isRaspberryPi, RpiGPIO;
import 'package:rpi_gpio/wiringpi_gpio.dart' deferred as rpi;

/// Read current values for pins 0 - 7
main() async {
  if (isRaspberryPi) {
    // Initialize the underlying GPIO API library
    await rpi.loadLibrary();
    Pin.gpio = new rpi.WiringPiGPIO();
  } else {
    // Mock the GPIO library when testing
    print('>>> initializing mock GPIO');
    Pin.gpio = new MockGPIO();
  }

  for (int pinNum = 0; pinNum < 8; ++pinNum) {
    var p = pin(pinNum, Mode.input);
    print('${p.value} => ${p.description}');
  }
}

/// Simulate GPIO API when testing.
class MockGPIO implements RpiGPIO {
  /// Simulate all pins return value of 1 (high).
  @override
  bool getPin(int pin) => true;

  @override
  void setMode(int pin, Mode mode) {}

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
