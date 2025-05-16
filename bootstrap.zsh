#!/usr/bin/env zsh

# Bootstrapping script for zert plugin manager.
# Add this to your .zshrc to bootstrap zert:
#   [ -f "${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}/zert.pulgin.zsh" ] && source "${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}/bootstrap.zsh" || source <(curl -fsSL https://raw.githubusercontent.com/whoiscircuit/zert/main/install.sh)

# Zert configuration variables
[ -z "$ZERT_REPO"        ] && export ZERT_REPO="https://github.com/whoiscircuit/zert"
[ -z "$ZERT_DIR"         ] && export ZERT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zert"
[ -z "$ZERT_FILE"        ] && export ZERT_FILE="${ZERT_DIR}/zert.ini"
[ -z "$ZERT_PLUGINS_DIR" ] && export ZERT_PLUGINS_DIR="${ZERT_DIR}/plugins"
[ -z "$ZERT_LOCKFILE"    ] && export ZERT_LOCKFILE="${ZERT_DIR}/zert.lock"

# Colors for output
ERROR='\033[0;31m[ZERT]: '
SUCCESS='\033[0;32m[ZERT]:'
INFO='\033[34m[ZERT]:'
HL='\033[33m[ZERT]:' # Highlight
NC='\033[0m' # No Color

if ! command -v git >/dev/null 2>&1; then
    echo "${RED}git is required but not installed. please install git and try again.${NC}" >&2
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "${RED}curl is required but not installed. please install curl and try again.${NC}" >&2
    exit 1
fi

if ! [ -d "$ZERT_DIR" ]; then
    echo "${INFO}creating ZERT_DIR: ${HL}${ZERT_DIR}${NC}" >&2
    mkdir -p "$ZERT_DIR"
fi

if ! [ -d "$ZERT_PLUGINS_DIR" ]; then
    echo "${INFO}creating ZERT_PLUGINS_DIR: ${HL}${ZERT_PLUGINS_DIR}${NC}" >&2
    mkdir -p "$ZERT_PLUGINS_DIR"
fi

if ! [ -d "$ZERT_PLUGINS_DIR/zert" ]; then
    echo "${INFO}installing zert from ${HL}'${ZERT_REPO}'${INFO}...${NC}" >&2
    git clone "$ZERT_REPO" "$ZERT_PLUGINS_DIR/zert"
fi

if ! [ -f "$ZERT_FILE" ]; then
    echo "${INFO}initializing the zert file at ${HL}${ZERT_FILE}${NC}" >&2
    echo "zert=$ZERT_REPO" > "$ZERT_FILE"
fi

if ! [ -f "$ZERT_LOCKFILE" ]; then
    echo "${INFO}initializing the zert lockfile at ${HL}${ZERT_LOCKFILE}${NC}" >&2
    echo "zert=$(git )
fi