import 'dart:io';

void main(List<String> args) {
  var nativeDir = Directory('lib/src/native');
  if (!nativeDir.existsSync()) {
    throw Exception('Cannot find ${nativeDir.path}'
        '\nThis expects to be run from the package root');
  }

  var headerInfo = HeaderInfo();
  var gpiodHeaderFile = File('${nativeDir.path}/gpiod_v1.h');
  headerInfo.parse(gpiodHeaderFile.readAsLinesSync());

  var gpioGenFile = File('${nativeDir.path}/gpiod_ext.g.dart');
  gpioGenFile.writeAsStringSync(headerInfo.codegenBase());
  print('Generated ${gpioGenFile.path}');

  gpioGenFile = File('${nativeDir.path}/gpiod_ext32.g.dart');
  gpioGenFile.writeAsStringSync(headerInfo.codegen32());
  print('Generated ${gpioGenFile.path}');

  gpioGenFile = File('${nativeDir.path}/gpiod_ext64.g.dart');
  gpioGenFile.writeAsStringSync(headerInfo.codegen64());
  print('Generated ${gpioGenFile.path}');
}

class HeaderInfo {
  final functs = <String, FunctInfo>{};
  final structs = <String, StructInfo>{};

  void parse(List<String> lines) {
    final whitespace = RegExp('[\n\t ]+');

    var chunk = '';
    var comment = '';
    var blockDepth = 0;
    var inDefine = false;
    var inMultiLineComment = false;

    for (var line in lines) {
      line = line.trim();

      if (line.isEmpty) continue;

      if (!inMultiLineComment) {
        if (line.startsWith('/*')) {
          comment = line;
          inMultiLineComment = !line.endsWith('*/');
          continue;
        }
      } else {
        comment = '$comment\n$line';
        if (line.trim().endsWith('*/')) {
          inMultiLineComment = false;
        }
        continue;
      }

      if (line.startsWith('extern "C" {')) continue;

      if (!inDefine) {
        if (line.startsWith('#define ')) {
          inDefine = line.endsWith('\\');
          continue;
        }
      } else {
        if (line.endsWith('\\')) {
          continue;
        } else {
          inDefine = false;
          continue;
        }
      }
      if (line.startsWith('#')) continue;

      chunk = '$chunk$line\n';

      var oldBlockDepth = blockDepth;
      if (line.contains('{')) blockDepth++;
      if (line.contains('}')) blockDepth--;
      if (blockDepth > 0) continue;
      if (oldBlockDepth == 0 && !line.endsWith(';')) continue;

      chunk = chunk //
          .replaceAll('*', ' * ')
          .trim()
          .replaceAll(whitespace, ' ');

      var structInfo = StructInfo.parse(chunk);
      if (structInfo != null) {
        structs[structInfo.name] = structInfo;
        chunk = '';
        continue;
      }

      var functInfo = FunctInfo.parse(chunk, comment);
      if (functInfo != null) {
        if (functs.containsKey(functInfo.name)) {
          throw Exception('Duplicate funct ${functInfo.name}');
        }
        if (functInfo.isApi && !functInfo.isDeprecated) {
          functs[functInfo.name] = functInfo;
        }
        chunk = '';
        continue;
      }

      if (chunk.startsWith('enum ')) {
        chunk = '';
        continue;
      }

      if (chunk.startsWith('typedef ')) {
        chunk = '';
        continue;
      }

      throw Exception('Failed to parse chunk:\n$chunk');
    }
  }

  String codegenBase() {
    var sortedFuncts = functs.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    var sortedStructs = structs.values.toList() //
      ..sort((a, b) => a.name.compareTo(b.name));

    var buf = StringBuffer('''
//
// Generated from native/rpi_gpio_ext.cc
//
// ignore_for_file: slash_for_doc_comments

import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as ffi;
import 'package:rpi_gpio/src/native/gpiod_ext32.g.dart';
import 'package:rpi_gpio/src/native/gpiod_ext64.g.dart';
import 'package:rpi_gpio/src/native/rpi_system_info.dart';

class NativePgkLib {
  final ffi.DynamicLibrary dyLib;
''');
    for (var functInfo in sortedFuncts) {
      buf.writeln('');
      buf.writeln(functInfo.asDartFieldDecl);
    }
    buf.write('''

  factory NativePgkLib(ffi.DynamicLibrary dylib, {bool? is64Bit}) => //
      is64Bit ?? RpiSystemInfo.read().is64Bit //
          ? NativePgkLib64(dylib)
          : NativePgkLib32(dylib);

  NativePgkLib.base(
    this.dyLib,''');
    for (var functInfo in sortedFuncts) {
      buf.write('\n    ${functInfo.asDartConstructorArg},');
    }
    buf.write('''

  );
}

// Structs

''');
    for (var structInfo in sortedStructs) {
      buf.writeln(structInfo.asDartClassDecl);
    }
    buf.write('''

// Functions

''');
    for (var functInfo in sortedFuncts) {
      buf.writeln(functInfo.asDartTypedef);
    }

    return buf.toString();
  }

