# OpenEdge Database Dockerfile
# Based on actual database image used in devcontainer

FROM docker.io/rdroge/oe_sports2020_db:latest

USER root

# Install additional tools for OECC agent
RUN apt-get update && apt-get install -y \
    file \
    curl \
    wget \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME for OECC agent
ENV JAVA_HOME=/opt/java/openjdk

# Copy license file into the image
COPY --chown=openedge:openedge ../../license/progress.cfg /usr/dlc/progress.cfg

# Copy OECC agent installer and configuration files
COPY docker/binaries/PROGRESS_OECC_AGENT_2.0.0_LNX_64.bin /tmp/oecc-agent-installer.bin
COPY docker/oecc/agent-response-db.properties /tmp/agent-response.properties
COPY docker/oecc/installationsInfo.json /tmp/oecc-config/installationsInfo.json
COPY docker/oecc/serverInfo.json /tmp/oecc-config/serverInfo.json
COPY docker/oecc/java.properties /tmp/oecc-config/java.properties
COPY docker/oecc/otagentoedb.yaml /tmp/oecc-config/otagentoedb.yaml
COPY docker/oecc/start-agent.sh /docker/oecc/start-agent.sh

# Install OECC agent in silent mode
RUN chmod +x /tmp/oecc-agent-installer.bin && \
    export JAVA_HOME=/opt/java/openjdk && \
    export PATH=$JAVA_HOME/bin:$PATH && \
    echo "Java version:" && java -version && \
    echo "Starting OECC agent installation..." && \
    /tmp/oecc-agent-installer.bin -i silent -f /tmp/agent-response.properties || \
    (echo "Installation failed with exit code $?" && \
     echo "Checking for installation logs..." && \
     find /tmp -name "*.log" -type f -exec echo "Found log: {}" \; -exec cat {} \; && \
     find /root -name "*.log" -type f -exec echo "Found log: {}" \; -exec cat {} \; && \
     cat /tmp/agent-response.properties && exit 1) && \
    rm -f /tmp/oecc-agent-installer.bin

# Copy OECC configuration files to agent installation directory
RUN mkdir -p /usr/oecc/agent/conf && \
    cp /tmp/oecc-config/installationsInfo.json /usr/oecc/agent/conf/ && \
    cp /tmp/oecc-config/serverInfo.json /usr/oecc/agent/conf/ && \
    cp /tmp/oecc-config/java.properties /usr/oecc/agent/conf/ && \
    cp /tmp/oecc-config/otagentoedb.yaml /usr/oecc/agent/conf/ && \
    chown -R openedge:openedge /usr/oecc && \
    chmod +x /docker/oecc/start-agent.sh && \
    rm -rf /tmp/oecc-config

# Copy custom db.pf and sqlbroker.pf to both locations to ensure they're used
COPY --chown=openedge:openedge conf/db.pf /app/db/db.pf
COPY --chown=openedge:openedge conf/db.pf /app/conf/db.pf
COPY --chown=openedge:openedge conf/sqlbroker.pf /app/conf/sqlbroker.pf
RUN cat /app/db/db.pf && echo "db.pf copied successfully" && \
    cat /app/conf/sqlbroker.pf && echo "sqlbroker.pf copied successfully"
# Copy custom startdb.sh that includes SQL broker startup
COPY --chown=openedge:openedge docker/database/startdb.sh /app/scripts/startdb.sh
RUN chmod +x /app/scripts/startdb.sh
# Copy database startup script with agent integration
COPY --chown=openedge:openedge docker/database/start-with-agent.sh /app/start-with-agent.sh
RUN chmod +x /app/start-with-agent.sh && \
    chown openedge:openedge /usr/wrk

USER openedge

# Expose database ports
EXPOSE 10000-10010

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD /usr/dlc/bin/proutil /app/db/sports2020 -C busy || exit 1

# Use startup script with OECC agent integration
CMD ["/app/start-with-agent.sh"]
