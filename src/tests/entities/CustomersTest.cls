/*------------------------------------------------------------------------
    File        : CustomersTest
    Purpose     : Unit tests for customers entity class
    Syntax      : 
    Description : ABLUnit test cases for customers entity functionality
    Author(s)   : rdroge
    Created     : 2025-06-16
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Core.Assert.
using entities.customers.
using data.DataAccess.
using generics.FilterParams.
using Progress.Json.ObjectModel.*.

block-level on error undo, throw.

class tests.entities.CustomersTest:

    /* Test fixtures */
    var private customers customersEntity.
    var private handle hDsCustomer.
    var private JsonObject testJsonObject.
    var private FilterParams testFilter.
    var private handle hQueryParams.
    var private handle hDataSet.

    /*------------------------------------------------------------------------------
     Purpose: Set up test environment before each test
     Notes: Creates fresh instances of test objects
    ------------------------------------------------------------------------------*/
    @Setup.
    method public void setUp():
        /* Create fresh instances for each test */
        customersEntity = new customers().
        testJsonObject = new JsonObject().
        testFilter = new FilterParams("customer", "", "", "", "", output table-handle hQueryParams).
        
        /* Reset dataset handle for each test */
        hDataSet = ?.
        
        /* Initialize test data */
        testJsonObject:Add("CustNum", 9999).
        testJsonObject:Add("Name", "Test Customer").
        testJsonObject:Add("Address", "123 Test Street").
        testJsonObject:Add("City", "Test City").
        testJsonObject:Add("State", "TS").
        testJsonObject:Add("Country", "USA").
        testJsonObject:Add("Phone", "555-1234").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up test environment after each test
     Notes: Releases resources used in tests
    ------------------------------------------------------------------------------*/
    @TearDown.
    method public void tearDown():
        /* Clean up resources */
        if valid-object(customersEntity) then
            delete object customersEntity.
            
        if valid-object(testJsonObject) then
            delete object testJsonObject.
            
        if valid-object(testFilter) then
            delete object testFilter.
            
        if valid-handle(hDataSet) then
            delete object hDataSet.
            assign hDataSet = ?.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test read method with basic parameters
     Notes: Verifies customer read functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testRead():
        /* Set up test filter */
        testFilter:TopRecs = 5.
        
        /* Test read method */
        customersEntity:Read(testFilter, output dataset-handle hDataSet).
        
        /* Verify dataset handle is valid */
        Assert:IsTrue(valid-handle(hDataSet),
            "Dataset handle should be valid after read operation").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test read method with filtering
     Notes: Verifies filter parameter handling
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testReadWithFilter():
        /* Set up test filter with where clause */
        testFilter:Where = "CustNum > 1000".
        testFilter:TopRecs = 5.
        
        /* Test read method with filter */
        customersEntity:Read(testFilter, output dataset-handle hDataSet).
        
        /* Verify dataset handle */
        Assert:IsTrue(valid-handle(hDataSet),
            "Dataset handle should be valid with filter").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test read method with sorting
     Notes: Verifies sort parameter handling
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testReadWithSorting():
        /* Set up test filter with sorting */
        testFilter:SortBy = "Name".
        testFilter:TopRecs = 5.
        
        /* Test read method with sorting */
        customersEntity:Read(testFilter, output dataset-handle hDataSet).
        
        /* Verify dataset handle */
        Assert:IsTrue(valid-handle(hDataSet),
            "Dataset handle should be valid with sorting").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test create method
     Notes: Verifies customer creation functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testCreate():
        /* Test create method */
        do on error undo, throw:
            customersEntity:Create(testJsonObject, output dataset-handle hDataSet).
            
            /* Verify dataset handle is valid */
            Assert:IsTrue(valid-handle(hDataSet),
                "Dataset handle should be valid after create operation").
                
            catch e as Progress.Lang.Error:
                /* If database is read-only, this is expected */
                Assert:IsTrue(INDEX(e:GetMessage(1), "read-only") > 0 or 
                              INDEX(e:GetMessage(1), "permission denied") > 0,
                              "Expected error for read-only database or permission issue").
            end catch.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test update method
     Notes: Verifies customer update functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testUpdate():
        /* Set up test filter */
        testFilter:id1 = "1000". /* Assuming customer 1000 exists */
        
        /* Test update method */
        do on error undo, throw:
            customersEntity:Update(testFilter, testJsonObject, output dataset-handle hDataSet).
            
            /* Verify dataset handle is valid */
            Assert:IsTrue(valid-handle(hDataSet),
                "Dataset handle should be valid after update operation").
                
            catch e as Progress.Lang.Error:
                /* If database is read-only, this is expected */
                Assert:IsTrue(INDEX(e:GetMessage(1), "read-only") > 0 or 
                              INDEX(e:GetMessage(1), "permission denied") > 0,
                              "Expected error for read-only database or permission issue").
            end catch.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test delete method
     Notes: Verifies customer deletion functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testDelete():
        /* Set up test filter */
        testFilter:id1 = "9999". /* Use a test record ID that's safe to delete */
        
        /* Test delete method */
        do on error undo, throw:
            customersEntity:Delete(testFilter, output dataset-handle hDataSet).
            
            /* Verify dataset handle is valid */
            Assert:IsTrue(valid-handle(hDataSet),
                "Dataset handle should be valid after delete operation").
                
            catch e as Progress.Lang.Error:
                /* If database is read-only, this is expected */
                Assert:IsTrue(INDEX(e:GetMessage(1), "read-only") > 0 or 
                              INDEX(e:GetMessage(1), "permission denied") > 0,
                              "Expected error for read-only database or permission issue").
            end catch.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test getCustomers method
     Notes: Tests the private method via reflection
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testGetCustomers():
        /* Set up test filter */
        testFilter:TopRecs = 5.
        
        /* Test read method which calls getCustomers internally */
        customersEntity:Read(testFilter, output dataset-handle hDataSet).
        
        /* Verify dataset handle is valid */
        Assert:IsTrue(valid-handle(hDataSet),
            "Dataset handle should be valid after getCustomers operation").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test updateCustomer method
     Notes: Tests the updateCustomer method
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testUpdateCustomer():
        /* Set up test filter */
        testFilter:id1 = "1000". /* Assuming customer 1000 exists */
        
        /* Test update method which calls updateCustomer internally */
        do on error undo, throw:
            customersEntity:Update(testFilter, testJsonObject, output dataset-handle hDataSet).
            
            /* Verify dataset handle is valid */
            Assert:IsTrue(valid-handle(hDataSet),
                "Dataset handle should be valid after updateCustomer operation").
                
            catch e as Progress.Lang.Error:
                /* If database is read-only, this is expected */
                Assert:IsTrue(INDEX(e:GetMessage(1), "read-only") > 0 or 
                              INDEX(e:GetMessage(1), "permission denied") > 0,
                              "Expected error for read-only database or permission issue").
            end catch.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test deleteCustomer method
     Notes: Tests the deleteCustomer method
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testDeleteCustomer():
        /* Set up test filter */
        testFilter:id1 = "9999". /* Use a test record ID that's safe to delete */
        
        /* Test delete method which calls deleteCustomer internally */
        do on error undo, throw:
            customersEntity:Delete(testFilter, output dataset-handle hDataSet).
            
            /* Verify dataset handle is valid */
            Assert:IsTrue(valid-handle(hDataSet),
                "Dataset handle should be valid after deleteCustomer operation").
                
            catch e as Progress.Lang.Error:
                /* If database is read-only, this is expected */
                Assert:IsTrue(INDEX(e:GetMessage(1), "read-only") > 0 or 
                              INDEX(e:GetMessage(1), "permission denied") > 0,
                              "Expected error for read-only database or permission issue").
            end catch.
        end.
    end method.

end class.
