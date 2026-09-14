# OpenTelemetry Configuration Guide

## Overview
This guide explains how to configure OpenEdge PASOE and Database to send metrics and tracing data to a local OpenTelemetry Collector.

## Architecture

```
┌─────────────────┐
│   PASOE Inst 1  │──┐
│   Port: 8810    │  │
└─────────────────┘  │
                     │
┌─────────────────┐  │    ┌──────────────────┐    ┌─────────────────┐
│   PASOE Inst 2  │──┼───▶│  OpenTelemetry   │───▶│  Observability  │
│   Port: 8820    │  │    │    Collector     │    │   Backend       │
└─────────────────┘  │    │  Port: 4317/4318 │    │ (Jaeger/Prom)   │
                     │    └──────────────────┘    └─────────────────┘
┌─────────────────┐  │
│  Sports2020 DB  │──┘
│   Port: 10000   │
└─────────────────┘
```

## Configuration Files

### PASOE Instance 1
- **File**: `conf/otelconfig.json`
- **Service Name**: `oe-web-api-pasoe`
- **Instance ID**: `pasoe-instance-1`

### PASOE Instance 2
- **File**: `conf/otelconfig-pas2.json`
- **Service Name**: `oe-web-api-pasoe`
- **Instance ID**: `pasoe-instance-2`

### Database
- **File**: `conf/otelconfig-db.json`
- **Service Name**: `sports2020-database`
- **Instance ID**: `sports2020-db`

## OpenTelemetry Collector Setup

### 1. Install OpenTelemetry Collector

#### Using Docker
```bash
docker run -d \
  --name otel-collector \
  -p 4317:4317 \
  -p 4318:4318 \
  -p 8888:8888 \
  -p 8889:8889 \
  -v $(pwd)/otel-collector-config.yaml:/etc/otel-collector-config.yaml \
  otel/opentelemetry-collector:latest \
  --config=/etc/otel-collector-config.yaml
```

#### Using Binary
```bash
# Download from https://github.com/open-telemetry/opentelemetry-collector-releases
wget https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.91.0/otelcol_0.91.0_linux_amd64.tar.gz
tar -xzf otelcol_0.91.0_linux_amd64.tar.gz
./otelcol --config=otel-collector-config.yaml
```

### 2. OpenTelemetry Collector Configuration

Create `otel-collector-config.yaml`:

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 10s
    send_batch_size: 1024
  
  memory_limiter:
    check_interval: 1s
    limit_mib: 512
  
  resource:
    attributes:
      - key: service.namespace
        value: "openedge"
        action: upsert

exporters:
  # Export to Jaeger for tracing
  otlp/jaeger:
    endpoint: localhost:4317
    tls:
      insecure: true
  
  # Export to Prometheus for metrics
  prometheus:
    endpoint: "0.0.0.0:8889"
  
  # Console exporter for debugging
  logging:
    loglevel: info
  
  # File exporter for backup
  file:
    path: /var/log/otel/traces.json

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, batch, resource]
      exporters: [otlp/jaeger, logging, file]
    
    metrics:
      receivers: [otlp]
      processors: [memory_limiter, batch, resource]
      exporters: [prometheus, logging]
    
    logs:
      receivers: [otlp]
      processors: [memory_limiter, batch, resource]
      exporters: [logging, file]
  
  telemetry:
    logs:
      level: info
    metrics:
      address: 0.0.0.0:8888
```

### 3. Jaeger Backend Setup (Optional)

```bash
docker run -d \
  --name jaeger \
  -e COLLECTOR_OTLP_ENABLED=true \
  -p 16686:16686 \
  -p 4317:4317 \
  -p 4318:4318 \
  jaegertracing/all-in-one:latest
```

Access Jaeger UI at: http://localhost:16686

### 4. Prometheus Setup (Optional)

Create `prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'otel-collector'
    static_configs:
      - targets: ['localhost:8889']
  
  - job_name: 'openedge-pasoe'
    static_configs:
      - targets: ['localhost:8810', 'localhost:8820']
    metrics_path: '/metrics'
```

Start Prometheus:
```bash
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

Access Prometheus UI at: http://localhost:9090

## PASOE Configuration

### Update openedge.properties

