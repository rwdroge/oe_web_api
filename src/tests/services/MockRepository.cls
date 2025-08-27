/*------------------------------------------------------------------------
    File        : MockRepository
    Purpose     : Mock implementation of IRepository for testing
    Syntax      : 
    Description : Mock repository for testing BaseService functionality
    Author(s)   : 
    Created     : Tue Jul 08 12:09:15 UTC 2025
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using interfaces.IRepository.
using generics.FilterParams.

block-level on error undo, throw.

class tests.services.MockRepository implements IRepository:
    method public character GetEntityName():
        return "mock".
    end method. 
    
    /*------------------------------------------------------------------------------
     Purpose: Find entity by primary key as required by IRepository interface
     Parameters:
       input pcId - Primary key value
     Returns: handle to dataset containing the entity
    ------------------------------------------------------------------------------*/
    method public handle FindById(input pcId as character):
        define variable hDataset as handle no-undo.
        define variable hTempTable as handle no-undo.
        define variable hBuffer as handle no-undo.
        
        create temp-table hTempTable.
        hTempTable:add-new-field("id", "character").
        hTempTable:add-new-field("name", "character").
        hTempTable:temp-table-prepare("MockEntity").
        
        create dataset hDataset.
        hDataset:add-buffer(hTempTable:default-buffer-handle).
        hBuffer = hTempTable:default-buffer-handle.
        
        hBuffer:buffer-create().
        hBuffer:buffer-field("id"):buffer-value = pcId.
        hBuffer:buffer-field("name"):buffer-value = "Mock Item " + pcId.
        
        return hDataset.
    end method.
    
    method public Progress.Json.ObjectModel.JsonObject GetById(input id as character):
        define variable jsonObj as Progress.Json.ObjectModel.JsonObject no-undo.
        jsonObj = new Progress.Json.ObjectModel.JsonObject().
        jsonObj:Add("id", id).
        jsonObj:Add("name", "Mock Item " + id).
        return jsonObj.
    end method.
    
    method public Progress.Json.ObjectModel.JsonArray GetAll(input filter as character, input sort as character, input limit as integer, input offset as integer):
        define variable jsonArray as Progress.Json.ObjectModel.JsonArray no-undo.
        define variable jsonObj as Progress.Json.ObjectModel.JsonObject no-undo.
        define variable i as integer no-undo.
        
        jsonArray = new Progress.Json.ObjectModel.JsonArray().
        
        do i = 1 to 5:
            jsonObj = new Progress.Json.ObjectModel.JsonObject().
            jsonObj:Add("id", string(i)).
            jsonObj:Add("name", "Mock Item " + string(i)).
            jsonArray:Add(jsonObj).
        end.
        
        return jsonArray.
    end method.
    
    method public Progress.Json.ObjectModel.JsonObject Create(input data as Progress.Json.ObjectModel.JsonObject):
        define variable jsonObj as Progress.Json.ObjectModel.JsonObject no-undo.
        define variable id as character no-undo.
        
        id = string(random(1, 1000)).
        jsonObj = new Progress.Json.ObjectModel.JsonObject().
        jsonObj:Add("id", id).
        jsonObj:Add("name", data:GetCharacter("name")).
        
        return jsonObj.
    end method.
    
    method public handle Update(input id as character, input data as Progress.Json.ObjectModel.JsonObject):
        define variable hDataset as handle no-undo.
        define variable hTempTable as handle no-undo.
        define variable hBuffer as handle no-undo.
        
        create temp-table hTempTable.
        hTempTable:add-new-field("id", "character").
        hTempTable:add-new-field("name", "character").
        hTempTable:temp-table-prepare("MockEntity").
        
        create dataset hDataset.
        hDataset:add-buffer(hTempTable:default-buffer-handle).
        hBuffer = hTempTable:default-buffer-handle.
        
        hBuffer:buffer-create().
        hBuffer:buffer-field("id"):buffer-value = id.
        hBuffer:buffer-field("name"):buffer-value = data:GetCharacter("name").
        
        return hDataset.
    end method.
    
    method public logical Delete(input id as character):
        return true.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Find entities by filter criteria
     Parameters:
       input pFilter - Filter parameters
     Returns: handle to dataset containing matching entities
    ------------------------------------------------------------------------------*/
    method public handle FindByFilter(input pFilter as generics.FilterParams):
        define variable hDataset as handle no-undo.
        define variable hTempTable as handle no-undo.
        define variable hBuffer as handle no-undo.
        define variable i as integer no-undo.
        
        create temp-table hTempTable.
        hTempTable:add-new-field("id", "character").
        hTempTable:add-new-field("name", "character").
        hTempTable:temp-table-prepare("MockEntity").
        
        create dataset hDataset.
        hDataset:add-buffer(hTempTable:default-buffer-handle).
        hBuffer = hTempTable:default-buffer-handle.
        
        do i = 1 to 5:
            hBuffer:buffer-create().
            hBuffer:buffer-field("id"):buffer-value = string(i).
            hBuffer:buffer-field("name"):buffer-value = "Mock Item " + string(i).
        end.
        
        return hDataset.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get metadata for the entity
     Returns: longchar containing entity metadata
    ------------------------------------------------------------------------------*/
    method public longchar GetMetadata():
        define variable lcMetadata as longchar no-undo.
        
        lcMetadata = '~{"entity"~:"MockEntity","fields"~:[~{"name"~:"id","type"~:"character","label"~:"ID","required"~:true~},~{"name"~:"name","type"~:"character","label"~:"Name","required"~:true~}]~}'.
        
        return lcMetadata.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Save a new entity
     Parameters:
       input poEntity - JSON object containing entity data
     Returns: handle to dataset containing the created entity
    ------------------------------------------------------------------------------*/
    method public handle Save(input poEntity as Progress.Json.ObjectModel.JsonObject):
        define variable hDataset as handle no-undo.
        define variable hTempTable as handle no-undo.
        define variable hBuffer as handle no-undo.
        define variable cId as character no-undo.
        
        cId = string(random(1, 1000)).
        
        create temp-table hTempTable.
        hTempTable:add-new-field("id", "character").
        hTempTable:add-new-field("name", "character").
        hTempTable:temp-table-prepare("MockEntity").
        
        create dataset hDataset.
        hDataset:add-buffer(hTempTable:default-buffer-handle).
        hBuffer = hTempTable:default-buffer-handle.
        
        hBuffer:buffer-create().
        hBuffer:buffer-field("id"):buffer-value = cId.
        hBuffer:buffer-field("name"):buffer-value = poEntity:GetCharacter("name").
        
        return hDataset.
    end method.
end class.
