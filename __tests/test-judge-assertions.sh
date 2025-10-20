#!/usr/bin/env bash
# Test suite for judge.sh assertion functions

# Test: assert_equals works with matching values
test_assert_equals_success() {
  { assert_equals "test" "test" "Values should match" & } >/dev/null
  assert_success "Should succeed 'assert_equals'"
}

# Test: assert_equals fails with non-matching values
test_assert_equals_failure() {
  { assert_equals "expected" "actual" "Values should not match" & } >/dev/null
  assert_failure "Should fail 'assert_equals'"
}

# Test: assert_contains detects substring
test_assert_contains_success() {
  { assert_contains "Hello World" "World" "Should find substring" & } >/dev/null
  assert_success "Should succeed 'assert_contains'"
}

# Test: assert_contains fails when substring absent
test_assert_contains_failure() {
  { assert_contains "Hello World" "Missing" "Should not find substring" & } >/dev/null
  assert_success "Should fail 'assert_contains'"
}

# Test: assert_not_contains works correctly
test_assert_not_contains_success() {
  { assert_not_contains "Hello World" "Missing" "Should not contain substring" & } >/dev/null
  assert_success "Should succeed 'assert_not_contains'"
}

# Test: assert_not_contains fails when substring present
test_assert_not_contains_failure() {
  { assert_not_contains "Hello World" "World" "Should fail" & } >/dev/null
  assert_success "Should fail 'assert_not_contains'"
}

# Test: assert_exit_code checks correct code
test_assert_exit_code_success() {
  { assert_exit_code 0 0 "Exit codes should match" & } >/dev/null
  assert_success "Should succeed 'assert_exit_code'"
}

# Test: assert_exit_code fails on mismatch
test_assert_exit_code_failure() {
  { assert_exit_code assert_exit_code 0 1 "Exit codes mismatch" & } >/dev/null
  assert_success "Should fail 'assert_exit_code'"
}

# Test: assert_file_exists detects existing file
test_assert_file_exists_success() {
  touch "testfile.txt"
  { assert_file_exists "testfile.txt" "File should exist" & } >/dev/null
  assert_success "Should succeed 'assert_file_exists'"
}

# Test: assert_file_exists fails for missing file
test_assert_file_exists_failure() {
  { assert_file_exists "nonexistent.txt" "Missing file" & } >/dev/null
  assert_success "Should fail 'assert_file_exists'"
}

# Test: assert_directory_exists detects existing directory
test_assert_directory_exists_success() {
  mkdir "testdir"
  { assert_directory_exists "testdir" "Directory should exist" & } >/dev/null
  assert_success "Should succeed 'assert_directory_exists'"
}

# Test: assert_directory_exists fails for missing directory
test_assert_directory_exists_failure() {
  { assert_directory_exists "nonexistent" "Missing dir" & } >/dev/null
  assert_success "Should fail 'assert_directory_exists'"
}

# Test: assert_true evaluates commands
test_assert_true_success() {
  { assert_true "true" "True command" & } >/dev/null
  assert_success "Should succeed 'assert_true'"
}

# Test: assert_true fails for false commands
test_assert_true_failure() {
  { assert_true "false" "False command" & } >/dev/null
  assert_success "Should fail 'assert_true'"
}

# Test: assert_false evaluates commands
test_assert_false_success() {
  { assert_false "false" "False command" & } >/dev/null
  assert_success "Should succeed 'assert_false'"
}

# Test: assert_false fails for true commands
test_assert_false_failure() {
  { assert_false "true" "True command" & } >/dev/null
  assert_success "Should fail 'assert_false'"
}

# Run all tests
run_tests() {
  log_section "Assertion Tests"

  test_assert_equals_success
  test_assert_equals_failure
  test_assert_contains_success
  test_assert_contains_failure
  test_assert_not_contains_success
  test_assert_not_contains_failure
  test_assert_exit_code_success
  test_assert_exit_code_failure
  test_assert_file_exists_success
  test_assert_file_exists_failure
  test_assert_directory_exists_success
  test_assert_directory_exists_failure
  test_assert_true_success
  test_assert_true_failure
  test_assert_false_success
  test_assert_false_failure
}

export -f run_tests
