# Deployment Script Updates - OpenTelemetry Integration

## Changes Made

The production deployment script has been updated to automatically deploy OpenTelemetry configuration files and optionally start the observability stack.

## Updated Files

### 1. `scripts/deploy-production.sh`

**New Features:**
- ✅ Automatically deploys `otelconfig.json` to PASOE Instance 1
- ✅ Automatically deploys `otelconfig-pas2.json` to PASOE Instance 2
- ✅ Optionally starts OpenTelemetry observability stack (Jaeger, Prometheus, Grafana)
- ✅ New `--skip-otel` flag to skip observability stack setup
- ✅ Enhanced deployment summary with OpenTelemetry endpoints

**New Command Line Option:**
```bash
--skip-otel    Skip OpenTelemetry stack setup
```

**What Happens During Deployment:**

**Step 3: Deploy to PASOE Instance 1**
```bash
# Deploy OpenTelemetry configuration...
cp conf/otelconfig.json /opt/oe_web_api/pas1/conf/
```

**Step 4: Deploy to PASOE Instance 2**
```bash
# Deploy OpenTelemetry configuration...
cp conf/otelconfig-pas2.json /opt/oe_web_api/pas2/conf/otelconfig.json
```

**Step 5: Setup OpenTelemetry (NEW)**
- Checks if Docker is available
- Starts OpenTelemetry Collector, Jaeger, Prometheus, and Grafana
- Displays access URLs for all services
- Can be skipped with `--skip-otel` flag

### 2. `scripts/start_db.sh`

**New Features:**
- ✅ Automatically loads `otelconfig-db.json` when starting database
- ✅ Displays OpenTelemetry status in startup message

**Changes:**
```bash
# New variable
OTEL_CONFIG="/opt/oe_web_api/conf/otelconfig-db.json"

# Added to proserve command
-otelconfig "$OTEL_CONFIG"

# Enhanced success message
✓ Database started successfully
  Port: 10000
  Location: /opt/oe_web_api/db/sports2020
  OpenTelemetry: Enabled (config: /opt/oe_web_api/conf/otelconfig-db.json)
```

## Usage Examples

### Full Deployment with OpenTelemetry
```bash
./scripts/deploy-production.sh --db-host localhost
```

This will:
1. Setup database
2. Compile application
3. Deploy to PASOE Instance 1 (with otelconfig.json)
4. Deploy to PASOE Instance 2 (with otelconfig-pas2.json)
5. Start OpenTelemetry stack (Collector, Jaeger, Prometheus, Grafana)
6. Verify deployment

### Deployment Without OpenTelemetry Stack
```bash
./scripts/deploy-production.sh --db-host localhost --skip-otel
```

This will:
1. Setup database
2. Compile application
3. Deploy to PASOE Instance 1 (with otelconfig.json)
4. Deploy to PASOE Instance 2 (with otelconfig-pas2.json)
5. Skip OpenTelemetry stack (configs still deployed)
6. Verify deployment

### Skip Database and Compilation
```bash
./scripts/deploy-production.sh --skip-db --skip-compile
```

Useful for redeployment when database and code haven't changed.

## Deployment Output

### New Output Sections

**During Deployment:**
```
Step 3: Deploying to PASOE Instance 1...
Deploying configuration...
Deploying OpenTelemetry configuration...
✓ PASOE Instance 1 deployed and started

Step 4: Deploying to PASOE Instance 2...
Deploying configuration...
Deploying OpenTelemetry configuration...
✓ PASOE Instance 2 deployed and started

Step 5: Setting up OpenTelemetry observability...
Starting OpenTelemetry stack...
✓ OpenTelemetry stack started
  - Jaeger UI: http://localhost:16686
  - Prometheus: http://localhost:9090
  - Grafana: http://localhost:3000 (admin/admin)
```

**Final Summary:**
```
========================================
Deployment Summary
========================================
Database: Running on port 10000
PASOE Instance 1: http://localhost:8810
PASOE Instance 2: http://localhost:8820

API Endpoints:
  - WEB Transport: http://localhost:8810/web/api/data/customers
  - APSV Transport: http://localhost:8810/pas/apsv

✓✓✓ Deployment completed successfully! ✓✓✓

OpenTelemetry Configuration:
  - Collector: http://localhost:4317 (gRPC), http://localhost:4318 (HTTP)
  - Jaeger UI: http://localhost:16686
  - Prometheus: http://localhost:9090
  - Grafana: http://localhost:3000 (admin/admin)

Next steps:
1. Run APSV transport tests: _progres -p test/run-all-apsv-tests.p
2. Generate traffic to see traces: curl http://localhost:8810/web/api/data/customers
3. View traces in Jaeger: http://localhost:16686
4. Configure load balancer (if applicable)
5. Set up monitoring alerts and backups
6. Review logs in pas1/logs and pas2/logs
```

## Configuration Files Deployed

