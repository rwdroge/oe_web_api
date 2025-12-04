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
using interfaces.IRepository.

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
     Purpose: Constructor for CustomerService with dependency injection
     Parameters:
       input poRepository - Repository instance (for testing)
     Notes: Allows injection of mock repository for testing
    ------------------------------------------------------------------------------*/
    constructor public CustomerService(input poRepository as interfaces.IRepository):
        /* Call super constructor with provided repository and entity name */
        super(poRepository, "customer").
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get customers by country
     Parameters:
       input pcCountry - Country name
     Returns: JsonObject containing customers in the country
     Notes: Example of service-specific business logic
    ------------------------------------------------------------------------------*/
    method public JsonObject GetCustomersByCountry(input pcCountry as character):
        var JsonObject joMetadata = new JsonObject().
        
        /* Add metadata */
        joMetadata:Add("country", pcCountry).
        
        /* Use base helper method to execute query and convert to JSON */
        return this-object:ExecuteRepositoryQueryWithMetadata(
            "FindCustomersByCountry", 
            pcCountry, 
            joMetadata, 
            "customers").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get customers by sales rep
     Parameters:
       input pcSalesRep - Sales representative name
     Returns: JsonObject containing customers for the sales rep
     Notes: Example of service-specific business logic
    ------------------------------------------------------------------------------*/
    method public JsonObject GetCustomersBySalesRep(input pcSalesRep as character):
        var JsonObject joMetadata = new JsonObject().
        
        /* Add metadata */
        joMetadata:Add("salesRep", pcSalesRep).
        
        /* Use base helper method to execute query and convert to JSON */
        return this-object:ExecuteRepositoryQueryWithMetadata(
            "FindCustomersBySalesRep", 
            pcSalesRep, 
            joMetadata, 
            "customers").
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
        return this-object:UpdateEntity(pcId, joCustomer).
        

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
     Purpose: Override validation method for customer-specific validation
     Parameters:
       input poEntity - JSON object containing entity data
     Returns: JsonObject with validation results
    ------------------------------------------------------------------------------*/
    method public override JsonObject ValidateEntityForCreate(input poEntity as JsonObject):
        /* Delegate to existing validation method */
        return this-object:ValidateCustomer(poEntity).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public CustomerService():
        /* Base class destructor will handle cleanup */
    end destructor.
    
end class.
