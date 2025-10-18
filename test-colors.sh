#!/bin/bash

# Simple color test script
export FORCE_COLOR=1

# Source test helpers to get color variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/test-helpers.sh"

echo "Testing colors..."
echo ""
echo "Color variables:"
echo "CYAN='$CYAN'"
echo "GREEN='$GREEN'"
echo "NC='$NC'"
echo ""

echo "Testing banner:"
echo -e "${CYAN}╔════════════════════════╗${NC}"
echo -e "${CYAN}║  TEST BANNER          ║${NC}"
echo -e "${CYAN}╚════════════════════════╝${NC}"
echo ""

echo "Testing section:"
echo -e "${CYAN}═══════════════════════════════${NC}"
echo -e "${CYAN}  TEST SECTION${NC}"
echo -e "${CYAN}═══════════════════════════════${NC}"
echo ""

echo "Testing labels:"
echo -e "${GREEN}[PASS]${NC} This should be green"
echo -e "${BLUE}[INFO]${NC} This should be blue"
echo -e "${RED}[FAIL]${NC} This should be red"
echo ""

echo "If you see color codes like [0;36m above, colors are NOT working"
echo "If you see actual colors, then colors ARE working"
