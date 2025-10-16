#!/usr/bin/env bash

# judge.sh - A bash testing framework
# Version: 1.0.0

set -euo pipefail

# Global test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
JUDGE_VERBOSE=${JUDGE_VERBOSE:-false}
JUDGE_STOP_ON_FAIL=${JUDGE_STOP_ON_FAIL:-false}

# Current test suite
CURRENT_SUITE=""

# Test result storage
declare -a TEST_RESULTS=()

# Logging functions
log_suite() {
    echo -e "\n${CYAN}▶ Test Suite: $1${NC}"
}

log_pass() {
    echo -e "  ${GREEN}✓${NC} $1"
}

log_fail() {
    echo -e "  ${RED}✗${NC} $1"
    if [[ -n "${2:-}" ]]; then
        echo -e "    ${RED}Error: $2${NC}"
    fi
}

log_skip() {
    echo -e "  ${YELLOW}○${NC} $1 ${YELLOW}(skipped)${NC}"
}

log_info() {
    if [[ "$JUDGE_VERBOSE" == "true" ]]; then
        echo -e "  ${BLUE}ℹ${NC} $1"
    fi
}

# Initialize a test suite
describe() {
    local suite_name="$1"
    CURRENT_SUITE="$suite_name"
    log_suite "$suite_name"
}

# Run a test
it() {
    local test_name="$1"
    local test_func="$2"
    
    ((TESTS_TOTAL++))
    
    log_info "Running: $test_name"
    
    # Run the test in a subshell to isolate failures
    if ( set -e; eval "$test_func" ) 2>/dev/null; then
        ((TESTS_PASSED++))
        log_pass "$test_name"
        TEST_RESULTS+=("PASS|$CURRENT_SUITE|$test_name")
        return 0
    else
        ((TESTS_FAILED++))
        log_fail "$test_name" "Test function failed"
        TEST_RESULTS+=("FAIL|$CURRENT_SUITE|$test_name")
        
        if [[ "$JUDGE_STOP_ON_FAIL" == "true" ]]; then
            exit 1
        fi
        return 1
    fi
}

# Skip a test
xit() {
    local test_name="$1"
    ((TESTS_TOTAL++))
    ((TESTS_SKIPPED++))
    log_skip "$test_name"
    TEST_RESULTS+=("SKIP|$CURRENT_SUITE|$test_name")
}

# Assertion functions

# Assert that two values are equal
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Expected '$expected' but got '$actual'}"
    
    if [[ "$expected" != "$actual" ]]; then
        echo "$message" >&2
        return 1
    fi
    return 0
}

# Assert that a value is true (non-empty and not 0)
assert_true() {
    local value="$1"
    local message="${2:-Expected true value}"
    
    if [[ -z "$value" ]] || [[ "$value" == "0" ]] || [[ "$value" == "false" ]]; then
        echo "$message" >&2
        return 1
    fi
    return 0
}

# Assert that a value is false (empty or 0)
assert_false() {
    local value="$1"
    local message="${2:-Expected false value}"
    
    if [[ -n "$value" ]] && [[ "$value" != "0" ]] && [[ "$value" != "false" ]]; then
        echo "$message" >&2
        return 1
    fi
    return 0
}

# Assert that a value is empty
assert_empty() {
    local value="$1"
    local message="${2:-Expected empty value}"
    
    if [[ -n "$value" ]]; then
        echo "$message" >&2
        return 1
    fi
    return 0
}

# Assert that a value is not empty
assert_not_empty() {
    local value="$1"
    local message="${2:-Expected non-empty value}"
    
    if [[ -z "$value" ]]; then
        echo "$message" >&2
        return 1
    fi
    return 0
}

# Assert that a value contains a substring
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Expected '$haystack' to contain '$needle'}"
    
    if [[ "$haystack" != *"$needle"* ]]; then
        echo "$message" >&2
        return 1
    fi
    return 0
}

# Assert that a file exists
assert_file_exists() {
    local file="$1"
    local message="${2:-Expected file '$file' to exist}"
    
    if [[ ! -f "$file" ]]; then
        echo "$message" >&2
        return 1
    fi
    return 0
}

# Assert that a directory exists
assert_dir_exists() {
    local dir="$1"
    local message="${2:-Expected directory '$dir' to exist}"
    
    if [[ ! -d "$dir" ]]; then
        echo "$message" >&2
        return 1
    fi
    return 0
}

