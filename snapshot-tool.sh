#!/bin/bash

# Snapshot management utility
# View, compare, and manage test snapshots

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Use environment variable if set, otherwise default to script directory
SNAPSHOT_DIR="${SNAPSHOT_DIR:-${SCRIPT_DIR}/snapshots}"

# Colors for output - only use colors if output is to a terminal or if FORCE_COLOR is set
export FORCE_COLOR=${FORCE_COLOR:-"1"}
if [[ "$FORCE_COLOR" = "0" ]]; then
  export RED=''
  export GREEN=''
  export YELLOW=''
  export BLUE=''
  export CYAN=''
  export MAGENTA=''
  export BOLD=''
  export NC=''
else
  export RED='\033[0;31m'
  export GREEN='\033[0;32m'
  export YELLOW='\033[1;33m'
  export BLUE='\033[0;34m'
  export CYAN='\033[0;36m'
  export MAGENTA='\033[0;35m'
  export BOLD='\033[1m'
  export NC='\033[0m'
fi

show_help() {
  cat <<EOF
Snapshot Management Utility for judge.sh

Usage: $0 <command> [options]

Commands:
    list                List all snapshots
    show <test-id>      Show latest snapshot for test
    diff <test-id>      Compare latest with master
    clean [days]        Remove old snapshots (default: 7 days)
    stats               Show snapshot statistics

Examples:
    $0 list                      # List all snapshots
    $0 show my-test              # Show latest my-test snapshot
    $0 diff my-test              # Compare latest with master
    $0 clean                     # Remove snapshots older than 7 days
    $0 clean 14                  # Remove snapshots older than 14 days
    $0 stats                     # Show statistics

EOF
}

list_snapshots() {
  echo "Snapshots in: ${SNAPSHOT_DIR}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  echo "Master Snapshots:"
  ls -lh "${SNAPSHOT_DIR}"/*_master.log 2>/dev/null | awk '{print "  " $9, "(" $5 ")"}'
  echo ""

  echo "Recent Run Snapshots:"
  ls -lt "${SNAPSHOT_DIR}"/*_[0-9]*_[0-9]*.log 2>/dev/null | head -10 | awk '{print "  " $9, "(" $5 ")"}'

  local count=$(ls "${SNAPSHOT_DIR}"/*_[0-9]*_[0-9]*.log 2>/dev/null | wc -l)
  if [[ $count -gt 10 ]]; then
    echo "  ... and $((count - 10)) more"
  fi
}

show_snapshot() {
  local test_id="$1"

  if [[ -z "$test_id" ]]; then
    echo "Error: Test ID required"
    echo "Usage: $0 show <test-id>"
    exit 1
  fi

  # Find latest snapshot for this test
  local latest=$(ls -t "${SNAPSHOT_DIR}/${test_id}"_*.log 2>/dev/null | head -1)

  if [[ -z "$latest" ]]; then
    echo "No snapshots found for: $test_id"
    exit 1
  fi

  echo "Showing: $latest"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  cat "$latest"
}

diff_snapshot() {
  local test_id="$1"

  if [[ -z "$test_id" ]]; then
    echo "Error: Test ID required"
    echo "Usage: $0 diff <test-id>"
    exit 1
  fi

  local master="${SNAPSHOT_DIR}/${test_id}_master.log"
  local latest=$(ls -t "${SNAPSHOT_DIR}/${test_id}"_[0-9]*_[0-9]*.log 2>/dev/null | head -1)

  if [[ ! -f "$master" ]]; then
    echo -e "${RED}Master snapshot not found: $master${NC}"
    exit 1
  fi

  if [[ -z "$latest" ]]; then
    echo -e "${YELLOW}No recent snapshots found for: $test_id${NC}"
    exit 1
  fi

  echo "Comparing:"
  echo "  Master: $master"
  echo "  Latest: $latest"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  if diff -q "$master" "$latest" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ No differences - outputs match${NC}"
  else
    echo -e "${YELLOW}⚠ Differences found:${NC}"
    echo ""
    diff -u "$master" "$latest" | head -50
    echo ""
    echo "... (showing first 50 lines of diff)"
  fi
}

clean_snapshots() {
  local days="${1:-7}"

  echo "Removing snapshots older than $days days..."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  local count=$(find "${SNAPSHOT_DIR}" -name "*_[0-9]*_[0-9]*.log" -mtime +$days 2>/dev/null | wc -l)

  if [[ $count -eq 0 ]]; then
    echo "No old snapshots to remove"
    return
  fi

  echo "Found $count snapshot(s) to remove:"
  find "${SNAPSHOT_DIR}" -name "*_[0-9]*_[0-9]*.log" -mtime +$days -exec basename {} \; | sed 's/^/  /'
  echo ""

  read -p "Remove these files? [y/N] " -n 1 -r
  echo

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    find "${SNAPSHOT_DIR}" -name "*_[0-9]*_[0-9]*.log" -mtime +$days -delete
    echo -e "${GREEN}✓ Removed $count snapshot(s)${NC}"
  else
    echo "Cancelled"
  fi
}

show_stats() {
  echo "Snapshot Statistics"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  local master_count=$(ls "${SNAPSHOT_DIR}"/*_master.log 2>/dev/null | wc -l)
  local run_count=$(ls "${SNAPSHOT_DIR}"/*_[0-9]*_[0-9]*.log 2>/dev/null | wc -l)
  local total_size=$(du -sh "${SNAPSHOT_DIR}" 2>/dev/null | awk '{print $1}')

  echo "Master snapshots: $master_count"
  echo "Run snapshots:    $run_count"
  echo "Total size:       $total_size"
  echo ""

  if [[ $run_count -gt 0 ]]; then
    echo "Oldest snapshot:"
    ls -lt "${SNAPSHOT_DIR}"/*_[0-9]*_[0-9]*.log 2>/dev/null | tail -1 | awk '{print "  " $9, "(" $6, $7, $8 ")"}'
    echo ""

    echo "Newest snapshot:"
    ls -lt "${SNAPSHOT_DIR}"/*_[0-9]*_[0-9]*.log 2>/dev/null | head -1 | awk '{print "  " $9, "(" $6, $7, $8 ")"}'
  fi
}

# Main command dispatcher
case "${1:-}" in
list)
  list_snapshots
  ;;
show)
  show_snapshot "$2"
  ;;
diff)
  diff_snapshot "$2"
  ;;
clean)
  clean_snapshots "$2"
  ;;
stats)
  show_stats
  ;;
-h | --help | help | "")
  show_help
  ;;
*)
  echo "Unknown command: $1"
  echo ""
  show_help
  exit 1
  ;;
esac
