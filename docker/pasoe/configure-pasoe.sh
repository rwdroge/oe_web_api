#!/bin/bash
set -e

echo "Configuring PASOE instance: ${INSTANCE_NAME}"

export DLC=${DLC:-/usr/dlc}
export CATALINA_BASE=${CATALINA_BASE:-/usr/wrk/${INSTANCE_NAME}}

# Enable APSV transport
echo "Enabling APSV transport..."
${DLC}/bin/tcman feature apsv enable ${CATALINA_BASE}

# Enable REST transport
echo "Enabling REST transport..."
${DLC}/bin/tcman feature rest enable ${CATALINA_BASE}

# Enable SOAP transport
echo "Enabling SOAP transport..."
${DLC}/bin/tcman feature soap enable ${CATALINA_BASE}

# Configure web handler
echo "Configuring web handler..."
${DLC}/bin/tcman feature webhandler enable ${CATALINA_BASE}

# Set session timeout (30 minutes)
${DLC}/bin/tcman session timeout 30 ${CATALINA_BASE}

# Configure thread pool
${DLC}/bin/tcman pool set -m 50 -M 200 ${CATALINA_BASE}

# Enable OpenTelemetry instrumentation
if [ -f "/usr/wrk/conf/otelconfig.json" ]; then
    echo "Enabling OpenTelemetry instrumentation..."
    
    # Add OpenTelemetry Java agent if available
    OTEL_AGENT_PATH="${DLC}/lib/opentelemetry-javaagent.jar"
    if [ -f "${OTEL_AGENT_PATH}" ]; then
        ${DLC}/bin/tcman jvmopt add "-javaagent:${OTEL_AGENT_PATH}" ${CATALINA_BASE}
        ${DLC}/bin/tcman jvmopt add "-Dotel.javaagent.configuration-file=/usr/wrk/conf/otelconfig.json" ${CATALINA_BASE}
    fi
fi

# Set JVM memory options
${DLC}/bin/tcman jvmopt add "-Xms512m" ${CATALINA_BASE}
${DLC}/bin/tcman jvmopt add "-Xmx2048m" ${CATALINA_BASE}
${DLC}/bin/tcman jvmopt add "-XX:+UseG1GC" ${CATALINA_BASE}

# Enable access logging
${DLC}/bin/tcman logging enable ${CATALINA_BASE}

echo "PASOE configuration completed"
