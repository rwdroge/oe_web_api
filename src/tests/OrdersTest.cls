/*------------------------------------------------------------------------
    File        : OrdersTest
    Purpose     : Unit tests for orders entity class
    Syntax      : 
    Description : ABLUnit test cases for orders entity functionality
    Author(s)   : rdroge
    Created     : 2025-06-16
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Core.Assert.
using entities.orders.
using data.DataAccess.
using generics.FilterParams.
using Progress.Json.ObjectModel.*.

block-level on error undo, throw.

class tests.OrdersTest:

    /* Test fixtures */
    var private orders ordersEntity.
    var private handle hDsOrder.
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
        ordersEntity = new orders().
        testJsonObject = new JsonObject().
        testFilter = new FilterParams("order", "", "", "", "", output table-handle hQueryParams).
        
        /* Initialize test data */
        testJsonObject:Add("OrderNum", 99999).
        testJsonObject:Add("CustNum", 1000).
        testJsonObject:Add("OrderDate", TODAY).
        testJsonObject:Add("ShipDate", TODAY + 7).
        testJsonObject:Add("Carrier", "Test Carrier").
        testJsonObject:Add("OrderStatus", "Ordered").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up test environment after each test
     Notes: Releases resources used in tests
    ------------------------------------------------------------------------------*/
    @TearDown.
    method public void tearDown():
        /* Clean up resources */
        if valid-object(ordersEntity) then
            delete object ordersEntity.
            
        if valid-object(testJsonObject) then
            delete object testJsonObject.
            
        if valid-object(testFilter) then
            delete object testFilter.
            
        if valid-handle(hDataSet) then
            delete object hDataSet.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Read method with basic parameters
     Notes: Verifies order read functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testRead():
        /* Set up test filter */
        testFilter:TopRecs = 5.
        
        /* Test Read method */
        ordersEntity:Read(testFilter, output dataset-handle hDataSet).
        
        /* Verify dataset handle is valid */
        Assert:IsTrue(valid-handle(hDataSet),
            "Dataset handle should be valid after Read operation").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Read method with filtering
     Notes: Verifies filter parameter handling
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testReadWithFilter():
        /* Set up test filter with where clause */
        testFilter:Where = "OrderNum > 10000".
        testFilter:TopRecs = 5.
        
        /* Test Read method with filter */
        ordersEntity:Read(testFilter, output dataset-handle hDataSet).
        
        /* Verify dataset handle */
        Assert:IsTrue(valid-handle(hDataSet),
            "Dataset handle should be valid with filter").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Read method with sorting
     Notes: Verifies sort parameter handling
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testReadWithSorting():
        /* Set up test filter with sorting */
        testFilter:SortBy = "OrderDate DESC".
        testFilter:TopRecs = 5.
        
        /* Test Read method with sorting */
        ordersEntity:Read(testFilter, output dataset-handle hDataSet).
        
        /* Verify dataset handle */
        Assert:IsTrue(valid-handle(hDataSet),
            "Dataset handle should be valid with sorting").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Create method
     Notes: Verifies order creation functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testCreate():
        /* Test Create method */
        do on error undo, throw:
            ordersEntity:Create(testJsonObject, output dataset-handle hDataSet).
            
            /* Verify dataset handle is valid */
            Assert:IsTrue(valid-handle(hDataSet),
                "Dataset handle should be valid after Create operation").
                
            catch e as Progress.Lang.Error:
                /* If database is read-only, this is expected */
                Assert:IsTrue(INDEX(e:GetMessage(1), "read-only") > 0 or 
                              INDEX(e:GetMessage(1), "permission denied") > 0,
                              "Expected error for read-only database or permission issue").
            end catch.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Update method
     Notes: Verifies order update functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testUpdate():
        /* Set up test filter */
        testFilter:id1 = "10000". /* Assuming order 10000 exists */
        
        /* Test Update method */
        do on error undo, throw:
            ordersEntity:Update(testFilter, testJsonObject, output dataset-handle hDataSet).
            
            /* Verify dataset handle is valid */
            Assert:IsTrue(valid-handle(hDataSet),
                "Dataset handle should be valid after Update operation").
                
            catch e as Progress.Lang.Error:
                /* If database is read-only, this is expected */
                Assert:IsTrue(INDEX(e:GetMessage(1), "read-only") > 0 or 
                              INDEX(e:GetMessage(1), "permission denied") > 0,
                              "Expected error for read-only database or permission issue").
            end catch.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Delete method
     Notes: Verifies order deletion functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testDelete():
        /* Set up test filter */
        testFilter:id1 = "99999". /* Use a test record ID that's safe to delete */
        
        /* Test Delete method */
        do on error undo, throw:
            ordersEntity:Delete(testFilter, output dataset-handle hDataSet).
            
            /* Verify dataset handle is valid */
            Assert:IsTrue(valid-handle(hDataSet),
                "Dataset handle should be valid after Delete operation").
                
            catch e as Progress.Lang.Error:
                /* If database is read-only, this is expected */
                Assert:IsTrue(INDEX(e:GetMessage(1), "read-only") > 0 or 
                              INDEX(e:GetMessage(1), "permission denied") > 0,
                              "Expected error for read-only database or permission issue").
            end catch.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test GetOrders method
     Notes: Tests the private method via the Read method
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testGetOrders():
        /* Set up test filter */
        testFilter:TopRecs = 5.
        
        /* Test Read method which calls GetOrders internally */
        ordersEntity:Read(testFilter, output dataset-handle hDataSet).
        
        /* Verify dataset handle is valid */
        Assert:IsTrue(valid-handle(hDataSet),
            "Dataset handle should be valid after GetOrders operation").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Updateorders method
     Notes: Tests the Updateorders method
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testUpdateorders():
        /* Set up test filter */
        testFilter:id1 = "10000". /* Assuming order 10000 exists */
        
        /* Test Update method which calls Updateorders internally */
        do on error undo, throw:
            ordersEntity:Update(testFilter, testJsonObject, output dataset-handle hDataSet).
            
            /* Verify dataset handle is valid */
            Assert:IsTrue(valid-handle(hDataSet),
                "Dataset handle should be valid after Updateorders operation").
                
            catch e as Progress.Lang.Error:
                /* If database is read-only, this is expected */
                Assert:IsTrue(INDEX(e:GetMessage(1), "read-only") > 0 or 
                              INDEX(e:GetMessage(1), "permission denied") > 0,
                              "Expected error for read-only database or permission issue").
            end catch.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Deleteorder method
     Notes: Tests the Deleteorder method
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testDeleteorder():
        /* Set up test filter */
        testFilter:id1 = "99999". /* Use a test record ID that's safe to delete */
        
        /* Test Delete method which calls Deleteorder internally */
        do on error undo, throw:
            ordersEntity:Delete(testFilter, output dataset-handle hDataSet).
            
            /* Verify dataset handle is valid */
            Assert:IsTrue(valid-handle(hDataSet),
                "Dataset handle should be valid after Deleteorder operation").
                
            catch e as Progress.Lang.Error:
                /* If database is read-only, this is expected */
                Assert:IsTrue(INDEX(e:GetMessage(1), "read-only") > 0 or 
                              INDEX(e:GetMessage(1), "permission denied") > 0,
                              "Expected error for read-only database or permission issue").
            end catch.
        end.
    end method.

end class.
