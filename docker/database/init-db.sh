#!/bin/bash
set -e

echo "Initializing OpenEdge Database: ${DB_NAME}"

export DLC=${DLC:-/usr/dlc}
export WRKDIR=${WRKDIR:-/usr/wrk}
export DB_NAME=${DB_NAME:-sports2020}
export DB_PATH=/usr/wrk/db/${DB_NAME}

# Check if database already exists
if [ -f "${DB_PATH}.db" ]; then
    echo "Database ${DB_NAME} already exists at ${DB_PATH}.db"
    exit 0
fi

# Check if a template database exists
if [ -f "/usr/wrk/db/${DB_NAME}.db" ]; then
    echo "Using existing database file"
    exit 0
fi

# Create new database from empty template
echo "Creating new database from template..."

# Copy empty database template
if [ -f "${DLC}/empty.db" ]; then
    cp ${DLC}/empty.db ${DB_PATH}.db
    cp ${DLC}/empty.st ${DB_PATH}.st 2>/dev/null || true
else
    # Create database using prodb
    cd /usr/wrk/db
    ${DLC}/bin/prodb ${DB_NAME} empty
fi

# Create database structure file if it doesn't exist
if [ ! -f "${DB_PATH}.st" ]; then
    cat > ${DB_PATH}.st << 'EOF'
b /usr/wrk/db
d "Schema Area":6,64 /usr/wrk/db/${DB_NAME}.d1 f 1024
EOF
fi

# Initialize database with structure
echo "Initializing database structure..."
${DLC}/bin/prostrct create ${DB_PATH}

# Load schema if exists
if [ -f "/usr/wrk/db/schema.df" ]; then
    echo "Loading database schema..."
    ${DLC}/bin/prostrct add ${DB_PATH} /usr/wrk/db/schema.df
fi

# Load initial data if exists
if [ -f "/usr/wrk/db/data.d" ]; then
    echo "Loading initial data..."
    ${DLC}/bin/proutil ${DB_PATH} -C load /usr/wrk/db/data.d
fi

echo "Database initialization completed"
