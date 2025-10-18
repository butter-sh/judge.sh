#!/usr/bin/env bash

# judge.sh - Main entry point for test framework
# Delegates commands to specialized scripts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REAL_BASH_SOURCE="$(readlink -f "${BASH_SOURCE[0]}")"
REAL_SCRIPT_DIR="$(cd "$(dirname "${REAL_BASH_SOURCE}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_usage() {
    cat << EOF
judge.sh - A bash testing framework with snapshot support

USAGE:
    judge.sh <command> [options]

COMMANDS:
    run      Run all tests (delegates to run-all-tests.sh)
    setup    Initialize snapshot baselines (delegates to setup-snapshots.sh)
    snap     Manage snapshots (delegates to snapshot-tool.sh)
    help     Show this help message

EXAMPLES:
    # Run all tests
    judge.sh run

    # Run tests with verbose output
    judge.sh run -v

    # Run specific test suite
    judge.sh run -t my-test

    # Update snapshots
    judge.sh run -u

    # Initialize snapshots (first time setup)
    judge.sh setup

    # List all snapshots
    judge.sh snap list

    # Compare snapshot with master
    judge.sh snap diff test-name

    # Show snapshot statistics
    judge.sh snap stats

For detailed command help:
    judge.sh run --help
    judge.sh snap --help

EOF
}

main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 0
    fi

    local command="$1"
    shift
    

    case "$command" in
        run)
            # Delegate to run-all-tests.sh
            exec bash "${REAL_SCRIPT_DIR}/run-all-tests.sh" "$@"
            ;;
        setup)
            # Delegate to setup-snapshots.sh
            exec bash "${REAL_SCRIPT_DIR}/setup-snapshots.sh" "$@"
            ;;
        snap)
            # Delegate to snapshot-tool.sh
            exec bash "${REAL_SCRIPT_DIR}/snapshot-tool.sh" "$@"
            ;;
        help|--help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown command '$command'${NC}"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
