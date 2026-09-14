# OpenEdge Web API - Docker Deployment Guide

This guide explains how to deploy the OpenEdge Web API application using Docker with full observability stack.

## Architecture Overview

The Docker deployment includes:

- **2 PASOE Instances** (`pasoe1`, `pasoe2`) - Running the web API application
- **OpenEdge Database** (`oedb`) - Sports2020 database
- **Traefik** - Load balancer and reverse proxy
- **OpenTelemetry Collector** - Telemetry data collection and export
- **Fluent Bit** - Log aggregation and transformation to OpenTelemetry format
- **Jaeger** - Distributed tracing UI
- **Prometheus** - Metrics storage and querying
- **Grafana** - Visualization dashboards

## Prerequisites

1. **Docker** and **Docker Compose** installed
2. **Progress OpenEdge License** file (`progress.cfg`) in the `license/` directory
3. **Docker Images** available:
   - `docker.io/rdroge/oe_db_sports2020:latest`
   - `docker.io/rdroge/oe_pas_dev:latest`

## Quick Start

### 1. Prepare License File

Ensure your Progress OpenEdge license file is in place:

```bash
cp /path/to/your/progress.cfg ./license/progress.cfg
```

### 2. Deploy the Stack

```bash
# Make deployment script executable
chmod +x docker/deploy.sh

# Run deployment
./docker/deploy.sh
```

### 3. Verify Deployment

Check that all services are running:

```bash
docker-compose ps
```

All services should show as "Up" or "healthy".

## Service URLs

Once deployed, access the following services:

| Service | URL | Credentials |
|---------|-----|-------------|
| Web API (via Traefik) | http://localhost/web | - |
| Traefik Dashboard | http://localhost:8080 | - |
| Jaeger UI | http://localhost:16686 | - |
| Prometheus | http://localhost:9090 | - |
| Grafana | http://localhost:3000 | admin/admin |
| OpenTelemetry Collector | http://localhost:13133 | - |

## Architecture Details

### Load Balancing

Traefik distributes requests between `pasoe1` and `pasoe2`:
- Round-robin load balancing
- Sticky sessions using cookies
- Health checks every 10 seconds
- Automatic failover if an instance is unhealthy

### Observability Stack

#### Traces
- PASOE instances send traces to OpenTelemetry Collector via OTLP
- Collector exports to Jaeger for visualization
- Also exports to JSON files for persistence

#### Metrics
- PASOE and database export metrics to OpenTelemetry Collector
- Collector exposes Prometheus endpoint
- Prometheus scrapes and stores metrics
- Grafana visualizes metrics from Prometheus

#### Logs
- PASOE and database logs are written to mounted volumes
- Fluent Bit tails log files and transforms them to OpenTelemetry format
- Transformed logs sent to OpenTelemetry Collector
- Collector exports to JSON files

### Network Architecture

Three Docker networks:
- **frontend**: Traefik ↔ PASOE instances
- **backend**: PASOE instances ↔ Database
- **observability**: All services ↔ OpenTelemetry/monitoring stack

## Configuration Files

### Docker Compose
- `docker-compose.yml` - Main orchestration file

### Traefik
- `docker/traefik/dynamic.yml` - Load balancer configuration

### OpenTelemetry
- `docker/otel/otel-collector-config.yaml` - Collector configuration
- `conf/otelconfig.json` - PASOE instance 1 configuration
- `conf/otelconfig-pas2.json` - PASOE instance 2 configuration
- `conf/otelconfig-db.json` - Database configuration

### Fluent Bit
- `docker/fluent-bit/fluent-bit.conf` - Main configuration
- `docker/fluent-bit/parsers.conf` - Log parsers
- `docker/fluent-bit/otel_transform.lua` - OpenTelemetry transformation script

### Prometheus
- `docker/prometheus/prometheus.yml` - Scrape configuration

### Grafana
- `docker/grafana/provisioning/datasources/datasources.yml` - Data source configuration
- `docker/grafana/provisioning/dashboards/dashboards.yml` - Dashboard provisioning

