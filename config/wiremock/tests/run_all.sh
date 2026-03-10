#!/usr/bin/env bash
# Run all WireMock test suites and summarize results
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FAIL_FAST=false
FILTERS=()

for arg in "$@"; do
  case "$arg" in
    --fail-fast)
      FAIL_FAST=true
      ;;
    --help|-h)
      echo "Usage: $0 [--fail-fast] [suiteName ...]"
      echo "  Available suites: sms, teams"
      exit 0
      ;;
    *)
      FILTERS+=("$arg")
      ;;
  esac
done

FOUND=()
for f in "$SCRIPT_DIR"/*/tests.sh; do
  if [ -f "$f" ]; then
    FOUND+=("$f")
  fi
done

SUITES=()
if [ ${#FILTERS[@]} -gt 0 ]; then
  for suite in "${FOUND[@]}"; do
    name="$(basename "$(dirname "$suite")")"
    for flt in "${FILTERS[@]}"; do
      if [ "$name" = "$flt" ]; then
        SUITES+=("$suite")
        break
      fi
    done
  done
else
  SUITES=("${FOUND[@]}")
fi

if [ ${#SUITES[@]} -eq 0 ]; then
  echo "No test suites matched."
  exit 1
fi

TOTAL=${#SUITES[@]}
PASSED=0
FAILED=0

NAMES=()
for s in "${SUITES[@]}"; do
  NAMES+=("$(basename "$(dirname "$s")")")
done

echo "Running $TOTAL suite(s): ${NAMES[*]}"

idx=1
for suite in "${SUITES[@]}"; do
  name="$(basename "$(dirname "$suite")")"
  echo
  echo "[$idx/$TOTAL] $name"
  if bash "$suite"; then
    echo "$name ✓"
    PASSED=$((PASSED+1))
  else
    code=$?
    echo "$name ✗ (exit $code)"
    FAILED=$((FAILED+1))
    if [ "$FAIL_FAST" = true ]; then
      echo
      echo "Suites summary: $TOTAL total, $PASSED passed, $FAILED failed"
      exit 1
    fi
  fi
  idx=$((idx+1))
done

echo
echo "Suites summary: $TOTAL total, $PASSED passed, $FAILED failed"
if [ $FAILED -gt 0 ]; then
  exit 1
fi