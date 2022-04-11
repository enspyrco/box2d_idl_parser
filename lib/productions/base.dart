import '../token.dart';

class Base {
  /// @param {object} initializer
  /// @param {Base["source"]} initializer.source
  /// @param {Base["tokens"]} initializer.tokens
  Base(this.source, this.tokens);
  
  String source;
  List<Token> tokens;

  // toJSON() {
  //   const json = { type: undefined, name: undefined, inheritance: undefined };
  //   let proto = this;
  //   while (proto !== Object.prototype) {
  //     const descMap = Object.getOwnPropertyDescriptors(proto);
  //     for (const [key, value] of Object.entries(descMap)) {
  //       if (value.enumerable || value.get) {
  //         // @ts-ignore - allow indexing here
  //         json[key] = this[key];
  //       }
  //     }
  //     proto = Object.getPrototypeOf(proto);
  //   }
  //   return json;
  // }
}
