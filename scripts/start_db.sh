#!/bin/bash
##########################################################################
# start_db.sh
# Start Sports2020 database with production parameters
##########################################################################

set -e

DB_PATH="/opt/oe_web_api/db"
DB_NAME="sports2020"
DB_PORT="10000"
OTEL_CONFIG="/opt/oe_web_api/conf/otelconfig-db.json"

cd "$DB_PATH"

echo "Starting $DB_NAME database on port $DB_PORT..."

proserve "$DB_NAME" \
  -S "$DB_PORT" \
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
  -otelconfig "$OTEL_CONFIG"

if [ $? -eq 0 ]; then
    echo "✓ Database started successfully"
    echo "  Port: $DB_PORT"
    echo "  Location: $DB_PATH/$DB_NAME"
    if [ -f "$OTEL_CONFIG" ]; then
        echo "  OpenTelemetry: Enabled (config: $OTEL_CONFIG)"
    else
        echo "  OpenTelemetry: Config not found (will use defaults)"
    fi
else
    echo "✗ Failed to start database"
    exit 1
fi