# Assert that a command succeeds (exit code 0)
assert_success() {
    local command="$1"
    local message="${2:-Expected command to succeed: $command}"
    
    if ! eval "$command" &>/dev/null; then
        echo "$message" >&2
        return 1
    fi
    return 0
}

# Assert that a command fails (non-zero exit code)
assert_failure() {
    local command="$1"
    local message="${2:-Expected command to fail: $command}"
    
    if eval "$command" &>/dev/null; then
        echo "$message" >&2
        return 1
    fi
    return 0
}

# Print test summary
print_summary() {
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${CYAN}Test Summary${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "Total:   ${BLUE}$TESTS_TOTAL${NC}"
    echo -e "Passed:  ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed:  ${RED}$TESTS_FAILED${NC}"
    
    if [[ $TESTS_SKIPPED -gt 0 ]]; then
        echo -e "Skipped: ${YELLOW}$TESTS_SKIPPED${NC}"
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        return 1
    fi
}

# Run test files
run_test_file() {
    local test_file="$1"
    
    if [[ ! -f "$test_file" ]]; then
        echo -e "${RED}Error: Test file not found: $test_file${NC}"
        return 1
    fi
    
    echo -e "${MAGENTA}Running tests from: $test_file${NC}"
    
    # Source the test file
    source "$test_file"
}

# Run all test files in a directory
run_test_dir() {
    local test_dir="${1:-.}"
    local pattern="${2:-*test.sh}"
    
    if [[ ! -d "$test_dir" ]]; then
        echo -e "${RED}Error: Test directory not found: $test_dir${NC}"
        return 1
    fi
    
    local test_files=()
    while IFS= read -r -d '' file; do
        test_files+=("$file")
    done < <(find "$test_dir" -name "$pattern" -type f -print0)
    
    if [[ ${#test_files[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No test files found matching pattern: $pattern${NC}"
        return 0
    fi
    
    for test_file in "${test_files[@]}"; do
        run_test_file "$test_file"
    done
}

# Show usage
show_usage() {
    cat << EOF
judge.sh - A bash testing framework

USAGE:
    judge.sh [command] [options]

COMMANDS:
    test [file/dir]     Run test file(s)
    help                Show this help message

OPTIONS:
    -v, --verbose       Verbose output
    -s, --stop          Stop on first failure
    -p, --pattern       File pattern for test discovery (default: *test.sh)

EXAMPLES:
    # Run a single test file
    judge.sh test my_test.sh

    # Run all tests in a directory
    judge.sh test ./tests

    # Run with custom pattern
    judge.sh test ./tests --pattern "*spec.sh"

    # Verbose mode
    judge.sh test --verbose my_test.sh

WRITING TESTS:
    #!/usr/bin/env bash
    source judge.sh

    describe "My Test Suite"

    it "should pass this test" "
        assert_equals 'hello' 'hello'
    "

    it "should compare numbers" "
        result=\$((2 + 2))
        assert_equals '4' \"\$result\"
    "

ASSERTIONS:
    assert_equals <expected> <actual> [message]
    assert_true <value> [message]
    assert_false <value> [message]
    assert_empty <value> [message]
    assert_not_empty <value> [message]
    assert_contains <haystack> <needle> [message]
    assert_file_exists <file> [message]
    assert_dir_exists <dir> [message]
    assert_success <command> [message]
    assert_failure <command> [message]

EOF
}

# Main function
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 0
    fi
    
    local command="$1"
    shift
    
    # Parse options
    local test_path="."
    local pattern="*test.sh"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                JUDGE_VERBOSE=true
                shift
                ;;
            -s|--stop)
                JUDGE_STOP_ON_FAIL=true
                shift
                ;;
            -p|--pattern)
                pattern="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                test_path="$1"
                shift
                ;;
        esac
    done
    
    case "$command" in
        test)
            if [[ -f "$test_path" ]]; then
                run_test_file "$test_path"
            elif [[ -d "$test_path" ]]; then
                run_test_dir "$test_path" "$pattern"
            else
                echo -e "${RED}Error: Path not found: $test_path${NC}"
                exit 1
            fi
            
            print_summary
            exit $?
            ;;
        help|--help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Export functions for use in test files
export -f describe it xit
export -f assert_equals assert_true assert_false assert_empty assert_not_empty
export -f assert_contains assert_file_exists assert_dir_exists
export -f assert_success assert_failure

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