  String codegen32() {
    var sortedFuncts = functs.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    var buf = StringBuffer('''
//
// Generated from native/rpi_gpio_ext.cc
//

import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as ffi;
import 'package:rpi_gpio/src/native/gpiod_ext.g.dart';

class NativePgkLib32 extends NativePgkLib {
  NativePgkLib32(ffi.DynamicLibrary dylib) : super.base(
        dylib,''');
    for (var functInfo in sortedFuncts) {
      buf.write('\n        ${functInfo.asDartFfiLookup},');
    }
    buf.write('''

  );
}

// Functions

''');
    for (var functInfo in sortedFuncts) {
      buf.writeln(functInfo.asDartFfiTypedef32);
    }

    return buf.toString();
  }

  String codegen64() {
    var sortedFuncts = functs.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    var buf = StringBuffer('''
//
// Generated from native/rpi_gpio_ext.cc
//

import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as ffi;
import 'package:rpi_gpio/src/native/gpiod_ext.g.dart';

class NativePgkLib64 extends NativePgkLib {
  NativePgkLib64(ffi.DynamicLibrary dylib) : super.base(
        dylib,''');
    for (var functInfo in sortedFuncts) {
      buf.write('\n        ${functInfo.asDartFfiLookup},');
    }
    buf.write('''

  );
}

// Functions

''');
    for (var functInfo in sortedFuncts) {
      buf.writeln(functInfo.asDartFfiTypedef64);
    }

    return buf.toString();
  }
}

class FunctInfo {
  final String name;
  final TypeInfo returnType;
  final List<TypeInfo> arguments;
  final String comment;
  final bool isApi;
  final bool isDeprecated;

  FunctInfo(this.name, this.returnType, this.arguments, this.comment,
      {required this.isApi, required this.isDeprecated});

  String get dartFieldName => name.underscoreToCamelCase;
  String get dartClassName => dartFieldName.capitalizeFirst;

  bool get exclude => [
        'gpiod_ctxless_event_monitor',
        'gpiod_ctxless_event_monitor_ext',
        'gpiod_ctxless_event_monitor_multiple',
        'gpiod_ctxless_event_monitor_multiple_ext',
        'gpiod_ctxless_set_value',
        'gpiod_ctxless_set_value_ext',
        'gpiod_ctxless_set_value_multiple',
        'gpiod_ctxless_set_value_multiple_ext',
        'gpiod_line_event_wait',
        'gpiod_line_event_wait_bulk',
      ].contains(name);
  String get excludeComment => exclude ? '// ' : '';

  static FunctInfo? parse(String chunk, String comment) {
    bool isApi;
    bool isDeprecated;
    if (chunk.endsWith(') GPIOD_API GPIOD_DEPRECATED;')) {
      isApi = true;
      isDeprecated = true;
    } else if (chunk.endsWith(') GPIOD_API;')) {
      isApi = true;
      isDeprecated = false;
    } else if (chunk.endsWith(');') || chunk.endsWith('}')) {
      isApi = false;
      isDeprecated = false;
    } else {
      return null;
    }

    var split = chunk.split('(');
    if (split.length != 2) return null;

    var nameAndReturnType = split[0];
    var nameStart = nameAndReturnType.lastIndexOf(' ') + 1;
    if (nameStart == 0) return null;
    var name = nameAndReturnType.substring(nameStart).trim();

    var returnType =
        TypeInfo.parse(nameAndReturnType.substring(0, nameStart).trim());

    var arguments = split[1] //
        .split(')')[0]
        .split(',')
        .map((argText) => TypeInfo.parse(argText, hasParamName: true))
        .toList();
    if (arguments.length == 1 && arguments[0].name == 'void') {
      arguments.removeLast();
    }

    final briefRegExp = RegExp('@brief ([^\\n]*)');
    var briefMatch = briefRegExp.firstMatch(comment);
    if (briefMatch != null) {
      var replacement = briefMatch.group(1)!;
      comment =
          comment.replaceRange(briefMatch.start, briefMatch.end, replacement);
    }
    comment = comment //
        .replaceAll(' @param', '\n* @param')
        .replaceAll(' @return', '\n* @return')
        .replaceAll(' @note', '\n* @note')
        .replaceAll(' @attention', '\n* @attention')
        .replaceAll('\n*', '\n   *');

    return FunctInfo(name, returnType, arguments, comment,
        isApi: isApi, isDeprecated: isDeprecated);
  }

  String get asDartFieldDecl => //
      '  $comment\n  ${excludeComment}final $dartClassName $dartFieldName;';

  String get asDartConstructorArg => //
      '${excludeComment}this.$dartFieldName';

  String get asDartFfiLookup => '''
${excludeComment}dylib
        $excludeComment  .lookup<ffi.NativeFunction<${dartClassName}Ffi>>('$name')
        $excludeComment  .asFunction<$dartClassName>()''';

