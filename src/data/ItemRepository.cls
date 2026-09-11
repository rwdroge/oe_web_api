/*------------------------------------------------------------------------
    File        : ItemRepository
    Purpose     : Repository implementation for items entity
    Syntax      : 
    Description : Provides data access operations for items
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Repository pattern implementation for items entity
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using data.BaseRepository.
using generics.FilterParams.
using Progress.Json.ObjectModel.*.

block-level on error undo, throw.

class data.ItemRepository inherits BaseRepository:
    
    /* Dataset definition for items */
    {entities/inc/items.i}
    
    /* Temp-table for query parameters */
    define temp-table ttQueryParams
        field fieldname   as character 
        field fieldvalue  as character 
        index fieldname is primary unique fieldname ascending
    .
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for ItemRepository
     Notes: Initializes repository with items entity information
    ------------------------------------------------------------------------------*/
    constructor public ItemRepository():
        /* Call super constructor with entity information */
        super("ttitem", "itemnum", "item", "", dataset dsItem).
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get metadata for the items entity
     Returns: longchar containing entity metadata
    ------------------------------------------------------------------------------*/
    method override public longchar GetMetadata():
        var longchar lcModel = "".
        var handle hBuffer = ?.
        
        /* Get the buffer handle for the item temp-table */
        hBuffer = dataset dsItem:get-buffer-handle(1).
        
        /* Use metadata service to create entity model */
        this-object:MetadataService:createEntityModel(hBuffer, output lcModel).
        
        return lcModel.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Find items with advanced filtering
     Parameters:
       input pFilter - Filter parameters
     Returns: handle to dataset containing matching items
     Notes: Example of repository-specific method
    ------------------------------------------------------------------------------*/
    method public handle FindItemsByCategory(input pcCategory as character):
        return this-object:FindByQueryString("category = '" + pcCategory + "'").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public ItemRepository():
        /* Base class destructor will handle DAO cleanup */
        delete ttitem no-error.
    end destructor.
    
end class.
