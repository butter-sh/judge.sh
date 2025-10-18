# Judge.sh Test Suite - Complete Documentation

## 📋 Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Test Suite Structure](#test-suite-structure)
4. [Test Coverage](#test-coverage)
5. [Running Tests](#running-tests)
6. [Writing New Tests](#writing-new-tests)
7. [Troubleshooting](#troubleshooting)
8. [Reference](#reference)

---

## 🎯 Overview

Comprehensive test suite for judge.sh with **117 test cases** across **8 test suites**, providing complete coverage of the testing framework's functionality.

### Key Features
- ✅ Complete functional coverage
- ✅ Isolated test execution
- ✅ Snapshot testing support
- ✅ Integration test scenarios
- ✅ Clear documentation
- ✅ CI/CD ready

### Test Statistics
- **Total Tests**: 117
- **Test Suites**: 8
- **Lines of Code**: 2,500+
- **Functions Tested**: 25+

---

## 🚀 Quick Start

### Verify Setup
```bash
cd __tests
bash verify-setup.sh
```

### Run All Tests
```bash
bash run-all-tests.sh
```

### Interactive Start
```bash
bash quick-start.sh
```

### View Test List
```bash
bash list-tests.sh
```

---

## 📁 Test Suite Structure

```
__tests/
├── README.md                      # Complete documentation
├── SUMMARY.md                     # Creation summary
├── OVERVIEW.md                    # This file
├── test-config.sh                 # Test configuration
├── run-all-tests.sh              # Main test runner
├── quick-start.sh                # Interactive runner
├── list-tests.sh                 # Test overview
├── verify-setup.sh               # Setup verification
│
├── test-judge-cli.sh             # 15 CLI tests
├── test-judge-assertions.sh      # 17 assertion tests
├── test-judge-snapshots.sh       # 14 snapshot tests
├── test-judge-logging.sh         # 18 logging tests
├── test-judge-environment.sh     # 15 environment tests
├── test-judge-snapshot-tool.sh   # 15 tool tests
├── test-judge-colors.sh          # 8 color tests
├── test-judge-integration.sh     # 15 integration tests
│
└── snapshots/                    # Test snapshots
```

---

## 🔍 Test Coverage

### 1. CLI Interface Tests (test-judge-cli.sh)
**15 tests** covering command-line interface

```bash
✓ Help and usage display
✓ Command recognition (run, setup, snap)
✓ Flag handling (--help, -h)
✓ Unknown command error handling
✓ Command descriptions
✓ Example display
```

**Sample Test:**
```bash
test_help_command() {
    output=$(bash "$JUDGE_SH" help 2>&1)
    assert_contains "$output" "USAGE:" "Should show usage"
    assert_contains "$output" "COMMANDS:" "Should show commands"
}
```

### 2. Assertion Tests (test-judge-assertions.sh)
**17 tests** for all assertion functions

```bash
✓ assert_equals - value equality
✓ assert_contains - substring presence
✓ assert_not_contains - substring absence
✓ assert_exit_code - exit code validation
✓ assert_file_exists - file checks
✓ assert_directory_exists - directory checks
✓ assert_true - command success
✓ assert_false - command failure
✓ Counter incrementation
```

**Sample Test:**
```bash
test_assert_equals_success() {
    TESTS_RUN=0
    TESTS_PASSED=0
    
    assert_equals "test" "test" "Values should match"
    
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should increment"
}
```

### 3. Snapshot Tests (test-judge-snapshots.sh)
**14 tests** for snapshot functionality

```bash
✓ Snapshot creation
✓ Snapshot updates
✓ Snapshot comparison
✓ Output normalization
✓ ANSI code stripping
✓ Whitespace handling
✓ Missing snapshot handling
✓ Multiline content
✓ Empty content
```

**Sample Test:**
```bash
test_compare_snapshot_match() {
    create_snapshot "test-snap" "test content"
    compare_snapshot "test-snap" "test content" "Test"
    
    assert_true "[[ $TESTS_PASSED -eq 1 ]]" "Should pass"
}
```

### 4. Logging Tests (test-judge-logging.sh)
**18 tests** for logging and output

```bash
✓ All log functions (test, pass, fail, skip, info, warning, error, success)
✓ Section formatting
✓ Test summaries
✓ Counter incrementation
✓ Pass rate calculation
✓ Special character handling
```

**Sample Test:**
```bash
test_log_pass_counter() {
    TESTS_PASSED=0
    log_pass "Test 1"
    log_pass "Test 2"
    
    assert_true "[[ $TESTS_PASSED -eq 2 ]]" "Should count"
}
```

### 5. Environment Tests (test-judge-environment.sh)
**15 tests** for test environment management

```bash
✓ setup_test_env - initialization
✓ cleanup_test_env - cleanup
✓ capture_output - output capturing
✓ Temporary directory management
✓ Snapshot persistence
✓ Function exports
✓ Environment isolation
```

**Sample Test:**
```bash
test_setup_creates_dirs() {
    setup_test_env > /dev/null 2>&1
    
    assert_directory_exists "$SNAPSHOT_DIR" "Should exist"
    assert_directory_exists "$TEMP_DIR" "Should exist"
}
```

### 6. Snapshot Tool Tests (test-judge-snapshot-tool.sh)
**15 tests** for snapshot management tool

```bash
✓ list command
✓ show command
✓ diff command
✓ stats command
✓ clean command
✓ Error handling
```

**Sample Test:**
```bash
test_diff_no_differences() {
    echo "content" > "$SNAPSHOT_DIR/test_master.log"
    echo "content" > "$SNAPSHOT_DIR/test_20231201.log"
    
    output=$(bash "$SNAPSHOT_TOOL" diff test 2>&1)
    assert_contains "$output" "No differences" "Should match"
}
```

### 7. Color Tests (test-judge-colors.sh)
**8 tests** for color handling

```bash
✓ Color enabling/disabling
✓ Terminal detection
✓ FORCE_COLOR variable
✓ Color variable definitions
✓ Color exports
✓ Consistency checks
```

### 8. Integration Tests (test-judge-integration.sh)
**15 tests** for complete workflows

```bash
✓ Complete test lifecycle
✓ Multiple assertions
✓ Setup/cleanup workflows
✓ Snapshot workflows
✓ Mixed results
✓ File operations
✓ Error handling
✓ Complex scenarios
```

---

## 🏃 Running Tests

### All Tests
```bash
cd __tests
bash run-all-tests.sh
```

**Output:**
```
╔════════════════════════════════════════════════════════════════╗
║              JUDGE.SH TEST SUITE                               ║
╚════════════════════════════════════════════════════════════════╝

Running: test-judge-cli
  ✓ All tests passed

Running: test-judge-assertions
  ✓ All tests passed

...

TEST SUITE SUMMARY
Total test suites: 8
Passed: 8
Failed: 0

✓ All test suites passed!
```

### Specific Suite
```bash
bash test-judge-cli.sh
bash test-judge-assertions.sh
```

### With Options
```bash
# Verbose output
VERBOSE=1 bash run-all-tests.sh

# Update snapshots
UPDATE_SNAPSHOTS=1 bash run-all-tests.sh

# Force colors
FORCE_COLOR=1 bash run-all-tests.sh
```

### Using Judge Itself
```bash
cd .. # Back to judge.sh root
./judge.sh run
```

---

## ✍️ Writing New Tests

### Test Template
```bash
#!/usr/bin/env bash
# Test suite for [feature]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

setup() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
}

teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

test_feature_works() {
    setup
    
    # Test code
    assert_equals "expected" "actual" "Description"
    
    teardown
}

run_tests() {
    test_feature_works
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
```

### Best Practices

1. **Isolation**: Use setup/teardown for each test
2. **Naming**: Clear, descriptive function names
3. **Single Purpose**: One behavior per test
4. **Cleanup**: Always clean up resources
5. **Assertions**: Use appropriate assertion functions

### Adding to Suite

1. Create test file: `test-judge-newfeature.sh`
2. Add to `test-config.sh` TEST_FILES array
3. Update documentation
4. Run verification: `bash verify-setup.sh`

---

## 🔧 Troubleshooting

### Tests Fail on Snapshots
```bash
# Update master snapshots
UPDATE_SNAPSHOTS=1 bash run-all-tests.sh
```

### Permission Errors
```bash
# Make executable
chmod +x __tests/*.sh
```

### Cleanup Issues
```bash
# Remove temp directories
rm -rf /tmp/tmp.*
```

### Verification Failures
```bash
# Run setup verification
bash verify-setup.sh
```

### Missing Dependencies
```bash
# Ensure judge.sh is present
ls -la ../judge.sh
ls -la ../test-helpers.sh
```

---

## 📚 Reference

### Assertion Functions
```bash
assert_equals "expected" "actual" "description"
assert_contains "haystack" "needle" "description"
assert_not_contains "haystack" "needle" "description"
assert_exit_code 0 $? "description"
assert_file_exists "/path/to/file" "description"
assert_directory_exists "/path/to/dir" "description"
assert_true "command" "description"
assert_false "command" "description"
```

### Logging Functions
```bash
log_test "message"
log_pass "message"
log_fail "message"
log_skip "message"
log_info "message"
log_warning "message"
log_error "message"
log_success "message"
log_section "title"
print_test_summary
```

### Snapshot Functions
```bash
create_snapshot "name" "content"
update_snapshot "name" "content"
compare_snapshot "name" "content" "description"
normalize_output "$content"
```

### Environment Functions
```bash
setup_test_env
cleanup_test_env
capture_output "command"
```

### Environment Variables
```bash
UPDATE_SNAPSHOTS=1    # Update mode
VERBOSE=1             # Verbose output
FORCE_COLOR=1         # Force colors
JUDGE_TEST_MODE=1     # Test mode
SNAPSHOT_DIR          # Snapshot location
TEMP_DIR              # Temp location
```

---

## 📊 Test Metrics

| Metric | Value |
|--------|-------|
| Total Tests | 117 |
| Test Suites | 8 |
| Assertion Types | 8 |
| Logging Functions | 9 |
| Snapshot Functions | 4 |
| Environment Functions | 4 |
| Lines of Code | 2,500+ |
| Documentation Files | 4 |

---

## 🎓 Learning Resources

### Examples
- See individual test files for patterns
- Check integration tests for workflows
- Review assertion tests for usage

### Documentation
- **README.md** - Complete guide
- **SUMMARY.md** - Creation overview
- **This file** - Comprehensive reference

### Helper Scripts
- **verify-setup.sh** - Check installation
- **list-tests.sh** - View all tests
- **quick-start.sh** - Interactive run

---

## 📝 Contributing

When contributing tests:

1. Follow existing patterns
2. Write clear test names
3. Use setup/teardown properly
4. Add descriptive assertions
5. Document in README
6. Run verification before commit

---

## 📄 License

Same as judge.sh - see LICENSE file.

---

**Created**: 2025-10-18  
**Version**: 1.0.0  
**Total Tests**: 117  
**Coverage**: Complete
