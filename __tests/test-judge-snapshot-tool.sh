#!/usr/bin/env bash
# Test suite for judge.sh snapshot tool

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SNAPSHOT_TOOL="${SCRIPT_DIR}/../snapshot-tool.sh"
TEST_HELPERS="${SCRIPT_DIR}/../test-helpers.sh"

# Source helpers
source "$TEST_HELPERS"

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    export SNAPSHOT_DIR="$TEST_DIR/snapshots"
    mkdir -p "$SNAPSHOT_DIR"
    cd "$TEST_DIR"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: snapshot tool without arguments shows help
test_no_args_shows_help() {
    setup
    output=$(bash "$SNAPSHOT_TOOL" 2>&1)
    assert_contains "$output" "Usage:" "Should show usage"
    assert_contains "$output" "Commands:" "Should show commands"
    teardown
}

# Test: snapshot tool help command
test_help_command() {
    setup
    output=$(bash "$SNAPSHOT_TOOL" help 2>&1)
    assert_contains "$output" "Snapshot Management" "Should show help header"
    teardown
}

# Test: snapshot tool list command
test_list_command() {
    setup
    echo "master content" > "$SNAPSHOT_DIR/test_master.log"
    echo "run content" > "$SNAPSHOT_DIR/test_20231201_120000.log"
    output=$(cd "$TEST_DIR" && bash "$SNAPSHOT_TOOL" list 2>&1)
    assert_contains "$output" "Master Snapshots" "Should show master section"
    assert_contains "$output" "Recent Run Snapshots" "Should show recent section"
    teardown
}

# Test: snapshot tool list with empty directory
test_list_empty() {
    setup
    output=$(cd "$TEST_DIR" && bash "$SNAPSHOT_TOOL" list 2>&1)
    assert_contains "$output" "Snapshots in:" "Should show directory"
    teardown
}

# Test: snapshot tool show command requires test-id
test_show_requires_id() {
    setup
    set +e
    output=$(cd "$TEST_DIR" && bash "$SNAPSHOT_TOOL" show 2>&1)
    exit_code=$?
    set -e
    assert_true "[[ $exit_code -ne 0 ]]" "Should fail without test-id"
    assert_contains "$output" "Test ID required" "Should show error"
    teardown
}

# Test: snapshot tool show displays snapshot
test_show_displays_snapshot() {
    setup
    echo "test content" > "$SNAPSHOT_DIR/mytest_20231201_120000.log"
    output=$(cd "$TEST_DIR" && bash "$SNAPSHOT_TOOL" show mytest 2>&1)
    assert_contains "$output" "test content" "Should display snapshot content"
    teardown
}

# Test: snapshot tool show handles missing snapshot
test_show_missing_snapshot() {
    setup
    set +e
    output=$(cd "$TEST_DIR" && bash "$SNAPSHOT_TOOL" show nonexistent 2>&1)
    exit_code=$?
    set -e
    assert_true "[[ $exit_code -ne 0 ]]" "Should fail for missing snapshot"
    assert_contains "$output" "No snapshots found" "Should show error"
    teardown
}

# Test: snapshot tool diff requires test-id
test_diff_requires_id() {
    setup
    set +e
    output=$(cd "$TEST_DIR" && bash "$SNAPSHOT_TOOL" diff 2>&1)
    exit_code=$?
    set -e
    assert_true "[[ $exit_code -ne 0 ]]" "Should fail without test-id"
    assert_contains "$output" "Test ID required" "Should show error"
    teardown
}

# Test: snapshot tool diff detects no differences
test_diff_no_differences() {
    setup
    echo "same content" > "$SNAPSHOT_DIR/mytest_master.log"
    echo "same content" > "$SNAPSHOT_DIR/mytest_20231201_120000.log"
    output=$(cd "$TEST_DIR" && bash "$SNAPSHOT_TOOL" diff mytest 2>&1)
    # Check for the key phrase (works with or without emoji)
    assert_contains "$output" "outputs match" "Should show no differences"
    teardown
}

# Test: snapshot tool diff detects differences
test_diff_detects_differences() {
    setup
    echo "original content" > "$SNAPSHOT_DIR/mytest_master.log"
    echo "different content" > "$SNAPSHOT_DIR/mytest_20231201_120000.log"
    output=$(cd "$TEST_DIR" && bash "$SNAPSHOT_TOOL" diff mytest 2>&1)
    # Check for the key phrase (with or without emoji/colors)
    assert_contains "$output" "Differences" "Should detect differences"
    teardown
}

# Test: snapshot tool diff handles missing master
test_diff_missing_master() {
    setup
    echo "run content" > "$SNAPSHOT_DIR/mytest_20231201_120000.log"
    set +e
    output=$(cd "$TEST_DIR" && bash "$SNAPSHOT_TOOL" diff mytest 2>&1)
    exit_code=$?
    set -e
    assert_true "[[ $exit_code -ne 0 ]]" "Should fail without master"
    assert_contains "$output" "Master snapshot not found" "Should show error"
    teardown
}

# Test: snapshot tool stats shows statistics
test_stats_command() {
    setup
    echo "master1" > "$SNAPSHOT_DIR/test1_master.log"
    echo "master2" > "$SNAPSHOT_DIR/test2_master.log"
    echo "run1" > "$SNAPSHOT_DIR/test1_20231201_120000.log"
    echo "run2" > "$SNAPSHOT_DIR/test2_20231201_120000.log"
    echo "run3" > "$SNAPSHOT_DIR/test1_20231202_120000.log"
    output=$(cd "$TEST_DIR" && bash "$SNAPSHOT_TOOL" stats 2>&1)
    assert_contains "$output" "Master snapshots:" "Should show master count"
    assert_contains "$output" "Run snapshots:" "Should show run count"
    assert_contains "$output" "Total size:" "Should show size"
    teardown
}

# Test: snapshot tool clean command
test_clean_command() {
    setup
    touch -d "8 days ago" "$SNAPSHOT_DIR/old_20231101_120000.log"
    touch "$SNAPSHOT_DIR/new_20231201_120000.log"
    output=$(cd "$TEST_DIR" && echo "n" | bash "$SNAPSHOT_TOOL" clean 2>&1 || true)
    assert_contains "$output" "Removing snapshots older than" "Should show cleanup message"
    teardown
}

# Test: snapshot tool clean with custom days
test_clean_custom_days() {
    setup
    touch -d "15 days ago" "$SNAPSHOT_DIR/old_20231101_120000.log"
    output=$(cd "$TEST_DIR" && echo "n" | bash "$SNAPSHOT_TOOL" clean 14 2>&1 || true)
    assert_contains "$output" "older than 14 days" "Should use custom days"
    teardown
}

# Test: snapshot tool unknown command
test_unknown_command() {
    setup
    set +e
    output=$(cd "$TEST_DIR" && bash "$SNAPSHOT_TOOL" nonexistent 2>&1)
    exit_code=$?
    set -e
    assert_true "[[ $exit_code -ne 0 ]]" "Should fail for unknown command"
    assert_contains "$output" "Unknown command" "Should show error"
    teardown
}

# Run all tests
run_tests() {
    test_no_args_shows_help
    test_help_command
    test_list_command
    test_list_empty
    test_show_requires_id
    test_show_displays_snapshot
    test_show_missing_snapshot
    test_diff_requires_id
    test_diff_no_differences
    test_diff_detects_differences
    test_diff_missing_master
    test_stats_command
    test_clean_command
    test_clean_custom_days
    test_unknown_command
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
    print_test_summary
    exit $?
fi
