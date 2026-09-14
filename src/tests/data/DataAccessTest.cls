/*------------------------------------------------------------------------
    File        : DataAccessTest
    Purpose     : Unit tests for DataAccess class
    Syntax      : 
    Description : ABLUnit test cases for data access functionality
    Author(s)   : rdroge
    Created     : 2025-05-20
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Core.Assert.
using data.DataAccess.
using generics.FilterParams.
using generics.DataSourceAttachParams.

block-level on error undo, throw.

class tests.data.DataAccessTest:

    /* Test fixtures */
    var private DataAccess dataAccess.
    var private handle hTestDataset.
    var private handle hQueryParams.
    var private handle hCustomerBuffer.

    define private temp-table ttQueryParams
        field fieldname   as character 
        field fieldvalue  as character 
        index fieldname is primary unique fieldname ascending
        .  
    
    /*------------------------------------------------------------------------------
     Purpose: Set up test environment before each test
     Notes: Creates fresh instances of test objects
    ------------------------------------------------------------------------------*/
    @Setup.
    method public void setUp():
        /* Create fresh instances for each test */
        dataAccess = new DataAccess().
        
        /* Reset dataset handle for each test */
        hTestDataset = ?.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up test environment after each test
     Notes: Releases resources used in tests
    ------------------------------------------------------------------------------*/
    @TearDown.
    method public void tearDown():
        /* Clean up resources */
        if valid-handle(hTestDataset) then
            delete object hTestDataset.
            assign hTestDataset = ?.
        
        /* Clean up buffer handle if it exists */
        if valid-handle(hCustomerBuffer) then
            delete object hCustomerBuffer.
        
        if valid-object(dataAccess) then
            delete object dataAccess.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test attachSource with basic parameters
     Notes: Verifies basic data source attachment functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testBasicAttachSource():
        /* Test variables */
        var FilterParams filter.
        var DataSourceAttachParams attachParams.
        
        /* Create test filter */
        filter = new FilterParams(
            "customer",     /* pcentity */
            "",            /* pcquerystring */
            "",            /* pcid1 */
            output table ttQueryParams  /* output table */
        ).
        filter:TopRecs = 10.
        
        /* Test attachSource with minimal parameters */
        attachParams = new DataSourceAttachParams(
            "customer",           /* buffers */
            "CustNum,Name",      /* dsFields */
            "Customer",          /* sources */
            "CustNum",          /* sourceKeys */
            "",                  /* keyValue */
            filter,             /* filter */
            hTestDataset        /* dsDataSet */
        ).
        
        dataAccess:attachSource(attachParams).
        
        /* Verify dataset handle is valid */
        Assert:IsTrue(valid-handle(hTestDataset),
            "Dataset handle should be valid after attachSource").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test attachSource with filtering
     Notes: Verifies filter parameter handling
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testAttachSourceWithFilter():
        /* Test variables */
        var FilterParams filter.
        var DataSourceAttachParams attachParams.
        
        /* Create test filter with where clause */
        filter = new FilterParams(
            "customer",     /* pcentity */
            "",            /* pcquerystring */
            "",            /* pcid1 */
            output table ttQueryParams  /* output table */
        ).
        filter:Where = "CustNum > 100".
        filter:TopRecs = 5.
        
        /* Test attachSource with filter */
        attachParams = new DataSourceAttachParams(
            "customer",
            "CustNum,Name",
            "Customer",
            "CustNum",
            "",
            filter,
            hTestDataset
        ).
        
        dataAccess:attachSource(attachParams).
        
        /* Verify dataset handle */
        Assert:IsTrue(valid-handle(hTestDataset),
            "Dataset handle should be valid with filter").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test attachSource with sorting
     Notes: Verifies sort parameter handling
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testAttachSourceWithSorting():
        /* Test variables */
        var FilterParams filter.
        var DataSourceAttachParams attachParams.

        /* Create test filter with sorting */
        filter = new FilterParams(
            "customer",     /* pcentity */
            "",            /* pcquerystring */
            "",            /* pcid1 */
            output table ttQueryParams  /* output table */
        ).
        filter:SortBy = "Name".
        
        /* Test attachSource with sorting */
        attachParams = new DataSourceAttachParams(
            "customer",
            "CustNum,Name",
            "Customer",
            "CustNum",
            "",
            filter,
            hTestDataset
        ).
        
        dataAccess:attachSource(attachParams).
        
        /* Verify dataset handle */
        Assert:IsTrue(valid-handle(hTestDataset),
            "Dataset handle should be valid with sorting").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test attachSource with pagination
     Notes: Verifies skip/top functionality
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testAttachSourceWithPagination():
        /* Test variables */
        var FilterParams filter.
        var DataSourceAttachParams attachParams.
        
        /* Create test filter with pagination */
        filter = new FilterParams(
            "customer",     /* pcentity */
            "",            /* pcquerystring */
            "",            /* pcid1 */
            output table ttQueryParams  /* output table */
        ).
        filter:SkipRecs = 5.
        filter:TopRecs = 10.
        
        /* Test attachSource with pagination */
        attachParams = new DataSourceAttachParams(
            "customer",
            "CustNum,Name",
            "Customer",
            "CustNum",
            "",
            filter,
            hTestDataset
        ).
        
        dataAccess:attachSource(attachParams).
        
        /* Verify dataset handle */
        Assert:IsTrue(valid-handle(hTestDataset),
            "Dataset handle should be valid with pagination").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test error handling in attachSource
     Notes: Verifies proper error handling for invalid parameters
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testAttachSourceErrorHandling():
        /* Test variables */
        var FilterParams filter.
        var logical lCaughtError = false.
        var DataSourceAttachParams attachParams.
        
        /* Create test filter */
        filter = new FilterParams(
            "customer",     /* pcentity */
            "",            /* pcquerystring */
            "",            /* pcid1 */
            output table ttQueryParams  /* output table */
        ).
        
        /* Test with invalid buffer name */
        do on error undo, 
            throw:
                attachParams = new DataSourceAttachParams(
                    "invalid_buffer",  /* Invalid buffer name */
                    "Field1",
                    "Customer",
                    "CustNum",
                    "",
                    filter,
                    hTestDataset
                ).
                
                dataAccess:attachSource(attachParams).
            catch e as Progress.Lang.Error:
                lCaughtError = true.
            end.
        end.
        /* Verify error was caught */
        Assert:IsTrue(lCaughtError,
            "Should catch error with invalid buffer name").
    end method.

end class.