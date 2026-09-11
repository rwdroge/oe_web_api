# OpenTelemetry to MongoDB Integration

## Overview
The OpenTelemetry Collector exports telemetry data to JSON files in **OTLP/JSON format**. A separate service (to be created in another project) will read these files and persist the data to MongoDB.

## Quick Reference

### File Locations
```
/var/log/otel/traces.jsonl   - OTLP ResourceSpans (traces)
/var/log/otel/metrics.jsonl  - OTLP ResourceMetrics (metrics)
/var/log/otel/logs.jsonl     - OTLP ResourceLogs (logs)
```

### File Format
- **Format**: OTLP/JSON (JSON Lines)
- **Structure**: One complete OTLP object per line
- **Encoding**: UTF-8
- **Extension**: `.jsonl`

### MongoDB Collections
```
Database: openedge_telemetry

Collections:
  - traces   (OTLP ResourceSpans)
  - metrics  (OTLP ResourceMetrics)
  - logs     (OTLP ResourceLogs)
```

## Configuration Files

### OpenTelemetry Collector
File: `conf/otel-collector-config.yaml`

**Key Exporters:**
```yaml
exporters:
  file/traces:
    path: /var/log/otel/traces.jsonl
    format: json
  
  file/metrics:
    path: /var/log/otel/metrics.jsonl
    format: json
  
  file/logs:
    path: /var/log/otel/logs.jsonl
    format: json
```

**Pipelines:**
```yaml
service:
  pipelines:
    traces:
      exporters: [otlp/jaeger, logging, file/traces]
    metrics:
      exporters: [prometheus, logging, file/metrics]
    logs:
      exporters: [logging, file/logs]
```

## Data Flow

```
┌──────────────┐
│ PASOE Inst 1 │
│ PASOE Inst 2 │──┐
│ Database     │  │
└──────────────┘  │
                  │ OTLP/gRPC or HTTP
                  ▼
         ┌─────────────────┐
         │ OTel Collector  │
         └────────┬────────┘
                  │
        ┌─────────┼─────────┐
        │         │         │
        ▼         ▼         ▼
   ┌────────┐ ┌────────┐ ┌────────┐
   │ Jaeger │ │ Prom   │ │ Files  │
   └────────┘ └────────┘ └───┬────┘
                              │
                              │ OTLP/JSON
                              ▼
                    ┌──────────────────┐
                    │  Your Service    │
                    │  (Separate Proj) │
                    └────────┬─────────┘
                             │
                             │ Persist
                             ▼
                      ┌─────────────┐
                      │   MongoDB   │
                      │ Collections │
                      └─────────────┘
```

## OTLP/JSON Format

### Traces Example
```json
{
  "resourceSpans": [{
    "resource": {
      "attributes": [
        {"key": "service.name", "value": {"stringValue": "oe-web-api-pasoe"}},
        {"key": "service.instance.id", "value": {"stringValue": "pasoe-instance-1"}}
      ]
    },
    "scopeSpans": [{
      "spans": [{
        "traceId": "5b8aa5a2d2c872e8321cf37308d69df2",
        "spanId": "051581bf3cb55c13",
        "name": "GET /web/api/data/customers",
        "startTimeUnixNano": "1606240000000000000",
        "endTimeUnixNano": "1606240000100000000",
        "attributes": [
          {"key": "http.method", "value": {"stringValue": "GET"}},
          {"key": "http.status_code", "value": {"intValue": "200"}}
        ]
      }]
    }]
  }]
}
```

### Metrics Example
```json
{
  "resourceMetrics": [{
    "resource": {
      "attributes": [
        {"key": "service.name", "value": {"stringValue": "oe-web-api-pasoe"}}
      ]
    },
    "scopeMetrics": [{
      "metrics": [{
        "name": "openedge.pasoe.requests.total",
        "sum": {
          "dataPoints": [{
            "timeUnixNano": "1606240060000000000",
            "asInt": "42"
          }]
        }
      }]
    }]
  }]
}
```

## Service Requirements

Your separate service should:

### 1. Monitor Files
- Watch `/var/log/otel/*.jsonl` files
- Use incremental reading (track file position)
- Handle file rotation
- Process new data in < 10 seconds

