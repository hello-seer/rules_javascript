load("//rules/javascript/bzl:providers.bzl",
    _JsPackage = "JsPackage",
    _create_package_dep = "create_package_dep",
    _create_package = "create_package",
    _create_module = "create_module",
    _merge_packages = "merge_packages",
)
load(":aspects.bzl", _js_proto_aspect = "js_proto_aspect")
load("//rules/util/bzl:path.bzl", "runfile_path")
load(":providers.bzl", _JsProtobuf = "JsProtobuf")

def _js_protoc_impl(ctx):
    js_protobuf = _JsProtobuf(
        runtime = ctx.attr.runtime[_JsPackage]
    )

    return [js_protobuf]

js_protoc = rule(
    implementation = _js_protoc_impl,
    attrs = {
        "runtime": attr.label(
            doc = "Runtime dependencies",
            providers = [_JsPackage]
        )
    }
)

def _js_proto_library(ctx):
    js_package = ctx.attr.dep[_JsPackage]

    return [js_package]

def js_proto_library_rule(js_proto):
    return rule(
        implementation = _js_proto_library,
        attrs = {
            "dep": attr.label(
                aspects = [js_proto],
            ),
        }
    )