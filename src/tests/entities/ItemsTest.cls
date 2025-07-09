/*------------------------------------------------------------------------
    File        : ItemsTest
    Purpose     : Unit tests for items entity class
    Syntax      : 
    Description : ABLUnit test cases for items entity functionality
    Author(s)   : rdroge
    Created     : 2025-06-16
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Core.Assert.
using entities.items.
using data.DataAccess.
using generics.FilterParams.
using Progress.Json.ObjectModel.*.

block-level on error undo, throw.

class tests.entities.ItemsTest:

    /* Test fixtures */
    var private items itemsEntity.
    var private handle hDsItem.
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
        itemsEntity = new items().
        testJsonObject = new JsonObject().
        testFilter = new FilterParams("item", "", "", "", "", output table-handle hQueryParams).
        
        /* Reset dataset handle for each test */
        hDataSet = ?.
        
        /* Initialize test data */
        testJsonObject:Add("Itemnum", 9999).
        testJsonObject:Add("ItemName", "Test Item").
        testJsonObject:Add("Price", 99.99).
        testJsonObject:Add("Onhand", 100).
        testJsonObject:Add("Category1", "Test Category").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up test environment after each test
     Notes: Releases resources used in tests
    ------------------------------------------------------------------------------*/
    @TearDown.
    method public void tearDown():
        /* Clean up resources */
        if valid-object(itemsEntity) then
            delete object itemsEntity.
            
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
     Notes: Verifies item read functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testRead():
        /* Set up test filter */
        testFilter:TopRecs = 5.
        
        /* Test Read method */
        itemsEntity:Read(testFilter, output dataset-handle hDataSet).
        
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
        testFilter:Where = "Itemnum > 100".
        testFilter:TopRecs = 5.
        
        /* Test Read method with filter */
        itemsEntity:Read(testFilter, output dataset-handle hDataSet).
        
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
        testFilter:SortBy = "ItemName".
        testFilter:TopRecs = 5.
        
        /* Test Read method with sorting */
        itemsEntity:Read(testFilter, output dataset-handle hDataSet).
        
        /* Verify dataset handle */
        Assert:IsTrue(valid-handle(hDataSet),
            "Dataset handle should be valid with sorting").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Create method
     Notes: Verifies item creation functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testCreate():
        /* Test Create method */
        do on error undo, throw:
            itemsEntity:Create(testJsonObject, output dataset-handle hDataSet) no-error.
            hDataSet:write-json('file', 'test.json').

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
     Purpose: Test update method
     Notes: Verifies item update functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testUpdate():
        /* Set up test filter */
        testFilter:id1 = "100". /* Assuming item 100 exists */
        
        /* Test update method */
        do on error undo, throw:
            itemsEntity:Update(testFilter, testJsonObject, output dataset-handle hDataSet).
            
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
     Purpose: Test Delete method
     Notes: Verifies item deletion functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testDelete():
        /* Set up test filter */
        testFilter:id1 = "9999". /* Use a test record ID that's safe to delete */
        
        /* Test Delete method */
        do on error undo, throw:
            itemsEntity:Delete(testFilter, output dataset-handle hDataSet).
            
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
     Purpose: Test GetItems method
     Notes: Tests the private method via the Read method
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testGetItems():
        /* Set up test filter */
        testFilter:TopRecs = 5.
        
        /* Test Read method which calls GetItems internally */
        itemsEntity:Read(testFilter, output dataset-handle hDataSet).
        
        /* Verify dataset handle is valid */
        Assert:IsTrue(valid-handle(hDataSet),
            "Dataset handle should be valid after GetItems operation").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Updateitems method
     Notes: Tests the Updateitems method
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testUpdateitems():
        /* Set up test filter */
        testFilter:id1 = "100". /* Assuming item 100 exists */
        
        /* Test update method which calls Updateitems internally */
        do on error undo, throw:
            itemsEntity:Update(testFilter, testJsonObject, output dataset-handle hDataSet).
            
            /* Verify dataset handle is valid */
            Assert:IsTrue(valid-handle(hDataSet),
                "Dataset handle should be valid after Updateitems operation").
                
            catch e as Progress.Lang.Error:
                /* If database is read-only, this is expected */
                Assert:IsTrue(INDEX(e:GetMessage(1), "read-only") > 0 or 
                              INDEX(e:GetMessage(1), "permission denied") > 0,
                              "Expected error for read-only database or permission issue").
            end catch.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Deleteitem method
     Notes: Tests the Deleteitem method
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testDeleteitem():
        /* Set up test filter */
        testFilter:id1 = "9999". /* Use a test record ID that's safe to delete */
        
        /* Test Delete method which calls Deleteitem internally */
        do on error undo, throw:
            itemsEntity:Delete(testFilter, output dataset-handle hDataSet).
            
            /* Verify dataset handle is valid */
            Assert:IsTrue(valid-handle(hDataSet),
                "Dataset handle should be valid after Deleteitem operation").
                
            catch e as Progress.Lang.Error:
                /* If database is read-only, this is expected */
                Assert:IsTrue(INDEX(e:GetMessage(1), "read-only") > 0 or 
                              INDEX(e:GetMessage(1), "permission denied") > 0,
                              "Expected error for read-only database or permission issue").
            end catch.
        end.
    end method.

end class.
