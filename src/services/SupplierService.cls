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
     Purpose: Get suppliers by country
     Parameters:
       input pcCountry - Country name
     Returns: JsonObject containing suppliers in the country
     Notes: Example of service-specific business logic
    ------------------------------------------------------------------------------*/
    method public JsonObject GetSuppliersByCountry(input pcCountry as character):
        /* Cast repository to specific type to access specialized methods */
        var SupplierRepository supplierRepo = cast(this-object:Repository, SupplierRepository).
        
        /* Get suppliers by country */
        var handle hDataSet = supplierRepo:FindSuppliersByCountry(pcCountry).
        
        /* Convert to JSON */
        var JsonObject joResult = new JsonObject().
        var JsonArray jaSuppliers = new JsonArray().
        var JsonObject joSupplier = new JsonObject().
        var handle hBuffer = ?.
        
        /* Check if suppliers were found */
        if valid-handle(hDataSet) then do:
            hBuffer = hDataSet:get-buffer-handle(1).
            if hBuffer:available then do:
                
                /* Process all records */
                hBuffer:find-first() no-error.
                do while hBuffer:available:
                    joSupplier = new JsonObject().
                    joSupplier:Read(hBuffer).
                    jaSuppliers:Add(joSupplier).
                end.
                
                joResult:Add("country", pcCountry).
                joResult:Add("count", jaSuppliers:Length).
                joResult:Add("suppliers", jaSuppliers).
            end.
            else do:
                /* Return empty result if not found */
                joResult:Add("country", pcCountry).
                joResult:Add("count", 0).
                joResult:Add("suppliers", jaSuppliers).
            end.
        end.
        else do:
            /* Return empty result if dataset is invalid */
            joResult:Add("country", pcCountry).
            joResult:Add("count", 0).
            joResult:Add("suppliers", jaSuppliers).
        end.
        
        return joResult.
        
        finally:
            /* Clean up dataset resources */
            if valid-handle(hDataSet) then do:
                delete object hDataSet no-error.
            end.
            delete object jaSuppliers no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get suppliers with discount
     Parameters:
       input piMinDiscount - Minimum discount percentage
     Returns: JsonObject containing suppliers with discount
     Notes: Example of service-specific business logic
    ------------------------------------------------------------------------------*/
    method public JsonObject GetSuppliersWithDiscount(input piMinDiscount as integer):
        /* Cast repository to specific type to access specialized methods */
        var SupplierRepository supplierRepo = cast(this-object:Repository, SupplierRepository).
        
        /* Get suppliers with discount */
        var handle hDataSet = supplierRepo:FindSuppliersWithDiscount(piMinDiscount).
        
        /* Convert to JSON */
        var JsonObject joResult = new JsonObject().
        var JsonArray jaSuppliers = new JsonArray().
        var JsonObject joSupplier = new JsonObject().
        var handle hBuffer = ?.
        
        /* Check if suppliers were found */
        if valid-handle(hDataSet) then do:
            hBuffer = hDataSet:get-buffer-handle(1).
            if hBuffer:available then do:
                
                /* Process all records */
                hBuffer:find-first() no-error.
                do while hBuffer:available:
                    joSupplier = new JsonObject().
                    joSupplier:Read(hBuffer).
                    jaSuppliers:Add(joSupplier).
                end.
                
                joResult:Add("minDiscount", piMinDiscount).
                joResult:Add("count", jaSuppliers:Length).
                joResult:Add("suppliers", jaSuppliers).
            end.
            else do:
                /* Return empty result if not found */
                joResult:Add("minDiscount", piMinDiscount).
                joResult:Add("count", 0).
                joResult:Add("suppliers", jaSuppliers).
            end.
        end.
        else do:
            /* Return empty result if dataset is invalid */
            joResult:Add("minDiscount", piMinDiscount).
            joResult:Add("count", 0).
            joResult:Add("suppliers", jaSuppliers).
        end.
        
        return joResult.
        
        finally:
            /* Clean up dataset resources */
            if valid-handle(hDataSet) then do:
                delete object hDataSet no-error.
            end.
            delete object jaSuppliers no-error.
        end finally.
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
        return this-object:Update(pcId, joSupplier).
        
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
        /* Perform supplier-specific validation */
        var JsonObject joValidation = this-object:ValidateSupplier(poEntity).
        
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
    destructor public SupplierService():
        /* Base class destructor will handle cleanup */
    end destructor.
    
end class.
