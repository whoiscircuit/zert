#!/usr/bin/env zsh
# Tests for __zert-fetch function
set -e

# Determine the script's directory
HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"

# Setup temporary environment
TEMP_DIR=$(mktemp -d)
ZERT_PLUGINS_DIR="$TEMP_DIR/plugins"
HERE="$TEMP_DIR/test_dir"
mkdir -p "$HERE"

# Mock functions
git() {
    echo "git $@" >> "$TEMP_DIR/git.log"
    if [[ "$1" == "clone" ]]; then
        local dest="${@: -1}"
        mkdir -p "$dest/.git/info"
        touch "$dest/.git/info/exclude"
    fi
}

ln() {
    echo "ln $@" >> "$TEMP_DIR/ln.log"
    command ln "$@"
}

mkdir() {
    echo "mkdir $@" >> "$TEMP_DIR/mkdir.log"
    command mkdir "$@"
}

__zert-log() {
    echo "__zert-log $@" >> "$TEMP_DIR/log.log"
}

# Test Functions

test_fetch_github_repository() {
    source "$HERE/../functions/__zert-fetch"
    local source="user/repo"
    local expected_dest="$ZERT_PLUGINS_DIR/github-user-repo"

    __zert-fetch "$source"

    assert_file_exists "$expected_dest/.git/info/exclude"
    assert_contains "*.zwc" "$(cat "$expected_dest/.git/info/exclude")"
    assert_contains "git clone https://github.com/user/repo.git $expected_dest" "$(cat "$TEMP_DIR/git.log")"
}
test_case test_fetch_github_repository

test_fetch_url_repository() {
    source "$HERE/../functions/__zert-fetch"
    local source="https://example.com/user/repo.git"
    local expected_dest="$ZERT_PLUGINS_DIR/example.com-repo"

    __zert-fetch "$source"

    assert_file_exists "$expected_dest/.git/info/exclude"
    assert_contains "*.zwc" "$(cat "$expected_dest/.git/info/exclude")"
    assert_contains "git clone $source $expected_dest" "$(cat "$TEMP_DIR/git.log")"
}
test_case test_fetch_url_repository

test_fetch_ssh_repository() {
    source "$HERE/../functions/__zert-fetch"
    local source="git@example.com:user/repo"
    local expected_dest="$ZERT_PLUGINS_DIR/example.com-repo"

    __zert-fetch "$source"

    assert_file_exists "$expected_dest/.git/info/exclude"
    assert_contains "*.zwc" "$(cat "$expected_dest/.git/info/exclude")"
    assert_contains "git clone $source $expected_dest" "$(cat "$TEMP_DIR/git.log")"
}
test_case test_fetch_ssh_repository

test_fetch_local_directory_absolute() {
    source "$HERE/../functions/__zert-fetch"
    local temp_source_dir=$(mktemp -d)
    local source="local:$temp_source_dir"
    local plugin_name=$(basename "$temp_source_dir")
    local expected_dest="$ZERT_PLUGINS_DIR/local-$plugin_name"

    __zert-fetch "$source"

    assert_file_exists "$expected_dest"
    assert_equals "$(readlink "$expected_dest")" "$temp_source_dir"
    assert_file_not_exists "$TEMP_DIR/git.log"  # No git commands for local
}
test_case test_fetch_local_directory_absolute

test_fetch_local_file_absolute() {
    source "$HERE/../functions/__zert-fetch"
    local temp_source_file="$TEMP_DIR/test_file.zsh"
    touch "$temp_source_file"
    local source="local:$temp_source_file"
    local plugin_name="test_file"
    local expected_dir="$ZERT_PLUGINS_DIR/local-$plugin_name"
    local expected_link="$expected_dir/test_file.zsh"

    __zert-fetch "$source"

    assert_file_exists "$expected_link"
    assert_equals "$(readlink "$expected_link")" "$temp_source_file"
    assert_file_not_exists "$TEMP_DIR/git.log"
}
test_case test_fetch_local_file_absolute

test_fetch_local_directory_relative() {
    source "$HERE/../functions/__zert-fetch"
    local relative_path="test_dir"
    local expected_source="$HERE/$relative_path"
    mkdir -p "$expected_source"
    local source="local:$relative_path"
    local plugin_name="$relative_path"
    local expected_dest="$ZERT_PLUGINS_DIR/local-$plugin_name"

    __zert-fetch "$source"

    assert_file_exists "$expected_dest"
    assert_equals "$(readlink "$expected_dest")" "$expected_source"
}
test_case test_fetch_local_directory_relative

test_fetch_invalid_source() {
    source "$HERE/../functions/__zert-fetch"
    local source="invalid_format"
    (__zert-fetch "$source" > /dev/null 2>&1)
    assert_fails $?
    assert_contains "__zert-log error 1 Invalid source format: $source" "$(cat "$TEMP_DIR/log.log")"
}
test_case test_fetch_invalid_source

test_skip_fetch_if_directory_exists() {
    source "$HERE/../functions/__zert-fetch"
    local source="user/repo"
    local expected_dest="$ZERT_PLUGINS_DIR/github-user-repo"
    mkdir -p "$expected_dest"

    __zert-fetch "$source"

    assert_file_not_exists "$TEMP_DIR/git.log"
    assert_contains "__zert-log info Plugin github-user-repo already exists in $expected_dest" "$(cat "$TEMP_DIR/log.log")"
}
test_case test_skip_fetch_if_directory_exists

test_fetch_with_blobless_clone_style() {
    source "$HERE/../functions/__zert-fetch"
    ZERT_CLONE_STYLE="blobless"
    local source="user/repo"
    local expected_dest="$ZERT_PLUGINS_DIR/github-user-repo"

    __zert-fetch "$source"

    assert_contains "git clone --filter=blob:none https://github.com/user/repo.git $expected_dest" "$(cat "$TEMP_DIR/git.log")"
}
test_case test_fetch_with_blobless_clone_style

rm -rf "${TEMP_DIR:-/dev/null}"

test_summary