#### For Instance 1 (`conf/openedge-pas1.properties`):
```properties
[AppServer.SessMgr]
    otelConfigFile=${catalina.base}/conf/otelconfig.json
```

#### For Instance 2 (`conf/openedge-pas2.properties`):
```properties
[AppServer.SessMgr]
    otelConfigFile=${catalina.base}/conf/otelconfig-pas2.json
```

### Deploy Configuration Files

```bash
# Copy to PASOE Instance 1
cp conf/otelconfig.json /opt/oe_web_api/pas1/conf/

# Copy to PASOE Instance 2
cp conf/otelconfig-pas2.json /opt/oe_web_api/pas2/conf/otelconfig.json
```

### Restart PASOE Instances

```bash
# Restart Instance 1
cd /opt/oe_web_api/pas1/bin
./tcman restart

# Restart Instance 2
cd /opt/oe_web_api/pas2/bin
./tcman restart
```

## Database Configuration

### Enable Database Telemetry

Add to database startup parameters in `scripts/start_db.sh`:

```bash
proserve sports2020 \
  -S 10000 \
  -n 50 \
  -Mi 20 \
  -Ma 20 \
  -Mpb 100 \
  -B 20000 \
  -spin 10000000 \
  -cpinternal UTF-8 \
  -cpstream UTF-8 \
  -L 100000 \
  -lruskip \
  -ServerType 4GL \
  -otelconfig /opt/oe_web_api/conf/otelconfig-db.json
```

### Restart Database

```bash
proshut sports2020
bash /opt/oe_web_api/scripts/start_db.sh
```

## Configuration Options Explained

### OpenTelemetryConfiguration

#### Service Identification
```json
"service": {
    "name": "oe-web-api-pasoe",        // Service name in traces
    "version": "1.0.0",                 // Application version
    "namespace": "production"           // Environment namespace
}
```

#### Resource Attributes
```json
"resource_attributes": {
    "deployment.environment": "production",  // Environment tag
    "service.instance.id": "pasoe-instance-1", // Unique instance ID
    "host.name": "localhost"            // Host identifier
}
```

#### Exporters

**GRPC Exporter** (Recommended for production):
```json
"grpc": [{
    "endpoint": "http://localhost:4317",  // Collector gRPC endpoint
    "compression": "gzip",                // Enable compression
    "timeout": 10000,                     // Connection timeout (ms)
    "span_processor": "batch",            // Batch processing
    "batch_processor_options": {
        "max_queue_size": 2048,           // Max spans in queue
        "schedule_delay": 5000,           // Batch delay (ms)
        "max_export_batch_size": 512,     // Max spans per batch
        "export_timeout": 30000           // Export timeout (ms)
    }
}]
```

**HTTP Exporter** (Alternative):
```json
"http": [{
    "endpoint": "http://localhost:4318/v1/traces",  // HTTP endpoint
    "compression": "gzip",
    "timeout": 10000
}]
```

#### Propagators
```json
"propagators": [
    "tracecontext",  // W3C Trace Context propagation
    "baggage"        // W3C Baggage propagation
]
```

#### Sampler
```json
"sampler": {
    "type": "parentbased_always_on",  // Always sample with parent
    "probability": 1.0                 // 100% sampling rate
}
```

**Sampler Types**:
- `always_on` - Sample all traces
- `always_off` - Sample no traces
- `traceidratio` - Sample based on probability
- `parentbased_always_on` - Sample if parent is sampled

### OpenEdgeTelemetryConfiguration

```json
{
    "enabled": true,                      // Enable telemetry
    "trace_classes": "*",                 // Trace all classes (* or specific)
    "trace_procedures": "*",              // Trace all procedures
    "trace_requires_parent": false,       // Create root spans
    "trace_abl_transactions": true,       // Trace transactions
    "trace_request_start": true,          // Trace request start
    "trace_request_end": true,            // Trace request end
    "trace_database_operations": true,    // Trace DB operations
    "trace_external_calls": true,         // Trace external calls
    "metrics_enabled": true,              // Enable metrics
    "metrics_export_interval": 60000,     // Metrics interval (ms)
    "log_level": "INFO"                   // Log level
}
```

## Metrics Collected

