#!/usr/bin/env bash
# Shared helper for WireMock API test suites
set -e

if [ -t 1 ]; then
  _GREEN=$'\033[0;32m'
  _RED=$'\033[0;31m'
  _DIM=$'\033[2m'
  _RESET=$'\033[0m'
else
  _GREEN=""; _RED=""; _DIM=""; _RESET=""
fi

PASS_COUNT=0
FAIL_COUNT=0
TOTAL_COUNT=0

init_report() {
  PASS_COUNT=0
  FAIL_COUNT=0
  TOTAL_COUNT=0
}

_request() {
  local _method="$1"
  local _url="$2"
  local _data="${3:-}"
  local _tmp_body
  _tmp_body=$(mktemp -t wm_body.XXXXXX)
  local _args=("-sS" "-o" "$_tmp_body" "-w" "%{http_code}")
  case "$_method" in
    GET)   _args+=("$_url") ;;
    POST)  _args+=("-X" "POST" "-H" "Content-Type: application/json" "-d" "${_data:-\{\}}" "$_url") ;;
    *) echo "Invalid method: $_method" >&2; rm -f "$_tmp_body"; return 2 ;;
  esac
  local _status
  _status=$(curl "${_args[@]}")
  _RES_STATUS="$_status"
  _RES_BODY=$(cat "$_tmp_body")
  rm -f "$_tmp_body"
}

run_test() {
  local _name="$1"; shift
  local _method="$1"; shift
  local _url="$1"; shift
  local _expect="${1-}"; if [ $# -gt 0 ]; then shift; fi
  local _data="${1-}"
  _request "$_method" "$_url" "$_data"
  TOTAL_COUNT=$((TOTAL_COUNT+1))
  local _ok=true
  if [ "$_RES_STATUS" != "200" ]; then
    _ok=false
  fi
  if [ "$_ok" = true ] && [ -n "$_expect" ]; then
    echo "$_RES_BODY" | grep -Fzq -- "$_expect" || _ok=false
  fi
  if [ "$_ok" = true ]; then
    PASS_COUNT=$((PASS_COUNT+1))
    printf "%s%s ✓%s\n" "$_GREEN" "$_name" "$_RESET"
  else
    FAIL_COUNT=$((FAIL_COUNT+1))
    printf "%s%s ✗%s (status %s)\n" "$_RED" "$_name" "$_RESET" "$_RES_STATUS"
  fi
}

run_status() {
  local _name="$1"; shift
  local _method="$1"; shift
  local _url="$1"; shift
  local _expected_status="$1"; shift
  local _expect="${1-}"; if [ $# -gt 0 ]; then shift; fi
  local _data="${1-}"
  _request "$_method" "$_url" "$_data"
  TOTAL_COUNT=$((TOTAL_COUNT+1))
  local _ok=true
  if [ "$_RES_STATUS" != "$_expected_status" ]; then
    _ok=false
  fi
  if [ "$_ok" = true ] && [ -n "$_expect" ]; then
    echo "$_RES_BODY" | grep -Fzq -- "$_expect" || _ok=false
  fi
  if [ "$_ok" = true ]; then
    PASS_COUNT=$((PASS_COUNT+1))
    printf "%s%s ✓%s\n" "$_GREEN" "$_name" "$_RESET"
  else
    FAIL_COUNT=$((FAIL_COUNT+1))
    printf "%s%s ✗%s (status %s)\n" "$_RED" "$_name" "$_RESET" "$_RES_STATUS"
  fi
}

print_summary_and_exit() {
  printf "\nSummary: %d total, %d passed, %d failed\n" "$TOTAL_COUNT" "$PASS_COUNT" "$FAIL_COUNT"
  if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
  fi
}