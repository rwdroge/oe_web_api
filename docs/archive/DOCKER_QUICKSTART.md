# Docker Deployment - Quick Start Guide

## Prerequisites

1. Docker and Docker Compose installed
2. Progress OpenEdge license file at `./license/progress.cfg`

## Deploy in 3 Steps

### 1. Prepare License

```bash
# Ensure your license file is in place
ls -l ./license/progress.cfg
```

### 2. Deploy

```bash
./docker/deploy.sh
```

### 3. Verify

```bash
./docker/health-check.sh
```

## Access Services

| Service | URL |
|---------|-----|
| **Web API** | http://localhost/web |
| **Traefik Dashboard** | http://localhost:8080 |
| **Jaeger (Traces)** | http://localhost:16686 |
| **Prometheus (Metrics)** | http://localhost:9090 |
| **Grafana (Dashboards)** | http://localhost:3000 |

**Grafana credentials:** admin/admin

## Common Commands

```bash
# View logs
./docker/logs.sh pasoe1
./docker/logs.sh all

# Check health
./docker/health-check.sh

# Stop everything
./docker/stop.sh

# Restart a service
docker-compose restart pasoe1
```

## Architecture

```
                    ┌─────────────┐
                    │   Traefik   │ (Load Balancer)
                    │  :80, :8080 │
                    └──────┬──────┘
                           │
              ┌────────────┴────────────┐
              │                         │
         ┌────▼────┐               ┌────▼────┐
         │ PASOE 1 │               │ PASOE 2 │
         └────┬────┘               └────┬────┘
              │                         │
              └────────────┬────────────┘
                           │
                    ┌──────▼──────┐
                    │  Database   │
                    │ :10000-10010│
                    └─────────────┘

    ┌──────────────────────────────────────┐
    │      Observability Stack             │
    ├──────────────────────────────────────┤
    │ OpenTelemetry Collector → Jaeger     │
    │ Fluent Bit → OTel Collector          │
    │ Prometheus ← OTel Collector          │
    │ Grafana ← Prometheus + Jaeger        │
    └──────────────────────────────────────┘
```

## What's Included

- **2 PASOE instances** with automatic load balancing
- **OpenEdge database** (sports2020)
- **Traefik** for load balancing and routing
- **Full observability stack:**
  - Distributed tracing (Jaeger)
  - Metrics (Prometheus)
  - Dashboards (Grafana)
  - Log aggregation (Fluent Bit)
  - Telemetry collection (OpenTelemetry)

## Troubleshooting

**Services won't start?**
```bash
docker-compose logs [service-name]
```

**Can't access web API?**
- Check Traefik dashboard: http://localhost:8080
- Verify PASOE instances are healthy: `docker-compose ps`

**Database issues?**
```bash
docker-compose exec oedb /usr/dlc/bin/proutil /app/db/sports2020 -C busy
```

## Next Steps

- See `DOCKER_DEPLOYMENT.md` for detailed documentation
- Configure Grafana dashboards at http://localhost:3000
- View traces in Jaeger at http://localhost:16686
- Monitor metrics in Prometheus at http://localhost:9090

## Clean Up

```bash
# Stop services
./docker/stop.sh

# Remove everything including volumes
docker-compose down -v
```
