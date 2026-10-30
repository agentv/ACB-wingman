#!/usr/bin/env bash
# bootstrap.sh — Download VS Code and install ACB extensions on a clean machine.
# Called automatically by setup.sh when VS Code is not found in /Applications.
# Requires internet access.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PORTABLE_APP="$ROOT/Visual Studio Code.app"
DATA_DIR="$ROOT/code-portable-data"
CODE_CLI="$PORTABLE_APP/Contents/Resources/app/bin/code"
VSCODE_URL="https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal"
TMP_ZIP="/tmp/acb-wingman-vscode.zip"

log()  { echo "▶  $*"; }
ok()   { echo "✓  $*"; }
die()  { echo "✗  $*" >&2; exit 1; }

# ── Connectivity check ────────────────────────────────────────────────────────
log "Checking internet connectivity..."
curl -sf --max-time 5 "https://code.visualstudio.com" > /dev/null \
  || die "No internet access. Connect to the network and try again."
ok "Network reachable."

# ── Download VS Code ──────────────────────────────────────────────────────────
log "Downloading VS Code (universal macOS build)..."
log "This may take a minute..."
curl -L --progress-bar -o "$TMP_ZIP" "$VSCODE_URL"
ok "Download complete."

# ── Unpack ────────────────────────────────────────────────────────────────────
log "Unpacking VS Code into project..."
unzip -q "$TMP_ZIP" -d "$ROOT/"
rm -f "$TMP_ZIP"

[ -d "$PORTABLE_APP" ] || die "Unzip succeeded but 'Visual Studio Code.app' not found in $ROOT. Check disk space."

# Remove macOS quarantine attribute
xattr -dr com.apple.quarantine "$PORTABLE_APP" 2>/dev/null || true
ok "VS Code unpacked."

# ── Create portable data dirs ─────────────────────────────────────────────────
mkdir -p "$DATA_DIR/extensions"
mkdir -p "$DATA_DIR/user-data/User"
ok "Portable data directory ready."

# ── Install ACB extensions via CLI ───────────────────────────────────────────
# Installing the extension pack pulls all component extensions automatically.
log "Installing ACB extensions (requires internet — may take several minutes)..."
"$CODE_CLI" \
  --extensions-dir "$DATA_DIR/extensions" \
  --user-data-dir  "$DATA_DIR/user-data" \
  --install-extension salesforce.mule-dx-extension-pack \
  2>&1 | grep -v "^$" | sed 's/^/   /'

# Verify the pack landed
PACK_DIR=$(find "$DATA_DIR/extensions" -maxdepth 1 -name "salesforce.mule-dx-extension-pack-*" -type d | head -1)
[ -n "$PACK_DIR" ] || die "Extension install appears to have failed — pack not found in $DATA_DIR/extensions."
ok "ACB extensions installed: $(basename "$PACK_DIR")"

# ── Write baseline settings ───────────────────────────────────────────────────
cat > "$DATA_DIR/user-data/User/settings.json" << 'EOF'
{
  "telemetry.telemetryLevel": "off",
  "update.mode": "none",
  "extensions.autoUpdate": false,
  "extensions.autoCheckUpdates": false,
  "workbench.startupEditor": "none",
  "editor.fontSize": 14,
  "editor.tabSize": 2,
  "files.autoSave": "onFocusChange"
}
EOF
ok "Baseline settings written."

log "Bootstrap complete — returning to setup."
