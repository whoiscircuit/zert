#!/usr/bin/env zsh
# Tests for __zert-add function

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"
source "$HERE/../functions/__zert-add"
source "$HERE/../lib/__zert-get-plugin-name"

# Setup temporary environment
TEMP_DIR=$(mktemp -d)
ZERT_PLUGINS_DIR="$TEMP_DIR/plugins"
mkdir -p "$ZERT_PLUGINS_DIR"

# Mock functions
function __zert-fetch() {
  local source="$1"
  mkdir -p "$ZERT_PLUGINS_DIR/$source"
  echo "echo $source" > "$ZERT_PLUGINS_DIR/$source/entry.zsh"
  return 0
}

function __zert-align-version() {
  return 0  # Assume alignment was performed
}

function __zert-compile() {
  echo "Compiled $1" > "$TEMP_DIR/compile.log"
  return 0
}
function __zert-log() {
  echo "__zert-log $@" >&2
  echo "__zert-log $@" >> "$TEMP_DIR/zert.log"
}

# Fetches and loads new plugin
function test_fetches_and_loads_new_plugin {
  local source="repo/test-plugin"
  rm -f "$TEMP_DIR/compile.log"
  __zert-is-aligned() { return 1; }
  __zert-add "$source"
  assert_file_exists "$ZERT_PLUGINS_DIR/$source/entry.zsh"
  assert_contains "Compiled $source" "$(cat "$TEMP_DIR/compile.log")"
}
test_case test_fetches_and_loads_new_plugin

# Loads existing aligned plugin silently
function test_loads_existing_aligned_plugin {
  local source="repo/existing-plugin"
  rm -f "$TEMP_DIR/compile.log" "$TEMP_DIR/zert.log"
  mkdir -p "$ZERT_PLUGINS_DIR/$source"
  touch "$ZERT_PLUGINS_DIR/$source/entry.zsh"
  __zert-is-aligned() { return 0; }
  __zert-add "$source"
  assert_file_not_exists "$TEMP_DIR/compile.log"
  assert_file_not_exists "$TEMP_DIR/zert.log"
}
test_case test_loads_existing_aligned_plugin

# Aligns and compiles if not aligned
function test_aligns_and_compiles_if_not_aligned {
  local source="repo/misaligned-plugin"
  rm -f "$TEMP_DIR/compile.log" "$TEMP_DIR/zert.log"
  mkdir -p "$ZERT_PLUGINS_DIR/$source"
  touch "$ZERT_PLUGINS_DIR/$source/entry.zsh"
  __zert-is-aligned() { echo "aligned called" >> "$TEMP_DIR/zert.log" ;return 1; }
  __zert-add "$source"
  assert_contains "Compiled $source" "$(cat "$TEMP_DIR/compile.log")"
  assert_contains "aligned called" "$(cat "$TEMP_DIR/zert.log")"
}
test_case test_aligns_and_compiles_if_not_aligned

# Handles --no-aliases flag
function test_handles_no_aliases_flag {
  local source="repo/aliases-plugin"
  mkdir -p "$ZERT_PLUGINS_DIR/$source"
  echo "alias test_alias='echo test'" > "$ZERT_PLUGINS_DIR/$source/entry.zsh"
  __zert-is-aligned() { return 0; }
  __zert-add "$source" --no-aliases 
  local output=$(alias test_alias)
  assert_equals "$output" ""
}
test_case test_handles_no_aliases_flag

# Uses custom entry file
function test_uses_custom_entry_file {
  local source="repo/custom-entry-plugin"
  mkdir -p "$ZERT_PLUGINS_DIR/$source"
  touch "$ZERT_PLUGINS_DIR/$source/custom.zsh"
  __zert-is-aligned() { return 0; }
  __zert-add "$source" --entry "custom.zsh" 
  # Note: Actual sourcing verification would require additional setup
}
test_case test_uses_custom_entry_file

# test_case test_uses_custom_entry_file
rm -rf "${TEMP_DIR:-/dev/null}"

test_summary && return 0 || return 1