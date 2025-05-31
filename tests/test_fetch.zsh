#!/usr/bin/env zsh
# Tests for __zert-fetch function

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"

# Setup temporary environment
TEMP_DIR=$(mktemp -d)
ZERT_PLUGINS_DIR="$TEMP_DIR/plugins"
mkdir -p "$ZERT_PLUGINS_DIR"
TEMP_LOG="$TEMP_DIR/log.txt"
touch "$TEMP_LOG"
ZERT_CLONE_STYLE="normal"

source "$HERE/../lib/__zert-fetch"
source "$HERE/../lib/__zert-get-plugin-name"

# Mock commands
function git() {
    echo "[MOCK] git $@" >> "$TEMP_LOG"
    local dest="${@[-1]}"
    mkdir -p "$dest/.git/info"
    touch "$dest/.git/info/exclude"
}

function __zert-log() {
    echo "[MOCK] __zert-log $@" >> "$TEMP_LOG"
}

function test_fetch_local_relative_path_errors {
    rm -f "$TEMP_LOG"
    local source="local:./relative/path"
    assert_fails __zert-fetch "$source"
    assert_contains "RELATIVE_PATH_NOT_ALLOWED" "$(cat "$TEMP_LOG")"
}
test_case test_fetch_local_relative_path_errors

function test_fetch_local_absolute_directory {
    rm -f "$TEMP_LOG"
    local temp_dir=$(mktemp -d)
    mkdir -p "$temp_dir"
    local source="local:$temp_dir"
    local plugin_name=$(basename "$temp_dir")
    local expected_dest="$ZERT_PLUGINS_DIR/local/$plugin_name"
    __zert-fetch "$source"
    assert_dir_exists "$expected_dest"
    assert_equals "$(readlink "$expected_dest")" "$temp_dir"
    rm -rf "${temp_dir:-/dev/null}"
}
test_case test_fetch_local_absolute_directory

function test_fetch_local_absolute_file {
    rm -f "$TEMP_LOG"
    local temp_file=$(mktemp)
    mv "$temp_file" "$temp_file.zsh"
    temp_file="$temp_file.zsh"
    local source="local:$temp_file"
    local plugin_name=$(basename "$temp_file" .zsh)
    local expected_dir="$ZERT_PLUGINS_DIR/local/$plugin_name"
    local expected_link="$expected_dir/$(basename "$temp_file")"
    __zert-fetch "$source"
    assert_file_exists "$expected_link"
    assert_equals "$(readlink "$expected_link")" "$temp_file"
    rm "$temp_file"
}
test_case test_fetch_local_absolute_file

function test_fetch_github_shorthand {
    rm -f "$TEMP_LOG"
    local source="zsh-users/zsh-plugin-1"
    local expected_dest="$ZERT_PLUGINS_DIR/zsh-users/zsh-plugin-1"
    __zert-fetch "$source"
    assert_file_exists "$expected_dest/.git/info/exclude"
    assert_contains "*.zwc" "$(cat "$expected_dest/.git/info/exclude")"
    assert_contains "git clone https://github.com/zsh-users/zsh-plugin-1.git $expected_dest" "$(cat "$TEMP_LOG")"
}
test_case test_fetch_github_shorthand

function test_fetch_github_url {
    rm -f "$TEMP_LOG"
    local source="https://github.com/zsh-users/zsh-plugin-2.git"
    local expected_dest="$ZERT_PLUGINS_DIR/zsh-users/zsh-plugin-2"
    __zert-fetch "$source"
    assert_file_exists "$expected_dest/.git/info/exclude"
    assert_contains "*.zwc" "$(cat "$expected_dest/.git/info/exclude")"
    assert_contains "git clone $source $expected_dest" "$(cat "$TEMP_LOG")"
}
test_case test_fetch_github_url

function test_fetch_ssh_url {
    rm -f "$TEMP_LOG"
    local source="git@github.com:zsh-users/zsh-plugin-3"
    local expected_dest="$ZERT_PLUGINS_DIR/zsh-users/zsh-plugin-3"
    __zert-fetch "$source"
    assert_file_exists "$expected_dest/.git/info/exclude"
    assert_contains "*.zwc" "$(cat "$expected_dest/.git/info/exclude")"
    assert_contains "git clone $source $expected_dest" "$(cat "$TEMP_LOG")"
}
test_case test_fetch_ssh_url

function test_fetch_with_custom_name {
    rm -f "$TEMP_LOG"
    local source="zsh-users/zsh-plugin-4"
    local custom_name="custom/custome-name"
    local expected_dest="$ZERT_PLUGINS_DIR/$custom_name"
    __zert-fetch --name "$custom_name" "$source"
    assert_file_exists "$expected_dest/.git/info/exclude"
    assert_contains "*.zwc" "$(cat "$expected_dest/.git/info/exclude")"
    assert_contains "git clone https://github.com/zsh-users/zsh-plugin-4.git $expected_dest" "$(cat "$TEMP_LOG")"
}
test_case test_fetch_with_custom_name

function test_fetch_with_branch {
    rm -f "$TEMP_LOG"
    local source="zsh-users/zsh-plugin-5"
    local branch="dev"
    local expected_dest="$ZERT_PLUGINS_DIR/zsh-users/zsh-plugin-5"
    __zert-fetch --branch "$branch" "$source"
    assert_file_exists "$expected_dest/.git/info/exclude"
    assert_contains "*.zwc" "$(cat "$expected_dest/.git/info/exclude")"
    assert_contains "git clone --branch $branch https://github.com/zsh-users/zsh-plugin-5.git $expected_dest" "$(cat "$TEMP_LOG")"
}
test_case test_fetch_with_branch

function test_fetch_invalid_source {
    rm -f "$TEMP_LOG"
    local source="invalid_source"
    assert_fails __zert-fetch "$source"
    assert_contains "INVALID_SOURCE_FORMAT" "$(cat "$TEMP_LOG")"
}
test_case test_fetch_invalid_source

function test_skip_fetch_if_directory_exists {
    rm -f "$TEMP_LOG"
    local source="zsh-users/zsh-plugin-5"
    local expected_dest="$ZERT_PLUGINS_DIR/zsh-users/zsh-plugin-5"
    mkdir -p "$expected_dest"
    __zert-fetch "$source"
    assert_equals '' "$(cat "$TEMP_LOG" | grep -v "debug")"
}
test_case test_skip_fetch_if_directory_exists

function test_fetch_with_blobless_clone_style {
    ZERT_CLONE_STYLE="blobless"
    rm -f "$TEMP_LOG"
    local source="zsh-users/zsh-plugin-6"
    local expected_dest="$ZERT_PLUGINS_DIR/zsh-users/zsh-plugin-6"
    __zert-fetch "$source"
    assert_contains "git clone --filter=blob:none https://github.com/zsh-users/zsh-plugin-6.git $expected_dest" "$(cat "$TEMP_LOG")"
}
test_case test_fetch_with_blobless_clone_style

function test_fetch_with_treeless_clone_style {
    ZERT_CLONE_STYLE="treeless"
    rm -f "$TEMP_LOG"
    local source="zsh-users/zsh-plugin-7"
    local expected_dest="$ZERT_PLUGINS_DIR/zsh-users/zsh-plugin-7"
    __zert-fetch "$source"
    assert_contains "git clone --filter=tree:0 https://github.com/zsh-users/zsh-plugin-7.git $expected_dest" "$(cat "$TEMP_LOG")"
}
test_case test_fetch_with_treeless_clone_style

rm -f "${TEMP_LOG:-/dev/null}"
rm -rf "${TEMP_DIR:-/dev/null}"

test_summary && return 0 || return 1
