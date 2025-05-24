#!/usr/bin/env zsh
# Tests for zert-bootstrap.zsh
set -e

source "${0:A:h}/lib.zsh"

# Setup temporary environment
ZERT_TEST_DIR=$(mktemp -d)
ZERT_PLUGINS_DIR="$ZERT_TEST_DIR/plugins"

# Mock git
function git {
  echo "git $@" >> "$ZERT_TEST_DIR/git.log"
  if [[ "$1" = "clone" ]]; then
    mkdir -p "$ZERT_PLUGINS_DIR/zert"
    touch "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh"
  fi
  return 0
}

# Mock failing git
function git_fail {
  echo "git $@" >> "$ZERT_TEST_DIR/git.log"
  return 1
}

function test_bootstrap_installs_zert {
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2>&1
  assert_file_exists "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh"
  assert_equals "" "$(cat /tmp/zert_bootstrap.out)"
}

function test_bootstrap_respects_zert_dir {
  ZERT_DIR="$ZERT_TEST_DIR/custom"
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2>&1
  assert_file_exists "$ZERT_DIR/plugins/zert/zert.plugin.zsh"
  assert_equals "" "$(cat /tmp/zert_bootstrap.out)"
}

function test_bootstrap_respects_xdg_data_home {
  unset ZERT_DIR ZERT_PLUGINS_DIR
  XDG_DATA_HOME="$ZERT_TEST_DIR/xdg"
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2>&1
  assert_file_exists "$XDG_DATA_HOME/zert/plugins/zert/zert.plugin.zsh"
  assert_equals "" "$(cat /tmp/zert_bootstrap.out)"
}

function test_bootstrap_silent_if_zert_already_installed {
  mkdir -p "$ZERT_PLUGINS_DIR/zert"
  touch "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh"
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2>&1
  assert_file_exists "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh"
  assert_equals "" "$(cat /tmp/zert_bootstrap.out)"
  assert_file_not_exists "$ZERT_TEST_DIR/git.log"
}

function test_bootstrap_fails_with_red_error_if_git_missing {
  unfunction git
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2> /tmp/zert_bootstrap.err
  assert_fails source "${0:A:h}/../zert-bootstrap.zsh"
  assert_equals $'\033[31m[ZERT]: git is required to install Zert\033[0m' "$(cat /tmp/zert_bootstrap.err)"
}

function test_bootstrap_fails_with_red_error_if_git_clone_fails {
  function git { git_fail "$@"; }
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2> /tmp/zert_bootstrap.err
  assert_fails source "${0:A:h}/../zert-bootstrap.zsh"
  assert_equals $'\033[31m[ZERT]: Failed to clone Zert to '"$ZERT_PLUGINS_DIR/zert"$'\033[0m' "$(cat /tmp/zert_bootstrap.err)"
}

function test_bootstrap_fails_with_red_error_if_mkdir_fails {
  function mkdir { return 1; }
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2> /tmp/zert_bootstrap.err
  assert_fails source "${0:A:h}/../zert-bootstrap.zsh"
  assert_equals $'\033[31m[ZERT]: Failed to create '"$ZERT_PLUGINS_DIR"$'\033[0m' "$(cat /tmp/zert_bootstrap.err)"
}

function test_bootstrap_logs_cloning_in_blue {
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2> /tmp/zert_bootstrap.err
  assert_file_exists "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh"
  assert_equals $'\033[34m[ZERT]: Cloning Zert to '"$ZERT_PLUGINS_DIR/zert"$'\033[0m' "$(cat /tmp/zert_bootstrap.out)"
}

test_case test_bootstrap_installs_zert_silently
test_case test_bootstrap_respects_zert_dir
test_case test_bootstrap_respects_xdg_data_home
test_case test_bootstrap_silent_if_zert_already_installed
test_case test_bootstrap_fails_with_red_error_if_git_missing
test_case test_bootstrap_fails_with_red_error_if_git_clone_fails
test_case test_bootstrap_fails_with_red_error_if_mkdir_fails
test_case test_bootstrap_logs_cloning_in_blue

test_summary

# Cleanup
rm -rf "$ZERT_TEST_DIR" /tmp/zert_bootstrap.out /tmp/zert_bootstrap.err