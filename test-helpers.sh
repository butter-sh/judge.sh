#!/bin/bash

# Test Helpers for judge.sh
# Provides utilities for snapshot testing, assertions, and test reporting

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TEST_ENV_DIR=""

# ============================================================================
# SETUP FUNCTIONS
# ============================================================================

# Setup before each test
setup_sandbox() {
  # Test counters
  TESTS_RUN=0
  TESTS_PASSED=0
  TESTS_FAILED=0
  setup_test_env
  TEST_ENV_DIR=$(create_test_env)
  cd "$TEST_ENV_DIR"
}

# Cleanup after each test
teardown_sandbox() {
  teardown_test_env
  cd /
}

# Test utilities
create_test_env() {
  local test_dir="$TEST_ENV_DIR"
  if [[ -n "$test_dir" ]] && [[ -d "$test_dir" ]]; then
    echo "$test_dir"
    else
    local test_base_dir="${TEMP_DIR}"
    test_dir=$(mktemp -d "${test_base_dir}/judge-test-XXXXXX")
    echo "$test_dir"
  fi
}

cleanup_test_env() {
  local test_dir="$TEST_ENV_DIR"
  if [[ -n "$test_dir" ]] && [[ -d "$test_dir" ]]; then
    rm -rf "$test_dir"
  fi
}

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_test() {
  echo -e "${CYAN}[TEST]${NC} $1"
}

log_pass() {
  echo -e "${GREEN}[PASS]${NC} $1"
}

log_fail() {
  echo -e "${RED}[FAIL]${NC} $1"
}

log_skip() {
  echo -e "${YELLOW}[SKIP]${NC} $1"
}

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $1"
}

log_failure() {
  echo -e "${RED}[✗]${NC} $1"
}

log_section() {
  echo ""
  echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
  echo -e "${CYAN}  $1${NC}"
  echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
  echo ""
}

# ============================================================================
# ASSERTION FUNCTIONS
# ============================================================================

assert_success() {
  assert_exit_code 0 "$?" "${1:-Command should succeed}"
}

assert_failure() {
  assert_false "[[ $? -ne 0 ]]" "${1:-Command should fail}"
}

