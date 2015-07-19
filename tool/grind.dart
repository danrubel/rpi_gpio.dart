import 'dart:async';
import 'dart:io';

import 'package:grinder/grinder.dart';

import '../test/test_util.dart';

main(args) => grind(args);

@Task()
void analyze() {
  /*
  Skip analyze because tuneup check gives the following warning
  that does not make sense:
    [warning] The argument type 'GpioHardware
    (/home/travis/build/danrubel/rpi_gpio.dart/lib/rpi_gpio.dart)'
    cannot be assigned to the parameter type 'GpioHardware
    (/home/travis/build/danrubel/rpi_gpio.dart/lib/rpi_gpio.dart)'
    at lib/rpi_gpio.dart, line 89.
   */
  print('>>> TODO: revisit analyze tuneup check');
  //new PubApp.global('tuneup')..run(['check']);
}


@DefaultTask()
@Depends(analyze, test, coverage)
void buildbot() => null;

@Task('Gather and send coverage data.')
void coverage() {
  final String coverageToken = Platform.environment['REPO_TOKEN'];
  if (coverageToken != null) {
    PubApp coverallsApp = new PubApp.global('dart_coveralls');
    coverallsApp.run([
      'report',
      '--token', coverageToken,
      '--retry', '2',
      '--exclude-test-files',
      'test/all.dart'
    ]);
  } else {
    log('Skipping coverage task: no environment variable `REPO_TOKEN` found.');
  }
}

@Task()
Future test() async {
  print(Directory.current);
  await setupHardware();
  new TestRunner().testAsync(files: 'test/all.dart');
}
