  
 /*------------------------------------------------------------------------
    File        : items 
    Syntax      : 
    Author(s)   : rdroge
    Created     : Thu Dec 13 10:02:58 CET 2018
    Notes       : Updated to use repository pattern
  ----------------------------------------------------------------------*/


using Progress.Lang.*.
using OpenEdge.BusinessLogic.BusinessEntity.
using Progress.Json.ObjectModel.*.
using data.*.

block-level on error undo, throw.

class entities.items inherits BusinessEntity implements interfaces.CRUD:
    /*------------------------------------------------------------------------------
            Purpose: Entity class for items using repository pattern                                                                     
            Notes: Refactored to use ItemRepository for data access                                                                       
    ------------------------------------------------------------------------------*/
    
    {"entities/inc/items.i"}
     
    define public property ttName as character no-undo initial "ttitem" get. set. 
    define public property piName as character no-undo initial "itemnum" get. set.
    define public property dbName as character no-undo initial "item" get. set.
    
    /* Repository for data access operations */
    var data.ItemRepository itemRepository.
    /*------------------------------------------------------------------------------
            Purpose: Initialize the items entity                                                                      
            Notes: Creates repository instance                                                                        
    ------------------------------------------------------------------------------*/
    constructor public items():
        super (dataset dsItem:HANDLE).
        
        /* Initialize repository */
        itemRepository = new data.ItemRepository().
    end constructor.
   
        method public void Read(input filter as generics.FilterParams, output dataset-handle hDataSet):
        /* Use repository to get items */
        hDataSet = itemRepository:FindByFilter(filter).
    end method.
    
    method public void Create(input jsonObject as JsonObject, output dataset-handle hDataSet):
        /* Use repository to create item */
        hDataSet = itemRepository:Save(jsonObject).
    end method.
    
    method public void update(input filter as generics.FilterParams, input jsonObject as JsonObject, output dataset-handle hDataSet):
        /* Use repository to update item */
        hDataSet = itemRepository:Update(filter:id1, jsonObject).
    end method.
    
    method public void Delete(input filter as generics.FilterParams, output dataset-handle hDataSet):
        /* Use repository to delete item */
        var logical lSuccess = itemRepository:Delete(filter:id1).
        
        /* Return dataset for consistency with interface */
        hDataSet = itemRepository:FindById(filter:id1).
    end method.
        
    /*------------------------------------------------------------------------------
            Purpose:  Get one or more records, based on a filter string                                                                     
            Notes:  Now uses repository pattern                                                                      
    ------------------------------------------------------------------------------*/
    method private void GetItems( input filter as generics.FilterParams, output DATASET dsItem ):
        /* This method is kept for backward compatibility */
        dataset dsItem:handle = itemRepository:FindByFilter(filter).
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose:  Update one or more records                                                                  
            Notes:  Now uses repository pattern                                                                      
    ------------------------------------------------------------------------------*/
    method public void Updateitems(input filter as generics.FilterParams, input-output DATASET dsItem):
        /* Convert dataset to JSON for repository update */
        var JsonObject updateJson = new JsonObject().
        updateJson:Read(dataset dsItem:get-buffer-handle(1):table-handle).
        
        /* Use repository to update */
        dataset dsItem:handle = itemRepository:Update(filter:id1, updateJson).
        
        finally:
            delete object updateJson no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose:    Delete a record                                                               
            Notes:  Now uses repository pattern                                                                      
    ------------------------------------------------------------------------------*/
    method public void Deleteitem(input-output DATASET dsItem):
        /* Get ID from dataset */
        var character itemId = dataset dsItem:get-buffer-handle(1):buffer-field("itemnum"):buffer-value().
        
        /* Use repository to delete */
        itemRepository:Delete(itemId).
    end method.     

    /* CheckFieldList, CheckValueList, and CreateEntityModel methods are included from metadata.i */
    
    destructor public items():
        delete object itemRepository no-error.
        delete ttitem no-error.
    end destructor.
    
end class.
