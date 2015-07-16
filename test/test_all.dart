library test.rpi_gpio;

import 'package:unittest/unittest.dart';

import 'basic_test.dart' as basic;
import 'interrupts_test.dart' as interrupts;
import 'read_write_test.dart' as read;
import 'test_util.dart';

main() async {
  basic.main();
  read.main();
  interrupts.main();
}