### PASOE Metrics
- **Request metrics**: Count, duration, errors
- **Agent metrics**: Active agents, sessions, requests
- **Memory metrics**: Heap usage, GC activity
- **Database metrics**: Connection pool, query duration
- **HTTP metrics**: Response codes, latency

### Database Metrics
- **Connection metrics**: Active connections, connection pool
- **Query metrics**: Query count, duration, errors
- **Transaction metrics**: Commits, rollbacks, duration
- **Buffer pool metrics**: Hit ratio, reads, writes
- **Lock metrics**: Lock waits, deadlocks
- **I/O metrics**: Read/write operations, throughput

## Traces Collected

### PASOE Traces
- **HTTP requests**: Full request/response lifecycle
- **ABL procedure calls**: Procedure execution spans
- **ABL class methods**: Method execution spans
- **Database operations**: Query execution spans
- **External API calls**: HTTP client spans
- **Transactions**: Transaction boundaries

### Database Traces
- **SQL queries**: Query execution with parameters
- **Transactions**: Transaction lifecycle
- **Connections**: Connection acquisition/release
- **Lock operations**: Lock acquisition/release

## Verification

### 1. Check OpenTelemetry Collector
```bash
# Check collector logs
docker logs otel-collector

# Check collector metrics endpoint
curl http://localhost:8888/metrics
```

### 2. Verify PASOE is Sending Data
```bash
# Check PASOE logs for telemetry messages
tail -f /opt/oe_web_api/pas1/logs/pas1.agent.log | grep -i otel

# Make test requests
curl http://localhost:8810/web/api/data/customers
```

### 3. View Traces in Jaeger
1. Open http://localhost:16686
2. Select service: `oe-web-api-pasoe`
3. Click "Find Traces"
4. View trace details

### 4. View Metrics in Prometheus
1. Open http://localhost:9090
2. Query: `openedge_pasoe_requests_total`
3. View graphs and metrics

## Troubleshooting

### No Traces Appearing

**Check Collector Connection**:
```bash
# Test gRPC endpoint
grpcurl -plaintext localhost:4317 list

# Test HTTP endpoint
curl -v http://localhost:4318/v1/traces
```

**Check PASOE Configuration**:
```bash
# Verify otelconfig.json is loaded
grep -i otel /opt/oe_web_api/pas1/conf/openedge.properties

# Check for errors in agent log
grep -i "error\|exception" /opt/oe_web_api/pas1/logs/pas1.agent.log
```

### High Memory Usage

Reduce batch sizes in otelconfig.json:
```json
"batch_processor_options": {
    "max_queue_size": 1024,
    "max_export_batch_size": 256
}
```

### Missing Metrics

Enable metrics in openedge.properties:
```properties
[AppServer]
    collectMetrics=1

[pas.ROOT]
    collectMetrics=1
```

### Slow Performance

Adjust sampling rate:
```json
"sampler": {
    "type": "traceidratio",
    "probability": 0.1  // Sample 10% of traces
}
```

## Production Recommendations

### 1. Sampling Strategy
- Use `traceidratio` sampler with 10-20% sampling in production
- Use `always_on` only for debugging

### 2. Batch Processing
- Increase `max_queue_size` for high-throughput systems
- Adjust `schedule_delay` based on latency requirements

### 3. Resource Limits
- Configure memory_limiter in collector
- Monitor collector resource usage

### 4. Security
- Use TLS for collector connections in production
- Secure collector endpoints with authentication

### 5. Data Retention
- Configure appropriate retention policies
- Archive old traces/metrics

## Example Queries

### Prometheus Queries
```promql
# Request rate
rate(openedge_pasoe_requests_total[5m])

# Average response time
rate(openedge_pasoe_request_duration_sum[5m]) / rate(openedge_pasoe_request_duration_count[5m])

# Error rate
rate(openedge_pasoe_errors_total[5m])

# Active agents
openedge_pasoe_agents_active

# Database connections
openedge_db_connections_active
```

### Jaeger Queries
- Service: `oe-web-api-pasoe`
- Operation: `GET /web/api/data/customers`
- Tags: `http.status_code=200`
- Duration: `> 100ms`

## References

- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [OpenEdge Telemetry Guide](https://docs.progress.com/)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
