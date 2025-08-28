/*------------------------------------------------------------------------
    File        : BaseResourceHandler
    Purpose     : Base implementation of MCP resource handler
    Syntax      : 
    Description : Abstract base class for MCP resource handlers
    Author(s)   : Cascade AI
    Created     : 2025-07-10
    Notes       : Provides common functionality for MCP resource handlers
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Json.ObjectModel.*.
using mcp.IMCPResourceHandler.
using interfaces.IService.
using webhandlers.ServiceFactory.
using generics.FilterParams.

block-level on error undo, throw.

class mcp.BaseResourceHandler abstract implements mcp.IMCPResourceHandler:
    
    /* Protected property for resource name */
    define protected property ResourceName as character no-undo get. set.
    
    /* Protected property for entity name */
    define protected property EntityName as character no-undo get. set.
    
    /* Service factory for creating service instances */
    define protected property ServiceFactory as webhandlers.ServiceFactory no-undo
        get():
            return webhandlers.ServiceFactory:GetInstance().
        end get.
        private set.
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for BaseResourceHandler
     Parameters:
       input pcResourceName - Name of the resource
       input pcEntityName - Name of the entity
     Notes: Initializes resource with name and entity information
    ------------------------------------------------------------------------------*/
    constructor public BaseResourceHandler(
        input pcResourceName as character,
        input pcEntityName as character):
        
        assign
            this-object:ResourceName = pcResourceName
            this-object:EntityName = pcEntityName.
        
            message pcEntityName.
            
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle a method call for this resource
     Parameters:
       input pcMethodName - Method name to handle
       input poParameters - Parameters for the method
     Returns: JsonObject containing the method result
    ------------------------------------------------------------------------------*/
    method public JsonObject HandleMethod(input pcMethodName as character, input poParameters as JsonObject):
        var JsonObject joResponse = new JsonObject().
        var IService entityService = ?.
        
        /* Get service for entity */
        entityService = ServiceFactory:GetService(EntityName).
        
        /* Handle method based on name */
        case pcMethodName:
            when "list" then
                joResponse = HandleList(entityService, poParameters).
            when "get" then
                joResponse = HandleGet(entityService, poParameters).
            when "create" then
                joResponse = HandleCreate(entityService, poParameters).
            when "update" then
                joResponse = HandleUpdate(entityService, poParameters).
            when "delete" then
                joResponse = HandleDelete(entityService, poParameters).
            otherwise
                /* Handle custom methods in subclasses */
                joResponse = HandleCustomMethod(pcMethodName, entityService, poParameters).
        end case.
        
        return joResponse.
        
        catch e as Progress.Lang.Error:
            /* Handle method errors */
            joResponse = new JsonObject().
            joResponse:Add("error", "Error handling method").
            joResponse:Add("resource", ResourceName).
            joResponse:Add("method", pcMethodName).
            joResponse:Add("details", e:GetMessage(1)).
            return joResponse.
        end.
        
        finally:
            /* Clean up */
            delete object joResponse no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get schema information for this resource
     Returns: JsonObject containing resource schema
    ------------------------------------------------------------------------------*/
    method public JsonObject GetSchema():
        var JsonObject joSchema = new JsonObject().
        var IService entityService = ?.
        
        /* Get metadata from service */
        var ObjectModelParser parser = new ObjectModelParser().
        var JsonObject joMetadata = new JsonObject().
        var longchar lcMetadata.
        var JsonArray jaMethods = new JsonArray().
        var JsonArray jaCustomMethods = new JsonArray().
        var JsonObject joMethod = new JsonObject().
        var JsonObject joResponse = new JsonObject().
        var integer i.
        entityService = ServiceFactory:GetService(EntityName) no-error.
        /* Get metadata from service */
        
        /* Get metadata and create a deep copy to avoid reference issues */
        joMetadata = entityService:GetMetadata().
        if valid-object(joMetadata) then do:
            joMetadata:WriteFile('/tmp/joMetadata.json').
            /* Create a deep copy by serializing and parsing again */
            lcMetadata = joMetadata:GetJsonText().
            joMetadata = cast(parser:Parse(lcMetadata), JsonObject) no-error.
            delete object parser no-error.
        end.
        else do:
            joMetadata = new JsonObject().
        end.
        jaCustomMethods = GetCustomMethodsSchema().

        
        /* Build schema from metadata */
        joSchema:Add("name", ResourceName).
        joSchema:Add("entityName", EntityName).
        joSchema:Add("metadata", joMetadata).
        
        /* Add methods information */

        /* Add standard methods */
        joMethod:Add("name", "list").
        joMethod:Add("description", "Get all " + ResourceName + " with optional filtering").
        jaMethods:Add(joMethod).
        
        joMethod = new JsonObject().
        joMethod:Add("name", "get").
        joMethod:Add("description", "Get " + EntityName + " by ID").
        jaMethods:Add(joMethod).
        
        joMethod = new JsonObject().
        joMethod:Add("name", "create").
        joMethod:Add("description", "Create a new " + EntityName).
        jaMethods:Add(joMethod).
        
        joMethod = new JsonObject().
        joMethod:Add("name", "update").
        joMethod:Add("description", "Update an existing " + EntityName).
        jaMethods:Add(joMethod).
        
        joMethod = new JsonObject().
        joMethod:Add("name", "delete").
        joMethod:Add("description", "Delete a " + EntityName + " by ID").
        jaMethods:Add(joMethod).
        
        /* Add custom methods from subclass */
        
        if valid-object(jaCustomMethods) and jaCustomMethods:Length > 0 then do:
            
            do i = 1 to jaCustomMethods:Length:
                jaMethods:Add(jaCustomMethods:GetJsonObject(i)).
            end.
        end.
        
    

        joSchema:Add("methods", jaMethods).
        /* Write schema to file for debugging */
        //joSchema:WriteFile('/tmp/joSchema.json').

        return joSchema.
    
        finally:
            //delete object joMetadata no-error.
            //delete object jaMethods no-error.
            //delete object joMethod no-error.
            //delete object jaCustomMethods no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get the name of this resource
     Returns: character containing the resource name
    ------------------------------------------------------------------------------*/
    method public character GetResourceName():
        return ResourceName.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle list method
     Parameters:
       input poService - Service instance
       input poParameters - Method parameters
     Returns: JsonObject containing method result
    ------------------------------------------------------------------------------*/
    method protected JsonObject HandleList(input poService as IService, input poParameters as JsonObject):
        /* Create filter from parameters */
        var character filterStr = poParameters:GetCharacter("filter").
        var integer limitVal = poParameters:GetInteger("limit").
        var integer offsetVal = poParameters:GetInteger("offset").
        var character sortBy = poParameters:GetCharacter("sort_by").
        var JsonObject joResult = new JsonObject().
        var handle hQueryParams.

        
        /* Create filter parameters */
        var FilterParams filter = new FilterParams(EntityName, "", "", "", "", output table-handle hQueryParams).
        
        /* Set filter values */
        if filterStr > "" then
            filter:Where = filterStr.
            
        if limitVal > 0 then
            filter:TopRecs = limitVal.
            
        if offsetVal >= 0 then
            filter:SkipRecs = offsetVal.
            
        if sortBy > "" then
            filter:sortby = sortBy.
        
        /* Get entities from service */
        poService:GetByFilter(filter).
        
        return joResult.
        
        finally:
            delete object filter no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle get method
     Parameters:
       input poService - Service instance
       input poParameters - Method parameters
     Returns: JsonObject containing method result
    ------------------------------------------------------------------------------*/
    method protected JsonObject HandleGet(input poService as IService, input poParameters as JsonObject):
        /* Get ID from parameters */
        var character id = poParameters:GetCharacter("id").
        var JsonObject joError = new JsonObject().
        var JsonObject joResult = poService:GetById(id).
        
        /* Validate ID */
        if id = ? or id = "" then do:
            joError:Add("error", "Missing ID parameter").
            joError:Add("resource", ResourceName).
            joError:Add("method", "get").
            return joError.
        end.
        
        /* Get entity from service */
        
        
        return joResult.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle create method
     Parameters:
       input poService - Service instance
       input poParameters - Method parameters
     Returns: JsonObject containing method result
    ------------------------------------------------------------------------------*/
    method protected JsonObject HandleCreate(input poService as IService, input poParameters as JsonObject):
        /* Create entity from parameters */
        var JsonObject joResult = poService:Create(poParameters).
        
        return joResult.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle update method
     Parameters:
       input poService - Service instance
       input poParameters - Method parameters
     Returns: JsonObject containing method result
    ------------------------------------------------------------------------------*/
    method protected JsonObject HandleUpdate(input poService as IService, input poParameters as JsonObject):
        /* Get ID from parameters */
        var character id = poParameters:GetCharacter("id").
        var JsonObject entityData = cast(poParameters:GetJsonObject(EntityName), JsonObject).
        var JsonObject joError = new JsonObject().
        var JsonObject joResult = new JsonObject().
        /* If entity data is under the entity name key, use that */
        if not valid-object(entityData) then
            entityData = cast(poParameters:GetJsonObject("entity"), JsonObject).
            
        /* If still not found, try using the parameters directly (without id) */
        if not valid-object(entityData) then do:
            entityData = cast(poParameters:Clone(), JsonObject).
            entityData:Remove("id").
        end.
        
        /* Validate parameters */
        if id = ? or id = "" then do:
            
            joError:Add("error", "Missing ID parameter").
            joError:Add("resource", ResourceName).
            joError:Add("method", "update").
            return joError.
        end.
        
        if not valid-object(entityData) then do:
            
            joError:Add("error", "Missing entity data").
            joError:Add("resource", ResourceName).
            joError:Add("method", "update").
            joError:Add("id", id).
            return joError.
        end.
        
        /* Update entity */
        poService:Update(id, entityData).
        
        return joResult.
        
        finally:
            delete object entityData no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle delete method
     Parameters:
       input poService - Service instance
       input poParameters - Method parameters
     Returns: JsonObject containing method result
    ------------------------------------------------------------------------------*/
    method protected JsonObject HandleDelete(input poService as IService, input poParameters as JsonObject):
        /* Get ID from parameters */
        var character id = poParameters:GetCharacter("id").
        var JsonObject joError = new JsonObject().
        var JsonObject joResult = new JsonObject().
        
        var logical lResult. 

        /* Validate ID */
        if id = ? or id = "" then do:
            
            joError:Add("error", "Missing ID parameter").
            joError:Add("resource", ResourceName).
            joError:Add("method", "delete").
            return joError.
        end.
        
        /* Delete entity */
        lResult = poService:Delete(id).
        
        
        if lResult then do:
            joResult:Add("message", "Entity deleted successfully").
            joResult:Add("entity", EntityName).
            joResult:Add("id", id).
        end.
        else do:
            joResult:Add("error", "Entity not found").
            joResult:Add("entity", EntityName).
            joResult:Add("id", id).
        end.
        
        return joResult.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle custom method
     Parameters:
       input pcMethodName - Method name
       input poService - Service instance
       input poParameters - Method parameters
     Returns: JsonObject containing method result
     Notes: Override in subclasses to handle custom methods
    ------------------------------------------------------------------------------*/
    method protected JsonObject HandleCustomMethod(
        input pcMethodName as character, 
        input poService as IService, 
        input poParameters as JsonObject):
        
        /* Default implementation returns method not found error */
        var JsonObject joError = new JsonObject().
        joError:Add("error", "Method not found").
        joError:Add("resource", ResourceName).
        joError:Add("method", pcMethodName).
        
        return joError.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get schema for custom methods
     Returns: JsonArray containing custom method schemas
     Notes: Override in subclasses to provide custom method schemas
    ------------------------------------------------------------------------------*/
    method protected JsonArray GetCustomMethodsSchema():
        /* Default implementation returns empty array */
        return new JsonArray().
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public BaseResourceHandler():
        /* No resources to clean up */
    end destructor.
    
end class.
