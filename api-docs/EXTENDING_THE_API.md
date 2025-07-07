# Extending the GenericServiceRefactored API

This guide provides step-by-step instructions on how to extend the GenericServiceRefactored API with new entities.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Adding a New Entity](#adding-a-new-entity)
  - [Step 1: Create the Entity Class](#step-1-create-the-entity-class)
  - [Step 2: Create the Repository Class](#step-2-create-the-repository-class)
  - [Step 3: Create the Service Class](#step-3-create-the-service-class)
  - [Step 4: Register the Service with ServiceFactory](#step-4-register-the-service-with-servicefactory)
  - [Step 5: Update the OpenAPI Specification](#step-5-update-the-openapi-specification)
- [Adding Custom Endpoints](#adding-custom-endpoints)
- [Testing Your New Entity](#testing-your-new-entity)
- [Best Practices](#best-practices)

## Overview

The GenericServiceRefactored API follows a layered architecture pattern that makes it easy to extend with new entities. The architecture consists of:

1. **Entity Layer**: Defines the data structure and properties
2. **Repository Layer**: Handles data access and persistence
3. **Service Layer**: Implements business logic and validation
4. **API Layer**: Exposes HTTP endpoints for client interaction

This guide will walk you through adding a new entity to the API.

## Architecture

The API uses the following components:

- `GenericServiceRefactored.cls`: The main API handler that processes HTTP requests
- `IService` interface: Defines the contract for service classes
- `ServiceFactory`: Creates and manages service instances
- `BaseRepository`: Provides common data access functionality
- `BaseService`: Provides common service layer functionality

## Adding a New Entity

### Step 1: Create the Entity Class

Create a new class file in the `src/entities` directory with the name of your entity.

Example for a `products.cls` entity:

```abl
/*********************************************************************
* File: products.cls
* Description: Products entity class
*********************************************************************/

class entities.products:
    
    /* Define properties */
    define public property productId as integer no-undo get. set.
    define public property name as character no-undo get. set.
    define public property description as character no-undo get. set.
    define public property price as decimal no-undo get. set.
    define public property categoryId as integer no-undo get. set.
    define public property inStock as logical no-undo get. set.
    define public property createdDate as date no-undo get. set.
    
    /* Constructor */
    constructor public products():
        super().
    end constructor.
    
    /* Methods */
    method public void Initialize():
        this-object:productId = 0.
        this-object:name = "".
        this-object:description = "".
        this-object:price = 0.
        this-object:categoryId = 0.
        this-object:inStock = false.
        this-object:createdDate = today.
    end method.
    
end class.
```

### Step 2: Create the Repository Class

Create a repository class in the `src/data` directory to handle data access for your entity.

Example for a `ProductRepository.cls`:

```abl
/*********************************************************************
* File: ProductRepository.cls
* Description: Repository for Products entity
*********************************************************************/

using data.BaseRepository.
using entities.products.

class data.ProductRepository inherits BaseRepository:
    
    /* Constructor */
    constructor public ProductRepository():
        super("products").  /* Pass the entity name to the base constructor */
    end constructor.
    
    /* Override FindById method if needed */
    method override public JsonObject FindById(input id as character):
        /* Custom implementation if needed */
        return super:FindById(id).
    end method.
    
    /* Add custom methods specific to Products */
    method public JsonObject FindProductsByCategory(input categoryId as integer):
        define variable joResult as JsonObject no-undo.
        define variable jaProducts as JsonArray no-undo.
        
        /* Implementation to find products by category */
        jaProducts = new JsonArray().
        
        /* Example: Query the database for products in the specified category */
        /* ... */
        
        joResult = new JsonObject().
        joResult:Add("products", jaProducts).
        
        return joResult.
    end method.
    
    /* Override GetMetadata to provide entity-specific metadata */
    method override public JsonObject GetMetadata():
        define variable joMetadata as JsonObject no-undo.
        define variable jaFields as JsonArray no-undo.
        define variable joField as JsonObject no-undo.
        
        joMetadata = new JsonObject().
        jaFields = new JsonArray().
        
        /* Define metadata for each field */
        joField = new JsonObject().
        joField:Add("name", "productId").
        joField:Add("type", "integer").
        joField:Add("required", true).
        joField:Add("key", true).
        jaFields:Add(joField).
        
        joField = new JsonObject().
        joField:Add("name", "name").
        joField:Add("type", "character").
        joField:Add("required", true).
        joField:Add("maxLength", 100).
        jaFields:Add(joField).
        
        joField = new JsonObject().
        joField:Add("name", "description").
        joField:Add("type", "character").
        joField:Add("required", false).
        joField:Add("maxLength", 2000).
        jaFields:Add(joField).
        
        joField = new JsonObject().
        joField:Add("name", "price").
        joField:Add("type", "decimal").
        joField:Add("required", true).
        jaFields:Add(joField).
        
        joField = new JsonObject().
        joField:Add("name", "categoryId").
        joField:Add("type", "integer").
        joField:Add("required", true).
        jaFields:Add(joField).
        
        joField = new JsonObject().
        joField:Add("name", "inStock").
        joField:Add("type", "logical").
        joField:Add("required", true).
        jaFields:Add(joField).
        
        joField = new JsonObject().
        joField:Add("name", "createdDate").
        joField:Add("type", "date").
        joField:Add("required", true).
        jaFields:Add(joField).
        
        joMetadata:Add("entity", "products").
        joMetadata:Add("fields", jaFields).
        
        return joMetadata.
    end method.
    
end class.
```

### Step 3: Create the Service Class

Create a service class in the `src/services` directory to implement business logic for your entity.

Example for a `ProductService.cls`:

```abl
/*********************************************************************
* File: ProductService.cls
* Description: Service for Products entity
*********************************************************************/

using services.BaseService.
using data.ProductRepository.
using interfaces.IService.

class services.ProductService inherits BaseService implements IService:
    
    /* Constructor */
    constructor public ProductService():
        super(new ProductRepository()).
    end constructor.
    
    /* Implement required interface methods */
    method override public JsonObject GetById(input id as character):
        return super:GetById(id).
    end method.
    
    method override public JsonObject GetByFilter(input filter as JsonObject):
        return super:GetByFilter(filter).
    end method.
    
    method override public JsonObject Create(input entityData as JsonObject):
        /* Add validation logic if needed */
        if not this-object:ValidateFields(entityData) then
            return this-object:CreateValidationErrorResponse().
        
        /* Set default values if needed */
        if not entityData:Has("createdDate") then
            entityData:Add("createdDate", string(today)).
        
        return super:Create(entityData).
    end method.
    
    method override public JsonObject Update(input id as character, input entityData as JsonObject):
        /* Add validation logic if needed */
        if not this-object:ValidateFields(entityData) then
            return this-object:CreateValidationErrorResponse().
        
        return super:Update(id, entityData).
    end method.
    
    method override public JsonObject Delete(input id as character):
        return super:Delete(id).
    end method.
    
    method override public JsonObject GetMetadata():
        return super:GetMetadata().
    end method.
    
    method override public logical ValidateFields(input entityData as JsonObject):
        define variable isValid as logical no-undo initial true.
        
        /* Add validation logic */
        if entityData:Has("name") and entityData:GetCharacter("name") = "" then do:
            this-object:AddValidationError("name", "Name cannot be empty").
            isValid = false.
        end.
        
        if entityData:Has("price") and entityData:GetDecimal("price") <= 0 then do:
            this-object:AddValidationError("price", "Price must be greater than zero").
            isValid = false.
        end.
        
        return isValid.
    end method.
    
    /* Add custom methods specific to Products */
    method public JsonObject GetProductsByCategory(input categoryId as integer):
        define variable productRepo as ProductRepository no-undo.
        
        productRepo = cast(this-object:repository, ProductRepository).
        return productRepo:FindProductsByCategory(categoryId).
    end method.
    
end class.
```

### Step 4: Register the Service with ServiceFactory

Update the `ServiceFactory.cls` to register your new service.

```abl
/* Add this to the GetService method in ServiceFactory.cls */
when "products" then
    return new services.ProductService().
```

### Step 5: Update the OpenAPI Specification

Update the OpenAPI specification file (`openapi-specification.yaml`) to include your new entity:

```yaml
# Add paths for the new entity
paths:
  /data/products:
    get:
      summary: Get all products
      # ... rest of the definition
    post:
      summary: Create a new product
      # ... rest of the definition
  
  /data/products/{id}:
    get:
      summary: Get a product by ID
      # ... rest of the definition
    put:
      summary: Update a product
      # ... rest of the definition
    delete:
      summary: Delete a product
      # ... rest of the definition
  
  /meta/products:
    get:
      summary: Get product metadata
      # ... rest of the definition

# Add schema definition for the new entity
components:
  schemas:
    Product:
      type: object
      properties:
        productId:
          type: integer
          description: The unique identifier for the product
        name:
          type: string
          description: The name of the product
        description:
          type: string
          description: The description of the product
        price:
          type: number
          format: decimal
          description: The price of the product
        categoryId:
          type: integer
          description: The category ID of the product
        inStock:
          type: boolean
          description: Whether the product is in stock
        createdDate:
          type: string
          format: date
          description: The date the product was created
      required:
        - name
        - price
        - categoryId
        - inStock
```

## Adding Custom Endpoints

If your entity requires custom endpoints beyond the standard CRUD operations, you'll need to:

1. Add the custom method to your repository class
2. Add the corresponding method to your service class
3. Update the `GenericServiceRefactored.cls` to handle the custom endpoint

Example for adding a custom endpoint to get products by category:

1. First, add the method to the repository (already done in the example above)
2. Then, add the method to the service (already done in the example above)
3. Update `GenericServiceRefactored.cls` to handle the custom endpoint:

```abl
/* Add this to the HandleGet method in GenericServiceRefactored.cls */
if entityName = "products" and poRequest:GetPathSegment(3) = "category" then do:
    var character categoryIdStr = poRequest:GetPathSegment(4).
    var integer categoryId = integer(categoryIdStr).
    var services.ProductService productService = cast(serviceFactory:GetService("products"), services.ProductService).
    joResponse = productService:GetProductsByCategory(categoryId).
    return 200.
end.
```

4. Update the OpenAPI specification to include the custom endpoint:

```yaml
paths:
  /data/products/category/{categoryId}:
    get:
      summary: Get products by category
      description: Returns all products in the specified category
      parameters:
        - name: categoryId
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: A list of products in the category
          content:
            application/json:
              schema:
                type: object
                properties:
                  products:
                    type: array
                    items:
                      $ref: '#/components/schemas/Product'
```

## Testing Your New Entity

After adding your new entity, you should test it to ensure it works correctly:

1. Use the Postman collection to test the API endpoints
2. Update the Postman collection to include your new entity endpoints
3. Use the cURL examples as a reference for testing from the command line
4. Use the Python test script to test programmatically

Example Postman request for the new entity:

```
GET http://localhost:8080/api/v1/data/products
```

Example cURL command:

```bash
curl -X GET "http://localhost:8080/api/v1/data/products" -H "Accept: application/json"
```

## Best Practices

When extending the API with new entities, follow these best practices:

1. **Consistent Naming**: Use consistent naming conventions for your entity, repository, and service classes
2. **Validation**: Implement proper validation in your service class
3. **Error Handling**: Return appropriate error responses with clear messages
4. **Documentation**: Update the OpenAPI specification to document your new entity
5. **Testing**: Test all endpoints thoroughly
6. **Security**: Consider security implications and implement appropriate measures
7. **Performance**: Optimize database queries and consider pagination for large datasets

By following this guide, you can easily extend the GenericServiceRefactored API with new entities while maintaining the architecture and design patterns of the existing codebase.
