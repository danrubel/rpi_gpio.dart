import 'package:test/test.dart';

import 'basic_test.dart' as basic;
import 'debouncer_test.dart' as debouncer;
import 'example_test.dart' as example;
import 'src/polling_node_test.dart' as polling_node;
import 'src/pwm_node_test.dart' as pwm_node;

main() {
  group('polling', () => polling_node.main());
  group('pwm', () => pwm_node.main());
  group('basic', () => basic.main());
  group('debouncer', () => debouncer.main());
  group('example', () => example.main());
}
