# OECC Agent OpenTelemetry Integration Setup

## Overview

This document describes the complete setup for enabling OpenEdge Command Center (OECC) agents to collect performance metrics from PASOE and Database instances and export them to OpenTelemetry Collector.

Based on the official OECC OpenTelemetry documentation, the agents use YAML configuration files to define metric collection and export settings.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                  OECC Agent → OpenTelemetry Flow                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐                                               │
│  │   Database   │                                               │
│  │              │                                               │
│  │ OECC Agent   │  Reads: otagentoedb.yaml                     │
│  │   ↓          │  Monitors: Database VSTs                     │
│  │ Collects:    │  - _ActSummary, _ActRecord                   │
│  │ - Commits    │  - _ActPWs, _ActBILog                        │
│  │ - Locks      │  - _ActAILog, _ActBuffer                     │
│  │ - Buffer Pool│                                               │
│  │ - I/O Stats  │                                               │
│  └──────┬───────┘                                               │
│         │                                                        │
│         │ OTLP/gRPC                                             │
│         │ (port 4317)                                           │
│         ↓                                                        │
│  ┌─────────────────┐                                           │
│  │ OpenTelemetry   │                                           │
│  │   Collector     │                                           │
│  │                 │                                           │
│  │ Receives metrics│                                           │
│  │ Processes data  │                                           │
│  │ Exports to APM  │                                           │
│  └────────┬────────┘                                           │
│           │                                                     │
│           ↓                                                     │
│  ┌─────────────────┐                                           │
│  │  APM Tools      │                                           │
│  │  - Prometheus   │                                           │
│  │  - Grafana      │                                           │
│  │  - Jaeger       │                                           │
│  │  - Elastic APM  │                                           │
│  └─────────────────┘                                           │
│                                                                  │
│  ┌──────────────┐                                               │
│  │   PASOE 1    │                                               │
│  │              │                                               │
│  │ OECC Agent   │  Reads: otagentpasoe.yaml                    │
│  │   ↓          │  Monitors: /app/pas                          │
│  │ Collects:    │  Transports: REST, SOAP, APSV, WEB          │
│  │ - Sessions   │                                               │
│  │ - Requests   │                                               │
│  │ - Memory     │                                               │
│  │ - CPU        │                                               │
│  └──────────────┘                                               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Configuration Files

### 1. Database Monitoring (`otagentoedb.yaml`)

**Location**: `/usr/oecc/agent/conf/otagentoedb.yaml`

**Purpose**: Configures OECC agent to collect database performance metrics and export to OpenTelemetry Collector.

**Configuration**:
```yaml
exporter:
  name: "otlp"
  endpoint: "http://otel-collector:4317"
  protocol: "grpc"
  timeout: 10
  connectionretry: 20

oedbInstances:
  - dbname: sports
    host: localhost
    port: 20000
    user: sysprogress
    password: sysprogress
    metricsregex: 
    otherdbconnparams: 
    dbschedule: 60
    dbduration: SECONDS
```

**Key Settings**:
- **endpoint**: OpenTelemetry Collector endpoint (must match OTel Collector receiver config)
- **protocol**: `grpc` for OTLP/gRPC transport
- **connectionretry**: Number of retry attempts if connection fails
- **dbschedule**: Metric collection interval (60 seconds recommended)
- **dbduration**: Time unit (SECONDS, MINUTES, HOURS, DAYS)

**Database User Requirements**:
The database user must have SELECT permissions on these Virtual System Tables (VSTs):
- `_ActSummary`
- `_ActRecord`
- `_ActPWs`
- `_ActBILog`
- `_ActAILog`
- `_ActBuffer`

### 2. PASOE Monitoring (`otagentpasoe.yaml`)

**Location**: `/usr/oecc/agent/conf/otagentpasoe.yaml`

**Purpose**: Configures OECC agent to collect PASOE performance metrics and export to OpenTelemetry Collector.

