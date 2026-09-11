#!/bin/bash
# PASOE Startup Script with OECC Agent Integration

set -e

# Start OECC agent in background if installed
if [ -f "/usr/oecc/agent/oeccagent" ]; then
    echo "Starting OECC agent for PASOE monitoring..."
    /docker/oecc/start-agent.sh &
else
    echo "OECC agent not installed, skipping agent startup"
fi

# Start PASOE using the original startup script
exec /app/pas/start.sh
