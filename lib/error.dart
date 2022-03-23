import 'dart:math';

import 'token.dart';

class ParseError implements Exception {
  ParseError(this.message,
  this.bareMessage,
  this.context,
  this.line,
  this.sourceName,
  this.level,
  this.ruleName,
  {
    this.autofix,
    this.input,
    this.tokens});
  String message;
  String bareMessage;
  String context;
  int line;
  dynamic sourceName;
  String level;
  String? ruleName;
  Function? autofix;
  String? input;
  List<Token>? tokens;
  }

/// @param {string} text
String lastLine(String text) {
  final splitted = text.split('\n');
  return splitted[splitted.length - 1];
}

String appendIfExist(String base, String? target) {
  var result = base;
  if (target != null) {
    result += ' $target';
  }
  return result;
}

// TODO: fix this when we figure out what 'node' is
contextAsText(node) {
  return '';
//   final hierarchy = [node];
//   while (node && node.parent) {
//     final parent = node.parent;
//     hierarchy.unshift(parent);
//     node = parent;
//   }
//   return hierarchy.map((n) => appendIfExist(n.type, n.name)).join(" -> ");
}

/// @typedef {object} WebIDL2ErrorOptions
/// @property {"error" | "warning"} [level]
/// @property {Function} [autofix]
/// @property {string} [ruleName]
/// 
/// @typedef {ReturnType<typeof error>} WebIDLErrorData
/// 
/// @param {string} message error message
/// @param {*} position
/// @param {*} current
/// @param {*} message
/// @param {"Syntax" | "Validation"} kind error type
/// @param {WebIDL2ErrorOptions=} options
ParseError error(
  source,
  int position,
  current,
  String message,
  String kind,
  { String level = 'error', Function? autofix, String? ruleName }
) {
  /// @param {number} count
  sliceTokens(int count) {
    return count > 0
      ? source.slice(position, position + count)
      : source.slice(max(position + count, 0), position);
  }

  /// @param {import("./tokeniser.js").Token[]} inputs
  /// @param {object} [options]
  /// @param {boolean} [options.precedes]
  /// @returns
  tokensToText(List<Token> inputs, { bool precedes = false}) {
    final text = inputs.map((t) => t.trivia + t.value).join('');
    final nextToken = source[position];
    if (nextToken.type == 'eof') {
      return text;
    }
    if (precedes) {
      return text + nextToken.trivia;
    }
    return text.substring(nextToken.trivia.length);
  }

  final maxTokens = 5; // arbitrary but works well enough
  final line =
    source[position].type != 'eof'
      ? source[position].line
      : source.length > 1
      ? source[position - 1].line
      : 1;

  final precedingLastLine = lastLine(
    tokensToText(sliceTokens(-maxTokens), precedes: true )
  );

  final subsequentTokens = sliceTokens(maxTokens);
  final subsequentText = tokensToText(subsequentTokens);
  final subsequentFirstLine = subsequentText.split("\n")[0];

  final spaced = ' ' * precedingLastLine.length + '^';
  final sourceContext = precedingLastLine + subsequentFirstLine + "\n" + spaced;

  final contextType = kind == 'Syntax' ? 'since' : 'inside';
  final inSourceName = source.name ? ' in ${source.name}' : '';
  final grammaticalContext =
    current && current.name
      ? ', $contextType \'${current.partial ? 'partial ' : ''}${contextAsText(current)}\''
      : '';
  final context = '$kind error at line $line$inSourceName$grammaticalContext:\n$sourceContext';
  return ParseError('$context $message', message, context, line, source.name, level, ruleName, autofix: autofix, input: subsequentText,
    tokens: subsequentTokens);
}

/// @param {string} message error message
syntaxError(source, int position, current, String message) {
  return error(source, position, current, message, 'Syntax');
}

// /**
//  * @param {string} message error message
//  * @param {WebIDL2ErrorOptions} [options]
//  */
// export function validationError(
//   token,
//   current,
//   ruleName,
//   message,
//   options = {}
// ) {
//   options.ruleName = ruleName;
//   return error(
//     current.source,
//     token.index,
//     current,
//     message,
//     "Validation",
//     options
//   );
// }