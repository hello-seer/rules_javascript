#!/usr/bin/env bash
set -euo pipefail

# For additional options to the Node.js runtime, use the
# NODE_OPTIONS environment variable.

if [ -z "${RUNFILES_DIR-}" ]; then
  if [ ! -z "${RUNFILES_MANIFEST_FILE-}" ]; then
    export RUNFILES_DIR="${RUNFILES_MANIFEST_FILE%.runfiles_manifest}.runfiles"
  else
    export RUNFILES_DIR="$0.runfiles"
  fi
fi

export JEST_CONFIG="$RUNFILES_DIR"/%{config}
export NODE_PACKAGE_MANIFEST="$RUNFILES_DIR"/%{package_manifest}
export NODE_FS_PACKAGE_MANIFEST="$RUNFILES_DIR"/%{package_manifest}
export NODE_FS_RUNFILES=true

args=()

# sharding
if [ ! -z "${TEST_SHARD_INDEX-}" ] && [ ! -z "${TEST_TOTAL_SHARDS-}" ]; then
  # use --passWithNoTests in case there are no tests in the shard
  args+=(--passWithNoTests --shard="$(("$TEST_SHARD_INDEX"+1))"/"$TEST_TOTAL_SHARDS")
fi

%{preamble}

# exta arguments
args+=("$@")

# test filter
if [ ! -z "${TESTBRIDGE_TEST_ONLY-}" ]; then
  args+=("$TESTBRIDGE_TEST_ONLY")
fi

%{env} \
  exec -a "$0" "$RUNFILES_DIR"/%{node} \
  -r "$(realpath -s "$RUNFILES_DIR"/%{module_linker})" \
  -r "$(realpath -s "$RUNFILES_DIR"/%{fs_linker})" \
  --preserve-symlinks \
  --preserve-symlinks-main \
  %{node_options} \
  "$(realpath -s "$RUNFILES_DIR"/%{main_module})" \
  -i \
  --config="$RUNFILES_DIR"/%{config_loader} \
  --no-cache \
  --no-watchman \
  "${args[@]}"
