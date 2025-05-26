#!/usr/bin/env zsh
# Installs Zert into the plugins directory.
# Simple logging function
function zert_log {
    local color="$1" msg="$2"
    local red="\033[31m" blue="\033[34m" reset="\033[0m"
    local prefix="[ZERT]: "
    case "$color" in
        red) echo -e "${red}${prefix}${msg}${reset}" >/dev/stderr ;;
        blue) echo -e "${blue}${prefix}${msg}${reset}" >/dev/stderr ;;
        *) echo -e "${prefix}${msg}" >/dev/stderr ;;
    esac
}

# Resolve Zert directories
ZERT_DIR="${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}"
ZERT_PLUGINS_DIR="${ZERT_PLUGINS_DIR:-${ZERT_DIR}/plugins}"

# Check if Zert is already installed
if [[ -f "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh" ]]; then
    return 0
fi

# Ensure git is available
if ! command -v git >/dev/null 2>&1; then
    zert_log red "git is required to install Zert"
    return 1
fi

# Create plugins directory
mkdir -p "$ZERT_PLUGINS_DIR" || {
    zert_log red "Failed to create $ZERT_PLUGINS_DIR"
    return 1
}

# Clone Zert repository
zert_log blue "Cloning Zert to $ZERT_PLUGINS_DIR/zert"
git clone "https://github.com/whoiscircuit/zert" "$ZERT_PLUGINS_DIR/zert" 2>&1 || {
    zert_log red "Failed to clone Zert to $ZERT_PLUGINS_DIR/zert"
    return 1
}

return 0
