import 'error.dart';
import 'token.dart';
import 'tokenise.dart';

class Tokeniser {
  /// @param {string} idl
  Tokeniser(String idl) {
    _source = tokenise(idl);
    _position = 0;
  }

  late final List<Token> _source;
  int _position = 0;

  /// @param {string} message
  /// @return {never}
  Never error(String message) {
    throw // TODO: wrap this in WebIDLParseError();
      syntaxError(_source, _position, null, message);
      // TODO: replace "null" with "current" when we figure out what "current" is?
  }

  /// @param {string} type
  bool probeKind(String type) {
    return (_source.length > _position && _source[_position].type == type);
  }


  /// @param {string} value
  probe(value) {
    return (probeKind("inline") && _source[_position].value == value);
  }

  /// @param {...string} candidates
  Token? consumeKind(List<String> candidates) {
    for (final type in candidates) {
      if (!probeKind(type)) continue;
      final token = _source[_position];
      _position++;
      return token;
    }
    return null;
  }

  /// @param {...string} candidates
  Token? consume(List<String> candidates) {
    if (!probeKind('inline')) return null;
    final token = _source[_position];
    for (final value in candidates) {
      if (token.value != value) continue;
      _position++;
      return token;
    }
    return null;
  }

  /// @param {string} value
  Token? consumeIdentifier(String value) {
    if (!probeKind('identifier')) return null;
    if (_source[_position].value != value) return null;
    return consumeKind(['identifier']);
  }

  /// @param {number} position
  unconsume(int position) {
    _position = position;
  }
}