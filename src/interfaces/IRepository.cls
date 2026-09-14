/*------------------------------------------------------------------------
    File        : IRepository
    Purpose     : Define standard repository operations
    Syntax      : 
    Description : Interface for repository pattern implementation
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Repository pattern interface for data access abstraction
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using generics.FilterParams.
using Progress.Json.ObjectModel.*.

interface interfaces.IRepository:  
   
    /*------------------------------------------------------------------------------
     Purpose: Find entity by primary key
     Parameters:
       input pcId - Primary key value
     Returns: handle to dataset containing the entity
    ------------------------------------------------------------------------------*/
    method public handle FindById(input pcId as character).
    
    /*------------------------------------------------------------------------------
     Purpose: Find entities by filter criteria
     Parameters:
       input pFilter - Filter parameters
     Returns: handle to dataset containing matching entities
    ------------------------------------------------------------------------------*/
    method public handle FindByFilter(input pFilter as generics.FilterParams).
    
    /*------------------------------------------------------------------------------
     Purpose: Save a new entity
     Parameters:
       input poEntity - JSON object containing entity data
     Returns: handle to dataset containing the created entity
    ------------------------------------------------------------------------------*/
    method public handle Save(input poEntity as JsonObject).
    
    /*------------------------------------------------------------------------------
     Purpose: Update an existing entity
     Parameters:
       input pcId - Entity ID
       input poEntity - JSON object containing updated entity data
     Returns: handle to dataset containing the updated entity
    ------------------------------------------------------------------------------*/
    method public handle UpdateEntity(input pcId as character, input poEntity as JsonObject).
    
    /*------------------------------------------------------------------------------
     Purpose: Delete an entity by primary key
     Parameters:
       input pcId - Primary key value
     Returns: logical indicating success
    ------------------------------------------------------------------------------*/
    method public logical Delete(input pcId as character).
    
    /*------------------------------------------------------------------------------
     Purpose: Get metadata for the entity
     Returns: longchar containing entity metadata
    ------------------------------------------------------------------------------*/
    method public longchar GetMetadata().

end interface.
