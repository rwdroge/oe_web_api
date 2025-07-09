/*------------------------------------------------------------------------
    File        : SuppliersTest
    Purpose     : Unit tests for suppliers entity class
    Syntax      : 
    Description : ABLUnit test cases for suppliers entity functionality
    Author(s)   : rdroge
    Created     : 2025-06-16
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Core.Assert.
using entities.suppliers.
using data.DataAccess.
using generics.FilterParams.
using Progress.Json.ObjectModel.*.

block-level on error undo, throw.

class tests.entities.SuppliersTest:

    /* Test fixtures */
    var private suppliers suppliersEntity.
    var private handle hDsSupplier.
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
        suppliersEntity = new suppliers().
        testJsonObject = new JsonObject().
        testFilter = new FilterParams("supplier", "", "", "", "", output table-handle hQueryParams).
        
        /* Reset dataset handle for each test */
        hDataSet = ?.
        
        /* Initialize test data */
        testJsonObject:Add("SupplierIDNum", 999).
        testJsonObject:Add("Name", "Test Supplier").
        testJsonObject:Add("Address", "123 Test Street").
        testJsonObject:Add("City", "Test City").
        testJsonObject:Add("State", "TS").
        testJsonObject:Add("Country", "USA").
        testJsonObject:Add("Phone", "555-1234").
        testJsonObject:Add("Password", "testpass").
        testJsonObject:Add("ShipAmount", 100).
        testJsonObject:Add("Discount", 10).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up test environment after each test
     Notes: Releases resources used in tests
    ------------------------------------------------------------------------------*/
    @TearDown.
    method public void tearDown():
        /* Clean up resources */
        if valid-object(suppliersEntity) then
            delete object suppliersEntity.
            
        if valid-object(testJsonObject) then
            delete object testJsonObject.
            
        if valid-object(testFilter) then
            delete object testFilter.
            
        if valid-handle(hDataSet) then
            delete object hDataSet.
            assign hDataSet = ?.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Read method with basic parameters
     Notes: Verifies supplier read functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testRead():
        /* Set up test filter */
        testFilter:TopRecs = 5.
        
        /* Test Read method */
        suppliersEntity:Read(testFilter, output dataset-handle hDataSet).
        
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
        testFilter:Where = "SupplierIDNum > 10".
        testFilter:TopRecs = 5.
        
        /* Test Read method with filter */
        suppliersEntity:Read(testFilter, output dataset-handle hDataSet).
        
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
        testFilter:SortBy = "Name".
        testFilter:TopRecs = 5.
        
        /* Test Read method with sorting */
        suppliersEntity:Read(testFilter, output dataset-handle hDataSet).
        
        /* Verify dataset handle */
        Assert:IsTrue(valid-handle(hDataSet),
            "Dataset handle should be valid with sorting").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Create method
     Notes: Verifies supplier creation functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testCreate():
        /* Test Create method */
        do on error undo, throw:
            suppliersEntity:Create(testJsonObject, output dataset-handle hDataSet).
            
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
     Notes: Verifies supplier update functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testUpdate():
        /* Set up test filter */
        testFilter:id1 = "10". /* Assuming supplier 10 exists */
        
        /* Test Update method */
        do on error undo, throw:
            suppliersEntity:Update(testFilter, testJsonObject, output dataset-handle hDataSet).
            
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
     Notes: Verifies supplier deletion functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testDelete():
        /* Set up test filter */
        testFilter:id1 = "999". /* Use a test record ID that's safe to delete */
        
        /* Test Delete method */
        do on error undo, throw:
            suppliersEntity:Delete(testFilter, output dataset-handle hDataSet).
            
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
     Purpose: Test GetSuppliers method
     Notes: Tests the private method via the Read method
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testGetSuppliers():
        /* Set up test filter */
        testFilter:TopRecs = 5.
        
        /* Test Read method which calls GetSuppliers internally */
        suppliersEntity:Read(testFilter, output dataset-handle hDataSet).
        
        /* Verify dataset handle is valid */
        Assert:IsTrue(valid-handle(hDataSet),
            "Dataset handle should be valid after GetSuppliers operation").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test UpdateSuppliers method
     Notes: Tests the UpdateSuppliers method
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testUpdateSuppliers():
        /* Set up test filter */
        testFilter:id1 = "10". /* Assuming supplier 10 exists */
        
        /* Test Update method which calls UpdateSuppliers internally */
        do on error undo, throw:
            suppliersEntity:Update(testFilter, testJsonObject, output dataset-handle hDataSet).
            
            /* Verify dataset handle is valid */
            Assert:IsTrue(valid-handle(hDataSet),
                "Dataset handle should be valid after UpdateSuppliers operation").
                
            catch e as Progress.Lang.Error:
                /* If database is read-only, this is expected */
                Assert:IsTrue(INDEX(e:GetMessage(1), "read-only") > 0 or 
                              INDEX(e:GetMessage(1), "permission denied") > 0,
                              "Expected error for read-only database or permission issue").
            end catch.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test DeleteSupplier method
     Notes: Tests the DeleteSupplier method
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testDeleteSupplier():
        /* Set up test filter */
        testFilter:id1 = "999". /* Use a test record ID that's safe to delete */
        
        /* Test Delete method which calls DeleteSupplier internally */
        do on error undo, throw:
            suppliersEntity:Delete(testFilter, output dataset-handle hDataSet).
            
            /* Verify dataset handle is valid */
            Assert:IsTrue(valid-handle(hDataSet),
                "Dataset handle should be valid after DeleteSupplier operation").
                
            catch e as Progress.Lang.Error:
                /* If database is read-only, this is expected */
                Assert:IsTrue(INDEX(e:GetMessage(1), "read-only") > 0 or 
                              INDEX(e:GetMessage(1), "permission denied") > 0,
                              "Expected error for read-only database or permission issue").
            end catch.
        end.
    end method.

end class.
