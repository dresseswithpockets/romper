package test

import "core:runtime"
import "core:fmt"
import "core:mem"

ImportedPrintStruct :: struct {
  imported_print: #type proc "c" (msg: cstring),
  set_callback: #type proc "c" (c: CallbackStruct),
}

CallbackStruct :: struct {
  callback: #type proc "c" (),
}

@(export)
test_func :: proc "c" (p: ^ImportedPrintStruct) {
  test_print(p, "hello from odin without a context\n")
  context = runtime.default_context()
  fmt.println("hello from odin")

  callback := CallbackStruct {callback,}
  p.set_callback(callback)
}

test_print :: proc "contextless" (p: ^ImportedPrintStruct, msg: string) {
  d := transmute(mem.Raw_String)msg
  cstr := cstring(d.data)
  p.imported_print(cstr);
}

callback :: proc "c" () {
  context = runtime.default_context()
  fmt.println("hello from callback")
}
