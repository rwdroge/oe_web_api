# Parameter Object Refactoring

## Overview
This document describes the refactoring performed to address code quality issues related to methods with too many parameters, following the "Keep unit interfaces small" rule.

## Problem
Several ABL components in the project violated the code quality rule by having methods with many parameters (4-5+ parameters), making them inconvenient to call and indicating a lack of abstraction.

## Solution
Introduced parameter objects to encapsulate related parameters and reduce method parameter counts.

## Changes Made

### 1. Created Parameter Object Classes

#### ErrorResponseParams (`/src/generics/ErrorResponseParams.cls`)
- **Purpose**: Encapsulates parameters for error response creation
- **Properties**:
  - `StatusCode` (integer) - HTTP status code
  - `ErrorMessage` (character) - Error message
  - `Details` (character) - Optional error details
  - `EntityName` (character) - Entity context
  - `ResourceName` (character) - Resource context
  - `MethodName` (character) - Method context
  - `Id` (character) - Entity ID
- **Methods**:
  - `SetEntityContext()` - Set entity and ID
  - `SetResourceContext()` - Set resource and method
  - `HasEntityContext()`, `HasResourceContext()`, `HasDetails()`, `HasId()` - Validation methods

#### QueryParams (`/src/generics/QueryParams.cls`)
- **Purpose**: Encapsulates parameters for query operations
- **Properties**:
  - `Filter` (character) - Filter criteria
  - `Sort` (character) - Sort criteria
  - `Limit` (integer) - Result limit
  - `Offset` (integer) - Result offset
  - `SearchTerm` (character) - Search term
  - `SearchFields` (character) - Fields to search
- **Methods**:
  - `SetPagination()` - Set limit and offset
  - `SetSearch()` - Set search parameters
  - Various `Has*()` validation methods

### 2. Refactored Methods

#### GenericService.CreateErrorResponse
- **Before**: 5 parameters (`piStatusCode`, `pcError`, `pcEntity`, `pcDetails`, `pcId`)
- **After**: 1 parameter (`poErrorParams as ErrorResponseParams`)
- **Benefits**: Cleaner interface, easier to extend, better maintainability

#### MCPHandler.CreateErrorResponse
- **Before**: 4 parameters (`pcError`, `pcResource`, `pcMethod`, `pcDetails`)
- **After**: 1 parameter (`poErrorParams as ErrorResponseParams`)
- **Benefits**: Consistent with GenericService pattern, reusable parameter object

#### MockRepository.GetAll
- **Before**: 4 parameters (`filter`, `sort`, `limit`, `offset`)
- **After**: 1 parameter (`poQueryParams as QueryParams`)
- **Benefits**: Extensible for future query parameters, cleaner interface

### 3. Updated Callers
- Updated `GenericService.HandleNotAllowedMethod()` to use `ErrorResponseParams`
- Updated `GenericServiceTest.cls` mock implementation to match new signature

## Benefits

1. **Reduced Parameter Count**: Methods now have 1 parameter instead of 4-5
2. **Better Abstraction**: Related parameters are grouped logically
3. **Easier Maintenance**: Adding new parameters doesn't require changing method signatures
4. **Improved Readability**: Parameter objects make intent clearer
5. **Reusability**: Parameter objects can be reused across different methods
6. **Type Safety**: Properties provide better type checking than individual parameters

## Usage Examples

### ErrorResponseParams
```abl
/* Old way */
joError = CreateErrorResponse(404, "Not found", "customers", "Customer not found", "123").

/* New way */
var ErrorResponseParams errorParams = new ErrorResponseParams(404, "Not found").
errorParams:SetEntityContext("customers", "123").
errorParams:Details = "Customer not found".
joError = CreateErrorResponse(errorParams).
```

### QueryParams
```abl
/* Old way */
jsonArray = GetAll("status='active'", "name", 10, 0).

/* New way */
var QueryParams queryParams = new QueryParams("status='active'", "name", 10, 0).
jsonArray = GetAll(queryParams).
```

## Future Considerations

1. Consider applying this pattern to other methods with 3+ parameters
2. Evaluate creating additional parameter objects for common parameter patterns
3. Consider adding validation logic to parameter objects
4. Document parameter object patterns in coding standards

## Files Modified

- `/src/generics/ErrorResponseParams.cls` (new)
- `/src/generics/QueryParams.cls` (new)
- `/src/GenericService.cls` (modified)
- `/src/mcp/MCPHandler.cls` (modified)
- `/src/tests/services/MockRepository.cls` (modified)
- `/src/tests/GenericServiceTest.cls` (modified)
