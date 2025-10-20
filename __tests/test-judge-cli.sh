#!/usr/bin/env bash
# Test suite for judge.sh CLI interface and commands

# Test: judge without arguments shows usage
test_no_args_shows_usage() {

  output=$(bash "$JUDGE_SH" 2>&1)
  assert_contains "$output" "USAGE:" "Should show usage"
  assert_contains "$output" "COMMANDS:" "Should show commands"

}

# Test: judge help shows usage
test_help_command() {

  output=$(bash "$JUDGE_SH" help 2>&1)
  assert_contains "$output" "USAGE:" "Should show usage"
  assert_contains "$output" "COMMANDS:" "Should show commands"

}

# Test: judge --help shows usage
test_help_flag() {

  output=$(bash "$JUDGE_SH" --help 2>&1)
  assert_contains "$output" "USAGE:" "Should show usage"

}

# Test: judge -h shows usage
test_help_short_flag() {

  output=$(bash "$JUDGE_SH" -h 2>&1)
  assert_contains "$output" "USAGE:" "Should show usage"

}

# Test: unknown command shows error
test_unknown_command() {
  set +e
  output=$(bash "$JUDGE_SH" nonexistent-command 2>&1)
  exit_code=$?
  set -e
  assert_true "[[ $exit_code -ne 0 ]]" "Unknown command should fail"
  assert_contains "$output" "Unknown command" "Should show error message"

}

# Test: judge run command exists
test_run_command_exists() {

  output=$(bash "$JUDGE_SH" help 2>&1)
  assert_contains "$output" "run" "Should show run command"

}

# Test: judge setup command exists
test_setup_command_exists() {

  output=$(bash "$JUDGE_SH" help 2>&1)
  assert_contains "$output" "setup" "Should show setup command"

}

# Test: judge snap command exists
test_snap_command_exists() {

  output=$(bash "$JUDGE_SH" help 2>&1)
  assert_contains "$output" "snap" "Should show snap command"

}

# Test: usage shows examples
test_usage_shows_examples() {

  output=$(bash "$JUDGE_SH" help 2>&1)
  assert_contains "$output" "EXAMPLES:" "Should show examples"

}

# Test: usage describes run command
test_usage_describes_run() {

  output=$(bash "$JUDGE_SH" help 2>&1)
  assert_contains "$output" "Run all tests" "Should describe run command"

}

# Test: usage describes setup command
test_usage_describes_setup() {

  output=$(bash "$JUDGE_SH" help 2>&1)
  assert_contains "$output" "snapshot" "Should describe setup command"

}

# Test: usage describes snap command
test_usage_describes_snap() {

  output=$(bash "$JUDGE_SH" help 2>&1)
  assert_contains "$output" "Manage snapshots" "Should describe snap command"

}

# Test: command examples shown in help
test_command_examples_shown() {

  output=$(bash "$JUDGE_SH" help 2>&1)
  assert_contains "$output" "judge.sh run" "Should show run example"
  assert_contains "$output" "judge.sh setup" "Should show setup example"
  assert_contains "$output" "judge.sh snap" "Should show snap example"

}

# Test: detailed command help referenced
test_detailed_help_referenced() {

  output=$(bash "$JUDGE_SH" help 2>&1)
  assert_contains "$output" "For detailed command help" "Should mention detailed help"

}

# Run all tests
run_tests() {
  log_section "CLI Tests"

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

export -f run_tests
