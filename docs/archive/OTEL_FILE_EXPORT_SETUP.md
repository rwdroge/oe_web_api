# OpenTelemetry File Export Setup

## Overview
The OpenTelemetry Collector is configured to export telemetry data **only to OTLP/JSON files**. Alternative observability targets (Jaeger, Prometheus, Grafana) are commented out for potential later use.

## Current Configuration

### Active Exporters
✅ **File Exporters Only**
- `file/traces` → `/var/log/otel/traces.jsonl`
- `file/metrics` → `/var/log/otel/metrics.jsonl`
- `file/logs` → `/var/log/otel/logs.jsonl`

### Commented Out (Available for Later)
💤 **Alternative Exporters**
- `otlp/jaeger` - Distributed tracing UI
- `prometheus` - Metrics storage and querying
- `logging` - Console logging for debugging

## File Locations

| Signal | File Path | Format |
|--------|-----------|--------|
| Traces | `/var/log/otel/traces.jsonl` | OTLP/JSON (ResourceSpans) |
| Metrics | `/var/log/otel/metrics.jsonl` | OTLP/JSON (ResourceMetrics) |
| Logs | `/var/log/otel/logs.jsonl` | OTLP/JSON (ResourceLogs) |

## Quick Start

### 1. Start the Collector
```bash
# Using the script
./scripts/start-observability.sh

# Or using docker-compose directly
docker-compose -f docker-compose-observability.yaml up -d
```

### 2. Verify Collector is Running
```bash
# Check health
curl http://localhost:13133

# Check collector logs
docker logs otel-collector
```

### 3. Generate Test Data
```bash
# Make API calls to generate telemetry
curl http://localhost:8810/web/api/data/customers
curl http://localhost:8810/web/api/meta/customers
```

### 4. View OTLP Files
```bash
# View traces (with jq for pretty printing)
tail -f /var/log/otel/traces.jsonl | jq .

# View metrics
tail -f /var/log/otel/metrics.jsonl | jq .

# View logs
tail -f /var/log/otel/logs.jsonl | jq .

# View raw (without jq)
tail -f /var/log/otel/traces.jsonl
```

## Collector Endpoints

| Endpoint | Port | Purpose |
|----------|------|---------|
| OTLP gRPC | 4317 | Receive telemetry via gRPC |
| OTLP HTTP | 4318 | Receive telemetry via HTTP |
| Health Check | 13133 | Collector health status |
| Metrics | 8888 | Collector's own metrics |
| zPages | 55679 | Debugging pages |

## Enabling Alternative Exporters

If you want to enable Jaeger, Prometheus, or Grafana later:

### 1. Update Collector Config
Edit `conf/otel-collector-config.yaml`:

```yaml
exporters:
  # Uncomment the exporters you want
  otlp/jaeger:
    endpoint: localhost:4317
    # ... rest of config
  
  prometheus:
    endpoint: "0.0.0.0:8889"
    # ... rest of config
  
  logging:
    loglevel: info
    # ... rest of config

service:
  pipelines:
    traces:
      exporters: [file/traces, otlp/jaeger, logging]  # Add to list
    metrics:
      exporters: [file/metrics, prometheus, logging]  # Add to list
    logs:
      exporters: [file/logs, logging]  # Add to list
```

### 2. Update Docker Compose
Edit `docker-compose-observability.yaml`:

```yaml
# Uncomment the services you want
services:
  jaeger:
    # ... uncomment entire service
  
  prometheus:
    # ... uncomment entire service
  
  grafana:
    # ... uncomment entire service

# Uncomment volumes section
volumes:
  jaeger-data:
    driver: local
  # ... etc
```

### 3. Restart
```bash
docker-compose -f docker-compose-observability.yaml down
docker-compose -f docker-compose-observability.yaml up -d
```

## File Format Details

### OTLP/JSON Format
- **Standard**: OpenTelemetry Protocol in JSON encoding
- **Structure**: JSON Lines (one complete OTLP object per line)
- **Specification**: https://opentelemetry.io/docs/specs/otlp/

