import 'package:ffi/ffi.dart';
import 'package:rpi_gpio/src/native/gpiod_ext.dart' as gpio;

void main() async {
  print(gpio.findNativePkgLibPath());

  var gpioLib = gpio.nativePkgLib;

  var result = gpioLib.gpiodVersionString();
  var text = result.toDartString();

  gpioLib.close();

  print(text);
}
