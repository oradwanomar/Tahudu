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
    gitleaks)
        version=8.30.1
        case "$(uname -m)" in
            arm64)
                architecture=arm64
                checksum=b40ab0ae55c505963e365f271a8d3846efbc170aa17f2607f13df610a9aeb6a5
                ;;
            x86_64)
                architecture=x64
                checksum=dfe101a4db2255fc85120ac7f3d25e4342c3c20cf749f2c20a18081af1952709
                ;;
            *)
                printf >&2 'Unsupported Gitleaks architecture: %s\n' "$(uname -m)"
                exit 2
                ;;
        esac
        archive="gitleaks_${version}_darwin_${architecture}.tar.gz"
        url="https://github.com/gitleaks/gitleaks/releases/download/v$version/$archive"
        ;;
    *)
        exit 2
        ;;
esac

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tool_dir="$repo_root/.build/tools/$tool-$version${architecture:+-$architecture}"
tool_bin="$tool_dir/$tool"

if [ ! -x "$tool_bin" ]; then
    mkdir -p "$tool_dir"
    download_dir=$(mktemp -d "$tool_dir/download.XXXXXX")
    trap 'rm -rf "$download_dir"' EXIT HUP INT TERM

    curl --fail --location --retry 3 --silent --show-error \
        --output "$download_dir/$archive" "$url"
    printf '%s  %s\n' "$checksum" "$download_dir/$archive" | shasum -a 256 -c - >&2
    case "$archive" in
        *.zip)
            unzip -q "$download_dir/$archive" -d "$download_dir"
            ;;
        *.tar.gz)
            tar -xzf "$download_dir/$archive" -C "$download_dir" "$tool"
            ;;
    esac
    test -x "$download_dir/$tool"
    mv "$download_dir/$tool" "$tool_bin"
    rm -rf "$download_dir"
    trap - EXIT HUP INT TERM
fi

printf '%s\n' "$tool_bin"
