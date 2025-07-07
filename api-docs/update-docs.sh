#!/bin/bash

# Script to update API documentation
# This script helps maintain the API documentation when changes are made to the API

echo "Updating API Documentation..."

# Check if OpenAPI specification exists
if [ ! -f "../openapi-specification.yaml" ]; then
    echo "Error: openapi-specification.yaml not found!"
    exit 1
fi

# Validate OpenAPI specification
echo "Validating OpenAPI specification..."
if command -v openapi-validator &> /dev/null; then
    openapi-validator ../openapi-specification.yaml
    if [ $? -ne 0 ]; then
        echo "OpenAPI specification validation failed!"
        echo "Please fix the errors and try again."
        exit 1
    fi
else
    echo "Warning: openapi-validator not found. Skipping validation."
    echo "To install: npm install -g openapi-validator"
fi

# Update the date in documentation files
echo "Updating documentation dates..."
TODAY=$(date +"%Y-%m-%d")

# Update API_GUIDE.md date
if [ -f "API_GUIDE.md" ]; then
    sed -i "s/Last updated: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/Last updated: $TODAY/" API_GUIDE.md
fi

# Update INTEGRATION_GUIDE.md date
if [ -f "INTEGRATION_GUIDE.md" ]; then
    sed -i "s/Last updated: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/Last updated: $TODAY/" INTEGRATION_GUIDE.md
fi

# Update EXTENDING_THE_API.md date
if [ -f "EXTENDING_THE_API.md" ]; then
    sed -i "s/Last updated: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/Last updated: $TODAY/" EXTENDING_THE_API.md
fi

# Generate Postman collection from OpenAPI spec if openapi-to-postman is available
echo "Generating Postman collection from OpenAPI specification..."
if command -v openapi2postmanv2 &> /dev/null; then
    openapi2postmanv2 -s ../openapi-specification.yaml -o GenericServiceRefactored_API.postman_collection.json -p
    if [ $? -eq 0 ]; then
        echo "Postman collection updated successfully."
    else
        echo "Warning: Failed to update Postman collection."
    fi
else
    echo "Warning: openapi2postmanv2 not found. Skipping Postman collection generation."
    echo "To install: npm install -g openapi-to-postmanv2"
fi

# Start the documentation server
echo "Starting documentation server..."
echo "You can access the documentation at http://localhost:8000"
echo "Press Ctrl+C to stop the server"
python3 -m http.server 8000

echo "Documentation update complete!"
