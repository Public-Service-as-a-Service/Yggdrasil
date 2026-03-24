#!/usr/bin/env bash
set -e

NOTIFIER_URL="http://localhost:8082/api/notifier/messages"
WIREMOCK_ADMIN_URL="http://localhost:9090/__admin/requests"

source "$(dirname "$0")/../_helpers.sh"
init_report

# Reset WireMock request log before testing
curl -sS -X DELETE "$WIREMOCK_ADMIN_URL" > /dev/null

# ── SMS flow ────────────────────────────────────────────────────────────────

run_status "SendSmsViaNotifier" POST "$NOTIFIER_URL" 204 "" '{"title":"E2E Test","content":"e2e-sms-test-marker","sender":"test@sundsvall.se","recipientEmployeeIds":[1,2,3],"messageType":"SMS"}'

sleep 2

run_test "WireMockReceivedSms" GET "$WIREMOCK_ADMIN_URL" "e2e-sms-test-marker"

# Reset WireMock request log between tests
curl -sS -X DELETE "$WIREMOCK_ADMIN_URL" > /dev/null

# ── Teams flow ──────────────────────────────────────────────────────────────

run_status "SendTeamsViaNotifier" POST "$NOTIFIER_URL" 204 "" '{"title":"E2E Test","content":"e2e-teams-test-marker","sender":"test@sundsvall.se","recipientEmployeeIds":[1],"messageType":"TEAMS"}'

sleep 2

run_test "WireMockReceivedTeams" GET "$WIREMOCK_ADMIN_URL" "e2e-teams-test-marker"

print_summary_and_exit