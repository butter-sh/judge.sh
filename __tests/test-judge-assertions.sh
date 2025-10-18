#!/usr/bin/env bash
# Test suite for judge.sh assertion functions

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_HELPERS="${SCRIPT_DIR}/../test-helpers.sh"

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    source "$TEST_HELPERS" 2>/dev/null
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: assert_equals works with matching values
test_assert_equals_success() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    assert_equals "test" "test" "Values should match" >/dev/null 2>&1
    
    if [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ assert_equals increments passed counter"
        teardown
        return 0
    else
        echo "✗ assert_equals did not increment passed counter"
        teardown
        return 1
    fi
}

# Test: assert_equals fails with non-matching values
test_assert_equals_failure() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_equals "expected" "actual" "Values should not match" >/dev/null 2>&1
    result=$?
    set -e
    
    if [[ $result -ne 0 ]] && [[ $TESTS_FAILED -eq 1 ]]; then
        echo "✓ assert_equals fails correctly"
        teardown
        return 0
    else
        echo "✗ assert_equals failure behavior incorrect"
        teardown
        return 1
    fi
}

# Test: assert_contains detects substring
test_assert_contains_success() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    assert_contains "Hello World" "World" "Should find substring" >/dev/null 2>&1
    
    if [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ assert_contains finds substring"
        teardown
        return 0
    else
        echo "✗ assert_contains did not find substring"
        teardown
        return 1
    fi
}

# Test: assert_contains fails when substring absent
test_assert_contains_failure() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_contains "Hello World" "Missing" "Should not find substring" >/dev/null 2>&1
    result=$?
    set -e
    
    if [[ $result -ne 0 ]] && [[ $TESTS_FAILED -eq 1 ]]; then
        echo "✓ assert_contains fails when substring absent"
        teardown
        return 0
    else
        echo "✗ assert_contains failure behavior incorrect"
        teardown
        return 1
    fi
}

# Test: assert_not_contains works correctly
test_assert_not_contains_success() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    assert_not_contains "Hello World" "Missing" "Should not contain substring" >/dev/null 2>&1
    
    if [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ assert_not_contains works correctly"
        teardown
        return 0
    else
        echo "✗ assert_not_contains did not work"
        teardown
        return 1
    fi
}

# Test: assert_not_contains fails when substring present
test_assert_not_contains_failure() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_not_contains "Hello World" "World" "Should fail" >/dev/null 2>&1
    result=$?
    set -e
    
    if [[ $result -ne 0 ]] && [[ $TESTS_FAILED -eq 1 ]]; then
        echo "✓ assert_not_contains fails when substring present"
        teardown
        return 0
    else
        echo "✗ assert_not_contains failure behavior incorrect"
        teardown
        return 1
    fi
}

# Test: assert_exit_code checks correct code
test_assert_exit_code_success() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    assert_exit_code 0 0 "Exit codes should match" >/dev/null 2>&1
    
    if [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ assert_exit_code works correctly"
        teardown
        return 0
    else
        echo "✗ assert_exit_code did not work"
        teardown
        return 1
    fi
}

# Test: assert_exit_code fails on mismatch
test_assert_exit_code_failure() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_exit_code 0 1 "Exit codes mismatch" >/dev/null 2>&1
    result=$?
    set -e
    
    if [[ $result -ne 0 ]] && [[ $TESTS_FAILED -eq 1 ]]; then
        echo "✓ assert_exit_code fails on mismatch"
        teardown
        return 0
    else
        echo "✗ assert_exit_code failure behavior incorrect"
        teardown
        return 1
    fi
}

# Test: assert_file_exists detects existing file
test_assert_file_exists_success() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    touch "testfile.txt"
    assert_file_exists "testfile.txt" "File should exist" >/dev/null 2>&1
    
    if [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ assert_file_exists detects file"
        teardown
        return 0
    else
        echo "✗ assert_file_exists did not detect file"
        teardown
        return 1
    fi
}

# Test: assert_file_exists fails for missing file
test_assert_file_exists_failure() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_file_exists "nonexistent.txt" "Missing file" >/dev/null 2>&1
    result=$?
    set -e
    
    if [[ $result -ne 0 ]] && [[ $TESTS_FAILED -eq 1 ]]; then
        echo "✓ assert_file_exists fails for missing file"
        teardown
        return 0
    else
        echo "✗ assert_file_exists failure behavior incorrect"
        teardown
        return 1
    fi
}

