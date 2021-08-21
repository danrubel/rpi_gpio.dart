import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

const pkgName = 'rpi_gpio';
const buildScriptVersion = 2;

void main(List<String> args) {
  // Locate the Dart SDK
  var dartVm = File(Platform.resolvedExecutable);
  print('Dart VM... ${dartVm.path}');

  // Locate Dart SDK
  final dartSdk = dartVm.parent.parent;
  print('Dart SDK... ${dartSdk.path}');

  // Locate dart_api.h
  final headerRelUriPath = 'include/dart_api.h';
  final headerFile = File.fromUri(dartSdk.uri.resolve(headerRelUriPath));
  abortIf(!headerFile.existsSync(), 'Failed to find $headerRelUriPath');

  // Run pub list to determine the location of the GPIO package being used
  final pub = File.fromUri(dartSdk.uri.resolve('bin/pub'));
  var pubOut =
      Process.runSync(pub.path, ['list-package-dirs']).stdout as String;
  var pubResult = jsonDecode(pubOut) as Map<String, dynamic>;
  assertNoPubListError(pubResult);
  var dirName = pubResult['packages'][pkgName] as String;
  final pkgDir = Directory(dirName);
  print('Building library in ${pkgDir.path}');

  // Display the version of the rpi_gpio being built
  final pubspecFile = File(join(pkgDir.path, '..', 'pubspec.yaml'));
  abortIf(!pubspecFile.existsSync(), 'Failed to find ${pubspecFile.path}');
  final pubspec = pubspecFile.readAsStringSync();
  print('$pkgName version ${parseVersion(pubspec)}');

  // Build the native library
  final nativeDir = Directory(join(pkgDir.path, 'src', 'native'));
  final buildScriptFile = File(join(nativeDir.path, 'build_native'));
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
  var start = pubspec.indexOf(key) + key.length;
  var end = pubspec.indexOf('\n', start);
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
    var packages = pubResult['packages'] as Map<String, dynamic>?;
    if (packages != null) {
      var pkg = packages[pkgName];
      if (pkg != null) {
        return;
      }
      print('Cannot find $pkgName in pub list result');
      print('Must run this script on app referencing $pkgName package');
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
void assertRunningOnRaspberryPi() {
  // Check for Windows 11 running on RPi
  if (Platform.isWindows) {
    // TODO detect typical install on RPi
    print('Running Windows... hopefully on the Raspberry Pi...');
    return;
  }
  if (Platform.isMacOS || Platform.isIOS) {
    print('Not running on Raspberry Pi... skipping build');
    throw 'Aborting build';
  }
  // Check for typical Raspbian install
  if (Directory('/home/pi').existsSync()) return;
  print('Typical setup not found... hopefully running on the Raspberry Pi...');
}
