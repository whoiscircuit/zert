#!/usr/bin/env zsh
# Runs all Zert tests
set -e

typeset -ig TEST_COUNT=0
typeset -ig TEST_FAILS=0

source "${0:A:h}/lib.zsh"

for test_file in "${0:A:h}"/*_test.zsh; do
  echo "Running $test_file..."
  zsh "$test_file"
done

echo "All tests completed"
test_summary