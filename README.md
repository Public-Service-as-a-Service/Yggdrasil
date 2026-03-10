# Yggdrasil

Yggdrasil deploys all backend microservices and databases for the crisis information system — spin up the full stack with a single command.

## Services & Ports

| Service | Port | Purpose |
|---|---|---|
| api-service-notifier | 8082 | Sends notifications via SMS and Teams |
| api-service-webappusers | 8081 | Manages web app users and authentication |
| api-service-sms-sender | internal | Sends SMS via Telia and Linkmobility |
| api-service-teams-sender | internal | Sends messages via Microsoft Teams |
| csv-filereader | internal | Imports organization and employee data from CSV |
| MariaDB | internal | notifier and users databases |
| WireMock (mock only) | 9090 | Mocks external SMS and Teams APIs |

## Requirements

- Docker

## Quick Start

### Production
```bash
git clone git@github.com:Public-Service-as-a-Service/Yggdrasil.git
cd Yggdrasil
docker compose up -d
```

### Mock (local development)
Starts the full stack with WireMock replacing external SMS and Teams APIs. Includes mock CSV data with 12 employees and 5 organizations. Uses a separate database volume (`db_data_mock`) so production data is never affected.
```bash
docker compose -f docker-compose.yml -f docker-compose.mock.yml up -d
```

To stop and clean up the mock database:
```bash
docker compose down --remove-orphans -v
```

## Configuration

### Production
Copy and fill in the required environment files:
```
config/frontend/.env-notifier
config/frontend/.env-webappusers
config/frontend/.env-smssender
config/frontend/.env-teams-sender
config/frontend/.env-csv-filereader
```

### Mock
Mock environment files are included in the repo and require no configuration:
```
config/frontend/mock-notifier.env
config/frontend/mock-smssender.env
config/frontend/mock-teams-sender.env
```

## WireMock Tests

With the mock stack running, verify that all WireMock endpoints respond correctly:

```bash
# Run all test suites
bash config/wiremock/tests/run_all.sh

# Run a specific suite
bash config/wiremock/tests/run_all.sh sms
bash config/wiremock/tests/run_all.sh teams
```

See [config/wiremock/tests/README.md](config/wiremock/tests/README.md) for more details.

## Logs & Troubleshooting
```bash
# Tail all logs
docker compose logs -f

# Tail a specific service
docker compose logs -f api-service-notifier

# Check running services
docker compose ps
```
