# OECC Agent Installation and Configuration

## Overview

This document describes the OpenEdge Command Center (OECC) agent installation and configuration for the OpenEdge Web API Docker environment. The OECC agents are installed on both PASOE and Database containers to provide enhanced monitoring capabilities alongside the existing OpenTelemetry observability stack.

## Architecture

The OECC agents run in **standalone mode** without requiring a central OECC server. They complement the existing OpenTelemetry setup by providing OpenEdge-specific monitoring data.

### Components

- **PASOE Containers (pasoe1, pasoe2)**: Each runs an OECC agent for application server monitoring
- **Database Container (oedb)**: Runs an OECC agent for database monitoring
- **OpenTelemetry Collector**: Aggregates metrics from both OECC agents and native OpenTelemetry instrumentation

## Installation

### Prerequisites

The following are automatically installed during Docker image build:

- OpenJDK 17 (required for OECC agent)
- netcat-openbsd (for network connectivity checks)
- OECC Agent installer binary: `docker/binaries/PROGRESS_OECC_AGENT_2.0.0_LNX_64.bin`

### Build Process

The OECC agent is installed during the Docker build process using silent installation:

```bash
# Build images with OECC agent
docker-compose build pasoe1 pasoe2 oedb

# Start containers
docker-compose up -d
```

### Installation Details

Each container's Dockerfile includes:

1. **Java Installation**
   ```dockerfile
   RUN apt-get install -y openjdk-17-jdk
   ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
   ```

2. **Agent Installation**
   ```dockerfile
   COPY docker/binaries/PROGRESS_OECC_AGENT_2.0.0_LNX_64.bin /tmp/oecc-agent-installer.bin
   COPY docker/oecc/agent-response-*.properties /tmp/agent-response.properties
   RUN /tmp/oecc-agent-installer.bin -i silent -f /tmp/agent-response.properties
   ```

3. **Configuration Deployment**
   ```dockerfile
   RUN cp /tmp/oecc-config/*.json /usr/oecc/agent/conf/
   ```

## Configuration Files

All configuration files are located in `docker/oecc/`:

| File | Purpose |
|------|---------|
| `agent-response-pasoe.properties` | Silent installation settings for PASOE |
| `agent-response-db.properties` | Silent installation settings for Database |
| `installationsInfo.json` | OpenEdge installation paths |
| `serverInfo.json` | Server connection info (localhost for standalone) |
| `java.properties` | Java home directory |
| `start-agent.sh` | Agent startup script |

### Key Configuration Settings

**Standalone Mode** (no OECC server required):
```properties
OECC_SERVER_HOST=localhost
OECC_INSTALL_AS_SERVICE=0
OECC_OPENEDGE_INSTALLATIONS=/usr/dlc
```

## Startup Integration

### Container Startup Flow

1. Container starts with main application
2. OECC agent starts in background via `start-with-agent.sh`
3. Agent runs independently, providing monitoring data
4. If agent fails, container continues normally (graceful degradation)

### Startup Scripts

- **PASOE**: `docker/pasoe/start-with-agent.sh`
- **Database**: `docker/database/start-with-agent.sh`
- **Agent Startup**: `docker/oecc/start-agent.sh`

## Monitoring Capabilities

### PASOE Monitoring

The OECC agent on PASOE containers monitors:

- Application server health and status
- Session management and statistics
- Request/response metrics
- Memory and CPU utilization
- ABL procedure execution details
- Connection pool statistics

### Database Monitoring

The OECC agent on the database container monitors:

- Database server health
- Active connections and sessions
- Transaction statistics
- Lock monitoring and deadlock detection
- Buffer pool performance
- I/O operations and throughput
- Backup and recovery status

## Integration with OpenTelemetry

### Complementary Monitoring

The OECC agents work alongside the existing OpenTelemetry setup:

**OpenTelemetry** (Primary):
- Distributed tracing
- Custom metrics
- Log aggregation
- Service mesh observability

**OECC Agents** (Complementary):
- OpenEdge-specific metrics
- Resource auto-discovery
- Deep OpenEdge performance data
- Historical trending

### Data Flow

```
PASOE/DB → OECC Agent → Metrics Export
                ↓
         OpenTelemetry Collector
                ↓
    ┌───────────┼───────────┐
    ↓           ↓           ↓
  Jaeger    Prometheus   Grafana
```

