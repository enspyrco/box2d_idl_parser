// These regular expressions use the sticky flag so they will only match at
// the current location (ie. the offset of lastIndex).

import 'package:string_unescape/string_unescape.dart';
import 'package:webidl2js_dart_port/token.dart';

import 'error.dart';

// There are all 'sticky', with /y at the end - we use Pattern.matchAsPrefix
// with substring and check that any match starts at 0 to replicate 'stickyness'.
//
// /g means regexp should be tested against all possible matches in a string
final tokenRe = {
  // This expression uses a lookahead assertion to catch false matches
  // against integers early.
  'decimal': RegExp(
      r'-?(?=[0-9]*\.|[0-9]+[eE])(([0-9]+\.[0-9]*|[0-9]*\.[0-9]+)([Ee][-+]?[0-9]+)?|[0-9]+[Ee][-+]?[0-9]+)'),
  'integer': RegExp(r'-?(0([Xx][0-9A-Fa-f]+|[0-7]*)|[1-9][0-9]*)'),
  'identifier': RegExp(r'[_-]?[A-Za-z][0-9A-Z_a-z-]*'),
  'string': RegExp(r'"[^"]*"'),
  'whitespace': RegExp(r'[\t\n\r ]+'),
  'comment': RegExp(r'\/\/.*|\/\*[\s\S]*?\*\/'),
  'other': RegExp(r'[^\t\n\r 0-9A-Za-z]'),
};

const typeNameKeywords = [
  'ArrayBuffer',
  'DataView',
  'Int8Array',
  'Int16Array',
  'Int32Array',
  'Uint8Array',
  'Uint16Array',
  'Uint32Array',
  'Uint8ClampedArray',
  'BigInt64Array',
  'BigUint64Array',
  'Float32Array',
  'Float64Array',
  'any',
  'object',
  'symbol',
];

const stringTypes = ['ByteString', 'DOMString', 'USVString'];

const argumentNameKeywords = [
  'async',
  'attribute',
  'callback',
  'const',
  'constructor',
  'deleter',
  'dictionary',
  'enum',
  'getter',
  'includes',
  'inherit',
  'interface',
  'iterable',
  'maplike',
  'namespace',
  'partial',
  'required',
  'setlike',
  'setter',
  'static',
  'stringifier',
  'typedef',
  'unrestricted',
];

const nonRegexTerminals = [
  '-Infinity',
  'FrozenArray',
  'Infinity',
  'NaN',
  'ObservableArray',
  'Promise',
  'bigint',
  'boolean',
  'byte',
  'double',
  'false',
  'float',
  'long',
  'mixin',
  'null',
  'octet',
  'optional',
  'or',
  'readonly',
  'record',
  'sequence',
  'short',
  'true',
  'undefined',
  'unsigned',
  'void',
  ...argumentNameKeywords,
  ...stringTypes,
  ...typeNameKeywords
];

const punctuations = [
  "(",
  ")",
  ",",
  "...",
  ":",
  ";",
  "<",
  "=",
  ">",
  "?",
  "*",
  "[",
  "]",
  "{",
  "}",
];

const reserved = [
  // "constructor" is now a keyword
  "_constructor",
  "toString",
  "_toString",
];

/// @typedef {ArrayItemType<ReturnType<typeof tokenise>>} Token
/// @param {string} str
List<Token> tokenise(String str) {
  final tokens = <Token>[];
  var lastCharIndex = 0;
  var trivia = '';
  var line = 1;
  var index = 0;

  /// @param {keyof typeof tokenRe} type
  /// @param {object} options
  /// @param {boolean} [options.noFlushTrivia]
  int attemptTokenMatch(String type, {bool noFlushTrivia = false}) {
    final re = tokenRe[type]!;
    var substring = str.substring(lastCharIndex);
    Match? result = re.firstMatch(substring);
    if (result != null && result.start == 0) {
      var token = Token(
          type: type,
          value: result[0]!,
          trivia: trivia,
          line: line,
          index: index);
      tokens.add(token);
      if (!noFlushTrivia) trivia = "";
      return lastCharIndex + result.end;
    }
    return -1;
  }

  while (lastCharIndex < str.length) {
    final nextChar = str[lastCharIndex];
    var result = -1;

    if (RegExp(r'[\t\n\r ]').matchAsPrefix(nextChar) != null) {
      result = attemptTokenMatch('whitespace', noFlushTrivia: true);
    } else if (nextChar == '/') {
      result = attemptTokenMatch('comment', noFlushTrivia: true);
    }

    if (result != -1) {
      final currentTrivia = tokens.removeLast().value;
      line += RegExp(r'\n').allMatches(currentTrivia).length;
      trivia += currentTrivia;
      index -= 1;
    } else if (RegExp('[-0-9.A-Z_a-z]').matchAsPrefix(nextChar) != null) {
      result = attemptTokenMatch('decimal');
      if (result == -1) {
        result = attemptTokenMatch('integer');
      }
      if (result == -1) {
        result = attemptTokenMatch("identifier");
        final lastIndex = tokens.length - 1;
        final token = tokens[lastIndex];
        if (result != -1) {
          if (reserved.contains(token.value)) {
            final message =
                '${unescape(token.value)} is a reserved identifier and must not be used.';
            throw syntaxError(tokens, lastIndex, null,
                message); // TODO: turn this into a [WebIDLParseError]
          } else if (nonRegexTerminals.contains(token.value)) {
            token.type = 'inline';
          }
        }
      }
    } else if (nextChar == '"') {
      result = attemptTokenMatch("string");
    }

    for (final punctuation in punctuations) {
      if (str.startsWith(punctuation, lastCharIndex)) {
        var token = Token(
          type: 'inline',
          value: punctuation,
          trivia: trivia,
          line: line,
          index: index,
        );
        tokens.add(token);
        trivia = '';
        lastCharIndex += punctuation.length;
        result = lastCharIndex;
        break;
      }
    }

    // other as the last try
    if (result == -1) {
      result = attemptTokenMatch('other');
    }
    if (result == -1) {
      throw Exception('Token stream not progressing');
    }
    lastCharIndex = result;
    index += 1;
  }

  // remaining trivia as eof
  tokens.add(Token(
    type: 'eof',
    value: '',
    trivia: trivia,
    line: line,
    index: index,
  ));

  return tokens;
}

class WebIDLParseError implements Exception {
  /// @param {object} options
  /// @param {string} options.message
  /// @param {string} options.bareMessage
  /// @param {string} options.context
  /// @param {number} options.line
  /// @param {*} options.sourceName
  /// @param {string} options.input
  /// @param {*[]} options.tokens
  WebIDLParseError({
    this.name = "WebIDLParseError", // not to be mangled
    this.bareMessage,
    this.context,
    this.line,
    this.sourceName,
    required this.input,
    this.tokens = const [],
  });

  String? name;
  String? bareMessage;
  String? context;
  int? line;
  dynamic sourceName;
  String input;
  List<Token> tokens;
}
