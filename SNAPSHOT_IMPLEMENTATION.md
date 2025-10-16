# Snapshot Testing Implementation - Complete

## Overview

Implemented comprehensive snapshot testing for the Kompose test suite. All test runs are now captured, saved to `__tests/snapshots/`, and can be compared against committed master snapshots.

## What Was Implemented

### 1. Enhanced Test Runner (`run-all-tests.sh`)

**Features:**
- ✅ Captures all terminal output during test runs
- ✅ Saves timestamped snapshots for every run
- ✅ Compares output with master snapshots
- ✅ Supports multiple command-line options
- ✅ Creates proper snapshot directory structure

**Command Line Options:**
```bash
-u, --update-snapshots    Update master snapshots
-i, --integration         Run integration tests
-v, --verbose            Verbose output
-t, --test <name>        Run specific test suite
-h, --help               Show help
```

**Usage Examples:**
```bash
./run-all-tests.sh              # Normal run, compare with master
./run-all-tests.sh -u           # Update master snapshots
./run-all-tests.sh -v           # Verbose mode
./run-all-tests.sh -t stack-list    # Specific test
./run-all-tests.sh -u -v -t config-generate  # Combined
```

### 2. Snapshot Directory Structure

```
__tests/snapshots/
├── .gitignore                    # Ignore timestamped, keep masters
├── README.md                     # Snapshot documentation
├── config-generate_master.log    # Master (committed to git)
├── config-validate_master.log    # Master (committed to git)
├── stack-list_master.log         # Master (committed to git)
├── config-generate_20250116_143022.log  # Run (not committed)
├── config-validate_20250116_143025.log  # Run (not committed)
└── stack-list_20250116_143028.log       # Run (not committed)
```

**Git Behavior:**
- Master snapshots (`*_master.log`) → ✅ Committed
- Timestamped snapshots (`*_YYYYMMDD_HHMMSS.log`) → ❌ Ignored

### 3. Snapshot Management Tool (`snapshot-tool.sh`)

**Commands:**
```bash
./snapshot-tool.sh list                # List all snapshots
./snapshot-tool.sh show stack-list     # View latest snapshot
./snapshot-tool.sh diff config-generate # Compare with master
./snapshot-tool.sh clean               # Remove old snapshots (>7 days)
./snapshot-tool.sh clean 14            # Remove old snapshots (>14 days)
./snapshot-tool.sh stats               # Show statistics
```

**Features:**
- View snapshots easily
- Compare latest run with master
- Clean old timestamped snapshots
- Show size and count statistics
- Color-coded output

### 4. Initial Setup Script (`setup-snapshots.sh`)

**Purpose:** First-time setup to create initial master snapshots

**Usage:**
```bash
./setup-snapshots.sh
```

**What it does:**
1. Runs all tests with `-u` flag
2. Creates master snapshots
3. Provides next steps (commit to git)

### 5. Documentation

**Created Files:**
- `TESTING.md` - Comprehensive testing guide
- `snapshots/README.md` - Snapshot-specific documentation
- `SNAPSHOT_IMPLEMENTATION.md` - This file

### 6. Git Configuration

**`.gitignore` in snapshots directory:**
```gitignore
# Ignore timestamped snapshots
*_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9].log

# Keep master snapshots
!*_master.log

# Keep documentation
!README.md
!.gitignore
```

## How It Works

### Snapshot Creation Flow

```
┌─────────────────┐
│  Run Tests      │
│ ./run-all-tests│
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────┐
│  Capture Output                 │
│  - All stdout/stderr            │
│  - Test results                 │
│  - Timing info                  │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  Save Timestamped Snapshot      │
│  test-id_YYYYMMDD_HHMMSS.log   │
└────────┬────────────────────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌────────┐  ┌──────────────┐
│Update? │  │Compare?      │
│ (-u)   │  │ (default)    │
└───┬────┘  └──────┬───────┘
    │              │
    ▼              ▼
┌────────────┐  ┌──────────────┐
│Update      │  │Compare with  │
│Master      │  │Master        │
└────────────┘  └──────────────┘
```

### Snapshot Comparison

1. **Test runs** → Output captured
2. **Timestamped snapshot** created (`test-id_20250116_143022.log`)
3. **Compare** with master (`test-id_master.log`)
4. **Report** differences if any
5. **Update** master with `-u` flag if changes are intentional

## Workflow Examples

### Example 1: Normal Development

```bash
# Make code changes
vim kompose-stack-list.sh

# Run tests
./run-all-tests.sh

# Output matches master → ✓ Pass
# Output differs → ⚠ Warning shown
```

### Example 2: Intentional Changes

```bash
# Improve error messages
vim kompose-stack-list.sh

# Run and update snapshots
./run-all-tests.sh -u

# Commit changes including snapshots
git add kompose-stack-list.sh
git add __tests/snapshots/*_master.log
git commit -m "Improve error messages"
```

### Example 3: Reviewing Changes

```bash
# Run tests
./run-all-tests.sh

# View latest snapshot
./snapshot-tool.sh show stack-list

# Compare with master
./snapshot-tool.sh diff stack-list

# Update if correct
./run-all-tests.sh -u
```

### Example 4: Debugging Test Failure

