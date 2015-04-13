import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:rpi_gpio/rpi_gpio.dart';

const rpiGpioPkgName = 'rpi_gpio';
const buildScriptVersion = 1;

main(List<String> args) {

  // Locate the Dart SDK
  var dartVm = new File(Platform.executable);
  print('Dart VM... ${dartVm.path}');
  var dartSdk = dartVm.parent.parent;
  print('Dart SDK... ${dartSdk.path}');
  var headerFile = new File(join(dartSdk.path, 'include', 'dart_api.h'));
  assertExists('include file', headerFile);

  // Run pub list to determine the location of the GPIO package being used
  var pubResult = JSON.decode(Process.runSync(
      join(dartSdk.path, 'bin', 'pub'), ['list-package-dirs']).stdout);
  assertNoPubListError(pubResult);
  var rpiGpioDir = new Directory(pubResult['packages'][rpiGpioPkgName]);
  print('Building library in ${rpiGpioDir.path}');

  // Display the version of the rpi_gpio being built
  var pubspecFile = new File(join(rpiGpioDir.path, 'pubspec.yaml'));
  assertExists('pubspec', pubspecFile);
  var pubspec = pubspecFile.readAsStringSync();
  print('rpi_gpio version ${parseVersion(pubspec)}');

  // Build the native library
  var nativeDir = new Directory(join(rpiGpioDir.path, 'src', 'native'));
  var buildScriptFile = new File(join(nativeDir.path, 'build_lib'));
  assertRunningOnRaspberryPi();
  var buildResult = Process.runSync(
      buildScriptFile.path, [buildScriptVersion.toString(), dartSdk.path]);
  print(buildResult.stdout);
  print(buildResult.stderr);
}

/// Parse the given content and return the version string
String parseVersion(String pubspec) {
  var key = 'version:';
  int start = pubspec.indexOf(key) + key.length;
  int end = pubspec.indexOf('\n', start);
  return pubspec.substring(start, end).trim();
}

/// Assert that the given file or directory exists.
assertExists(String name, FileSystemEntity entity) {
  if (entity.existsSync()) return;
  print('Failed to find $name: ${entity.path}');
  throw 'Aborting build';
}

/// Assert that the given pub list result does not indicate an error
void assertNoPubListError(Map<String, String> pubResult) {
  var error = pubResult['error'];
  if (error == null) {
    var packages = pubResult['packages'];
    if (packages != null) {
      var rpiGpio = packages[rpiGpioPkgName];
      if (rpiGpio != null) {
        return;
      }
      print('Cannot find $rpiGpioPkgName in pub list result');
      print('Must run this script on app referencing $rpiGpioPkgName package');
      throw 'Aborting build';
    }
    print('Cannot find packages in pub list result');
    throw 'Aborting build';
  }
  print(error);
  print('Must run this script from directory containing pubspec.yaml file');
  throw 'Aborting build';
}

/// Assert that this script is executing on the Raspberry Pi.
assertRunningOnRaspberryPi() {
  if (!isRaspberryPi) {
    if (Platform.isLinux) {
      print('Marker file not found: ${raspberryPiMarkerFile.absolute.path}');
      print('If this is running on a Raspberry Pi, please create this file');
    } else {
      print('Not running on Raspberry Pi... skipping build');
    }
    throw 'Aborting build';
  }
}
