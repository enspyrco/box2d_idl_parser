import 'dart:io';

import 'package:test/test.dart';
import 'package:webidl2js_dart_port/tokenise.dart';

void main() {
  test('integer regexp does not match', () {
    // String fileText = File('Box2D.idl').readAsStringSync();
    // var substr = fileText.substring(421);

    // the regexp is  -?(0([Xx][0-9A-Fa-f]+|[0-7]*)|[1-9][0-9]*)
    RegExp re = tokenRe['integer']!;
    RegExpMatch? match = re.firstMatch('NoDelete]\ninterface b2C');

    expect(match, isNull);
  });

  test('comment regexp matches first block comment', () {
    String fileText = File('Box2D.idl').readAsStringSync();

    // the regexp is  \/\/.*|\/\*[\s\S]*?\*\/
    RegExp re = tokenRe['comment']!;

    RegExpMatch? match = re.firstMatch(fileText);

    expect(match, isNotNull);
    expect(match!.end, 418);
  });

  test('comment regexp matches all comments', () {
    String fileText = File('Box2D.idl').readAsStringSync();

    // the regexp is  \/\/.*|\/\*[\s\S]*?\*\/
    RegExp re = tokenRe['comment']!;

    for (var match in re.allMatches(fileText)) {
      print(match);
      print(match.start);
      print(match.end);
    }
    // expect(match, isNotNull);
    // expect(match!.end, 418);
  });

  test('comment regexp matches first block comment with matchAsPrefix', () {
    String fileText = File('Box2D.idl').readAsStringSync();

    Match? match = r'\/\/.*|\/\*[\s\S]*?\*\/'.matchAsPrefix(fileText, 0);

    expect(match, isNotNull);
    expect(match!.end, 418);
  },
      skip:
          true); // matchAsPrefix doesn't work as I expected given this comment https://github.com/dart-lang/sdk/issues/34935#issuecomment-467450332
}
