import 'dart:async';

import 'package:rpi_gpio/gpio.dart';

Future runInput4(Gpio gpio) async {
  // Allocate pins as input
  var button1 = gpio.input(11, Pull.up);
  var button2 = gpio.input(15, Pull.up);
  var button3 = gpio.input(16, Pull.up);
  var button4 = gpio.input(13, Pull.up);

  // Set polling
  gpio.pollingFrequency = const Duration(milliseconds: 100);

  // Track number of buttons pressed
  var buttonsPressed = <int>{};
  var run = true;

  // Handle a button press
  void handleButton(int buttonNum, bool event) {
    var pressed = !event;
    if (pressed) {
      buttonsPressed.add(buttonNum);
    } else {
      buttonsPressed.remove(buttonNum);
    }
    print('button $buttonNum ${pressed ? 'pressed ' : 'released'}, '
        '  ${buttonsPressed.length} button(s) pressed');
    if (buttonsPressed.length > 1) {
      run = false;
    }
  }

  // Listen for changes
  var listener1 = button1.values.listen((event) => handleButton(1, event));
  var listener2 = button2.values.listen((event) => handleButton(2, event));
  var listener3 = button3.values.listen((event) => handleButton(3, event));
  var listener4 = button4.values.listen((event) => handleButton(4, event));

  // Wait for button events
  var timer = Timer(const Duration(seconds: 15), () {
    print('timer called');
    run = false;
  });
  print('running');
  while (run) {
    await Future.delayed(const Duration(milliseconds: 200));
  }
  print('stopping');
  timer.cancel();

  // Cleanup
  await listener4.cancel();
  await listener3.cancel();
  await listener2.cancel();
  await listener1.cancel();
  await gpio.dispose();

  print('finished');
}
