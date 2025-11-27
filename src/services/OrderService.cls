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
        var handle hDataSet.
        var OrderRepository orderRepo.
        var JsonObject joResult.
        var JsonArray jaOrders.
        var JsonObject joOrder.
        var handle hBuffer.
        
        /* Try to cast to OrderRepository, otherwise use dynamic invocation */
        if type-of(this-object:Repository, OrderRepository) then do:
            orderRepo = cast(this-object:Repository, OrderRepository).
            hDataSet = orderRepo:FindOrdersByCustomer(piCustNum).
        end.
        else do:
            /* For mock repositories, use dynamic invocation */
            hDataSet = dynamic-invoke(this-object:Repository, "FindOrdersByCustomer", piCustNum).
        end.
        
        /* Convert to JSON */
        joResult = new JsonObject().
        jaOrders = new JsonArray().
        joOrder = new JsonObject().
        
        /* Check if orders were found */
        if valid-handle(hDataSet) then do:
            hBuffer = hDataSet:get-buffer-handle(1).
            if hBuffer:available then do:
                
                /* Process all records */
                hBuffer:find-first() no-error.
                do while hBuffer:available:
                    joOrder = new JsonObject().
                    joOrder:Read(hBuffer).
                    jaOrders:Add(joOrder).
                end.
                
                joResult:Add("customerNumber", piCustNum).
                joResult:Add("count", jaOrders:Length).
                joResult:Add("orders", jaOrders).
            end.
            else do:
                /* Return empty result if not found */
                joResult:Add("customerNumber", piCustNum).
                joResult:Add("count", 0).
                joResult:Add("orders", jaOrders).
            end.
        end.
        else do:
            /* Return empty result if dataset is invalid */
            joResult:Add("customerNumber", piCustNum).
            joResult:Add("count", 0).
            joResult:Add("orders", jaOrders).
        end.
        
        return joResult.
        
        finally:
            /* Clean up dataset resources */
            if valid-handle(hDataSet) then do:
                delete object hDataSet no-error.
            end.
            delete object jaOrders no-error.
        end finally.
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
        /* Cast repository to specific type to access specialized methods */
        var OrderRepository orderRepo = cast(this-object:Repository, OrderRepository).
        
        /* Get orders by date range */
        var handle hDataSet = orderRepo:FindOrdersByDateRange(pdStartDate, pdEndDate).
        
        /* Convert to JSON */
        var JsonObject joResult = new JsonObject().
        var JsonArray jaOrders = new JsonArray().
        var JsonObject joOrder = new JsonObject().
        var handle hBuffer = ?.
        
        /* Check if orders were found */
        if valid-handle(hDataSet) then do:
            hBuffer = hDataSet:get-buffer-handle(1).
            if hBuffer:available then do:
                
                /* Process all records */
                hBuffer:find-first() no-error.
                do while hBuffer:available:
                    joOrder = new JsonObject().
                    joOrder:Read(hBuffer).
                    jaOrders:Add(joOrder).
                end.
                
                joResult:Add("startDate", string(pdStartDate)).
                joResult:Add("endDate", string(pdEndDate)).
                joResult:Add("count", jaOrders:Length).
                joResult:Add("orders", jaOrders).
            end.
            else do:
                /* Return empty result if not found */
                joResult:Add("startDate", string(pdStartDate)).
                joResult:Add("endDate", string(pdEndDate)).
                joResult:Add("count", 0).
                joResult:Add("orders", jaOrders).
            end.
        end.
        else do:
            /* Return empty result if dataset is invalid */
            joResult:Add("startDate", string(pdStartDate)).
            joResult:Add("endDate", string(pdEndDate)).
            joResult:Add("count", 0).
            joResult:Add("orders", jaOrders).
        end.
        
        return joResult.
        
        finally:
            /* Clean up dataset resources */
            if valid-handle(hDataSet) then do:
                delete object hDataSet no-error.
            end.
            delete object jaOrders no-error.
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
        /* Cast repository to specific type to access specialized methods */
        var OrderRepository orderRepo = cast(this-object:Repository, OrderRepository).
        
        /* Get orders by status */
        var handle hDataSet = orderRepo:FindOrdersByStatus(pcStatus).
        
        /* Convert to JSON */
        var JsonObject joResult = new JsonObject().
        var JsonArray jaOrders = new JsonArray().
        var JsonObject joOrder = new JsonObject().
        var handle hBuffer = ?.
        
        /* Check if orders were found */
        if valid-handle(hDataSet) then do:
            hBuffer = hDataSet:get-buffer-handle(1).
            if hBuffer:available then do:
                
                /* Process all records */
                hBuffer:find-first() no-error.
                do while hBuffer:available:
                    joOrder = new JsonObject().
                    joOrder:Read(hBuffer).
                    jaOrders:Add(joOrder).
                end.
                
                joResult:Add("status", pcStatus).
                joResult:Add("count", jaOrders:Length).
                joResult:Add("orders", jaOrders).
            end.
            else do:
                /* Return empty result if not found */
                joResult:Add("status", pcStatus).
                joResult:Add("count", 0).
                joResult:Add("orders", jaOrders).
            end.
        end.
        else do:
            /* Return empty result if dataset is invalid */
            joResult:Add("status", pcStatus).
            joResult:Add("count", 0).
            joResult:Add("orders", jaOrders).
        end.
        
        return joResult.
        
        finally:
            /* Clean up dataset resources */
            if valid-handle(hDataSet) then do:
                delete object hDataSet no-error.
            end.
            delete object jaOrders no-error.
        end finally.
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
     Purpose: Override create method to add validation
     Parameters:
       input poEntity - JSON object containing entity data
     Returns: JsonObject containing created entity
    ------------------------------------------------------------------------------*/
    method override public JsonObject Create(input poEntity as JsonObject):
        /* Perform order-specific validation */
        var JsonObject joValidation = this-object:ValidateOrder(poEntity).
        
        /* Check validation result */
        if not joValidation:GetLogical("valid") then
            return joValidation.
            
        /* Call base implementation */
        return super:Create(poEntity).
        
        finally:
            delete object joValidation no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public OrderService():
        /* Base class destructor will handle cleanup */
    end destructor.
    
end class.
