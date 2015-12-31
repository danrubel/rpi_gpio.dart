import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/gpio_pins.dart';
import 'package:rpi_gpio/wiringpi_gpio.dart';

/// Read current values for pins 0 - 7
main() async {

  // Initialize the hardware
  // See read_with_mocks.dart for testing on non-RaspberryPi platforms
  Gpio.hardware = new WiringPiGPIO();

  // TODO remove the need to call this method
  Gpio.instance;

  for (int pinNum = 0; pinNum < 8; ++pinNum) {
    var p = pin(pinNum, Mode.input);
    print('${p.value} => ${p.description}');
  }
}
