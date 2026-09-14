# OECC Agent Performance Metrics Collection

## Overview

This document describes how the OpenEdge Command Center (OECC) agents are configured to collect performance metrics from PASOE and Database containers. The agents operate in standalone mode and export metrics to the OpenTelemetry collector for comprehensive observability.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Metric Collection Flow                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐              ┌──────────────┐                │
│  │   PASOE 1    │              │   PASOE 2    │                │
│  │              │              │              │                │
│  │ OECC Agent   │              │ OECC Agent   │                │
│  │   ↓          │              │   ↓          │                │
│  │ Auto-Discover│              │ Auto-Discover│                │
│  │ PASOE Instance              │ PASOE Instance                │
│  │   ↓          │              │   ↓          │                │
│  │ Collect:     │              │ Collect:     │                │
│  │ - Sessions   │              │ - Sessions   │                │
│  │ - Requests   │              │ - Requests   │                │
│  │ - Memory     │              │ - Memory     │                │
│  │ - CPU        │              │ - CPU        │                │
│  │ - ABL Procs  │              │ - ABL Procs  │                │
│  └──────┬───────┘              └──────┬───────┘                │
│         │                             │                         │
│         └─────────────┬───────────────┘                         │
│                       ↓                                         │
│              ┌─────────────────┐                               │
│              │ OpenTelemetry   │                               │
│              │   Collector     │                               │
│              │   (OTLP gRPC)   │                               │
│              └────────┬────────┘                               │
│                       │                                         │
│         ┌─────────────┼─────────────┐                          │
│         ↓             ↓             ↓                          │
│   ┌─────────┐   ┌─────────┐   ┌─────────┐                    │
│   │ Jaeger  │   │Prometheus│   │ Grafana │                    │
│   │ (Traces)│   │ (Metrics)│   │  (Viz)  │                    │
│   └─────────┘   └─────────┘   └─────────┘                    │
│                                                                  │
│  ┌──────────────┐                                              │
│  │  Database    │                                              │
│  │              │                                              │
│  │ OECC Agent   │                                              │
│  │   ↓          │                                              │
│  │ Auto-Discover│                                              │
│  │ DB Instance  │                                              │
│  │   ↓          │                                              │
│  │ Collect:     │                                              │
│  │ - Connections│                                              │
│  │ - Transactions                                              │
│  │ - Locks      │                                              │
│  │ - Buffer Pool│                                              │
│  │ - I/O Stats  │                                              │
│  └──────────────┘                                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Configuration Files

### 1. Bootstrap Policy (`bootstrap-policy.json`)

Defines agent permissions, resource discovery settings, and metric collection policies.

**Location**: `/usr/oecc/agent/conf/bootstrap-policy.json`

**Key Settings**:
```json
{
  "policies": {
    "resourceDiscovery": {
      "enabled": true,
      "scanInterval": 300,
      "autoRegister": true
    },
    "metricCollection": {
      "enabled": true,
      "collectionInterval": 60
    }
  }
}
```

**Features**:
- **Auto-Discovery**: Automatically detects running PASOE and database instances
- **Scan Interval**: Checks for new resources every 5 minutes (300 seconds)
- **Auto-Register**: Automatically registers discovered resources for monitoring
- **Collection Interval**: Collects metrics every 60 seconds

### 2. Agent Metrics Configuration (`agent-metrics-config.json`)

Detailed configuration for metric collection and export to OpenTelemetry.

**Location**: `/usr/oecc/agent/conf/agent-metrics-config.json`

**Key Features**:

#### OpenTelemetry Export
```json
{
  "metricsCollection": {
    "enabled": true,
    "exportFormat": "opentelemetry",
    "exportEndpoint": "http://otel-collector:4317",
    "collectionInterval": 60
  }
}
```

#### Database Metrics
- **Connections**: Active, idle, and total connection counts
- **Transactions**: Transaction rates, long-running transaction tracking (>5s threshold)
- **Locks**: Lock counts, deadlock detection and tracking
- **Buffer Pool**: Hit ratio, buffer usage statistics
- **I/O**: Read/write operations, throughput metrics
- **Performance**: CPU usage, memory usage, disk usage

#### PASOE Metrics
- **Sessions**: Active and idle session counts
- **Requests**: Response times, throughput, request rates
- **Memory**: Heap usage, session memory consumption
- **CPU**: Process-level CPU utilization
- **ABL Procedures**: Execution tracking, error rates
- **Connection Pool**: Available vs. in-use connections

### 3. Installation Info (`installationsInfo.json`)

Specifies OpenEdge installation paths for resource discovery.

**Location**: `/usr/oecc/agent/conf/installationsInfo.json`

