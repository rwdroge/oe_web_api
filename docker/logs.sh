#!/bin/bash

# Script to view logs from Docker services

SERVICE=${1:-all}

if [ "$SERVICE" = "all" ]; then
    echo "Following logs for all services..."
    docker-compose logs -f
elif [ "$SERVICE" = "pasoe" ]; then
    echo "Following logs for all PASOE instances..."
    docker-compose logs -f pasoe1 pasoe2
else
    echo "Following logs for $SERVICE..."
    docker-compose logs -f "$SERVICE"
fi
