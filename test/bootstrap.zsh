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

function test_bootstrap_install {
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2>&1
  assert_file_exists "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh"
  assert_equals "" "$(cat /tmp/zert_bootstrap.out)"
}

function test_bootstrap_zert_dir {
  ZERT_DIR="$ZERT_TEST_DIR/custom"
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2>&1
  assert_file_exists "$ZERT_DIR/plugins/zert/zert.plugin.zsh"
  assert_equals "" "$(cat /tmp/zert_bootstrap.out)"
}

function test_bootstrap_xdg_data_home {
  unset ZERT_DIR ZERT_PLUGINS_DIR
  XDG_DATA_HOME="$ZERT_TEST_DIR/xdg"
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2>&1
  assert_file_exists "$XDG_DATA_HOME/zert/plugins/zert/zert.plugin.zsh"
  assert_equals "" "$(cat /tmp/zert_bootstrap.out)"
}

function test_bootstrap_already_installed {
  mkdir -p "$ZERT_PLUGINS_DIR/zert"
  touch "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh"
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2>&1
  assert_file_exists "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh"
  assert_equals "" "$(cat /tmp/zert_bootstrap.out)"
  assert_file_not_exists "$ZERT_TEST_DIR/git.log"
}

function test_bootstrap_no_git {
  unfunction git
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2> /tmp/zert_bootstrap.err
  assert_fails source "${0:A:h}/../zert-bootstrap.zsh"
  assert_equals $'\033[31m[ZERT]: git is required to install Zert\033[0m' "$(cat /tmp/zert_bootstrap.err)"
}

function test_bootstrap_git_clone_fails {
  function git { git_fail "$@"; }
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2> /tmp/zert_bootstrap.err
  assert_fails source "${0:A:h}/../zert-bootstrap.zsh"
  assert_equals $'\033[31m[ZERT]: Failed to clone Zert to '"$ZERT_PLUGINS_DIR/zert"$'\033[0m' "$(cat /tmp/zert_bootstrap.err)"
}

function test_bootstrap_mkdir_fails {
  function mkdir { return 1; }
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2> /tmp/zert_bootstrap.err
  assert_fails source "${0:A:h}/../zert-bootstrap.zsh"
  assert_equals $'\033[31m[ZERT]: Failed to create '"$ZERT_PLUGINS_DIR"$'\033[0m' "$(cat /tmp/zert_bootstrap.err)"
}

function test_bootstrap_clone_log {
  source "${0:A:h}/../zert-bootstrap.zsh" > /tmp/zert_bootstrap.out 2> /tmp/zert_bootstrap.err
  assert_file_exists "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh"
  assert_equals $'\033[34m[ZERT]: Cloning Zert to '"$ZERT_PLUGINS_DIR/zert"$'\033[0m' "$(cat /tmp/zert_bootstrap.out)"
}

test_case "Bootstrap installs Zert silently on success" test_bootstrap_install
test_case "Bootstrap respects ZERT_DIR" test_bootstrap_zert_dir
test_case "Bootstrap respects XDG_DATA_HOME" test_bootstrap_xdg_data_home
test_case "Bootstrap is silent if Zert already installed" test_bootstrap_already_installed
test_case "Bootstrap fails with red error if git is missing" test_bootstrap_no_git
test_case "Bootstrap fails with red error if git clone fails" test_bootstrap_git_clone_fails
test_case "Bootstrap fails with red error if mkdir fails" test_bootstrap_mkdir_fails
test_case "Bootstrap logs cloning in blue" test_bootstrap_clone_log

test_summary

# Cleanup
rm -rf "$ZERT_TEST_DIR" /tmp/zert_bootstrap.out /tmp/zert_bootstrap.err