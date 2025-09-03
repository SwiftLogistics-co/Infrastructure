# SwiftTrack Infrastructure Setup Guide

This document explains how to set up and run the local development infrastructure for the SwiftLogistics project.

---

## 1. Overview

The `Infrastructure` repository provides the following services for local development:

| Service       | Purpose |
|---------------|---------|
| **PostgreSQL** | Stores orders, vehicles, routes, and other persistent data |
| **Redis**      | Caching and Celery backend for asynchronous tasks |
| **Redpanda**   | Kafka-compatible message broker for event-driven microservices |
| **Kafka UI**   | Monitor Kafka topics and events via a web interface |
| **Keycloak**   | Authentication and authorization for clients and drivers |

---

## 2. Prerequisites

- [Docker](https://www.docker.com/get-started)  
- [Docker Compose](https://docs.docker.com/compose/)  
- Git  

**Optional:** `psql` or Redis client to view data.

---

## 3. Setup Steps

### 3.1 Clone the repository

```bash
git clone https://github.com/SwiftLogistics-co/Infrastructure.git
cd Infrastructure
```

### 3.2 Configure environment variables

```bash
cp .env.example .env
```

Edit `.env` to update credentials or ports if needed.

### 3.3 Start the infrastructure

```bash
docker compose up -d --build
```

This starts:
- **PostgreSQL** → `localhost:5432`
- **Redis** → `localhost:6379`
- **Redpanda** → `localhost:9092`
- **Kafka UI** → `http://localhost:8081`
- **Keycloak** → `http://localhost:8080`

---

## 4. Initialize Infrastructure

### 4.1 Initialize PostgreSQL

```bash
bash scripts/init-db.sh
```

### 4.2 Create Kafka topics

```bash
bash scripts/create-kafka-topics.sh
```

---

## 5. Keycloak Setup

1. Import `keycloak/realm-export.json` to pre-configure users, clients, and roles
2. **Default admin login:** `admin` / `admin` (as set in `.env`)
3. **Access Keycloak Admin Console:** `http://localhost:8080`

---

## 6. Connecting Microservices

All services run on the same Docker network. Use these hostnames:

| Service | Hostname / Port |
|---------|----------------|
| **PostgreSQL** | `postgres:5432` |
| **Redis** | `redis:6379` |
| **Redpanda** | `redpanda:9092` |
| **Keycloak** | `keycloak:8080` |

Microservices only need environment variables pointing to these hostnames; no code changes required.

---

## 7. Verification & Testing

### 7.1 Check service status

```bash
docker compose ps
```

### 7.2 View service logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f <service_name>
```

### 7.3 Test connections

**PostgreSQL:**
```bash
# Using psql (if installed)
psql -h localhost -p 5432 -U postgres -d swifttrack

# Or using Docker
docker compose exec postgres psql -U postgres -d swifttrack
```

**Redis:**
```bash
# Using redis-cli (if installed)
redis-cli -h localhost -p 6379

# Or using Docker
docker compose exec redis redis-cli
```

**Kafka UI:**
Open `http://localhost:8081` in your browser to monitor topics and events.

---

## 8. Common Operations

### 8.1 Stop all services

```bash
docker compose down
```

### 8.2 Stop and remove volumes (⚠️ This deletes all data)

```bash
docker compose down -v
```

### 8.3 Restart specific service

```bash
docker compose restart <service_name>
```

### 8.4 Update service images

```bash
docker compose pull
docker compose up -d --build
```

---

## 9. Troubleshooting

### 9.1 Port conflicts

If you encounter port conflicts, edit the `.env` file to use different ports:

```bash
# Example: Change PostgreSQL port
POSTGRES_PORT=5433
```

Then restart the services:

```bash
docker compose down
docker compose up -d
```

### 9.2 Service won't start

Check the logs for the specific service:

```bash
docker compose logs <service_name>
```

### 9.3 Clear all data and restart

```bash
docker compose down -v
docker compose up -d --build
bash scripts/init-db.sh
bash scripts/create-kafka-topics.sh
```

---

## 10. Development Notes

- **Persistent data** is stored in `./data/` directory
- **Docker containers** can be restarted without losing data
- **Kafka events** can be monitored via Kafka UI (`http://localhost:8081`)
- **Database schema changes** should be applied through migration scripts
- **Service discovery** works automatically within the Docker network

---

## 11. File Structure Reference

```
swift-infra/
├── docker-compose.yml          # Main service definitions
├── .env                        # Environment configuration
├── .env.example               # Template for environment variables
├── data/                      # Persistent data volumes
│   ├── postgres/
│   ├── redis/
│   └── redpanda/
├── scripts/                   # Initialization scripts
│   ├── init-db.sh
│   └── create-kafka-topics.sh
├── keycloak/                  # Authentication configuration
│   └── realm-export.json
└── docs/
    └── infra-setup.md        # This document
```

---

## 12. Next Steps

After setting up the infrastructure:

1. **Start your microservices** (ROS, CMS, ESB)
2. **Configure service connections** using the hostnames from Section 6
3. **Import Keycloak realm** for authentication setup
4. **Monitor services** using Kafka UI and logs
5. **Run integration tests** to verify everything works together