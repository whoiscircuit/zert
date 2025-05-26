#!/usr/bin/env zsh
# Tests for __zert-align-version function
set -e

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"
source "$HERE/../lib/__zert-align-version"

# Setup temporary environment
TEMP_DIR=$(mktemp -d)
ZERT_PLUGINS_DIR="$TEMP_DIR/plugins"
ZERT_LOCKFILE="$TEMP_DIR/zert.lock"
mkdir -p "$ZERT_PLUGINS_DIR/test-plugin/.git"
touch "$ZERT_LOCKFILE"

# Mock git commands
function git() {
  if [[ "$1" == '-C' ]]; then
    shift 2; 
  fi
  local cmd="$1"
  shift
  case "$cmd" in
    rev-parse)
      echo "current_hash"
      ;;
    checkout)
      echo "Checked out $1" > "$TEMP_DIR/git.log"
      ;;
    *)
      echo "Unknown git command: $cmd"
      return 1
      ;;
  esac
}

# Mock rm for zwc removal tracking
function rm() {
  echo "rm $@" >> "$TEMP_DIR/rm.log"
}

# Test 1: Exits quietly if ZERT_NO_LOCKFILE is set
function test_exits_quietly_with_no_lockfile {
  ZERT_NO_LOCKFILE=1
  __zert-align-version "test-plugin"
  assert_equals 0 $?
  assert_file_not_exists "$TEMP_DIR/log"  # No logging
}
test_case test_exits_quietly_with_no_lockfile

# Test 2: Errors if ZERT_LOCKFILE is missing
function test_errors_if_lockfile_missing {
  rm "$ZERT_LOCKFILE"
  ( __zert-align-version "test-plugin" > /dev/null 2>&1 )
  assert_fails $?
}
test_case test_errors_if_lockfile_missing

# Test 3: Exits quietly if already aligned
function test_exits_quietly_if_aligned {
  echo "[test-plugin]=current_hash" > "$ZERT_LOCKFILE"
  __zert-align-version "test-plugin"
  assert_equals 0 $?
  assert_file_not_exists "$TEMP_DIR/git.log"  # No git checkout
}
test_case test_exits_quietly_if_aligned

# Test 4: Aligns version if not aligned
function test_aligns_if_not_aligned {
  set -x
  echo "[test-plugin]=lockfile_hash" > "$ZERT_LOCKFILE"
  __zert-align-version "test-plugin"
  assert_contains "Checked out lockfile_hash" "$(cat "$TEMP_DIR/git.log")"
}
test_case test_aligns_if_not_aligned

# Test 5: Removes zwc files from subdirectories
function test_removes_zwc {
  touch "$ZERT_PLUGINS_DIR/test-plugin/root.zwc"
  mkdir -p "$ZERT_PLUGINS_DIR/test-plugin/subdir"
  touch "$ZERT_PLUGINS_DIR/test-plugin/subdir/test.zwc"
  echo "[test-plugin]=lockfile_hash" > "$ZERT_LOCKFILE"
  __zert-align-version "test-plugin"
  assert_file_not_exists "$ZERT_PLUGINS_DIR/test-plugin/subdir/test.zwc"
  assert_file_not_exists "$ZERT_PLUGINS_DIR/test-plugin/root.zwc"
}
test_case test_removes_zwc

# Test 6: Adds hash if plugin not in lockfile
function test_adds_hash_if_not_in_lockfile {
  echo "" > "$ZERT_LOCKFILE"
  __zert-align-version "test-plugin"
  assert_contains "[test-plugin]=current_hash" "$(cat "$ZERT_LOCKFILE")"
}
test_case test_adds_hash_if_not_in_lockfile

# Test 7: Errors on git failure
function test_errors_on_git_failure {
  function git() { return 1; }
  echo "[test-plugin]=lockfile_hash" > "$ZERT_LOCKFILE"
  assert_fails __zert-align-version "test-plugin"
}
test_case test_errors_on_git_failure

test_summary