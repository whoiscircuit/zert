#!/usr/bin/env zsh
# Tests for test framework
set -e

source "${0:A:h}/lib.zsh"

function test_assert_equals_passes_on_equal_strings {
  assert_equals "test" "test"
}
test_case test_assert_equals_passes_on_equal_strings

function test_assert_equals_fails_on_unequal_strings {
  assert_fails assert_equals "test" "wrong"
}
test_case test_assert_equals_fails_on_unequal_strings

function test_assert_file_exists_passes_on_existing_file {
  local TEMP_FILE="$(mktemp)"
  touch "$TEMP_FILE"
  assert_file_exists "$TEMP_FILE"
  local RESULT=$?
  rm $TEMP_FILE
  return $RESULT
}
test_case test_assert_file_exists_passes_on_existing_file

function test_assert_file_exists_fails_on_missing_file {
  assert_fails assert_file_exists /tmp/missing-pluwyfplywfhdcxnYwflpyu
}
test_case test_assert_file_exists_fails_on_missing_file

function test_assert_file_not_exists_passes_on_missing_file {
  assert_file_not_exists /tmp/missing-pluwyfplywfhdcxnYwflpyu
}
test_case test_assert_file_not_exists_passes_on_missing_file

function test_assert_file_not_exists_fails_on_existing_file {
  local TEMP_FILE="$(mktemp)"
  touch "$TEMP_FILE"
  assert_fails assert_file_not_exists "$TEMP_FILE"
  local RESULT=$?
  rm $TEMP_FILE
  return $RESULT
}
test_case test_assert_file_not_exists_fails_on_existing_file

function test_assert_fails_passes_on_failing_command {
  assert_fails false
}
test_case test_assert_fails_passes_on_failing_command

function test_assert_fails_fails_on_succeeding_command {
  assert_fails false
}
test_case test_assert_fails_fails_on_succeeding_command

test_summary