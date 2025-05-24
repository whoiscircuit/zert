#!/usr/bin/env zsh
# Test framework for Zert
set -e

# Global counter for test results
[ -z "$TEST_COUNT" ] && typeset -i TEST_COUNT=0
[ -z "$TEST_FAILS" ] && typeset -i TEST_FAILS=0

# Colors
local RED="\033[31m"
local GREEN="\033[32m"
local BLUE="\033[34m"
local RESET="\033[0m"

# Run a test case
function test_case {
  local name="$1"
  local fn="$2"
  TEST_COUNT=$(( TEST_COUNT+1 ))
  echo -n "${BLUE}Running test: $name... ${RESET}"
  local OUTPUT=$(set +e; $fn 2>&1)
  if [ $? -eq 0 ]; then
    echo "${GREEN}PASS${RESET}"
  else
    echo "${RED}FAIL${RESET}"
    if [ -n "$OUTPUT" ]; then
      echo "OUTPUT:"
      echo "$OUTPUT"
      echo ""
    fi
    TEST_FAILS=$(( TEST_FAILS+1 ))
  fi
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
  "$@"
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