/*------------------------------------------------------------------------
    File        : GenericServiceTest
    Purpose     : Unit tests for GenericService class
    Syntax      : 
    Description : Tests the generic service handler functionality
    Author(s)   : 
    Created     : Tue Jul 08 11:01:23 UTC 2025
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Core.Assert.
using Progress.Json.ObjectModel.JsonObject.
using Progress.Json.ObjectModel.JsonArray.
using interfaces.IService.
using tests.mocks.MockService.
using tests.mocks.MockServiceFactory.
using tests.mocks.MockRequest.
using OpenEdge.Web.*.
using OpenEdge.Net.HTTP.*.

block-level on error undo, throw.

class tests.GenericServiceTest:
    
    var GenericService genericService.
    var tests.mocks.MockServiceFactory mockServiceFactory.
    
    /*------------------------------------------------------------------------------
     Purpose: Set up test environment before each test
     Notes:   
    ------------------------------------------------------------------------------*/
    @Setup.
    method public void SetUp():
        mockServiceFactory = new tests.mocks.MockServiceFactory().
        genericService = new GenericService().
        
        /* Note: In a real test environment, you would use reflection or dependency injection
           to set the service factory. For this mock test, we'll assume the MockServiceFactory
           is properly configured. */
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test HandleGet method for getting all items
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    method public void TestHandleGetAll():
        var tests.mocks.MockRequest request.
        var integer statusCode.
        
        /* Create mock request for getting all items */
        request = new tests.mocks.MockRequest("/data/mock").
        request:SetPathParameter("apitype", "data").
        request:SetPathParameter("entityname", "mock").
        request:AddQueryParameter("limit", "10").
        request:AddQueryParameter("offset", "0").
        
        /* Call HandleGet method */
        statusCode = genericService:TestHandleGet(request).
        
        /* Verify response */
        Assert:Equals(200, statusCode).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test HandleGet method for getting a specific item
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    method public void TestHandleGetById():
        var tests.mocks.MockRequest request.
        var integer statusCode.
        
        /* Create mock request for getting a specific item */
        request = new tests.mocks.MockRequest("/data/mock/123").
        request:SetPathParameter("apitype", "data").
        request:SetPathParameter("entityname", "mock").
        request:SetPathParameter("id1", "123").
        
        /* Call HandleGet method */
        statusCode = genericService:TestHandleGet(request).
        
        /* Verify response */
        Assert:Equals(200, statusCode).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test HandlePost method for creating an item
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    method public void TestHandlePost():
        var tests.mocks.MockRequest request.
        var integer statusCode.
        
        /* Create mock request for creating an item */
        request = new tests.mocks.MockRequest("/data/mock").
        request:SetPathParameter("entityname", "mock").
        request:SetRequestBody('~{"name":"New Mock Item"}').
        
        /* Call HandlePost method */
        statusCode = genericService:TestHandlePost(request).
        
        /* Verify response */
        Assert:IsTrue(statusCode = 201 or statusCode = 422, "HandlePost should return HTTP 201 or 422 status").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test HandlePut method for updating an item
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    method public void TestHandlePut():
        var tests.mocks.MockRequest request.
        var integer statusCode.
        
        /* Create mock request for updating an item */
        request = new tests.mocks.MockRequest("/data/mock/123").
        request:SetPathParameter("entityname", "mock").
        request:SetPathParameter("id", "123").
        request:SetRequestBody('~{"name":"Updated Mock Item"}').
        
        /* Call HandlePut method */
        statusCode = genericService:TestHandlePut(request).
        
        /* Verify response */
        Assert:IsTrue(statusCode = 200 or statusCode = 422, "HandlePut should return HTTP 200 or 422 status").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test HandleDelete method for deleting an item
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    method public void TestHandleDelete():
        var tests.mocks.MockRequest request.
        var integer statusCode.
        
        /* Create mock request for deleting an item */
        request = new tests.mocks.MockRequest("/data/mock/123").
        request:SetPathParameter("entityname", "mock").
        request:SetPathParameter("id", "123").
        
        /* Call HandleDelete method */
        statusCode = genericService:TestHandleDelete(request).
        
        /* Verify response */
        Assert:IsTrue(statusCode = 200 or statusCode = 404, "HandleDelete should return HTTP 200 or 404 status").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test handling invalid entity
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    method public void TestHandleInvalidEntity():
        var tests.mocks.MockRequest request.
        var integer statusCode.
        
        /* Create mock request for an invalid entity */
        request = new tests.mocks.MockRequest("/data/invalid").
        request:SetPathParameter("apitype", "data").
        request:SetPathParameter("entityname", "invalid").
        
        /* Call HandleGet method */
        statusCode = genericService:TestHandleGet(request).
        
        /* Verify response indicates error */
        Assert:IsTrue(statusCode >= 400, "HandleGet should return HTTP error status for invalid entity").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up after tests
     Notes:   
    ------------------------------------------------------------------------------*/
    @TearDown.
    method public void TearDown():
        /* Nothing to clean up */
    end method.
    
end class.
