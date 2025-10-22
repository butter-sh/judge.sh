<div align="center">

# judge.sh

**Bash Testing Framework with Snapshot Support**

[![Organization](https://img.shields.io/badge/org-butter--sh-4ade80?style=for-the-badge&logo=github&logoColor=white)](https://github.com/butter-sh)
[![License](https://img.shields.io/badge/license-MIT-86efac?style=for-the-badge)](LICENSE)
[![Build Status](https://img.shields.io/github/actions/workflow/status/butter-sh/judge.sh/test.yml?branch=main&style=flat-square&logo=github&color=22c55e)](https://github.com/butter-sh/judge.sh/actions)
[![Version](https://img.shields.io/github/v/tag/butter-sh/judge.sh?style=flat-square&label=version&color=4ade80)](https://github.com/butter-sh/judge.sh/releases)
[![butter.sh](https://img.shields.io/badge/butter.sh-judge-22c55e?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cGF0aCBkPSJNMjEgMTZWOGEyIDIgMCAwIDAtMS0xLjczbC03LTRhMiAyIDAgMCAwLTIgMGwtNyA0QTIgMiAwIDAgMCAzIDh2OGEyIDIgMCAwIDAgMSAxLjczbDcgNGEyIDIgMCAwIDAgMiAwbDctNEEyIDIgMCAwIDAgMjEgMTZ6IiBzdHJva2U9IiM0YWRlODAiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIi8+PHBvbHlsaW5lIHBvaW50cz0iMy4yNyA2Ljk2IDEyIDEyLjAxIDIwLjczIDYuOTYiIHN0cm9rZT0iIzRhZGU4MCIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48bGluZSB4MT0iMTIiIHkxPSIyMi4wOCIgeDI9IjEyIiB5Mj0iMTIiIHN0cm9rZT0iIzRhZGU4MCIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48L3N2Zz4=)](https://butter-sh.github.io/judge.sh)

*Full assertion library with snapshot testing and beautiful output*

[Documentation](https://butter-sh.github.io/judge.sh) • [GitHub](https://github.com/butter-sh/judge.sh) • [butter.sh](https://github.com/butter-sh)

</div>

---

## Features

- **Comprehensive Test Framework** - Full assertion library
- **Snapshot Testing** - Capture and validate test outputs
- **Command Delegation** - Clean CLI with specialized sub-commands
- **Test Reporting** - Detailed test summaries and statistics
- **Colorful Output** - Beautiful, readable test results
- **Easy Setup** - Quick initialization and configuration

## Installation

### Quick Install

```bash
git clone https://github.com/butter-sh/judge.sh.git
cd judge.sh
sudo make install
```

### Using hammer.sh

```bash
hammer judge my-tests
cd my-tests
./setup.sh
```

### Using arty.sh

```bash
# Add to your arty.yml
references:
  - https://github.com/butter-sh/judge.sh.git

# Install dependencies
arty deps

# Use via arty
arty exec judge run
```

## Quick Start

```bash
# 1. Make scripts executable
./setup.sh

# 2. Run the example test
./examples/basic_test.sh

# 3. Initialize snapshots for test runner
./judge.sh setup

# 4. Run all tests
./judge.sh run
```

## Usage

### Main Commands

The `judge.sh` script provides three main commands:

#### 1. `run` - Run Tests

Execute test suites with various options:

```bash
# Run all tests
./judge.sh run

# Run with verbose output
./judge.sh run -v

# Run specific test suite
./judge.sh run -t example

# Update master snapshots
./judge.sh run -u

# Run integration tests
./judge.sh run -i

# Combine options
./judge.sh run -v -u -t my-test
```

**Options:**
- `-u, --update-snapshots` - Update master snapshots
- `-i, --integration` - Run integration tests
- `-v, --verbose` - Enable verbose output
- `-t, --test TEST` - Run specific test suite
- `-h, --help` - Show help

#### 2. `setup` - Initialize Snapshots

Run once to create initial master snapshots:

```bash
./judge.sh setup
```

This will:
1. Run all test suites
2. Create master snapshot files
3. Save them in `snapshots/` directory

**Important:** Commit master snapshots to git!

```bash
git add snapshots/*_master.log
git commit -m "Add initial test snapshots"
```

#### 3. `snap` - Manage Snapshots

Utility for snapshot management:

```bash
# List all snapshots
./judge.sh snap list

# Show latest snapshot for a test
./judge.sh snap show example

# Compare latest with master
./judge.sh snap diff example

# Show statistics
./judge.sh snap stats

# Clean old snapshots (older than 7 days)
./judge.sh snap clean

# Clean older than N days
./judge.sh snap clean 14
```

## Writing Tests

### Test File Structure

Create test files with the pattern `test-*.sh`:

```bash
#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test-helpers.sh"

# Test suite name
log_section "My Test Suite"

# Setup (creates temp directories, etc.)
setup_test_env

# ============================================================================
# YOUR TESTS HERE
# ============================================================================

log_test "Test 1: String equality"
assert_equals "expected" "expected" "Should match"

log_test "Test 2: File operations"
echo "content" > "${TEMP_DIR}/test.txt"
assert_file_exists "${TEMP_DIR}/test.txt" "File should exist"

log_test "Test 3: String contains"
output="Hello World"
assert_contains "$output" "World" "Should contain World"

log_test "Test 4: Command success"
assert_true "[ 1 -eq 1 ]" "Should be true"

# ============================================================================
# CLEANUP
# ============================================================================

cleanup_test_env
print_test_summary

exit $?
```

### Available Assertions

**Equality & Comparison:**
```bash
assert_equals "expected" "actual" "Test description"
```

**String Operations:**
```bash
assert_contains "haystack" "needle" "Should contain needle"
assert_not_contains "haystack" "needle" "Should not contain"
```

**File System:**
```bash
assert_file_exists "/path/to/file" "File should exist"
assert_directory_exists "/path/to/dir" "Directory should exist"
```

**Exit Codes:**
```bash
command_to_test
assert_exit_code 0 $? "Command should succeed"
```

**Boolean:**
```bash
assert_true "test -f file.txt" "File test should pass"
assert_false "test -f missing.txt" "Should not exist"
```

### Logging Functions

```bash
log_section "Section Title"          # Major section separator
log_test "Running test X"            # Test announcement
log_pass "Test passed"               # Success message
log_fail "Test failed"               # Failure message
log_info "Information"               # Info message
log_warning "Warning message"        # Warning
log_error "Error occurred"           # Error message
log_success "Operation successful"   # Success indicator
```

## Snapshot Testing

### How Snapshots Work

1. **First Run** - Creates master snapshots
2. **Subsequent Runs** - Compares output against masters
3. **Differences Detected** - Test fails, shows diff
4. **Update Mode** - Overwrites master snapshots

### Snapshot Files

- `*_master.log` - Reference snapshots (commit to git)
- `*_YYYYMMDD_HHMMSS.log` - Timestamped runs (temporary)

### Snapshot Workflow

```bash
# 1. Create initial snapshots
./judge.sh setup

# 2. Review and commit
git add snapshots/*_master.log
git commit -m "Initial snapshots"

# 3. Normal test runs compare against masters
./judge.sh run

# 4. When output legitimately changes, update
./judge.sh run -u

# 5. Review changes
./judge.sh snap diff test-name

# 6. Commit updated snapshots
git add snapshots/*_master.log
git commit -m "Update snapshots after refactoring"
```

## Integration with arty.sh

This project includes an `arty.yml` configuration file:

```yaml
name: "judge.sh"
version: "1.0.0"
main: "judge.sh"
scripts:
  run: "bash judge.sh run"
  setup: "bash judge.sh setup"
  snap: "bash judge.sh snap"
```

Run via arty.sh:
```bash
arty exec judge run
arty exec judge setup
arty exec judge snap list
```

## Project Structure

```
judge.sh/
├── judge.sh              # Main CLI entry point
├── run-all-tests.sh      # Test runner with snapshot support
├── setup-snapshots.sh    # Snapshot initialization
├── snapshot-tool.sh      # Snapshot management utility
├── test-helpers.sh       # Testing utilities library
├── test-example.sh       # Example test suite
├── examples/
│   └── basic_test.sh     # Standalone example test
├── snapshots/            # Snapshot storage directory
├── arty.yml              # arty.sh configuration
├── setup.sh              # Initial project setup
├── README.md             # This file
├── LICENSE               # MIT License
└── .gitignore            # Git ignore rules
```

## Examples

### Example 1: Simple Test

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/test-helpers.sh"

log_section "Simple Tests"
setup_test_env

assert_equals "hello" "hello" "Strings match"
assert_true "[ 2 -gt 1 ]" "Math works"

cleanup_test_env
print_test_summary
```

### Example 2: File Testing

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/test-helpers.sh"

log_section "File Tests"
setup_test_env

# Create test file
echo "test" > "${TEMP_DIR}/file.txt"
assert_file_exists "${TEMP_DIR}/file.txt" "File created"

# Check content
content=$(cat "${TEMP_DIR}/file.txt")
assert_equals "test" "$content" "Content matches"

cleanup_test_env
print_test_summary
```

### Example 3: Command Testing

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/test-helpers.sh"

log_section "Command Tests"
setup_test_env

# Test command output
output=$(echo "Hello World")
assert_contains "$output" "World" "Output contains World"

# Test exit codes
true
assert_exit_code 0 $? "True command succeeds"

cleanup_test_env
print_test_summary
```

## Best Practices

1. **Descriptive Test Names** - Make test descriptions clear
2. **Setup & Cleanup** - Always use `setup_test_env` and `cleanup_test_env`
3. **Commit Snapshots** - Keep master snapshots in version control
4. **Review Diffs** - Check snapshot differences before updating
5. **Isolate Tests** - Each test should be independent
6. **Use Temp Dir** - Store test artifacts in `${TEMP_DIR}`

## Related Projects

Part of the butter.sh ecosystem:

- **[arty.sh](https://github.com/butter-sh/arty.sh)** - Bash library dependency manager
- **[hammer.sh](https://github.com/butter-sh/hammer.sh)** - Project generator from templates
- **[leaf.sh](https://github.com/butter-sh/leaf.sh)** - Documentation generator
- **[whip.sh](https://github.com/butter-sh/whip.sh)** - Release cycle management
- **[myst.sh](https://github.com/butter-sh/myst.sh)** - Templating engine

## License

MIT License - see [LICENSE](LICENSE) file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

Created by [valknar](https://github.com/valknarogg)

---

<div align="center">

Part of the [butter.sh](https://github.com/butter-sh) ecosystem

**Unlimited. Independent. Fresh.**

</div>
