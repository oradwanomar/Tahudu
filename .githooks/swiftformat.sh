#!/bin/sh
set -eu

hook_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$hook_dir/.." && pwd)
swiftformat_bin=$("$hook_dir/ensure-tool.sh" swiftformat)

cd "$repo_root"
case "${1:-lint}" in
    format)
        "$swiftformat_bin" Tahudu TahuduTests Packages/DesignSystem/Sources Packages/Networking/Sources Packages/Networking/Tests Packages/Analytics/Sources Packages/Analytics/Tests Packages/AnalyticsInterface/Sources --strict --config "$repo_root/.swiftformat" --cache ignore
        ;;
    lint)
        "$swiftformat_bin" Tahudu TahuduTests Packages/DesignSystem/Sources Packages/Networking/Sources Packages/Networking/Tests Packages/Analytics/Sources Packages/Analytics/Tests Packages/AnalyticsInterface/Sources --lint --config "$repo_root/.swiftformat" --cache ignore
        ;;
    *)
        exit 2
        ;;
esac
