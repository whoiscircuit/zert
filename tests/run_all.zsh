#!/usr/bin/env zsh
# Runs all Zert tests
set -e

typeset -ig TEST_COUNT=0
typeset -ig TEST_FAILS=0

HERE="${${(%):-%N}:A:h}"
source "$HERE/lib.zsh"

# Colors
local YELLOW="\033[33m"
local RESET="\033[0m"

for test_file in "$HERE"/test_*.zsh; do
  echo "${YELLOW}Running $test_file...${RESET}"
  zsh "$test_file"
done

echo "All tests completed"