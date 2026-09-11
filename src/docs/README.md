# MCP Tools OpenAPI Specification

This directory contains the OpenAPI specification files for the Windsurf Model Context Protocol (MCP) tools. These YAML files define the API endpoints, request/response schemas, and other metadata for the MCP tools implemented in the PASOE application.

## Files

- `mcp-tools-openapi.yml` - The complete OpenAPI specification for all MCP tools
- `mcp-tools-items.yml` - OpenAPI specification for item management operations
- `mcp-tools-customers.yml` - OpenAPI specification for customer management operations
- `mcp-tools-metadata.yml` - OpenAPI specification for metadata operations

## Usage with PASOE

These YAML files are available to the PASOE application server through the src directory in the PROPATH. They can be used for:

1. **API Documentation**: Generate interactive API documentation using tools like Swagger UI
2. **Client Code Generation**: Generate client code for various programming languages
3. **API Testing**: Test API endpoints using tools that support OpenAPI specifications
4. **API Validation**: Validate API requests and responses against the defined schemas

## Integration with Windsurf MCP

The Windsurf MCP implementation in this application uses these specifications to:

1. Define the available tools and their parameters
2. Validate incoming requests against the defined schemas
3. Format responses according to the defined schemas
4. Provide self-documenting API capabilities

## Updating the Specifications

When adding new tools or modifying existing ones:

1. Update the corresponding YAML file(s)
2. Ensure the JSON specification file (`windsurf-mcp-tools-specification.json`) is also updated
3. Implement the tool functionality in the appropriate ABL classes

## Example Usage

To view the API documentation using Swagger UI, you can:

1. Use the Swagger UI endpoint in PASOE (if configured)
2. Import the YAML files into an online Swagger Editor
3. Use a local Swagger UI instance with these files