  String? get asDartTypedef => //
      '${excludeComment}typedef $dartClassName = ${returnType.dartName} Function('
      '${arguments.map((arg) => arg.dartName).join(', ')});';

  String get asDartFfiTypedef => //
      '${excludeComment}typedef ${dartClassName}Ffi = ${returnType.dartFfiName} Function('
      '${arguments.map((arg) => arg.dartFfiName).join(', ')});';

  String get asDartFfiTypedef32 => asDartFfiTypedef //
      .replaceAll('ffi.Int64', 'ffi.Int32');

  String get asDartFfiTypedef64 => asDartFfiTypedef;
}

class TypeInfo {
  final String name;
  final bool isStruct;
  final int pointerCount;

  TypeInfo(this.name, this.isStruct, this.pointerCount);

  String get dartName {
    if (pointerCount > 0) return dartFfiName;

    String dartName;
    if (isStruct) {
      dartName = name.underscoreToCamelCase.capitalizeFirst;
    } else {
      switch (name) {
        case 'bool':
          dartName = 'bool';
          break;
        case 'char':
          dartName = 'ffi.Utf8';
          break;
        case 'int':
        case 'int64_t':
        case 'size_t':
        case 'uint':
        case 'uint64_t':
        case 'ulong':
          dartName = 'int';
          break;
        case 'void':
          dartName = 'void';
          break;
        default:
          throw Exception('Unhandled type dartName: $name');
      }
    }

    return dartName;
  }

  String get dartFfiName {
    String dartName;
    if (isStruct) {
      dartName = name.underscoreToCamelCase.capitalizeFirst;
    } else {
      switch (name) {
        case 'bool':
          dartName = 'ffi.Bool';
          break;
        case 'char':
          dartName = 'ffi.Utf8';
          break;
        case 'int':
        case 'int64_t':
        case 'size_t':
        case 'uint':
        case 'uint64_t':
          if (pointerCount > 0) return 'ffi.Pointer';
          dartName = 'ffi.Int64';
          break;
        case 'ulong':
          if (pointerCount > 0) return 'ffi.Pointer';
          dartName = 'ffi.Uint64';
          break;
        case 'void':
          dartName = 'ffi.Void';
          break;
        default:
          throw Exception('Unhandled type dartName: $name');
      }
    }

    for (var i = 0; i < pointerCount; ++i) {
      dartName = 'ffi.Pointer<$dartName>';
    }

    return dartName;
  }

  static TypeInfo parse(String chunk, {bool hasParamName = false}) {
    var pointerCount = 0;
    var isStruct = false;

    var split = chunk.trim().split(' ');
    var index = 0;
    if (split[index] == 'static') {
      ++index;
    }
    if (split[index] == 'inline') {
      ++index;
    }
    if (split[index] == 'const') {
      ++index;
    }
    if (split[index] == 'struct') {
      isStruct = true;
      ++index;
    }
    var name = split[index];
    ++index;
    if (name == 'unsigned') {
      name = 'u${split[index]}';
      ++index;
    }
    if (name == 'enum') {
      name = split[index];
      ++index;
      name = 'int';
    }
    if (name.startsWith('gpiod_')) {
      isStruct = true;
    }
    while (index < split.length && split[index] == '*') {
      ++pointerCount;
      ++index;
    }

    String? paramName;
    if (hasParamName) {
      if (index < split.length) {
        paramName = split[index];
        ++index;
      } else if (name == 'void') {
        paramName = 'ignored';
      }
    }

    if (index < split.length || //
        name.contains('*') ||
        (hasParamName && paramName == null)) {
      throw Exception('Failed to parse type: $chunk'
          '\n  name: $name'
          '\n  isStruct: $isStruct'
          '\n  pointerCount: $pointerCount');
    }

    return TypeInfo(name, isStruct, pointerCount);
  }
}

class StructInfo {
  final String name;

  StructInfo(this.name);

  String get dartName => name.underscoreToCamelCase.capitalizeFirst;

  static StructInfo? parse(String chunk) {
    if (!chunk.startsWith('struct ')) return null;
    if (!chunk.endsWith(';')) return null;
    if (chunk.endsWith(') GPIOD_API;')) return null;

    var name = chunk.substring(7, chunk.length - 1).trim();
    if (name.endsWith('}')) name = name.substring(0, name.indexOf('{')).trim();
    if (name.endsWith(')')) return null;

    return StructInfo(name);
  }

  String get asDartClassDecl => //
      'sealed class $dartName extends ffi.Opaque {}';
}

extension StringUtil on String {
  String get capitalizeFirst => substring(0, 1).toUpperCase() + substring(1);
  String get underscoreToCamelCase {
    var parts = split('_');
    if (parts.length == 1) return this;
    return parts.first +
        parts.sublist(1).map((part) => part.capitalizeFirst).join('');
  }
}
