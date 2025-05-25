#!/usr/bin/env zsh
# Tests for zert-bootstrap.zsh
set -e

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"

TEMP_DIR=$(mktemp -d)

# Mock git
function git {
    echo "[MOCK] git $@"
    if [[ "$1" = "clone" ]]; then
        mkdir -p "$3"
        touch "$3/zert.plugin.zsh"
    fi
    return 0
}

# Mock failing git
function git_fail {
    echo "[MOCK] git $@" >> "$ZERT_TEST_DIR/git.log"
    return 1
}

function test_bootstrap_installs_zert {
    local ZERT_PLUGINS_DIR="$TEMP_DIR/plugins"
    source "$HERE/../zert-bootstrap.zsh"
    assert_file_exists "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh"
}
test_case test_bootstrap_installs_zert

function test_bootstrap_respects_zert_dir {
    unset ZERT_PLUGINS_DIR
    local ZERT_DIR="$TEMP_DIR/custom"
    source "$HERE/../zert-bootstrap.zsh"
    assert_file_exists "$ZERT_DIR/plugins/zert/zert.plugin.zsh"
}
test_case test_bootstrap_respects_zert_dir

function test_bootstrap_respects_xdg_data_home {
    unset ZERT_DIR ZERT_PLUGINS_DIR
    local XDG_DATA_HOME="$TEMP_DIR/xdg"
    source "$HERE/../zert-bootstrap.zsh"
    assert_file_exists "$XDG_DATA_HOME/zert/plugins/zert/zert.plugin.zsh"
}
test_case test_bootstrap_respects_xdg_data_home

function test_bootstrap_silent_if_zert_already_installed {
    local ZERT_PLUGINS_DIR="$TEMP_DIR/plugins"
    mkdir -p "$ZERT_PLUGINS_DIR/zert"
    touch "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh"
    source "$HERE/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2>&1
    assert_file_exists "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh" && \
    assert_equals "" "$(cat /tmp/zert_bootstrap.out)" && \
    assert_file_not_exists "$TEMP_DIR/git.log"
}
test_case test_bootstrap_silent_if_zert_already_installed

function test_bootstrap_fails_if_git_missing {
    local ZERT_PLUGINS_DIR="$TEMP_DIR/nowhere"
    function command { return 1; }
    ( source "$HERE/../zert-bootstrap.zsh" )
    assert_fails $?
}
test_case test_bootstrap_fails_if_git_missing

function test_bootstrap_fails_if_git_clone_fails {
    local ZERT_PLUGINS_DIR="$TEMP_DIR/nowhere"
    function git { git_fail "$@"; }
    ( source "$HERE/../zert-bootstrap.zsh" )
    assert_fails $?
}
test_case test_bootstrap_fails_if_git_clone_fails

test_summary
