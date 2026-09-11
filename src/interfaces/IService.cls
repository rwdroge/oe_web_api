/*------------------------------------------------------------------------
    File        : IService
    Purpose     : Define standard service operations
    Syntax      : 
    Description : Interface for service layer implementation
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Service layer interface for business logic abstraction
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using generics.FilterParams.
using Progress.Json.ObjectModel.*.

interface interfaces.IService:  
   
    /*------------------------------------------------------------------------------
     Purpose: Get entity by ID
     Parameters:
       input pcId - Entity ID
     Returns: JsonObject containing entity data
    ------------------------------------------------------------------------------*/
    method public JsonObject GetById(input pcId as character).
    
    /*------------------------------------------------------------------------------
     Purpose: Get entities by filter criteria
     Parameters:
       input pFilter - Filter parameters
     Returns: JsonObject or JsonArray containing entities
    ------------------------------------------------------------------------------*/
    method public JsonObject GetByFilter(input pFilter as generics.FilterParams).
    
    /*------------------------------------------------------------------------------
     Purpose: Create a new entity
     Parameters:
       input poEntity - JSON object containing entity data
     Returns: JsonObject containing created entity
    ------------------------------------------------------------------------------*/
    method public JsonObject Create(input poEntity as JsonObject).
    
    /*------------------------------------------------------------------------------
     Purpose: Update an existing entity
     Parameters:
       input pcId - Entity ID
       input poEntity - JSON object containing updated entity data
     Returns: JsonObject containing updated entity
    ------------------------------------------------------------------------------*/
    method public JsonObject UpdateEntity(input pcId as character, input poEntity as JsonObject).
    
    /*------------------------------------------------------------------------------
     Purpose: Delete an entity by ID
     Parameters:
       input pcId - Entity ID
     Returns: logical indicating success
    ------------------------------------------------------------------------------*/
    method public logical Delete(input pcId as character).
    
    /*------------------------------------------------------------------------------
     Purpose: Get entity metadata
     Returns: JsonObject containing entity metadata
    ------------------------------------------------------------------------------*/
    method public JsonObject GetMetadata().
    
    /*------------------------------------------------------------------------------
     Purpose: Validate entity fields
     Parameters:
       input pcFieldList - Comma-separated list of fields to validate
     Returns: logical indicating if all fields are valid
    ------------------------------------------------------------------------------*/
    method public logical ValidateFields(input pcFieldList as character, output pcInvalidFields as character).
    
    /*------------------------------------------------------------------------------
     Purpose: Get the name of the entity managed by this service
     Returns: character containing the entity name
    ------------------------------------------------------------------------------*/
    method public character GetEntityName().
    
    /*------------------------------------------------------------------------------
     Purpose: Get fields for a specific entity
     Parameters:
       input pcEntity - Entity name
     Returns: JsonArray containing entity fields
    ------------------------------------------------------------------------------*/
    method public JsonArray GetEntityFields(input pcEntity as character).
    
    /*------------------------------------------------------------------------------
     Purpose: Create a JSON model of an entity's structure
     Parameters:
       input phTempTable - Handle to the temp-table
       output plcModel - Longchar containing the JSON model
     Notes: Builds a JSON object describing the entity's fields and data types
    ------------------------------------------------------------------------------*/
    method public void createEntityModel(
        input phTempTable as handle,
        output plcModel as longchar).

end interface.
