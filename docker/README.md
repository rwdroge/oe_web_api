# Docker Deployment Scripts

This directory contains Docker-related files for deploying the OpenEdge Web API with full observability stack.

## Quick Reference

### Deployment Scripts

- **`deploy.sh`** - Deploy the entire stack
- **`stop.sh`** - Stop all services
- **`logs.sh`** - View service logs
- **`health-check.sh`** - Check health of all services

### Usage

```bash
# Deploy everything
./docker/deploy.sh

# View logs
./docker/logs.sh [service-name]
./docker/logs.sh pasoe1
./docker/logs.sh all

# Check health
./docker/health-check.sh

# Stop everything
./docker/stop.sh
```

## Directory Structure

```
docker/
├── deploy.sh              # Main deployment script
├── stop.sh                # Stop all services
├── logs.sh                # Log viewer
├── health-check.sh        # Health check script
├── README.md              # This file
│
├── pasoe/                 # PASOE configuration
│   ├── Dockerfile         # PASOE image (based on actual image)
│   ├── startup.sh         # PASOE startup script (legacy)
│   └── configure-pasoe.sh # PASOE configuration (legacy)
│
├── database/              # Database configuration
│   ├── Dockerfile         # Database image (based on actual image)
│   ├── init-db.sh         # Database initialization (legacy)
│   └── startup-db.sh      # Database startup (legacy)
│
├── traefik/               # Traefik load balancer
│   └── dynamic.yml        # Dynamic configuration
│
├── otel/                  # OpenTelemetry Collector
│   └── otel-collector-config.yaml
│
├── fluent-bit/            # Fluent Bit log aggregation
│   ├── fluent-bit.conf    # Main configuration
│   ├── parsers.conf       # Log parsers
│   └── otel_transform.lua # OpenTelemetry transformation
│
├── prometheus/            # Prometheus metrics
│   └── prometheus.yml     # Scrape configuration
│
└── grafana/               # Grafana dashboards
    └── provisioning/
        ├── datasources/
        │   └── datasources.yml
        └── dashboards/
            └── dashboards.yml
```

## Configuration Files

### Main Configuration
- `../docker-compose.yml` - Main orchestration file
- `../.env.docker` - Environment variables template

### Application Configuration
- `../conf/otelconfig.json` - PASOE 1 OpenTelemetry config
- `../conf/otelconfig-pas2.json` - PASOE 2 OpenTelemetry config
- `../conf/otelconfig-db.json` - Database OpenTelemetry config
- `../conf/openedge.properties` - OpenEdge properties
- `../conf/as.pf` - Application server parameters

## Services

The deployment includes:

1. **Traefik** - Load balancer (ports 80, 443, 8080)
2. **PASOE Instance 1** - Web API server
3. **PASOE Instance 2** - Web API server
4. **OpenEdge Database** - Sports2020 database (ports 10000-10010)
5. **OpenTelemetry Collector** - Telemetry collection (ports 4317, 4318)
6. **Fluent Bit** - Log aggregation
7. **Jaeger** - Trace visualization (port 16686)
8. **Prometheus** - Metrics storage (port 9090)
9. **Grafana** - Dashboards (port 3000)

## Networks

- **frontend** - Traefik ↔ PASOE
- **backend** - PASOE ↔ Database
- **observability** - All ↔ Monitoring stack

## Volumes

- **db-data** - Database files
- **otel-logs** - OpenTelemetry logs
- **fluent-bit-logs** - Fluent Bit state
- **prometheus-data** - Prometheus metrics
- **grafana-data** - Grafana dashboards
- **traefik-certs** - TLS certificates

## Notes

- The PASOE and Database Dockerfiles use the actual images from your devcontainer setup
- Startup scripts in `pasoe/` and `database/` directories are legacy and not used (images have built-in startup logic)
- All configuration is mounted as read-only volumes
- Logs are written to `../logs/` directory

For detailed deployment instructions, see `../DOCKER_DEPLOYMENT.md`
