#!/usr/bin/env bash
# setup.sh — First-time setup for ACB-wingman portable VS Code
# Run once to build the portable environment and bake a clean snapshot.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

VSCODE_APP="/Applications/Visual Studio Code.app"
PORTABLE_APP="$ROOT/Visual Studio Code.app"
DATA_DIR="$ROOT/code-portable-data"
SNAPSHOT_DIR="$ROOT/snapshots/clean"
CODE_CLI="$PORTABLE_APP/Contents/Resources/app/bin/code"

# ACB extension IDs (pack pulls in components; list components for offline copy)
ACB_EXTENSIONS=(
  salesforce.mule-dx-extension-pack
  salesforce.mule-dx-vscode
  salesforce.mule-dx-mule-dev-component
  salesforce.mule-dx-runtime
  salesforce.mule-dx-api-component
  salesforce.mule-dx-apikit-component
  salesforce.mule-dx-data-weave-client
  salesforce.mule-dx-dependencies
  salesforce.mule-dx-munit-component
)

log()  { echo "▶  $*"; }
ok()   { echo "✓  $*"; }
warn() { echo "⚠  $*"; }
die()  { echo "✗  $*" >&2; exit 1; }

# ── 1. Copy VS Code app (if not already present) ────────────────────────────
if [ -d "$PORTABLE_APP" ]; then
  ok "Portable VS Code already present, skipping copy."
else
  log "Copying VS Code from $VSCODE_APP ..."
  [ -d "$VSCODE_APP" ] || die "VS Code not found at $VSCODE_APP. Install it first."
  cp -R "$VSCODE_APP" "$PORTABLE_APP"
  # Remove macOS quarantine so it opens without Gatekeeper prompts
  xattr -dr com.apple.quarantine "$PORTABLE_APP" 2>/dev/null || true
  ok "VS Code copied."
fi

# ── 2. Create portable data dir (activates portable mode) ───────────────────
mkdir -p "$DATA_DIR/extensions"
mkdir -p "$DATA_DIR/user-data/User"
ok "Portable data directory ready."

# ── 3. Copy ACB extensions from local VS Code install ───────────────────────
VSCODE_EXT_SRC="$HOME/.vscode/extensions"
log "Copying ACB extensions from $VSCODE_EXT_SRC ..."
copied=0
for ext_id in "${ACB_EXTENSIONS[@]}"; do
  # Match any platform/arch variant of this extension
  for src in "$VSCODE_EXT_SRC"/${ext_id}-*; do
    [ -d "$src" ] || continue
    name="$(basename "$src")"
    dest="$DATA_DIR/extensions/$name"
    if [ -d "$dest" ]; then
      warn "  Already present: $name"
    else
      cp -R "$src" "$dest"
      ok "  Copied: $name"
      ((copied++))
    fi
  done
done
log "Extensions copied: $copied"

# ── 4. Write baseline VS Code settings ──────────────────────────────────────
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

# ── 5. Bake the clean snapshot ───────────────────────────────────────────────
log "Baking clean snapshot to $SNAPSHOT_DIR ..."
mkdir -p "$SNAPSHOT_DIR"
rm -rf "${SNAPSHOT_DIR:?}/extensions" "${SNAPSHOT_DIR:?}/user-data"
cp -R "$DATA_DIR/extensions" "$SNAPSHOT_DIR/extensions"
cp -R "$DATA_DIR/user-data"  "$SNAPSHOT_DIR/user-data"
ok "Clean snapshot saved."

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Setup complete."
echo " Launch:  bin/launch.sh"
echo " Reset:   bin/reset.sh"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
