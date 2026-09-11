#!/bin/bash
set -e

echo "Stopping OpenEdge Web API Docker stack..."
docker-compose down

echo ""
echo "All services stopped."
echo ""
echo "To remove volumes as well, run:"
echo "  docker-compose down -v"
echo ""
