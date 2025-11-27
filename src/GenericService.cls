/*------------------------------------------------------------------------
   File        : GenericService
   Purpose     : Generic REST service handler for CRUD operations using Service Layer
   Syntax      : class GenericService inherits WebHandler
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
using generics.FilterConstructorParams.
using generics.ErrorResponseParams.
using generics.CrudErrorParams.
using Progress.Lang.*.
using OpenEdge.Net.*.
using OpenEdge.Net.HTTP.*.
using OpenEdge.Web.*.
using interfaces.IService.
using webhandlers.ServiceFactory.

block-level on error undo, throw.


class GenericService inherits WebHandler: 
    define temp-table ttQueryParams
            field fieldname   as character 
            field fieldvalue  as character 
            index fieldname is primary unique fieldname ascending.
    /* Service factory for creating service instances */
    define private variable serviceFactory as ServiceFactory no-undo.

    constructor public GenericService():
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
        var generics.FilterConstructorParams filterParams = new generics.FilterConstructorParams().
        var FilterParams filter.
        
        /* Service instance */
        var IService entityService = ?.
        
        /* JSON response objects */
        var JsonObject joResponse = new JsonObject().
        var CrudErrorParams errorParams.
        
        /* Set filter properties */
        assign
            filterParams:Entity = entityName
            filterParams:Entity2 = entityName2
            filterParams:QueryString = queryString
            filterParams:Id1 = id1
            filterParams:Id2 = id2.
        
        /* Create filter with parameters */
        filter = new generics.FilterParams(filterParams, output table ttQueryParams).
        
        /* Process request based on API type */
        if apiType = "data" then do:
            joResponse = this-object:ProcessDataRequest(entityName, filter).
            response:StatusCode = 200.
        end.
        else if apiType = "meta" then do:
            joResponse = this-object:ProcessMetaRequest(entityName).
            response:StatusCode = 200.
        end.    
        else do:
            /* Handle invalid API type */
            response:StatusCode = 400.
            joResponse = new JsonObject().
            joResponse:Add("error", "Invalid API type").
            joResponse:Add("apiType", apiType).
        end.
        
        /* Write response */
        response:ContentType = "application/json".
        response:ContentLength = length(joResponse:GetJsonText()).
        writer:write(joResponse:GetJsonText()).
        writer:flush().
        writer:close().
        
        return response:StatusCode.
        catch e as Progress.Lang.Error:
            errorParams = new CrudErrorParams("Error retrieving entity data").
            assign
                errorParams:EntityName = entityName
                errorParams:ErrorDetails = e:GetMessage(1).
            this-object:HandleCrudError(response, writer, errorParams).
            delete object errorParams no-error.
            return 500.
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
        var CrudErrorParams errorParams.
        
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
        
        this-object:WriteJsonResponse(response, writer, joResponse).
        
        return response:StatusCode.
        catch e as Progress.Lang.Error:
            errorParams = new CrudErrorParams("Error creating entity").
            assign
                errorParams:EntityName = entityName
                errorParams:ErrorDetails = e:GetMessage(1).
            this-object:HandleCrudError(response, writer, errorParams).
            delete object errorParams no-error.
            return 500.
        end.
        
        finally:
            this-object:CleanupResponseObjects(joResponse, response, writer).
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
        var CrudErrorParams errorParams.
        
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
        
        this-object:WriteJsonResponse(response, writer, joResponse).
        
        return response:StatusCode.
        catch e as Progress.Lang.Error:
            errorParams = new CrudErrorParams("Error updating entity").
            assign
                errorParams:EntityName = entityName
                errorParams:Id = id
                errorParams:ErrorDetails = e:GetMessage(1).
            this-object:HandleCrudError(response, writer, errorParams).
            delete object errorParams no-error.
            return 500.
        end.
        finally:
            this-object:CleanupResponseObjects(joResponse, response, writer).
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
        var CrudErrorParams errorParams.
        
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
        
        this-object:WriteJsonResponse(response, writer, joResponse).
        
        return response:StatusCode.
        catch e as Progress.Lang.Error:
            errorParams = new CrudErrorParams("Error deleting entity").
            assign
                errorParams:EntityName = entityName
                errorParams:Id = id
                errorParams:ErrorDetails = e:GetMessage(1).
            this-object:HandleCrudError(response, writer, errorParams).
            delete object errorParams no-error.
            return 500.
        end.
        
        finally:
            this-object:CleanupResponseObjects(joResponse, response, writer).
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Processes data API requests (GET with filtering)
     Parameters:
       input entityName - Entity name
       input filter - FilterParams object
     Returns: JsonObject - Response data
     Notes: Handles both single record (by ID) and filtered list requests
    ------------------------------------------------------------------------------*/
    method private JsonObject ProcessDataRequest(
        input entityName as character,
        input filter as FilterParams):
        
        var IService entityService = serviceFactory:GetService(entityName).
        var JsonObject joResponse.
        
        /* Process request based on ID presence */
        if filter:id1 > "" then
            joResponse = entityService:GetById(filter:id1).
        else
            joResponse = entityService:GetByFilter(filter).
        
        return joResponse.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Processes metadata API requests
     Parameters:
       input entityName - Entity name
     Returns: JsonObject - Entity metadata
    ------------------------------------------------------------------------------*/
    method private JsonObject ProcessMetaRequest(input entityName as character):
        
        var IService entityService = ServiceFactory:GetService(entityName).
        var JsonObject joResponse = entityService:GetMetadata().
        
        return joResponse.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a standardized error response
     Parameters:
       input poErrorParams as ErrorResponseParams - Error response parameters
     Returns: JsonObject - Error response object
    ------------------------------------------------------------------------------*/
    method private JsonObject CreateErrorResponse(input poErrorParams as ErrorResponseParams):
        
        var JsonObject joError = new JsonObject().
        joError:Add("error", poErrorParams:ErrorMessage).
        
        if poErrorParams:HasEntityContext() then
            joError:Add("entity", poErrorParams:EntityName).
            
        if poErrorParams:HasDetails() then
            joError:Add("details", poErrorParams:Details).
            
        if poErrorParams:HasId() then
            joError:Add("id", poErrorParams:Id).
            
        return joError.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Writes JSON response and finalizes the HTTP response
     Parameters:
       input response - WebResponse object
       input writer - WebResponseWriter object
       input joResponse - JsonObject to write
     Notes: Handles writing, flushing, and closing the response writer
    ------------------------------------------------------------------------------*/
    method private void WriteJsonResponse(
        input response as WebResponse,
        input writer as WebResponseWriter,
        input joResponse as JsonObject):
        
        response:ContentType = "application/json".
        writer:write(joResponse:GetJsonText()).
        writer:flush().
        writer:close().
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handles error responses for CRUD operations
     Parameters:
       input response - WebResponse object
       input writer - WebResponseWriter object
       input errorParams - CrudErrorParams containing error details
     Notes: Creates error JSON, sets 500 status, and writes response
    ------------------------------------------------------------------------------*/
    method private void HandleCrudError(
        input response as WebResponse,
        input writer as WebResponseWriter,
        input errorParams as CrudErrorParams):
        
        var JsonObject joError = new JsonObject().
        
        response:StatusCode = 500.
        joError:Add("error", errorParams:ErrorMessage).
        
        if errorParams:EntityName > "" then
            joError:Add("entity", errorParams:EntityName).
            
        if errorParams:Id > "" then
            joError:Add("id", errorParams:Id).
            
        if errorParams:ErrorDetails > "" then
            joError:Add("details", errorParams:ErrorDetails).
            
        writer:write(joError:GetJsonText()).
        
        delete object joError no-error.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Cleans up response-related objects
     Parameters:
       input joResponse - JsonObject to delete
       input response - WebResponse to delete
       input writer - WebResponseWriter to delete
     Notes: Safely deletes objects with no-error
    ------------------------------------------------------------------------------*/
    method private void CleanupResponseObjects(
        input joResponse as JsonObject,
        input response as WebResponse,
        input writer as WebResponseWriter):
        
        delete object joResponse no-error.
        delete object response no-error.
        delete object writer no-error.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Public wrapper for HandleGet - for testing purposes only
     Parameters:
       input poRequest as OpenEdge.Web.IWebRequest - The incoming web request
     Returns: integer - HTTP status code
     Notes: This method exists solely to enable unit testing of HandleGet logic
    ------------------------------------------------------------------------------*/
    method public integer TestHandleGet(input poRequest as OpenEdge.Web.IWebRequest):
        return this-object:HandleGet(poRequest).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Public wrapper for HandlePost - for testing purposes only
     Parameters:
       input poRequest as OpenEdge.Web.IWebRequest - The incoming web request
     Returns: integer - HTTP status code
     Notes: This method exists solely to enable unit testing of HandlePost logic
    ------------------------------------------------------------------------------*/
    method public integer TestHandlePost(input poRequest as OpenEdge.Web.IWebRequest):
        return this-object:HandlePost(poRequest).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Public wrapper for HandlePut - for testing purposes only
     Parameters:
       input poRequest as OpenEdge.Web.IWebRequest - The incoming web request
     Returns: integer - HTTP status code
     Notes: This method exists solely to enable unit testing of HandlePut logic
    ------------------------------------------------------------------------------*/
    method public integer TestHandlePut(input poRequest as OpenEdge.Web.IWebRequest):
        return this-object:HandlePut(poRequest).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Public wrapper for HandleDelete - for testing purposes only
     Parameters:
       input poRequest as OpenEdge.Web.IWebRequest - The incoming web request
     Returns: integer - HTTP status code
     Notes: This method exists solely to enable unit testing of HandleDelete logic
    ------------------------------------------------------------------------------*/
    method public integer TestHandleDelete(input poRequest as OpenEdge.Web.IWebRequest):
        return this-object:HandleDelete(poRequest).
    end method.

    destructor public GenericService():
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
        /* Declare all variables at the beginning of the method */
        var ErrorResponseParams errorParams = new ErrorResponseParams(405, "Method not allowed").
        var JsonObject joError.
        var WebResponse response = new WebResponse().
        var WebResponseWriter writer = new WebResponseWriter(response).
        
        /* Set error parameters */
        errorParams:SetEntityContext(poRequest:GetPathParameter("entityname"), "").
        errorParams:Details = "The HTTP method used is not supported for this resource".
        joError = createErrorResponse(errorParams).
        
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
