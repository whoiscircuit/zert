#!/usr/bin/env zsh
# Tests for __zert-purge function

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"
source "$HERE/../functions/__zert-purge"

# Setup temporary environment
TEMP_DIR=$(mktemp -d)
ZERT_PLUGINS_DIR="$TEMP_DIR/plugins"
ZERT_LOCKFILE="$TEMP_DIR/zert.lock"
mkdir -p "$ZERT_PLUGINS_DIR"

# Mock __zert-log
function __zert-log() {
  echo "__zert-log $@" >> "$TEMP_DIR/log"
}

# Purge unused plugin directories
function test_purge_unused_plugins {
  mkdir -p "$ZERT_PLUGINS_DIR/repo/keep-plugin"
  mkdir -p "$ZERT_PLUGINS_DIR/repo/purge-plugin"
  echo "[repo/keep-plugin]=hash1" > "$ZERT_LOCKFILE"
  echo "[repo/purge-plugin]=hash2" >> "$ZERT_LOCKFILE"
  ZERT_PLUGINS_LIST=("repo/keep-plugin")
  __zert-purge
  assert_dir_exists "$ZERT_PLUGINS_DIR/repo/keep-plugin"
  assert_fails assert_dir_exists "$ZERT_PLUGINS_DIR/repo/purge-plugin"
  assert_contains "[repo/keep-plugin]=hash1" "$(cat "$ZERT_LOCKFILE")"
  assert_not_contains "[repo/purge-plugin]=hash2" "$(cat "$ZERT_LOCKFILE")"
}
test_case test_purge_unused_plugins

# Remove symlinks without affecting originals
function test_remove_symlinks {
  local original_dir=$(mktemp -d)
  mkdir -p "$ZERT_PLUGINS_DIR/local"
  local symlink_dir="$ZERT_PLUGINS_DIR/local/local-plugin"
  ln -s "$original_dir" "$symlink_dir"
  ZERT_PLUGINS_LIST=()
  __zert-purge
  assert_fails assert_dir_exists "$symlink_dir"
  assert_dir_exists "$original_dir"
}
test_case test_remove_symlinks

# Handle missing lockfile
function test_handle_missing_lockfile {
  mkdir -p "$ZERT_PLUGINS_DIR/repo/keep-plugin"
  mkdir -p "$ZERT_PLUGINS_DIR/repo/purge-plugin"
  rm -f "$ZERT_LOCKFILE"
  ZERT_PLUGINS_LIST=("repo/keep-plugin")
  __zert-purge
  assert_dir_exists "$ZERT_PLUGINS_DIR/repo/keep-plugin"
  assert_fails assert_dir_exists "$ZERT_PLUGINS_DIR/repo/purge-plugin"
  assert_fails assert_file_exists "$ZERT_LOCKFILE"
}
test_case test_handle_missing_lockfile

# Purge all if ZERT_PLUGINS_LIST is empty
function test_purge_all_if_empty_list {
  mkdir -p "$ZERT_PLUGINS_DIR/repo/plugin1"
  mkdir -p "$ZERT_PLUGINS_DIR/repo/plugin2"
  ZERT_PLUGINS_LIST=()
  __zert-purge
  assert_fails assert_dir_exists "$ZERT_PLUGINS_DIR/repo/plugin1"
  assert_fails assert_dir_exists "$ZERT_PLUGINS_DIR/repo/plugin2"
}
test_case test_purge_all_if_empty_list

# Skip non-directory items
function test_skip_non_directory_items {
  touch "$ZERT_PLUGINS_DIR/not_a_plugin.txt"
  ZERT_PLUGINS_LIST=()
  __zert-purge
  assert_file_exists "$ZERT_PLUGINS_DIR/not_a_plugin.txt"
}
test_case test_skip_non_directory_items

# Cleanup
rm -rf "$TEMP_DIR"

test_summary && return 0 || return 1