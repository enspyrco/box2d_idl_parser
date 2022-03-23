import 'dart:io';

import 'package:box2d_idl_parser/tokeniser.dart';
void main(List<String> args) {
  String fileText = File('Box2D.idl').readAsStringSync();
  var tokens = tokenise(fileText);
}
