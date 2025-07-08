/*------------------------------------------------------------------------
    File        : CustomerService
    Purpose     : Service implementation for customers entity
    Syntax      : 
    Description : Provides business logic for customers
    Author(s)   : Cascade AI
    Created     : 2025-07-07
    Notes       : Service layer implementation for customers entity
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using services.BaseService.
using data.CustomerRepository.
using generics.FilterParams.
using Progress.Json.ObjectModel.*.

block-level on error undo, throw.

class services.CustomerService inherits BaseService:
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for CustomerService
     Notes: Initializes service with customers repository
    ------------------------------------------------------------------------------*/
    constructor public CustomerService():
        /* Call super constructor with repository and entity name */
        super(new CustomerRepository(), "customer").
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get customers by country
     Parameters:
       input pcCountry - Country name
     Returns: JsonObject containing customers in the country
     Notes: Example of service-specific business logic
    ------------------------------------------------------------------------------*/
    method public JsonObject GetCustomersByCountry(input pcCountry as character):
        /* Cast repository to specific type to access specialized methods */
        var CustomerRepository custRepo = cast(this-object:Repository, CustomerRepository).
        
        /* Get customers by country */
        var handle hDataSet = custRepo:FindCustomersByCountry(pcCountry).
        
        /* Convert to JSON */
        var JsonObject joResult = new JsonObject().
        var JsonArray jaCustomers = new JsonArray().
        var JsonObject joCustomer = new JsonObject().
        var handle hBuffer = hDataSet:get-buffer-handle(1).
        
        /* Check if customers were found */
        if valid-handle(hDataSet) then do:
            if hBuffer:available then do:
                
                /* Process all records */
                hBuffer:find-first() no-error.
                do while hBuffer:available:
                    joCustomer = new JsonObject().
                    joCustomer:Read(hBuffer).
                    jaCustomers:Add(joCustomer).
                end.
                
                joResult:Add("country", pcCountry).
                joResult:Add("count", jaCustomers:Length).
                joResult:Add("customers", jaCustomers).
            end.
            else do:
                /* Return empty result if not found */
                joResult:Add("country", pcCountry).
                joResult:Add("count", 0).
                joResult:Add("customers", jaCustomers).
            end.
        end.
        else do:
            /* Return empty result if dataset is invalid */
            joResult:Add("country", pcCountry).
            joResult:Add("count", 0).
            joResult:Add("customers", jaCustomers).
        end.
        
        return joResult.
        
        finally:
            /* Clean up dataset resources */
            if valid-handle(hDataSet) then do:
                delete object hDataSet no-error.
            end.
            delete object jaCustomers no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get customers by sales rep
     Parameters:
       input pcSalesRep - Sales representative name
     Returns: JsonObject containing customers for the sales rep
     Notes: Example of service-specific business logic
    ------------------------------------------------------------------------------*/
    method public JsonObject GetCustomersBySalesRep(input pcSalesRep as character):
        /* Cast repository to specific type to access specialized methods */
        var CustomerRepository custRepo = cast(this-object:Repository, CustomerRepository).
        
        /* Get customers by sales rep */
        var handle hDataSet = custRepo:FindCustomersBySalesRep(pcSalesRep).
        
        /* Convert to JSON */
        var JsonObject joResult = new JsonObject().
        var JsonArray jaCustomers = new JsonArray().
        var JsonObject joCustomer = new JsonObject().
        var handle hBuffer = hDataSet:get-buffer-handle(1).
        
        /* Check if customers were found */
        if valid-handle(hDataSet) then do:
            hBuffer = hDataSet:get-buffer-handle(1).
            if hBuffer:available then do:
                
                /* Process all records */
                hBuffer:find-first() no-error.
                do while hBuffer:available:
                    joCustomer = new JsonObject().
                    joCustomer:Read(hBuffer).
                    jaCustomers:Add(joCustomer).
                end.
                
                joResult:Add("salesRep", pcSalesRep).
                joResult:Add("count", jaCustomers:Length).
                joResult:Add("customers", jaCustomers).
            end.
            else do:
                /* Return empty result if not found */
                joResult:Add("salesRep", pcSalesRep).
                joResult:Add("count", 0).
                joResult:Add("customers", jaCustomers).
            end.
        end.
        else do:
            /* Return empty result if dataset is invalid */
            joResult:Add("salesRep", pcSalesRep).
            joResult:Add("count", 0).
            joResult:Add("customers", jaCustomers).
        end.
        
        return joResult.
        
        finally:
            /* Clean up dataset resources */
            if valid-handle(hDataSet) then do:
                delete object hDataSet no-error.
            end.
            delete object jaCustomers no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Update customer credit limit
     Parameters:
       input pcId - Customer ID
       input pdCreditLimit - New credit limit
     Returns: JsonObject containing updated customer
     Notes: Example of business logic in service layer
    ------------------------------------------------------------------------------*/
    method public JsonObject UpdateCreditLimit(input pcId as character, input pdCreditLimit as decimal):
        var JsonObject joError = new JsonObject().
         /* Get customer from repository */
        var JsonObject joCustomer = this-object:GetById(pcId).
        
        /* Validate credit limit */
        if pdCreditLimit < 0 then do:
            joError:Add("error", "Invalid credit limit").
            joError:Add("message", "Credit limit must be greater than or equal to 0").
            return joError.
        end.
        
        
        
        /* Check if customer exists */
        if joCustomer:Has("error") then
            return joCustomer.
            
        /* Update credit limit */
        joCustomer:Set("creditlimit", pdCreditLimit).
        
        /* Save updated customer */
        return this-object:Update(pcId, joCustomer).
        

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate customer data
     Parameters:
       input poCustomer - JSON object containing customer data
     Returns: JsonObject with validation results
     Notes: Example of validation in service layer
    ------------------------------------------------------------------------------*/
    method public JsonObject ValidateCustomer(input poCustomer as JsonObject):
        var JsonObject joResult = new JsonObject().
        var JsonObject joError = new JsonObject().
        var JsonArray jaErrors = new JsonArray().
        var logical lValid = true.
        
        /* Check required fields */
        if not poCustomer:Has("custnum") or poCustomer:GetInteger("custnum") = ? then do:
            joError = new JsonObject().
            joError:Add("field", "custnum").
            joError:Add("message", "Customer number is required").
            jaErrors:Add(joError).
            lValid = false.
        end.
        
        if not poCustomer:Has("name") or poCustomer:GetCharacter("name") = ? then do:
            joError = new JsonObject().
            joError:Add("field", "name").
            joError:Add("message", "Customer name is required").
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
        /* Perform customer-specific validation */
        var JsonObject joValidation = this-object:ValidateCustomer(poEntity).
        
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
    destructor public CustomerService():
        /* Base class destructor will handle cleanup */
    end destructor.
    
end class.
