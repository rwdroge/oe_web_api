#!/bin/bash
# Database Startup Script with OECC Agent Integration

set -e

# Copy custom db.pf if it exists in /app/conf
if [ -f "/app/conf/db.pf" ]; then
    echo "Copying custom db.pf configuration..."
    cp /app/conf/db.pf /app/db/db.pf
    echo "Custom db.pf applied:"
    cat /app/db/db.pf
fi

# Start the database in background
echo "Starting database..."
/app/scripts/startdb.sh &
DB_PID=$!

# Wait for database to be healthy
echo "Waiting for database to be fully initialized..."
export DLC=${DLC:-/usr/dlc}
export DB_PATH=/app/db/${DBNAME:-sports2020}

# Poll until database is ready (max 60 seconds)
MAX_WAIT=60
COUNTER=0
while [ $COUNTER -lt $MAX_WAIT ]; do
    if ${DLC}/bin/proutil ${DB_PATH} -C busy > /dev/null 2>&1; then
        echo "Database is ready!"
        break
    fi
    sleep 1
    COUNTER=$((COUNTER + 1))
done

if [ $COUNTER -eq $MAX_WAIT ]; then
    echo "ERROR: Database did not become ready within ${MAX_WAIT} seconds"
    exit 1
fi

# Now start OECC agent after database is confirmed healthy
if [ -f "/usr/oecc/agent/oeccagent" ]; then
    echo "Database is healthy. Starting OECC agent for database monitoring..."
    /docker/oecc/start-agent.sh &
else
    echo "OECC agent not installed, skipping agent startup"
fi

# Wait for the database process
wait $DB_PID
