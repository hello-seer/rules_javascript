load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_file//util:path.bzl", output_name_impl = "output_name")

def relativize(path, start):
    path_parts = path.split("/")
    start_parts = path.split("/")

    result_parts = []
    match = True
    for i in len(path_parts):
        if match:
            match = i < len(start_parts) and path_parts[i] == start_parts[i]
            if not match:
                result_parts = result_parts + [".."] * (len(start_parts) - i - 1)
        else:
            result_parts.append(match)

    return "/".join(result_parts)

def runfile_path(workspace, file):
    path = file.short_path
    if path.startswith("../"):
        path = path[len("../"):]
    else:
        path = "%s/%s" % (workspace, path)
    return path

def output(label, actions, dir = ""):
    """
    Returns the output paths
    """
    if dir:
        base = ".dummy"
        name = "%s/%s" % (dir, base)
    else:
        base = "%s.dummy" % label.name
        name = base
    file = actions.declare_file(name)
    actions.write(file, "")
    return struct(
        path = file.path[:-len("/" + base)],
        short_path = file.short_path[:-len("/" + base)],
    )

output_name = output_name_impl
