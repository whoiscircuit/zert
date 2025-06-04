#!/usr/bin/env zsh
# Test framework for Zert

# Global counter for test results
TEST_COUNT=0
TEST_FAILS=0

# Colors
local RED="\033[31m"
local GREEN="\033[32m"
local BLUE="\033[34m"
local GRAY="\e[38;5;8m"
local RESET="\033[0m"

# Run a test case
function test_case {
    local fn="$1"
    TEST_COUNT=$((TEST_COUNT + 1))
    echo -n "${BLUE}Running test: $fn... ${RESET}"
    OUTPUT_FILE=$(mktemp)
    {
        set +e
        (
            set +e
            "$fn" >$OUTPUT_FILE 2>&1
        )
        local SUCCESS=$?
    }
    if [ $SUCCESS -eq 0 ]; then
        echo "${GREEN}PASS${RESET}"
    else
        echo "${RED}FAIL${RESET}"
        echo "${GRAY}OUTPUT:${RESET}"
        echo "$(cat $OUTPUT_FILE)"
        echo ""
        TEST_FAILS=$((TEST_FAILS + 1))
    fi
    rm "$OUTPUT_FILE"
}

# Assert two values are equal
function assert_equals {
    local expected="$1"
    local actual="$2"
    if [ "$expected" = "$actual" ]; then
        return 0
    else
        echo "Assertion failed: expected '$expected', got '$actual'"
        return 1
    fi
}

# Assert substring Exists in string
function assert_contains {
    local substring="$1"
    local string="$2"
    if [[ "$string" == *"$substring"* ]]; then
        return 0
    else
        echo "Assertion failed: string '$string' does not contain substring '$substring'"
        return 1
    fi
}
function assert_not_contains {
    if assert_contains "$1" "$2"; then
        echo "Assertion failed: string '$string' does contain substring '$substring' but it shouldn't"
        return 1
    else
        return 0
    fi
}

# Assert a file exists
function assert_file_exists {
    local file="$1"
    if [ -f "$file" ]; then
        return 0
    else
        echo "File does not exist: $file"
        return 1
    fi
}

# Assert a directory exists
function assert_dir_exists {
    local dir="$1"
    if [ -d "$dir" ]; then
        return 0
    else
        echo "directory does not exist: $dir"
        return 1
    fi
}

# Assert a file does not exist
function assert_file_not_exists {
    local file="$1"
    if [ ! -f "$file" ]; then
        return 0
    else
        echo "File exists: $file"
        return 1
    fi
}

# Assert a command fails
function assert_fails {
    {
        set +e
        "$@"
    }
    if [ $? -eq 0 ]; then
        echo "Command succeeded unexpectedly: $@"
        return 1
    fi
    return 0
}

# Print test summary
function test_summary {
    echo "Ran $TEST_COUNT tests, $TEST_FAILS failures"
    [ $TEST_FAILS -eq 0 ] && return 0 || return 1
}
