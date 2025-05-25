#!/usr/bin/env zsh
# Main entry point for Zert

# Resolve Zert directories
ZERT_DIR="${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}"

HERE="${${(%):-%N}:A:h}"

# Add functions and lib directory to fpath and autoload functions
fpath=("$HERE/functions" "$HERE/lib" $fpath)
autoload -Uz zert __zert-log