### Example Trace Line
```json
{"resourceSpans":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"oe-web-api-pasoe"}}]},"scopeSpans":[{"spans":[{"traceId":"5b8aa5a2d2c872e8321cf37308d69df2","spanId":"051581bf3cb55c13","name":"GET /web/api/data/customers","startTimeUnixNano":"1606240000000000000","endTimeUnixNano":"1606240000100000000"}]}]}]}
```

### File Rotation
Files automatically rotate when:
- Size exceeds 100 MB
- Keeps last 7 days
- Maintains 3 backup files

## MongoDB Persistence Service

Your separate service should:

1. **Monitor** the three `.jsonl` files
2. **Parse** each line as OTLP/JSON
3. **Persist** to MongoDB collections
4. **Run** continuously with your AI agent

See `docs/OTEL_MONGODB_SERVICE_SPEC.md` for full specification.

## Troubleshooting

### No Files Being Created

**Check collector is running:**
```bash
docker ps | grep otel-collector
```

**Check collector logs:**
```bash
docker logs otel-collector
```

**Check file permissions:**
```bash
ls -la /var/log/otel/
```

### Files Empty

**Generate test traffic:**
```bash
curl http://localhost:8810/web/api/data/customers
```

**Check PASOE is sending data:**
```bash
# Check PASOE logs for OTLP messages
tail -f /opt/oe_web_api/pas1/logs/pas1.agent.log | grep -i otel
```

**Verify collector is receiving:**
```bash
# Check collector metrics
curl http://localhost:8888/metrics | grep otelcol_receiver
```

### Collector Not Starting

**Check Docker:**
```bash
docker info
```

**Check ports available:**
```bash
netstat -an | grep -E '4317|4318|13133'
```

**Check config syntax:**
```bash
# Validate YAML
docker run --rm -v $(pwd)/conf:/conf \
  otel/opentelemetry-collector-contrib:latest \
  validate --config=/conf/otel-collector-config.yaml
```

## Monitoring

### Check Collector Health
```bash
curl http://localhost:13133
# Should return: {"status":"Server available"}
```

### Check Collector Metrics
```bash
# View all metrics
curl http://localhost:8888/metrics

# Check received spans
curl http://localhost:8888/metrics | grep otelcol_receiver_accepted_spans

# Check exported spans
curl http://localhost:8888/metrics | grep otelcol_exporter_sent_spans
```

### Check File Sizes
```bash
# Monitor file growth
watch -n 1 'ls -lh /var/log/otel/'

# Check line counts
wc -l /var/log/otel/*.jsonl
```

## Performance

### Current Settings
- **Batch Size**: 1024 records
- **Batch Timeout**: 10 seconds
- **Memory Limit**: 512 MB
- **File Rotation**: 100 MB per file

### Tuning for High Volume
If you have high telemetry volume, adjust in `otel-collector-config.yaml`:

```yaml
processors:
  batch:
    timeout: 5s              # Faster batching
    send_batch_size: 2048    # Larger batches
  
  memory_limiter:
    limit_mib: 1024          # More memory
```

## Documentation

- **Full Specification**: `docs/OTEL_MONGODB_SERVICE_SPEC.md`
- **Integration Guide**: `OTEL_MONGODB_INTEGRATION.md`
- **Deployment Updates**: `DEPLOYMENT_SCRIPT_UPDATES.md`
- **Quick Start**: `OPENTELEMETRY_QUICKSTART.md`

## Summary

✅ **What's Active:**
- OpenTelemetry Collector receiving on ports 4317/4318
- File exporters writing OTLP/JSON to `/var/log/otel/*.jsonl`
- Health check on port 13133

💤 **What's Available (Commented Out):**
- Jaeger UI for trace visualization
- Prometheus for metrics storage
- Grafana for dashboards
- Console logging for debugging

🎯 **Next Steps:**
1. Start collector: `./scripts/start-observability.sh`
2. Generate traffic: `curl http://localhost:8810/web/api/data/customers`
3. View files: `tail -f /var/log/otel/traces.jsonl | jq .`
4. Create your MongoDB persistence service
5. Enable alternative exporters if needed
