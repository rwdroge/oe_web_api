/*------------------------------------------------------------------------
    File        : MetadataService
    Purpose     : Provide metadata services for entity repositories
    Syntax      : 
    Description : Service class for handling entity metadata operations
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Replaces the metadata.i include file with a reusable service
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Json.ObjectModel.*.
using generics.FieldListValidationParams.
using generics.ValueListValidationParams.
 
block-level on error undo, throw. 
 
class services.MetadataService inherits services.BaseService:
     
    /*------------------------------------------------------------------------------
     Purpose: Constructor for MetadataService
     Notes: MetadataService is a utility service that doesn't require a repository
    ------------------------------------------------------------------------------*/
    constructor public MetadataService():
        super(?, "metadata").
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Check if a field list is valid for a given temp-table
     Parameters:
       input-output pparams - FieldListValidationParams containing validation parameters
     Notes: Validates that all fields in pparams.FieldList exist in the temp-table
    ------------------------------------------------------------------------------*/
    method public void checkFieldList(input-output pparams as FieldListValidationParams):
        
        var character cFieldList = "".
        var integer i = 0.
        var character cNotListed = "".
        
        /* Validate input parameters */
        if not pparams:HasValidInputs() then do:
            pparams:IsValid = false.
            pparams:InvalidFields = "Invalid input parameters".
            return.
        end.
        
        pparams:IsValid = true.

        /* Build list of all fields in the temp-table */
        do i = 1 to pparams:hTempTableHandle:num-fields:
            cFieldList = right-trim(pparams:hTempTableHandle:buffer-field(i):name + "," + cFieldList, ",").
        end.
        
        /* Check each requested field against the field list */
        do i = 1 to num-entries(pparams:cFieldList, ","):
            if lookup(entry(i, pparams:cFieldList), cFieldList) = 0 then do:
                cNotListed = left-trim(cNotListed + "," + entry(i, pparams:cFieldList), ",").
            end.
        end.
        
        if cNotListed > "" then
            pparams:IsValid = false.
            
        pparams:InvalidFields = cNotListed.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Check if values in query parameters match field data types
     Parameters:
       input-output pparams - ValueListValidationParams containing validation parameters
     Notes: Validates that values in query parameters match field data types
    ------------------------------------------------------------------------------*/
    method public void checkValueList(input-output pparams as ValueListValidationParams):
        
        var character cDataType = "".
        var character cFieldName = "".
        var character cValue = "".
        var handle hQuery = ?.
        var handle bQueryparams = ?.
        
        /* Validate input parameters */
        if not pparams:HasValidInputs() then do:
            pparams:IsValid = false.
            pparams:InvalidPairs = "Invalid input parameters".
            return.
        end.
        
        pparams:IsValid = true.
        
        bQueryparams = pparams:QueryparamsHandle:default-buffer-handle.
        
        create query hQuery.
        hQuery:set-buffers(bQueryparams).
        hQuery:query-prepare("for each " + pparams:QueryparamsHandle:name).
        hQuery:query-open.
        
        /* Go through all query string parameters and check their values for incorrect datatypes */
        repeat:
            hQuery:get-next().
            if hQuery:query-off-end then leave.
            
            if bQueryparams:available then do:
                cFieldName = bQueryparams:buffer-field("fieldname"):buffer-value().
                cValue = bQueryparams:buffer-field("fieldvalue"):buffer-value().
                
                /* Get the data type of the field */
                assign cDataType = pparams:TempTableHandle:buffer-field(cFieldName):data-type no-error.
                
                if error-status:error then do:
                    pparams:InvalidPairs = pparams:InvalidPairs + cFieldName + "/unknown/unknown/,".
                    pparams:IsValid = false.
                    next.
                end.
                
                /* Check if the value matches the data type */
                case cDataType:
                    when "integer" then integer(cValue) no-error.
                    when "decimal" then decimal(cValue) no-error.    
                    when "logical" then logical(cValue) no-error.
                    when "date" then date(cValue) no-error.
                end case.
                
                if error-status:error then do:
                    pparams:InvalidPairs = pparams:InvalidPairs + cFieldName + "/" + cValue + "/" + cDataType + "/,".
                    pparams:IsValid = false.
                end.
            end.
        end.
        
        finally:
            delete object hQuery no-error.
        end finally.
    end method.
    
    /* Note: createEntityModel method inherited from BaseService */
    
    
    /*------------------------------------------------------------------------------
     Purpose: Get metadata for all available entities
     Returns: JsonArray containing metadata for all entity classes
     Notes: Returns information about customers, items, orders, suppliers, and customersorders entities
    ------------------------------------------------------------------------------*/
    method public Progress.Json.ObjectModel.JsonArray GetAllEntitiesMetadata():
        
        VAR Progress.Json.ObjectModel.JsonArray jaEntities.
        VAR Progress.Json.ObjectModel.JsonObject joEntity.
        VAR handle hTempTable.
        VAR longchar lcModel.
        VAR Progress.Json.ObjectModel.ObjectModelParser parser.
        
        jaEntities = new Progress.Json.ObjectModel.JsonArray().
        parser = new Progress.Json.ObjectModel.ObjectModelParser().
        
        /* Create metadata for customers entity */
        create temp-table hTempTable.
        hTempTable:add-new-field("CustNum", "integer").
        hTempTable:add-new-field("Name", "character").
        hTempTable:add-new-field("Country", "character").
        hTempTable:add-new-field("CreditLimit", "decimal").
        hTempTable:temp-table-prepare("ttCustomers").
        
        this-object:createEntityModel(hTempTable, output lcModel).
        joEntity = new Progress.Json.ObjectModel.JsonObject().
        joEntity:add("name", "customers").
        joEntity:add("fields", cast(parser:Parse(lcModel), Progress.Json.ObjectModel.JsonObject)).
        jaEntities:add(joEntity).
        delete object hTempTable no-error.
        
        /* Create metadata for items entity */
        create temp-table hTempTable.
        hTempTable:add-new-field("ItemNum", "integer").
        hTempTable:add-new-field("ItemName", "character").
        hTempTable:add-new-field("Price", "decimal").
        hTempTable:add-new-field("OnHand", "integer").
        hTempTable:temp-table-prepare("ttItems").
        
        this-object:createEntityModel(hTempTable, output lcModel).
        joEntity = new Progress.Json.ObjectModel.JsonObject().
        joEntity:add("name", "items"). 
        joEntity:add("fields", cast(parser:Parse(lcModel), Progress.Json.ObjectModel.JsonObject)).
        jaEntities:add(joEntity).
        delete object hTempTable no-error.
        
        /* Create metadata for orders entity */
        create temp-table hTempTable.
        hTempTable:add-new-field("OrderNum", "integer").
        hTempTable:add-new-field("CustNum", "integer").
        hTempTable:add-new-field("OrderDate", "date").
        hTempTable:add-new-field("ShipDate", "date").
        hTempTable:temp-table-prepare("ttOrders").
        
        this-object:createEntityModel(hTempTable, output lcModel).
        joEntity = new Progress.Json.ObjectModel.JsonObject().
        joEntity:add("name", "orders").
        joEntity:add("fields", cast(parser:Parse(lcModel), Progress.Json.ObjectModel.JsonObject)).
        jaEntities:add(joEntity).
        delete object hTempTable no-error.
        
        /* Create metadata for suppliers entity */
        create temp-table hTempTable.
        hTempTable:add-new-field("SupplierNum", "integer").
        hTempTable:add-new-field("SupplierName", "character").
        hTempTable:add-new-field("Country", "character").
        hTempTable:add-new-field("ContactName", "character").
        hTempTable:temp-table-prepare("ttSuppliers").
        
        this-object:createEntityModel(hTempTable, output lcModel).
        joEntity = new Progress.Json.ObjectModel.JsonObject().
        joEntity:add("name", "suppliers").
        joEntity:add("fields", cast(parser:Parse(lcModel), Progress.Json.ObjectModel.JsonObject)).
        jaEntities:add(joEntity). 
        delete object hTempTable no-error.
        
        /* Create metadata for customersorders joined entity */
        create temp-table hTempTable.
        hTempTable:add-new-field("CustNum", "integer").
        hTempTable:add-new-field("Name", "character").
        hTempTable:add-new-field("OrderNum", "integer").
        hTempTable:add-new-field("OrderDate", "date").
        hTempTable:temp-table-prepare("ttCustomersOrders").
        
        this-object:createEntityModel(hTempTable, output lcModel).
        joEntity = new Progress.Json.ObjectModel.JsonObject().
        joEntity:add("name", "customersorders").
        joEntity:add("fields", cast(parser:Parse(lcModel), Progress.Json.ObjectModel.JsonObject)).
        jaEntities:add(joEntity).
        delete object hTempTable no-error.
        
        return jaEntities.
        
    end method. 
    
end class.
