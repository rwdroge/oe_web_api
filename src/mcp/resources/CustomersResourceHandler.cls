/*------------------------------------------------------------------------
    File        : CustomersResourceHandler
    Purpose     : MCP resource handler for Customers
    Syntax      : 
    Description : Handles MCP operations for the Customers resource
    Author(s)   : Cascade AI
    Created     : 2025-07-10
    Notes       : Implements custom methods for Customers resource
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Json.ObjectModel.*.
using mcp.BaseResourceHandler.
using interfaces.IService.

block-level on error undo, throw.

class mcp.resources.CustomersResourceHandler inherits mcp.BaseResourceHandler:
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for CustomersResourceHandler
     Notes: Initializes resource with name and entity information
    ------------------------------------------------------------------------------*/
    constructor public CustomersResourceHandler():
        super("customers", "customer").
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle custom method
     Parameters:
       input pcMethodName - Method name
       input poService - Service instance
       input poParameters - Method parameters
     Returns: JsonObject containing method result
     Notes: Implements custom methods for Customers resource
    ------------------------------------------------------------------------------*/
    method override protected JsonObject HandleCustomMethod(
        input pcMethodName as character, 
        input poService as IService, 
        input poParameters as JsonObject):
        
        var JsonObject joResult = new JsonObject().
        
        case pcMethodName:
            when "getByCountry" then
                joResult = HandleGetByCountry(poService, poParameters).
            when "updateCreditLimit" then
                joResult = HandleUpdateCreditLimit(poService, poParameters).
            otherwise
                /* Method not found, use base implementation */
                joResult = super:HandleCustomMethod(pcMethodName, poService, poParameters).
        end case.
        
        return joResult.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get schema for custom methods
     Returns: JsonArray containing custom method schemas
     Notes: Provides schema for custom methods
    ------------------------------------------------------------------------------*/
    method override protected JsonArray GetCustomMethodsSchema():
        var JsonArray jaMethods = new JsonArray().
        var JsonObject joMethod = new JsonObject().
        var JsonObject joInput = new JsonObject().
        var JsonObject joProperties = new JsonObject().
        var JsonObject joCountryProp = new JsonObject().
        var JsonArray jaRequired = new JsonArray().
        var JsonObject joIdProp = new JsonObject().
        var JsonObject joCreditLimitProp = new JsonObject().
        
        /* Add getByCountry method schema */
        joMethod:Add("name", "getByCountry").
        joMethod:Add("description", "Get customers by country").
        
        joInput:Add("type", "object").
        
        joCountryProp:Add("type", "string").
        joCountryProp:Add("description", "Country name to filter by").
        joProperties:Add("country", joCountryProp).
        
        joInput:Add("properties", joProperties).
        joInput:Add("required", new JsonArray():Add("country")).
        
        joMethod:Add("input_schema", joInput).
        jaMethods:Add(joMethod).
        
        /* Add updateCreditLimit method schema */
        joMethod = new JsonObject().
        joInput = new JsonObject().
        joProperties = new JsonObject().

        
        joMethod:Add("name", "updateCreditLimit").
        joMethod:Add("description", "Update credit limit for a customer").
        
        joInput:Add("type", "object").
        
        joIdProp:Add("type", "string").
        joIdProp:Add("description", "Customer ID to update credit limit for").
        joProperties:Add("id", joIdProp).
        
        joCreditLimitProp:Add("type", "number").
        joCreditLimitProp:Add("description", "New credit limit value").
        joProperties:Add("creditLimit", joCreditLimitProp).
        
        joInput:Add("properties", joProperties).
        jaRequired:Add("id").
        jaRequired:Add("creditLimit").
        joInput:Add("required", jaRequired).
        
        joMethod:Add("input_schema", joInput).
        jaMethods:Add(joMethod).
        
        
        return jaMethods.
        
        finally:
            delete object joMethod no-error.
            delete object joInput no-error.
            delete object joProperties no-error.
            delete object joCountryProp no-error.
            delete object joIdProp no-error.
            delete object joCreditLimitProp no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle getByCountry method
     Parameters:
       input poService - Service instance
       input poParameters - Method parameters
     Returns: JsonObject containing method result
    ------------------------------------------------------------------------------*/
    method private JsonObject HandleGetByCountry(input poService as IService, input poParameters as JsonObject):
        /* Get country from parameters */
        var character country = poParameters:GetCharacter("country").
        var handle hQueryParams = ?.
        var generics.FilterParams filter = new generics.FilterParams(EntityName, "", "", "", "", output table-handle hQueryParams).
        var JsonObject joResult = new JsonObject().
        var JsonObject joError = new JsonObject().
        
        /* Validate country */
        if country = ? or country = "" then do:
            
            joError:Add("error", "Missing country parameter").
            joError:Add("resource", ResourceName).
            joError:Add("method", "getByCountry").
            return joError.
        end.
        
        /* Create filter for country */
        
        filter:Where = "country=" + country.
        
        /* Get customers by filter */
        joResult = poService:GetByFilter(filter).
        
        return joResult.
        
        finally:
            delete object filter no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle updateCreditLimit method
     Parameters:
       input poService - Service instance
       input poParameters - Method parameters
     Returns: JsonObject containing method result
    ------------------------------------------------------------------------------*/
    method private JsonObject HandleUpdateCreditLimit(input poService as IService, input poParameters as JsonObject):
        /* Get parameters */
        var character id = poParameters:GetCharacter("id").
        var decimal creditLimit = poParameters:GetDecimal("creditLimit").
        var JsonObject joError = new JsonObject().
        var JsonObject joCustomer = new JsonObject().
        var JsonObject joUpdate = new JsonObject().
        var JsonObject joResult = new JsonObject().
        var decimal oldCreditLimit = 0.
        
        /* Validate parameters */
        if id = ? or id = "" then do:
            
            joError:Add("error", "Missing ID parameter").
            joError:Add("resource", ResourceName).
            joError:Add("method", "updateCreditLimit").
            return joError.
        end.
        
        if creditLimit = ? or creditLimit < 0 then do:
            joError:Add("error", "Invalid creditLimit parameter").
            joError:Add("resource", ResourceName).
            joError:Add("method", "updateCreditLimit").
            joError:Add("details", "Credit limit must be a positive number").
            return joError.
        end.
        
        /* Get customer */
        poService:GetById(id).
        
        /* Check if customer exists */
        if joCustomer:Has("error") then
            return joCustomer.
            
        /* Update customer with new credit limit */
        
        joUpdate:Add("creditLimit", creditLimit).
        
        /* Update customer */
        joResult = poService:Update(id, joUpdate).
        
        /* Add credit limit information to result */
        if not joResult:Has("error") then do:
            oldCreditLimit = joCustomer:GetDecimal("creditLimit").
            joResult:Add("oldCreditLimit", oldCreditLimit).
            joResult:Add("newCreditLimit", creditLimit).
        end.
        
        return joResult.
        
        finally:
            delete object joCustomer no-error.
            delete object joUpdate no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public CustomersResourceHandler():
        /* No resources to clean up */
    end destructor.
    
end class.
