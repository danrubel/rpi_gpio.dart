import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/rpi_gpio.dart';

/// Read some pin values.
main() async {
  final gpio = new RpiGpio();
  final inputs = <int, GpioInput>{};

  const [3, 5, 7, 11, 12, 13].forEach((int physicalPin) {
    inputs[physicalPin] = gpio.input(physicalPin);
  });

  inputs.forEach((int physicalPin, GpioInput input) {
    print('pin $physicalPin = ${input.value}');
  });
}
