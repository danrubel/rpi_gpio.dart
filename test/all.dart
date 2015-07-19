library test.rpi_gpio;

import 'basic_test.dart' as basic;
import 'interrupts_test.dart' as interrupts;
import 'read_write_test.dart' as read;
import 'test_util.dart';

main() async {
  await setupHardware();
  runTests();
}

runTests() {
  basic.runTests();
  read.runTests();
  interrupts.runTests();
}
