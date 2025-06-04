#!/usr/bin/env zsh
# Runs all Zert tests

typeset -ig TEST_COUNT=0
typeset -ig TEST_FAILS=0
typeset -i TOTAL_TEST_COUNT=0
typeset -i TOTAL_TEST_FAILS=0

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"

# Colors
local YELLOW="\033[33m"
local RESET="\033[0m"

failed_files=()
for test_file in "$HERE"/test_*.zsh; do
    echo "${YELLOW}Running $test_file...${RESET}"
    (zsh "$test_file" )
    if [ $? -ne 0 ]; then
        failed_files=($failed_files "$test_file")
    fi
done
if [[ -n "${failed_files[@]}" ]]; then
    echo ""
    echo "${YELLOW}FAILED_TESTS:${RESET}"
    print -l -- "${failed_files[@]}"
    return 1;
else
    echo ""
    echo "All Tests Passed!"
    return 0;
fi