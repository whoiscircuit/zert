#!/usr/bin/env zsh
# Tests for test framework
set -e

source "${0:A:h}/lib.zsh"

function test_assert_equals_pass {
  assert_equals "test" "test"
}

function test_assert_equals_fail {
  assert_fails assert_equals "test" "wrong"
}

function test_assert_file_exists_pass {
  touch /tmp/testfile
  assert_file_exists /tmp/testfile
}

function test_assert_file_exists_fail {
  assert_fails assert_file_exists /tmp/missing
}

function test_assert_file_not_exists_pass {
  assert_file_not_exists /tmp/missing
}

function test_assert_file_not_exists_fail {
  touch /tmp/testfile
  assert_fails assert_file_not_exists /tmp/testfile
}

function test_assert_fails_pass {
  assert_fails false
}

function test_assert_fails_fail {
  assert_fails true
}

test_case "assert_equals passes on equal strings" test_assert_equals_pass
test_case "assert_equals fails on unequal strings" test_assert_equals_fail
test_case "assert_file_exists passes on existing file" test_assert_file_exists_pass
test_case "assert_file_exists fails on missing file" test_assert_file_exists_fail
test_case "assert_file_not_exists passes on missing file" test_assert_file_not_exists_pass
test_case "assert_file_not_exists fails on existing file" test_assert_file_not_exists_fail
test_case "assert_fails passes on failing command" test_assert_fails_pass
test_case "assert_fails fails on succeeding command" test_assert_fails_fail

test_summary