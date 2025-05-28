#!/usr/bin/env zsh
# Tests for __zert-compile function
set -e

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"
source "$HERE/../lib/__zert-compile"

# Setup temporary environment
TEMP_DIR=$(mktemp -d)
ZERT_PLUGINS_DIR="$TEMP_DIR/plugins"
PLUGIN_NAME="test-plugin"
PLUGIN_DIR="$ZERT_PLUGINS_DIR/$PLUGIN_NAME"
mkdir -p "$PLUGIN_DIR/subdir"

# Mock zcompile (default success case)
function zcompile() {
    local file="$1"
    local zwc_file="${file}.zwc"
    echo "" > "$zwc_file"
}

# Mock __zert-log
function __zert-log() {
    echo "__zert-log $@" >> "$TEMP_DIR/log"
}

# Compiles .zsh and .zsh-theme files in root and subdirectories
function test_compiles_zsh_and_theme_files {
    rm -f "$TEMP_DIR/log"
    touch "$PLUGIN_DIR/test.zsh"
    touch "$PLUGIN_DIR/test.zsh-theme"
    touch "$PLUGIN_DIR/subdir/sub.zsh"
    __zert-compile "$PLUGIN_NAME"
    assert_file_exists "$PLUGIN_DIR/test.zsh.zwc"
    assert_file_exists "$PLUGIN_DIR/test.zsh-theme.zwc"
    assert_file_exists "$PLUGIN_DIR/subdir/sub.zsh.zwc"
}
test_case test_compiles_zsh_and_theme_files

# Overwrites existing .zwc files
function test_overwrites_existing_zwc {
    rm -f "$TEMP_DIR/log"
    echo "old" > "$PLUGIN_DIR/existing.zsh.zwc"
    echo "echo hi" > "$PLUGIN_DIR/existing.zsh"
    __zert-compile "$PLUGIN_NAME"
    assert_file_exists "$PLUGIN_DIR/existing.zsh.zwc"
    assert_fails assert_equals "old" "$(cat "$PLUGIN_DIR/existing.zsh.zwc")"
}
test_case test_overwrites_existing_zwc

# Skips compilation if ZERT_NO_COMPILE is set
function test_skips_with_no_compile {
    rm -f "$TEMP_DIR/log"
    ZERT_NO_COMPILE=1
    echo "no_compile" > "$PLUGIN_DIR/no_compile.zsh"
    __zert-compile "$PLUGIN_NAME"
    assert_file_not_exists "$PLUGIN_DIR/no_compile.zsh.zwc"
}
test_case test_skips_with_no_compile

# Logs warning on compilation failure
function test_logs_warning_on_failure {
    rm -f "$TEMP_DIR/log"
    unset ZERT_NO_COMPILE
    function zcompile() { return 1; }
    assert_fails __zert-compile "$PLUGIN_NAME"
    assert_contains "__zert-log warning" "$(cat "$TEMP_DIR/log")"
}
test_case test_logs_warning_on_failure

# Handles missing plugin directory
function test_handles_missing_plugin_dir {
    rm -f "$TEMP_DIR/log"
    local missing_plugin="missing-plugin"
    assert_fails __zert-compile "$missing_plugin"
    assert_contains "PLUGIN_MISSING" "$(cat "$TEMP_DIR/log")"
}
test_case test_handles_missing_plugin_dir

test_summary

rm -rf "${TEMP_DIR:-/dev/null}"