#!/bin/bash

# Test Runner with Snapshot Support
# Runs all test suites, captures output, and manages snapshots

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test-helpers.sh"

# Export tests dir
export TESTS_DIR="$PWD/__tests"

# Load test config
source "${SCRIPT_DIR}/test-config.sh"
if [ -f "${TESTS_DIR}/test-config.sh" ]; then
	source "${TESTS_DIR}/test-config.sh"
fi

# ============================================================================
# CONFIGURATION
# ============================================================================

PROJECT_ROOT="${PWD}/__tests"
SNAPSHOT_DIR="${PROJECT_ROOT}/snapshots"
SNAPSHOT_TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create snapshot directory if it doesn't exist
mkdir -p "${SNAPSHOT_DIR}"

# Parse command line arguments
UPDATE_SNAPSHOTS=0
RUN_INTEGRATION_TESTS=0
VERBOSE=0
SPECIFIC_TEST=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--update-snapshots)
            UPDATE_SNAPSHOTS=1
            export UPDATE_SNAPSHOTS
            shift
            ;;
        -i|--integration)
            RUN_INTEGRATION_TESTS=1
            export RUN_INTEGRATION_TESTS
            shift
            ;;
        -v|--verbose)
            VERBOSE=1
            export VERBOSE
            shift
            ;;
        -t|--test)
            SPECIFIC_TEST="$2"
            shift 2
            ;;
        -h|--help)
            cat << EOF
judge.sh Test Suite Runner

Usage: $0 [OPTIONS]

Options:
    -u, --update-snapshots   Update all test snapshots
    -i, --integration        Run integration tests
    -v, --verbose           Enable verbose output
    -t, --test TEST         Run specific test suite
    -h, --help             Show this help message

Examples:
    $0                              Run all tests
    $0 -u                           Update all snapshots
    $0 -i                           Run integration tests
    $0 -v                           Verbose output
    $0 -t my-test                   Run only my-test suite
    $0 -u -t my-test                Update snapshots for my-test

Snapshots:
    Test output is captured and saved to: snapshots/
    Each test run creates a timestamped snapshot for comparison.
    Use -u flag to update the master snapshots.

EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# ============================================================================
# SNAPSHOT FUNCTIONS
# ============================================================================

save_snapshot() {
    local test_name="$1"
    local output="$2"
    local snapshot_file="${SNAPSHOT_DIR}/${test_name}_${SNAPSHOT_TIMESTAMP}.log"
    local master_snapshot="${SNAPSHOT_DIR}/${test_name}_master.log"
    
    # Save timestamped snapshot
    echo "$output" > "$snapshot_file"
    
    # Update master snapshot if requested
    if [ $UPDATE_SNAPSHOTS -eq 1 ]; then
        echo "$output" > "$master_snapshot"
        log_info "Updated master snapshot: ${master_snapshot}"
    fi
    
    log_info "Saved snapshot: ${snapshot_file}"
}

compare_snapshot() {
    local test_name="$1"
    local output="$2"
    local master_snapshot="${SNAPSHOT_DIR}/${test_name}_master.log"
    
    if [ ! -f "$master_snapshot" ]; then
        log_warning "No master snapshot found for ${test_name}"
        log_info "Creating initial master snapshot..."
        echo "$output" > "$master_snapshot"
        return 0
    fi
    
    # Compare with master
    local temp_file=$(mktemp)
    echo "$output" > "$temp_file"
    
    if diff -q "$master_snapshot" "$temp_file" > /dev/null 2>&1; then
        log_info "✓ Output matches master snapshot"
        rm "$temp_file"
        return 0
    else
        log_warning "⚠ Output differs from master snapshot"
        log_info "Run with -u flag to update snapshots"
        rm "$temp_file"
        return 1
    fi
}

# ============================================================================
# BANNER
# ============================================================================

clear
cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              judge.sh TEST SUITE                       ║
║              Version 1.0.0                                     ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

EOF

# ============================================================================
# PRE-FLIGHT CHECKS
# ============================================================================

log_section "PRE-FLIGHT CHECKS"


for test_file in "${TEST_FILES[@]}"; do
    if [ -f "${TESTS_DIR}/${test_file}" ]; then
        log_pass "Found ${test_file}"
    else
        log_warning "Missing ${test_file}"
    fi
