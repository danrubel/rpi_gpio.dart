import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:path/path.dart';
import 'package:rpi_gpio/src/native/rpi_gpio_ext.g.dart';

export 'package:rpi_gpio/src/native/rpi_gpio_ext.g.dart'
    show NativePgkLib, nativePkgName;

ffi.DynamicLibrary findDynamicLibrary() {
  String libName;
  if (Platform.isLinux) {
    libName = 'lib${nativePkgName}_ext.so';
  } else {
    // Windows: Debug\${nativePkgName}_ext.dll
    // MacOS:   lib${nativePkgName}_ext.dylib
    throw 'Unsupported OS: ${Platform.operatingSystem}';
  }

  var pkgRootDir = findPkgRootDir(File.fromUri(Platform.script).parent);
  var libPath = join(pkgRootDir.path, 'lib', 'src', 'native', libName);
  if (!File(libPath).existsSync()) throw 'failed to find $libPath';
  return ffi.DynamicLibrary.open(libPath);
}

/// Find the package root directory
Directory findPkgRootDir(Directory appDir) {
  // Find the app root dir containing the pubspec.yaml
  while (true) {
    if (File(join(appDir.path, 'pubspec.yaml')).existsSync()) break;
    var parentDir = appDir.parent;
    if (parentDir.path == appDir.path) {
      throw 'Failed to find application directory '
          'containing the pubspec.yaml file starting from ${appDir.path}';
    }
    appDir = parentDir;
  }

  // Load the package configuration information
  var pkgConfigFile =
      File(join(appDir.path, '.dart_tool', 'package_config.json'));
  if (!pkgConfigFile.existsSync()) {
    throw 'Failed to find ${pkgConfigFile.path}'
        '\nPlease be sure to run pub get in ${appDir.path}';
  }
  var pkgConfig =
      jsonDecode(pkgConfigFile.readAsStringSync()) as Map<String, dynamic>;
  var pkgList = pkgConfig['packages'] as List;

  // Determine the location of the package being used
  var pkgInfo = pkgList.firstWhere(
      (info) => (info as Map)['name'] == nativePkgName,
      orElse: () => throw 'Failed to find $nativePkgName in ${pkgConfigFile.path}'
          '\nPlease be sure that the pubspec.yaml contains $nativePkgName, then re-run pub get');
  var pkgPath = pkgInfo['rootUri'] as String;
  return Directory.fromUri(pkgConfigFile.uri.resolve(pkgPath));
}
