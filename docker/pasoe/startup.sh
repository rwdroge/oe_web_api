#!/bin/bash
set -e

echo "Starting PASOE instance: ${INSTANCE_NAME}"
echo "HTTP Port: ${HTTP_PORT}"
echo "HTTPS Port: ${HTTPS_PORT}"
echo "Shutdown Port: ${SHUTDOWN_PORT}"

# Set up environment
export DLC=${DLC:-/usr/dlc}
export WRKDIR=${WRKDIR:-/usr/wrk}
export CATALINA_BASE=${CATALINA_BASE:-/usr/wrk/${INSTANCE_NAME}}
export INSTANCE_NAME=${INSTANCE_NAME:-pasoe1}

# Create PASOE instance if it doesn't exist
if [ ! -d "${CATALINA_BASE}" ]; then
    echo "Creating PASOE instance: ${INSTANCE_NAME}"
    
    # Create PASOE instance using tcman
    ${DLC}/bin/tcman create -p ${HTTP_PORT} -P ${HTTPS_PORT} -s ${SHUTDOWN_PORT} ${CATALINA_BASE}
    
    # Run configuration script
    /usr/wrk/configure-pasoe.sh
fi

# Copy web application if exists
if [ -d "/usr/wrk/webapps" ]; then
    echo "Deploying web applications..."
    cp -r /usr/wrk/webapps/* ${CATALINA_BASE}/webapps/ 2>/dev/null || true
fi

# Set PROPATH to include source directory
export PROPATH=/usr/wrk/src:${CATALINA_BASE}/openedge:${DLC}

# Configure database connection
if [ -n "${DB_HOST}" ] && [ -n "${DB_NAME}" ]; then
    echo "Configuring database connection to ${DB_HOST}:${DB_PORT}/${DB_NAME}"
    
    # Create database connection file
    cat > ${CATALINA_BASE}/conf/db.pf << EOF
-db ${DB_NAME}
-H ${DB_HOST}
-S ${DB_PORT}
-ld ${DB_NAME}
EOF
fi

# Configure OpenTelemetry if config exists
if [ -f "/usr/wrk/conf/otelconfig.json" ]; then
    echo "Configuring OpenTelemetry..."
    cp /usr/wrk/conf/otelconfig.json ${CATALINA_BASE}/conf/otelconfig.json
    
    # Set OpenTelemetry environment variables
    export OTEL_EXPORTER_OTLP_ENDPOINT=${OTEL_EXPORTER_OTLP_ENDPOINT:-http://otel-collector:4317}
    export OTEL_SERVICE_NAME=${OTEL_SERVICE_NAME:-oe-web-api-pasoe}
    export OTEL_RESOURCE_ATTRIBUTES=${OTEL_RESOURCE_ATTRIBUTES}
fi

# Copy additional configuration files
if [ -f "/usr/wrk/conf/openedge.properties" ]; then
    cp /usr/wrk/conf/openedge.properties ${CATALINA_BASE}/conf/
fi

if [ -f "/usr/wrk/conf/as.pf" ]; then
    cp /usr/wrk/conf/as.pf ${CATALINA_BASE}/conf/
fi

# Start PASOE instance
echo "Starting PASOE instance..."
${DLC}/bin/tcman start ${CATALINA_BASE}

# Follow logs
echo "PASOE instance started. Following logs..."
tail -f ${CATALINA_BASE}/logs/catalina.out
