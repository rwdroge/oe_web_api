/*------------------------------------------------------------------------
    File        : ApplicationBootstrapTest
    Purpose     : Unit tests for ApplicationBootstrap class
    Syntax      : 
    Description : Tests the application bootstrap functionality
    Author(s)   : 
    Created     : Tue Jul 08 10:45:12 UTC 2025
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Core.Assert.
USING core.ApplicationBootstrap.
USING core.DependencyContainer.
USING interfaces.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS tests.core.ApplicationBootstrapTest:
    
    DEFINE PRIVATE VARIABLE bootstrap AS core.ApplicationBootstrap NO-UNDO.
    DEFINE PRIVATE VARIABLE container AS core.DependencyContainer NO-UNDO.
    
    /*------------------------------------------------------------------------------
     Purpose: Set up test environment before each test
     Notes:   
    ------------------------------------------------------------------------------*/
    @Setup.
    METHOD PUBLIC VOID SetUp():
        /* Get singleton instances */
        bootstrap = ApplicationBootstrap:GetInstance().
        container = DependencyContainer:GetInstance().
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test that GetInstance returns a valid singleton instance
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestGetInstance():
        /* Test that GetInstance returns a valid instance */
        Assert:NotNull(bootstrap, "ApplicationBootstrap:GetInstance() should return a valid instance").
        
        /* Test that calling GetInstance again returns the same instance */
        DEFINE VARIABLE bootstrap2 AS core.ApplicationBootstrap NO-UNDO.
        bootstrap2 = ApplicationBootstrap:GetInstance().
        Assert:IsTrue(bootstrap = bootstrap2, "ApplicationBootstrap:GetInstance() should return the same instance when called multiple times").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test that repositories are properly registered
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestRepositoryRegistration():
        /* Test that item repository is registered */
        DEFINE VARIABLE itemRepo AS IRepository NO-UNDO.
        itemRepo = bootstrap:GetRepository("item").
        Assert:NotNull(itemRepo, "Item repository should be registered").
        
        /* Test that customer repository is registered */
        DEFINE VARIABLE customerRepo AS IRepository NO-UNDO. 
        customerRepo = bootstrap:GetRepository("customer").
        Assert:NotNull(customerRepo, "Customer repository should be registered").
        
        /* Test that order repository is registered */
        DEFINE VARIABLE orderRepo AS IRepository NO-UNDO.
        orderRepo = bootstrap:GetRepository("order").
        Assert:NotNull(orderRepo, "Order repository should be registered").
        
        /* Test that supplier repository is registered */
        DEFINE VARIABLE supplierRepo AS IRepository NO-UNDO.
        supplierRepo = bootstrap:GetRepository("supplier").
        Assert:NotNull(supplierRepo, "Supplier repository should be registered").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test that services are properly registered
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestServiceRegistration():
        /* Test that item service is registered */
        DEFINE VARIABLE itemService AS IService NO-UNDO.
        itemService = bootstrap:GetService("item").
        Assert:NotNull(itemService, "Item service should be registered").
        
        /* Test that customer service is registered */
        DEFINE VARIABLE customerService AS IService NO-UNDO.
        customerService = bootstrap:GetService("customer").
        Assert:NotNull(customerService, "Customer service should be registered").
        
        /* Test that order service is registered */
        DEFINE VARIABLE orderService AS IService NO-UNDO.
        orderService = bootstrap:GetService("order").
        Assert:NotNull(orderService, "Order service should be registered").
        
        /* Test that supplier service is registered */
        DEFINE VARIABLE supplierService AS IService NO-UNDO.
        supplierService = bootstrap:GetService("supplier").
        Assert:NotNull(supplierService, "Supplier service should be registered").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test that Initialize method works correctly
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestInitialize():
        /* Call Initialize method */
        bootstrap:Initialize().
        
        /* Verify that initialization was successful by checking for a registered component */
        DEFINE VARIABLE itemService AS IService NO-UNDO.
        itemService = bootstrap:GetService("item").
        Assert:NotNull(itemService, "After initialization, item service should be available").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up after tests
     Notes:   
    ------------------------------------------------------------------------------*/
    @TearDown.
    METHOD PUBLIC VOID TearDown():
        /* Nothing to clean up since we're using singletons */
    END METHOD.
    
END CLASS.
