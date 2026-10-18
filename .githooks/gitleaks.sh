#!/bin/sh
set -eu

hook_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$hook_dir/.." && pwd)
gitleaks_bin=$("$hook_dir/ensure-tool.sh" gitleaks)

cd "$repo_root"
"$gitleaks_bin" git --pre-commit --staged --redact --verbose --no-banner --config "$repo_root/.gitleaks.toml" .
