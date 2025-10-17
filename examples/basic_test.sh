#!/usr/bin/env bash

# Example test suite
# Demonstrates basic testing features

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../test-helpers.sh"

log_section "Example Test Suite"

# Setup
setup_test_env

# Test 1: Basic assertion
log_test "Basic string equality"
assert_equals "hello" "hello" "Should compare equal strings"

# Test 2: Exit code check
log_test "Command exit code"
true
assert_exit_code 0 $? "Command should succeed"

# Test 3: File existence (will fail if file doesn't exist, showing how failures look)
log_test "File existence check"
echo "test content" > "${TEMP_DIR}/test-file.txt"
assert_file_exists "${TEMP_DIR}/test-file.txt" "Test file should exist"

# Test 4: String contains
log_test "String contains check"
output="The quick brown fox"
assert_contains "$output" "quick" "Output should contain 'quick'"

# Test 5: Directory existence
log_test "Directory existence check"
mkdir -p "${TEMP_DIR}/test-dir"
assert_directory_exists "${TEMP_DIR}/test-dir" "Test directory should exist"

# Test 6: Command success
log_test "Command success check"
assert_true "[ 1 -eq 1 ]" "Math comparison should succeed"

# Cleanup
cleanup_test_env

# Print summary
print_test_summary
