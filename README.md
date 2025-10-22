<div align="center">

<img src="./icon.svg" width="100" height="100" alt="judge.sh">

# judge.sh

**Bash Testing Framework**

[![Organization](https://img.shields.io/badge/org-butter--sh-4ade80?style=for-the-badge&logo=github&logoColor=white)](https://github.com/butter-sh)
[![License](https://img.shields.io/badge/license-MIT-86efac?style=for-the-badge)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-22c55e?style=for-the-badge)](https://github.com/butter-sh/judge.sh/releases)
[![butter.sh](https://img.shields.io/badge/butter.sh-judge-4ade80?style=for-the-badge)](https://butter-sh.github.io)

*Professional testing framework with comprehensive assertion library, snapshot testing, and detailed reporting*

[Documentation](https://butter-sh.github.io/judge.sh) • [GitHub](https://github.com/butter-sh/judge.sh) • [butter.sh](https://github.com/butter-sh)

</div>

---

## Overview

judge.sh is a full-featured testing framework for bash scripts, bringing professional test-driven development practices to shell scripting. With a rich assertion library, snapshot testing capabilities, and beautiful output formatting, it makes writing and maintaining bash tests simple and enjoyable.

### Key Features

- **Rich Assertion Library** — Comprehensive set of assertion functions for all test scenarios
- **Snapshot Testing** — Capture and validate test outputs automatically
- **Test Isolation** — Clean environment setup and teardown for each test
- **Detailed Reporting** — Beautiful, colorful output with test statistics
- **Command Delegation** — Clean CLI with specialized sub-commands
- **Easy Integration** — Works standalone or with arty.sh ecosystem

---

## Installation

### Using arty.sh

```bash
arty install https://github.com/butter-sh/judge.sh.git
arty exec judge --help
```

### Manual Installation

```bash
git clone https://github.com/butter-sh/judge.sh.git
cd judge.sh
sudo cp judge.sh /usr/local/bin/judge
sudo chmod +x /usr/local/bin/judge
```

### Using hammer.sh

```bash
hammer judge my-tests
cd my-tests
```

---

## Quick Start

```bash
# 1. Initialize snapshots
judge setup

# 2. Run all tests
judge run

# 3. Run specific test
judge run -t test-name

# 4. Update snapshots after code changes
judge run -u
```

---

## Usage

### Main Commands

#### Run Tests

Execute test suites with various options:

```bash
# Run all tests
judge run

# Run with verbose output
judge run -v

# Run specific test suite
judge run -t example

# Update master snapshots
judge run -u

# Run integration tests
judge run -i

# Combine options
judge run -v -u -t my-test
```

**Options:**
- `-u, --update-snapshots` — Update master snapshots
- `-i, --integration` — Run integration tests
- `-v, --verbose` — Enable verbose output
- `-t, --test TEST` — Run specific test suite
- `-h, --help` — Show help

#### Setup Snapshots

Initialize master snapshots (run once):

```bash
judge setup
```

This creates initial snapshot files in `snapshots/` directory. Remember to commit them to git!

```bash
git add snapshots/*_master.log
git commit -m "Add initial test snapshots"
```

#### Manage Snapshots

Utility commands for snapshot management:

```bash
# List all snapshots
judge snap list

# Show latest snapshot for a test
judge snap show test-name

# Compare latest with master
judge snap diff test-name

# Show snapshot statistics
judge snap stats

# Clean old snapshots (older than 7 days)
judge snap clean

# Clean older than N days
judge snap clean 14
```

---

## Writing Tests

### Test File Structure

Create test files with the pattern `test-*.sh`:

```bash
#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test-helpers.sh"

log_section "My Test Suite"
setup_test_env

# Your tests here
log_test "Test string equality"
assert_equals "expected" "actual" "Should match"

log_test "Test file operations"
echo "content" > "${TEMP_DIR}/test.txt"
assert_file_exists "${TEMP_DIR}/test.txt" "File should exist"

cleanup_test_env
print_test_summary
exit $?
```

### Available Assertions

#### Equality & Comparison

```bash
assert_equals "expected" "actual" "Test description"
```

#### String Operations

```bash
assert_contains "haystack" "needle" "Should contain needle"
assert_not_contains "haystack" "needle" "Should not contain"
```

#### File System

```bash
assert_file_exists "/path/to/file" "File should exist"
assert_directory_exists "/path/to/dir" "Directory should exist"
```

#### Exit Codes

```bash
command_to_test
assert_exit_code 0 $? "Command should succeed"
```

#### Boolean

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

---

## Snapshot Testing

### How Snapshots Work

1. **First Run** — Creates master snapshots
2. **Subsequent Runs** — Compares output against masters
3. **Differences Detected** — Test fails, shows diff
4. **Update Mode** — Overwrites master snapshots

### Snapshot Files

- `*_master.log` — Reference snapshots (commit to git)
- `*_YYYYMMDD_HHMMSS.log` — Timestamped runs (temporary)

### Snapshot Workflow

```bash
# 1. Create initial snapshots
judge setup

# 2. Review and commit
git add snapshots/*_master.log
git commit -m "Initial snapshots"

# 3. Normal test runs compare against masters
judge run

# 4. When output legitimately changes, update
judge run -u

# 5. Review changes
judge snap diff test-name

# 6. Commit updated snapshots
git add snapshots/*_master.log
git commit -m "Update snapshots after refactoring"
```

---

## Examples

### Example 1: Simple Test

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/test-helpers.sh"

log_section "Simple Tests"
setup_test_env

assert_equals "hello" "hello" "Strings match"
assert_true "[[ 2 -gt 1 ]]" "Math works"

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

---

## Integration with arty.sh

Add judge.sh to your project's `arty.yml`:

```yaml
name: "my-project"
version: "1.0.0"

references:
  - https://github.com/butter-sh/judge.sh.git

scripts:
  test: "arty exec judge run"
  test-setup: "arty exec judge setup"
  test-update: "arty exec judge run -u"
```

Then run:

```bash
arty deps          # Install judge.sh
arty test          # Run tests
arty test-update   # Update snapshots
```

---

## Best Practices

1. **Descriptive Test Names** — Make test descriptions clear and actionable
2. **Setup & Cleanup** — Always use `setup_test_env` and `cleanup_test_env`
3. **Commit Snapshots** — Keep master snapshots in version control
4. **Review Diffs** — Check snapshot differences before updating
5. **Isolate Tests** — Each test should be independent
6. **Use Temp Dir** — Store test artifacts in `${TEMP_DIR}`

---

## Related Projects

Part of the [butter.sh](https://github.com/butter-sh) ecosystem:

- **[arty.sh](https://github.com/butter-sh/arty.sh)** — Dependency manager
- **[myst.sh](https://github.com/butter-sh/myst.sh)** — Templating engine
- **[hammer.sh](https://github.com/butter-sh/hammer.sh)** — Project scaffolding
- **[leaf.sh](https://github.com/butter-sh/leaf.sh)** — Documentation generator
- **[whip.sh](https://github.com/butter-sh/whip.sh)** — Release management
- **[clean.sh](https://github.com/butter-sh/clean.sh)** — Linter and formatter

---

## License

MIT License — see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

<div align="center">

**Part of the [butter.sh](https://github.com/butter-sh) ecosystem**

*Unlimited. Independent. Fresh.*

Crafted by [Valknar](https://github.com/valknarogg)

</div>
