load("//commonjs:workspace.bzl", "cjs_npm_plugin")
load("//javascript:workspace.bzl", "js_npm_plugin")

def npm_import_external_rule(plugins):
    def impl(ctx):
        deps = ctx.attr.deps
        extra_deps = {id: [json.decode(d) for d in deps] for id, deps in ctx.attr.extra_deps.items()}
        package_name = ctx.attr.package_name

        ctx.download_and_extract(
            ctx.attr.urls,
            "tmp",
            integrity = ctx.attr.integrity,
        )

        # packages can have different prefixes
        mv_result = ctx.execute(["sh", "-c", "mv tmp/* npm && rm -fr npm/node_modules"])
        if mv_result.return_code:
            fail("Could not extract package")

        files_result = ctx.execute(["find", "npm", "-type", "f"])
        if files_result.return_code:
            fail("Could not list files")
        files = files_result.stdout.split("\n")

        # if ctx.name.startswith("npm_protobufjs"):
        #     # protobufjs attempts to run npm install dependencies(!!)
        #     # this may be fixed when protobufjs-cli is released
        #     ctx.execute(["sh", "-c", "echo 'exports.setup = () => {}' >> npm/cli/util.js"])
        #     ctx.execute(["sh", "-c", "echo 'require(\"./targets/json-module\")' >> npm/cli/util.js"])
        #     ctx.execute(["sh", "-c", "echo 'require(\"./targets/json\")' >> npm/cli/util.js"])
        #     ctx.execute(["sh", "-c", "echo 'require(\"./targets/proto\")' >> npm/cli/util.js"])
        #     ctx.execute(["sh", "-c", "echo 'require(\"./targets/proto2\")' >> npm/cli/util.js"])
        #     ctx.execute(["sh", "-c", "echo 'require(\"./targets/proto3\")' >> npm/cli/util.js"])
        #     ctx.execute(["sh", "-c", "echo 'require(\"./targets/static-module\")' >> npm/cli/util.js"])
        #     ctx.execute(["sh", "-c", "echo 'require(\"./targets/static\")' >> npm/cli/util.js"])
        #     deps = list(deps)
        #     deps.append("@npm_chalk4.1.0//:lib")
        #     deps.append("@npm_escodegen2.0.0//:lib")
        #     deps.append("@npm_espree7.3.0//:lib")
        #     deps.append("@npm_glob7.1.6//:lib")
        #     deps.append("@npm_minimist1.2.5//:lib")
        #     deps.append("@npm_uglify_js3.11.6//:lib")
        #     deps.append("@npm_estraverse5.2.0//:lib")

        build = ""

        package = struct(
            deps = deps,
            extra_deps = extra_deps,
            name = package_name,
        )

        for plugin in plugins:
            content = plugin.package_build(package, files)
            if content:
                build += content
                build += "\n"

        ctx.file("BUILD.bazel", build)

    return repository_rule(
        implementation = impl,
        attrs = {
            "deps": attr.string_list(
                doc = "Dependencies.",
            ),
            "extra_deps": attr.string_list_dict(
                doc = "Extra dependencies.",
            ),
            "integrity": attr.string(
                doc = "Integrity",
            ),
            "package_name": attr.string(
                doc = "Package name.",
                mandatory = True,
            ),
            "urls": attr.string_list(
                doc = "URLs",
                mandatory = True,
            ),
        },
    )

def npm_import_rule(plugins):
    def impl(ctx):
        packages = ctx.attr.packages

        for package_name, repo in packages.items():
            build = ""

            for plugin in plugins:
                content = plugin.alias_build(repo)
                if content:
                    build += content
                    build += "\n"

            ctx.file("%s/BUILD.bazel" % package_name, build)

    return repository_rule(
        implementation = impl,
        attrs = {
            "packages": attr.string_dict(
                mandatory = True,
                doc = "Packages.",
            ),
        },
    )

def package_repo_name(prefix, name):
    if name.startswith("@"):
        name = name[len("@"):]
    name = name.replace("@", "_")
    name = name.replace("/", "_")
    return "%s_%s" % (prefix, name)

DEFAULT_PLUGINS = [
    cjs_npm_plugin(),
    js_npm_plugin(),
]

def npm(name, packages, roots, plugins = DEFAULT_PLUGINS):
    npm_import_external = npm_import_external_rule(plugins)
    npm_import = npm_import_rule(plugins)

    for id, package in packages.items():
        repo_name = package_repo_name(name, id)

        extra_deps = {
            package_repo_name(name, id): [json.encode({"id": package_repo_name(name, d["id"]), "name": d.get("name")}) for d in deps]
            for id, deps in package["extra_deps"].items()
        }
        npm_import_external(
            name = repo_name,
            package_name = package["name"],
            deps = [package_repo_name(name, dep["id"]) for dep in package["deps"]],
            extra_deps = extra_deps,
            urls = [package["url"]],
            integrity = package.get("integrity"),
        )
    root_packages = {root["name"]: package_repo_name(name, root["id"]) for root in roots}
    npm_import(name = name, packages = root_packages)
