#!/usr/bin/env sh

set -e

DOTS_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SETTINGS_FILE="$DOTS_DIR/agent/settings.json"

if ! command -v pi >/dev/null 2>&1; then
	echo "pi is not installed or not on PATH"
	exit 1
fi

if ! command -v node >/dev/null 2>&1; then
	echo "node is required to read $SETTINGS_FILE"
	exit 1
fi

INSTALLED_PACKAGES=$(mktemp)
trap 'rm -f "$INSTALLED_PACKAGES"' EXIT
pi list 2>/dev/null | awk '/^  [^ ].*:/{print $1}' >"$INSTALLED_PACKAGES"

node -e '
const fs = require("fs");
const settings = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
for (const pkg of settings.packages || []) {
  if (typeof pkg === "string") {
    console.log(pkg);
    continue;
  }
  if (pkg && typeof pkg.source === "string") {
    console.log(pkg.source);
  }
}
' "$SETTINGS_FILE" | while IFS= read -r pkg; do
	[ -n "$pkg" ] || continue
	if grep -Fqx "$pkg" "$INSTALLED_PACKAGES"; then
		echo "Already installed: $pkg"
		continue
	fi
	echo "Installing $pkg"
	pi install "$pkg"
done

echo "Pi packages synced. Run /reload in pi if it is already open."
