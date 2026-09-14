# OpenTelemetry Configuration Files Summary

## 📁 Files Created

### Configuration Files
1. **`conf/otelconfig.json`** - PASOE Instance 1 OpenTelemetry configuration
2. **`conf/otelconfig-pas2.json`** - PASOE Instance 2 OpenTelemetry configuration
3. **`conf/otelconfig-db.json`** - Database OpenTelemetry configuration
4. **`conf/otel-collector-config.yaml`** - OpenTelemetry Collector configuration
5. **`conf/prometheus.yml`** - Prometheus scrape configuration

### Docker & Scripts
6. **`docker-compose-observability.yaml`** - Complete observability stack
7. **`scripts/start-observability.sh`** - Quick start script

### Documentation
8. **`docs/OPENTELEMETRY_SETUP.md`** - Comprehensive setup guide
9. **`OPENTELEMETRY_QUICKSTART.md`** - Quick start guide

## 🎯 What Each File Does

### conf/otelconfig.json
**Purpose**: Configures OpenTelemetry for PASOE Instance 1

**Key Settings**:
- Service name: `oe-web-api-pasoe`
- Instance ID: `pasoe-instance-1`
- Collector endpoint: `http://localhost:4317` (gRPC)
- Collector endpoint: `http://localhost:4318` (HTTP)
- Traces all classes and procedures
- Enables metrics collection
- Batch processing for performance

**Used By**: PASOE Instance 1 (referenced in openedge.properties)

### conf/otelconfig-pas2.json
**Purpose**: Configures OpenTelemetry for PASOE Instance 2

**Key Settings**:
- Service name: `oe-web-api-pasoe`
- Instance ID: `pasoe-instance-2`
- Same collector endpoints as Instance 1
- Identical tracing and metrics configuration

**Used By**: PASOE Instance 2

### conf/otelconfig-db.json
**Purpose**: Configures OpenTelemetry for Sports2020 Database

**Key Settings**:
- Service name: `sports2020-database`
- Instance ID: `sports2020-db`
- Database-specific resource attributes
- Traces SQL queries and transactions
- Collects database performance metrics

**Used By**: Database server (via -otelconfig startup parameter)

### conf/otel-collector-config.yaml
**Purpose**: Configures the OpenTelemetry Collector

**What It Does**:
- Receives telemetry on ports 4317 (gRPC) and 4318 (HTTP)
- Processes and batches telemetry data
- Exports traces to Jaeger
- Exports metrics to Prometheus
- Provides logging and file backup
- Includes health checks and debugging endpoints

**Used By**: OpenTelemetry Collector container

### conf/prometheus.yml
**Purpose**: Configures Prometheus to scrape metrics

**What It Does**:
- Scrapes OpenTelemetry Collector metrics
- Scrapes PASOE instance metrics
- Scrapes Jaeger and Grafana metrics
- Defines scrape intervals and targets

**Used By**: Prometheus container

### docker-compose-observability.yaml
**Purpose**: Defines complete observability stack

**Services Included**:
- **otel-collector**: Receives and processes telemetry
- **jaeger**: Distributed tracing backend and UI
- **prometheus**: Metrics storage and querying
- **grafana**: Visualization and dashboards
- **loki**: Log aggregation (optional)
- **promtail**: Log collection (optional)

**Ports Exposed**:
- 4317/4318: OpenTelemetry Collector
- 16686: Jaeger UI
- 9090: Prometheus UI
- 3000: Grafana UI

### scripts/start-observability.sh
**Purpose**: Quick start script for observability stack

**What It Does**:
- Starts all Docker containers
- Waits for services to be ready
- Checks health of each service
- Displays access URLs

## 🔄 Data Flow

```
┌─────────────────┐
│  PASOE Inst 1   │
│  (otelconfig    │
│   .json)        │
└────────┬────────┘
         │
         │ Traces & Metrics
         │ (OTLP/gRPC:4317)
         ▼
┌─────────────────┐
│  PASOE Inst 2   │
│  (otelconfig    │
│   -pas2.json)   │
└────────┬────────┘
         │
         │ Traces & Metrics
         │ (OTLP/HTTP:4318)
         ▼
┌─────────────────┐    ┌──────────────────┐
│  Sports2020 DB  │───▶│  OpenTelemetry   │
│  (otelconfig    │    │    Collector     │
│   -db.json)     │    │  (otel-collector │
└─────────────────┘    │   -config.yaml)  │
                       └────────┬─────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
                    ▼                       ▼
            ┌──────────────┐       ┌──────────────┐
            │    Jaeger    │       │  Prometheus  │
            │   (Traces)   │       │  (Metrics)   │
            └──────┬───────┘       └──────┬───────┘
                   │                      │
                   └──────────┬───────────┘
                              ▼
                      ┌──────────────┐
                      │   Grafana    │
                      │ (Dashboards) │
                      └──────────────┘
```