| File | Deployed To | Purpose |
|------|-------------|---------|
| `conf/otelconfig.json` | `pas1/conf/otelconfig.json` | PASOE Instance 1 telemetry |
| `conf/otelconfig-pas2.json` | `pas2/conf/otelconfig.json` | PASOE Instance 2 telemetry |
| `conf/otelconfig-db.json` | Used by database startup | Database telemetry |

## OpenTelemetry Stack Components

When not using `--skip-otel`, the following services are started:

| Service | Port | Purpose | URL |
|---------|------|---------|-----|
| OpenTelemetry Collector | 4317, 4318 | Receive telemetry | http://localhost:4317 |
| Jaeger | 16686 | Distributed tracing UI | http://localhost:16686 |
| Prometheus | 9090 | Metrics storage | http://localhost:9090 |
| Grafana | 3000 | Dashboards | http://localhost:3000 |

## Verification Steps

After deployment, verify OpenTelemetry is working:

### 1. Check Config Files
```bash
# Check PASOE Instance 1
ls -l /opt/oe_web_api/pas1/conf/otelconfig.json

# Check PASOE Instance 2
ls -l /opt/oe_web_api/pas2/conf/otelconfig.json

# Check Database config
ls -l /opt/oe_web_api/conf/otelconfig-db.json
```

### 2. Check PASOE Logs
```bash
# Check if OpenTelemetry is loaded
tail -f /opt/oe_web_api/pas1/logs/pas1.agent.log | grep -i otel
```

### 3. Generate Traffic
```bash
# Make some API calls
curl http://localhost:8810/web/api/data/customers
curl http://localhost:8810/web/api/meta/customers
```

### 4. View Traces
1. Open http://localhost:16686
2. Select service: `oe-web-api-pasoe`
3. Click "Find Traces"
4. You should see traces from your API calls

### 5. View Metrics
1. Open http://localhost:9090
2. Query: `openedge_pasoe_requests_total`
3. You should see request metrics

## Troubleshooting

### OpenTelemetry Stack Fails to Start

**Issue:** Docker or Docker Compose not found
```
⚠ Docker not found, skipping OpenTelemetry stack
  To enable observability, install Docker and run:
  ./scripts/start-observability.sh
```

**Solution:**
1. Install Docker
2. Run manually: `./scripts/start-observability.sh`

### Config Files Not Deployed

**Issue:** Config files missing after deployment

**Solution:**
```bash
# Manually copy configs
cp conf/otelconfig.json /opt/oe_web_api/pas1/conf/
cp conf/otelconfig-pas2.json /opt/oe_web_api/pas2/conf/otelconfig.json

# Restart PASOE
cd /opt/oe_web_api/pas1/bin && ./tcman restart
cd /opt/oe_web_api/pas2/bin && ./tcman restart
```

### Database Not Sending Telemetry

**Issue:** Database started without OpenTelemetry config

**Solution:**
```bash
# Stop database
proshut sports2020

# Start with config
./scripts/start_db.sh
```

## Manual OpenTelemetry Setup

If you used `--skip-otel` or want to start the stack separately:

```bash
# Start observability stack
./scripts/start-observability.sh

# Or using docker-compose directly
docker-compose -f docker-compose-observability.yaml up -d

# Check status
docker-compose -f docker-compose-observability.yaml ps

# View logs
docker-compose -f docker-compose-observability.yaml logs -f

# Stop
docker-compose -f docker-compose-observability.yaml down
```

## Benefits

### Automatic Configuration
- ✅ No manual copying of config files
- ✅ Consistent configuration across instances
- ✅ Single command deployment

### Observability Out-of-the-Box
- ✅ Traces available immediately after deployment
- ✅ Metrics collection starts automatically
- ✅ Pre-configured dashboards ready to use

### Flexible Deployment
- ✅ Can skip observability stack if not needed
- ✅ Can deploy configs without starting stack
- ✅ Can start stack separately later

## Next Steps

1. **Run deployment:**
   ```bash
   ./scripts/deploy-production.sh --db-host localhost
   ```

2. **Generate traffic:**
   ```bash
   curl http://localhost:8810/web/api/data/customers
   ```

3. **View traces:**
   - Open http://localhost:16686
   - Select service: `oe-web-api-pasoe`
   - Explore your traces

4. **Create dashboards:**
   - Open http://localhost:3000 (admin/admin)
   - Add Prometheus data source
   - Add Jaeger data source
   - Create custom dashboards

5. **Set up alerts:**
   - Configure Prometheus alerting rules
   - Set up notification channels in Grafana
   - Monitor error rates and performance

## Documentation

- **Quick Start**: `OPENTELEMETRY_QUICKSTART.md`
- **Full Setup Guide**: `docs/OPENTELEMETRY_SETUP.md`
- **Files Summary**: `OPENTELEMETRY_FILES_SUMMARY.md`
- **Deployment Guide**: `docs/PRODUCTION_DEPLOYMENT.md`
