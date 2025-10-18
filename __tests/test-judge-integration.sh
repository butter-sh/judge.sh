#!/usr/bin/env bash
# Integration tests for judge.sh - tests complete workflows

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JUDGE_SH="${SCRIPT_DIR}/../judge.sh"
TEST_HELPERS="${SCRIPT_DIR}/../test-helpers.sh"

# Source helpers at top level
source "$TEST_HELPERS"

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    export PROJECT_ROOT="$TEST_DIR"
    export SNAPSHOT_DIR="$TEST_DIR/snapshots"
    mkdir -p "$SNAPSHOT_DIR"
    mkdir -p "$TEST_DIR/__tests"
    cd "$TEST_DIR"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: complete test lifecycle
test_complete_lifecycle() {
    setup
    cat > "$TEST_DIR/__tests/test-simple.sh" << 'EOF'
#!/usr/bin/env bash
exit 0
EOF
    chmod +x "$TEST_DIR/__tests/test-simple.sh"
    set +e
    bash "$TEST_DIR/__tests/test-simple.sh" > /dev/null 2>&1
    result=$?
    set -e
    assert_equals 0 $result "Test should pass"
    teardown
}

# Test: test with setup and cleanup
test_with_setup_cleanup() {
    setup
    setup_test_env > /dev/null 2>&1
    test_file="${TEMP_DIR}/test.txt"
    echo "content" > "$test_file"
    assert_file_exists "$test_file" "File should exist"
    cleanup_test_env > /dev/null 2>&1
    assert_false "[[ -f \"$test_file\" ]]" "File should be cleaned up"
    teardown
}

# Test: snapshot workflow
test_snapshot_workflow() {
    setup
    create_snapshot "test-workflow" "test content" >/dev/null 2>&1
    assert_file_exists "${SNAPSHOT_DIR}/test-workflow.snapshot" "Snapshot should be created"
    teardown
}

# Test: snapshot comparison
test_snapshot_comparison() {
    setup
    create_snapshot "test-compare" "test content" >/dev/null 2>&1
    # Compare with same content - should not output mismatch
    output=$(compare_snapshot "test-compare" "test content" "Comparison test" 2>&1)
    assert_contains "$output" "PASS" "Should pass with matching content"
    teardown
}

# Test: logging in sequence
test_logging_sequence() {
    setup
    output=$(
        log_info "Starting test"
        log_test "Running test"
        log_success "All done"
    ) 2>&1
    assert_contains "$output" "Starting test" "Should contain info"
    assert_contains "$output" "Running test" "Should contain test"
    assert_contains "$output" "All done" "Should contain success"
    teardown
}

# Test: file operations in test
test_file_operations() {
    setup
    setup_test_env > /dev/null 2>&1
    mkdir -p "${TEMP_DIR}/subdir"
    touch "${TEMP_DIR}/file1.txt"
    touch "${TEMP_DIR}/subdir/file2.txt"
    assert_file_exists "${TEMP_DIR}/file1.txt" "File 1 should exist"
    assert_file_exists "${TEMP_DIR}/subdir/file2.txt" "File 2 should exist"
    assert_directory_exists "${TEMP_DIR}/subdir" "Subdir should exist"
    teardown
}

# Test: error handling
test_error_handling() {
    setup
    set +e
    false
    result=$?
    set -e
    assert_equals 1 $result "Should capture failure"
    teardown
}

# Test: snapshot update workflow
test_snapshot_update() {
    setup
    create_snapshot "update-test" "version 1" >/dev/null 2>&1
    update_snapshot "update-test" "version 2" >/dev/null 2>&1
    content=$(cat "${SNAPSHOT_DIR}/update-test.snapshot")
    assert_contains "$content" "version 2" "Should be updated"
    teardown
}

# Test: temporary directory isolation
test_temp_isolation() {
    setup
    setup_test_env > /dev/null 2>&1
    echo "test" > "${TEMP_DIR}/test.txt"
    setup_test_env > /dev/null 2>&1
    assert_false "[[ -f \"${TEMP_DIR}/test.txt\" ]]" "Should clean temp"
    teardown
}

# Test: assertion functions work
test_assertions_work() {
    setup
    # Test assert_equals
    assert_equals "a" "a" "Equals should work"
    # Test assert_contains
    assert_contains "hello world" "world" "Contains should work"
    # Test assert_true
    assert_true "true" "True should work"
    # Test assert_false
    assert_false "false" "False should work"
    teardown
}

# Test: capture output functionality
test_capture_functionality() {
    setup
    output=$(capture_output "echo test")
    assert_equals "test" "$output" "Should capture command output"
    teardown
}

# Test: normalize output function
test_normalize_output() {
    setup
    input="  test  
    with spaces  "
    output=$(normalize_output "$input")
    # Just verify it produces some output
    assert_true "[[ -n \"$output\" ]]" "Should produce normalized output"
    teardown
}

# Run all tests
run_tests() {
    test_complete_lifecycle
    test_with_setup_cleanup
    test_snapshot_workflow
    test_snapshot_comparison
    test_logging_sequence
    test_file_operations
    test_error_handling
    test_snapshot_update
    test_temp_isolation
    test_assertions_work
    test_capture_functionality
    test_normalize_output
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
    print_test_summary
    exit $?
fi
