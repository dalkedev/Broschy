#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Compile a separate fixture executable. The shipping app never includes this
# entry point, sample data, or preview-only agent setter.
preview_build="$PWD/build/ui-preview"
preview_app="$preview_build/Broschy Preview.app"
mkdir -p "$preview_app/Contents/MacOS" "$preview_app/Contents/Frameworks" "$preview_app/Contents/Resources"
swiftc -swift-version 5 -emit-library -emit-module -module-name AgentBridge \
    Sources/AgentBridge/*.swift \
    -emit-module-path "$preview_build/AgentBridge.swiftmodule" \
    -o "$preview_build/libAgentBridge.dylib"
cp "$preview_build/libAgentBridge.dylib" "$preview_app/Contents/Frameworks/"
swiftc -swift-version 5 -parse-as-library -D BROSCHY_UI_PREVIEW -D AGENT_UI_PREVIEW \
    -I "$preview_build" -L "$preview_build" -lAgentBridge \
    -Xlinker -rpath -Xlinker @executable_path/../Frameworks \
    Sources/Broschy/*.swift scripts/PreviewMain.swift \
    -o "$preview_app/Contents/MacOS/BroschyPreview"
cp Resources/AppIcon.png Resources/Broschy.icns "$preview_app/Contents/Resources/"
cat > "$preview_app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleExecutable</key><string>BroschyPreview</string>
  <key>CFBundleIdentifier</key><string>app.broschy.preview</string>
  <key>CFBundleName</key><string>Broschy Preview</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleIconFile</key><string>Broschy.icns</string>
  <key>LSUIElement</key><true/>
  <key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
"$preview_app/Contents/MacOS/BroschyPreview" "$@"
