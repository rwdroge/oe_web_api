#!/bin/bash
##########################################################################
# start-observability.sh
# Start OpenTelemetry observability stack
##########################################################################

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Starting OpenTelemetry Collector${NC}"
echo -e "${GREEN}========================================${NC}"

# Create logs directory
mkdir -p logs/otel

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${YELLOW}Error: Docker is not running${NC}"
    exit 1
fi

# Start the observability stack
echo -e "${YELLOW}Starting containers...${NC}"
docker-compose -f docker-compose-observability.yaml up -d

# Wait for services to be ready
echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 10

# Check service health
echo ""
echo -e "${GREEN}Checking service health...${NC}"

# Check OpenTelemetry Collector
if curl -s http://localhost:13133 > /dev/null; then
    echo -e "${GREEN}✓ OpenTelemetry Collector is running${NC}"
else
    echo -e "${YELLOW}✗ OpenTelemetry Collector is not responding${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}OpenTelemetry Collector Started${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Collector endpoints:"
echo "  - OTLP gRPC:     localhost:4317"
echo "  - OTLP HTTP:     localhost:4318"
echo "  - Health Check:  http://localhost:13133"
echo "  - Metrics:       http://localhost:8888/metrics"
echo ""
echo "Exporting to OTLP/JSON files:"
echo "  - Traces:  /var/log/otel/traces.jsonl"
echo "  - Metrics: /var/log/otel/metrics.jsonl"
echo "  - Logs:    /var/log/otel/logs.jsonl"
echo ""
echo "To view OTLP files:"
echo "  tail -f /var/log/otel/traces.jsonl | jq ."
echo "  tail -f /var/log/otel/metrics.jsonl | jq ."
echo "  tail -f /var/log/otel/logs.jsonl | jq ."
echo ""
echo "To view collector logs:"
echo "  docker logs -f otel-collector"
echo ""
echo "To stop:"
echo "  docker-compose -f docker-compose-observability.yaml down"
