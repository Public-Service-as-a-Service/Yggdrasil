#!/usr/bin/env bash
set -e

BASE_URL="http://localhost:9090"

source "$(dirname "$0")/../_helpers.sh"
init_report

# Token endpoint - kräver application/x-www-form-urlencoded
TOTAL_COUNT=$((TOTAL_COUNT+1))
_status=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=mock&client_secret=mock")
if [ "$_status" = "200" ]; then
  PASS_COUNT=$((PASS_COUNT+1))
  printf "%sGetToken ✓%s\n" "$_GREEN" "$_RESET"
else
  FAIL_COUNT=$((FAIL_COUNT+1))
  printf "%sGetToken ✗%s (status %s)\n" "$_RED" "$_RESET" "$_status"
fi

# Send SMS - kräver Authorization header
TOTAL_COUNT=$((TOTAL_COUNT+1))
_status=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/sendSms" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer mock-token-123456789" \
  -d '{"originator":"Sundsvall","destinationNumber":"+46701234567","message":"Test","deliveryPriority":"high"}')
if [ "$_status" = "200" ]; then
  PASS_COUNT=$((PASS_COUNT+1))
  printf "%sSendSms ✓%s\n" "$_GREEN" "$_RESET"
else
  FAIL_COUNT=$((FAIL_COUNT+1))
  printf "%sSendSms ✗%s (status %s)\n" "$_RED" "$_RESET" "$_status"
fi

print_summary_and_exit