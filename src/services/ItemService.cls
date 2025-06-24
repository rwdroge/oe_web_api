/*------------------------------------------------------------------------
    File        : ItemService
    Purpose     : Service implementation for items entity
    Syntax      : 
    Description : Provides business logic for items
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Service layer implementation for items entity
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using services.BaseService.
using data.ItemRepository.
using generics.FilterParams.
using Progress.Json.ObjectModel.*.

block-level on error undo, throw.

class services.ItemService inherits BaseService:
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for ItemService
     Notes: Initializes service with items repository
    ------------------------------------------------------------------------------*/
    constructor public ItemService():
        /* Call super constructor with repository and entity name */
        super(new ItemRepository(), "item").
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get items by category
     Parameters:
       input pcCategory - Category name
     Returns: JsonObject containing items in the category
     Notes: Example of service-specific business logic
    ------------------------------------------------------------------------------*/
    method public JsonObject GetItemsByCategory(input pcCategory as character):
        /* Cast repository to specific type to access specialized methods */
        var ItemRepository itemRepo = cast(this-object:Repository, ItemRepository).
        
        /* Get items by category */
        var handle hDataSet = itemRepo:FindItemsByCategory(pcCategory).
        
        /* Convert to JSON */
        var JsonObject joResult = new JsonObject().
        var JsonArray jaItems = new JsonArray().
        var JsonObject joItem = new JsonObject().
        var handle hBuffer = hDataSet:get-buffer-handle(1).
        /* Check if items were found */
        if valid-handle(hDataSet) and hBuffer:available then do:
            /* Process all records */
            
            hBuffer:find-first() no-error.
            do while hBuffer:available:
                joItem = new JsonObject().
                joItem:Read(hBuffer).
                jaItems:Add(joItem).
            end.
            
            joResult:Add("category", pcCategory).
            joResult:Add("count", jaItems:Length).
            joResult:Add("items", jaItems).
        end.
        else do:
            /* Return empty result if not found */
            joResult:Add("category", pcCategory).
            joResult:Add("count", 0).
            joResult:Add("items", jaItems).
        end.
        
        return joResult.
        
        finally:
            delete object jaItems no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Apply discount to item
     Parameters:
       input pcId - Item ID
       input pdDiscountPercent - Discount percentage (0-100)
     Returns: JsonObject containing updated item
     Notes: Example of business logic in service layer
    ------------------------------------------------------------------------------*/
    method public JsonObject ApplyDiscount(input pcId as character, input pdDiscountPercent as decimal):
        var JsonObject joError = new JsonObject().
        /* Get item from repository */
        var JsonObject joItem = this-object:GetById(pcId).
        /* Calculate discounted price */
        var decimal dPrice = decimal(joItem:GetJsonObject("price"):Getcharacter("value")).
        var decimal dDiscountedPrice = dPrice * (1 - (pdDiscountPercent / 100)).

        /* Validate discount percentage */
        if pdDiscountPercent < 0 or pdDiscountPercent > 100 then do:
            
            joError:Add("error", "Invalid discount percentage").
            joError:Add("message", "Discount must be between 0 and 100").
            return joError.
        end.
        
        /* Check if item exists */
        if joItem:Has("error") then
            return joItem.
            
        /* Update price */
        joItem:GetJsonObject("price"):set("value", dDiscountedPrice).
        joItem:Add("discountApplied", pdDiscountPercent).
        
        /* Save updated item */
        return this-object:Update(pcId, joItem).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate item data
     Parameters:
       input poItem - JSON object containing item data
     Returns: JsonObject with validation results
     Notes: Example of validation in service layer
    ------------------------------------------------------------------------------*/
    method public JsonObject ValidateItem(input poItem as JsonObject):
        var JsonObject joResult = new JsonObject().
        var JsonObject joError = new JsonObject().
        var JsonArray jaErrors = new JsonArray().
        var logical lValid = true.
        
        /* Check required fields */
        if not poItem:Has("itemnum") or poItem:GetInteger("itemnum") = ? then do:
            joError:Add("field", "itemnum").
            joError:Add("message", "Item number is required").
            jaErrors:Add(joError).
            lValid = false.
        end.
        
        if not poItem:Has("itemname") or poItem:GetCharacter("itemname") = ? then do:
            joError:Add("field", "itemname").
            joError:Add("message", "Item name is required").
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
        /* Perform item-specific validation */
        var JsonObject joValidation = this-object:ValidateItem(poEntity).
        
        /* Check validation result */
        if not joValidation:GetCharacter("valid") = "true" then
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
    destructor public ItemService():
        /* Base class destructor will handle cleanup */
    end destructor.
    
end class.
