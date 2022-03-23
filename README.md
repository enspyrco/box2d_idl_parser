# box2d_idl_parser

## emscripten

[box2d-wasm] uses emscripten’s [WebIDL Binder] to create JS bindings.

I added the file called `webidl_binder_json.py` to $

First run this to get the location of the emscripten tools (assumes homebrew install):

```sh
export EMSCRIPTEN_TOOLS="$(realpath "$(dirname "$(realpath "$(which emcc)")")/../libexec/tools")"
```

Then run the python:

```sh
python3 $EMSCRIPTEN_TOOLS/webidl_binder_json.py Box2D.idl
```

[box2d-wasm]: https://github.com/Birch-san/box2d-wasm
[WebIDL Binder]: https://emscripten.org/docs/porting/connecting_cpp_and_javascript/WebIDL-Binder.html
