class Token {
  Token(
      {required this.type,
      required this.value,
      required this.trivia,
      required this.line,
      required this.index});
  String type;
  final String value;
  final String trivia;
  final int line;
  final int index;
}
