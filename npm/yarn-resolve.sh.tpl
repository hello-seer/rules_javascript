#!/usr/bin/env bash
set -euo pipefail

if [ -z "${RUNFILES_DIR-}" ]; then
  if [ ! -z "${RUNFILES_MANIFEST_FILE-}" ]; then
    export RUNFILES_DIR="${RUNFILES_MANIFEST_FILE%.runfiles_manifest}.runfiles"
  else
    export RUNFILES_DIR="$0.runfiles"
  fi
fi

exec "$RUNFILES_DIR"/%{yarn_resolve} %{options} --dir "$BUILD_WORKSPACE_DIRECTORY"/%{path} "$BUILD_WORKSPACE_DIRECTORY"/%{output}
