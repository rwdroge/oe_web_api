/*------------------------------------------------------------------------
    File        : OrderService
    Purpose     : Service implementation for orders entity
    Syntax      : 
    Description : Provides business logic for orders
    Author(s)   : Cascade AI
    Created     : 2025-07-07
    Notes       : Service layer implementation for orders entity
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using services.BaseService.
using data.OrderRepository.
using generics.FilterParams.
using Progress.Json.ObjectModel.*.
using interfaces.IRepository.

block-level on error undo, throw.

class services.OrderService inherits BaseService:
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for OrderService
     Notes: Initializes service with orders repository
    ------------------------------------------------------------------------------*/
    constructor public OrderService():
        /* Call super constructor with repository and entity name */
        super(new OrderRepository(), "order").
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for OrderService with dependency injection
     Parameters:
       input poRepository - Repository instance (for testing)
     Notes: Allows injection of mock repository for testing
    ------------------------------------------------------------------------------*/
    constructor public OrderService(input poRepository as interfaces.IRepository):
        /* Call super constructor with provided repository and entity name */
        super(poRepository, "order").
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get orders by customer
     Parameters:
       input piCustNum - Customer number
     Returns: JsonObject containing orders for the customer
     Notes: Example of service-specific business logic
    ------------------------------------------------------------------------------*/
    method public JsonObject GetOrdersByCustomer(input piCustNum as integer):
        var JsonObject joMetadata = new JsonObject().
        
        /* Add metadata */
        joMetadata:Add("customerNumber", piCustNum).
        
        /* Use base helper method to execute query and convert to JSON */
        return this-object:ExecuteRepositoryQueryWithMetadata(
            "FindOrdersByCustomer", 
            piCustNum, 
            joMetadata, 
            "orders").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get orders by date range
     Parameters:
       input pdStartDate - Start date
       input pdEndDate - End date
     Returns: JsonObject containing orders in the date range
     Notes: Example of service-specific business logic
    ------------------------------------------------------------------------------*/
    method public JsonObject GetOrdersByDateRange(input pdStartDate as date, input pdEndDate as date):
        var JsonObject joMetadata = new JsonObject().
        var handle hDataSet.
        var JsonObject joResult.
        
        /* Add metadata */
        joMetadata:Add("startDate", string(pdStartDate)).
        joMetadata:Add("endDate", string(pdEndDate)).
        
        /* Invoke repository method directly to avoid overload resolution issues */
        hDataSet = dynamic-invoke(this-object:Repository, "FindOrdersByDateRange", pdStartDate, pdEndDate).
        
        /* Convert dataset to JSON with metadata */
        joResult = this-object:ConvertDataSetToJsonArray(hDataSet, joMetadata, "orders").
        
        return joResult.
        
        finally:
            this-object:CleanupResources(hDataSet, joMetadata).
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get orders by status
     Parameters:
       input pcStatus - Order status
     Returns: JsonObject containing orders with the specified status
     Notes: Example of service-specific business logic
    ------------------------------------------------------------------------------*/
    method public JsonObject GetOrdersByStatus(input pcStatus as character):
        var JsonObject joMetadata = new JsonObject().
        
        /* Add metadata */
        joMetadata:Add("status", pcStatus).
        
        /* Use base helper method to execute query and convert to JSON */
        return this-object:ExecuteRepositoryQueryWithMetadata(
            "FindOrdersByStatus", 
            pcStatus, 
            joMetadata, 
            "orders").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Update order status
     Parameters:
       input pcId - Order ID
       input pcStatus - New order status
     Returns: JsonObject containing updated order
     Notes: Example of business logic in service layer
    ------------------------------------------------------------------------------*/
    method public JsonObject UpdateOrderStatus(input pcId as character, input pcStatus as character):
        var JsonObject joError = new JsonObject().
        
        /* Get order from repository */
        var JsonObject joOrder = this-object:GetById(pcId).
        
        /* Validate order status */
        if not this-object:IsValidOrderStatus(pcStatus) then do:
            joError:Add("error", "Invalid order status").
            joError:Add("message", "Status must be one of: Ordered, Shipped, Processed, Billed").
            return joError.
        end.
        

        
        /* Check if order exists */
        if joOrder:Has("error") then
            return joOrder.
            
        /* Update status */
        joOrder:Set("orderstatus", pcStatus).
        
        /* Save updated order */
        return this-object:UpdateEntity(pcId, joOrder).
        
        finally:
            delete object joError no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Check if order status is valid
     Parameters:
       input pcStatus - Order status to check
     Returns: logical indicating if status is valid
     Notes: Helper method for validation
    ------------------------------------------------------------------------------*/
    method private logical IsValidOrderStatus(input pcStatus as character):
        var character cValidStatuses = "Ordered,Shipped,Processed,Billed".
        
        return lookup(pcStatus, cValidStatuses) > 0.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate order data
     Parameters:
       input poOrder - JSON object containing order data
     Returns: JsonObject with validation results
     Notes: Example of validation in service layer
    ------------------------------------------------------------------------------*/
    method public JsonObject ValidateOrder(input poOrder as JsonObject):
        var JsonObject joResult = new JsonObject().
        var JsonObject joError = new JsonObject().
        var JsonArray jaErrors = new JsonArray().
        var logical lValid = true.
        
        /* Check required fields */
        if not poOrder:Has("ordernum") or poOrder:GetInteger("ordernum") = ? then do:
            joError = new JsonObject().
            joError:Add("field", "ordernum").
            joError:Add("message", "Order number is required").
            jaErrors:Add(joError).
            lValid = false.
        end.
        
        if not poOrder:Has("custnum") or poOrder:GetInteger("custnum") = ? then do:
            joError = new JsonObject().
            joError:Add("field", "custnum").
            joError:Add("message", "Customer number is required").
            jaErrors:Add(joError).
            lValid = false.
        end.
        
        if poOrder:Has("orderstatus") and not this-object:IsValidOrderStatus(poOrder:GetCharacter("orderstatus")) then do:
            joError = new JsonObject().
            joError:Add("field", "orderstatus").
            joError:Add("message", "Invalid order status").
            jaErrors:Add(joError).
            lValid = false.
        end.
        
        /* Add validation result */
        joResult:Add("valid", lValid).
        if not lValid then
            joResult:Add("errors", jaErrors).
            
        return joResult.
        
        finally:
            delete object jaErrors no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Override validation method for order-specific validation
     Parameters:
       input poEntity - JSON object containing entity data
     Returns: JsonObject with validation results
    ------------------------------------------------------------------------------*/
    method override public JsonObject ValidateEntityForCreate(input poEntity as JsonObject):
        /* Delegate to existing validation method */
        return this-object:ValidateOrder(poEntity).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public OrderService():
        /* Base class destructor will handle cleanup */
    end destructor.
    
end class.