```json
{
  "installations": [
    {
      "path": "/usr/dlc"
    }
  ]
}
```

The agent scans this path to discover:
- Running PASOE instances
- Active database servers
- OpenEdge configuration files
- Resource metadata

## How Metric Collection Works

### 1. Agent Startup

When the container starts:

1. **Agent Initialization**
   ```bash
   /docker/oecc/start-agent.sh
   ```
   - Verifies agent installation
   - Starts agent in standalone mode
   - No OECC server connection required

2. **Resource Discovery**
   - Agent scans `/usr/dlc` for OpenEdge installations
   - Detects running PASOE instances
   - Detects active database servers
   - Registers resources for monitoring

### 2. Metric Collection Cycle

Every 60 seconds (configurable):

1. **Query Resources**
   - Connect to PASOE management interface
   - Query database performance views
   - Collect system-level metrics

2. **Process Metrics**
   - Aggregate metric data
   - Calculate derived metrics (e.g., hit ratios)
   - Format for OpenTelemetry export

3. **Export to OpenTelemetry**
   - Send via OTLP gRPC protocol
   - Endpoint: `otel-collector:4317`
   - Compression: gzip
   - Retry on failure (max 3 attempts)

### 3. Data Flow

```
OECC Agent → OpenTelemetry Collector → Backends
                                      ├→ Jaeger (traces)
                                      ├→ Prometheus (metrics)
                                      └→ Grafana (visualization)
```

## Collected Metrics

### PASOE Metrics

| Metric Category | Metrics Collected | Update Frequency |
|----------------|-------------------|------------------|
| **Sessions** | Active count, Idle count, Total sessions | 60s |
| **Requests** | Request rate, Response time (avg/p95/p99), Throughput | 60s |
| **Memory** | Heap used, Heap max, Session memory | 60s |
| **CPU** | Process CPU %, System CPU % | 60s |
| **ABL Procedures** | Execution count, Error count, Avg execution time | 60s |
| **Connection Pool** | Available, In-use, Total, Wait time | 60s |

### Database Metrics

| Metric Category | Metrics Collected | Update Frequency |
|----------------|-------------------|------------------|
| **Connections** | Active, Idle, Total, Max connections | 60s |
| **Transactions** | Commit rate, Rollback rate, Active transactions | 60s |
| **Locks** | Lock count, Lock waits, Deadlocks | 60s |
| **Buffer Pool** | Hit ratio, Reads, Writes, Buffer size | 60s |
| **I/O** | Read ops/sec, Write ops/sec, Throughput MB/s | 60s |
| **Performance** | CPU %, Memory %, Disk usage % | 60s |

## Verification

### Check Agent Status

```bash
# PASOE containers
docker exec -it pasoe1 /usr/oecc/agent/oeccagent status
docker exec -it pasoe2 /usr/oecc/agent/oeccagent status

# Database container
docker exec -it oedb /usr/oecc/agent/oeccagent status
```

Expected output:
```
Agent is running
PID: 1234
Uptime: 00:15:32
Resources discovered: 2
Metrics collected: 1250
Last export: 2026-01-07 14:35:00
```

### View Agent Logs

```bash
# PASOE agent logs
docker exec -it pasoe1 tail -f /usr/oecc/agent/logs/agent.log

# Database agent logs
docker exec -it oedb tail -f /usr/oecc/agent/logs/agent.log
```

Look for:
```
[INFO] Resource discovery completed: Found 1 PASOE instance
[INFO] Metrics collection cycle completed: 45 metrics collected
[INFO] OpenTelemetry export successful: 45 metrics sent
```

### Verify Metric Export

```bash
# Check OpenTelemetry collector logs
docker logs otel-collector | grep -i "oecc"

# Check Prometheus for OECC metrics
curl http://localhost:9090/api/v1/label/__name__/values | grep oecc
```

### View Configuration

```bash
# View bootstrap policy
docker exec -it pasoe1 cat /usr/oecc/agent/conf/bootstrap-policy.json

# View metrics configuration
docker exec -it pasoe1 cat /usr/oecc/agent/conf/agent-metrics-config.json

# View installation info
docker exec -it pasoe1 cat /usr/oecc/agent/conf/installationsInfo.json
```

## Troubleshooting

### Agent Not Collecting Metrics

**Symptoms**: Agent running but no metrics in OpenTelemetry

**Solutions**:

1. **Check resource discovery**:
   ```bash
   docker exec -it pasoe1 /usr/oecc/agent/oeccagent status
   ```
   Should show "Resources discovered: > 0"

