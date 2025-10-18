#!/usr/bin/env bash
# Test suite for judge.sh CLI interface and commands

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JUDGE_SH="${SCRIPT_DIR}/../judge.sh"
TEST_HELPERS="${SCRIPT_DIR}/../test-helpers.sh"

# Source helpers
source "$TEST_HELPERS"

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    export JUDGE_HOME="$TEST_DIR"
    cd "$TEST_DIR"
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: judge without arguments shows usage
test_no_args_shows_usage() {
    setup
    output=$(bash "$JUDGE_SH" 2>&1)
    assert_contains "$output" "USAGE:" "Should show usage"
    assert_contains "$output" "COMMANDS:" "Should show commands"
    teardown
}

# Test: judge help shows usage
test_help_command() {
    setup
    output=$(bash "$JUDGE_SH" help 2>&1)
    assert_contains "$output" "USAGE:" "Should show usage"
    assert_contains "$output" "COMMANDS:" "Should show commands"
    teardown
}

# Test: judge --help shows usage
test_help_flag() {
    setup
    output=$(bash "$JUDGE_SH" --help 2>&1)
    assert_contains "$output" "USAGE:" "Should show usage"
    teardown
}

# Test: judge -h shows usage
test_help_short_flag() {
    setup
    output=$(bash "$JUDGE_SH" -h 2>&1)
    assert_contains "$output" "USAGE:" "Should show usage"
    teardown
}

# Test: unknown command shows error
test_unknown_command() {
    setup
    set +e
    output=$(bash "$JUDGE_SH" nonexistent-command 2>&1)
    exit_code=$?
    set -e
    assert_true "[[ $exit_code -ne 0 ]]" "Unknown command should fail"
    assert_contains "$output" "Unknown command" "Should show error message"
    teardown
}

# Test: judge run command exists
test_run_command_exists() {
    setup
    output=$(bash "$JUDGE_SH" help 2>&1)
    assert_contains "$output" "run" "Should show run command"
    teardown
}

# Test: judge setup command exists
test_setup_command_exists() {
    setup
    output=$(bash "$JUDGE_SH" help 2>&1)
    assert_contains "$output" "setup" "Should show setup command"
    teardown
}

# Test: judge snap command exists
test_snap_command_exists() {
    setup
    output=$(bash "$JUDGE_SH" help 2>&1)
    assert_contains "$output" "snap" "Should show snap command"
    teardown
}

# Test: usage shows examples
test_usage_shows_examples() {
    setup
    output=$(bash "$JUDGE_SH" help 2>&1)
    assert_contains "$output" "EXAMPLES:" "Should show examples"
    teardown
}

# Test: usage describes run command
test_usage_describes_run() {
    setup
    output=$(bash "$JUDGE_SH" help 2>&1)
    assert_contains "$output" "Run all tests" "Should describe run command"
    teardown
}

# Test: usage describes setup command
test_usage_describes_setup() {
    setup
    output=$(bash "$JUDGE_SH" help 2>&1)
    assert_contains "$output" "snapshot" "Should describe setup command"
    teardown
}

# Test: usage describes snap command
test_usage_describes_snap() {
    setup
    output=$(bash "$JUDGE_SH" help 2>&1)
    assert_contains "$output" "Manage snapshots" "Should describe snap command"
    teardown
}

# Test: command examples shown in help
test_command_examples_shown() {
    setup
    output=$(bash "$JUDGE_SH" help 2>&1)
    assert_contains "$output" "judge.sh run" "Should show run example"
    assert_contains "$output" "judge.sh setup" "Should show setup example"
    assert_contains "$output" "judge.sh snap" "Should show snap example"
    teardown
}

# Test: detailed command help referenced
test_detailed_help_referenced() {
    setup
    output=$(bash "$JUDGE_SH" help 2>&1)
    assert_contains "$output" "For detailed command help" "Should mention detailed help"
    teardown
}

# Run all tests
run_tests() {
    test_no_args_shows_usage
    test_help_command
    test_help_flag
    test_help_short_flag
    test_unknown_command
    test_run_command_exists
    test_setup_command_exists
    test_snap_command_exists
    test_usage_shows_examples
    test_usage_describes_run
    test_usage_describes_setup
    test_usage_describes_snap
    test_command_examples_shown
    test_detailed_help_referenced
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
    print_test_summary
    exit $?
fi
