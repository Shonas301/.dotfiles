#!/usr/bin/env bash
# top-level installer — routes to the right OS-specific script
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$OSTYPE" in
    darwin*) exec "$SCRIPT_DIR/install-macos.sh" "$@" ;;
    linux*)  exec "$SCRIPT_DIR/install-linux.sh" "$@" ;;
    *)       echo "unsupported OS: $OSTYPE" >&2; exit 1 ;;
esac
