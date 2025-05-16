#!/usr/bin/env zsh
[ -z "$ZERT_DIR" ] && export ZERT_PULGINS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zert"

export ZERT_PLUGINS_DIR="${ZERT_DIR}/plugins"
export ZERT_FILE="${ZERT_DIR}/zert.ini"
export ZERT_LOCKFILE="${ZERT_DIR}/zert.lock"

