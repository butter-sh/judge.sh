# Judge.sh Test Suite

Comprehensive test suite for the judge.sh testing framework.

## Overview

This test suite validates all functionality of judge.sh including:

- CLI interface and commands
- Assertion functions
- Snapshot testing
- Logging and output
- Test environment management
- Snapshot management tool
- Color handling
- Integration workflows

## Running Tests

### Run All Tests

```bash
cd __tests
bash run-all-tests.sh
```

### Run Individual Test Suite

```bash
bash __tests/test-judge-cli.sh
bash __tests/test-judge-assertions.sh
bash __tests/test-judge-snapshots.sh
# etc.
```

### Using Judge to Test Itself

```bash
# From the judge.sh root directory
./judge.sh run
```

## Test Structure

```
__tests/
├── run-all-tests.sh              # Main test runner
├── test-config.sh                # Test configuration
├── test-judge-cli.sh             # CLI interface tests
├── test-judge-assertions.sh      # Assertion function tests
├── test-judge-snapshots.sh       # Snapshot functionality tests
├── test-judge-logging.sh         # Logging and output tests
├── test-judge-environment.sh     # Test environment tests
├── test-judge-snapshot-tool.sh   # Snapshot tool tests
├── test-judge-colors.sh          # Color handling tests
├── test-judge-integration.sh     # Integration tests
└── snapshots/                    # Test snapshots
```

## Test Suites

### test-judge-cli.sh
Tests the command-line interface of judge.sh:
- Help and usage display
- Command recognition (run, setup, snap)
- Error handling for unknown commands
- Command examples and documentation

### test-judge-assertions.sh
Tests all assertion functions:
- `assert_equals` - equality checks
- `assert_contains` - substring checks
- `assert_not_contains` - negative substring checks
- `assert_exit_code` - exit code verification
- `assert_file_exists` - file existence checks
- `assert_directory_exists` - directory existence checks
- `assert_true` - command success checks
- `assert_false` - command failure checks
- Test counter incrementation

### test-judge-snapshots.sh
Tests snapshot functionality:
- Creating snapshots
- Updating snapshots
- Comparing snapshots
- Normalizing output (whitespace, ANSI codes)
- Handling missing snapshots
- Multiple snapshots
- Multiline content
- Empty content

### test-judge-logging.sh
Tests logging and output functions:
- `log_test`, `log_pass`, `log_fail`, `log_skip`
- `log_info`, `log_warning`, `log_error`, `log_success`
- `log_section` - formatted section headers
- `print_test_summary` - test result summaries
- Counter incrementation
- Pass rate calculation
- Special character handling

### test-judge-environment.sh
Tests test environment management:
- `setup_test_env` - environment initialization
- `cleanup_test_env` - cleanup operations
- `capture_output` - output capturing
- Temporary directory management
- Snapshot directory persistence
- Function exports

### test-judge-snapshot-tool.sh
Tests the snapshot management tool:
- List command
- Show command
- Diff command
- Stats command
- Clean command
- Error handling

### test-judge-colors.sh
Tests color handling:
- Color enabling/disabling based on terminal
- FORCE_COLOR environment variable
- Color variable definitions
- Color exports
- Consistency checks

### test-judge-integration.sh
Integration tests for complete workflows:
- Complete test lifecycle
- Multiple assertions
- Setup and cleanup workflows
- Snapshot workflows
- Mixed test results
- File operations
- Error handling
- Nested assertions

## Writing New Tests

### Test File Template

```bash
#!/usr/bin/env bash
# Test suite for [feature name]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Import dependencies as needed

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

# Test: [description]
test_feature_name() {
    setup
    
    # Test code here
    assert_equals "expected" "actual" "Test description"
    
    teardown
}

# Run all tests
run_tests() {
    test_feature_name
    # Add more tests
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
```

### Best Practices

1. **Isolation**: Each test should use `setup()` and `teardown()` for isolation
2. **Descriptive Names**: Use clear, descriptive test function names
3. **Single Purpose**: Each test should verify one specific behavior
4. **Assertions**: Use appropriate assertion functions for the check
5. **Cleanup**: Always clean up temporary resources
6. **Error Handling**: Use `set +e` when testing failure cases

## Assertions Reference

```bash
# Equality
assert_equals "expected" "actual" "description"

# String contains
assert_contains "haystack" "needle" "description"
assert_not_contains "haystack" "needle" "description"

# Exit codes
assert_exit_code 0 $? "description"

# File system
assert_file_exists "/path/to/file" "description"
assert_directory_exists "/path/to/dir" "description"

# Commands
assert_true "command" "description"
assert_false "command" "description"
```

## Snapshot Testing

```bash
# Create snapshot
create_snapshot "snapshot-name" "content"

# Update snapshot
update_snapshot "snapshot-name" "new-content"

# Compare snapshot
compare_snapshot "snapshot-name" "actual-content" "description"
```

## Logging Functions

```bash
log_test "Test description"
log_pass "Success message"
log_fail "Failure message"
log_skip "Skip message"
log_info "Information message"
log_warning "Warning message"
log_error "Error message"
log_success "Success message"
log_section "Section Title"
```

## Environment Variables

- `UPDATE_SNAPSHOTS=1` - Update snapshots instead of comparing
- `VERBOSE=1` - Enable verbose output
- `FORCE_COLOR=1` - Force colored output
- `JUDGE_TEST_MODE=1` - Enable test mode

## Continuous Integration

The test suite is designed to run in CI environments:

```yaml
# Example GitHub Actions workflow
- name: Run Judge Tests
  run: |
    cd __tests
    bash run-all-tests.sh
```

## Troubleshooting

### Tests Fail on Snapshots
Run with `UPDATE_SNAPSHOTS=1` to update master snapshots:
```bash
UPDATE_SNAPSHOTS=1 bash run-all-tests.sh
```

### Permission Errors
Ensure test files are executable:
```bash
chmod +x __tests/*.sh
```

### Cleanup Issues
If temp directories persist, manually clean:
```bash
rm -rf /tmp/tmp.*
```

## Contributing

When adding new tests:
1. Follow the existing test structure
2. Add tests to the appropriate suite or create a new one
3. Update this README with new test descriptions
4. Ensure all tests pass before committing
5. Use meaningful test names and descriptions

## License

Same as judge.sh - see LICENSE file.
