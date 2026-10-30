#!/usr/bin/env bash
# launch.sh — Open the portable ACB VS Code instance.
# Pass an optional path argument to open a specific folder/workspace.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PORTABLE_APP="$ROOT/Visual Studio Code.app"
DATA_DIR="$ROOT/code-portable-data"
CODE_CLI="$PORTABLE_APP/Contents/Resources/app/bin/code"
WORKSPACE="${1:-$ROOT/workspace-template}"

die() { echo "✗  $*" >&2; exit 1; }

[ -d "$PORTABLE_APP" ] || die "Portable VS Code not found. Run bin/setup.sh first."
[ -d "$DATA_DIR" ]     || die "Portable data dir missing. Run bin/setup.sh first."

# code-portable-data must sit alongside the .app — it already does by design.
# The CLI resolves portable mode from the app's location automatically.
exec "$CODE_CLI" \
  --user-data-dir "$DATA_DIR/user-data" \
  --extensions-dir "$DATA_DIR/extensions" \
  "$WORKSPACE"
