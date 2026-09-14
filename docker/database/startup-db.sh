#!/bin/bash
set -e

echo "Starting OpenEdge Database: ${DB_NAME}"

export DLC=${DLC:-/usr/dlc}
export WRKDIR=${WRKDIR:-/usr/wrk}
export DB_NAME=${DB_NAME:-sports2020}
export DB_PATH=/usr/wrk/db/${DB_NAME}

# Initialize database if needed
/usr/wrk/init-db.sh

# Create startup parameter file
cat > /usr/wrk/conf/startup.pf << EOF
# Database startup parameters
-db ${DB_PATH}
-S 20000
-N TCP
-H 0.0.0.0
-Mi 5
-Ma 10
-Mn 5
-Mpb 50
-mmax 8192
-n 150
-L 128000
-lruskip
-B 10000
-spin 10000000
-directio
-aibufs 100
-aistall 90
-bibufs 100
-bistall 90
EOF

# Add OpenTelemetry configuration if available
if [ -f "/usr/wrk/conf/otelconfig.json" ]; then
    echo "Configuring OpenTelemetry for database..."
    export OTEL_EXPORTER_OTLP_ENDPOINT=${OTEL_EXPORTER_OTLP_ENDPOINT:-http://otel-collector:4317}
    export OTEL_SERVICE_NAME=${OTEL_SERVICE_NAME:-sports2020-database}
    export OTEL_RESOURCE_ATTRIBUTES=${OTEL_RESOURCE_ATTRIBUTES}
fi

# Start database broker
echo "Starting database broker on port 20000..."
${DLC}/bin/proserve ${DB_PATH} -pf /usr/wrk/conf/startup.pf

# Wait for database to be ready
echo "Waiting for database to be ready..."
sleep 5

# Verify database is running
if ${DLC}/bin/proutil ${DB_PATH} -C busy; then
    echo "Database ${DB_NAME} is running"
else
    echo "ERROR: Database failed to start"
    exit 1
fi

# Enable after-image journaling if not already enabled
if ! ${DLC}/bin/proutil ${DB_PATH} -C aimage begin; then
    echo "After-image journaling already enabled or not configured"
fi

# Monitor database
echo "Database started successfully. Monitoring..."
while true; do
    if ! ${DLC}/bin/proutil ${DB_PATH} -C busy > /dev/null 2>&1; then
        echo "ERROR: Database is no longer running"
        exit 1
    fi
    sleep 30
done