### 2. Parse OTLP/JSON
- Read JSON Lines format (one object per line)
- Parse OTLP structure (ResourceSpans, ResourceMetrics, ResourceLogs)
- Extract key fields (traceId, spanId, metric names, etc.)

### 3. Persist to MongoDB
- **Traces**: Upsert by `traceId + spanId`
- **Metrics**: Upsert by `metricName + timestamp`
- **Logs**: Insert (append-only)

### 4. Run with AI Agent
- Start automatically when agent starts
- Run continuously in background
- Expose health check endpoint
- Track statistics

## MongoDB Schema

### Traces Collection
```javascript
{
  _id: "traceId-spanId",
  traceId: "5b8aa5a2d2c872e8321cf37308d69df2",
  spanId: "051581bf3cb55c13",
  serviceName: "oe-web-api-pasoe",
  name: "GET /web/api/data/customers",
  startTime: ISODate("2024-11-26T07:00:00Z"),
  duration: 100000000,
  attributes: { http.method: "GET", http.status_code: 200 },
  rawOtlp: { /* original OTLP span */ },
  ingestedAt: ISODate("2024-11-26T07:00:01Z")
}
```

### Metrics Collection
```javascript
{
  _id: "metricName-timestamp",
  metricName: "openedge.pasoe.requests.total",
  serviceName: "oe-web-api-pasoe",
  value: 42,
  timestamp: ISODate("2024-11-26T07:01:00Z"),
  rawOtlp: { /* original OTLP metric */ },
  ingestedAt: ISODate("2024-11-26T07:01:01Z")
}
```

### Logs Collection
```javascript
{
  _id: ObjectId(),
  traceId: "5b8aa5a2d2c872e8321cf37308d69df2",
  serviceName: "oe-web-api-pasoe",
  severity: "INFO",
  body: "Request processed successfully",
  timestamp: ISODate("2024-11-26T07:00:00Z"),
  rawOtlp: { /* original OTLP log */ },
  ingestedAt: ISODate("2024-11-26T07:00:01Z")
}
```

## Environment Variables

```bash
# MongoDB
MONGO_HOST=localhost
MONGO_PORT=27017
MONGO_DATABASE=openedge_telemetry

# OTLP Files
OTEL_TRACES_FILE=/var/log/otel/traces.jsonl
OTEL_METRICS_FILE=/var/log/otel/metrics.jsonl
OTEL_LOGS_FILE=/var/log/otel/logs.jsonl

# Service
POLL_INTERVAL=5000  # milliseconds
```

## Testing

### 1. Generate Test Data
```bash
# Make API calls to generate traces
curl http://localhost:8810/web/api/data/customers
curl http://localhost:8810/web/api/meta/customers
```

### 2. Check OTLP Files
```bash
# View traces
tail -f /var/log/otel/traces.jsonl | jq .

# View metrics
tail -f /var/log/otel/metrics.jsonl | jq .

# View logs
tail -f /var/log/otel/logs.jsonl | jq .
```

### 3. Verify MongoDB
```bash
# Connect to MongoDB
mongo openedge_telemetry

# Count documents
db.traces.count()
db.metrics.count()
db.logs.count()

# View recent traces
db.traces.find().sort({ingestedAt:-1}).limit(5).pretty()
```

## Documentation

- **Full Specification**: `docs/OTEL_MONGODB_SERVICE_SPEC.md`
- **OTLP Spec**: https://opentelemetry.io/docs/specs/otlp/
- **OTLP/JSON Encoding**: https://opentelemetry.io/docs/specs/otlp/#json-protobuf-encoding

## Next Steps

1. **Create your separate service project**
   - Implement file monitoring
   - Parse OTLP/JSON format
   - Persist to MongoDB

2. **Integrate with AI agent**
   - Start service when agent starts
   - Monitor service health
   - Handle graceful shutdown

3. **Deploy and test**
   - Deploy OpenTelemetry Collector
   - Start your persistence service
   - Generate traffic and verify data flow

4. **Monitor and optimize**
   - Track processing statistics
   - Monitor MongoDB performance
   - Optimize batch sizes and intervals