```bash
# Test fails
./run-all-tests.sh -t config-validate

# View full output
./snapshot-tool.sh show config-validate

# Compare what changed
./snapshot-tool.sh diff config-validate

# Fix issue
vim kompose-config-validate.sh

# Verify fix
./run-all-tests.sh -t config-validate
```

## Integration with Git

### Initial Setup
```bash
# Create initial snapshots
./setup-snapshots.sh

# Commit master snapshots
git add __tests/snapshots/*_master.log
git add __tests/snapshots/.gitignore
git add __tests/snapshots/README.md
git commit -m "Add initial test snapshots"
```

### After Changes
```bash
# Update snapshots
./run-all-tests.sh -u

# Review changes
git diff __tests/snapshots/*_master.log

# Commit if correct
git add __tests/snapshots/*_master.log
git commit -m "Update snapshots for feature X"
```

### Pull Request Reviews
```bash
# Clone repo
git clone <repo>

# Run tests
cd __tests
./run-all-tests.sh

# If snapshots differ
./snapshot-tool.sh diff stack-list

# Review changes in PR
git diff origin/main __tests/snapshots/
```

## CI/CD Integration

### GitHub Actions

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
          path: __tests/snapshots/*_[0-9]*_[0-9]*.log
```

### GitLab CI

```yaml
test:
  script:
    - cd __tests
    - ./run-all-tests.sh
  artifacts:
    when: on_failure
    paths:
      - __tests/snapshots/*_[0-9]*_[0-9]*.log
    expire_in: 1 week
```

## Maintenance

### Clean Old Snapshots

**Automatic:**
```bash
# Remove snapshots older than 7 days
./snapshot-tool.sh clean

# Remove snapshots older than 14 days
./snapshot-tool.sh clean 14
```

**Manual:**
```bash
# Remove all timestamped snapshots
rm __tests/snapshots/*_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_*.log

# Remove specific test snapshots
rm __tests/snapshots/stack-list_*.log
```

### View Statistics

```bash
./snapshot-tool.sh stats

# Output:
# Master snapshots: 3
# Run snapshots:    15
# Total size:       2.3M
# By Test Suite:
#   config-generate:     6 files (800K)
#   config-validate:     5 files (750K)
#   stack-list:          7 files (800K)
```

## Files Created/Modified

### New Files
1. ✅ `snapshots/.gitignore` - Git ignore rules
2. ✅ `snapshots/README.md` - Snapshot documentation
3. ✅ `setup-snapshots.sh` - Initial setup
4. ✅ `snapshot-tool.sh` - Management utility
5. ✅ `TESTING.md` - Test documentation
6. ✅ `SNAPSHOT_IMPLEMENTATION.md` - This file
7. ✅ `make-executable.sh` - Make scripts executable

### Modified Files
1. ✅ `run-all-tests.sh` - **ENHANCED** with snapshot capture
2. ✅ `test-stack-list.sh` - Fixed Tests 19, 24-30

### Unchanged (Already Fixed)
1. ✅ `kompose-utils-logging.sh` - Logs to stderr
2. ✅ `kompose-stack-list.sh` - Success message for YAML only

## Benefits

### For Developers
- ✅ Easy to verify changes don't break output
- ✅ Quick comparison with `diff` commands
- ✅ Full history of test outputs
- ✅ Debugging information preserved

### For Code Review
- ✅ See exactly what changed in output
- ✅ Verify intentional changes
- ✅ Catch unintended side effects
- ✅ Documentation of expected behavior

### For CI/CD
- ✅ Automated output validation
- ✅ Artifacts uploaded on failure
- ✅ Historical comparison
- ✅ No manual inspection needed

## Quick Reference

### Common Commands

```bash
# Normal test run
./run-all-tests.sh

# Update snapshots after intentional changes
./run-all-tests.sh -u

# Run specific test
./run-all-tests.sh -t stack-list

# View latest snapshot
./snapshot-tool.sh show stack-list

# Compare with master
./snapshot-tool.sh diff stack-list

# Clean old snapshots
./snapshot-tool.sh clean

# Show statistics
./snapshot-tool.sh stats

# Initial setup (first time)
./setup-snapshots.sh
```

### Command Line Options Matrix

| Option | Short | Long | Description |
|--------|-------|------|-------------|
| Update | `-u` | `--update-snapshots` | Update master snapshots |
| Integration | `-i` | `--integration` | Run integration tests |
| Verbose | `-v` | `--verbose` | Verbose output |
| Test | `-t NAME` | `--test NAME` | Run specific test |
| Help | `-h` | `--help` | Show help |

### Test Suite IDs

| ID | Description | Test File |
|----|-------------|-----------|
| `config-generate` | Config generation | `test-config-generate.sh` |
| `config-validate` | Config validation | `test-config-validate.sh` |
| `stack-list` | Stack listing | `test-stack-list.sh` |

## Summary

✅ **Complete snapshot testing system implemented**
✅ **All command-line options working** (`-u`, `-i`, `-v`, `-t`)
✅ **Snapshots saved to `__tests/snapshots/`**
✅ **Master snapshots committed to git**
✅ **Timestamped snapshots ignored by git**
✅ **Management tools provided**
✅ **Comprehensive documentation**
✅ **CI/CD ready**

The test suite now provides enterprise-grade snapshot testing with easy-to-use tools for managing, comparing, and updating test outputs!
