#!/bin/bash

# Simple script to serve the API documentation locally
# This uses Python's built-in HTTP server

echo "Starting API documentation server..."
echo "Documentation will be available at http://localhost:8000/"
echo "Press Ctrl+C to stop the server"

# Change to the parent directory to serve both the docs and the OpenAPI spec
cd ..

# Start the Python HTTP server
python3 -m http.server 8000
