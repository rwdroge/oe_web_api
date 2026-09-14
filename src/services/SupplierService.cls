/*------------------------------------------------------------------------
    File        : SupplierService
    Purpose     : Service implementation for suppliers entity
    Syntax      : 
    Description : Provides business logic for suppliers
    Author(s)   : Cascade AI
    Created     : 2025-07-07
    Notes       : Service layer implementation for suppliers entity
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using services.BaseService.
using data.SupplierRepository.
using generics.FilterParams.
using Progress.Json.ObjectModel.*.
using interfaces.IRepository.

block-level on error undo, throw.

class services.SupplierService inherits BaseService:
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for SupplierService
     Notes: Initializes service with suppliers repository
    ------------------------------------------------------------------------------*/
    constructor public SupplierService():
        /* Call super constructor with repository and entity name */
        super(new SupplierRepository(), "supplier").
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for SupplierService with dependency injection
     Parameters:
       input poRepository - Repository instance (for testing)
     Notes: Allows injection of mock repository for testing
    ------------------------------------------------------------------------------*/
    constructor public SupplierService(input poRepository as interfaces.IRepository):
        /* Call super constructor with provided repository and entity name */
        super(poRepository, "supplier").
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get suppliers by country
     Parameters:
       input pcCountry - Country name
     Returns: JsonObject containing suppliers in the country
     Notes: Example of service-specific business logic
    ------------------------------------------------------------------------------*/
    method public JsonObject GetSuppliersByCountry(input pcCountry as character):
        var JsonObject joMetadata = new JsonObject().
        
        /* Add metadata */
        joMetadata:Add("country", pcCountry).
        
        /* Use base helper method to execute query and convert to JSON */
        return this-object:ExecuteRepositoryQueryWithMetadata(
            "FindSuppliersByCountry", 
            pcCountry, 
            joMetadata, 
            "suppliers").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get suppliers with discount
     Parameters:
       input piMinDiscount - Minimum discount percentage
     Returns: JsonObject containing suppliers with discount
     Notes: Example of service-specific business logic
    ------------------------------------------------------------------------------*/
    method public JsonObject GetSuppliersWithDiscount(input piMinDiscount as integer):
        var JsonObject joMetadata = new JsonObject().
        
        /* Add metadata */
        joMetadata:Add("minDiscount", piMinDiscount).
        
        /* Use base helper method to execute query and convert to JSON */
        return this-object:ExecuteRepositoryQueryWithMetadata(
            "FindSuppliersWithDiscount", 
            piMinDiscount, 
            joMetadata, 
            "suppliers").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Update supplier discount
     Parameters:
       input pcId - Supplier ID
       input piDiscount - New discount percentage
     Returns: JsonObject containing updated supplier
     Notes: Example of business logic in service layer
    ------------------------------------------------------------------------------*/
    method public JsonObject UpdateDiscount(input pcId as character, input piDiscount as integer):
        var JsonObject joError = new JsonObject().
        
        /* Get supplier from repository */
        var JsonObject joSupplier = this-object:GetById(pcId).
        
        /* Validate discount percentage */
        if piDiscount < 0 or piDiscount > 100 then do:
            joError:Add("error", "Invalid discount percentage").
            joError:Add("message", "Discount must be between 0 and 100").
            return joError.
        end.
        

        
        /* Check if supplier exists */
        if joSupplier:Has("error") then
            return joSupplier.
            
        /* Update discount */
        joSupplier:Set("discount", piDiscount).
        
        /* Save updated supplier */
        return this-object:UpdateEntity(pcId, joSupplier).
        
        finally:
            delete object joError no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate supplier data
     Parameters:
       input poSupplier - JSON object containing supplier data
     Returns: JsonObject with validation results
     Notes: Example of validation in service layer
    ------------------------------------------------------------------------------*/
    method public JsonObject ValidateSupplier(input poSupplier as JsonObject):
        var JsonObject joResult = new JsonObject().
        var JsonObject joError = new JsonObject().
        var JsonArray jaErrors = new JsonArray().
        var logical lValid = true.
        
        /* Check required fields */
        if not poSupplier:Has("supplieridnum") or poSupplier:GetInteger("supplieridnum") = ? then do:
            joError = new JsonObject().
            joError:Add("field", "supplieridnum").
            joError:Add("message", "Supplier ID is required").
            jaErrors:Add(joError).
            lValid = false.
        end.
        
        if not poSupplier:Has("name") or poSupplier:GetCharacter("name") = ? then do:
            joError = new JsonObject().
            joError:Add("field", "name").
            joError:Add("message", "Supplier name is required").
            jaErrors:Add(joError).
            lValid = false.
        end.
        
        /* Build and return validation result */
        joResult = this-object:BuildValidationResult(jaErrors, lValid).
        return joResult.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Override validation method for supplier-specific validation
     Parameters:
       input poEntity - JSON object containing entity data
     Returns: JsonObject with validation results
    ------------------------------------------------------------------------------*/
    method public override JsonObject ValidateEntityForCreate(input poEntity as JsonObject):
        /* Delegate to existing validation method */
        return this-object:ValidateSupplier(poEntity).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public SupplierService():
        /* Base class destructor will handle cleanup */
    end destructor.
    
end class.
