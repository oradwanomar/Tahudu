#!/bin/sh
set -eu

tool=$1
case "$tool" in
    swiftformat)
        version=0.62.1
        archive=swiftformat.zip
        checksum=7cb1cb1fae04932047c7015441c543848e8e60e1572d808d080e0a1f1661114a
        url="https://github.com/nicklockwood/SwiftFormat/releases/download/$version/$archive"
        ;;
    *)
        exit 2
        ;;
esac

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tool_dir="$repo_root/.build/tools/$tool-$version"
tool_bin="$tool_dir/$tool"

if [ ! -x "$tool_bin" ]; then
    mkdir -p "$tool_dir"
    download_dir=$(mktemp -d "$tool_dir/download.XXXXXX")
    trap 'rm -rf "$download_dir"' EXIT HUP INT TERM

    curl --fail --location --retry 3 --silent --show-error \
        --output "$download_dir/$archive" "$url"
    printf '%s  %s\n' "$checksum" "$download_dir/$archive" | shasum -a 256 -c - >&2
    unzip -q "$download_dir/$archive" -d "$download_dir"
    test -x "$download_dir/$tool"
    mv "$download_dir/$tool" "$tool_bin"
    rm -rf "$download_dir"
    trap - EXIT HUP INT TERM
fi

printf '%s\n' "$tool_bin"