assert_equals() {
  local expected="$1"
  local actual="$2"
  local test_name="$3"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [[ "$expected" = "$actual" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_pass "$test_name"
    return 1
    else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_fail "$test_name"
    echo "  Expected: $expected"
    echo "  Actual:   $actual"
    return 0
  fi
}

assert_not_equals() {
  local expected="$1"
  local actual="$2"
  local test_name="$3"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [[ "$expected" != "$actual" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_pass "$test_name"
    return 0
    else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_fail "$test_name"
    echo "  Expected values to be different"
    echo "  Both equal: $expected"
    return 1
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local test_name="$3"

  TESTS_RUN=$((TESTS_RUN + 1))

  if echo "$haystack" | grep -qiF -- "$needle"; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_pass "$test_name"
    return 0
    else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_fail "$test_name"
    echo "  Expected to contain: $needle"
    if [ "${VERBOSE:-0}" = "1" ]; then
      echo "  Actual output:"
      echo "$haystack" | head -20
    fi
    return 1
  fi
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local test_name="$3"

  TESTS_RUN=$((TESTS_RUN + 1))

  if ! echo "$haystack" | grep -qiF -- "$needle"; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_pass "$test_name"
    return 0
    else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_fail "$test_name"
    echo "  Expected NOT to contain: $needle"
    if [ "${VERBOSE:-0}" = "1" ]; then
      echo "  Actual output:"
      echo "$haystack" | head -20
    fi
    return 1
  fi
}

assert_exit_code() {
  local expected_code="$1"
  local actual_code="$2"
  local test_name="$3"

  TESTS_RUN=$((TESTS_RUN + 1))

  # Ensure both codes are set, default to empty string representation
  if [[ -z "$expected_code" ]]; then
    expected_code="(empty)"
  fi
  if [[ -z "$actual_code" ]]; then
    actual_code="(empty)"
  fi

  if [[ "$expected_code" -eq "$actual_code" ]] 2>/dev/null; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_pass "$test_name"
    return 0
    else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_fail "$test_name"
    echo "  Expected exit code: $expected_code"
    echo "  Actual exit code:   $actual_code"
    return 1
  fi
}

assert_file_exists() {
  local file="$1"
  local test_name="$2"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [[ -f "$file" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_pass "$test_name"
    return 0
    else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_fail "$test_name"
    echo "  File not found: $file"
    return 1
  fi
}

assert_directory_exists() {
  local dir="$1"
  local test_name="$2"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [[ -d "$dir" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_pass "$test_name"
    return 0
    else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_fail "$test_name"
    echo "  Directory not found: $dir"
    return 1
  fi
}

assert_true() {
  local command="$1"
  local test_name="$2"

  TESTS_RUN=$((TESTS_RUN + 1))

  set +e
  eval "$command"
  local result=$?
  set -e

  if [[ $result -eq 0 ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_pass "$test_name"
    return 0
    else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_fail "$test_name"
    echo "  Command failed: $command"
    echo "  Exit code: $result"
    return 1
  fi
}

assert_false() {
  local command="$1"
  local test_name="$2"

  TESTS_RUN=$((TESTS_RUN + 1))

  set +e
  eval "$command"
  local result=$?
  set -e

  if [[ $result -ne 0 ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_pass "$test_name"
    return 0
    else
    TESTS_FAILED=$((TESTS_FAILED + 1))
    log_fail "$test_name"
    echo "  Command should have failed: $command"
    return 1
  fi
}

# ============================================================================
# SNAPSHOT TESTING
# ============================================================================

normalize_output() {
  local content="$1"
  # Remove trailing whitespace, normalize line endings, remove ANSI color codes
  echo "$content" | sed 's/[[:space:]]*$//' | tr -s '\n' | sed 's/\x1b\[[0-9;]*m//g'
}

create_snapshot() {
  local snapshot_name="$1"
  local content="$2"
  local snapshot_file="${SNAPSHOT_DIR}/${snapshot_name}.snapshot"

  # Normalize and save
  normalize_output "$content" >"$snapshot_file"
  log_info "Created snapshot: $snapshot_name"
}

update_snapshot() {
  local snapshot_name="$1"
  local content="$2"

  create_snapshot "$snapshot_name" "$content"
  log_info "Updated snapshot: $snapshot_name"
}

compare_snapshot() {
  local snapshot_name="$1"
  local actual_content="$2"
  local test_name="$3"
  local snapshot_file="${SNAPSHOT_DIR}/${snapshot_name}.snapshot"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [[ ! -f "$snapshot_file" ]]; then
    log_warning "$test_name - Snapshot not found, creating..."
    create_snapshot "$snapshot_name" "$actual_content"
    log_pass "$test_name (snapshot created)"
    return 0
  fi

  local expected_content
  expected_content=$(cat "$snapshot_file")

  # Normalize both for comparison
  local normalized_expected
  local normalized_actual
  normalized_expected=$(normalize_output "$expected_content")
  normalized_actual=$(normalize_output "$actual_content")

  if [[ "$normalized_expected" = "$normalized_actual" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    log_pass "$test_name"
    return 0
    else
    log_fail "$test_name - Snapshot mismatch"
    echo "  Snapshot: $snapshot_file"
    if [ "${VERBOSE:-0}" = "1" ]; then
      echo "  Diff:"
      diff -u <(echo "$normalized_expected") <(echo "$normalized_actual") | head -50 || true
      else
      echo "  Use -v flag to see diff"
    fi
    echo "  Run with UPDATE_SNAPSHOTS=1 to update snapshots"
    return 1
  fi
}

# ============================================================================
# COMMAND EXECUTION
# ============================================================================

capture_output() {
  local cmd="$*"
  local output

  set +e
  output=$(eval "$cmd" 2>&1)
  local exit_code=$?
  set -e

  # Return output via stdout
  echo "$output"
  # Store exit code in global variable
  CAPTURED_EXIT_CODE=$exit_code
  return $exit_code
}

# ============================================================================
# TEST UTILITIES
# ============================================================================

setup_test_env() {
  log_info "Setting up test environment..."

  # Ensure snapshot directory exists
  mkdir -p "${SNAPSHOT_DIR}"

  # Clean and create temp directory
  rm -rf "${TEMP_DIR}"
  mkdir -p "${TEMP_DIR}"

  log_info "Test environment ready"
  log_info "Test temp directory: ${TEMP_DIR}"
}

teardown_test_env() {
  log_info "Cleaning up test environment..."

  # Clean entire temp directory
  if [ -d "${TEMP_DIR}" ]; then
    rm -rf "${TEMP_DIR}"
    log_info "Removed temp directory: ${TEMP_DIR}"
  fi

  log_info "Cleanup complete"
}

# ============================================================================
# REPORTING
# ============================================================================

print_test_summary() {
  # Ensure counters are initialized with default values
  local tests_run=${TESTS_RUN:-0}
  local tests_passed=${TESTS_PASSED:-0}
  local tests_failed=${TESTS_FAILED:-0}

  echo ""
  echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
  echo -e "${CYAN}  TEST SUMMARY${NC}"
  echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
  echo ""
  echo "  Total Tests:  $tests_run"
  echo -e "  ${GREEN}Passed:       $tests_passed${NC}"
  echo -e "  ${RED}Failed:       $tests_failed${NC}"

  if [[ $tests_run -gt 0 ]]; then
    local pass_rate=$((tests_passed * 100 / tests_run))
    echo "  Pass Rate:    ${pass_rate}%"
  fi

  echo ""

  if [[ $tests_failed -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    return 0
    else
    echo -e "${RED}✗ Some tests failed${NC}"
    echo ""
    return 1
  fi
}

# Export functions for use in test scripts
export -f log_test log_pass log_fail log_skip log_info log_warning log_error log_success log_failure log_section
export -f assert_success assert_failure
export -f assert_equals assert_not_equals assert_contains assert_not_contains assert_exit_code
export -f assert_file_exists assert_directory_exists
export -f assert_true assert_false
export -f normalize_output create_snapshot update_snapshot compare_snapshot
export -f capture_output
export -f create_test_env cleanup_test_env print_test_summary
