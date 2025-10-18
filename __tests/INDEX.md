#!/usr/bin/env bash
# Index of all test suite files and their purposes

cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                 JUDGE.SH TEST SUITE INDEX                      ║
║                    Complete File Guide                         ║
╚════════════════════════════════════════════════════════════════╝

📁 DOCUMENTATION FILES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

README.md
  Complete test suite documentation with usage examples,
  assertion reference, and best practices guide.
  
OVERVIEW.md
  Comprehensive reference covering all aspects: structure,
  coverage, running tests, writing tests, troubleshooting.
  
SUMMARY.md
  Creation summary with metrics, coverage breakdown, and
  quality indicators for the entire test suite.
  
INDEX.md (this file)
  Directory of all files with descriptions and purposes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔧 CONFIGURATION & UTILITIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

test-config.sh
  Test configuration, environment variables, and shared
  utilities used across all test suites.

verify-setup.sh
  Verification script to check test suite installation,
  dependencies, and file permissions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏃 RUNNER SCRIPTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

run-all-tests.sh
  Main test runner that executes all 8 test suites and
  provides comprehensive summary of results.
  Usage: bash run-all-tests.sh

quick-start.sh
  Interactive test runner with overview and prompt before
  execution. Good for first-time users.
  Usage: bash quick-start.sh

list-tests.sh
  Displays complete overview of all test suites with
  descriptions and quick command reference.
  Usage: bash list-tests.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧪 TEST SUITES (117 tests total)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

test-judge-cli.sh (15 tests)
  Tests for command-line interface:
  • Help and usage display
  • Command routing (run, setup, snap)
  • Flag handling (--help, -h)
  • Unknown command errors
  • Command descriptions and examples

test-judge-assertions.sh (17 tests)
  Tests for all assertion functions:
  • assert_equals - equality checks
  • assert_contains - substring presence
  • assert_not_contains - substring absence
  • assert_exit_code - exit code validation
  • assert_file_exists - file checks
  • assert_directory_exists - directory checks
  • assert_true - command success
  • assert_false - command failure
  • Counter incrementation

test-judge-snapshots.sh (14 tests)
  Tests for snapshot functionality:
  • Snapshot creation and updates
  • Snapshot comparison logic
  • Output normalization
  • ANSI code stripping
  • Whitespace handling
  • Missing snapshot handling
  • Multiline and empty content

test-judge-logging.sh (18 tests)
  Tests for logging and output:
  • All log functions (test, pass, fail, skip, etc.)
  • Section formatting
  • Test summaries
  • Counter incrementation
  • Pass rate calculation
  • Special character handling

test-judge-environment.sh (15 tests)
  Tests for test environment management:
  • setup_test_env - initialization
  • cleanup_test_env - cleanup
  • capture_output - output capturing
  • Temporary directory management
  • Snapshot directory persistence
  • Function exports
  • Environment isolation

test-judge-snapshot-tool.sh (15 tests)
  Tests for snapshot management tool:
  • list command - snapshot listing
  • show command - display snapshots
  • diff command - compare snapshots
  • stats command - statistics
  • clean command - cleanup old snapshots
  • Error handling and validation

test-judge-colors.sh (8 tests)
  Tests for color handling:
  • Color enabling/disabling logic
  • Terminal detection
  • FORCE_COLOR environment variable
  • Color variable definitions
  • Color exports
  • Consistency checks

test-judge-integration.sh (15 tests)
  Integration tests for complete workflows:
  • Complete test lifecycle
  • Multiple assertions in sequence
  • Setup/cleanup workflows
  • Snapshot workflows
  • Mixed test results
  • File operations
  • Error handling
  • Complex scenarios

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 DATA DIRECTORIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

snapshots/
  Directory for storing test snapshots. Automatically
  populated during test execution.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 QUICK STATISTICS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Total Files:           14
Documentation Files:   4
Configuration Files:   1
Runner Scripts:        3
Test Suites:          8
Total Tests:          117
Lines of Code:        2,500+

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 RECOMMENDED READING ORDER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For New Users:
1. README.md - Start here for overview
2. quick-start.sh - Run first tests
3. list-tests.sh - See what's available
4. OVERVIEW.md - Deep dive into details

For Test Writers:
1. README.md - Writing new tests section
2. test-judge-assertions.sh - See assertion patterns
3. test-judge-integration.sh - See integration patterns
4. OVERVIEW.md - Reference guide

For Maintainers:
1. SUMMARY.md - Creation details
2. test-config.sh - Configuration
3. verify-setup.sh - Verification process
4. All test suites - Implementation details

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 QUICK START COMMANDS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Verify everything is set up
bash verify-setup.sh

# View test overview
bash list-tests.sh

# Run all tests
bash run-all-tests.sh

# Interactive start
bash quick-start.sh

# Run specific suite
bash test-judge-cli.sh

# With options
VERBOSE=1 bash run-all-tests.sh
UPDATE_SNAPSHOTS=1 bash run-all-tests.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For more information, see README.md or OVERVIEW.md

EOF
