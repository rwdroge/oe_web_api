/*------------------------------------------------------------------------
    File        : BaseService
    Purpose     : Base implementation of service layer
    Syntax      : 
    Description : Abstract base class for entity services
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Provides common service functionality
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using interfaces.IService.
using interfaces.IRepository.
using generics.FilterParams.
using Progress.Json.ObjectModel.*.

block-level on error undo, throw.

class services.BaseService abstract implements interfaces.IService:
    
    /* Protected property for repository */
    define protected property Repository as interfaces.IRepository no-undo get. set.
    
    /* Protected property for entity name */
    define protected property EntityName as character no-undo get. set.
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for BaseService
     Parameters:
       input poRepository - Repository instance
       input pcEntityName - Name of the entity
     Notes: Initializes service with repository and entity information
    ------------------------------------------------------------------------------*/
    constructor public BaseService(
        input poRepository as interfaces.IRepository,
        input pcEntityName as character):
        
        assign
            this-object:Repository = poRepository
            this-object:EntityName = pcEntityName.
            
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get entity by ID
     Parameters:
       input pcId - Entity ID
     Returns: JsonObject containing entity data
    ------------------------------------------------------------------------------*/
    method public JsonObject GetById(input pcId as character):
        /* Get entity from repository */
        var handle hDataSet = this-object:Repository:FindById(pcId).
        
        /* Convert to JSON */
        var JsonObject joResult = new JsonObject().
        
        /* Check if entity was found */
        if valid-handle(hDataSet) and hDataSet:get-buffer-handle(1):available then do:
            joResult:Read(hDataSet:get-buffer-handle(1):table-handle).
        end.
        else do:
            /* Return empty object if not found */
            joResult:Add("error", "Entity not found").
            joResult:Add("entityName", this-object:EntityName).
            joResult:Add("id", pcId).
        end.
        

        
        return joResult.

        finally:
            /* Clean up dataset */
            if valid-handle(hDataSet) then do:
                delete object hDataSet no-error.
            end.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get entities by filter criteria
     Parameters:
       input pFilter - Filter parameters
     Returns: JsonObject or JsonArray containing entities
    ------------------------------------------------------------------------------*/
    method public JsonObject GetByFilter(input pFilter as generics.FilterParams):
        /* Get entities from repository */
        /* Initialize result */
        var handle hDataSet = ?.
        
        var JsonObject joResult = new JsonObject().
        
        /* Get dataset from repository */
        hDataSet = this-object:Repository:FindByFilter(pFilter).
        
        /* Check if entities were found */
        if valid-handle(hDataSet) then do:
            /* Convert to JSON */
            joResult:Read(hDataSet).
        end.
        else do:
            /* Return empty object if not found */
            joResult:Add("count", 0).
            joResult:Add("entityName", this-object:EntityName).
        end.
         
        return joResult.
        
        catch e as Progress.Lang.Error:
            /* Handle service errors */
            joResult = new JsonObject().
            joResult:Add("error", "Error retrieving entity metadata").
            joResult:Add("entity", entityName).
            joResult:Add("details", e:GetMessage(1)).
            return joResult.
        end.
        
        finally:
            /* Clean up dataset - make sure to detach data source before deleting */
            if valid-handle(hDataSet) then do:
                /* The repository should have already detached the data source */
                delete object hDataSet no-error.
            end.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Create a new entity
     Parameters:
       input poEntity - JSON object containing entity data
     Returns: JsonObject containing created entity
    ------------------------------------------------------------------------------*/
    method public JsonObject Create(input poEntity as JsonObject):
        /* Validate entity data */
        var character cInvalidFields.
        var character cFieldList = this-object:GetFieldList(poEntity).
        var JsonObject joError = new JsonObject().
        var JsonObject joResult = new JsonObject().
        var handle hDataSet = this-object:Repository:Save(poEntity).

        if not this-object:ValidateFields(cFieldList, output cInvalidFields) then do:
            joError:Add("error", "Invalid fields in request").
            joError:Add("entityName", this-object:EntityName).
            joError:Add("invalidFields", cInvalidFields).
        end.
        
        /* Begin transaction */
        do transaction:
            /* Check if entity was created */
            if valid-handle(hDataSet) and hDataSet:get-buffer-handle(1):available then do:
                joResult:Read(hDataSet:get-buffer-handle(1):table-handle).
            end.
            else do:
                /* Return error if not created */
                joResult:Add("error", "Failed to create entity").
                joResult:Add("entityName", this-object:EntityName).
            end.

            
            return joResult.
        end.
        finally:
            /* Clean up dataset */
            if valid-handle(hDataSet) then do:
                delete object hDataSet no-error.
            end.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Update an existing entity
     Parameters:
       input pcId - Entity ID
       input poEntity - JSON object containing updated entity data
     Returns: JsonObject containing updated entity
    ------------------------------------------------------------------------------*/
    method public JsonObject Update(input pcId as character, input poEntity as JsonObject):
        /* Validate entity data */
        var character cInvalidFields.
        var character cFieldList = this-object:GetFieldList(poEntity).
        var JsonObject joError = new JsonObject().
        var handle hDataSet = this-object:Repository:Update(pcId, poEntity).
        var JsonObject joResult = new JsonObject().
        
        if not this-object:ValidateFields(cFieldList, output cInvalidFields) then do:
            joError:Add("error", "Invalid fields in request").
            joError:Add("entityName", this-object:EntityName).
            joError:Add("invalidFields", cInvalidFields).
            
            return joError.
        end.
        
        /* Begin transaction */
        do transaction:
            /* Check if entity was updated */
            if valid-handle(hDataSet) and hDataSet:get-buffer-handle(1):available then do:
                joResult:Read(hDataSet:get-buffer-handle(1):table-handle).
            end.
            else do:
                /* Return error if not updated */
                joResult:Add("error", "Failed to update entity").
                joResult:Add("entityName", this-object:EntityName).
                joResult:Add("id", pcId).
            end.
            return joResult.
        end.
        finally:
            /* Clean up dataset */
            if valid-handle(hDataSet) then do:
                delete object hDataSet no-error.
            end.
        end finally.
            

    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Delete an entity by ID
     Parameters:
       input pcId - Entity ID
     Returns: logical indicating success
    ------------------------------------------------------------------------------*/
    method public logical Delete(input pcId as character):
        var logical lResult.
        /* Begin transaction */
        do transaction:
            /* Delete entity from repository */
            lResult = this-object:Repository:Delete(pcId).
            return lResult.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get metadata for the entity
     Parameters:
     Returns: JsonObject containing entity metadata
    ------------------------------------------------------------------------------*/
    method public JsonObject GetMetadata():
        /* Get metadata from repository */
        var longchar lcMetadata = this-object:Repository:GetMetadata().
        
        /* Convert to JSON using ObjectModelParser */
        var ObjectModelParser parser = new ObjectModelParser().
        var JsonObject joMetadata = cast(parser:Parse(lcMetadata), JsonObject).
        
        return joMetadata.
        
        finally:
            delete object parser no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate entity fields
     Parameters:
       input pcFieldList - Comma-separated list of fields to validate
     Returns: logical indicating if all fields are valid
    ------------------------------------------------------------------------------*/
    method public logical ValidateFields(input pcFieldList as character, output pcInvalidFields as character):
        /* Get metadata for validation */
        var JsonObject joMetadata = this-object:GetMetadata().
        var logical lValid = true.
        var integer i.
        var character cField.
        /* Initialize output */
        pcInvalidFields = "".
        
        
        /* Validate each field against metadata */
        
        do i = 1 to num-entries(pcFieldList, ","):
            
            if cField > "" and not joMetadata:Has(cField) then do:
                lValid = false.
                pcInvalidFields = pcInvalidFields + (if pcInvalidFields > "" then "," else "") + cField.
            end.
        end.
        
        return lValid.
        
        finally:
            delete object joMetadata no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get field list from JSON object
     Parameters:
       input poJson - JSON object
     Returns: Comma-separated list of fields
    ------------------------------------------------------------------------------*/
    method protected character GetFieldList(input poJson as JsonObject):
        var character cFieldList = "".
        var character[] aFieldNames = poJson:GetNames().
        
        var integer i.
        do i = 1 to extent(aFieldNames):
            cFieldList = cFieldList + (if cFieldList > "" then "," else "") + aFieldNames[i].
        end.
        
        return cFieldList.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public BaseService():
        /* No resources to clean up */
    end destructor.
    
end class.
