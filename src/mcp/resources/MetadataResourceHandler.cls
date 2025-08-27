/*------------------------------------------------------------------------
    File        : MetadataResourceHandler
    Purpose     : MCP resource handler for Metadata
    Syntax      : 
    Description : Handles MCP operations for the Metadata resource
    Author(s)   : Cascade AI
    Created     : 2025-07-10
    Notes       : Implements metadata operations for all entities
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Json.ObjectModel.*.
using mcp.BaseResourceHandler.
using interfaces.IService.
using webhandlers.ServiceFactory.

block-level on error undo, throw.

class mcp.resources.MetadataResourceHandler inherits mcp.BaseResourceHandler:
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for MetadataResourceHandler
     Notes: Initializes resource with name and entity information
    ------------------------------------------------------------------------------*/
    constructor public MetadataResourceHandler():
        super("metadata", "metadata").
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle a method call for this resource
     Parameters:
       input pcMethodName - Method name to handle
       input poParameters - Parameters for the method
     Returns: JsonObject containing the method result
     Notes: Override to handle metadata-specific methods
    ------------------------------------------------------------------------------*/
    method override public JsonObject HandleMethod(input pcMethodName as character, input poParameters as JsonObject):
        var JsonObject joResponse = new JsonObject().
        
        /* Handle method based on name */
        case pcMethodName:
            when "getEntityMetadata" then
                joResponse = HandleGetEntityMetadata(poParameters).
            when "getAllMetadata" then
                joResponse = HandleGetAllMetadata().
            otherwise
                /* Use base implementation for standard methods */
                joResponse = super:HandleMethod(pcMethodName, poParameters).
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
    method override public JsonObject GetSchema():
        /* Declare variables */
        var JsonObject joSchema = new JsonObject().
        var JsonArray jaMethods = new JsonArray().
        var JsonArray jaRequired = new JsonArray().
        var JsonObject joMethod = new JsonObject().
        var JsonObject joInput = new JsonObject().
        var JsonObject joProperties = new JsonObject().
        var JsonObject joEntityProp = new JsonObject().
        
        message " do it get here?"
        /* Initialize schema object */
        joSchema:Add("name", ResourceName).
        joSchema:Add("description", "Entity metadata operations").
        
        
        /* Add getEntityMetadata method */
        joMethod:Add("name", "getEntityMetadata").
        joMethod:Add("description", "Get metadata for a specific entity").
        
        /* Create input schema */
        joInput:Add("type", "object").
        
        
        /* Create entity property */
        joEntityProp:Add("type", "string").
        joEntityProp:Add("description", "Entity name to get metadata for").
        joProperties:Add("entity", joEntityProp).
        
        /* Add properties to input */
        joInput:Add("properties", joProperties).
        
        /* Create required fields */
        jaRequired:Add("entity").
        joInput:Add("required", jaRequired).
        
        /* Add input schema to method */
        joMethod:Add("input_schema", joInput).
        jaMethods:Add(joMethod).
        
        /* Add getAllMetadata method */
        joMethod:Add("name", "getAllMetadata").
        joMethod:Add("description", "Get metadata for all entities").
        
        /* Create input schema */
        joInput:Add("type", "object").
        
        /* Create empty properties */
        joInput:Add("properties", joProperties).
        
        /* Add input schema to method */
        joMethod:Add("input_schema", joInput).
        jaMethods:Add(joMethod).
        
        /* Add methods to schema */
        joSchema:Add("methods", jaMethods).
        
        return joSchema.
        
        finally:
            delete object jaMethods no-error.
            delete object joMethod no-error.
            delete object joInput no-error.
            delete object joProperties no-error.
            delete object joEntityProp no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle getEntityMetadata method
     Parameters:
       input poParameters - Method parameters
     Returns: JsonObject containing method result
    ------------------------------------------------------------------------------*/
    method private JsonObject HandleGetEntityMetadata(input poParameters as JsonObject):
        /* Declare variables */
        var character entityName = ?.
        var JsonObject joError = ?.
        var IService entityService = ?.
        var JsonObject joResult = ?.
        
        /* Get entity from parameters */
        entityName = poParameters:GetCharacter("entity").
        
        /* Validate entity */
        if entityName = ? or entityName = "" then do:
            joError = new JsonObject().
            
            joError:Add("error", "Missing entity parameter").
            joError:Add("resource", ResourceName).
            joError:Add("method", "getEntityMetadata").
            return joError.
        end.
        
        /* Get service for entity */
        
        
        /* Try to get service for entity */
        do:
            entityService = ServiceFactory:GetService(entityName).
        end.
        
        
        /* Get metadata from service */
        joResult = entityService:GetMetadata().
        
        return joResult.
        catch e as Progress.Lang.Error:
            
            joError:Add("error", "Entity not found").
            joError:Add("entity", entityName).
            joError:Add("details", e:GetMessage(1)).
            return joError.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handle getAllMetadata method
     Returns: JsonObject containing method result
    ------------------------------------------------------------------------------*/
    method private JsonObject HandleGetAllMetadata():
        /* Declare variables */
        var JsonObject joResult = ?.
        var JsonObject joEntities = ?.
        var character cEntities = ?.
        var integer i = ?.
        var character cEntity = ?.
        var IService entityService. 
        var JsonObject joMetadata.
        
        /* Initialize objects */
        joResult = new JsonObject().
        joEntities = new JsonObject().
        
        /* Get metadata for standard entities */
        cEntities = "items,customers,orders,suppliers".
        
        do i = 1 to num-entries(cEntities):
            cEntity = entry(i, cEntities).
            
            /* Try to get service for entity */
            do:
                entityService = ServiceFactory:GetService(cEntity).
                joMetadata = entityService:GetMetadata().
                joEntities:Add(cEntity, joMetadata).
                
                delete object joMetadata no-error.
            end.

        end.
        
        
        joResult:Add("entities", joEntities).
        
        return joResult.
        catch e as Progress.Lang.Error:
            /* Skip entities that don't have a service */
        end.
        
        finally:
            delete object joEntities no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public MetadataResourceHandler():
        /* No resources to clean up */
    end destructor.
    
end class.
