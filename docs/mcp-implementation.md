# Model Context Protocol (MCP) Implementation

This document describes the implementation of the Model Context Protocol (MCP) server for the Generic API.

## Overview

The MCP implementation provides a standardized way for AI models to interact with the Generic API. It maps entity operations to MCP resources and methods, allowing for consistent and predictable interactions.

## Architecture

The MCP implementation consists of the following components:

### 1. MCPHandler (mcp.MCPHandler)

The main handler class that processes HTTP requests for MCP operations. It:
- Handles POST requests for method calls
- Handles GET requests for schema information
- Routes requests to appropriate resource handlers
- Provides standardized error handling

### 2. Resource Interface (mcp.IMCPResourceHandler)

Defines the contract for all resource handlers:
- `HandleMethod()` - Process method calls
- `GetSchema()` - Provide schema information
- `GetResourceName()` - Return resource name

### 3. Base Resource Handler (mcp.BaseResourceHandler)

Abstract base class implementing common functionality:
- Standard CRUD operations (list, get, create, update, delete)
- Schema generation
- Integration with existing IService implementations

### 4. Resource Factory (mcp.MCPResourceFactory)

Creates and manages resource handlers:
- Singleton pattern for efficient resource usage
- Creates appropriate handlers for each entity
- Provides discovery of available resources

### 5. Entity-Specific Resource Handlers

Implement entity-specific methods:
- `ItemsResourceHandler` - Items operations
- `CustomersResourceHandler` - Customer operations
- `OrdersResourceHandler` - Order operations
- `SuppliersResourceHandler` - Supplier operations
- `MetadataResourceHandler` - Metadata operations

## Endpoints

The MCP server exposes the following endpoints:

- `POST /api/mcp/v1` - Execute an MCP method
- `GET /api/mcp/v1/{resource}` - Get schema for a specific resource

## Request Format

### Method Execution (POST)

```json
{
  "resource": "items",
  "method": "getByCategory",
  "parameters": {
    "category": "electronics"
  }
}
```

### Schema Request (GET)

```
GET /api/mcp/v1/items
```

## Response Format

### Method Execution

```json
{
  "items": [
    {
      "id": "ITEM001",
      "name": "Laptop",
      "category": "electronics",
      "price": 999.99
    },
    {
      "id": "ITEM002",
      "name": "Smartphone",
      "category": "electronics",
      "price": 699.99
    }
  ]
}
```

### Schema Response

```json
{
  "name": "items",
  "entityName": "items",
  "metadata": {
    "fields": [
      {
        "name": "id",
        "type": "character",
        "required": true
      },
      {
        "name": "name",
        "type": "character",
        "required": true
      },
      {
        "name": "category",
        "type": "character",
        "required": false
      },
      {
        "name": "price",
        "type": "decimal",
        "required": true
      }
    ]
  },
  "methods": [
    {
      "name": "list",
      "description": "Get all items with optional filtering"
    },
    {
      "name": "get",
      "description": "Get item by ID"
    },
    {
      "name": "create",
      "description": "Create a new item"
    },
    {
      "name": "update",
      "description": "Update an existing item"
    },
    {
      "name": "delete",
      "description": "Delete an item by ID"
    },
    {
      "name": "getByCategory",
      "description": "Get items by category"
    },
    {
      "name": "applyDiscount",
      "description": "Apply discount to an item"
    }
  ]
}
```

## Error Handling

Errors are returned in a standardized format:

```json
{
  "error": "Entity not found",
  "resource": "items",
  "method": "get",
  "details": "Item with ID 'ITEM999' does not exist"
}
```

## Integration with Existing Code

The MCP implementation integrates with the existing code by:

1. Using the `ServiceFactory` to get entity services
2. Mapping MCP methods to `IService` interface methods
3. Preserving all business logic in existing service classes
4. Providing a standardized MCP interface on top of the API

## Testing

The `MCPHandlerTest` class provides unit tests for the MCP implementation, covering:

1. Schema retrieval
2. Standard CRUD operations
3. Custom methods
4. Error handling

## Usage Examples

### Get Items by Category

```json
// Request
POST /api/mcp/v1
{
  "resource": "items",
  "method": "getByCategory",
  "parameters": {
    "category": "electronics"
  }
}

// Response
{
  "items": [
    {
      "id": "ITEM001",
      "name": "Laptop",
      "category": "electronics",
      "price": 999.99
    },
    {
      "id": "ITEM002",
      "name": "Smartphone",
      "category": "electronics",
      "price": 699.99
    }
  ]
}
```

### Update Customer Credit Limit

```json
// Request
POST /api/mcp/v1
{
  "resource": "customers",
  "method": "updateCreditLimit",
  "parameters": {
    "id": "CUST001",
    "creditLimit": 5000
  }
}

// Response
{
  "id": "CUST001",
  "name": "John Doe",
  "oldCreditLimit": 2000,
  "newCreditLimit": 5000
}
```

### Get Entity Metadata

```json
// Request
POST /api/mcp/v1
{
  "resource": "metadata",
  "method": "getEntityMetadata",
  "parameters": {
    "entity": "items"
  }
}

// Response
{
  "fields": [
    {
      "name": "id",
      "type": "character",
      "required": true
    },
    {
      "name": "name",
      "type": "character",
      "required": true
    },
    {
      "name": "category",
      "type": "character",
      "required": false
    },
    {
      "name": "price",
      "type": "decimal",
      "required": true
    }
  ]
}
```
