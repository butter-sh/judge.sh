#!/usr/bin/env bash

# Example test suite that runs with the test runner
# Add your actual test suites following this pattern

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test-helpers.sh"

log_section "Example Test Suite"

# Setup test environment
setup_test_env

# ============================================================================
# TEST CASES
# ============================================================================

log_test "Test 1: Basic assertion"
assert_equals "expected" "expected" "String equality check"

log_test "Test 2: File operations"
test_file="${TEMP_DIR}/test.txt"
echo "test content" > "$test_file"
assert_file_exists "$test_file" "File should be created"

log_test "Test 3: String contains"
output="Hello World from judge.sh"
assert_contains "$output" "World" "Output should contain 'World'"

log_test "Test 4: Exit code verification"
true
assert_exit_code 0 $? "Command should succeed with exit code 0"

log_test "Test 5: Directory check"
test_dir="${TEMP_DIR}/testdir"
mkdir -p "$test_dir"
assert_directory_exists "$test_dir" "Directory should exist"

# ============================================================================
# CLEANUP
# ============================================================================

cleanup_test_env

# Print test summary
print_test_summary

exit $?