**Configuration**:
```yaml
exporter:
  name: "otlp"
  endpoint: "http://otel-collector:4317"
  protocol: "grpc"
  timeout: 10
  connectionretry: 20

pasInstances:
  - pasdir: "/app/pas"
    passchedule: 60
    pasduration: SECONDS
    metricsregex:
```

**Key Settings**:
- **pasdir**: Absolute path to PASOE instance directory
- **passchedule**: Metric collection interval (60 seconds recommended)
- **pasduration**: Time unit (SECONDS, MINUTES, HOURS, DAYS)
- **metricsregex**: Optional regex to filter specific metrics (blank = collect all)

## Collected Metrics

### Database Metrics (prefix: `progress_oedb_`)

| Metric | Description |
|--------|-------------|
| `summary_commits_total` | Total number of committed transactions |
| `summary_undos_total` | Total number of rolled back transactions |
| `record_updates_total` | Total number of records updated |
| `record_reads_total` | Total number of records read |
| `record_creates_total` | Total number of records created |
| `record_deletes_total` | Total number of records deleted |
| `summary_dbwrites_total` | Total database blocks written to disk |
| `summary_dbreads_total` | Total database blocks read |
| `summary_biwrites_total` | Total BI blocks written to disk |
| `summary_bireads_total` | Total BI blocks read |
| `summary_aiwrites_total` | Total AI blocks written to disk |
| `summary_reclocks_total` | Total record locks used |
| `summary_recwaits_total` | Total record lock waits |
| `summary_chkpts_total` | Total checkpoints performed |
| `summary_flushed_total` | Total buffers flushed to disk |
| `reclock_waits_percent` | Percentage of record lock waits |
| `bibuf_waits_percent` | Percentage of BI buffer waits |
| `aibuf_waits_percent` | Percentage of AI buffer waits |
| `apw_writes_percent` | Percentage of APW writes |
| `biw_writes_percent` | Percentage of BIW writes |
| `aiw_writes_percent` | Percentage of AIW writes |
| `buffer_hits_percent` | Overall buffer hit percentage |
| `primary_hits_percent` | Primary buffer pool hit percentage |
| `alternate_hits_percent` | Alternate buffer pool hit percentage |
| `instance_running_status` | Database status (1=running, -1=stopped) |

### PASOE Metrics (prefix: `progress_pasoe_`)

#### REST Transport
- `expression_errors_total`, `failed_requests_total`, `successful_requests_total`
- `connect_requests_total`, `status_requests_total`, `run_requests_total`
- `service_unavailable_requests_total`

#### SOAP Transport
- `url_notfound_errors_total`, `active_requests_total`, `wsdl_requests_total`
- `method_notallowed_errors_total`, `http_requests_errors_total`
- `processor_errors_total`

#### APSV Transport
- `forbidden_requests_total`, `disconnect_errors_total`, `connect_errors_total`
- `session_requests_total`, `session_errors_total`

#### WEB Transport
- `get_requests_total`, `post_requests_total`, `put_requests_total`, `delete_requests_total`
- `patch_requests_total`, `head_requests_total`, `options_requests_total`, `trace_requests_total`
- `servlet_requests_total`, `successful_servlet_requests_total`
- `ablruntime_errors_total`, `ablconnect_errors_total`

#### Common Metrics
- `all_requests_total`, `applications_total`, `agents_total`
- `available_agents_total`, `agent_sessions_total`
- `client_connections_total`, `client_sessions_total`
- `init_sessions_total`, `idle_sessions_total`, `starting_sessions_total`
- `available_sessions_total`, `reserved_sessions_total`, `stopped_sessions_total`
- `instance_running_status` (1=running, -1=stopped)

## Docker Implementation

### Database Container

The database Dockerfile includes:
1. OECC agent installation
2. Copy of `otagentoedb.yaml` to `/usr/oecc/agent/conf/`
3. Agent startup integration

**Relevant Dockerfile sections**:
```dockerfile
# Copy YAML configuration
COPY docker/oecc/otagentoedb.yaml /tmp/oecc-config/otagentoedb.yaml

# Copy to agent conf directory
RUN cp /tmp/oecc-config/otagentoedb.yaml /usr/oecc/agent/conf/
```

