# OpenEdge Command Center (OECC) Agent Configuration

## Overview

This directory contains the configuration files and scripts for installing and running OECC agents on both PASOE and Database containers in **standalone mode**. The agents operate independently without requiring a central OECC server, providing monitoring capabilities through OpenTelemetry integration.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Environment                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐              ┌──────────────┐            │
│  │   PASOE 1    │              │   PASOE 2    │            │
│  │              │              │              │            │
│  │ OECC Agent   │              │ OECC Agent   │            │
│  │     ↓        │              │     ↓        │            │
│  │  OpenTel     │              │  OpenTel     │            │
│  └──────┬───────┘              └──────┬───────┘            │
│         │                             │                     │
│         └─────────────┬───────────────┘                     │
│                       ↓                                     │
│              ┌─────────────────┐                           │
│              │ OpenTelemetry   │                           │
│              │   Collector     │                           │
│              └────────┬────────┘                           │
│                       │                                     │
│         ┌─────────────┼─────────────┐                      │
│         ↓             ↓             ↓                      │
│   ┌─────────┐   ┌─────────┐   ┌─────────┐                │
│   │ Jaeger  │   │Prometheus│   │ Grafana │                │
│   └─────────┘   └─────────┘   └─────────┘                │
│                                                              │
│  ┌──────────────┐                                          │
│  │  Database    │                                          │
│  │              │                                          │
│  │ OECC Agent   │                                          │
│  │     ↓        │                                          │
│  │  OpenTel     │                                          │
│  └──────────────┘                                          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Files in This Directory

### Configuration Files

- **`agent-response-pasoe.properties`** - Silent installation response file for PASOE containers
- **`agent-response-db.properties`** - Silent installation response file for Database containers
- **`installationsInfo.json`** - OpenEdge installation paths configuration
- **`serverInfo.json`** - Server connection info (set to localhost for standalone mode)
- **`java.properties`** - Java home directory configuration
- **`agent-config-pasoe.json`** - PASOE-specific agent configuration
- **`agent-config-db.json`** - Database-specific agent configuration
- **`bootstrap-policy.json`** - Agent permissions and resource discovery settings
- **`agent-metrics-config.json`** - Detailed metric collection and export configuration

### Scripts

- **`start-agent.sh`** - Startup script for OECC agent (standalone mode)

## Installation Process

The OECC agent is installed during Docker image build using the following process:

### 1. Prerequisites Installation
```dockerfile
# Java 17 is required for OECC agent
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    netcat-openbsd
```

### 2. Silent Installation
```dockerfile
# Copy installer and configuration
COPY docker/binaries/PROGRESS_OECC_AGENT_2.0.0_LNX_64.bin /tmp/oecc-agent-installer.bin
COPY docker/oecc/agent-response-*.properties /tmp/agent-response.properties

# Install in silent mode
RUN /tmp/oecc-agent-installer.bin -i silent -f /tmp/agent-response.properties
```

### 3. Configuration Deployment
```dockerfile
# Copy configuration files to agent installation directory
RUN cp /tmp/oecc-config/*.json /usr/oecc/agent/conf/
```

## Standalone Mode Configuration

### Key Settings

The agents are configured to run in **standalone mode** without connecting to an OECC server:

1. **Server Host**: Set to `localhost` (not used in standalone mode)
2. **No Server Dependency**: Agents start independently
3. **OpenTelemetry Integration**: Agents export metrics/data to OpenTelemetry collector

### Agent Response File Settings

```properties
# Standalone mode - no OECC server connection
OECC_SERVER_HOST=localhost
OECC_SERVER_MANAGEMENT_PORT=8001
OECC_NOHOST_VERIFY=1

# Agent runs as process (not service)
OECC_INSTALL_AS_SERVICE=0

# OpenEdge installation path
OECC_OPENEDGE_INSTALLATIONS=/usr/dlc
```

## Startup Process

### Container Startup Flow

1. **Container starts** → Main application startup script
2. **Agent startup** → `/docker/oecc/start-agent.sh` runs in background
3. **Agent verification** → Checks if agent is running
4. **Graceful fallback** → If agent fails, container continues without it

### Startup Script Features

- **Non-blocking**: Agent starts in background, doesn't block main application
- **Error handling**: Graceful fallback if agent installation is missing
- **Status verification**: Confirms agent started successfully
- **Standalone mode**: No waiting for OECC server connection

## Integration with OpenTelemetry

The OECC agents complement the existing OpenTelemetry setup:

### Existing OpenTelemetry Configuration
```yaml
environment:
  - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
  - OTEL_SERVICE_NAME=oe-web-api-pasoe
  - OTEL_RESOURCE_ATTRIBUTES=deployment.environment=production
```

### OECC Agent Benefits
- **Additional metrics**: OECC agents provide OpenEdge-specific monitoring data
- **Resource discovery**: Automatic detection of PASOE and database instances
- **Performance monitoring**: Detailed OpenEdge performance metrics
- **Health checks**: Enhanced health monitoring capabilities

## Monitoring Capabilities

### PASOE Monitoring
- Application server metrics
- Session management
- Request/response statistics
- Memory and CPU usage
- ABL procedure execution

### Database Monitoring
- Database connections
- Transaction statistics
- Lock monitoring
- Buffer pool metrics
- I/O performance

## Troubleshooting

### Agent Not Starting

Check the container logs:
```bash
docker logs pasoe1 | grep -i "oecc"
docker logs oedb | grep -i "oecc"
```

### Verify Agent Installation

Execute inside container:
```bash
docker exec -it pasoe1 /bin/bash
ls -la /usr/oecc/agent/
/usr/oecc/agent/oeccagent status
```

### Check Configuration Files

```bash
docker exec -it pasoe1 cat /usr/oecc/agent/conf/installationsInfo.json
docker exec -it pasoe1 cat /usr/oecc/agent/conf/serverInfo.json
```

### Common Issues

1. **Java not found**
   - Ensure Java 17 is installed in the container
   - Check `JAVA_HOME` environment variable

2. **Agent binary missing**
   - Verify `PROGRESS_OECC_AGENT_2.0.0_LNX_64.bin` exists in `docker/binaries/`
   - Check Dockerfile COPY commands

3. **Permission issues**
   - Ensure agent files are owned by `openedge:openedge`
   - Check execute permissions on scripts

## Upgrading OECC Agent

To upgrade to a newer version:

1. Download new agent installer binary
2. Replace `docker/binaries/PROGRESS_OECC_AGENT_2.0.0_LNX_64.bin`
3. Update version in Dockerfiles if needed
4. Rebuild containers:
   ```bash
   docker-compose build pasoe1 pasoe2 oedb
   docker-compose up -d
   ```

## Removing OECC Agent

To remove OECC agent from containers:

1. Remove agent installation steps from Dockerfiles:
   - Remove OECC COPY commands
   - Remove agent installation RUN commands
   - Remove agent configuration steps

2. Remove agent startup from scripts:
   - Edit `start-with-agent.sh` to skip agent startup
   - Or use original startup scripts

3. Rebuild containers

## Additional Resources

- [OpenEdge Command Center Documentation](https://docs.progress.com/bundle/openedge-command-center-olh/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [OECC Installation Guide](../docs/oecc_install.txt)

## Notes

- **Standalone Mode**: Agents operate independently without OECC server
- **OpenTelemetry First**: Primary monitoring is through OpenTelemetry
- **Complementary**: OECC agents provide additional OpenEdge-specific metrics
- **Optional**: Containers will start successfully even if agent fails
