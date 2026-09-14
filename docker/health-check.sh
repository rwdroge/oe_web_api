#!/bin/bash

echo "=================================================="
echo "OpenEdge Web API - Health Check"
echo "=================================================="
echo ""

# Check if services are running
echo "Service Status:"
echo "---------------"
docker-compose ps
echo ""

# Check Traefik
echo "Traefik Health:"
echo "---------------"
curl -s http://localhost:8080/api/overview | jq '.http.routers' 2>/dev/null || echo "Traefik dashboard not accessible"
echo ""

# Check PASOE instances
echo "PASOE Instance 1:"
echo "-----------------"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost/web || echo "PASOE 1 not accessible"
echo ""

echo "PASOE Instance 2:"
echo "-----------------"
docker-compose exec -T pasoe2 curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:8810/web || echo "PASOE 2 not accessible"
echo ""

# Check Database
echo "Database Status:"
echo "----------------"
docker-compose exec -T oedb /usr/dlc/bin/proutil /app/db/sports2020 -C busy 2>/dev/null && echo "Database is running" || echo "Database is not running"
echo ""

# Check OpenTelemetry Collector
echo "OpenTelemetry Collector:"
echo "------------------------"
curl -s http://localhost:13133 | jq '.status' 2>/dev/null || echo "OTel Collector not accessible"
echo ""

# Check Jaeger
echo "Jaeger:"
echo "-------"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:16686 || echo "Jaeger not accessible"
echo ""

# Check Prometheus
echo "Prometheus:"
echo "-----------"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:9090 || echo "Prometheus not accessible"
echo ""

# Check Grafana
echo "Grafana:"
echo "--------"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:3000 || echo "Grafana not accessible"
echo ""

echo "=================================================="
echo "Health check complete"
echo "=================================================="
