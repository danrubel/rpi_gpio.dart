import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_gpio/rpi_hardware.dart';

/// Read current values for pins 0 - 7
main() async {

  // Initialize the hardware
  // See read_with_mocks.dart for testing on non-RaspberryPi platforms
  Gpio.hardware = new RpiHardware();

  var gpio = Gpio.instance;
  for (int pinNum = 0; pinNum < 8; ++pinNum) {
    var pin = gpio.pin(pinNum, input);
    print('${pin.value} => ${pin.description}');
  }
}
