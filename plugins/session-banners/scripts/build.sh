#!/bin/bash
# SessionStart hook: builds Claude Notify.app into the plugin's data folder, which survives plugin
# updates, whenever the helper's sources change. Prints nothing on stdout, since Claude Code adds a
# SessionStart hook's output to the session's context.
set -euo pipefail

src="$CLAUDE_PLUGIN_ROOT/helper"
app="$CLAUDE_PLUGIN_DATA/Claude Notify.app"
stamp="$CLAUDE_PLUGIN_DATA/build-hash"
hash=$(cat "$src/main.swift" "$src/Info.plist" "$src/AppIcon.icns" | shasum | cut -d ' ' -f 1)

if [[ -x "$app/Contents/MacOS/claude-notify" && "$(cat "$stamp" 2>/dev/null)" == "$hash" ]]; then
  exit 0
fi

# /usr/bin/swiftc exists without the tools too, and running it opens the installer dialog
if ! xcode-select -p >/dev/null 2>&1; then
  echo "claude-notify: run xcode-select --install, the helper app is built with swiftc" >&2
  exit 0
fi

# Built aside and moved into place, so a session starting at the same time never sees half an app
build="$CLAUDE_PLUGIN_DATA/build.$$/Claude Notify.app"
trap 'rm -rf "$CLAUDE_PLUGIN_DATA/build.$$"' EXIT
mkdir -p "$build/Contents/MacOS" "$build/Contents/Resources"
cp "$src/Info.plist" "$build/Contents/Info.plist"
cp "$src/AppIcon.icns" "$build/Contents/Resources/AppIcon.icns"
swiftc -O "$src/main.swift" -o "$build/Contents/MacOS/claude-notify" >&2
codesign --force --sign - --deep "$build" >&2
rm -rf "$app"
mv "$build" "$app"
echo "$hash" >"$stamp"
