# GenericService API Guide

## Overview

The GenericService API provides a RESTful interface for performing CRUD (Create, Read, Update, Delete) operations on various entities in the system. The API follows a service layer pattern, separating business logic from data access concerns.

## Base URL

All API endpoints are relative to the base URL:

```
/api/v1
```

## Authentication

Authentication details will be added in a future version of the API.

## API Types

The API supports two types of operations, specified by the `apitype` path parameter:

- `data`: For retrieving and manipulating entity data
- `meta`: For retrieving entity metadata (field definitions, validation rules, etc.)

## Common Parameters

### Path Parameters

- `apitype`: Type of API request (`data` or `meta`)
- `entityname`: Name of the entity (`item`, `customer`, `order`, `supplier`)
- `id`: Entity identifier

### Query Parameters

- `limit`: Maximum number of records to return (default: 100)
- `offset`: Number of records to skip (default: 0)
- `sort_by`: Field to sort by (prefix with `-` for descending order)
- Custom filters: Any field can be used as a filter parameter (e.g., `category=Electronics`)

## Endpoints

### Get All Entities

Retrieves all records of the specified entity type.

```
GET /{apitype}/{entityname}
```

#### Example Request

```
GET /data/items?limit=10&offset=0&sort_by=itemname
```

#### Example Response

```json
{
  "count": 10,
  "data": [
    {
      "itemnum": 101,
      "itemname": "Laptop",
      "price": {
        "value": 999.99
      },
      "category": "Electronics",
      "instock": true,
      "quantity": 50
    },
    // ... more items
  ]
}
```

### Get Entity by ID

Retrieves a specific entity by its ID.

```
GET /{apitype}/{entityname}/{id}
```

#### Example Request

```
GET /data/items/101
```

#### Example Response

```json
{
  "itemnum": 101,
  "itemname": "Laptop",
  "price": {
    "value": 999.99
  },
  "category": "Electronics",
  "instock": true,
  "quantity": 50
}
```

### Create Entity

Creates a new entity record.

```
POST /{apitype}/{entityname}
```

#### Example Request

```
POST /data/items

{
  "itemname": "Smartphone",
  "price": {
    "value": 699.99
  },
  "category": "Electronics",
  "instock": true,
  "quantity": 100
}
```

#### Example Response

```json
{
  "itemnum": 102,
  "itemname": "Smartphone",
  "price": {
    "value": 699.99
  },
  "category": "Electronics",
  "instock": true,
  "quantity": 100
}
```

### Update Entity

Updates an existing entity record.

```
PUT /{apitype}/{entityname}/{id}
```

#### Example Request

```
PUT /data/items/102

{
  "price": {
    "value": 649.99
  },
  "quantity": 75
}
```

#### Example Response

```json
{
  "itemnum": 102,
  "itemname": "Smartphone",
  "price": {
    "value": 649.99
  },
  "category": "Electronics",
  "instock": true,
  "quantity": 75
}
```

### Delete Entity

Deletes an entity record.

```
DELETE /{apitype}/{entityname}/{id}
```

#### Example Request

```
DELETE /data/items/102
```

#### Example Response

```json
{
  "message": "Entity deleted successfully",
  "entity": "item",
  "id": "102"
}
```

### Get Entity Metadata

Retrieves metadata for an entity.

```
GET /meta/{entityname}
```

#### Example Request

```
GET /meta/items
```

#### Example Response

```json
{
  "name": "item",
  "fields": [
    {
      "name": "itemnum",
      "type": "integer",
      "label": "Item Number",
      "required": true
    },
    {
      "name": "itemname",
      "type": "character",
      "label": "Item Name",
      "required": true
    },
    {
      "name": "price",
      "type": "decimal",
      "label": "Price",
      "required": true
    },
    {
      "name": "category",
      "type": "character",
      "label": "Category",
      "required": false
    },
    {
      "name": "instock",
      "type": "logical",
      "label": "In Stock",
      "required": false
    },
    {
      "name": "quantity",
      "type": "integer",
      "label": "Quantity",
      "required": false
    }
  ]
}
```

## Entity-Specific Endpoints

### Get Items by Category

Retrieves all items belonging to a specific category.

```
GET /data/items/category/{category}
```

#### Example Request

```
GET /data/items/category/Electronics
```

#### Example Response

```json
{
  "category": "Electronics",
  "count": 5,
  "items": [
    {
      "itemnum": 101,
      "itemname": "Laptop",
      "price": {
        "value": 999.99
      },
      "category": "Electronics",
      "instock": true,
      "quantity": 50
    },
    // ... more items
  ]
}
```

### Apply Discount to Item

Applies a percentage discount to an item's price.

```
POST /data/items/{id}/discount
```

#### Example Request

```
POST /data/items/101/discount

{
  "discountPercent": 15.5
}
```

#### Example Response

```json
{
  "itemnum": 101,
  "itemname": "Laptop",
  "price": {
    "value": 844.99
  },
  "category": "Electronics",
  "instock": true,
  "quantity": 50,
  "discountApplied": 15.5
}
```

## Error Handling

The API uses standard HTTP status codes to indicate the success or failure of requests:

- `200 OK`: The request was successful
- `201 Created`: The entity was created successfully
- `400 Bad Request`: The request was invalid
- `404 Not Found`: The requested resource was not found
- `422 Unprocessable Entity`: Validation error
- `500 Internal Server Error`: Server error

Error responses include detailed information about the error:

```json
{
  "error": "Entity not found",
  "entity": "item",
  "details": "The requested entity could not be found"
}
```

## Validation Errors

Validation errors include information about the invalid fields:

```json
{
  "error": "Invalid fields in request",
  "entityName": "item",
  "invalidFields": "price,quantity"
}
```

## Implemented Entities

The API currently supports the following entities:

### Items

Represents products or inventory items.

**Fields:**
- `itemnum`: Item number (integer, primary key)
- `itemname`: Item name (character)
- `price`: Price (decimal)
- `category`: Category (character)
- `instock`: In stock status (logical)
- `quantity`: Quantity available (integer)

### Customers

Represents customer information.

**Fields:**
- `custnum`: Customer number (integer, primary key)
- `name`: Customer name (character)
- `address`: Address (character)
- `city`: City (character)
- `state`: State (character)
- `country`: Country (character)
- `phone`: Phone number (character)
- `email`: Email address (character)

### Orders

Represents customer orders.

**Fields:**
- `ordernum`: Order number (integer, primary key)
- `custnum`: Customer number (integer, foreign key)
- `orderdate`: Order date (date)
- `shipdate`: Ship date (date)
- `status`: Order status (character)
- `total`: Order total (decimal)

### Suppliers

Represents supplier information.

**Fields:**
- `suppnum`: Supplier number (integer, primary key)
- `name`: Supplier name (character)
- `address`: Address (character)
- `city`: City (character)
- `state`: State (character)
- `country`: Country (character)
- `phone`: Phone number (character)
- `email`: Email address (character)
- `active`: Active status (logical)
