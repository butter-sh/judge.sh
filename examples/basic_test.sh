#!/usr/bin/env bash

# Basic test examples for judge.sh

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source judge.sh from parent directory
source "$SCRIPT_DIR/../judge.sh"

# Test Suite 1: Basic Assertions
describe "Basic Assertions"

it "should compare equal values" "
    assert_equals 'hello' 'hello'
"

it "should compare numbers" "
    result=\$((5 + 5))
    assert_equals '10' \"\$result\"
"

it "should check true values" "
    assert_true '1'
    assert_true 'true'
    assert_true 'yes'
"

it "should check false values" "
    assert_false '0'
    assert_false ''
"

# Test Suite 2: String Operations
describe "String Operations"

it "should check if string contains substring" "
    text='The quick brown fox'
    assert_contains \"\$text\" 'quick'
    assert_contains \"\$text\" 'fox'
"

it "should check empty strings" "
    empty=''
    assert_empty \"\$empty\"
"

it "should check non-empty strings" "
    text='hello'
    assert_not_empty \"\$text\"
"

# Test Suite 3: Math Operations
describe "Math Operations"

it "should add numbers correctly" "
    result=\$((2 + 3))
    assert_equals '5' \"\$result\"
"

it "should multiply numbers correctly" "
    result=\$((4 * 5))
    assert_equals '20' \"\$result\"
"

it "should handle division" "
    result=\$((10 / 2))
    assert_equals '5' \"\$result\"
"

# Test Suite 4: Command Execution
describe "Command Execution"

it "should succeed with valid commands" "
    assert_success 'echo hello'
    assert_success 'true'
"

it "should fail with invalid commands" "
    assert_failure 'false'
"

# Test Suite 5: File System
describe "File System"

it "should check if common files exist" "
    assert_file_exists '/etc/hosts'
"

it "should check if common directories exist" "
    assert_dir_exists '/tmp'
    assert_dir_exists '/etc'
"

# Example of a skipped test
xit "should be implemented later" "
    # This test is skipped
    assert_true '1'
"

# Print summary if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo
    print_summary
    exit $?
fi
