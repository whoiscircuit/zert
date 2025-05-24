#!/usr/bin/env zsh
# Tests for zert-bootstrap.zsh
set -e

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"

ZERT_TEST_DIR=$(mktemp -d)
ZERT_PLUGINS_DIR="$ZERT_TEST_DIR/plugins"

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
  source "$HERE/../zert-bootstrap.zsh"
  assert_file_exists "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh"
}
test_case test_bootstrap_installs_zert

function test_bootstrap_respects_zert_dir {
  ZERT_DIR="$ZERT_TEST_DIR/custom"
  source "$HERE/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2>&1
  assert_file_exists "$ZERT_DIR/plugins/zert/zert.plugin.zsh"
  assert_equals "" "$(cat /tmp/zert_bootstrap.out)"
}
test_case test_bootstrap_respects_zert_dir

function test_bootstrap_respects_xdg_data_home {
  unset ZERT_DIR ZERT_PLUGINS_DIR
  XDG_DATA_HOME="$ZERT_TEST_DIR/xdg"
  source "$HERE/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2>&1
  assert_file_exists "$XDG_DATA_HOME/zert/plugins/zert/zert.plugin.zsh"
  assert_equals "" "$(cat /tmp/zert_bootstrap.out)"
}
test_case test_bootstrap_respects_xdg_data_home

function test_bootstrap_silent_if_zert_already_installed {
  mkdir -p "$ZERT_PLUGINS_DIR/zert"
  touch "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh"
  source "$HERE/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2>&1
  assert_file_exists "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh"
  assert_equals "" "$(cat /tmp/zert_bootstrap.out)"
  assert_file_not_exists "$ZERT_TEST_DIR/git.log"
}
test_case test_bootstrap_silent_if_zert_already_installed

function test_bootstrap_fails_with_red_error_if_git_missing {
  unfunction git
  source "$HERE/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2> /tmp/zert_bootstrap.err
  assert_fails source "$HERE/../zert-bootstrap.zsh"
  assert_equals $'\033[31m[ZERT]: git is required to install Zert\033[0m' "$(cat /tmp/zert_bootstrap.err)"
}
test_case test_bootstrap_fails_with_red_error_if_git_missing

function test_bootstrap_fails_with_red_error_if_git_clone_fails {
  function git { git_fail "$@"; }
  source "$HERE/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2> /tmp/zert_bootstrap.err
  assert_fails source "$HERE/../zert-bootstrap.zsh"
  assert_equals $'\033[31m[ZERT]: Failed to clone Zert to '"$ZERT_PLUGINS_DIR/zert"$'\033[0m' "$(cat /tmp/zert_bootstrap.err)"
}
test_case test_bootstrap_fails_with_red_error_if_git_clone_fails

function test_bootstrap_fails_with_red_error_if_mkdir_fails {
  function mkdir { return 1; }
  source "$HERE/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2> /tmp/zert_bootstrap.err
  assert_fails source "$HERE/../zert-bootstrap.zsh"
  assert_equals $'\033[31m[ZERT]: Failed to create '"$ZERT_PLUGINS_DIR"$'\033[0m' "$(cat /tmp/zert_bootstrap.err)"
}
test_case test_bootstrap_fails_with_red_error_if_mkdir_fails

function test_bootstrap_logs_cloning_in_blue {
  source "$HERE/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2> /tmp/zert_bootstrap.err
  assert_file_exists "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh"
  assert_equals $'\033[34m[ZERT]: Cloning Zert to '"$ZERT_PLUGINS_DIR/zert"$'\033[0m' "$(cat /tmp/zert_bootstrap.out)"
}
test_case test_bootstrap_logs_cloning_in_blue


test_summary