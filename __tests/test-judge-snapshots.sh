#!/usr/bin/env bash
# Test suite for judge.sh snapshot functionality

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_HELPERS="${SCRIPT_DIR}/../test-helpers.sh"

# Setup before each test
setup() {
    TEST_DIR=$(mktemp -d)
    export SNAPSHOT_DIR="$TEST_DIR/snapshots"
    mkdir -p "$SNAPSHOT_DIR"
    cd "$TEST_DIR"
    source "$TEST_HELPERS" 2>/dev/null
}

# Cleanup after each test
teardown() {
    cd /
    rm -rf "$TEST_DIR"
}

# Test: create_snapshot creates snapshot file
test_create_snapshot() {
    setup
    
    create_snapshot "test-snap" "test content" >/dev/null 2>&1
    
    if [[ -f "${SNAPSHOT_DIR}/test-snap.snapshot" ]]; then
        echo "✓ Snapshot file created"
        teardown
        return 0
    else
        echo "✗ Snapshot file not created"
        teardown
        return 1
    fi
}

# Test: create_snapshot normalizes content
test_create_snapshot_normalizes() {
    setup
    
    create_snapshot "test-snap" "content with trailing spaces   " >/dev/null 2>&1
    
    content=$(cat "${SNAPSHOT_DIR}/test-snap.snapshot")
    if [[ ! "$content" =~ [[:space:]]+$ ]]; then
        echo "✓ Trailing spaces removed"
        teardown
        return 0
    else
        echo "✗ Trailing spaces not removed"
        teardown
        return 1
    fi
}

# Test: update_snapshot updates existing snapshot
test_update_snapshot() {
    setup
    
    create_snapshot "test-snap" "original content" >/dev/null 2>&1
    update_snapshot "test-snap" "updated content" >/dev/null 2>&1
    
    content=$(cat "${SNAPSHOT_DIR}/test-snap.snapshot")
    if [[ "$content" == "updated content" ]]; then
        echo "✓ Snapshot updated"
        teardown
        return 0
    else
        echo "✗ Snapshot not updated correctly"
        teardown
        return 1
    fi
}

# Test: compare_snapshot matches identical content
test_compare_snapshot_match() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    create_snapshot "test-snap" "test content" >/dev/null 2>&1
    compare_snapshot "test-snap" "test content" "Snapshot comparison" >/dev/null 2>&1
    
    if [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ Snapshot comparison passes on match"
        teardown
        return 0
    else
        echo "✗ Snapshot comparison failed on match"
        teardown
        return 1
    fi
}

# Test: compare_snapshot fails on mismatch
test_compare_snapshot_mismatch() {
    setup
    
    TESTS_RUN=0
    TESTS_FAILED=0
    
    create_snapshot "test-snap" "original content" >/dev/null 2>&1
    
    set +e
    compare_snapshot "test-snap" "different content" "Snapshot comparison" >/dev/null 2>&1
    result=$?
    set -e
    
    if [[ $result -ne 0 ]] && [[ $TESTS_FAILED -eq 1 ]]; then
        echo "✓ Snapshot comparison fails on mismatch"
        teardown
        return 0
    else
        echo "✗ Snapshot comparison mismatch behavior incorrect"
        teardown
        return 1
    fi
}

# Test: compare_snapshot creates missing snapshot
test_compare_snapshot_creates_missing() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    compare_snapshot "new-snap" "new content" "New snapshot" >/dev/null 2>&1
    
    if [[ -f "${SNAPSHOT_DIR}/new-snap.snapshot" ]] && [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ Missing snapshot created"
        teardown
        return 0
    else
        echo "✗ Missing snapshot not created correctly"
        teardown
        return 1
    fi
}

# Test: normalize_output removes ANSI codes
test_normalize_output_ansi() {
    setup
    
    input=$'\033[0;31mRed text\033[0m'
    output=$(normalize_output "$input")
    
    if [[ ! "$output" =~ $'\033' ]] && [[ "$output" == *"Red text"* ]]; then
        echo "✓ ANSI codes removed"
        teardown
        return 0
    else
        echo "✗ ANSI codes not removed correctly"
        teardown
        return 1
    fi
}

# Test: normalize_output removes trailing whitespace
test_normalize_output_whitespace() {
    setup
    
    input="content with spaces   "
    output=$(normalize_output "$input")
    
    if [[ ! "$output" =~ [[:space:]]+$ ]]; then
        echo "✓ Trailing whitespace removed"
        teardown
        return 0
    else
        echo "✗ Trailing whitespace not removed"
        teardown
        return 1
    fi
}

