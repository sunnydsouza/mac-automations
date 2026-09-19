#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/Library/Services"
DEST_DIR="$HOME/Library/Services"
DRY_RUN=false

usage() {
  cat <<'EOF'
Usage: ./install.sh [--dry-run]

Install all .workflow bundles from Library/Services into ~/Library/Services.

Options:
  --dry-run   Show what would be installed without changing any files.
  -h, --help  Show this help.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This installer is intended for macOS." >&2
  exit 1
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Services source directory not found: $SOURCE_DIR" >&2
  exit 1
fi

shopt -s nullglob
workflows=("$SOURCE_DIR"/*.workflow)

if (( ${#workflows[@]} == 0 )); then
  echo "No .workflow bundles found in: $SOURCE_DIR" >&2
  exit 1
fi

echo "Source:      $SOURCE_DIR"
echo "Destination: $DEST_DIR"

if [[ "$DRY_RUN" == false ]]; then
  mkdir -p "$DEST_DIR"
fi

for workflow in "${workflows[@]}"; do
  name="$(basename "$workflow")"
  target="$DEST_DIR/$name"

  if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] install $name"
    continue
  fi

  if [[ -e "$target" ]]; then
    echo "Replacing $name"
    rm -rf "$target"
  else
    echo "Installing $name"
  fi

  ditto "$workflow" "$target"
done

if [[ "$DRY_RUN" == true ]]; then
  echo "Dry run complete. No files were changed."
else
  echo
  echo "Installed ${#workflows[@]} workflow(s) into $DEST_DIR"
  echo "If a Service is not visible, enable it under System Settings > Keyboard > Keyboard Shortcuts > Services."
fi
