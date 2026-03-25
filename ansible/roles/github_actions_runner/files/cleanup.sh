#!/usr/bin/env bash
set -euo pipefail

workspace="${GITHUB_WORKSPACE:-}"
[[ -n "$workspace" && -d "$workspace" ]] || exit 0

rm -rf -- "${workspace:?}/"* "${workspace:?}"/.[!.]* "${workspace:?}"/..?* 2>/dev/null || true