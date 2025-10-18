#!/usr/bin/env bash
# Test configuration for judge.sh test suite
# This file is sourced by test files to set common configuration

export TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test directory structure
export JUDGE_SH_ROOT="$(dirname "$TEST_ROOT")"
export JUDGE_SH="${JUDGE_SH_ROOT}/judge.sh"

# Test behavior flags
export JUDGE_TEST_MODE=1

# Color output in tests (set to 0 to disable)
export JUDGE_TEST_COLORS=1

# Snapshot configuration
export SNAPSHOT_UPDATE="${UPDATE_SNAPSHOTS:-0}"
export SNAPSHOT_VERBOSE="${VERBOSE:-0}"

# Auto-discover test files
# NOTE: This pattern explicitly excludes judge's own tests (test-judge-*)
# Projects using judge should name their tests with different patterns like:
# - test-feature.sh
# - test-myapp-*.sh
# - integration-*.sh
# etc.
shopt -s nullglob
TEST_FILES_ARRAY=()
for test_file in ${TEST_ROOT}/test-judge-*.sh; do
    basename_file="$(basename "$test_file")"
    TEST_FILES_ARRAY+=("$basename_file")
done
export TEST_FILES=("${TEST_FILES_ARRAY[@]}")
shopt -u nullglob
