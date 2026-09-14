# DataAccess Parameter Object Refactoring

## Overview

This document describes the refactoring of the `DataAccess.attachSource` method to address "Keep unit interfaces small" code quality violations by implementing the parameter object pattern.

## Problem Identified

The `DataAccess.attachSource` method had **7 parameters**, violating the code quality rule for keeping method interfaces small:

```abl
method public void attachSource(
    input pcBuffers as character,
    input pcFields as character,
    input pcSources as character,
    input pcSourceKeys as character,
    input pcKeyValue as character,
    input pFilter as FilterParams,
    input-output dataset-handle phDataSet)
```

## Solution Implemented

### 1. Created DataSourceAttachParams Class

**File:** `src/generics/DataSourceAttachParams.cls`

Encapsulates all attachment parameters:
- `Buffers` (CHARACTER) - Buffer names for the dataset
- `Fields` (CHARACTER) - Fields to include in the query
- `Sources` (CHARACTER) - Data source names
- `SourceKeys` (CHARACTER) - Key fields for the data sources
- `KeyValue` (CHARACTER) - Value for key field filtering
- `Filter` (FilterParams) - Filter parameters (sorting, paging, where clause)
- `DataSet` (DATASET-HANDLE) - Handle to the target dataset

**Key Features:**
- Default constructor for empty initialization
- Convenience constructor with all parameters
- `IsValid()` method for parameter validation
- Proper error handling and validation

### 2. Refactored DataAccess.attachSource Method

**Before:**
```abl
method public void attachSource(
    input pcBuffers as character,
    input pcFields as character,
    input pcSources as character,
    input pcSourceKeys as character,
    input pcKeyValue as character,
    input pFilter as FilterParams,
    input-output dataset-handle phDataSet)
```

**After:**
```abl
method public void attachSource(input params as DataSourceAttachParams)
```

### 3. Updated All Callers

**File:** `src/data/BaseRepository.cls`

Updated all methods that call `attachSource`:
- `FindById()` - Primary key lookup
- `FindByFilter()` - Filtered data retrieval
- `Save()` - New entity creation
- `Update()` - Entity modification
- `Delete()` - Entity removal

**Example transformation:**
```abl
// Before
this-object:Dao:attachSource(
    this-object:TempTableName,
    this-object:PrimaryKeyField,
    this-object:DatabaseTable,
    this-object:PrimaryKeyField,
    pcId,
    filter,
    input-output dataset-handle dshandle by-reference)

// After
VAR DataSourceAttachParams attachParams = NEW DataSourceAttachParams(
    this-object:TempTableName,
    this-object:PrimaryKeyField,
    this-object:DatabaseTable,
    this-object:PrimaryKeyField,
    pcId,
    filter,
    dshandle).
this-object:Dao:attachSource(attachParams)
```

## Benefits Achieved

1. **Reduced Method Complexity**: From 7 parameters to 1 parameter object
2. **Improved Maintainability**: Easier to add new parameters without breaking existing calls
3. **Better Parameter Validation**: Centralized validation in the parameter object
4. **Enhanced Type Safety**: Strongly typed parameter object prevents parameter order mistakes
5. **Consistent Pattern**: Follows the same approach used for `ErrorResponseParams` and `QueryParams`
6. **Better Documentation**: Self-documenting parameter object with clear property names

## Files Modified

### New Files
- `src/generics/DataSourceAttachParams.cls` - Parameter object class

### Modified Files
- `src/data/DataAccess.cls` - Refactored `attachSource` method
- `src/data/BaseRepository.cls` - Updated all callers to use parameter object

### Pending Updates
- `src/tests/data/DataAccessTest.cls` - Test file updates needed

## Code Quality Impact

This refactoring addresses the "Keep unit interfaces small" code quality rule violation by:
- Reducing parameter count from 7 to 1
- Improving method signature readability
- Making the code more maintainable and extensible
- Following established patterns in the codebase

## Testing

The refactoring maintains the same functionality while improving the interface. All existing functionality should work unchanged, but test files need to be updated to use the new parameter object pattern.

## Future Considerations

This parameter object pattern can be applied to other methods in the codebase that have excessive parameters, continuing the effort to improve code quality and maintainability.