## Common Operations

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f pasoe1
docker-compose logs -f oedb
docker-compose logs -f traefik
docker-compose logs -f otel-collector
```

### Restart a Service

```bash
docker-compose restart pasoe1
docker-compose restart oedb
```

### Scale PASOE Instances

To add more PASOE instances, edit `docker-compose.yml` and add `pasoe3`, `pasoe4`, etc., following the same pattern as `pasoe1` and `pasoe2`.

### Stop All Services

```bash
# Stop services (keeps volumes)
docker-compose down

# Stop services and remove volumes
docker-compose down -v
```

### Update Application Code

The `src/` directory is mounted as read-only. To update:

1. Update your source code in `src/`
2. Restart PASOE instances:
   ```bash
   docker-compose restart pasoe1 pasoe2
   ```

## Troubleshooting

### PASOE Instance Won't Start

Check logs:
```bash
docker-compose logs pasoe1
```

Common issues:
- License file missing or invalid
- Port conflicts
- Database not ready

### Database Connection Issues

Verify database is running:
```bash
docker-compose exec oedb /usr/dlc/bin/proutil /app/db/sports2020 -C busy
```

### Traefik Not Routing Requests

Check Traefik dashboard: http://localhost:8080

Verify PASOE instances are registered:
- Go to HTTP → Routers
- Look for `pasoe` router
- Check backend servers are healthy

### OpenTelemetry Not Receiving Data

Check collector health:
```bash
curl http://localhost:13133
```

View collector logs:
```bash
docker-compose logs otel-collector
```

Verify PASOE can reach collector:
```bash
docker-compose exec pasoe1 curl -v http://otel-collector:4317
```

## Performance Tuning

### PASOE Memory

Edit `docker-compose.yml` and add memory limits:

```yaml
pasoe1:
  deploy:
    resources:
      limits:
        memory: 2G
      reservations:
        memory: 1G
```

### Database Performance

The database image comes pre-configured. For production, consider:
- Mounting database files to faster storage
- Adjusting database parameters via startup parameters
- Enabling after-image journaling for crash recovery

### OpenTelemetry Sampling

To reduce overhead, adjust sampling in `conf/otelconfig.json`:

```json
"sampler": {
    "type": "parentbased_traceidratio",
    "probability": 0.1
}
```

## Security Considerations

### Production Deployment

For production:

1. **Enable HTTPS** in Traefik:
   - Configure TLS certificates
   - Redirect HTTP to HTTPS

2. **Secure Grafana**:
   - Change default admin password
   - Configure authentication (LDAP, OAuth, etc.)

3. **Network Isolation**:
   - Use Docker secrets for sensitive data
   - Restrict network access
   - Use firewall rules

4. **Resource Limits**:
   - Set memory and CPU limits for all services
   - Configure restart policies

## Monitoring and Alerts

### Prometheus Alerts

Create alert rules in `docker/prometheus/alerts.yml`:

```yaml
groups:
  - name: openedge
    rules:
      - alert: PasoeInstanceDown
        expr: up{job="openedge-metrics"} == 0
        for: 1m
        annotations:
          summary: "PASOE instance is down"
```

### Grafana Dashboards

Import pre-built dashboards:
1. Go to Grafana (http://localhost:3000)
2. Navigate to Dashboards → Import
3. Use dashboard IDs:
   - 1860 (Node Exporter)
   - 3662 (Prometheus 2.0)
   - 13639 (Jaeger)

## Backup and Recovery

### Database Backup

```bash
# Create backup
docker-compose exec oedb /usr/dlc/bin/probkup online /app/db/sports2020 /app/backup

# Copy backup out of container
docker cp oedb:/app/backup ./backups/
```

### Configuration Backup

All configuration is in the repository. Ensure:
- `conf/` directory is backed up
- `docker/` directory is backed up
- Custom Grafana dashboards are exported

## Support

For issues or questions:
1. Check logs: `docker-compose logs [service]`
2. Verify service health: `docker-compose ps`
3. Check OpenTelemetry data flow in Jaeger UI
4. Review Prometheus metrics for anomalies
