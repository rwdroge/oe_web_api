/*------------------------------------------------------------------------
    File        : MockService
    Purpose     : Mock service implementation for testing
    Syntax      : 
    Description : Provides mock data for unit tests
    Author(s)   : 
    Created     : Tue Jul 08 11:01:23 UTC 2025
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonArray.
USING interfaces.IService.
USING generics.FilterParams.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS tests.mocks.MockService IMPLEMENTS IService:
    
    METHOD PUBLIC CHARACTER GetEntityName():
        RETURN "mock".
    END METHOD.
    
    METHOD PUBLIC JsonObject GetById(INPUT id AS CHARACTER):
        VAR JsonObject jsonObj.
        jsonObj = NEW JsonObject().
        jsonObj:Add("id", id).
        jsonObj:Add("name", "Mock Item " + id).
        RETURN jsonObj.
    END METHOD.
    
    METHOD PUBLIC JsonObject GetByFilter(INPUT pFilter AS generics.FilterParams):
        VAR JsonArray jsonArray.
        VAR JsonObject jsonObj.
        VAR JsonObject response.
        
        jsonArray = NEW JsonArray().
        
        jsonObj = NEW JsonObject().
        jsonObj:Add("id", "1").
        jsonObj:Add("name", "Mock Item 1").
        jsonArray:Add(jsonObj).
        
        jsonObj = NEW JsonObject().
        jsonObj:Add("id", "2").
        jsonObj:Add("name", "Mock Item 2").
        jsonArray:Add(jsonObj).
        
        response = NEW JsonObject().
        response:Add("data", jsonArray).
        response:Add("total", 2).
        
        RETURN response.
    END METHOD.
    
    METHOD PUBLIC JsonObject Create(INPUT data AS JsonObject):
        VAR JsonObject jsonObj.
        jsonObj = NEW JsonObject().
        jsonObj:Add("id", "new-id").
        jsonObj:Add("name", data:GetCharacter("name")).
        RETURN jsonObj.
    END METHOD.
    
    METHOD PUBLIC JsonObject Update(INPUT id AS CHARACTER, INPUT data AS JsonObject):
        VAR JsonObject jsonObj.
        jsonObj = NEW JsonObject().
        jsonObj:Add("id", id).
        jsonObj:Add("name", data:GetCharacter("name")).
        RETURN jsonObj.
    END METHOD.
    
    METHOD PUBLIC LOGICAL Delete(INPUT id AS CHARACTER):
        RETURN TRUE.
    END METHOD.
    
    METHOD PUBLIC JsonObject GetMetadata():
        VAR JsonObject metadata.
        metadata = NEW JsonObject().
        metadata:Add("entity", "mock").
        metadata:Add("fields", NEW JsonArray()).
        RETURN metadata.
    END METHOD.
    
    METHOD PUBLIC LOGICAL ValidateFields(INPUT pcFieldList AS CHARACTER, OUTPUT pcInvalidFields AS CHARACTER):
        pcInvalidFields = "".
        RETURN TRUE.
    END METHOD.
    
    METHOD PUBLIC JsonArray GetEntityFields(INPUT pcEntity AS CHARACTER):
        VAR JsonArray fieldArray.
        VAR JsonObject fieldObj.
        
        fieldArray = NEW JsonArray().
        
        fieldObj = NEW JsonObject().
        fieldObj:Add("name", "id").
        fieldObj:Add("type", "character").
        fieldArray:Add(fieldObj).
        
        fieldObj = NEW JsonObject().
        fieldObj:Add("name", "name").
        fieldObj:Add("type", "character").
        fieldArray:Add(fieldObj).
        
        RETURN fieldArray.
    END METHOD.
    
    METHOD PUBLIC VOID createEntityModel(INPUT phTempTable AS HANDLE, OUTPUT plcModel AS LONGCHAR):
        plcModel = '~{"entity":"mock","fields":[~{"name":"id","type":"character"},~{"name":"name","type":"character"}]}'.
    END METHOD.
    
END CLASS.