2. **Verify OpenEdge installation path**:
   ```bash
   docker exec -it pasoe1 ls -la /usr/dlc
   ```

3. **Check agent logs for errors**:
   ```bash
   docker exec -it pasoe1 tail -100 /usr/oecc/agent/logs/agent.log
   ```

4. **Verify OpenTelemetry collector connectivity**:
   ```bash
   docker exec -it pasoe1 nc -zv otel-collector 4317
   ```

### Metrics Not Appearing in Grafana

**Symptoms**: Metrics collected but not visible in Grafana

**Solutions**:

1. **Check Prometheus is scraping**:
   ```bash
   curl http://localhost:9090/api/v1/targets
   ```

2. **Verify metric names**:
   ```bash
   curl http://localhost:9090/api/v1/label/__name__/values
   ```

3. **Check Grafana data source**:
   - Navigate to Grafana → Configuration → Data Sources
   - Verify Prometheus connection

### High Metric Collection Overhead

**Symptoms**: Performance impact from metric collection

**Solutions**:

1. **Increase collection interval**:
   Edit `agent-metrics-config.json`:
   ```json
   {
     "metricsCollection": {
       "collectionInterval": 120
     }
   }
   ```

2. **Disable specific metrics**:
   ```json
   {
     "resourceMonitoring": {
       "pasoe": {
         "metrics": {
           "ablProcedures": {
             "enabled": false
           }
         }
       }
     }
   }
   ```

3. **Restart agent**:
   ```bash
   docker exec -it pasoe1 /usr/oecc/agent/oeccagent restart
   ```

## Performance Impact

### Resource Usage

| Component | CPU | Memory | Network | Disk |
|-----------|-----|--------|---------|------|
| **OECC Agent** | <2% | 50-100 MB | <1 Mbps | <10 MB/day |
| **Metric Collection** | <1% | N/A | <500 Kbps | N/A |
| **Total Impact** | <3% | 50-100 MB | <1.5 Mbps | <10 MB/day |

### Recommendations

- **Collection Interval**: 60s is optimal for most use cases
- **Batch Size**: Default 100 metrics per export is efficient
- **Retention**: Configure based on storage capacity
- **Alerting**: Disable if not using OECC server (standalone mode)

## Integration with Existing Monitoring

### OpenTelemetry Integration

OECC metrics complement existing OpenTelemetry instrumentation:

**Existing (Native OpenTelemetry)**:
- Application-level traces
- Custom business metrics
- Log aggregation
- Service mesh data

**Added (OECC Agents)**:
- OpenEdge-specific metrics
- Resource auto-discovery
- Deep performance data
- Historical trending

### Metric Correlation

Correlate OECC metrics with OpenTelemetry data:

```promql
# Example: Correlate PASOE response time with request rate
rate(oecc_pasoe_requests_total[5m]) 
  and 
oecc_pasoe_response_time_seconds > 1.0
```

## Configuration Tuning

### Adjust Collection Interval

For high-traffic systems, reduce collection frequency:

```json
{
  "metricsCollection": {
    "collectionInterval": 300
  }
}
```

### Enable Specific Metrics Only

Disable unnecessary metrics to reduce overhead:

```json
{
  "resourceMonitoring": {
    "database": {
      "metrics": {
        "connections": { "enabled": true },
        "transactions": { "enabled": true },
        "locks": { "enabled": false },
        "bufferPool": { "enabled": true },
        "io": { "enabled": false }
      }
    }
  }
}
```

### Configure Export Batching

Optimize network usage:

```json
{
  "metricsCollection": {
    "batchSize": 200,
    "exporters": {
      "opentelemetry": {
        "compression": "gzip",
        "timeout": 15000
      }
    }
  }
}
```

## Security Considerations

### Standalone Mode

- No external OECC server connection
- All metrics stay within Docker network
- No additional ports exposed to host

### Metric Data

- Metrics contain performance data only
- No sensitive business data included
- No user credentials in metrics
- Safe for long-term storage

### Network Security

- Metrics exported via internal Docker network
- OTLP gRPC uses internal DNS (otel-collector:4317)
- No external network access required

## Additional Resources

- **OECC Configuration**: `docker/oecc/README.md`
- **Installation Guide**: `docs/OECC_AGENT_SETUP.md`
- **OpenTelemetry Setup**: `docker/otel/README.md`
- **Grafana Dashboards**: `docker/grafana/provisioning/dashboards/`

## Support

For issues related to:
- **Metric Collection**: Check this document
- **Agent Installation**: See `docs/OECC_AGENT_SETUP.md`
- **OpenTelemetry**: See `docker/otel/README.md`
- **Grafana Visualization**: See Grafana documentation
