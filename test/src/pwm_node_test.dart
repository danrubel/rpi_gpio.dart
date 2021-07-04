import 'dart:async';

import 'package:rpi_gpio/src/pwm_node.dart';
import 'package:test/test.dart';

void main() {
  test('remove null', () {
    expect(firstPwmNode, isNull);
    var node = removePwmNode(7);
    expect(node, isNull);
  });

  test('add/remove one', () async {
    expect(firstPwmNode, isNull);
    final newNode = MockPwmNode(7, 50);

    addPwmNode(newNode);
    expect(firstPwmNode, same(newNode));
    expect(firstPwmNode!.nextNode, isNull);
    expect(firstPwmNode!.nextNode, isNull);
    expect(newNode.state, true);
    expect(currentPwmTick, 50);

    newNode.stateChanged = Completer<bool>();
    expect(await newNode.stateChanged!.future, isFalse);
    expect(currentPwmTick, 0);

    newNode.stateChanged = Completer<bool>();
    expect(await newNode.stateChanged!.future, isTrue);
    expect(currentPwmTick, 50);

    newNode.stateChanged = Completer<bool>();
    expect(await newNode.stateChanged!.future, isFalse);
    expect(currentPwmTick, 0);

    var node = removePwmNode(8);
    expect(node, isNull);
    expect(firstPwmNode, same(newNode));
    expect(firstPwmNode!.nextNode, isNull);

    node = removePwmNode(7);
    expect(node, same(newNode));
    expect(firstPwmNode, isNull);
  });

  test('add/remove three', () async {
    expect(firstPwmNode, isNull);
    final newNode1 = MockPwmNode(7, 50);
    final newNode2 = MockPwmNode(9, 25);
    final newNode3 = MockPwmNode(11, 75);

    addPwmNode(newNode1);
    addPwmNode(newNode2);
    addPwmNode(newNode3);
    expect(firstPwmNode, same(newNode2));
    expect(firstPwmNode!.nextNode, same(newNode1));
    expect(firstPwmNode!.nextNode!.nextNode, same(newNode3));
    expect(firstPwmNode!.nextNode!.nextNode!.nextNode, isNull);
    expect(newNode1.state, false);
    expect(newNode2.state, false);
    expect(newNode3.state, false);
    expect(currentPwmTick, 0);

    newNode1.stateChanged = Completer<bool>();
    expect(await newNode1.stateChanged!.future, isTrue);
    expect(newNode1.state, true);
    expect(newNode2.state, true);
    expect(newNode3.state, true);
    expect(currentPwmTick, 25);

    newNode2.stateChanged = Completer<bool>();
    expect(await newNode2.stateChanged!.future, isFalse);
    expect(newNode1.state, true);
    expect(newNode2.state, false);
    expect(newNode3.state, true);
    expect(currentPwmTick, 50);

    newNode1.stateChanged = Completer<bool>();
    expect(await newNode1.stateChanged!.future, isFalse);
    expect(newNode1.state, false);
    expect(newNode2.state, false);
    expect(newNode3.state, true);
    expect(currentPwmTick, 75);

    newNode3.stateChanged = Completer<bool>();
    expect(await newNode3.stateChanged!.future, isFalse);
    expect(newNode1.state, false);
    expect(newNode2.state, false);
    expect(newNode3.state, false);
    expect(currentPwmTick, 0);

    newNode1.stateChanged = Completer<bool>();
    expect(await newNode1.stateChanged!.future, isTrue);
    expect(newNode1.state, true);
    expect(newNode2.state, true);
    expect(newNode3.state, true);
    expect(currentPwmTick, 25);

    var node = removePwmNode(8);
    expect(node, isNull);
    expect(firstPwmNode, same(newNode2));
    expect(firstPwmNode!.nextNode, same(newNode1));
    expect(firstPwmNode!.nextNode!.nextNode, same(newNode3));
    expect(firstPwmNode!.nextNode!.nextNode!.nextNode, isNull);

    newNode2.stateChanged = Completer<bool>();
    expect(await newNode2.stateChanged!.future, isFalse);
    expect(newNode1.state, true);
    expect(newNode2.state, false);
    expect(newNode3.state, true);
    expect(currentPwmTick, 50);

    node = removePwmNode(7);
    expect(node, same(newNode1));
    expect(firstPwmNode, same(newNode2));
    expect(firstPwmNode!.nextNode, same(newNode3));
    expect(firstPwmNode!.nextNode!.nextNode, isNull);

    newNode3.stateChanged = Completer<bool>();
    expect(await newNode3.stateChanged!.future, isFalse);
    expect(newNode1.state, true); // removed before turned off
    expect(newNode2.state, false);
    expect(newNode3.state, false);
    expect(currentPwmTick, 0);

    node = removePwmNode(11);
    expect(node, same(newNode3));
    expect(firstPwmNode, same(newNode2));
    expect(firstPwmNode!.nextNode, isNull);

    newNode2.stateChanged = Completer<bool>();
    expect(await newNode2.stateChanged!.future, isTrue);
    expect(newNode1.state, true); // removed before turned off
    expect(newNode2.state, true);
    expect(newNode3.state, false); // removed when off
    expect(currentPwmTick, 25);

    newNode2.stateChanged = Completer<bool>();
    expect(await newNode2.stateChanged!.future, isFalse);
    expect(newNode1.state, true); // removed before turned off
    expect(newNode2.state, false);
    expect(newNode3.state, false); // removed when off
    expect(currentPwmTick, 0);

    newNode2.stateChanged = Completer<bool>();
    expect(await newNode2.stateChanged!.future, isTrue);
    expect(newNode1.state, true); // removed before turned off
    expect(newNode2.state, true);
    expect(newNode3.state, false); // removed when off
    expect(currentPwmTick, 25);

    addPwmNode(newNode3);
    expect(firstPwmNode, same(newNode2));
    expect(firstPwmNode!.nextNode, same(newNode3));
    expect(firstPwmNode!.nextNode!.nextNode, isNull);

    node = removePwmNode(9);
    expect(node, same(newNode2));
    expect(firstPwmNode, same(newNode3));
    expect(firstPwmNode!.nextNode, isNull);
  });

  tearDown(() {
    stopPwm();
  });
}

class MockPwmNode extends PwmNode {
  bool state = false;
  Completer<bool>? stateChanged;

  MockPwmNode(int bcmGpioPin, int dutyCycle) : super(bcmGpioPin, dutyCycle);

  @override
  void write(bool newValue) {
    state = newValue;
    stateChanged?.complete(newValue);
    stateChanged = null;
  }
}
