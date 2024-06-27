import 'dart:io';

import 'package:rpi_gpio/src/native/rpi_platform.dart';

void main() {
  if (!Platform.isLinux) {
    print('This script runs only on Linux');
    return;
  }

  var cpuName = Process.runSync('uname', ['-m']).stdout.toString().trim();
  var systemName = Process.runSync('uname', ['-n']).stdout.toString().trim();
  var archName = Process.runSync('uname', ['-p']).stdout.toString().trim();
  var osRelease = Process.runSync('uname', ['-r']).stdout.toString().trim();
  var osName = Process.runSync('uname', ['-s']).stdout.toString().trim();
  var osVersion = Process.runSync('uname', ['-v']).stdout.toString().trim();

  print('CPU          : $cpuName');
  print('Arch         : $archName');
  print('System       : $systemName');
  print('OS           : $osName');
  print('Version      : $osVersion');
  print('Release      : $osRelease');

  var dartVersion = Platform.version;

  print('');
  print('Dart Version : $dartVersion');

  if (RpiPlatform.compatFile.existsSync()) {
    var rpiSysInfo = RpiPlatform.current;

    print('');
    print('Board Make   : ${rpiSysInfo.boardMake}');
    print('Board Model  : ${rpiSysInfo.boardModel}');
    print('CPU Make     : ${rpiSysInfo.cpuMake}');
    print('CPU Model    : ${rpiSysInfo.cpuModel}');
    print('Is 64-bit    : ${rpiSysInfo.is64Bit}');
    print('Is Rpi 5     : ${rpiSysInfo.isPi5}');
    print('Gpio Chip    : ${rpiSysInfo.gpioChipName}');
  }
}
