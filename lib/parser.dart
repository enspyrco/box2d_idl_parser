import 'productions/callback.dart';
import 'token.dart';
import 'tokeniser.dart';

/// @param {Tokeniser} tokeniser
/// @param {object} options
/// @param {boolean} [options.concrete]
/// @param {Function[]} [options.productions]
parseByTokens(String idlText) {
  final source = [];
  final tokeniser = Tokeniser(idlText);

  Never error(str) => tokeniser.error(str);

  Token? consume(List<String> candidates) =>  tokeniser.consume(candidates);

  callback() {
    final callback = consume(['callback']);
    if (callback == null) return;
    if (tokeniser.probe('interface')) {
      return CallbackInterface.parse(tokeniser, callback);
    }
    return CallbackFunction.parse(tokeniser, callback);
  }

  function interface_(opts) {
    const base = consume("interface");
    if (!base) return;
    const ret =
      Mixin.parse(tokeniser, base, opts) ||
      Interface.parse(tokeniser, base, opts) ||
      error("Interface has no proper body");
    return ret;
  }

  function partial() {
    const partial = consume("partial");
    if (!partial) return;
    return (
      Dictionary.parse(tokeniser, { partial }) ||
      interface_({ partial }) ||
      Namespace.parse(tokeniser, { partial }) ||
      error("Partial doesn't apply to anything")
    );
  }

  function definition() {
    if (options.productions) {
      for (const production of options.productions) {
        const result = production(tokeniser);
        if (result) {
          return result;
        }
      }
    }

    return (
      callback() ||
      interface_() ||
      partial() ||
      Dictionary.parse(tokeniser) ||
      Enum.parse(tokeniser) ||
      Typedef.parse(tokeniser) ||
      Includes.parse(tokeniser) ||
      Namespace.parse(tokeniser)
    );
  }

  function definitions() {
    if (!source.length) return [];
    const defs = [];
    while (true) {
      const ea = ExtendedAttributes.parse(tokeniser);
      const def = definition();
      if (!def) {
        if (ea.length) error("Stray extended attributes");
        break;
      }
      autoParenter(def).extAttrs = ea;
      defs.push(def);
    }
    const eof = Eof.parse(tokeniser);
    if (options.concrete) {
      defs.push(eof);
    }
    return defs;
  }
  const res = definitions();
  if (tokeniser.position < source.length) error("Unrecognised tokens");
  return res;
}