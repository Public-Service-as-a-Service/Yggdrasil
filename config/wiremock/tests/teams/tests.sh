#!/usr/bin/env bash
set -e

BASE_URL="http://localhost:9090"

source "$(dirname "$0")/../_helpers.sh"
init_report

# Get sender user
run_test "GetMe" GET "$BASE_URL/me" "mock-sender-id"

# Get recipient user
run_test "GetUser" GET "$BASE_URL/users/mock.recipient@sundsvall.se" "mock-recipient-id"

# Create chat
run_status "CreateChat" POST "$BASE_URL/chats" 201 "mock-chat-id-123" \
  '{"chatType":"oneOnOne","members":[]}'

# Send message
run_status "SendMessage" POST "$BASE_URL/chats/mock-chat-id-123/messages" 201 "mock-message-id-123" \
  '{"body":{"content":"Test"}}'

print_summary_and_exit