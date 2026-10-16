#!/bin/sh
set -eu

hook_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$hook_dir/.." && pwd)
swiftformat_bin=$("$hook_dir/ensure-tool.sh" swiftformat)

cd "$repo_root"
case "${1:-lint}" in
    format)
        "$swiftformat_bin" Tahudu TahuduTests --strict --config "$repo_root/.swiftformat" --cache ignore
        ;;
    lint)
        "$swiftformat_bin" Tahudu TahuduTests --lint --config "$repo_root/.swiftformat" --cache ignore
        ;;
    *)
        exit 2
        ;;
esac
