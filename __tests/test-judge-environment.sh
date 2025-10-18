#!/usr/bin/env bash
# Test suite for judge.sh test environment utilities

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_HELPERS="${SCRIPT_DIR}/../test-helpers.sh"

# Source helpers once at top level
source "$TEST_HELPERS"

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    export TEMP_DIR="$TEST_DIR/temp"
    export SNAPSHOT_DIR="$TEST_DIR/snapshots"
    cd "$TEST_DIR"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: setup_test_env creates directories
test_setup_creates_dirs() {
    setup
    setup_test_env > /dev/null 2>&1
    assert_directory_exists "$SNAPSHOT_DIR" "Snapshot dir should exist"
    assert_directory_exists "$TEMP_DIR" "Temp dir should exist"
    teardown
}

# Test: setup_test_env is idempotent
test_setup_idempotent() {
    setup
    setup_test_env > /dev/null 2>&1
    setup_test_env > /dev/null 2>&1
    setup_test_env > /dev/null 2>&1
    assert_directory_exists "$SNAPSHOT_DIR" "Snapshot dir should still exist"
    assert_directory_exists "$TEMP_DIR" "Temp dir should still exist"
    teardown
}

# Test: setup_test_env cleans temp directory
test_setup_cleans_temp() {
    setup
    mkdir -p "$TEMP_DIR"
    touch "$TEMP_DIR/oldfile.txt"
    setup_test_env > /dev/null 2>&1
    assert_false "[[ -f \"$TEMP_DIR/oldfile.txt\" ]]" "Old file should be removed"
    assert_directory_exists "$TEMP_DIR" "Temp dir should be recreated"
    teardown
}

# Test: cleanup_test_env removes temp directory
test_cleanup_removes_temp() {
    setup
    mkdir -p "$TEMP_DIR"
    touch "$TEMP_DIR/testfile.txt"
    cleanup_test_env > /dev/null 2>&1
    assert_false "[[ -d \"$TEMP_DIR\" ]]" "Temp dir should be removed"
    teardown
}

# Test: cleanup_test_env handles missing directory
test_cleanup_missing_dir() {
    setup
    set +e
    cleanup_test_env > /dev/null 2>&1
    result=$?
    set -e
    assert_equals 0 $result "Should handle missing directory gracefully"
    teardown
}

# Test: capture_output captures stdout
test_capture_stdout() {
    setup
    output=$(capture_output "echo 'test output'")
    assert_equals "test output" "$output" "Should capture stdout"
    teardown
}

# Test: capture_output captures stderr
test_capture_stderr() {
    setup
    output=$(capture_output "echo 'error output' >&2")
    assert_equals "error output" "$output" "Should capture stderr"
    teardown
}

# Test: capture_output with successful command
test_capture_success() {
    setup
    output=$(capture_output "echo success; exit 0")
    assert_equals "success" "$output" "Should capture output from successful command"
    teardown
}

# Test: capture_output with failed command  
test_capture_failure() {
    setup
    output=$(capture_output "echo failure; exit 1" || true)
    assert_equals "failure" "$output" "Should capture output from failed command"
    teardown
}

# Test: capture_output handles complex commands
test_capture_complex() {
    setup
    output=$(capture_output "echo line1; echo line2; echo line3")
    assert_contains "$output" "line1" "Should contain line1"
    assert_contains "$output" "line2" "Should contain line2"
    assert_contains "$output" "line3" "Should contain line3"
    teardown
}

# Test: capture_output handles pipes
test_capture_pipes() {
    setup
    output=$(capture_output "echo 'test' | tr 'a-z' 'A-Z'")
    assert_equals "TEST" "$output" "Should handle pipes"
    teardown
}

# Test: temp directory isolation
test_temp_dir_isolation() {
    setup
    setup_test_env > /dev/null 2>&1
    echo "test" > "$TEMP_DIR/test.txt"
    setup_test_env > /dev/null 2>&1
    assert_false "[[ -f \"$TEMP_DIR/test.txt\" ]]" "Should clean temp directory"
    teardown
}

# Test: snapshot directory persistence
test_snapshot_persistence() {
    setup
    setup_test_env > /dev/null 2>&1
    echo "snapshot" > "$SNAPSHOT_DIR/test.snapshot"
    setup_test_env > /dev/null 2>&1
    assert_file_exists "$SNAPSHOT_DIR/test.snapshot" "Should preserve snapshots"
    teardown
}

# Test: environment functions exported
test_exported_functions() {
    setup
    assert_true "type log_info > /dev/null 2>&1" "log_info should be exported"
    assert_true "type capture_output > /dev/null 2>&1" "capture_output should be exported"
    assert_true "type setup_test_env > /dev/null 2>&1" "setup_test_env should be exported"
    assert_true "type cleanup_test_env > /dev/null 2>&1" "cleanup_test_env should be exported"
    teardown
}

# Run all tests
run_tests() {
    test_setup_creates_dirs
    test_setup_idempotent
    test_setup_cleans_temp
    test_cleanup_removes_temp
    test_cleanup_missing_dir
    test_capture_stdout
    test_capture_stderr
    test_capture_success
    test_capture_failure
    test_capture_complex
    test_capture_pipes
    test_temp_dir_isolation
    test_snapshot_persistence
    test_exported_functions
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
    print_test_summary
    exit $?
fi
