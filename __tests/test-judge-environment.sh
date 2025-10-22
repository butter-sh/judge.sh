#!/usr/bin/env bash
# Test suite for judge.sh test environment utilities

# Test: cleanup_test_env handles missing directory
test_cleanup_missing_dir() {

  set +e
  cleanup_test_env >/dev/null 2>&1
  result=$?
  set -e
  assert_equals 0 $result "Should handle missing directory gracefully"
}

# Test: capture_output captures stdout
test_capture_stdout() {

  output=$(capture_output "echo 'test output'")
  assert_equals "test output" "$output" "Should capture stdout"
}

# Test: capture_output captures stderr
test_capture_stderr() {

  output=$(capture_output "echo 'error output' >&2")
  assert_equals "error output" "$output" "Should capture stderr"
}

# Test: capture_output with successful command
test_capture_success() {

  output=$(capture_output "echo success; exit 0")
  assert_equals "success" "$output" "Should capture output from successful command"
}

# Test: capture_output with failed command
test_capture_failure() {

  output=$(capture_output "echo failure; exit 1" || true)
  assert_equals "failure" "$output" "Should capture output from failed command"
}

# Test: capture_output handles complex commands
test_capture_complex() {

  output=$(capture_output "echo line1; echo line2; echo line3")
  assert_contains "$output" "line1" "Should contain line1"
  assert_contains "$output" "line2" "Should contain line2"
  assert_contains "$output" "line3" "Should contain line3"
}

# Test: capture_output handles pipes
test_capture_pipes() {

  output=$(capture_output "echo 'test' | tr 'a-z' 'A-Z'")
  assert_equals "TEST" "$output" "Should handle pipes"
}

# Test: environment functions exported
test_exported_functions() {

  assert_true "type log_info > /dev/null 2>&1" "log_info should be exported"
  assert_true "type capture_output > /dev/null 2>&1" "capture_output should be exported"
  assert_true "type setup_test_env > /dev/null 2>&1" "setup_test_env should be exported"
  assert_true "type cleanup_test_env > /dev/null 2>&1" "cleanup_test_env should be exported"
}

# Run all tests
run_tests() {
  log_section "Environment Tests"

  test_capture_stdout
  test_capture_stderr
  test_capture_success
  test_capture_failure
  test_capture_complex
  test_capture_pipes
  test_exported_functions
}

export -f run_tests