## 🚀 Quick Setup Commands

### 1. Start Observability Stack
```bash
chmod +x scripts/start-observability.sh
./scripts/start-observability.sh
```

### 2. Deploy PASOE Configs
```bash
# Instance 1
cp conf/otelconfig.json /opt/oe_web_api/pas1/conf/

# Instance 2
cp conf/otelconfig-pas2.json /opt/oe_web_api/pas2/conf/otelconfig.json
```

### 3. Restart PASOE
```bash
cd /opt/oe_web_api/pas1/bin && ./tcman restart
cd /opt/oe_web_api/pas2/bin && ./tcman restart
```

### 4. Update Database Startup
Add to `scripts/start_db.sh`:
```bash
-otelconfig /opt/oe_web_api/conf/otelconfig-db.json
```

## 📊 What Gets Collected

### From PASOE Instances
- ✅ HTTP request traces (full lifecycle)
- ✅ ABL procedure/class execution spans
- ✅ Database query spans
- ✅ Request count, duration, errors
- ✅ Agent pool metrics
- ✅ Memory usage metrics
- ✅ Session metrics

### From Database
- ✅ SQL query traces
- ✅ Transaction traces
- ✅ Connection pool metrics
- ✅ Buffer pool metrics
- ✅ Lock metrics
- ✅ I/O metrics

## 🎛️ Configuration Options

### Sampling Rate
Control how many traces are captured:

```json
"sampler": {
    "type": "traceidratio",
    "probability": 0.1  // 10% sampling
}
```

**Options**:
- `always_on`: Capture all traces (development)
- `always_off`: Capture no traces
- `traceidratio`: Capture percentage (production)
- `parentbased_always_on`: Follow parent decision

### Batch Processing
Control performance vs latency:

```json
"batch_processor_options": {
    "max_queue_size": 2048,        // Max spans in queue
    "schedule_delay": 5000,         // Wait 5s before export
    "max_export_batch_size": 512,  // Max spans per batch
    "export_timeout": 30000         // Timeout for export
}
```

### What to Trace
Control what gets traced:

```json
"trace_classes": "*",              // All classes or specific ones
"trace_procedures": "*",           // All procedures or specific ones
"trace_abl_transactions": true,    // Trace transactions
"trace_database_operations": true, // Trace DB operations
"trace_external_calls": true       // Trace external APIs
```

## 🔍 Verification

### Check Collector is Running
```bash
curl http://localhost:13133
```

### Check Traces in Jaeger
1. Open http://localhost:16686
2. Select service: `oe-web-api-pasoe`
3. Click "Find Traces"

### Check Metrics in Prometheus
1. Open http://localhost:9090
2. Query: `openedge_pasoe_requests_total`

### Check PASOE Logs
```bash
tail -f /opt/oe_web_api/pas1/logs/pas1.agent.log | grep -i otel
```

## 📚 Documentation

- **Quick Start**: `OPENTELEMETRY_QUICKSTART.md`
- **Full Setup Guide**: `docs/OPENTELEMETRY_SETUP.md`
- **Deployment Guide**: `docs/PRODUCTION_DEPLOYMENT.md`

## 🆘 Troubleshooting

### No Traces Appearing
1. Check collector: `curl http://localhost:13133`
2. Check PASOE logs for errors
3. Verify otelconfig.json is loaded
4. Test collector endpoints

### High Memory Usage
- Reduce `max_queue_size`
- Reduce `max_export_batch_size`
- Increase `schedule_delay`
- Lower sampling rate

### Collector Not Starting
- Check Docker logs: `docker logs otel-collector`
- Verify YAML syntax
- Check port availability
- Verify file paths

## 🎯 Next Steps

1. **Start the stack**: Run `start-observability.sh`
2. **Deploy configs**: Copy otelconfig files to PASOE
3. **Restart PASOE**: Restart both instances
4. **Generate traffic**: Make API calls
5. **View traces**: Open Jaeger UI
6. **View metrics**: Open Prometheus UI
7. **Create dashboards**: Configure Grafana

## 🔗 Access URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| Jaeger UI | http://localhost:16686 | None |
| Prometheus | http://localhost:9090 | None |
| Grafana | http://localhost:3000 | admin/admin |
| OTel Collector Health | http://localhost:13133 | None |
| OTel Collector Metrics | http://localhost:8888/metrics | None |
