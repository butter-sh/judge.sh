#!/bin/bash

# Initial snapshot setup
# Run this once to create master snapshots for the first time

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "════════════════════════════════════════════════════"
echo "  Initial Snapshot Setup for judge.sh"
echo "════════════════════════════════════════════════════"
echo ""
echo "This will create master snapshots for all test suites."
echo "Master snapshots serve as the reference for future test runs."
echo ""
echo "Press Enter to continue, or Ctrl+C to cancel..."
read

echo ""
echo "Running all tests and creating master snapshots..."
echo ""

# Run with update flag to create master snapshots
"${SCRIPT_DIR}/run-all-tests.sh" -u

echo ""
echo "════════════════════════════════════════════════════"
echo "  Setup Complete"
echo "════════════════════════════════════════════════════"
echo ""
echo "Master snapshots created in: snapshots/"
echo ""
echo "Next steps:"
echo "  1. Review the master snapshot files"
echo "  2. Commit them to git:"
echo "     git add snapshots/*_master.log"
echo "     git commit -m \"Add initial test snapshots\""
echo ""
echo "  3. Run tests normally:"
echo "     ./judge.sh run"
echo ""
