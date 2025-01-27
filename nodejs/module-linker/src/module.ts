import { Resolver } from "@better-rules-javascript/commonjs-package/resolve";
import Module from "module";
import * as path from "path";

function resolveFilename(resolver: Resolver, delegate: Function): Function {
  return function (request: string, parent: Module, isMain: boolean) {
    if (
      Module.builtinModules.includes(request) ||
      !parent ||
      parent.path === "internal" ||
      request.startsWith("node:") ||
      request == "." ||
      request == ".." ||
      request.startsWith("./") ||
      request.startsWith("../") ||
      request.startsWith("/") ||
      request.startsWith("#")
    ) {
      return delegate.apply(this, arguments);
    }

    const resolved = resolver.resolve(parent.path, request);
    request = path.basename(resolved.package);
    if (resolved.inner) {
      request = `${request}/${resolved.inner}`;
    }

    parent.paths = [path.dirname(resolved.package)];

    // ignore options, because paths interferes with resolution
    return delegate.call(this, request, parent, isMain);
  };
}
export function patchModule(resolver: Resolver, delegate: typeof Module) {
  (<any>delegate)._resolveFilename = resolveFilename(
    resolver,
    (<any>delegate)._resolveFilename,
  );
}
