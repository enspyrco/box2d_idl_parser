# webidl2js_dart_port

`webidl2.js` uses JS [sticky] RegExp in combination with [lastIndex].

As there does not seem to be an equivalent for the JS [sticky] RegExp, we use Dart’s `substring`, `firstMatch` and check that `result.start == 0` to get the same result.

See: Notion > Dart > [RegExp] for more info.

[sticky]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/sticky
[lastIndex]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/lastIndex
[RegExp]: https://www.notion.so/reference-material/RegExp-f69ec2025e194dfa9927d19003f22b11
