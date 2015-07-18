library test.rpi_gpio;

import 'basic_test.dart' as basic;
import 'interrupts_test.dart' as interrupts;
import 'read_write_test.dart' as read;

main() async {
  basic.main();
  read.main();
  interrupts.main();
}
