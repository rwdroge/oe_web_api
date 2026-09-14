#!/bin/bash
set -e

echo "=================================================="
echo "OpenEdge Web API - Docker Deployment Script"
echo "=================================================="
echo ""

# Check if license file exists
if [ ! -f "./license/progress.cfg" ]; then
    echo "ERROR: License file not found at ./license/progress.cfg"
    echo "Please ensure your Progress OpenEdge license file is in the license directory"
    exit 1
fi

# Create necessary directories
echo "Creating log directories..."
mkdir -p logs/pasoe1 logs/pasoe2 logs/db logs/otel

# Create directory for OpenTelemetry Collector
echo "Creating OpenTelemetry directories..."
mkdir -p docker/otel

# Pull latest images
echo ""
echo "Pulling Docker images..."
docker-compose pull

# Build custom images if needed
echo ""
echo "Building custom images..."
docker-compose build

# Start the stack
echo ""
echo "Starting services..."
docker-compose up -d

# Wait for services to be healthy
echo ""
echo "Waiting for services to start..."
sleep 10

# Check service health
echo ""
echo "Checking service health..."
docker-compose ps

echo ""
echo "=================================================="
echo "Deployment complete!"
echo "=================================================="
echo ""
echo "Service URLs:"
echo "  - Web API (via Traefik): http://localhost/web"
echo "  - Traefik Dashboard: http://localhost:8080"
echo "  - Jaeger UI: http://localhost:16686"
echo "  - Prometheus: http://localhost:9090"
echo "  - Grafana: http://localhost:3000 (admin/admin)"
echo "  - OpenTelemetry Collector Health: http://localhost:13133"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f [service-name]"
echo ""
echo "To stop all services:"
echo "  docker-compose down"
echo ""
