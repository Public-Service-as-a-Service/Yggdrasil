# WireMock Tests

This folder contains test suites that validate the WireMock mock endpoints for SMS and Teams, as well as end-to-end tests that verify the full message flow through the stack.

- Test suites: `tests/*/tests.sh`
- Shared helpers: `tests/_helpers.sh`
- Aggregator: `tests/run_all.sh`

## Prerequisites

- Docker (for WireMock)
- Bash
- The mock stack must be running: `docker compose -f docker-compose.yml -f docker-compose.mock.yml up -d`

## Run the Tests

Run all suites:
```bash
bash config/wiremock/tests/run_all.sh
```

Run a specific suite:
```bash
bash config/wiremock/tests/run_all.sh sms
bash config/wiremock/tests/run_all.sh teams
bash config/wiremock/tests/run_all.sh e2e
```

Stop on first failing suite:
```bash
bash config/wiremock/tests/run_all.sh --fail-fast
```

## Test Suites

### sms
Validates the WireMock SMS mappings directly — token endpoint and sendSms endpoint.

### teams
Validates the WireMock Teams mappings directly — fetching sender/recipient users, creating a chat and sending a message.

### e2e
Sends a real message via the notifier API and verifies that WireMock received the expected downstream calls. Requires the full mock stack to be running including notifier, sms-sender and teams-sender.

## Output

```
Running 3 suite(s): sms teams e2e

[1/3] sms
GetToken ✓
SendSms ✓
Summary: 2 total, 2 passed, 0 failed
sms ✓

[2/3] teams
GetMe ✓
GetUser ✓
CreateChat ✓
SendMessage ✓
Summary: 4 total, 4 passed, 0 failed
teams ✓

[3/3] e2e
SendSmsViaNotifier ✓
WireMockReceivedSms ✓
SendTeamsViaNotifier ✓
WireMockReceivedTeams ✓
Summary: 4 total, 4 passed, 0 failed
e2e ✓

Suites summary: 3 total, 3 passed, 0 failed
```

## Adding a New Test Suite

1. Create a folder and script: `tests/<servicename>/tests.sh`
2. Use this template:

```bash
#!/usr/bin/env bash
set -e

BASE_URL="http://localhost:9090"

source "$(dirname "$0")/../_helpers.sh"
init_report

run_test "MyTest" GET "$BASE_URL/my-endpoint" "expected-substring"

print_summary_and_exit
```

3. Add any needed mappings under `mappings/` in the WireMock config.
4. Run `bash config/wiremock/tests/run_all.sh` to include it automatically.

## Helper API

- `run_test name METHOD URL [expected-substring] [data]` — asserts HTTP 200 and optionally that the body contains the expected substring.
- `run_status name METHOD URL expected-status [expected-substring] [data]` — asserts a specific status code and optional substring.
