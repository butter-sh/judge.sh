#!/usr/bin/env bash
# Test configuration for test suites
# This file is sourced by test files to set common configuration

# Snapshot configuration
export SNAPSHOT_UPDATE="${UPDATE_SNAPSHOTS:-0}"
export SNAPSHOT_VERBOSE="${VERBOSE:-0}"
