#!/usr/bin/env bash
set -e

NOTIFIER_URL="http://localhost:8082/api/notifier/messages"
WIREMOCK_ADMIN_URL="http://localhost:9090/__admin/requests"

source "$(dirname "$0")/../_helpers.sh"
init_report

# Reset WireMock request log before testing
curl -sS -X DELETE "$WIREMOCK_ADMIN_URL" > /dev/null

# ── SMS flow ────────────────────────────────────────────────────────────────

# Send SMS message via notifier
TOTAL_COUNT=$((TOTAL_COUNT+1))
_status=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "$NOTIFIER_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "E2E Test",
    "content": "e2e-sms-test-marker",
    "sender": "test@sundsvall.se",
    "recipientEmployeeIds": [1, 2, 3],
    "messageType": "SMS"
  }')
if [ "$_status" = "204" ]; then
  PASS_COUNT=$((PASS_COUNT+1))
  printf "%sSendSmsViaNotifier ✓%s\n" "$_GREEN" "$_RESET"
else
  FAIL_COUNT=$((FAIL_COUNT+1))
  printf "%sSendSmsViaNotifier ✗%s (status %s)\n" "$_RED" "$_RESET" "$_status"
fi

# Give notifier a moment to process
sleep 2

# Verify WireMock received /sendSms with correct content
TOTAL_COUNT=$((TOTAL_COUNT+1))
_body=$(curl -sS "$WIREMOCK_ADMIN_URL")
if echo "$_body" | grep -Fq "sendSms" && echo "$_body" | grep -Fq "e2e-sms-test-marker"; then
  PASS_COUNT=$((PASS_COUNT+1))
  printf "%sWireMockReceivedSms ✓%s\n" "$_GREEN" "$_RESET"
else
  FAIL_COUNT=$((FAIL_COUNT+1))
  printf "%sWireMockReceivedSms ✗%s (sendSms not found in WireMock log)\n" "$_RED" "$_RESET"
fi

# Reset WireMock request log between tests
curl -sS -X DELETE "$WIREMOCK_ADMIN_URL" > /dev/null

# ── Teams flow ──────────────────────────────────────────────────────────────

# Send Teams message via notifier
TOTAL_COUNT=$((TOTAL_COUNT+1))
_status=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "$NOTIFIER_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "E2E Test",
    "content": "e2e-teams-test-marker",
    "sender": "test@sundsvall.se",
    "recipientEmployeeIds": [1],
    "messageType": "TEAMS"
  }')
if [ "$_status" = "204" ]; then
  PASS_COUNT=$((PASS_COUNT+1))
  printf "%sSendTeamsViaNotifier ✓%s\n" "$_GREEN" "$_RESET"
else
  FAIL_COUNT=$((FAIL_COUNT+1))
  printf "%sSendTeamsViaNotifier ✗%s (status %s)\n" "$_RED" "$_RESET" "$_status"
fi

# Give notifier a moment to process
sleep 2

# Verify WireMock received /chats and message with correct content
TOTAL_COUNT=$((TOTAL_COUNT+1))
_body=$(curl -sS "$WIREMOCK_ADMIN_URL")
if echo "$_body" | grep -Fq "chats" && echo "$_body" | grep -Fq "e2e-teams-test-marker"; then
  PASS_COUNT=$((PASS_COUNT+1))
  printf "%sWireMockReceivedTeams ✓%s\n" "$_GREEN" "$_RESET"
else
  FAIL_COUNT=$((FAIL_COUNT+1))
  printf "%sWireMockReceivedTeams ✗%s (chats not found in WireMock log)\n" "$_RED" "$_RESET"
fi

print_summary_and_exit