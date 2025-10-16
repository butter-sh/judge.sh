# Kompose Test Suite Documentation

## Overview

The Kompose test suite provides comprehensive testing with snapshot support, allowing you to verify that command outputs remain consistent across changes.

## Quick Start

### Run All Tests
```bash
cd __tests
./run-all-tests.sh
```

### First Time Setup
```bash
cd __tests
./setup-snapshots.sh
```

## Command Line Options

### Available Flags

| Flag | Long Form | Description |
|------|-----------|-------------|
| `-u` | `--update-snapshots` | Update master snapshots |
| `-i` | `--integration` | Run integration tests (requires Docker) |
| `-v` | `--verbose` | Enable verbose output |
| `-t TEST` | `--test TEST` | Run specific test suite |
| `-h` | `--help` | Show help message |

### Examples

```bash
# Normal test run (compare with snapshots)
./run-all-tests.sh

# Update all master snapshots
./run-all-tests.sh -u

# Run with verbose output
./run-all-tests.sh -v

# Run integration tests
./run-all-tests.sh -i

# Run specific test suite
./run-all-tests.sh -t stack-list

# Combine options
./run-all-tests.sh -u -v -t config-generate
```

## Test Suites

### Available Test Suites

1. **config-generate** - Tests `kompose config generate` command
   - Skeleton template generation
   - Full template generation
   - Parameter validation
   - Output format verification

2. **config-validate** - Tests `kompose config validate` command
   - YAML validation
   - Required field checks
   - Format conversion (YAML/JSON/ENV)
   - Error handling

3. **stack-list** - Tests `kompose stack list` command
   - Stack discovery
   - Format outputs (YAML/JSON/ENV/quiet)
   - Verbose mode
   - Edge cases

### Running Individual Suites

```bash
# Config generate tests only
./run-all-tests.sh -t config-generate

# Config validate tests only
./run-all-tests.sh -t config-validate

# Stack list tests only
./run-all-tests.sh -t stack-list
```

## Snapshot Testing

### What is Snapshot Testing?

Snapshot testing captures the complete terminal output of test runs and compares it against a committed reference (master snapshot). This ensures:
- Output format consistency
- No unintended changes to command output
- Easy verification of intentional changes

### Snapshot Files

**Master Snapshots** (`*_master.log`)
- Committed to git repository
- Reference for comparisons
- Updated with `-u` flag

**Timestamped Snapshots** (`*_YYYYMMDD_HHMMSS.log`)
- Created every test run
- Not committed (in .gitignore)
- Used for comparison and debugging

### Snapshot Workflow

#### 1. Normal Development
```bash
# Make code changes
vim kompose-stack-list.sh

# Run tests (compares with master)
./run-all-tests.sh

# If output differs, review changes
diff snapshots/stack-list_master.log snapshots/stack-list_*.log
```

#### 2. Intentional Output Changes
```bash
# Update the code intentionally
# (e.g., improve error messages)

# Update snapshots
./run-all-tests.sh -u

# Review and commit
git add snapshots/*_master.log
git commit -m "Update snapshots for improved error messages"
```

#### 3. Reviewing Changes
```bash
# Run tests
./run-all-tests.sh

# If snapshots differ, review what changed
ls -lt snapshots/ | head -5
diff snapshots/config-generate_master.log \
     snapshots/config-generate_20250116_143022.log
```

### When to Update Snapshots

✅ **Update When:**
- New features change output format
- Bug fixes affect displayed messages
- Improvements to error handling
- Formatting changes are intentional

❌ **Don't Update When:**
- Tests fail due to bugs
- Unexpected output changes
- Haven't verified new output is correct

## Directory Structure

```
__tests/
├── run-all-tests.sh           # Main test runner (ENHANCED)
├── setup-snapshots.sh         # Initial snapshot setup
├── test-helpers.sh            # Test utilities
│
├── test-config-generate.sh    # Config generate tests
├── test-config-validate.sh    # Config validate tests  
├── test-stack-list.sh         # Stack list tests (FIXED)
│
├── snapshots/                 # Snapshot directory
│   ├── .gitignore            # Ignore timestamped files
│   ├── README.md             # Snapshot documentation
│   ├── config-generate_master.log     # Master (committed)
│   ├── config-validate_master.log     # Master (committed)
│   ├── stack-list_master.log          # Master (committed)
│   └── *_YYYYMMDD_HHMMSS.log         # Runs (ignored)
│
└── temp/                      # Test workspace (ignored)
```

