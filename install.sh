#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/Library/Services"
DEST_DIR="$HOME/Library/Services"
DRY_RUN=false
INSTALL_ALL=false

usage() {
  cat <<'EOF'
Usage: ./install.sh [--all] [--dry-run]

Interactively select macOS automations from Library/Services and install them
into ~/Library/Services.

Options:
  --all       Install all available automations without showing the selection menu.
  --dry-run   Show what would be installed without changing any files.
  -h, --help  Show this help.

Examples:
  ./install.sh
  ./install.sh --dry-run
  ./install.sh --all
  ./install.sh --all --dry-run
EOF
}

for arg in "$@"; do
  case "$arg" in
    --all)
      INSTALL_ALL=true
      ;;
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

selected_workflows=()

if [[ "$INSTALL_ALL" == true ]]; then
  selected_workflows=("${workflows[@]}")
else
  echo
  echo "Automations in Library/Services:"
  echo

  for ((i = 0; i < ${#workflows[@]}; i++)); do
    name="$(basename "${workflows[$i]}" .workflow)"
    printf "  %d) %s\n" "$((i + 1))" "$name"
  done

  echo
  echo "  a) All"
  echo "  q) Quit"
  echo

  while true; do
    read -r -p "Select automations (e.g. 1,3 or a): " selection

    case "$selection" in
      q|Q)
        echo "Nothing installed."
        exit 0
        ;;
      a|A)
        selected_workflows=("${workflows[@]}")
        break
        ;;
    esac

    selection="${selection//,/ }"
    read -r -a choices <<< "$selection"

    if (( ${#choices[@]} == 0 )); then
      echo "Please select at least one automation."
      continue
    fi

    selected_workflows=()
    invalid=false

    for choice in "${choices[@]}"; do
      if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
        invalid=true
        break
      fi

      index=$((choice - 1))
      if (( index < 0 || index >= ${#workflows[@]} )); then
        invalid=true
        break
      fi

      candidate="${workflows[$index]}"
      already_selected=false

      for selected in "${selected_workflows[@]}"; do
        if [[ "$selected" == "$candidate" ]]; then
          already_selected=true
          break
        fi
      done

      if [[ "$already_selected" == false ]]; then
        selected_workflows+=("$candidate")
      fi
    done

    if [[ "$invalid" == true || ${#selected_workflows[@]} == 0 ]]; then
      echo "Invalid selection. Enter numbers from 1 to ${#workflows[@]}, separated by commas or spaces, or choose a/q."
      continue
    fi

    break
  done

  echo
  echo "Selected automations:"
  for workflow in "${selected_workflows[@]}"; do
    echo "  - $(basename "$workflow" .workflow)"
  done
  echo

  if [[ "$DRY_RUN" == true ]]; then
    prompt="Preview installation for these automations? [Y/n] "
  else
    prompt="Install these automations? [Y/n] "
  fi

  read -r -p "$prompt" confirm
  case "$confirm" in
    n|N|no|No|NO)
      echo "Nothing installed."
      exit 0
      ;;
  esac
fi

echo
echo "Source:      $SOURCE_DIR"
echo "Destination: $DEST_DIR"

if [[ "$DRY_RUN" == false ]]; then
  mkdir -p "$DEST_DIR"
fi

for workflow in "${selected_workflows[@]}"; do
  name="$(basename "$workflow")"
  target="$DEST_DIR/$name"

  if [[ "$DRY_RUN" == true ]]; then
    if [[ -e "$target" ]]; then
      echo "[dry-run] replace $name"
    else
      echo "[dry-run] install $name"
    fi
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
  echo
  echo "Dry run complete. No files were changed."
else
  echo
  echo "Installed ${#selected_workflows[@]} automation(s) into $DEST_DIR"
  echo "If a Service is not visible, enable it under System Settings > Keyboard > Keyboard Shortcuts > Services."
fi