### PASOE Containers

The PASOE Dockerfile includes:
1. OECC agent installation
2. Copy of `otagentpasoe.yaml` to `/usr/oecc/agent/conf/`
3. Agent startup integration

**Relevant Dockerfile sections**:
```dockerfile
# Copy YAML configuration
COPY docker/oecc/otagentpasoe.yaml /tmp/oecc-config/otagentpasoe.yaml

# Copy to agent conf directory
RUN cp /tmp/oecc-config/otagentpasoe.yaml /usr/oecc/agent/conf/
```

## OpenTelemetry Collector Configuration

The OTel Collector must be configured to receive metrics from OECC agents.

**Required `config.yaml` sections**:

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: localhost:4317
      http:

exporters:
  debug:
    verbosity: detailed
  file:
    path: ./export.json
  otlp/elastic:
    endpoint: localhost:8200
    insecure: true
  prometheus:
    endpoint: "0.0.0.0:9090"

processors:
  batch:

service:
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, file, prometheus]
```

## Verification

### 1. Check Agent Status

```bash
# Database container
docker exec -it oedb /usr/oecc/agent/oeccagent status

# PASOE containers
docker exec -it pasoe1 /usr/oecc/agent/oeccagent status
docker exec -it pasoe2 /usr/oecc/agent/oeccagent status
```

**Expected output**:
```
Agent is running
PID: 1234
Uptime: 00:15:32
```

### 2. Verify Configuration Files

```bash
# Database YAML config
docker exec -it oedb cat /usr/oecc/agent/conf/otagentoedb.yaml

# PASOE YAML config
docker exec -it pasoe1 cat /usr/oecc/agent/conf/otagentpasoe.yaml
```

### 3. Check Agent Logs

```bash
# Database agent logs
docker exec -it oedb tail -f /usr/oecc/agent/logs/agent.log

# PASOE agent logs
docker exec -it pasoe1 tail -f /usr/oecc/agent/logs/agent.log
```

**Look for**:
```
[INFO] Starting OpenTelemetry metric collection
[INFO] Connected to OTel Collector at http://otel-collector:4317
[INFO] Collecting metrics from database: sports
[INFO] Metrics exported successfully
```

### 4. Verify Metrics in OpenTelemetry Collector

```bash
# Check OTel Collector logs
docker logs otel-collector | grep -i "progress_oedb\|progress_pasoe"

# Check exported JSON file (if configured)
docker exec -it otel-collector cat /export.json | jq '.resourceMetrics[].scopeMetrics[].metrics[] | select(.name | startswith("progress_"))'
```

### 5. Query Metrics in Prometheus

```bash
# List all OECC metrics
curl http://localhost:9090/api/v1/label/__name__/values | jq '.data[] | select(startswith("progress_"))'

