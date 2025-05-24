#!/usr/bin/env zsh
# Runs all Zert tests
set -e

typeset -ig TEST_COUNT=0
typeset -ig TEST_FAILS=0

source "${0:A:h}/lib.zsh"

# Colors
local YELLOW="\033[33m"
local RESET="\033[0m"

for test_file in "${0:A:h}"/test_*.zsh; do
  echo "${YELLOW}Running $test_file...${RESET}"
  zsh "$test_file"
done

echo "All tests completed"