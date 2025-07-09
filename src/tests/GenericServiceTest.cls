/*------------------------------------------------------------------------
    File        : GenericServiceTest
    Purpose     : Unit tests for GenericService class
    Syntax      : 
    Description : Tests the generic service handler functionality
    Author(s)   : 
    Created     : Tue Jul 08 11:01:23 UTC 2025
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Core.Assert.
USING Progress.Web.MappedRequest.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonArray.
USING interfaces.IService.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS tests.GenericServiceTest:
    
    /* Mock service for testing */
    CLASS MockService IMPLEMENTS IService:
        METHOD PUBLIC CHARACTER GetEntityName():
            RETURN "mock".
        END METHOD.
        
        METHOD PUBLIC JsonObject GetById(INPUT id AS CHARACTER):
            DEFINE VARIABLE jsonObj AS JsonObject NO-UNDO.
            jsonObj = NEW JsonObject().
            jsonObj:Add("id", id).
            jsonObj:Add("name", "Mock Item " + id).
            RETURN jsonObj.
        END METHOD.
        
        METHOD PUBLIC JsonArray GetAll(INPUT filter AS CHARACTER, INPUT sort AS CHARACTER, INPUT limit AS INTEGER, INPUT offset AS INTEGER):
            DEFINE VARIABLE jsonArray AS JsonArray NO-UNDO.
            DEFINE VARIABLE jsonObj AS JsonObject NO-UNDO.
            
            jsonArray = NEW JsonArray().
            
            jsonObj = NEW JsonObject().
            jsonObj:Add("id", "1").
            jsonObj:Add("name", "Mock Item 1").
            jsonArray:Add(jsonObj).
            
            jsonObj = NEW JsonObject().
            jsonObj:Add("id", "2").
            jsonObj:Add("name", "Mock Item 2").
            jsonArray:Add(jsonObj).
            
            RETURN jsonArray.
        END METHOD.
        
        METHOD PUBLIC JsonObject Create(INPUT data AS JsonObject):
            DEFINE VARIABLE jsonObj AS JsonObject NO-UNDO.
            jsonObj = NEW JsonObject().
            jsonObj:Add("id", "new-id").
            jsonObj:Add("name", data:GetCharacter("name")).
            RETURN jsonObj.
        END METHOD.
        
        METHOD PUBLIC JsonObject Update(INPUT id AS CHARACTER, INPUT data AS JsonObject):
            DEFINE VARIABLE jsonObj AS JsonObject NO-UNDO.
            jsonObj = NEW JsonObject().
            jsonObj:Add("id", id).
            jsonObj:Add("name", data:GetCharacter("name")).
            RETURN jsonObj.
        END METHOD.
        
        METHOD PUBLIC LOGICAL Delete(INPUT id AS CHARACTER):
            RETURN TRUE.
        END METHOD.
    END CLASS.
    
    /* Mock service factory for testing */
    CLASS MockServiceFactory:
        METHOD PUBLIC IService GetService(INPUT entityName AS CHARACTER):
            IF entityName = "mock" THEN
                RETURN NEW MockService().
            ELSE
                RETURN ?.
        END METHOD.
    END CLASS.
    
    /* Mock request for testing */
    CLASS MockRequest INHERITS Progress.Web.MappedRequest:
        DEFINE PRIVATE VARIABLE pathSegments AS CHARACTER EXTENT NO-UNDO.
        DEFINE PRIVATE VARIABLE queryParams AS Progress.Collections.StringStringMap NO-UNDO.
        DEFINE PRIVATE VARIABLE requestBody AS CHARACTER NO-UNDO.
        
        CONSTRUCTOR PUBLIC MockRequest(INPUT path AS CHARACTER):
            SUPER().
            queryParams = NEW Progress.Collections.StringStringMap().
            
            /* Split path into segments */
            DEFINE VARIABLE segments AS CHARACTER EXTENT NO-UNDO.
            segments = path:SPLIT("/").
            
            /* Remove empty segments */
            DEFINE VARIABLE count AS INTEGER NO-UNDO INITIAL 0.
            DO i = 1 TO EXTENT(segments):
                IF segments[i] NE "" THEN count = count + 1.
            END.
            
            EXTENT(pathSegments) = count.
            count = 0.
            
            DO i = 1 TO EXTENT(segments):
                IF segments[i] NE "" THEN DO:
                    count = count + 1.
                    pathSegments[count] = segments[i].
                END.
            END.
        END CONSTRUCTOR.
        
        METHOD PUBLIC CHARACTER GetPathSegment(INPUT index AS INTEGER):
            IF index > 0 AND index <= EXTENT(pathSegments) THEN
                RETURN pathSegments[index].
            ELSE
                RETURN "".
        END METHOD.
        
        METHOD PUBLIC VOID AddQueryParameter(INPUT name AS CHARACTER, INPUT value AS CHARACTER):
            queryParams:Put(name, value).
        END METHOD.
        
        METHOD PUBLIC CHARACTER GetQueryParameter(INPUT name AS CHARACTER):
            RETURN queryParams:Get(name).
        END METHOD.
        
        METHOD PUBLIC VOID SetRequestBody(INPUT body AS CHARACTER):
            requestBody = body.
        END METHOD.
        
        METHOD PUBLIC CHARACTER GetRequestBody():
            RETURN requestBody.
        END METHOD.
    END CLASS.
    
    DEFINE PRIVATE VARIABLE genericService AS GenericService NO-UNDO.
    DEFINE PRIVATE VARIABLE mockServiceFactory AS MockServiceFactory NO-UNDO.
    
    /*------------------------------------------------------------------------------
     Purpose: Set up test environment before each test
     Notes:   
    ------------------------------------------------------------------------------*/
    @Setup.
    METHOD PUBLIC VOID SetUp():
        mockServiceFactory = NEW MockServiceFactory().
        genericService = NEW GenericService().
        
        /* Use reflection to set the service factory */
        DEFINE VARIABLE serviceFactoryField AS Progress.Reflect.Field NO-UNDO.
        serviceFactoryField = Progress.Reflect.Class:GetClass("GenericService"):GetField("serviceFactory", TRUE).
        serviceFactoryField:Set(genericService, mockServiceFactory).
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test HandleGet method for getting all items
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestHandleGetAll():
        /* Create mock request for getting all items */
        DEFINE VARIABLE request AS MockRequest NO-UNDO.
        request = NEW MockRequest("/data/mock").
        request:AddQueryParameter("limit", "10").
        request:AddQueryParameter("offset", "0").
        
        /* Call HandleGet method */
        DEFINE VARIABLE response AS CHARACTER NO-UNDO.
        response = genericService:HandleGet(request).
        
        /* Verify response */
        Assert:NotNull(response, "HandleGet should return a response").
        Assert:IsTrue(response CONTAINS "Mock Item 1", "Response should contain mock item data").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test HandleGet method for getting a specific item
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestHandleGetById():
        /* Create mock request for getting a specific item */
        DEFINE VARIABLE request AS MockRequest NO-UNDO.
        request = NEW MockRequest("/data/mock/123").
        
        /* Call HandleGet method */
        DEFINE VARIABLE response AS CHARACTER NO-UNDO.
        response = genericService:HandleGet(request).
        
        /* Verify response */
        Assert:NotNull(response, "HandleGet should return a response").
        Assert:IsTrue(response CONTAINS "123", "Response should contain the requested item ID").
        Assert:IsTrue(response CONTAINS "Mock Item 123", "Response should contain the requested item name").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test HandlePost method for creating an item
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestHandlePost():
        /* Create mock request for creating an item */
        DEFINE VARIABLE request AS MockRequest NO-UNDO.
        request = NEW MockRequest("/data/mock").
        request:SetRequestBody('{"name":"New Mock Item"}').
        
        /* Call HandlePost method */
        DEFINE VARIABLE response AS CHARACTER NO-UNDO.
        response = genericService:HandlePost(request).
        
        /* Verify response */
        Assert:NotNull(response, "HandlePost should return a response").
        Assert:IsTrue(response CONTAINS "new-id", "Response should contain the new item ID").
        Assert:IsTrue(response CONTAINS "New Mock Item", "Response should contain the new item name").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test HandlePut method for updating an item
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestHandlePut():
        /* Create mock request for updating an item */
        DEFINE VARIABLE request AS MockRequest NO-UNDO.
        request = NEW MockRequest("/data/mock/123").
        request:SetRequestBody('{"name":"Updated Mock Item"}').
        
        /* Call HandlePut method */
        DEFINE VARIABLE response AS CHARACTER NO-UNDO.
        response = genericService:HandlePut(request).
        
        /* Verify response */
        Assert:NotNull(response, "HandlePut should return a response").
        Assert:IsTrue(response CONTAINS "123", "Response should contain the updated item ID").
        Assert:IsTrue(response CONTAINS "Updated Mock Item", "Response should contain the updated item name").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test HandleDelete method for deleting an item
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestHandleDelete():
        /* Create mock request for deleting an item */
        DEFINE VARIABLE request AS MockRequest NO-UNDO.
        request = NEW MockRequest("/data/mock/123").
        
        /* Call HandleDelete method */
        DEFINE VARIABLE response AS CHARACTER NO-UNDO.
        response = genericService:HandleDelete(request).
        
        /* Verify response */
        Assert:NotNull(response, "HandleDelete should return a response").
        Assert:IsTrue(response CONTAINS "true", "Response should indicate successful deletion").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test handling invalid entity
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestHandleInvalidEntity():
        /* Create mock request for an invalid entity */
        DEFINE VARIABLE request AS MockRequest NO-UNDO.
        request = NEW MockRequest("/data/invalid").
        
        /* Call HandleGet method */
        DEFINE VARIABLE response AS CHARACTER NO-UNDO.
        response = genericService:HandleGet(request).
        
        /* Verify response indicates error */
        Assert:NotNull(response, "HandleGet should return a response for invalid entity").
        Assert:IsTrue(response CONTAINS "error", "Response should contain error indication").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up after tests
     Notes:   
    ------------------------------------------------------------------------------*/
    @TearDown.
    METHOD PUBLIC VOID TearDown():
        /* Nothing to clean up */
    END METHOD.
    
END CLASS.
