#!/bin/bash
# OECC Agent Startup Script for Docker Containers
# Standalone mode - no OECC server connection required

set -e

AGENT_DIR="/usr/oecc/agent"
AGENT_BIN="${AGENT_DIR}/oeccagent"

echo "Starting OECC agent in standalone mode for OpenTelemetry monitoring..."

# Check if agent is installed
if [ ! -f "$AGENT_BIN" ]; then
    echo "WARNING: OECC agent not found at $AGENT_BIN"
    echo "Skipping OECC agent startup..."
    exit 0
fi

# Start the OECC agent in standalone mode
echo "Starting OECC agent..."
cd "$AGENT_DIR"
./oeccagent start || {
    echo "WARNING: OECC agent failed to start"
    echo "Continuing without OECC agent..."
    exit 0
}

# Verify agent started
sleep 2
if ./oeccagent status 2>/dev/null | grep -q "running"; then
    echo "OECC agent started successfully in standalone mode"
else
    echo "WARNING: OECC agent may not have started correctly"
    ./oeccagent status 2>/dev/null || true
fi
