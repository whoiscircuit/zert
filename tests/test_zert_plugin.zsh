#!/usr/bin/env zsh
# Tests for zert.plugin.zsh
set -e

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"

function test_zert_function_is_defined {
    source "$HERE/../zert.plugin.zsh"
    assert_equals "function" "$(type -w zert | awk '{print $2}')"
}
test_case test_zert_function_is_defined

function test_zert_dispatches_add_subcommand {
    source "$HERE/../zert.plugin.zsh"
    # Create a mock add function
    zert-add() {
        echo '[MOCK] add called with $@';
    }
    local output=$(zert add test_plugin)
    assert_equals "[MOCK] add called with test_plugin" "$output"
}
test_case test_zert_dispatches_add_subcommand

function test_zert_handles_unknown_subcommand {
    source "$HERE/../zert.plugin.zsh"
    local output=$(zert unknown_subcommand 2>&1)
    assert_fails $? && \
    assert_equals "Unknown subcommand: unknown_subcommand" "$output"
}
test_case test_zert_handles_unknown_subcommand

test_summary
