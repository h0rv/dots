#!/usr/bin/env sh

set -e

PI_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

find "$PI_DIR" -type f -name '*.ts' -exec node --experimental-strip-types --check {} \;

npx --yes oxfmt --check "$PI_DIR"
npx --yes oxlint "$PI_DIR"
