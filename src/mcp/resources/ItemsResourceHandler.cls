/*------------------------------------------------------------------------
    File        : ItemsResourceHandler
    Purpose     : MCP resource handler for Items
    Syntax      : 
    Description : Handles MCP operations for the Items resource
    Author(s)   : Cascade AI
    Created     : 2025-07-10
    Notes       : Implements custom methods for Items resource
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Json.ObjectModel.*.
using mcp.BaseResourceHandler.
using interfaces.IService.

block-level on error undo, throw.

class mcp.resources.ItemsResourceHandler inherits mcp.BaseResourceHandler:
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for ItemsResourceHandler
     Notes: Initializes resource with name and entity information
    ------------------------------------------------------------------------------*/
    constructor public ItemsResourceHandler():
        super("items", "item").
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle custom method
     Parameters:
       input pcMethodName - Method name
       input poService - Service instance
       input poParameters - Method parameters
     Returns: JsonObject containing method result
     Notes: Implements custom methods for Items resource
    ------------------------------------------------------------------------------*/
    method override protected JsonObject HandleCustomMethod(
        input pcMethodName as character, 
        input poService as IService, 
        input poParameters as JsonObject):
        
        var JsonObject joResult = new JsonObject().
        
        case pcMethodName:
            when "getByCategory" then
                joResult = HandleGetByCategory(poService, poParameters).
            when "applyDiscount" then
                joResult = HandleApplyDiscount(poService, poParameters).
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
        var JsonArray jaRequired = new JsonArray().
        var JsonObject joMethod = new JsonObject().
        var JsonObject joInput = new JsonObject().
        var JsonObject joProperties = new JsonObject().
        var JsonObject joCategoryProp = new JsonObject().
        var JsonObject joIdProp = new JsonObject().
        var JsonObject joDiscountProp = new JsonObject().
        
        message " am i causing this?".
        /* Add getByCategory method schema */
        joMethod:Add("name", "getByCategory").
        joMethod:Add("description", "Get items by category").
        
        joInput:Add("type", "object").
        
        joCategoryProp:Add("type", "string").
        joCategoryProp:Add("description", "Category name to filter by").
        joProperties:Add("category", joCategoryProp).
        
        joInput:Add("properties", joProperties).
        jaRequired:Add("category").
        joInput:Add("required", jaRequired).
        
        joMethod:Add("input_schema", joInput).
        jaMethods:Add(joMethod).
        
        /* Add applyDiscount method schema */
        joMethod = new JsonObject().
        joInput = new JsonObject().
        joProperties = new JsonObject().
        jaRequired = new JsonArray().

        
        joMethod:Add("name", "applyDiscount").
        joMethod:Add("description", "Apply discount to an item").
        
        joInput:Add("type", "object").
        
        joIdProp:Add("type", "string").
        joIdProp:Add("description", "Item ID to apply discount to").
        joProperties:Add("id", joIdProp).
        
        joDiscountProp:Add("type", "number").
        joDiscountProp:Add("description", "Discount percentage (0-100)").
        joProperties:Add("discount", joDiscountProp).
        
        joInput:Add("properties", joProperties).
        jaRequired:Add("id").
        jaRequired:Add("discount").
        joInput:Add("required", jaRequired).
        
        joMethod:Add("input_schema", joInput).
        jaMethods:Add(joMethod).

        jaMethods:WriteFile('/tmp/jaMethods.json').
        
        return jaMethods.
        
        finally:
            delete object joMethod no-error.
            delete object joInput no-error.
            delete object joProperties no-error.
            delete object joCategoryProp no-error.
            delete object joIdProp no-error.
            delete object joDiscountProp no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle getByCategory method
     Parameters:
       input poService - Service instance
       input poParameters - Method parameters
     Returns: JsonObject containing method result
    ------------------------------------------------------------------------------*/
    method private JsonObject HandleGetByCategory(input poService as IService, input poParameters as JsonObject):
        /* Declare variables */
        var character category = ?.
        var JsonObject joError = ?.
        var handle hQueryParams = ?.
        var generics.FilterParams filter = ?.
        var JsonObject joResult = ?.
        
        /* Get category from parameters */
        category = poParameters:GetCharacter("category") no-error.
        
        /* Validate category */
        if category = ? or category = "" then do:
            joError = new JsonObject().
            joError:Add("error", "Missing category parameter").
            joError:Add("resource", ResourceName).
            joError:Add("method", "getByCategory").
            return joError.
        end.
        
        /* Create filter for category */
        filter = new generics.FilterParams(EntityName, "", "", "", "", output table-handle hQueryParams).
        filter:Where = "category=" + category.
        
        /* Get items by filter */
        joResult = poService:GetByFilter(filter).
        
        return joResult.
        
        finally:
            delete object filter no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle applyDiscount method
     Parameters:
       input poService - Service instance
       input poParameters - Method parameters
     Returns: JsonObject containing method result
    ------------------------------------------------------------------------------*/
    method private JsonObject HandleApplyDiscount(input poService as IService, input poParameters as JsonObject):
        /* Declare variables */
        var character id = ?.
        var decimal discount = ?.
        var JsonObject joError = ?.
        var JsonObject joItem = ?.
        var decimal originalPrice = ?.
        var decimal newPrice = ?.
        var JsonObject joUpdate = ?.
        var JsonObject joResult = ?.
        
        /* Get parameters */
        id = poParameters:GetCharacter("id") no-error.
        discount = poParameters:GetDecimal("discount") no-error.
        
        /* Validate parameters */
        if id = ? or id = "" then do:
            joError = new JsonObject().
            joError:Add("error", "Missing ID parameter").
            joError:Add("resource", ResourceName).
            joError:Add("method", "applyDiscount").
            return joError.
        end.
        
        if discount = ? or discount < 0 or discount > 100 then do:
            joError = new JsonObject().
            joError:Add("error", "Invalid discount parameter").
            joError:Add("resource", ResourceName).
            joError:Add("method", "applyDiscount").
            joError:Add("details", "Discount must be between 0 and 100").
            return joError.
        end.
        
        /* Get item */
        joItem = poService:GetById(id).
        
        /* Check if item exists */
        if joItem:Has("error") then
            return joItem.
            
        /* Apply discount */
        originalPrice = joItem:GetDecimal("price") no-error.
        if originalPrice = ? then do:
            joError = new JsonObject().
            joError:Add("error", "Item has no price").
            joError:Add("resource", ResourceName).
            joError:Add("method", "applyDiscount").
            joError:Add("id", id).
            return joError.
        end.
        
        /* Calculate new price */
        newPrice = originalPrice * (1 - (discount / 100)).
        
        /* Update item with new price */
        joUpdate = new JsonObject().
        joUpdate:Add("price", newPrice).
        
        /* Update item */
        joResult = poService:Update(id, joUpdate).
        
        /* Add discount information to result */
        if not joResult:Has("error") then do:
            joResult:Add("originalPrice", originalPrice).
            joResult:Add("discount", discount).
            joResult:Add("newPrice", newPrice).
        end.
        
        return joResult.
        
        finally:
            delete object joItem no-error.
            delete object joUpdate no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public ItemsResourceHandler():
        /* No resources to clean up */
    end destructor.
    
end class.
