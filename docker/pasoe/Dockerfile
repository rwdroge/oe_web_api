# OpenEdge PASOE Dockerfile
# Based on actual PASOE image used in devcontainer

FROM docker.io/rdroge/oe_pas_dev:latest

USER root

# Install additional tools for observability and OECC agent
RUN apt-get update && apt-get install -y \
    file \
    curl \
    wget \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME for OECC agent
ENV JAVA_HOME=/opt/java/openjdk

# Copy PASOE configuration files
COPY --chown=openedge:openedge ../../conf/as.pf /app/config/as.pf
COPY --chown=openedge:openedge ../../conf/db.pf /app/config/db.pf
COPY --chown=openedge:openedge ../../conf/openedge.properties /app/pas/as/conf/openedge.properties
COPY --chown=openedge:openedge ../../conf/memProfConf /app/pas/as/openedge/memProfConf

# Copy application source code
COPY --chown=openedge:openedge ../../src /app/src

# Copy OpenTelemetry configuration
COPY --chown=openedge:openedge ../../conf/otelconfig.json /app/pas/as/openedge/otelconfig.json

# Copy OECC agent installer and configuration files
COPY docker/binaries/PROGRESS_OECC_AGENT_2.0.0_LNX_64.bin /tmp/oecc-agent-installer.bin
COPY docker/oecc/agent-response-pasoe.properties /tmp/agent-response.properties
COPY docker/oecc/installationsInfo.json /tmp/oecc-config/installationsInfo.json
COPY docker/oecc/serverInfo.json /tmp/oecc-config/serverInfo.json
COPY docker/oecc/java.properties /tmp/oecc-config/java.properties
COPY docker/oecc/otagentpasoe.yaml /tmp/oecc-config/otagentpasoe.yaml
COPY docker/oecc/start-agent.sh /docker/oecc/start-agent.sh

# Install OECC agent in silent mode
RUN chmod +x /tmp/oecc-agent-installer.bin && \
    export JAVA_HOME=/opt/java/openjdk && \
    export PATH=$JAVA_HOME/bin:$PATH && \
    /tmp/oecc-agent-installer.bin -i silent -f /tmp/agent-response.properties && \
    rm -f /tmp/oecc-agent-installer.bin

# Copy OECC configuration files to agent installation directory
RUN mkdir -p /usr/oecc/agent/conf && \
    cp /tmp/oecc-config/installationsInfo.json /usr/oecc/agent/conf/ && \
    cp /tmp/oecc-config/serverInfo.json /usr/oecc/agent/conf/ && \
    cp /tmp/oecc-config/java.properties /usr/oecc/agent/conf/ && \
    cp /tmp/oecc-config/otagentpasoe.yaml /usr/oecc/agent/conf/ && \
    chown -R openedge:openedge /usr/oecc && \
    chmod +x /docker/oecc/start-agent.sh && \
    rm -rf /tmp/oecc-config

# Copy startup scripts
COPY --chown=openedge:openedge docker/pasoe/start.sh /app/pas/start.sh
COPY --chown=openedge:openedge docker/pasoe/start-with-agent.sh /app/start-with-agent.sh
RUN chmod +x /app/pas/start.sh /app/start-with-agent.sh

USER openedge

# Enable PASOE HealthCheck feature
RUN /app/pas/as/bin/tcman.sh feature HealthCheck=on

# Expose PASOE ports (8810=HTTP, 8811=HTTPS, 8899=HealthCheck)
EXPOSE 8810 8811 8899

# Health check using PASOE built-in health endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
    CMD curl -f http://localhost:8899 || exit 1

# Use startup script with OECC agent integration
CMD ["/app/start-with-agent.sh"]
