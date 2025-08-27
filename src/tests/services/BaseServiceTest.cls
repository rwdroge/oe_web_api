/*------------------------------------------------------------------------
    File        : BaseServiceTest
    Purpose     : Unit tests for BaseService class
    Syntax      : 
    Description : Tests the base service functionality
    Author(s)   : 
    Created     : Tue Jul 08 10:52:18 UTC 2025
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Core.Assert.
using services.BaseService.
using interfaces.IRepository.
using interfaces.IService.
using tests.services.MockRepository.
using generics.FilterParams.

BLOCK-LEVEL ON ERROR UNDO, THROW.



CLASS tests.services.BaseServiceTest INHERITS BaseService:
        CONSTRUCTOR PUBLIC BaseServiceTest(INPUT repository AS IRepository, INPUT entityName AS CHARACTER):
            SUPER(repository, entityName).
        END CONSTRUCTOR.

    
    var private tests.services.MockRepository mockRepository.
    var private tests.services.BaseServiceTest testService.
    
    /*------------------------------------------------------------------------------
     Purpose: Set up test environment before each test
     Notes:   
    ------------------------------------------------------------------------------*/
    @Setup.
    METHOD PUBLIC VOID SetUp():
        mockRepository = NEW MockRepository().
        testService = NEW tests.services.BaseServiceTest(mockRepository, "mock").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test GetById method
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestGetById():
        /* Call GetById method */
        var Progress.Json.ObjectModel.JsonObject result.
        result = testService:GetById("123").
        
        /* Verify result */
        Assert:NotNull(result, "GetById should return a JsonObject").
        Assert:IsTrue(result:GetCharacter("id") = "123", "GetById should return object with correct ID").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test GetByFilter method for retrieving all entities
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestGetAll():
        var generics.FilterParams filterParams.
        var handle hQueryParams.
        var Progress.Json.ObjectModel.JsonObject resultObj.
        var Progress.Json.ObjectModel.JsonArray dataArray.
        var Progress.Json.ObjectModel.JsonObject firstItem.
        
        /* Create filter parameters */
        filterParams = NEW generics.FilterParams("items", "", "", "", "", output table-handle hQueryParams).
        
        /* Call GetByFilter method */
        resultObj = testService:GetByFilter(filterParams).
        
        /* Verify result */
        Assert:NotNull(resultObj, "GetByFilter should return a JsonObject").
        
        /* Extract data array from result if it exists */
        IF resultObj:Has("data") THEN DO:
            
            dataArray = resultObj:GetJsonArray("data").
            
            Assert:NotNull(dataArray, "Result should contain a data array").
            Assert:IsTrue(dataArray:Length >= 1, "Data array should contain at least one item").
            
            IF dataArray:Length >= 1 THEN DO:
                firstItem = dataArray:GetJsonObject(1).
                Assert:NotNull(firstItem, "First item should not be null").
                IF firstItem:Has("id") THEN
                    Assert:IsTrue(firstItem:GetCharacter("id") > "", "First item should have an ID").
            END.
        END.
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Create method
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestCreate():
        var Progress.Json.ObjectModel.JsonObject data.
        var Progress.Json.ObjectModel.JsonObject result.
        
        /* Create test data */
        data = NEW Progress.Json.ObjectModel.JsonObject().
        data:Add("name", "New Test Item").
        
        /* Call Create method */
        result = testService:Create(data).
        
        /* Verify result */
        Assert:NotNull(result, "Create should return a JsonObject").
        Assert:IsTrue(result:GetCharacter("id") = "new-id", "Create should return object with new ID").
        Assert:IsTrue(result:GetCharacter("name") = "New Test Item", "Create should return object with correct name").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Update method
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestUpdate():
        var Progress.Json.ObjectModel.JsonObject data.
        var Progress.Json.ObjectModel.JsonObject result.
        
        /* Create update data */
        data = NEW Progress.Json.ObjectModel.JsonObject().
        data:Add("name", "Updated Test Item").
        
        /* Call Update method */
        result = testService:Update("123", data).
        
        /* Verify result */
        Assert:NotNull(result, "Update should return a JsonObject").
        Assert:IsTrue(result:GetCharacter("id") = "123", "Update should return object with correct ID").
        Assert:IsTrue(result:GetCharacter("name") = "Updated Test Item", "Update should return object with updated name").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Delete method
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestDelete():
        var logical result.
        
        /* Call Delete method */
        result = testService:Delete("123").
        
        /* Verify result */
        Assert:IsTrue(result, "Delete should return TRUE for successful deletion").
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