# Test: assert_directory_exists detects existing directory
test_assert_directory_exists_success() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    mkdir "testdir"
    assert_directory_exists "testdir" "Directory should exist" >/dev/null 2>&1
    
    if [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ assert_directory_exists detects directory"
        teardown
        return 0
    else
        echo "✗ assert_directory_exists did not detect directory"
        teardown
        return 1
    fi
}

# Test: assert_directory_exists fails for missing directory
test_assert_directory_exists_failure() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_directory_exists "nonexistent" "Missing dir" >/dev/null 2>&1
    result=$?
    set -e
    
    if [[ $result -ne 0 ]] && [[ $TESTS_FAILED -eq 1 ]]; then
        echo "✓ assert_directory_exists fails for missing directory"
        teardown
        return 0
    else
        echo "✗ assert_directory_exists failure behavior incorrect"
        teardown
        return 1
    fi
}

# Test: assert_true evaluates commands
test_assert_true_success() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    assert_true "true" "True command" >/dev/null 2>&1
    
    if [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ assert_true works correctly"
        teardown
        return 0
    else
        echo "✗ assert_true did not work"
        teardown
        return 1
    fi
}

# Test: assert_true fails for false commands
test_assert_true_failure() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_true "false" "False command" >/dev/null 2>&1
    result=$?
    set -e
    
    if [[ $result -ne 0 ]] && [[ $TESTS_FAILED -eq 1 ]]; then
        echo "✓ assert_true fails for false commands"
        teardown
        return 0
    else
        echo "✗ assert_true failure behavior incorrect"
        teardown
        return 1
    fi
}

# Test: assert_false evaluates commands
test_assert_false_success() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    assert_false "false" "False command" >/dev/null 2>&1
    
    if [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ assert_false works correctly"
        teardown
        return 0
    else
        echo "✗ assert_false did not work"
        teardown
        return 1
    fi
}

# Test: assert_false fails for true commands
test_assert_false_failure() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    set +e
    assert_false "true" "True command" >/dev/null 2>&1
    result=$?
    set -e
    
    if [[ $result -ne 0 ]] && [[ $TESTS_FAILED -eq 1 ]]; then
        echo "✓ assert_false fails for true commands"
        teardown
        return 0
    else
        echo "✗ assert_false failure behavior incorrect"
        teardown
        return 1
    fi
}

# Test: test counter increments
test_counter_increments() {
    setup
    
    TESTS_RUN=0
    
    assert_equals "a" "a" "Test 1" >/dev/null 2>&1
    assert_equals "b" "b" "Test 2" >/dev/null 2>&1
    assert_equals "c" "c" "Test 3" >/dev/null 2>&1
    
    if [[ $TESTS_RUN -eq 3 ]]; then
        echo "✓ Test counter increments correctly"
        teardown
        return 0
    else
        echo "✗ Test counter incorrect (expected 3, got $TESTS_RUN)"
        teardown
        return 1
    fi
}

# Run all tests
run_tests() {
    local total=17
    local passed=0
    
    echo "Running assertion function tests..."
    echo ""
    
    test_assert_equals_success && passed=$((passed + 1))
    test_assert_equals_failure && passed=$((passed + 1))
    test_assert_contains_success && passed=$((passed + 1))
    test_assert_contains_failure && passed=$((passed + 1))
    test_assert_not_contains_success && passed=$((passed + 1))
    test_assert_not_contains_failure && passed=$((passed + 1))
    test_assert_exit_code_success && passed=$((passed + 1))
    test_assert_exit_code_failure && passed=$((passed + 1))
    test_assert_file_exists_success && passed=$((passed + 1))
    test_assert_file_exists_failure && passed=$((passed + 1))
    test_assert_directory_exists_success && passed=$((passed + 1))
    test_assert_directory_exists_failure && passed=$((passed + 1))
    test_assert_true_success && passed=$((passed + 1))
    test_assert_true_failure && passed=$((passed + 1))
    test_assert_false_success && passed=$((passed + 1))
    test_assert_false_failure && passed=$((passed + 1))
    test_counter_increments && passed=$((passed + 1))
    
    echo ""
    echo "═══════════════════════════════════════"
    echo "Assertion Tests: $passed/$total passed"
    echo "═══════════════════════════════════════"
    
    if [[ $passed -eq $total ]]; then
        return 0
    else
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
    exit $?
fi
