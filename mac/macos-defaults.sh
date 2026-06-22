#!/usr/bin/env sh
# macOS system defaults. Idempotent — safe to re-run.
# Apply with: mac/macos-defaults.sh  (also run by mac/bootstrap.sh)

set -eu

##### Dock #####

# Don't show the "Recent applications" / suggested-apps section in the Dock.
defaults write com.apple.dock show-recents -bool false

killall Dock 2>/dev/null || true

echo "macOS defaults applied."
