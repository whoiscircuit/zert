#!/usr/bin/env zsh
# Tests for zert.plugin.zsh

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"

# mock functinos
__zert-log(){
    echo $@
}

function test_zert_function_is_defined {
    source "$HERE/../functions/zert"
    assert_equals "function" "$(type -w zert | awk '{print $2}')"
}
test_case test_zert_function_is_defined

function test_zert_dispatches_add_subcommand {
    source "$HERE/../functions/zert"
    # Create a mock add function
    __zert-add() {
        echo "MOCK_ADD";
    }
    local output=$(zert add test_plugin)
    assert_contains "MOCK_ADD" "$output"
}
test_case test_zert_dispatches_add_subcommand

function test_zert_handles_unknown_subcommand {
    source "$HERE/../functions/zert"
    local output=$(zert unknown_subcommand 2>&1)
    assert_equals $? 0
    assert_contains "UNKNOWN_SUBCOMMAND" "$output"
}
test_case test_zert_handles_unknown_subcommand

test_summary && return 0 || return 1
