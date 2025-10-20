#!/usr/bin/env bash
# Test configuration for judge.sh test suite
# This file is sourced by test files to set common configuration

export TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Test directory structure
export JUDGE_SH_ROOT="$(dirname "$TEST_ROOT")"
export JUDGE_SH="${JUDGE_SH_ROOT}/judge.sh"
