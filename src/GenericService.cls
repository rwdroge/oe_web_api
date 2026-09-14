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
using generics.ResponseContext.
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
     Purpose: Validate request body exists
     Parameters:
       input poRequestBody - Request body to validate
       input pcEntityName - Entity name for error message
       input poContext - Response context
       input pcId - Optional ID for error message
     Returns: logical - true if valid, false if invalid (response already sent)
     Notes: Helper to eliminate duplication in Handle* methods
    ------------------------------------------------------------------------------*/
    method private logical ValidateRequestBody(
        input poRequestBody as JsonObject,
        input pcEntityName as character,
        input poContext as ResponseContext,
        input pcId as character):
        
        if not valid-object(poRequestBody) then do:
            poContext:Response:StatusCode = 400.
            poContext:JsonResponse = new JsonObject().
            poContext:JsonResponse:Add("error", "Missing request body").
            poContext:JsonResponse:Add("entity", pcEntityName).
            if pcId > "" then
                poContext:JsonResponse:Add("id", pcId).
            poContext:Writer:write(poContext:JsonResponse:GetJsonText()).
            return false.
        end.
        
        return true.
    end method.

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
        
        /* Response context */
        var ResponseContext ctx = new ResponseContext().
        
        /* Filter parameters */
        var generics.FilterConstructorParams filterParams = new generics.FilterConstructorParams().
        var FilterParams filter.
        
        /* Service instance */
        var IService entityService = ?.
        
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
            ctx:JsonResponse = this-object:ProcessDataRequest(entityName, filter).
            ctx:Response:StatusCode = 200.
        end.
        else if apiType = "meta" then do:
            ctx:JsonResponse = this-object:ProcessMetaRequest(entityName).
            ctx:Response:StatusCode = 200.
        end.    
        else do:
            /* Handle invalid API type */
            ctx:Response:StatusCode = 400.
            ctx:JsonResponse = new JsonObject().
            ctx:JsonResponse:Add("error", "Invalid API type").
            ctx:JsonResponse:Add("apiType", apiType).
        end.
        
        /* Set response entity and write using proper WebHandler pattern */
        ctx:Response:Entity = ctx:JsonResponse.
        ctx:Writer:Open().
        ctx:Writer:Close().
        
        return 0.
        catch e as Progress.Lang.Error:
            return this-object:HandleException(e, ctx:Response, entityName).
        end.

        finally:
            delete object filter no-error.
            delete object ctx:JsonResponse no-error.
            delete object ctx:Response no-error.
            delete object ctx:Writer no-error.
            delete object ctx no-error.
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
        
        /* Response context */
        var ResponseContext ctx = new ResponseContext().
        
        /* Service instance */
        var IService entityService = ?.
        
        /* Validate request body */
        if not valid-object(requestBody) then do:
            ctx:Response:StatusCode = 400.
            ctx:JsonResponse = new JsonObject().
            ctx:JsonResponse:Add("error", "Missing request body").
            ctx:JsonResponse:Add("entity", entityName).
            ctx:Response:Entity = ctx:JsonResponse.
            ctx:Writer:Open().
            ctx:Writer:Close().
            return 0.
        end.
        
        /* Get service for entity */
        entityService = serviceFactory:GetService(entityName).
        
        /* Process create request */
        ctx:JsonResponse = entityService:Create(requestBody).
            
        /* Check for error in response */
        if ctx:JsonResponse:Has("error") then
            ctx:Response:StatusCode = 422.
        else
            ctx:Response:StatusCode = 201.
        
        /* Set entity and write using proper pattern */
        ctx:Response:Entity = ctx:JsonResponse.
        ctx:Writer:Open().
        ctx:Writer:Close().
        
        return 0.
        catch e as Progress.Lang.Error:
            return this-object:HandleException(e, ctx:Response, entityName).
        end.
        
        finally:
            delete object ctx:JsonResponse no-error.
            delete object ctx:Response no-error.
            delete object ctx:Writer no-error.
            delete object ctx no-error.
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
        
        /* Response context */
        var ResponseContext ctx = new ResponseContext().
        
        /* Service instance */
        var IService entityService = ?.
        
        /* Validate request parameters */
        if id = "" then do:
            ctx:Response:StatusCode = 400.
            ctx:JsonResponse = new JsonObject().
            ctx:JsonResponse:Add("error", "Missing ID parameter").
            ctx:JsonResponse:Add("entity", entityName).
            ctx:Response:Entity = ctx:JsonResponse.
            ctx:Writer:Open().
            ctx:Writer:Close().
            return 0.
        end.
        
        /* Validate request body */
        if not valid-object(requestBody) then do:
            ctx:Response:StatusCode = 400.
            ctx:JsonResponse = new JsonObject().
            ctx:JsonResponse:Add("error", "Missing request body").
            ctx:JsonResponse:Add("entity", entityName).
            ctx:JsonResponse:Add("id", id).
            ctx:Response:Entity = ctx:JsonResponse.
            ctx:Writer:Open().
            ctx:Writer:Close().
            return 0.
        end.
        
        /* Get service for entity */
        entityService = serviceFactory:GetService(entityName).
        
        /* Process update request */
        ctx:JsonResponse = entityService:UpdateEntity(id, requestBody).
            
        /* Check for error in response */
        if ctx:JsonResponse:Has("error") then
            ctx:Response:StatusCode = 422.
        else
            ctx:Response:StatusCode = 200.
        
        /* Set entity and write using proper pattern */
        ctx:Response:Entity = ctx:JsonResponse.
        ctx:Writer:Open().
        ctx:Writer:Close().
        
        return 0.
        catch e as Progress.Lang.Error:
            return this-object:HandleException(e, ctx:Response, entityName).
        end.
        finally:
            delete object ctx:JsonResponse no-error.
            delete object ctx:Response no-error.
            delete object ctx:Writer no-error.
            delete object ctx no-error.
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
            response:Entity = joResponse.
            writer:Open().
            writer:Close().
            return 0.
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
        
        /* Set entity and write using proper pattern */
        response:Entity = joResponse.
        writer:Open().
        writer:Close().
        
        return 0.
        catch e as Progress.Lang.Error:
            return this-object:HandleException(e, response, entityName).
        end.
        
        finally:
            delete object joResponse no-error.
            delete object response no-error.
            delete object writer no-error.
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
     Purpose: Handles exceptions following proper WebHandler pattern
     Parameters:
       input poError - The error/exception being processed
       input pResponse - The current response
       input pcEntityName - Optional entity name for context
     Returns: integer - Always returns 0 (framework handles response)
     Notes: Follows RequestEchoHandler pattern for proper error handling
    ------------------------------------------------------------------------------*/
    method protected integer HandleException(
        input poError as Progress.Lang.Error,
        input pResponse as WebResponse,
        input pcEntityName as character):
        
        var JsonObject joError = new JsonObject().
        var WebResponseWriter writer = new WebResponseWriter(pResponse).
        var character cErrorDetails = "".
        var integer i = 0.
        
        /* Set error status and content type */
        assign pResponse:StatusCode = 500
               pResponse:ContentType = "application/json".
        
        /* Collect all error messages */
        do i = 1 to poError:NumMessages:
            cErrorDetails = cErrorDetails + (if i > 1 then " | " else "") + poError:GetMessage(i).
        end.
        
        /* If no messages, provide generic error */
        if cErrorDetails = "" then
            cErrorDetails = "An error occurred processing the request".
        
        /* Build error response */
        joError:Add("error", "Error processing request").
        if pcEntityName > "" then
            joError:Add("entity", pcEntityName).
        joError:Add("details", cErrorDetails).
        joError:Add("errorType", poError:GetClass():TypeName).
        
        /* Set entity and write using proper pattern */
        pResponse:Entity = joError.
        writer:Open().
        writer:Close().
        
        return 0.
        
        finally:
            delete object writer no-error.
        end finally.
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
     Purpose: Handles error in catch block with consistent pattern
     Parameters:
       input response - WebResponse object
       input writer - WebResponseWriter object
       input errorParams - CrudErrorParams object (already created)
     Returns: integer - Always returns 500
     Notes: Calls HandleCrudError, cleans up errorParams, returns 500
    ------------------------------------------------------------------------------*/
    method private integer ProcessCatchError(
        input response as WebResponse,
        input writer as WebResponseWriter,
        input errorParams as CrudErrorParams):
        
        this-object:HandleCrudError(response, writer, errorParams).
        delete object errorParams no-error.
        return 500.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates error params for CRUD operations with entity name
     Parameters:
       input errorMessage - Error message
       input entityName - Entity name
       input errorDetails - Error details from exception
     Returns: CrudErrorParams - Configured error params object
    ------------------------------------------------------------------------------*/
    method private CrudErrorParams CreateCrudErrorParams(
        input errorMessage as character,
        input entityName as character,
        input errorDetails as character):
        
        var CrudErrorParams params = new CrudErrorParams(errorMessage).
        assign
            params:EntityName = entityName
            params:ErrorDetails = errorDetails.
        return params.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates error params for CRUD operations with entity name and ID
     Parameters:
       input errorMessage - Error message
       input entityName - Entity name
       input id - Entity ID
       input errorDetails - Error details from exception
     Returns: CrudErrorParams - Configured error params object
    ------------------------------------------------------------------------------*/
    method private CrudErrorParams CreateCrudErrorParamsWithId(
        input errorMessage as character,
        input entityName as character,
        input id as character,
        input errorDetails as character):
        
        var CrudErrorParams params = new CrudErrorParams(errorMessage).
        assign
            params:EntityName = entityName
            params:Id = id
            params:ErrorDetails = errorDetails.
        return params.
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
        response:Entity = joError.
        writer:Open().
        writer:Close().
        
        return 0. 
        
        finally:
            delete object joError no-error.
            delete object response no-error.
            delete object writer no-error.
            delete object errorParams no-error.
        end finally.
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
        
        response:Entity = joResponse.
        writer:Open().
        writer:Close().
        
        return 0.
        
        finally:
            delete object joResponse no-error.
            delete object response no-error.
            delete object writer no-error.
        end finally.
    end method.

end class.