## Verification

### Check Agent Status

```bash
# Check if agent is running in PASOE
docker exec -it pasoe1 /usr/oecc/agent/oeccagent status

# Check if agent is running in Database
docker exec -it oedb /usr/oecc/agent/oeccagent status
```

### View Agent Logs

```bash
# PASOE agent logs
docker exec -it pasoe1 tail -f /usr/oecc/agent/logs/agent.log

# Database agent logs
docker exec -it oedb tail -f /usr/oecc/agent/logs/agent.log
```

### Check Container Logs

```bash
# View startup logs
docker logs pasoe1 | grep -i oecc
docker logs oedb | grep -i oecc
```

## Troubleshooting

### Agent Not Starting

**Symptoms**: Agent status shows "not running"

**Solutions**:
1. Check Java installation:
   ```bash
   docker exec -it pasoe1 java -version
   ```

2. Verify agent binary exists:
   ```bash
   docker exec -it pasoe1 ls -la /usr/oecc/agent/oeccagent
   ```

3. Check permissions:
   ```bash
   docker exec -it pasoe1 ls -la /usr/oecc/agent/
   ```

### Installation Failed During Build

**Symptoms**: Docker build fails during agent installation

**Solutions**:
1. Verify installer binary exists:
   ```bash
   ls -la docker/binaries/PROGRESS_OECC_AGENT_2.0.0_LNX_64.bin
   ```

2. Check response file syntax:
   ```bash
   cat docker/oecc/agent-response-pasoe.properties
   ```

3. Review build logs:
   ```bash
   docker-compose build pasoe1 --no-cache 2>&1 | tee build.log
   ```

### Agent Installed But Not Monitoring

**Symptoms**: Agent runs but no metrics appear

**Solutions**:
1. Verify OpenEdge installation path:
   ```bash
   docker exec -it pasoe1 cat /usr/oecc/agent/conf/installationsInfo.json
   ```

2. Check agent can access OpenEdge:
   ```bash
   docker exec -it pasoe1 ls -la /usr/dlc
   ```

3. Review agent configuration:
   ```bash
   docker exec -it pasoe1 cat /usr/oecc/agent/conf/serverInfo.json
   ```

## Maintenance

### Updating OECC Agent

To update to a newer version:

1. Download new installer binary
2. Replace `docker/binaries/PROGRESS_OECC_AGENT_2.0.0_LNX_64.bin`
3. Update version references in Dockerfiles if needed
4. Rebuild and restart:
   ```bash
   docker-compose build pasoe1 pasoe2 oedb
   docker-compose up -d
   ```

### Removing OECC Agent

If you want to remove the OECC agent:

1. Comment out or remove OECC installation sections in:
   - `docker/pasoe/Dockerfile`
   - `docker/database/Dockerfile`

2. Use original startup scripts instead of `start-with-agent.sh`

3. Rebuild containers:
   ```bash
   docker-compose build
   docker-compose up -d
   ```

## Performance Impact

### Resource Usage

- **Memory**: ~50-100 MB per agent
- **CPU**: <5% during normal operation
- **Disk**: ~200 MB for agent installation
- **Network**: Minimal (local metrics collection)

### Recommendations

- Agents run with low priority to avoid impacting main application
- Graceful degradation if agent fails
- No impact on application startup time (agents start in background)

## Security Considerations

### Standalone Mode

- No external OECC server connection required
- All monitoring data stays within Docker network
- No additional ports exposed to host

### Certificates

- Default self-signed certificates used
- TLS hostname verification disabled (`nohostverify=true`)
- Suitable for development/testing environments

**Production Recommendation**: Configure custom certificates for production use.

## Additional Resources

- **OECC Configuration**: `docker/oecc/README.md`
- **Installation Guide**: `docs/oecc_install.txt`
- **OpenEdge Documentation**: [Progress Documentation](https://docs.progress.com/)
- **OpenTelemetry Setup**: `docker/otel/README.md`

## Support

For issues related to:
- **OECC Agent**: Check `docker/oecc/README.md`
- **Docker Setup**: See main `README.md`
- **OpenTelemetry**: See `docker/otel/README.md`
- **OpenEdge**: Consult Progress Software documentation
