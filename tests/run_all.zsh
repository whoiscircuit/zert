#!/usr/bin/env zsh
# Runs all Zert tests
set -e

typeset -ig TEST_COUNT=0
typeset -ig TEST_FAILS=0
typeset -i TOTAL_TEST_COUNT=0
typeset -i TOTAL_TEST_FAILS=0

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"

# Colors
local YELLOW="\033[33m"
local RESET="\033[0m"

for test_file in "$HERE"/test_*.zsh; do
    echo "${YELLOW}Running $test_file...${RESET}"
    source "$test_file"
    TOTAL_TEST_COUNT=$(( $TOTAL_TEST_COUNT + $TEST_COUNT ))
    TOTAL_TEST_FAILS=$(( $TOTAL_TEST_FAILS + $TEST_FAILS ))
done

echo "All tests completed. Run ${TOTAL_TEST_COUNT} tests. ${TOTAL_TEST_FAILS} failed."