# Test: snapshot comparison ignores whitespace differences
test_snapshot_whitespace_insensitive() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    create_snapshot "test-snap" "content" >/dev/null 2>&1
    compare_snapshot "test-snap" "content   " "Whitespace test" >/dev/null 2>&1
    
    if [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ Whitespace differences ignored"
        teardown
        return 0
    else
        echo "✗ Whitespace differences not ignored"
        teardown
        return 1
    fi
}

# Test: snapshot comparison ignores ANSI codes
test_snapshot_ansi_insensitive() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    create_snapshot "test-snap" "plain text" >/dev/null 2>&1
    compare_snapshot "test-snap" $'\033[0;32mplain text\033[0m' "ANSI test" >/dev/null 2>&1
    
    if [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ ANSI codes ignored in comparison"
        teardown
        return 0
    else
        echo "✗ ANSI codes not ignored"
        teardown
        return 1
    fi
}

# Test: multiple snapshots can coexist
test_multiple_snapshots() {
    setup
    
    create_snapshot "snap1" "content 1" >/dev/null 2>&1
    create_snapshot "snap2" "content 2" >/dev/null 2>&1
    create_snapshot "snap3" "content 3" >/dev/null 2>&1
    
    if [[ -f "${SNAPSHOT_DIR}/snap1.snapshot" ]] && \
       [[ -f "${SNAPSHOT_DIR}/snap2.snapshot" ]] && \
       [[ -f "${SNAPSHOT_DIR}/snap3.snapshot" ]]; then
        
        content1=$(cat "${SNAPSHOT_DIR}/snap1.snapshot")
        content2=$(cat "${SNAPSHOT_DIR}/snap2.snapshot")
        
        if [[ "$content1" != "$content2" ]]; then
            echo "✓ Multiple snapshots coexist independently"
            teardown
            return 0
        else
            echo "✗ Snapshots not independent"
            teardown
            return 1
        fi
    else
        echo "✗ Not all snapshots created"
        teardown
        return 1
    fi
}

# Test: snapshot names can include hyphens
test_snapshot_names_with_hyphens() {
    setup
    
    create_snapshot "test-snap-name-123" "content" >/dev/null 2>&1
    
    if [[ -f "${SNAPSHOT_DIR}/test-snap-name-123.snapshot" ]]; then
        echo "✓ Hyphens in snapshot names work"
        teardown
        return 0
    else
        echo "✗ Hyphens in snapshot names don't work"
        teardown
        return 1
    fi
}

# Test: snapshot handles multiline content
test_snapshot_multiline() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    multiline="line 1
line 2
line 3"
    
    create_snapshot "multiline" "$multiline" >/dev/null 2>&1
    compare_snapshot "multiline" "$multiline" "Multiline test" >/dev/null 2>&1
    
    if [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ Multiline content handled"
        teardown
        return 0
    else
        echo "✗ Multiline content not handled correctly"
        teardown
        return 1
    fi
}

# Test: snapshot handles empty content
test_snapshot_empty() {
    setup
    
    TESTS_RUN=0
    TESTS_PASSED=0
    
    create_snapshot "empty" "" >/dev/null 2>&1
    compare_snapshot "empty" "" "Empty test" >/dev/null 2>&1
    
    if [[ $TESTS_PASSED -eq 1 ]]; then
        echo "✓ Empty content handled"
        teardown
        return 0
    else
        echo "✗ Empty content not handled correctly"
        teardown
        return 1
    fi
}

# Run all tests
run_tests() {
    local total=14
    local passed=0
    
    echo "Running snapshot functionality tests..."
    echo ""
    
    test_create_snapshot && passed=$((passed + 1))
    test_create_snapshot_normalizes && passed=$((passed + 1))
    test_update_snapshot && passed=$((passed + 1))
    test_compare_snapshot_match && passed=$((passed + 1))
    test_compare_snapshot_mismatch && passed=$((passed + 1))
    test_compare_snapshot_creates_missing && passed=$((passed + 1))
    test_normalize_output_ansi && passed=$((passed + 1))
    test_normalize_output_whitespace && passed=$((passed + 1))
    test_snapshot_whitespace_insensitive && passed=$((passed + 1))
    test_snapshot_ansi_insensitive && passed=$((passed + 1))
    test_multiple_snapshots && passed=$((passed + 1))
    test_snapshot_names_with_hyphens && passed=$((passed + 1))
    test_snapshot_multiline && passed=$((passed + 1))
    test_snapshot_empty && passed=$((passed + 1))
    
    echo ""
    echo "═══════════════════════════════════════"
    echo "Snapshot Tests: $passed/$total passed"
    echo "═══════════════════════════════════════"
    
    if [[ $passed -eq $total ]]; then
        return 0
    else
        return 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
    exit $?
fi
