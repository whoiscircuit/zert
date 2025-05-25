#!/usr/bin/env zsh
# Main entry point for Zert

# Resolve Zert directories
ZERT_DIR="${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}"

HERE="${${(%):-%N}:A:h}"

# Add functions directory to fpath and autoload functions
fpath=("$HERE/functions" $fpath)
autoload -Uz zert-add

# Define the zert function
zert() {
    local subcommand="$1"
    shift
    case "$subcommand" in
        add)
            zert-add "$@"
        ;;
        *)
            echo "Unknown subcommand: $subcommand (UNKNOWN_SUBCOMMAND)" >&2
            return 1
        ;;
    esac
}
