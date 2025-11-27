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
            /* Normalize the response to remove ProDataSet wrapper */
            joResult = this-object:NormalizeSingleEntityResponse(joResult).
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
        var JsonArray jaEmpty = new JsonArray().
        /* Get dataset from repository */
        hDataSet = this-object:Repository:FindByFilter(pFilter).
        
        /* Check if entities were found */
        if valid-handle(hDataSet) then do:
            /* Convert to JSON */
            joResult:Read(hDataSet).
            /* Normalize the response to remove ProDataSet wrapper */
            joResult = this-object:NormalizeMultipleEntityResponse(joResult).
        end.
        else do:
            /* Return empty array if not found */
            
            joResult:Add("data", jaEmpty).
            joResult:Add("count", 0).
            joResult:Add("entityName", this-object:EntityName).
            /* Return normalized empty response */
            joResult = this-object:NormalizeMultipleEntityResponse(joResult).
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
        var handle hDataSet = ?.
        var JsonObject joProDataSetFormat = ?.
        
        
            /* Validate entity fields */
            if not this-object:ValidateFields(cFieldList, output cInvalidFields) then do:
                joError:Add("error", "Invalid fields in request").
                joError:Add("entityName", this-object:EntityName).
                joError:Add("invalidFields", cInvalidFields).
                return joError.
            end.
            
            /* Convert normalized JSON to ProDataSet format for repository */
            joProDataSetFormat = this-object:ConvertToProDataSetFormat(poEntity).
            
            /* Begin transaction */
            do transaction:
                /* Save entity via repository */
                hDataSet = this-object:Repository:Save(joProDataSetFormat).
                
                /* Check if entity was created */
                if valid-handle(hDataSet) and hDataSet:get-buffer-handle(1):available then do:
                    joResult:Read(hDataSet:get-buffer-handle(1):table-handle).
                    /* Normalize the response to remove ProDataSet wrapper */
                    joResult = this-object:NormalizeSingleEntityResponse(joResult).
                end.
                else do:
                    /* Return error if not created */
                    joResult:Add("error", "Failed to create entity").
                    joResult:Add("entityName", this-object:EntityName).
                end.
            end.
            
            return joResult.
        
        catch e as Progress.Lang.Error:
            /* Handle service errors */
            joError:Add("error", "Error creating entity").
            joError:Add("entityName", this-object:EntityName).
            joError:Add("details", e:GetMessage(1)).
            return joError.
        end.
        finally:
            /* Clean up dataset */
            if valid-handle(hDataSet) then do:
                delete object hDataSet no-error.
            end.
            /* Clean up ProDataSet format object */
            if valid-object(joProDataSetFormat) then do:
                delete object joProDataSetFormat no-error.
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
    method public JsonObject UpdateEntity(input pcId as character, input poEntity as JsonObject):
        /* Validate entity data */
        var character cInvalidFields.
        var character cFieldList = this-object:GetFieldList(poEntity).
        var JsonObject joError = new JsonObject().
        
        /* Convert normalized JSON to ProDataSet format for repository */
        var JsonObject joProDataSetFormat = this-object:ConvertToProDataSetFormat(poEntity).
        var handle hDataSet = this-object:Repository:UpdateEntity(pcId, joProDataSetFormat).
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
                /* Normalize the response to remove ProDataSet wrapper */
                joResult = this-object:NormalizeSingleEntityResponse(joResult).
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
            /* Clean up ProDataSet format object */
            if valid-object(joProDataSetFormat) then do:
                delete object joProDataSetFormat no-error.
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
        var longchar lcMetadata.
        var JsonObject joMetadata = new JsonObject().
        
        /* Convert to JSON using ObjectModelParser */
        var ObjectModelParser parser = new ObjectModelParser().
        
        lcMetadata = this-object:Repository:GetMetadata().
        
        /* Ensure we have valid metadata before parsing */
        if lcMetadata > "" then do:
            /* Parse the metadata into a JSON object with error handling */
            do on error undo, throw:
                joMetadata = cast(parser:Parse(lcMetadata), JsonObject).
                if not valid-object(joMetadata) then
                    joMetadata = new JsonObject().
            end.
            
        end.
        else do:
            joMetadata = new JsonObject().
            joMetadata:Add("warning", "No metadata available").
        end.
       
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
     Purpose: Get the name of the entity managed by this service
     Returns: character containing the entity name
    ------------------------------------------------------------------------------*/
    method public character GetEntityName():
        return this-object:EntityName.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get fields for a specific entity
     Parameters:
       input pcEntity - Entity name
     Returns: JsonArray containing entity fields
    ------------------------------------------------------------------------------*/
    method public JsonArray GetEntityFields(input pcEntity as character):
        /* Get metadata from repository */
        var JsonObject joMetadata = this-object:GetMetadata().
        var JsonArray jaFields = new JsonArray().
        var character[] aFieldNames = ?.
        var integer i.
        var JsonObject joField = ?.
        var JsonObject joFieldInfo = ?.
        
        /* Check if entity matches and extract fields */
        if pcEntity = this-object:EntityName and valid-object(joMetadata) then do:
            /* Extract field information from metadata */
            aFieldNames = joMetadata:GetNames().
            
            do i = 1 to extent(aFieldNames):
                joField = new JsonObject().
                joField:Add("name", aFieldNames[i]).
                
                /* Add field type if available in metadata */
                if joMetadata:Has(aFieldNames[i]) and type-of(joMetadata:GetJsonObject(aFieldNames[i]), JsonObject) then do:
                    joFieldInfo = cast(joMetadata:GetJsonObject(aFieldNames[i]), JsonObject).
                    if joFieldInfo:Has("type") then
                        joField:Add("type", joFieldInfo:GetCharacter("type")).
                    if joFieldInfo:Has("label") then
                        joField:Add("label", joFieldInfo:GetCharacter("label")).
                end.
                
                jaFields:Add(joField).
            end.
        end.
        
        return jaFields.
        
        finally:
            delete object joMetadata no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public BaseService():
        /* No resources to clean up */
    end destructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Create a JSON model of an entity's structure
     Parameters:
       input phTempTable - Handle to the temp-table
       output plcModel - Longchar containing the JSON model
     Notes: Builds a JSON object describing the entity's fields and data types
    ------------------------------------------------------------------------------*/
    method public void createEntityModel(
        input phTempTable as handle,
        output plcModel as longchar):
        
        var integer i = 0.
        var jsonobject joModel = new jsonobject().
        var character cDataType = "".
        
        /* Build JSON model from temp-table fields */
        do i = 1 to phTempTable:num-fields:
            /* Convert ABL data types to JSON-friendly types */
            case phTempTable:buffer-field(i):data-type:
                when "character" then cDataType = "string".
                when "decimal" then cDataType = "number".
                when "logical" then cDataType = "boolean".
                otherwise
                    cDataType = phTempTable:buffer-field(i):data-type.
            end case.
            
            /* Skip internal fields */
            if (phTempTable:buffer-field(i):name <> "seq" and 
                phTempTable:buffer-field(i):name <> "id") then
                joModel:add(phTempTable:buffer-field(i):name, cDataType).
        end.
        
        plcModel = joModel:getJsonText().
        
        finally:
            delete object joModel no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Convert normalized JSON to ProDataSet format for backend processing
     Parameters:
       input poNormalizedJson - JsonObject containing normalized entity data
     Returns: JsonObject containing ProDataSet format for repository layer
     Notes: Wraps normalized entity data in ds<Entity> format expected by repository
    ------------------------------------------------------------------------------*/
    method protected JsonObject ConvertToProDataSetFormat(input poNormalizedJson as JsonObject):
        var JsonObject joProDataSet = new JsonObject().
        var JsonObject joDataset = new JsonObject().
        var JsonArray jaTable = new JsonArray().
        var character cDatasetName = "ds" + this-object:EntityName.
        
        /* Add the normalized JSON as the first (and only) record in the table array */
        jaTable:Add(poNormalizedJson).
        
        /* Create the table structure with entity name */
        joDataset:Add("tt" + this-object:EntityName, jaTable).
        
        /* Create the dataset wrapper */
        joProDataSet:Add(cDatasetName, joDataset).
        
        return joProDataSet.
        
        finally:
            if valid-object(joDataset) then
                delete object joDataset no-error.
            if valid-object(jaTable) then
                delete object jaTable no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Normalize single entity response by removing ProDataSet wrapper
     Parameters:
       input poResponse - JsonObject containing ProDataSet format response
     Returns: JsonObject containing normalized single entity data
     Notes: Extracts the actual entity data from ds<Entity> wrapper
    ------------------------------------------------------------------------------*/
    method protected JsonObject NormalizeSingleEntityResponse(input poResponse as JsonObject):
        var JsonObject joNormalized = new JsonObject().
        var character cDatasetName = "".
        var JsonObject joDataset = ?.
        var JsonArray jaTable = ?.
        var JsonObject joFirstRecord = ?.
        var character[] aTableNames.
        var character[] aRecordNames.

        /* Find the dataset property (starts with "ds") */
        var character[] aNames = poResponse:GetNames().
        var integer i = 0.
        
        do i = 1 to extent(aNames):
            if aNames[i] begins "ds" then do:
                cDatasetName = aNames[i].
                leave.
            end.
        end.
        
        /* If we found a dataset property */
        if cDatasetName > "" then do:
            joDataset = poResponse:GetJsonObject(cDatasetName).
            
            /* Get the table name (should be the entity name) */
            aTableNames = joDataset:GetNames().
            if extent(aTableNames) > 0 then do:
                jaTable = joDataset:GetJsonArray(aTableNames[1]).
                
                /* If we have records, return the first one */
                if jaTable:Length > 0 then do:
                    joFirstRecord = jaTable:GetJsonObject(1).
                    /* Copy all properties from the record to our normalized response */
                    aRecordNames = joFirstRecord:GetNames().
                    do i = 1 to extent(aRecordNames):
                        case joFirstRecord:GetType(aRecordNames[i]):
                            when JsonDataType:string then
                                joNormalized:Add(aRecordNames[i], joFirstRecord:GetCharacter(aRecordNames[i])).
                            when JsonDataType:number then
                                joNormalized:Add(aRecordNames[i], joFirstRecord:GetDecimal(aRecordNames[i])).
                            when JsonDataType:boolean then
                                joNormalized:Add(aRecordNames[i], joFirstRecord:GetLogical(aRecordNames[i])).
                            when JsonDataType:null then
                                joNormalized:Add(aRecordNames[i], "?").
                            otherwise
                                joNormalized:Add(aRecordNames[i], joFirstRecord:GetJsonText(aRecordNames[i])).
                        end case.
                    end.
                end.
            end.
        end.
        else do:
            /* If no dataset found, return original response */
            joNormalized = poResponse.
        end.
        
        return joNormalized.
        
        finally:
            if valid-object(joDataset) and joDataset <> poResponse then
                delete object joDataset no-error.
            if valid-object(jaTable) then
                delete object jaTable no-error.
            if valid-object(joFirstRecord) and joFirstRecord <> joNormalized then
                delete object joFirstRecord no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Normalize multiple entity response by removing ProDataSet wrapper
     Parameters:
       input poResponse - JsonObject containing ProDataSet format response
     Returns: JsonObject containing normalized array of entities
     Notes: Extracts the actual entity array from ds<Entity> wrapper
    ------------------------------------------------------------------------------*/
    method protected JsonObject NormalizeMultipleEntityResponse(input poResponse as JsonObject):
        var JsonObject joNormalized = new JsonObject().
        var JsonArray jaNormalized = new JsonArray().
        var character cDatasetName = "".
        var JsonObject joDataset = ?.
        var JsonArray jaTable = ?.
        var JsonObject joRecord = ?.
        var JsonObject joNormalizedRecord = ?.
        var character[] aTableNames.
        var character[] aRecordNames.

        /* Find the dataset property (starts with "ds") */
        var character[] aNames = poResponse:GetNames().
        var integer i = 0.
        var integer j = 0.
        
        do i = 1 to extent(aNames):
            if aNames[i] begins "ds" then do:
                cDatasetName = aNames[i].
                leave.
            end.
        end.
        
        /* If we found a dataset property */
        if cDatasetName > "" then do:
            joDataset = poResponse:GetJsonObject(cDatasetName).
            
            /* Get the table name (should be the entity name) */
            aTableNames = joDataset:GetNames().
            if extent(aTableNames) > 0 then do:
                jaTable = joDataset:GetJsonArray(aTableNames[1]).
                
                /* Process each record */
                do j = 1 to jaTable:Length:
                    joRecord = jaTable:GetJsonObject(j).
                    joNormalizedRecord = new JsonObject().
                    
                    /* Copy all properties from the record */
                    aRecordNames = joRecord:GetNames().
                    do i = 1 to extent(aRecordNames):
                        case joRecord:GetType(aRecordNames[i]):
                            when JsonDataType:string then
                                joNormalizedRecord:Add(aRecordNames[i], joRecord:GetCharacter(aRecordNames[i])).
                            when JsonDataType:number then
                                joNormalizedRecord:Add(aRecordNames[i], joRecord:GetDecimal(aRecordNames[i])).
                            when JsonDataType:boolean then
                                joNormalizedRecord:Add(aRecordNames[i], joRecord:GetLogical(aRecordNames[i])).
                            when JsonDataType:null then
                                joNormalizedRecord:Add(aRecordNames[i], "?").
                            otherwise
                                joNormalizedRecord:Add(aRecordNames[i], joRecord:GetJsonText(aRecordNames[i])).
                        end case.
                    end.
                    
                    jaNormalized:Add(joNormalizedRecord).
                end.
            end.
        end.
        else do:
            /* If no dataset found, check if it's already an array or has data property */
            if poResponse:Has("data") and poResponse:GetType("data") = JsonDataType:array then do:
                jaNormalized = poResponse:GetJsonArray("data").
            end.
        end.
        
        /* For multiple entities, always return as array */
        if jaNormalized:Length = 1 then do:
            /* Single result - return the object directly */
            joNormalized = jaNormalized:GetJsonObject(1).
        end.
        else do:
            /* Multiple results or empty - return as array */
            joNormalized = new JsonObject().
            joNormalized:Add("data", jaNormalized).
            joNormalized:Add("count", jaNormalized:Length).
        end.
        
        return joNormalized.
        
    end method.
    
end class.
