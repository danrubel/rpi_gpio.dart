import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

const rpiGpioPkgName = 'rpi_gpio';
const buildScriptVersion = 2;

main(List<String> args) {
  // Locate the Dart SDK
  File dartVm = new File(Platform.executable);
  print('Dart VM... ${dartVm.path}');
  if (!dartVm.isAbsolute) {
    dartVm = new File.fromUri(Directory.current.uri.resolve(dartVm.path));
    print('Dart VM... ${dartVm.path}');
  }
  abortIf(!dartVm.isAbsolute, 'Failed to find absolute path to Dart VM');

  // Locate Dart SDK
  final dartSdk = dartVm.parent.parent;
  print('Dart SDK... ${dartSdk.path}');

  // Locate dart_api.h
  final headerPath = 'include/dart_api.h';
  final headerFile = new File.fromUri(dartSdk.uri.resolve(headerPath));
  abortIf(!headerFile.existsSync(), 'Failed to find $headerPath');

  // Run pub list to determine the location of the GPIO package being used
  final pub = new File.fromUri(dartSdk.uri.resolve('bin/pub'));
  final pubOut = Process.runSync(pub.path, ['list-package-dirs']).stdout;
  final pubResult = jsonDecode(pubOut);
  assertNoPubListError(pubResult);
  final rpiGpioDir = new Directory(pubResult['packages'][rpiGpioPkgName]);
  print('Building library in ${rpiGpioDir.path}');

  // Display the version of the rpi_gpio being built
  final pubspecFile = new File(join(rpiGpioDir.path, '..', 'pubspec.yaml'));
  abortIf(!pubspecFile.existsSync(), 'Failed to find ${pubspecFile.path}');
  final pubspec = pubspecFile.readAsStringSync();
  print('rpi_gpio version ${parseVersion(pubspec)}');

  // Build the native library
  final nativeDir = new Directory(join(rpiGpioDir.path, 'src', 'native'));
  final buildScriptFile = new File(join(nativeDir.path, 'build_lib'));
  assertRunningOnRaspberryPi();
  final buildResult = Process.runSync(
      buildScriptFile.path, [buildScriptVersion.toString(), dartSdk.path]);
  print(buildResult.stdout);
  print(buildResult.stderr);
  if (buildResult.exitCode != 0) exit(buildResult.exitCode);
}

/// Parse the given content and return the version string
String parseVersion(String pubspec) {
  var key = 'version:';
  int start = pubspec.indexOf(key) + key.length;
  int end = pubspec.indexOf('\n', start);
  return pubspec.substring(start, end).trim();
}

/// Abort if the specified condition is true.
void abortIf(bool condition, String message) {
  if (condition) {
    print(message);
    throw 'Aborting build';
  }
}

/// Assert that the given pub list result does not indicate an error
void assertNoPubListError(Map<String, dynamic> pubResult) {
  var error = pubResult['error'];
  if (error == null) {
    Map<String, dynamic> packages = pubResult['packages'];
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
  if (!new Directory('/home/pi').existsSync()) {
    print('Not running on Raspberry Pi... skipping build');
    throw 'Aborting build';
  }
}
