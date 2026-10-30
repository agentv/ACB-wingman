#!/usr/bin/env bash
# reset.sh — Wipe and restore the portable data dir from the clean snapshot.
# Run between class sessions (or any time) to get back to a known-good state.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

DATA_DIR="$ROOT/code-portable-data"
SNAPSHOT_DIR="$ROOT/snapshots/clean"

log()  { echo "▶  $*"; }
ok()   { echo "✓  $*"; }
die()  { echo "✗  $*" >&2; exit 1; }

[ -d "$SNAPSHOT_DIR" ] || die "No clean snapshot found. Run bin/setup.sh first."

# Guard: make sure VS Code isn't running against this portable instance
if pgrep -f "Visual Studio Code.app/Contents/MacOS/Electron" > /dev/null 2>&1; then
  die "VS Code is running. Close it before resetting."
fi

log "Resetting portable data dir from clean snapshot..."
rm -rf "${DATA_DIR:?}/extensions" "${DATA_DIR:?}/user-data"
cp -R "$SNAPSHOT_DIR/extensions" "$DATA_DIR/extensions"
cp -R "$SNAPSHOT_DIR/user-data"  "$DATA_DIR/user-data"

ok "Reset complete. Environment is clean."
echo ""
echo "  Launch with: bin/launch.sh"
