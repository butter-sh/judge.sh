#!/usr/bin/env bash
# Test suite for judge.sh logging and output functions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_HELPERS="${SCRIPT_DIR}/../test-helpers.sh"

# Source helpers once at top level
source "$TEST_HELPERS"

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: log_test produces output
test_log_test_output() {
    setup
    output=$(log_test "Test message" 2>&1)
    assert_contains "$output" "Test message" "Should contain message"
    assert_contains "$output" "TEST" "Should have TEST prefix"
    teardown
}

# Test: log_pass produces output
test_log_pass_output() {
    setup
    output=$(log_pass "Pass message" 2>&1)
    assert_contains "$output" "Pass message" "Should contain message"
    assert_contains "$output" "PASS" "Should have PASS prefix"
    teardown
}

# Test: log_fail produces output
test_log_fail_output() {
    setup
    output=$(log_fail "Fail message" 2>&1)
    assert_contains "$output" "Fail message" "Should contain message"
    assert_contains "$output" "FAIL" "Should have FAIL prefix"
    teardown
}

# Test: log_skip produces output
test_log_skip_output() {
    setup
    output=$(log_skip "Skip message" 2>&1)
    assert_contains "$output" "Skip message" "Should contain message"
    assert_contains "$output" "SKIP" "Should have SKIP prefix"
    teardown
}

# Test: log_info produces output
test_log_info_output() {
    setup
    output=$(log_info "Info message" 2>&1)
    assert_contains "$output" "Info message" "Should contain message"
    assert_contains "$output" "INFO" "Should have INFO prefix"
    teardown
}

# Test: log_warning produces output
test_log_warning_output() {
    setup
    output=$(log_warning "Warning message" 2>&1)
    assert_contains "$output" "Warning message" "Should contain message"
    assert_contains "$output" "WARN" "Should have WARN prefix"
    teardown
}

# Test: log_error produces output
test_log_error_output() {
    setup
    output=$(log_error "Error message" 2>&1)
    assert_contains "$output" "Error message" "Should contain message"
    assert_contains "$output" "ERROR" "Should have ERROR prefix"
    teardown
}

# Test: log_success produces output
test_log_success_output() {
    setup
    output=$(log_success "Success message" 2>&1)
    assert_contains "$output" "Success message" "Should contain message"
    teardown
}

# Test: log_section produces formatted output
test_log_section_output() {
    setup
    output=$(log_section "Section Title" 2>&1)
    assert_contains "$output" "Section Title" "Should contain title"
    assert_contains "$output" "═" "Should have separator"
    teardown
}

# Test: logging functions handle empty strings
test_log_empty_strings() {
    setup
    set +e
    log_info "" 2>&1 >/dev/null
    log_warning "" 2>&1 >/dev/null
    log_error "" 2>&1 >/dev/null
    result=$?
    set -e
    assert_equals 0 $result "Should handle empty strings"
    teardown
}

# Test: logging functions handle special characters
test_log_special_characters() {
    setup
    output=$(log_info "Test with \$special & <characters>" 2>&1)
    assert_contains "$output" "special" "Should handle special characters"
    teardown
}

# Test: print_test_summary shows counters
test_print_summary() {
    setup
    
    # Write isolated test script
    cat > test_script.sh << 'SCRIPT_END'
#!/usr/bin/env bash
source "$1"
TESTS_RUN=10
TESTS_PASSED=8
TESTS_FAILED=2
output=$(print_test_summary 2>&1)
if [[ "$output" == *"Total Tests:"* ]] && \
   [[ "$output" == *"Passed:"* ]] && \
   [[ "$output" == *"Failed:"* ]]; then
    echo "pass"
else
    echo "fail"
fi
SCRIPT_END
    
    result=$(bash test_script.sh "$TEST_HELPERS")
    assert_equals "pass" "$result" "Summary should show counters"
    teardown
}

# Test: print_test_summary returns success when all pass
test_summary_success_return() {
    setup
    
    # Write isolated test script
    cat > test_script.sh << 'SCRIPT_END'
#!/usr/bin/env bash
source "$1"
TESTS_RUN=5
TESTS_PASSED=5
TESTS_FAILED=0
print_test_summary > /dev/null 2>&1
echo $?
SCRIPT_END
    
    result=$(bash test_script.sh "$TEST_HELPERS")
    assert_equals "0" "$result" "Should return 0 when all pass"
    teardown
}

# Test: print_test_summary returns failure when tests fail
test_summary_failure_return() {
    setup
    
    # Write isolated test script
    cat > test_script.sh << 'SCRIPT_END'
#!/usr/bin/env bash
source "$1"
TESTS_RUN=5
TESTS_PASSED=3
TESTS_FAILED=2
print_test_summary > /dev/null 2>&1
echo $?
SCRIPT_END
    
    result=$(bash test_script.sh "$TEST_HELPERS")
    assert_true "[[ $result -ne 0 ]]" "Should return non-zero when tests fail"
    teardown
}

# Test: print_test_summary handles zero tests
test_summary_zero_tests() {
    setup
    
    # Write isolated test script
    cat > test_script.sh << 'SCRIPT_END'
#!/usr/bin/env bash
source "$1"
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
output=$(print_test_summary 2>&1)
if [[ "$output" == *"Total Tests:  0"* ]]; then
    echo "pass"
else
    echo "fail"
fi
SCRIPT_END
    
    result=$(bash test_script.sh "$TEST_HELPERS")
    assert_equals "pass" "$result" "Should handle zero tests"
    teardown
}

# Test: print_test_summary calculates pass rate
test_summary_pass_rate() {
    setup
    
    # Write isolated test script
    cat > test_script.sh << 'SCRIPT_END'
#!/usr/bin/env bash
source "$1"
TESTS_RUN=10
TESTS_PASSED=8
TESTS_FAILED=2
output=$(print_test_summary 2>&1)
if [[ "$output" == *"80%"* ]]; then
    echo "pass"
else
    echo "fail"
fi
SCRIPT_END
    
    result=$(bash test_script.sh "$TEST_HELPERS")
    assert_equals "pass" "$result" "Should show 80% pass rate"
    teardown
}

# Test: logging functions are exported
test_functions_exported() {
    setup
    assert_true "type log_info > /dev/null 2>&1" "log_info should be available"
    assert_true "type log_pass > /dev/null 2>&1" "log_pass should be available"
    assert_true "type log_fail > /dev/null 2>&1" "log_fail should be available"
    assert_true "type log_section > /dev/null 2>&1" "log_section should be available"
    teardown
}

# Run all tests
run_tests() {
    test_log_test_output
    test_log_pass_output
    test_log_fail_output
    test_log_skip_output
    test_log_info_output
    test_log_warning_output
    test_log_error_output
    test_log_success_output
    test_log_section_output
    test_log_empty_strings
    test_log_special_characters
    test_print_summary
    test_summary_success_return
    test_summary_failure_return
    test_summary_zero_tests
    test_summary_pass_rate
    test_functions_exported
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
    print_test_summary
    exit $?
fi
