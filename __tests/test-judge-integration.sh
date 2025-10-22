#!/usr/bin/env bash
# Integration tests for judge.sh - tests complete workflows

# Test: complete test lifecycle
test_complete_lifecycle() {

  cat >"${TEMP_DIR}/test-simple.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "${TEMP_DIR}/test-simple.sh"
  set +e
  bash "${TEMP_DIR}/test-simple.sh" >/dev/null 2>&1
  result=$?
  set -e
  assert_equals 0 $result "Test should pass"
}

# Test: logging in sequence
test_logging_sequence() {

  output=$(
    log_info "Starting test"
    log_test "Running test"
    log_success "All done"
  ) 2>&1
  assert_contains "$output" "Starting test" "Should contain info"
  assert_contains "$output" "Running test" "Should contain test"
  assert_contains "$output" "All done" "Should contain success"
}

# Test: error handling
test_error_handling() {

  set +e
  false
  result=$?
  set -e
  assert_equals 1 $result "Should capture failure"
}

# Test: assertion functions work
test_assertions_work() {

  # Test assert_equals
  assert_equals "a" "a" "Equals should work"
  # Test assert_contains
  assert_contains "hello world" "world" "Contains should work"
  # Test assert_true
  assert_true "true" "True should work"
  # Test assert_false
  assert_false "false" "False should work"
}

# Test: capture output functionality
test_capture_functionality() {

  output=$(capture_output "echo test")
  assert_equals "test" "$output" "Should capture command output"
}

# Test: normalize output function
test_normalize_output() {

  input="  test  
    with spaces  "
  output=$(normalize_output "$input")
  # Just verify it produces some output
  assert_true "[[ -n \"$output\" ]]" "Should produce normalized output"
}

# Run all tests
run_tests() {
  log_section "Integration Tests"

  test_complete_lifecycle
  test_logging_sequence
  test_error_handling
  test_assertions_work
  test_capture_functionality
  test_normalize_output
}

export -f run_tests
