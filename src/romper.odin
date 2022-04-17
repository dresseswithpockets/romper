package romper

import gd "lib:gdnative"
import "core:strings"
import "core:mem"
import "core:fmt"
import "core:runtime"

@(private)
gd_api: ^gd.GdnativeCoreApiStruct = nil

@(private)
ns_api: ^gd.GdnativeExtNativescriptApiStruct = nil

@(private)
global_ctx: runtime.Context

@(private)
global_method_data := "bwuh!"

@(export)
godot_gdnative_init :: proc "c" (options: ^gd.GdnativeInitOptions) {
    gd_api = options.api_struct
    global_ctx = gd_context(gd_api)
    context = global_ctx

    gd_print("[romper] init begin")

    ext_search: for i in 0..<gd_api.num_extensions {
        extension: ^gd.GdnativeApiStruct = mem.ptr_offset(gd_api.extensions, i)^
        #partial switch extension.type {
            case .GdnativeExtNativescript: {
                gd_print("[romper] acquiring ns_api (ExtNativescript)")
                ns_api = transmute(^gd.GdnativeExtNativescriptApiStruct)extension
                break ext_search
            }
        }
    }

    gd_print("[romper] init end")
}

@(export)
godot_gdnative_terminate :: proc "c" (options: ^gd.GdnativeInitOptions) {
    context = global_ctx
    // gd_print("[romper] terminating")
    gd_api = nil
    ns_api = nil
}

@(export)
godot_nativescript_init :: proc "c" (handle: rawptr) {
    context = global_ctx

    gd_print("[romper] nativescript init begin (copying global method data pointer)")

    create := gd.InstanceCreateFunc{nil,nil,nil}
    create.create_func = simple_constructor

    destroy := gd.InstanceDestroyFunc{nil,nil,nil}
    destroy.destroy_func = simple_destructor

    gd_print("[romper] nativescript registering romper_simple class")

    ns_api.godot_nativescript_register_class(handle, "romper_simple", "Reference", create, destroy)

    get_data := gd.InstanceMethod{}
    get_data.method = simple_get_data

    attributes := gd.MethodAttributes{.Disabled}

    gd_print("[romper] nativescript registering romper_simple.get_data method handler")

    ns_api.godot_nativescript_register_method(handle, "romper_simple", "get_data", attributes, get_data)

    gd_print("[romper] nativescript init end")
}

UserData :: struct {
    message: string,
    to_free: [dynamic]rawptr,
}

simple_constructor :: proc "c" (instance, r_method_data: rawptr) -> rawptr {
    context = global_ctx
    gd_print("[romper] simple_constructor")

    user_data := new(UserData)
    user_data.message = "World from GDNative!"
    user_data.to_free = make([dynamic]rawptr, 0, 1)

    return user_data
}

simple_destructor :: proc "c" (instance, r_method_data, r_user_data: rawptr) {
    context = global_ctx
    gd_print("[romper] simple_destructor")

    user_data := cast(^UserData)r_user_data
    for ptr in user_data.to_free {
        if ptr != nil {
            free(ptr)
        }
    }
    delete(user_data.to_free)
    free(user_data)
}

simple_get_data :: proc "c" (instance, r_method_data, r_user_data: rawptr, num_args: gd.Int, args: [^]gd.Variant) -> gd.Variant {
    context = global_ctx
    gd_print("[romper] simple_get_data")

    user_data := cast(^UserData)r_user_data

    cstr := strings.clone_to_cstring(user_data.message)
    defer free(cast(rawptr)cstr)

    data: gd.String
    ret: gd.Variant
    gd_api.godot_string_new(&data)
    gd_api.godot_string_parse_utf8(&data, cstr)
    gd_api.godot_variant_new_string(&ret, &data)
    gd_api.godot_string_destroy(&data)

    return ret;
}

gd_print :: proc(msg: string) {
    cstr := strings.clone_to_cstring(msg)
    defer free(cast(rawptr)cstr)

    data: gd.String
    gd_api.godot_string_new(&data)
    defer gd_api.godot_string_destroy(&data)
    gd_api.godot_string_parse_utf8(&data, cstr)

    gd_api.godot_print(&data)
}

gd_print_unsafe :: proc "contextless" (msg: string) {
    d := transmute(mem.Raw_String)msg
	cstr := cstring(d.data)

    data: gd.String
    gd_api.godot_string_new(&data)
    defer gd_api.godot_string_destroy(&data)
    gd_api.godot_string_parse_utf8(&data, cstr)

    gd_api.godot_print(&data)
}
