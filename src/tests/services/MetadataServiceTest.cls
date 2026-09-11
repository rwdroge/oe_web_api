/*------------------------------------------------------------------------
    File        : MetadataServiceTest
    Purpose     : Unit tests for MetadataService class
    Syntax      : 
    Description : Tests the metadata service functionality
    Author(s)   : 
    Created     : Tue Jul 08 10:55:32 UTC 2025
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Json.ObjectModel.* from propath.
using Progress.Lang.*.
using OpenEdge.Core.Assert.
using services.MetadataService.

block-level on error undo, throw.

CLASS tests.services.MetadataServiceTest:
    {entities/inc/customers.i}.
    {entities/inc/items.i}.
    {entities/inc/orders.i}.
    {entities/inc/suppliers.i}. 

    
    VAR private services.MetadataService metadataService.
    
    /*------------------------------------------------------------------------------
     Purpose: Set up test environment before each test
     Notes:   
    ------------------------------------------------------------------------------*/
    @Setup.
    METHOD PUBLIC VOID SetUp():
        metadataService = NEW services.MetadataService().
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test GetEntityMetadata method for items
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestGetItemMetadata():
        /* Variable declarations must come first */
        var Progress.Json.ObjectModel.JsonObject result.
        var longchar plcModel.
        var ObjectModelParser parser = new ObjectModelParser().
        var JsonObject joModel = new JsonObject().
        var Progress.Json.ObjectModel.JsonArray cfields.
        var Progress.Json.ObjectModel.JsonObject cfirstField.
        var handle hBuffer = ?.
        
        /* Get the buffer handle for the item temp-table */
        hBuffer = dataset dsItem:get-buffer-handle(1).
        
        /* Call GetEntityMetadata method for items */
        metadataService:createEntityModel(hBuffer, output plcModel).

        joModel = cast(parser:Parse(plcModel), jsonobject).

        /* Verify result */
        Assert:NotNull(joModel, "GetEntityMetadata should return a JsonObject for item entity").
        Assert:IsTrue(joModel:Has("fields"), "Item metadata should have fields property").
        Assert:IsTrue(joModel:Has("entity"), "Item metadata should have entity property").
        Assert:IsTrue(joModel:GetCharacter("entity") = "item", "Entity name should be 'item'").
        
        /* Check fields array */
        cfields = joModel:GetJsonArray("fields").
        Assert:NotNull(cfields, "Fields array should not be null").
        Assert:IsTrue(cfields:Length > 0, "Fields array should not be empty").
        
        /* Check first field has required properties */
        cfirstField = cfields:GetJsonObject(1).
        Assert:IsTrue(cfirstField:Has("name"), "Field should have name property").
        Assert:IsTrue(cfirstField:Has("type"), "Field should have type property").
        Assert:IsTrue(cfirstField:Has("label"), "Field should have label property").

        
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test GetEntityMetadata method for customers
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestGetCustomerMetadata():
        /* Variable declarations must come first */
        var longchar plcModel.
        var ObjectModelParser parser = new ObjectModelParser().
        var JsonObject joModel = new JsonObject().
        var Progress.Json.ObjectModel.JsonArray cfields.
        var handle hBuffer = ?.
        
        /* Get the buffer handle for the customer temp-table */
        hBuffer = dataset dsCustomer:get-buffer-handle(1).
        
        /* Call GetEntityMetadata method for customers */
        metadataService:createEntityModel(hBuffer, output plcModel).

        joModel = cast(parser:Parse(plcModel), jsonobject).

        /* Verify result */
        Assert:NotNull(joModel, "GetEntityMetadata should return a JsonObject for customer entity").
        Assert:IsTrue(joModel:Has("fields"), "Customer metadata should have fields property").
        Assert:IsTrue(joModel:Has("entity"), "Customer metadata should have entity property").
        Assert:IsTrue(joModel:GetCharacter("entity") = "customer", "Entity name should be 'customer'").
        
        /* Check fields array */
        cfields = joModel:GetJsonArray("fields").
        Assert:NotNull(cfields, "Fields array should not be null").
        Assert:IsTrue(cfields:Length > 0, "Fields array should not be empty").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test GetEntityMetadata method for orders
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestGetOrderMetadata():
        /* Variable declarations must come first */
        var longchar plcModel.
        var ObjectModelParser parser = new ObjectModelParser().
        var JsonObject joModel = new JsonObject().
        
        /* Get the buffer handle for the order temp-table */
        var handle hBuffer = ?.
        hBuffer = dataset dsOrder:get-buffer-handle(1).
        
        /* Call GetEntityMetadata method for orders */
        metadataService:createEntityModel(hBuffer, output plcModel).
        
        joModel = cast(parser:Parse(plcModel), jsonobject).
        
        /* Verify result */
        Assert:NotNull(joModel, "GetEntityMetadata should return a JsonObject for order entity").
        Assert:IsTrue(joModel:Has("fields"), "Order metadata should have fields property").
        Assert:IsTrue(joModel:Has("entity"), "Order metadata should have entity property").
        Assert:IsTrue(joModel:GetCharacter("entity") = "order", "Entity name should be 'order'").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test GetEntityMetadata method for suppliers
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestGetSupplierMetadata():
        /* Variable declarations must come first */
        var longchar plcModel.
        var ObjectModelParser parser = new ObjectModelParser().
        var JsonObject joModel = new JsonObject().
        
        /* Get the buffer handle for the supplier temp-table */
        var handle hBuffer = ?.
        hBuffer = dataset dsSupplier:get-buffer-handle(1).
        
        /* Call GetEntityMetadata method for suppliers */
        metadataService:createEntityModel(hBuffer, output plcModel).
        
        /* Verify result */
        Assert:NotNull(joModel, "GetEntityMetadata should return a JsonObject for supplier entity").
        Assert:IsTrue(joModel:Has("fields"), "Supplier metadata should have fields property").
        Assert:IsTrue(joModel:Has("entity"), "Supplier metadata should have entity property").
        Assert:IsTrue(joModel:GetCharacter("entity") = "supplier", "Entity name should be 'supplier'").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test GetEntityMetadata method for invalid entity
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestGetInvalidEntityMetadata():
        /* Variable declarations must come first */
        var longchar plcModel.
        var ObjectModelParser parser = new ObjectModelParser().
        var JsonObject joModel = new JsonObject().
        
        /* Call GetEntityMetadata method for invalid entity */
        var handle hBuffer = ?.
        /* Pass invalid handle to test error handling */
        metadataService:createEntityModel(hBuffer, output plcModel).
        
        /* Parse the result if any */
        if plcModel > "" then
            joModel = cast(parser:Parse(plcModel), jsonobject).
        
        /* Verify result is null for invalid entity */
        Assert:IsNull(joModel, "GetEntityMetadata should return null for invalid entity").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test GetAllEntitiesMetadata method
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestGetAllEntitiesMetadata():
        /* Variable declarations must come first */
        VAR Progress.Json.ObjectModel.JsonArray result.
        VAR LOGICAL foundItem = FALSE.
        VAR LOGICAL foundCustomer = FALSE.
        VAR LOGICAL foundOrder = FALSE.
        VAR LOGICAL foundSupplier = FALSE.
        VAR INTEGER i.
        VAR Progress.Json.ObjectModel.JsonObject entity.
        
        /* Call GetAllEntitiesMetadata method */
        result = metadataService:GetAllEntitiesMetadata().
        
        /* Verify result */
        Assert:NotNull(result, "GetAllEntitiesMetadata should return a JsonArray").
        Assert:IsTrue(result:Length >= 4, "GetAllEntitiesMetadata should return at least 4 entities").
        
        /* Check that all expected entities are present */
        
        do i = 1 to result:Length:
            entity = result:GetJsonObject(i).
            
            if entity:GetCharacter("entity") = "item" then foundItem = true.
            if entity:GetCharacter("entity") = "customer" then foundCustomer = true.
            if entity:GetCharacter("entity") = "order" then foundOrder = true.
            if entity:GetCharacter("entity") = "supplier" then foundSupplier = true.
        END.
        
        Assert:IsTrue(foundItem, "GetAllEntitiesMetadata should include item entity").
        Assert:IsTrue(foundCustomer, "GetAllEntitiesMetadata should include customer entity").
        Assert:IsTrue(foundOrder, "GetAllEntitiesMetadata should include order entity").
        Assert:IsTrue(foundSupplier, "GetAllEntitiesMetadata should include supplier entity").
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
