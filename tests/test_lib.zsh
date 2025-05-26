#!/usr/bin/env zsh
# Tests for test framework
set -e

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"
TEMP_FILE="$(mktemp)"

function test_assert_equals_passes_on_equal_strings {
    assert_equals "test" "test"
}
test_case test_assert_equals_passes_on_equal_strings

function test_assert_equals_fails_on_unequal_strings {
    assert_fails assert_equals "test" "wrong"
}
test_case test_assert_equals_fails_on_unequal_strings

function test_assert_file_exists_passes_on_existing_file {
    touch "$TEMP_FILE"
    assert_file_exists "$TEMP_FILE"
}
test_case test_assert_file_exists_passes_on_existing_file

function test_assert_file_exists_fails_on_missing_file {
    rm -f "$TEMP_FILE"
    assert_fails assert_file_exists "$TEMP_FILE"
}
test_case test_assert_file_exists_fails_on_missing_file

function test_assert_file_not_exists_passes_on_missing_file {
    rm -f "$TEMP_FILE"
    assert_file_not_exists "$TEMP_FILE"
}
test_case test_assert_file_not_exists_passes_on_missing_file

function test_assert_file_not_exists_fails_on_existing_file {
    touch "$TEMP_FILE"
    assert_fails assert_file_not_exists "$TEMP_FILE"
}
test_case test_assert_file_not_exists_fails_on_existing_file

function test_assert_fails_passes_on_failing_command {
    assert_fails false
}
test_case test_assert_fails_passes_on_failing_command


function test_assert_contains {
    assert_contains "test" "testing"
    assert_fails assert_contains "bash" "zsh"
}
test_case test_assert_contains

test_summary
