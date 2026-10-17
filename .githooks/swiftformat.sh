#!/bin/sh
set -eu

hook_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$hook_dir/.." && pwd)
swiftformat_bin=$("$hook_dir/ensure-tool.sh" swiftformat)

cd "$repo_root"
mode=${1:-lint}
set -- \
    Tahudu \
    TahuduTests \
    Packages/DesignSystem/Sources \
    Packages/DesignSystem/Tests \
    Packages/Networking/Sources \
    Packages/Networking/Tests \
    Packages/Analytics/Sources \
    Packages/Analytics/Tests \
    Packages/AnalyticsInterface/Sources \
    Packages/Caching/Sources \
    Packages/Caching/Tests \
    Packages/Modules/Search/Search/Sources \
    Packages/Modules/Search/Search/Tests \
    Packages/Modules/Settings/Settings/Sources \
    Packages/Modules/Settings/Settings/Tests

case "$mode" in
    format)
        "$swiftformat_bin" "$@" --strict --config "$repo_root/.swiftformat" --cache ignore
        ;;
    lint)
        "$swiftformat_bin" "$@" --lint --config "$repo_root/.swiftformat" --cache ignore
        ;;
    *)
        exit 2
        ;;
esac