# Query specific metric
curl 'http://localhost:9090/api/v1/query?query=progress_oedb_buffer_hits_percent'
```

## Troubleshooting

### Agent Not Collecting Metrics

**Symptoms**: Agent running but no metrics exported

**Solutions**:

1. **Verify YAML configuration**:
   ```bash
   docker exec -it oedb cat /usr/oecc/agent/conf/otagentoedb.yaml
   ```
   Ensure endpoint matches OTel Collector receiver

2. **Check database connectivity**:
   ```bash
   docker exec -it oedb /usr/dlc/bin/proutil /app/db/sports2020 -C busy
   ```

3. **Verify database user permissions**:
   ```sql
   -- Connect to database and check VST access
   SELECT * FROM _ActSummary;
   SELECT * FROM _ActRecord;
   ```

4. **Check OTel Collector connectivity**:
   ```bash
   docker exec -it oedb nc -zv otel-collector 4317
   ```

### Metrics Not Appearing in Prometheus

**Symptoms**: Metrics collected but not visible in Prometheus

**Solutions**:

1. **Verify OTel Collector pipeline**:
   Check `config.yaml` includes Prometheus exporter in metrics pipeline

2. **Check Prometheus scrape config**:
   Ensure Prometheus is scraping OTel Collector endpoint

3. **Verify metric names**:
   OECC metrics use `progress_oedb_` and `progress_pasoe_` prefixes

### Connection Failures

**Symptoms**: Agent cannot connect to OTel Collector

**Solutions**:

1. **Check network connectivity**:
   ```bash
   docker exec -it oedb ping otel-collector
   ```

2. **Verify OTel Collector is running**:
   ```bash
   docker ps | grep otel-collector
   docker logs otel-collector
   ```

3. **Check endpoint configuration**:
   Ensure `endpoint` in YAML matches OTel Collector receiver

4. **Review connection retry settings**:
   Increase `connectionretry` value if network is unstable

## Performance Considerations

### Collection Interval

- **Recommended**: 60 seconds (`dbschedule: 60`, `passchedule: 60`)
- **Minimum**: 30 seconds (OpenTelemetry limitation)
- **Maximum**: Configurable based on requirements

### Resource Impact

| Component | CPU | Memory | Network |
|-----------|-----|--------|---------|
| OECC Agent | <2% | 50-100 MB | <1 Mbps |
| Metric Collection | <1% | N/A | <500 Kbps |
| **Total** | **<3%** | **50-100 MB** | **<1.5 Mbps** |

### Optimization Tips

1. **Increase collection interval** for high-traffic systems:
   ```yaml
   dbschedule: 120  # Collect every 2 minutes
   ```

2. **Filter metrics** using regex:
   ```yaml
   metricsregex: "buffer_hits_percent|commits_total|instance_running_status"
   ```

3. **Install OTel Collector separately**: Run on different host to reduce resource contention

## Resilience and Failover

### Agent Behavior

1. **Database/PASOE stops**: Agent stops collecting metrics
2. **Database/PASOE restarts**: Agent resumes collection automatically
3. **OTel Collector stops**: Agent retries connection per `connectionretry` setting
4. **Connection restored**: Agent resumes metric export
5. **Retry limit exceeded**: Agent stops collecting; requires manual restart

### Recovery Procedure

If connection fails and retry limit is exceeded:

```bash
# Restart OECC agent
docker exec -it oedb /usr/oecc/agent/oeccagent restart

# Or restart entire container
docker restart oedb
docker restart pasoe1
docker restart pasoe2
```

## Integration with Existing Monitoring

### Complementary Data Sources

**OECC Agents provide**:
- OpenEdge-specific metrics
- Deep database performance data
- PASOE transport-level statistics
- Resource utilization trends

**Native OpenTelemetry provides**:
- Application-level traces
- Custom business metrics
- Service mesh data
- Log aggregation

### Metric Correlation Examples

```promql
# Correlate buffer hit ratio with transaction rate
progress_oedb_buffer_hits_percent 
  and 
rate(progress_oedb_summary_commits_total[5m]) > 100

# Identify PASOE instances with high error rates
rate(progress_pasoe_ablruntime_errors_total[5m]) > 0.1

# Monitor database lock contention
progress_oedb_reclock_waits_percent > 5
```

## References

- **Official Documentation**: `docs/oeccagent_openedge_opentelemetry`
- **OECC Agent Setup**: `docs/OECC_AGENT_SETUP.md`
- **Metrics Collection**: `docs/OECC_METRICS_COLLECTION.md`
- **OECC Configuration**: `docker/oecc/README.md`
- **OpenTelemetry Collector**: https://opentelemetry.io/docs/collector/

## Summary

The OECC agents are now configured to:

✅ **Collect database metrics** via `otagentoedb.yaml`  
✅ **Collect PASOE metrics** via `otagentpasoe.yaml`  
✅ **Export to OpenTelemetry Collector** via OTLP/gRPC  
✅ **Integrate with existing observability stack** (Prometheus, Grafana, Jaeger)  
✅ **Provide OpenEdge-specific performance insights**  

The agents operate in standalone mode, requiring no central OECC server, and seamlessly integrate with the existing OpenTelemetry infrastructure.
