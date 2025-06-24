/*------------------------------------------------------------------------
   File        : GenericServiceRefactored
   Purpose     : Generic REST service handler for CRUD operations using Service Layer
   Syntax      : class GenericServiceRefactored inherits WebHandler
   Description : Provides a generic web service interface for handling HTTP
                 requests to perform CRUD operations on entities.
                 Uses Service Layer for business logic.
   Author(s)   : rdroge, Cascade AI
   Created     : 2025-06-24
   Notes       : - Full CRUD support (GET, POST, PUT, DELETE)
                 - Uses Service Layer pattern
                 - Standardized error responses with details
                 - Resource cleanup and transaction management
 ----------------------------------------------------------------------*/

using Progress.Json.ObjectModel.*.
using generics.FilterParams.
using Progress.Lang.*.
using OpenEdge.Net.*.
using OpenEdge.Net.HTTP.*.
using OpenEdge.Web.*.
using interfaces.IService.
using webhandlers.ServiceFactory.

block-level on error undo, throw.


class GenericServiceRefactored inherits WebHandler: 
    define temp-table ttQueryParams
            field fieldname   as character 
            field fieldvalue  as character 
            index fieldname is primary unique fieldname ascending.
    /* Service factory for creating service instances */
    define private variable serviceFactory as ServiceFactory no-undo.

    constructor public GenericServiceRefactored():
        super().
        /* Initialize service factory */
        serviceFactory = webhandlers.ServiceFactory:GetInstance().
    end constructor.

    /*------------------------------------------------------------------------------
     Purpose: Handles HTTP GET requests for entity data or metadata
     Parameters:
       input poRequest as OpenEdge.Web.IWebRequest - The incoming web request
     Returns: integer - HTTP status code
     Notes:
       - Supports two API types: 'data' and 'meta'
       - For data: retrieves entity records with optional filtering
       - For meta: returns entity metadata/model information
       - Uses Service Layer for business logic
    ------------------------------------------------------------------------------*/
    method override protected integer HandleGet(input poRequest as OpenEdge.Web.IWebRequest):
        /* Request parameters */
        var character entityName = poRequest:GetPathParameter("entityname").
        var character entityName2 = poRequest:GetPathParameter("entityname2").
        var character id1 = poRequest:GetPathParameter("id1").
        var character id2 = poRequest:GetPathParameter("id2").
        var character apiType = poRequest:GetPathParameter("apitype").
        var character queryString = poRequest:GetContextValue("QUERY_STRING").
        
        /* Response objects */
        var WebResponse response = new WebResponse().
        var WebResponseWriter writer = new WebResponseWriter(response).
        var longchar body.
        
        /* Filter parameters */
        
        var FilterParams filter = new generics.FilterParams(
            entityName, entityName2, queryString, id1, id2, output table ttQueryParams).
        
        /* Service instance */
        var IService entityService = ?.
        
        /* JSON response objects */
        var JsonObject joResponse = ?.
        
        /* Process request based on API type */
        if apiType = "data" then do:
                /* Get service for entity */
                entityService = serviceFactory:GetService(entityName).
                
                /* Process request based on ID presence */
                if filter:id1 > "" then
                    joResponse = entityService:GetById(filter:id1).
                else
                    joResponse = entityService:GetByFilter(filter).
                
                /* Set success response */
                response:StatusCode = 200.
                body = joResponse:GetJsonText().
        end.
        
        else if apiType = "meta" then do:
            /* Get service for entity */
            entityService = ServiceFactory:GetService(entityName).
            
            /* Get entity metadata */
            joResponse = entityService:GetMetadata().
                
            /* Set success response */
            response:StatusCode = 200.
            body = joResponse:GetJsonText().

            
        end.    
        
        else do:
            /* Handle invalid API type */
            response:StatusCode = 400.
            joResponse = new JsonObject().
            joResponse:Add("error", "Invalid API type").
            joResponse:Add("apiType", apiType).
            body = joResponse:GetJsonText().
        end.
        
        /* Set response */
        response:ContentType = "application/json".
        writer:write(body).
        writer:flush().
        writer:close().
        
        return response:StatusCode.
        catch e as Progress.Lang.Error:
            /* Handle service errors */
            response:StatusCode = 500.
            joResponse = new JsonObject().
            joResponse:Add("error", "Error retrieving entity metadata").
            joResponse:Add("entity", entityName).
            joResponse:Add("details", e:GetMessage(1)).
            body = joResponse:GetJsonText().
        end.

        finally:
            delete object joResponse no-error.
            delete object filter no-error.
            delete object response no-error.
            delete object writer no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handles HTTP POST requests for entity operations
     Parameters:
       input poRequest as OpenEdge.Web.IWebRequest - The incoming web request
     Returns: integer - HTTP status code
     Notes:
       - Validates entity existence and request data
       - Performs create operations using Service Layer
       - Returns appropriate status codes and error messages
    ------------------------------------------------------------------------------*/
    method override protected integer HandlePost(input poRequest as OpenEdge.Web.IWebRequest):
        /* Request parameters */
        var character entityName = poRequest:GetPathParameter("entityname").
        var character id = poRequest:GetPathParameter("id").
        var JsonObject requestBody = cast(poRequest:Entity, JsonObject).
        
        /* Response objects */
        var WebResponse response = new WebResponse().
        var WebResponseWriter writer = new WebResponseWriter(response).
        var JsonObject joResponse = ?.
        
        /* Service instance */
        var IService entityService = ?.
        
        /* Initialize response */
        response:ContentType = "application/json".
        
        /* Validate request body */
        if not valid-object(requestBody) then do:
            response:StatusCode = 400.
            joResponse = new JsonObject().
            joResponse:Add("error", "Missing request body").
            joResponse:Add("entity", entityName).
            writer:write(joResponse:GetJsonText()).
            return response:StatusCode.
        end.
        
        /* Get service for entity */
        entityService = serviceFactory:GetService(entityName).
        
        /* Process create request */
        joResponse = entityService:Create(requestBody).
            
        /* Check for error in response */
        if joResponse:Has("error") then
            response:StatusCode = 422.
        else
            response:StatusCode = 201.
                
            writer:write(joResponse:GetJsonText()).

        
        writer:flush().
        writer:close().
        
        return response:StatusCode.
        catch e as Progress.Lang.Error:
            /* Handle service errors */
            response:StatusCode = 500.
            joResponse = new JsonObject().
            joResponse:Add("error", "Error creating entity").
            joResponse:Add("entity", entityName).
            joResponse:Add("details", e:GetMessage(1)).
            writer:write(joResponse:GetJsonText()).
        end.
        
        finally:
            delete object joResponse no-error.
            delete object response no-error.
            delete object writer no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handles HTTP PUT requests for entity updates
     Parameters:
       input poRequest as OpenEdge.Web.IWebRequest - The incoming web request
     Returns: integer - HTTP status code
     Notes:
       - Validates entity existence and request data
       - Performs update operations using Service Layer
       - Returns appropriate status codes and error messages
    ------------------------------------------------------------------------------*/
    method override protected integer HandlePut(input poRequest as OpenEdge.Web.IWebRequest):
        /* Request parameters */
        var character entityName = poRequest:GetPathParameter("entityname").
        var character id = poRequest:GetPathParameter("id").
        var JsonObject requestBody = cast(poRequest:Entity, JsonObject).
        
        /* Response objects */
        var WebResponse response = new WebResponse().
        var WebResponseWriter writer = new WebResponseWriter(response).
        var JsonObject joResponse = ?.
        
        /* Service instance */
        var IService entityService = ?.
        
        /* Initialize response */
        response:ContentType = "application/json".
        
        /* Validate request parameters */
        if id = "" then do:
            response:StatusCode = 400.
            joResponse = new JsonObject().
            joResponse:Add("error", "Missing ID parameter").
            joResponse:Add("entity", entityName).
            writer:write(joResponse:GetJsonText()).
            return response:StatusCode.
        end.
        
        /* Validate request body */
        if not valid-object(requestBody) then do:
            response:StatusCode = 400.
            joResponse = new JsonObject().
            joResponse:Add("error", "Missing request body").
            joResponse:Add("entity", entityName).
            joResponse:Add("id", id).
            writer:write(joResponse:GetJsonText()).
            return response:StatusCode.
        end.
        
        /* Get service for entity */
        entityService = serviceFactory:GetService(entityName).
        
        /* Process update request */
        joResponse = entityService:Update(id, requestBody).
            
        /* Check for error in response */
        if joResponse:Has("error") then
            response:StatusCode = 422.
        else
            response:StatusCode = 200.
            
        writer:write(joResponse:GetJsonText()).
        
        
        
        writer:flush().
        writer:close().
        
        return response:StatusCode.
        catch e as Progress.Lang.Error:
            /* Handle service errors */
            response:StatusCode = 500.
            joResponse = new JsonObject().
            joResponse:Add("error", "Error updating entity").
            joResponse:Add("entity", entityName).
            joResponse:Add("id", id).
            joResponse:Add("details", e:GetMessage(1)).
            writer:write(joResponse:GetJsonText()).
        end.
        finally:
            delete object joResponse no-error.
            delete object response no-error.
            delete object writer no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handles HTTP DELETE requests for entity deletions
     Parameters:
       input poRequest as OpenEdge.Web.IWebRequest - The incoming web request
     Returns: integer - HTTP status code
     Notes:
       - Validates entity existence
       - Performs delete operations using Service Layer
       - Returns appropriate status codes and error messages
    ------------------------------------------------------------------------------*/
    method override protected integer HandleDelete(input poRequest as OpenEdge.Web.IWebRequest):
        /* Request parameters */
        var character entityName = poRequest:GetPathParameter("entityname").
        var character id = poRequest:GetPathParameter("id").
        
        /* Response objects */
        var WebResponse response = new WebResponse().
        var WebResponseWriter writer = new WebResponseWriter(response).
        var JsonObject joResponse = new JsonObject().
        
        /* Service instance */
        var IService entityService = ?.
        var logical lSuccess.
        
        /* Initialize response */
        response:ContentType = "application/json".
        
        /* Validate request parameters */
        if id = "" then do:
            response:StatusCode = 400.
            joResponse:Add("error", "Missing ID parameter").
            joResponse:Add("entity", entityName).
            writer:write(joResponse:GetJsonText()).
            return response:StatusCode.
        end.
        
        /* Get service for entity */
        entityService = serviceFactory:GetService(entityName).
        
        /* Process delete request */
        lSuccess = entityService:Delete(id).
            
        /* Set response based on result */
        if lSuccess then do:
            response:StatusCode = 200.
            joResponse:Add("message", "Entity deleted successfully").
            joResponse:Add("entity", entityName).
            joResponse:Add("id", id).
            end.
            else do:
                response:StatusCode = 404.
                joResponse:Add("error", "Entity not found").
                joResponse:Add("entity", entityName).
                joResponse:Add("id", id).
            end.
            
            writer:write(joResponse:GetJsonText()).
        
        
        writer:flush().
        writer:close().
        
        return response:StatusCode.
        catch e as Progress.Lang.Error:
            /* Handle service errors */
            response:StatusCode = 500.
            joResponse:Add("error", "Error deleting entity").
            joResponse:Add("entity", entityName).
            joResponse:Add("id", id).
            joResponse:Add("details", e:GetMessage(1)).
            writer:write(joResponse:GetJsonText()).
        end.
        
        finally:
            delete object joResponse no-error.
            delete object response no-error.
            delete object writer no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a standardized error response
     Parameters:
       input piStatusCode as integer   - HTTP status code
       input pcError as character      - Error message
       input pcEntity as character     - Entity name
       input pcDetails as character    - Optional error details
       input pcId as character         - Optional entity ID
     Returns: JsonObject - Error response object
    ------------------------------------------------------------------------------*/
    method private JsonObject CreateErrorResponse(
        input piStatusCode as integer,
        input pcError as character,
        input pcEntity as character,
        input pcDetails as character,
        input pcId as character):
        
        var JsonObject joError = new JsonObject().
        joError:Add("error", pcError).
        joError:Add("entity", pcEntity).
        
        if pcDetails > "" then
            joError:Add("details", pcDetails).
            
        if pcId > "" then
            joError:Add("id", pcId).
            
        return joError.
    end method.
    
    destructor public GenericServiceRefactored():
        /* No resources to clean up */
    end destructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Handler for unsupported methods
     Parameters:
       input poRequest as OpenEdge.Web.IWebRequest - The incoming web request
     Returns: integer - HTTP status code
     Notes: Required implementation of abstract method from WebHandler
    ------------------------------------------------------------------------------*/
    method override protected integer HandleNotAllowedMethod(input poRequest as OpenEdge.Web.IWebRequest):
        var JsonObject joError = createErrorResponse(405, "Method not allowed", poRequest:GetPathParameter("entityname"), "The HTTP method used is not supported for this resource", "").
        
        /* Create and set response with error details */
        var WebResponse response = new WebResponse().
        var WebResponseWriter writer = new WebResponseWriter(response).
        
        response:StatusCode = 405. /* Method Not Allowed */
        response:ContentType = "application/json".
        writer:write(joError:GetJsonText()).
        writer:flush().
        
        
        return 405.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handler for unknown methods. The request being serviced and an 
              optional status code is returned. A zero or null value means 
              this method will deal with all errors.                                                               
     Notes:   Required implementation of abstract method from WebHandler                                                                     
    ------------------------------------------------------------------------------*/
    method override protected integer HandleNotImplemented(input poRequest as OpenEdge.Web.IWebRequest):
        /* Response objects */
        var WebResponse response = new WebResponse().
        var WebResponseWriter writer = new WebResponseWriter(response).
        var JsonObject joResponse = new JsonObject().
        
        /* Set error response */
        response:StatusCode = 501.
        response:ContentType = "application/json".
        joResponse:Add("error", "Method not implemented").
        joResponse:Add("method", poRequest:Method).
        joResponse:Add("path", poRequest:PathInfo).
        
        writer:write(joResponse:GetJsonText()).
        writer:flush().
        writer:close().
        
        return response:StatusCode.
        
        finally:
            delete object joResponse no-error.
            delete object response no-error.
            delete object writer no-error.
        end finally.
    end method.

end class.
