#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

install_bun() {
  if has_command bun; then
    log "INFO: Bun is already installed: $(bun --version)"
    return
  fi

  log "INFO: Installing Bun..."
  curl -fsSL https://bun.sh/install | bash
}

ensure_bun_path() {
  export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
  export PATH="$BUN_INSTALL/bin:$PATH"

  if ! has_command bun; then
    log "ERROR: Bun command not found after installation."
    log "INFO: Please add '$BUN_INSTALL/bin' to your PATH and re-run ./setup.sh"
    exit 1
  fi
}

main() {
  local normalized_args=()
  local show_help=false
  for arg in "$@"; do
    case "$arg" in
      --dry-run)
        normalized_args+=("--dryRun")
        ;;
      --help)
        show_help=true
        normalized_args+=("$arg")
        ;;
      *)
        normalized_args+=("$arg")
        ;;
    esac
  done

  if [ "$show_help" = true ]; then
    cat <<'EOF'
Usage: ./setup.sh [OPTIONS]

This script bootstraps Bun, installs setup dependencies, and runs setup.ts.

Options:
  --help       Show this help
  --dry-run    Alias of setup.ts --dryRun
  --dryRun     Show commands without executing
  --force      Force overwrite for symlink targets (nvim/zshrc)
  --yes        Install/update without interactive confirmations
EOF
    return 0
  fi

  log "INFO: Starting setup bootstrap (Bun)"
  install_bun
  ensure_bun_path

  log "INFO: Installing setup dependencies with Bun"
  (
    cd "$SCRIPT_DIR"
    bun install
  )

  log "INFO: Launching interactive installer (setup.ts)"
  (
    cd "$SCRIPT_DIR"
    if [ ${#normalized_args[@]} -eq 0 ]; then
      bun run setup.ts
    else
      bun run setup.ts "${normalized_args[@]}"
    fi
  )
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
