import 'dart:io';

import 'package:webidl2js_dart_port/tokenise.dart';

void main(List<String> args) {
  String fileText = File('Box2D.idl').readAsStringSync();

  var tokens = tokenise(fileText);

  var out = '';
  for (var token in tokens) {
    out += '[${token.type}]: ${token.value}\n';
  }
  File('out.txt').writeAsStringSync(out);
}