## Test Helper Functions

Available in `test-helpers.sh`:

### Logging
- `log_test(message)` - Start a test
- `log_pass(message)` - Test passed
- `log_fail(message)` - Test failed
- `log_info(message)` - Information
- `log_warning(message)` - Warning
- `log_error(message)` - Error

### Assertions
- `assert_equals(expected, actual, name)`
- `assert_contains(haystack, needle, name)`
- `assert_not_contains(haystack, needle, name)`
- `assert_exit_code(expected, actual, name)`
- `assert_file_exists(file, name)`
- `assert_true(command, name)`

### Environment
- `setup_test_env()` - Initialize test environment
- `cleanup_test_env()` - Clean up after tests

## Best Practices

### 1. Run Tests Before Committing
```bash
./run-all-tests.sh
git commit -m "Your changes"
```

### 2. Update Snapshots Carefully
```bash
# Review what changed
./run-all-tests.sh
diff snapshots/*_master.log snapshots/*_latest.log

# Update if correct
./run-all-tests.sh -u
git add snapshots/*_master.log
```

### 3. Clean Old Snapshots Periodically
```bash
# Remove snapshots older than 7 days
find snapshots/ -name "*_[0-9]*_[0-9]*.log" -mtime +7 -delete
```

### 4. Use Verbose Mode for Debugging
```bash
./run-all-tests.sh -v -t stack-list
```

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Run Tests
        run: |
          cd __tests
          ./run-all-tests.sh
      
      - name: Upload Snapshots on Failure
        if: failure()
        uses: actions/upload-artifact@v2
        with:
          name: test-snapshots
          path: __tests/snapshots/
```

### GitLab CI Example
```yaml
test:
  script:
    - cd __tests
    - ./run-all-tests.sh
  artifacts:
    when: on_failure
    paths:
      - __tests/snapshots/
```

## Troubleshooting

### Tests Fail With "Output differs from master"

**Solution 1**: Review and update if change is intentional
```bash
./run-all-tests.sh -u
```

**Solution 2**: Fix the code if change is unintentional
```bash
# Fix your code
./run-all-tests.sh  # Should pass now
```

### No Master Snapshots Found

**Cause**: First run or snapshots deleted
**Solution**: Run setup script
```bash
./setup-snapshots.sh
```

### Too Many Snapshot Files

**Cause**: Accumulated timestamped snapshots
**Solution**: Clean old files
```bash
cd snapshots
rm *_20250101_*.log  # Delete specific date
# Or use find for older than N days
find . -name "*_[0-9]*_[0-9]*.log" -mtime +7 -delete
```

### Integration Tests Fail

**Cause**: Docker not available
**Solution**: Install Docker or skip integration tests
```bash
./run-all-tests.sh  # Skips integration by default
```

## Files Modified for Snapshot Support

### Production Code
1. `kompose-utils-logging.sh` - Logs to stderr (don't contaminate output)
2. `kompose-stack-list.sh` - Success messages only for YAML format

### Test Code
1. `run-all-tests.sh` - **ENHANCED** with snapshot capture
2. `test-stack-list.sh` - **FIXED** Tests 19, 24-30
3. `test-helpers.sh` - Logging utilities
4. `setup-snapshots.sh` - **NEW** Initial setup script

### Documentation
1. `snapshots/README.md` - **NEW** Snapshot documentation
2. `snapshots/.gitignore` - **NEW** Git ignore rules
3. `TESTING.md` - **NEW** This file

## Summary

The enhanced test suite now provides:
- ✅ **Snapshot Testing** - Capture and compare output
- ✅ **Flexible CLI** - Multiple options (-u, -i, -v, -t)
- ✅ **Git Integration** - Master snapshots committed
- ✅ **Easy Updates** - Simple snapshot management
- ✅ **CI/CD Ready** - Works in automated pipelines
- ✅ **Comprehensive Logs** - Full output captured

All test runs are now captured and saved, making it easy to:
- Track changes over time
- Debug test failures  
- Verify output consistency
- Document expected behavior
