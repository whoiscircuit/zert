#!/usr/bin/env zsh
# Main entry point for Zert

# Resolve Zert directories
if [[ -z "$ZERT_DIR" ]]; then
    zstyle -s ':zert:' dir ZERT_DIR || ZERT_DIR="${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}"
fi
if [[ -z "$ZERT_PLUGINS_DIR" ]]; then
    zstyle -s ':zert:' plugins-dir ZERT_PLUGINS_DIR || ZERT_PLUGINS_DIR="${ZERT_PLUGINS_DIR:-${ZERT_DIR}/plugins}"
fi
if [[ -z "$ZERT_ICON_STYLE" ]]; then
    zstyle -s ':zert:' icon-style ZERT_ICON_STYLE || ZERT_ICON_STYLE="nerd"
fi
if [[ -z "$ZERT_CLONE_STYLE" ]]; then
    zstyle -s ':zert:' clone-style ZERT_CLONE_STYLE || ZERT_CLONE_STYLE="treeless"
fi
if [[ -z "$ZERT_LOCKFILE" ]]; then
    zstyle -s ':zert:' lockfile ZERT_LOCKFILE || ZERT_LOCKFILE="${ZERT_DIR}/zert.lock"
fi
if [[ -z "$ZERT_UI_HEIGHT_PERCENT" ]]; then
    zstyle -s ':zert:' ui-height-percent ZERT_UI_HEIGHT_PERCENT || ZERT_UI_HEIGHT_PERCENT="70"
fi

ZERT_PLUGIN_LIST=()

HERE="${${(%):-%N}:A:h}"

# Add functions and lib directory to fpath and autoload functions
fpath=("$HERE/functions" "$HERE/lib" $fpath)
autoload -Uz zert __zert-log __zert-get-plugin-name __zert-fetch __zert-align-version __zert-compile __zert-is-aligned __zert-add __zert-update __zert-purge __zert-review-plugin __zert-get-plugin-info __zert-set-plugin-info