done

# ============================================================================
# TEST CONFIGURATION INFO
# ============================================================================

log_section "TEST CONFIGURATION"

if [ $UPDATE_SNAPSHOTS -eq 1 ]; then
    log_info "Snapshot mode: UPDATE (will create/update snapshots)"
else
    log_info "Snapshot mode: COMPARE (will compare against existing snapshots)"
fi

if [ $RUN_INTEGRATION_TESTS -eq 1 ]; then
    log_info "Integration tests: ENABLED"
else
    log_info "Integration tests: DISABLED (use -i to enable)"
fi

if [ -n "$SPECIFIC_TEST" ]; then
    log_info "Running specific test: $SPECIFIC_TEST"
else
    log_info "Running all tests"
fi

log_info "Snapshot directory: ${SNAPSHOT_DIR}"

# ============================================================================
# RUN TESTS
# ============================================================================

FAILED_SUITES=()

run_test_suite() {
    local test_file="$1"
    local test_name="$2"
    local test_id="$3"

    if [ ! -f "${TESTS_DIR}/${test_file}" ]; then
        log_skip "Test file not found: ${test_file}"
        return
    fi

    chmod +x "${TESTS_DIR}/${test_file}"

    log_section "RUNNING: ${test_name}"

    # Capture all output
    local output_file=$(mktemp)
    
    set +e
    {
        bash "${TESTS_DIR}/${test_file}" 2>&1 | tee "$output_file"
    }
    local exit_code=${PIPESTATUS[0]}
    set -e
    
    # Read captured output
    local captured_output=$(cat "$output_file")
    
    # Save snapshot
    save_snapshot "$test_id" "$captured_output"
    
    # Compare with master if not updating
    if [ $UPDATE_SNAPSHOTS -eq 0 ]; then
        compare_snapshot "$test_id" "$captured_output"
    fi
    
    # Cleanup temp file
    rm "$output_file"
    
    if [ $exit_code -eq 0 ]; then
        log_success "✓ ${test_name} completed successfully"
    else
        log_error "✗ ${test_name} failed"
        FAILED_SUITES+=("$test_name")
    fi

    echo ""
}

# Run specific test or all tests
if [ -n "$SPECIFIC_TEST" ]; then
    run_test_suite "test-${SPECIFIC_TEST}.sh" "${SPECIFIC_TEST}" "${SPECIFIC_TEST}"
else
    # Add your test suites here
    run_test_suite "test-example.sh" "Example Tests" "example"
fi

# ============================================================================
# FINAL REPORT
# ============================================================================

log_section "FINAL TEST REPORT"

echo ""
echo "Test Execution Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ${#FAILED_SUITES[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All test suites passed!${NC}"
    echo ""
    suites_run=$([ -n "$SPECIFIC_TEST" ] && echo 1 || echo ${#TEST_FILES[@]})
    echo "  Test suites run: $suites_run"
    echo ""
else
    echo -e "${RED}✗ Some test suites failed:${NC}"
    echo ""
    for suite in "${FAILED_SUITES[@]}"; do
        echo "  - $suite"
    done
    echo ""
    echo "  Failed suites: ${#FAILED_SUITES[@]}"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Snapshot information
echo "Snapshots:"
echo "  Location: ${SNAPSHOT_DIR}"
echo "  Timestamp: ${SNAPSHOT_TIMESTAMP}"

if [ $UPDATE_SNAPSHOTS -eq 1 ]; then
    echo "  Status: Master snapshots updated ✓"
else
    echo "  Status: Compared against master snapshots"
fi
echo ""

# Suggestions
if [ $RUN_INTEGRATION_TESTS -eq 0 ]; then
    log_info "Tip: Run with -i flag to include integration tests"
fi

if [ $UPDATE_SNAPSHOTS -eq 0 ]; then
    log_info "Tip: Run with -u flag to update snapshots if tests fail"
fi

if [ $VERBOSE -eq 0 ]; then
    log_info "Tip: Run with -v flag for verbose output"
fi

echo ""

# Exit with appropriate code
if [ ${#FAILED_SUITES[@]} -eq 0 ]; then
    exit 0
else
    exit 1
fi
