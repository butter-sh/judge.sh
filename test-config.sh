#!/usr/bin/env bash
# Test configuration for test suites
# This file is sourced by test files to set common configuration

# Colors for output - only use colors if output is to a terminal or if FORCE_COLOR is set
if [[ -z "$FORCE_COLOR" ]]; then
		if [[ $FORCE_COLOR == 1 ]]; then
			  export RED='\033[0;31m'
				export GREEN='\033[0;32m'
				export YELLOW='\033[1;33m'
				export BLUE='\033[0;34m'
				export CYAN='\033[0;36m'
				export NC='\033[0m'
		else
			export RED=''
			export GREEN=''
			export YELLOW=''
			export BLUE=''
			export CYAN=''
			export NC=''
		fi
else if [[ -t 1 ]] && [[ -t 2 ]]; then
		export RED='\033[0;31m'
    export GREEN='\033[0;32m'
    export YELLOW='\033[1;33m'
    export BLUE='\033[0;34m'
    export CYAN='\033[0;36m'
    export NC='\033[0m'
else
    export RED=''
    export GREEN=''
    export YELLOW=''
    export BLUE=''
    export CYAN=''
    export NC=''
fi

# Test directory structure
export SNAPSHOTS_DIR="${TESTS_DIR}/snapshots"
export TEMP_DIR="${TESTS_DIR}/temp"

# Snapshot configuration
export SNAPSHOT_UPDATE="${UPDATE_SNAPSHOTS:-0}"
export SNAPSHOT_VERBOSE="${VERBOSE:-0}"

check() {
    local description="$1"
    local test_command="$2"
    
    printf "%-50s" "$description"
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo "✅ PASS"
        ((checks_passed++))
        return 0
    else
        echo "❌ FAIL"
        ((checks_failed++))
        return 1
    fi
}


# Test utilities
create_test_env() {
    local test_name="${1:-test}"
    local test_dir
    test_dir=$(mktemp -d "${TEMP_DIR}/arty-test-${test_name}-XXXXXX")
    echo "$test_dir"
}

cleanup_test_env() {
    local test_dir="$1"
    if [[ -n "$test_dir" ]] && [[ -d "$test_dir" ]]; then
        rm -rf "$test_dir"
    fi
}

# Assert helper shortcuts
assert_dir_exists() {
    assert_directory_exists "$@"
}

assert_success() {
    assert_exit_code 0 "$?" "${1:-Command should succeed}"
}

assert_failure() {
    assert_true "[[ $? -ne 0 ]]" "${1:-Command should fail}"
}

# Export utilities
export -f create_test_env
export -f cleanup_test_env
export -f assert_dir_exists
export -f assert_success
export -f assert_failure
export -f check
