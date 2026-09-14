/*------------------------------------------------------------------------
    File        : ServiceFactoryTest
    Purpose     : Unit tests for ServiceFactory class
    Syntax      : 
    Description : Tests the service factory functionality
    Author(s)   : 
    Created     : Tue Jul 08 10:58:12 UTC 2025
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Core.Assert.
USING webhandlers.ServiceFactory.
USING interfaces.IService.
USING core.ApplicationBootstrap.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS tests.webhandlers.ServiceFactoryTest:
    
    DEFINE PRIVATE VARIABLE serviceFactory AS webhandlers.ServiceFactory NO-UNDO.
    
    /*------------------------------------------------------------------------------
     Purpose: Set up test environment before each test
     Notes:   
    ------------------------------------------------------------------------------*/
    @Setup.
    METHOD PUBLIC VOID SetUp():
        /* Initialize application bootstrap to ensure services are registered */
        ApplicationBootstrap:GetInstance():Initialize().
        
        /* Create service factory */
        serviceFactory = webhandlers.ServiceFactory:GetInstance().
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test GetService method for item service
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestGetItemService():
        /* Get item service */
        DEFINE VARIABLE service AS IService NO-UNDO.
        service = serviceFactory:GetService("item").
        
        /* Verify service */
        Assert:NotNull(service, "GetService should return a valid service for 'item'").
        Assert:IsTrue(service:GetEntityName() = "item", "Service entity name should be 'item'").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test GetService method for customer service
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestGetCustomerService():
        /* Get customer service */
        DEFINE VARIABLE service AS IService NO-UNDO.
        service = serviceFactory:GetService("customer").
        
        /* Verify service */
        Assert:NotNull(service, "GetService should return a valid service for 'customer'").
        Assert:IsTrue(service:GetEntityName() = "customer", "Service entity name should be 'customer'").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test GetService method for order service
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestGetOrderService():
        /* Get order service */
        DEFINE VARIABLE service AS IService NO-UNDO.
        service = serviceFactory:GetService("order").
        
        /* Verify service */
        Assert:NotNull(service, "GetService should return a valid service for 'order'").
        Assert:IsTrue(service:GetEntityName() = "order", "Service entity name should be 'order'").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test GetService method for supplier service
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestGetSupplierService():
        /* Get supplier service */
        DEFINE VARIABLE service AS IService NO-UNDO.
        service = serviceFactory:GetService("supplier").
        
        /* Verify service */
        Assert:NotNull(service, "GetService should return a valid service for 'supplier'").
        Assert:IsTrue(service:GetEntityName() = "supplier", "Service entity name should be 'supplier'").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test GetService method for invalid service
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestGetInvalidService():
        /* Get invalid service */
        DEFINE VARIABLE service AS IService NO-UNDO.
        service = serviceFactory:GetService("invalid").
        
        /* Verify service is null */
        Assert:IsNull(service, "GetService should return null for invalid service name").
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
