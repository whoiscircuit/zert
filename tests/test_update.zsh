#!/usr/bin/env zsh
# Tests for __zert-update function

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"
source "$HERE/../functions/__zert-update"

# Setup temporary environment
TEMP_DIR=$(mktemp -d)
ZERT_PLUGINS_DIR="$TEMP_DIR/plugins"
ZERT_LOCKFILE="$TEMP_DIR/zert.lock"
mkdir -p "$ZERT_PLUGINS_DIR/repo/plugin1/.git"
mkdir -p "$ZERT_PLUGINS_DIR/repo/plugin2/.git"
mkdir -p "$ZERT_PLUGINS_DIR/local/local-plugin"  # Not a git repo
echo "[repo/plugin1]=old_hash" > "$ZERT_LOCKFILE"
echo "[repo/plugin2]=old_hash" >> "$ZERT_LOCKFILE"

# Mock git function to handle -C option
function git() {
  local dir
  if [[ "$1" == "-C" ]]; then
    dir="$2"
    shift 2
  else
    dir="."
  fi
  local cmd="$1"
  shift
  case "$cmd" in
    pull)
      echo "Pulled changes in $dir" >> "$TEMP_DIR/git.log"
      ;;
    rev-parse)
      if [[ "$1" == "HEAD" ]]; then
        echo "new_hash"  # Simulate new commit hash
      fi
      ;;
    *)
      echo "Unknown git command: $cmd" >&2
      return 1
      ;;
  esac
}

# Mock __zert-compile
function __zert-compile() {
  echo "Compiled $1" >> "$TEMP_DIR/compile.log"
  return 0
}

# Mock __zert-log
function __zert-log() {
  echo "__zert-log $@" >> "$TEMP_DIR/log"
}

# Update single plugin
function test_update_single_plugin() {
  rm -f "$TEMP_DIR/git.log" "$TEMP_DIR/compile.log" "$TEMP_DIR/log"
  __zert-update "plugin1"
  assert_contains "Pulled changes in $ZERT_PLUGINS_DIR/plugin1" "$(cat "$TEMP_DIR/git.log")"
  assert_contains "[plugin1]=new_hash" "$(cat "$ZERT_LOCKFILE")"
  assert_contains "Compiled plugin1" "$(cat "$TEMP_DIR/compile.log")"
}
test_case test_update_single_plugin

# Update all plugins when no arguments given
function test_update_all_plugins() {
  rm -f "$TEMP_DIR/git.log" "$TEMP_DIR/compile.log" "$TEMP_DIR/log"
  __zert-update
  assert_contains "Pulled changes in $ZERT_PLUGINS_DIR/plugin1" "$(cat "$TEMP_DIR/git.log")"
  assert_contains "Pulled changes in $ZERT_PLUGINS_DIR/plugin2" "$(cat "$TEMP_DIR/git.log")"
  assert_contains "[plugin1]=new_hash" "$(cat "$ZERT_LOCKFILE")"
  assert_contains "[plugin2]=new_hash" "$(cat "$ZERT_LOCKFILE")"
  assert_contains "Compiled plugin1" "$(cat "$TEMP_DIR/compile.log")"
  assert_contains "Compiled plugin2" "$(cat "$TEMP_DIR/compile.log")"
}
test_case test_update_all_plugins

# No git plugins found
function test_no_git_plugins() {
  rm -rf "$ZERT_PLUGINS_DIR"/*  # Clear plugins directory
  mkdir -p "$ZERT_PLUGINS_DIR/local-plugin"  # Only non-git plugin
  rm -f "$TEMP_DIR/git.log" "$TEMP_DIR/compile.log" "$TEMP_DIR/log"
  __zert-update
  assert_contains "__zert-log info No git plugins found in $ZERT_PLUGINS_DIR" "$(cat "$TEMP_DIR/log")"
  assert_file_not_exists "$TEMP_DIR/git.log"
  assert_file_not_exists "$TEMP_DIR/compile.log"
}
test_case test_no_git_plugins

# Cleanup
rm -rf "$TEMP_DIR"

test_summary && return 0 || return 1