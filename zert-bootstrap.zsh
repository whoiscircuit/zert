#!/usr/bin/env zsh

# Bootstrapping script for zert plugin manager.
# Add this to your .zshrc to bootstrap zert:
#   [ -f "${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}/zert.pulgin.zsh" ] && source "${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}/zert-bootstrap.zsh" || source <(curl -fsSL https://raw.githubusercontent.com/whoiscircuit/zert/main/zert-bootstrap.zsh)

# Zert configuration variables
[ -z "$ZERT_REPO"           ] && export ZERT_REPO="https://github.com/whoiscircuit/zert"
[ -z "$ZERT_DIR"            ] && export ZERT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zert"
[ -z "$ZERT_PLUGINS_DIR"    ] && export ZERT_PLUGINS_DIR="${ZERT_DIR}/plugins"
[ -z "$ZERT_LOCKFILE"       ] && export ZERT_LOCKFILE="${ZERT_DIR}/zert.lock"
[ -z "$ZERT_NOTIFY_UPDATES" ] && export ZERT_NOTIFY_UPDATES=1

# Colors for output
ERROR='\033[0;31m[ZERT]: '
SUCCESS='\033[0;32m[ZERT]:'
INFO='\033[34m[ZERT]:'
HL='\033[33m' # Highlight
NC='\033[0m' # No Color

if ! command -v git >/dev/null 2>&1; then
    echo "${RED}git is required but not installed. please install git and try again.${NC}" >&2
    return 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "${RED}curl is required but not installed. please install curl and try again.${NC}" >&2
    return 1
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
    echo "${INFO}installing zert from ${HL}'${ZERT_REPO}'${NC}" >&2
    git clone "$ZERT_REPO" "$ZERT_PLUGINS_DIR/zert"
fi

if [ -z "$ZERT_LOCKFILE_DISABLED" ]; then
    if ! [ -f "$ZERT_LOCKFILE" ]; then
        echo "${INFO}initializing the zert lockfile at ${HL}${ZERT_LOCKFILE}${NC}" >&2
        echo "zert=$(git -C "${ZERT_PLUGINS_DIR}/zert" rev-parse HEAD)" > "$ZERT_LOCKFILE"
    else
        LOCKFILE_REV=$(cat "$ZERT_LOCKFILE" | grep "^\[$ZERT_REPO\]=" | cut -d'=' -f2)
        CURRENT_REV=$(git -C "${ZERT_PLUGINS_DIR}/zert" rev-parse HEAD )
        if ! [[ "$LOCKFILE_REV" == "$CURRENT_REV" ]]; then
            echo "${INFO}checking out zert to commit ${HL}${LOCKFILE_REV}${NC}" >&2
            git -C "${ZERT_PLUGINS_DIR}/zert" checkout -f ${LOCKFILE_REV}
        fi
    fi
fi

unset ERROR SUCCESS INFO HL NC

source "${ZERT_PLUGINS_DIR}/zert/zert.plugin.zsh"