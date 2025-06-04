#!/usr/bin/env zsh
# Tests for __zert-is-aligned function

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"
source "$HERE/../lib/__zert-get-plugin-info"
source "$HERE/../lib/__zert-is-aligned"


# Setup temporary environment
TEMP_DIR=$(mktemp -d)
ZERT_PLUGINS_DIR="$TEMP_DIR/plugins"
ZERT_LOCKFILE="$TEMP_DIR/zert.lock"
mkdir -p "$ZERT_PLUGINS_DIR/test-plugin/.git"
echo "[test-plugin]=lockfile_hash" > "$ZERT_LOCKFILE"

# Mock git rev-parse
function git() {
  if [[ "$1" == "rev-parse" && "$2" == "HEAD" ]]; then
    echo "current_hash"
  else
    echo "Unexpected git command: $@"
    return 1
  fi
}

# Aligned with lockfile
function test_aligned_with_lockfile {
  git() { echo "lockfile_hash"; }
  __zert-is-aligned "test-plugin"
  assert_equals 0 $?
}
test_case test_aligned_with_lockfile

# Not aligned with lockfile
function test_not_aligned_with_lockfile {
  git() { echo "different_hash"; }
  assert_fails __zert-is-aligned "test-plugin"
}
test_case test_not_aligned_with_lockfile

# Plugin not in lockfile
function test_not_in_lockfile {
  echo "" > "$ZERT_LOCKFILE"
  assert_fails __zert-is-aligned "test-plugin"
  
}
test_case test_not_in_lockfile

# Not aligned with pin
function test_not_aligned_with_pin {
  git() { echo "different_hash"; }
  assert_fails __zert-is-aligned "test-plugin" "pin_hash"
}
test_case test_not_aligned_with_pin

# Plugin directory missing
function test_plugin_dir_missing {
  assert_fails __zert-is-aligned "missing-plugin"
}
test_case test_plugin_dir_missing

test_summary && return 0 || return 1