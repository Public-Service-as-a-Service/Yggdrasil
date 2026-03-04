# Yggdrasil

Yggdrasil deploys all backend microservices and databases for the crisis information system — spin up the full stack with a single command.

## Services & Ports

| Service | Port | Purpose |
|---|---|---|
| api-service-notifier | 8082 | Sends notifications via SMS and Teams |
| api-service-webappusers | 8081 | Manages web app users and authentication |
| api-service-sms-sender | - | Sends SMS via Telia and Linkmobility |
| api-service-teams-sender | - | Sends messages via Microsoft Teams |
| csv-filereader | - | Imports organization and employee data from CSV |
| MariaDB | 3306 | notifier and users databases |

## Requirements

- Docker

## Quick Start
```bash
git clone git@github.com:Public-Service-as-a-Service/Yggdrasil.git
cd Yggdrasil
docker compose up -d
```

## Configuration

Copy and fill in the required environment files:
```
config/frontend/.env-notifier
config/frontend/.env-webappusers
config/frontend/.env-smssender
config/frontend/.env-teams-sender
config/frontend/.env-csv-filereader
```

## Logs & Troubleshooting
```bash
# Tail all logs
docker compose logs -f

# Tail a specific service
docker compose logs -f api-service-notifier

# Check running services
docker compose ps
```
