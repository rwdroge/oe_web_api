/*------------------------------------------------------------------------
   File        : GenericService
   Purpose     : Generic REST service handler for CRUD operations
   Syntax      : class GenericService inherits WebHandler
   Description : Provides a generic web service interface for handling HTTP
                 requests to perform CRUD operations on entities.
                 Supports data operations, metadata retrieval, and error handling.
   Author(s)   : rdroge
   Created     : Jan 10, 2019 8:45:21 AM 2019
   Notes       : - Full CRUD support (GET, POST, PUT, DELETE)
                 - Supports single and joined entity operations
                 - Handles both data and metadata requests
                 - Implements field validation and error handling
                 - Standardized error responses with details
                 - Resource cleanup and transaction management
 ----------------------------------------------------------------------*/

using Progress.Json.ObjectModel.*.
using generics.FilterParams.*.
using Progress.Lang.*.
using OpenEdge.Net.*.
using OpenEdge.Net.HTTP.*.
using OpenEdge.Web.*.
using interfaces.CRUD.*.
using interfaces.RO.*.
using generics.GenericEntity.*.
block-level on error undo, throw.

class GenericService inherits WebHandler: 


    /*------------------------------------------------------------------------------
     Purpose: Handles HTTP GET requests for entity data or metadata
     Parameters:
       input poRequest as OpenEdge.Web.IWebRequest - The incoming web request
     Returns: integer - HTTP status code
     Notes:
       - Supports two API types: 'data' and 'meta'
       - For data: retrieves entity records with optional filtering
       - For meta: returns entity metadata/model information
       - Handles both single entity and joined entity requests
    ------------------------------------------------------------------------------*/
    method override protected integer HandleGet(input poRequest as OpenEdge.Web.IWebRequest):
        /* Control variables */
        var logical lOk = true.

        var integer ii, iii.
        var character listItem.
        
        /* Request parameters */
        var character entityName = poRequest:GetPathParameter("entityname").
        var character entityName2 = poRequest:GetPathParameter("entityname2").
        var character id1 = poRequest:GetPathParameter("id1").
        var character id2 = poRequest:GetPathParameter("id2").
        var character apiType = poRequest:GetPathParameter("apitype").
        var character queryString = poRequest:GetContextValue("QUERY_STRING").
        
        /* Response and data objects */
        var WebResponse response = new WebResponse().
        var WebResponseWriter writer = new WebResponseWriter(response).
        var longchar body, lcModel.
        var handle hDataSet, hTempTable, hQueryParams, hQuery.
        
        /* Business objects */
        var generics.FilterParams filter = new generics.FilterParams(entityName, entityName2, queryString, id1, id2, output table-handle hQueryParams).
        var interfaces.CRUD dynClass.
        var interfaces.RO dynClass2.
        
        /* Validation */
        var character oFieldlist, oValuelist.
        
        /* JSON objects */
        var JsonObject joError, joResult.
        var JsonArray jaError, jaResult.
        
        if apiType = "data" then
        do:
            
            dynClass = dynamic-new string("entities." + entityName) () no-error.
            
            if entityName2 > "" then
                dynClass2 = dynamic-new string("entities.joined." + entityName + entityName2) ().                
            
            if dynClass = ? or ( entityName2 > "" and dynClass2 = ?) then 
            do:
                lOk = false.
                response:StatusCode = 422.
                joError = new JsonObject().
                joError:Add("Error", "Following entities or combination of these entities do not exist for this api").
                joError:Add("Entity", right-trim(left-trim(entityName + "," + entityName2, ","), ",")).
                body = joError:GetJsonText().
            end.
            else if filter:where > "" then
            do:
                if dynClass2 <> ? then 
                do:
                    dynClass2:CheckFieldList(filter:FieldList, output oFieldList, output lOk).
                    if not lOk then 
                    do:
                        response:StatusCode = 422.
                        joError = new JsonObject().
                        joError:Add("Error", "Following field(s) in query do not exist for this entity").
                        joError:Add("Fields", oFieldList).
                        body = joError:GetJsonText().
                    end.
                end.
                else 
                do:
                    dynClass:CheckFieldList(filter:FieldList, output oFieldList, output lOk).
                    
                    if not lOk then
                    do:
                        response:StatusCode = 422.
                        joError = new JsonObject().
                        joError:Add("Error", "Following field(s) in query do not exist for this entity").
                        joError:Add("Fields", oFieldList).
                        body = joError:GetJsonText().
                    end.
                    dynClass:CheckValueList(input table-handle hQueryParams, output oValueList, output lOk) no-error. 
                    if not lOk then
                    do:
                        
                        
                        response:StatusCode = 422.
                        if num-entries(oValueList, ",") > 1 then do:
                            jaError = new JsonArray().
                        end.
                        do iii = 1 to num-entries(right-trim(oValueList, ","), "," ):
                            listItem = entry(iii, oValueList, ",").
                            joError = new JsonObject().
                            joError:Add("Error", "Following field in query has an incorrect value according to the datatype for field").
                            joError:Add("Field", entry(1, listItem, "/")).
                            joError:Add("Value", entry(2, listItem, "/")).
                            joError:Add("Expected Datatype", entry(3, listItem, "/") ).
                            jaError:Add(-1 + iii, joError).
                            
                        end.
                        body = body + jaError:GetJsonText().
                    end.
                end.
            end.
            
            if lOk and dynClass2 <> ? then
            do:
                response:StatusCode = 200.
                
                dynClass2:Read(filter, output dataset-handle hDataSet).
               
                hTempTable = hDataSet:get-buffer-handle(1):table-handle.
                joResult = new JsonObject().
                joResult:Read(hTempTable).
                
                do ii=2 to hDataSet:num-buffers:
                    hTempTable = hDataSet:get-buffer-handle(ii):table-handle.
                    jaResult = new JsonArray().
                    jaResult:read(hTempTable).
                    joResult:add(entityName2, jaResult ).
                                           
                end.
                body = joResult:GetJsonText(). 
            end.
            else if lOk then
            do:
                response:StatusCode = 200.
                dynClass:Read(filter, output dataset-handle hDataSet).
                hTempTable = hDataSet:get-buffer-handle(1):table-handle.
                joResult = new JsonObject().
                joResult:read(hTempTable).
                body = joResult:GetJsonText().
            end.
        end.
        else if apiType = "meta" then
        do:
            dynClass = dynamic-new string("entities." + entityName) () no-error.
            if dynClass = ? then
            do:
                response:StatusCode = 422.
                joError = new JsonObject().
                joError:Add("error", "Entity does not exist").
                joError:Add("entity", entityName).
                body = joError:GetJsonText().
            end.
            else do:
                dynClass:CreateEntityModel(output lcModel) no-error.
                if ERROR-STATUS:ERROR then
                do:
                    response:StatusCode = 500.
                    joError = new JsonObject().
                    joError:Add("error", "Error retrieving entity metadata").
                    joError:Add("entity", entityName).
                    joError:Add("details", ERROR-STATUS:GET-MESSAGE(1)).
                    body = joError:GetJsonText().
                end.
                else do:
                    response:StatusCode = 200.
                    body = lcModel.
                end.
            end.
        end.
                
        /* Set response */
        response:ContentType = "application/json".
        writer:write(body).
        writer:flush().
        writer:close().
        return response:StatusCode.
        
        
        finally:
            delete object joResult      no-error.
            delete object jaResult      no-error.
            delete object joError       no-error.
            delete object jaError       no-error.
            delete object dynClass      no-error.
            delete object dynClass2     no-error.
            delete object hDataSet      no-error.
            delete object hTempTable    no-error.
            delete object filter        no-error.
            delete object response      no-error.
            delete object writer        no-error.
            delete object hQueryParams  no-error.
        end.
        
        
        
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handles HTTP POST requests for entity operations
     Parameters:
       input poRequest as OpenEdge.Web.IWebRequest - The incoming web request
     Returns: integer - HTTP status code
     Notes:
       - Validates entity existence and request data
       - Performs create/update operations based on request
       - Returns appropriate status codes and error messages
    ------------------------------------------------------------------------------*/
    method override protected integer HandlePost(input poRequest as OpenEdge.Web.IWebRequest):
        /* Request parameters */
        var character entityName = poRequest:GetPathParameter("entityname").
        var character id = poRequest:GetPathParameter("id").
        var character apiType = poRequest:GetPathParameter("apitype").
        var character queryString = poRequest:GetContextValue("QUERY_STRING").
        var character cFieldList.
        var JsonObject requestBody = cast(poRequest:Entity, JsonObject).
        
        /* Response objects */
        var WebResponse response = new WebResponse().
        var WebResponseWriter writer = new WebResponseWriter(response).
        var JsonObject joError, joResult.
        
        /* Business objects */
        var interfaces.CRUD dynClass.
        var handle hDataSet, hQueryParams.
        var logical lOk.
        var character oFieldList.
        var integer ii=0.
        var char[] aFieldList.
        var generics.FilterParams filter = new generics.FilterParams(entityName, ?, ?, id, ?, output table-handle hQueryParams).
        
        /* Initialize response */
        response:ContentType = "application/json".
        
        /* Validate request body */
        if not valid-object(requestBody) then
        do:
            response:StatusCode = 400.
            joError = new JsonObject().
            joError:Add("error", "Missing request body").
            joError:Add("entity", entityName).
            writer:write(joError:GetJsonText()).
            return response:StatusCode.
        end.
        
        /* Initialize entity class */
        dynClass = dynamic-new string("entities." + entityName) () no-error.
        
        if dynClass = ? then
        do:
            response:StatusCode = 422.
            joError = new JsonObject().
            joError:Add("error", "Entity does not exist").
            joError:Add("entity", entityName).
            writer:write(joError:GetJsonText()).
            return response:StatusCode.
        end.
        aFieldList = requestBody:GetNames().
        
        /* Validate fields */
        do ii = 1 to EXTENT(aFieldList):
            cFieldList = cFieldList + aFieldList[ii] + ','.
        end.

        dynClass:CheckFieldList(cFieldList, output oFieldList, output lOk) no-error.
        if not lOk then
        do:
            response:StatusCode = 422.
            joError = new JsonObject().
            joError:Add("error", "Invalid fields in request").
            joError:Add("entity", entityName).
            joError:Add("invalid_fields", oFieldList).
            writer:write(joError:GetJsonText()).
            return response:StatusCode.
        end.
        
        /* Process create/update request */
        if id > "" then
        do:
            /* Update existing entity */
            dynClass:Update(filter, requestBody, output dataset-handle hDataSet) no-error.
            if ERROR-STATUS:ERROR then
            do:
                response:StatusCode = 500.
                joError = new JsonObject().
                joError:Add("error", "Error updating entity").
                joError:Add("entity", entityName).
                joError:Add("id", id).
                joError:Add("details", ERROR-STATUS:GET-MESSAGE(1)).
                writer:write(joError:GetJsonText()).
            end.
            else do:
                response:StatusCode = 200.
                joResult = new JsonObject().
                joResult:Add("message", "Entity updated successfully").
                joResult:Add("entity", entityName).
                joResult:Add("id", id).
                writer:write(joResult:GetJsonText()).
            end.
        end.
        else do:
            /* Create new entity */
            dynClass:Create(requestBody, output dataset-handle hDataSet) no-error.
            if ERROR-STATUS:ERROR then
            do:
                response:StatusCode = 500.
                joError = new JsonObject().
                joError:Add("error", "Error creating entity").
                joError:Add("entity", entityName).
                joError:Add("details", ERROR-STATUS:GET-MESSAGE(1)).
                writer:write(joError:GetJsonText()).
            end.
            else do:
                response:StatusCode = 201.
                joResult = new JsonObject().
                joResult:Add("message", "Entity created successfully").
                joResult:Add("entity", entityName).
                writer:write(joResult:GetJsonText()).
            end.
        end.
        
        writer:flush().
        writer:close().
        
        finally:
            delete object response no-error.
            delete object writer no-error.
            delete object joError no-error.
            delete object joResult no-error.
            delete object dynClass no-error.
            delete object hDataSet no-error.
        end.
        
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
    
    /*------------------------------------------------------------------------------
     Purpose: Handles HTTP PUT requests for entity updates
     Parameters:
       input poRequest as OpenEdge.Web.IWebRequest - The incoming web request
     Returns: integer - HTTP status code
     Notes:
       - Validates entity existence and request data
       - Updates existing entity
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
        var JsonObject joError, joResult.
        
        /* Business objects */
        var interfaces.CRUD dynClass.
        var handle hDataSet, hQueryParams.
        var logical lOk.
        var integer ii = 0.
        var character cFieldList, oFieldList.
        var char[] aFieldList.
        var generics.FilterParams filter = new generics.FilterParams(entityName, ?, ?, id, ?, output table-handle hQueryParams).
        
        /* Initialize response */
        response:ContentType = "application/json".
        
        /* Validate request */
        if not valid-object(requestBody) then
        do:
            response:StatusCode = 400.
            joError = CreateErrorResponse(400, "Missing request body", entityName, "", "").
            writer:write(joError:GetJsonText()).
            return response:StatusCode.
        end.
        
        if id = "" then
        do:
            response:StatusCode = 400.
            joError = CreateErrorResponse(400, "Missing entity ID", entityName, "", "").
            writer:write(joError:GetJsonText()).
            return response:StatusCode.
        end.
        
        /* Initialize entity class */
        dynClass = dynamic-new string("entities." + entityName) () no-error.
        
        if dynClass = ? then
        do:
            response:StatusCode = 422.
            joError = CreateErrorResponse(422, "Entity does not exist", entityName, "", id).
            writer:write(joError:GetJsonText()).
            return response:StatusCode.
        end.
        
        aFieldList = requestBody:GetNames().
        
        /* Validate fields */
        do ii = 1 to EXTENT(aFieldList):
            cFieldList = cFieldList + aFieldList[ii] + ','.
        end.
        
        /* Validate fields */
        dynClass:CheckFieldList(cFieldList, output oFieldList, output lOk) no-error.
        if not lOk then
        do:
            response:StatusCode = 422.
            joError = CreateErrorResponse(422, "Invalid fields in request", entityName, oFieldList, id).
            writer:write(joError:GetJsonText()).
            return response:StatusCode.
        end.
        
        /* Update entity */
        dynClass:Update(filter, requestBody, output dataset-handle hDataSet) no-error.
        if ERROR-STATUS:ERROR then
        do:
            response:StatusCode = 500.
            joError = CreateErrorResponse(500, "Error updating entity", entityName, ERROR-STATUS:GET-MESSAGE(1), id).
            writer:write(joError:GetJsonText()).
        end.
        else do:
            response:StatusCode = 200.
            joResult = new JsonObject().
            joResult:Add("message", "Entity updated successfully").
            joResult:Add("entity", entityName).
            joResult:Add("id", id).
            writer:write(joResult:GetJsonText()).
        end.
        
        writer:flush().
        writer:close().
        
        
        finally:
            delete object response no-error.
            delete object writer no-error.
            delete object joError no-error.
            delete object joResult no-error.
            delete object dynClass no-error.
            delete object hDataSet no-error.
        end.
        
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Handles HTTP DELETE requests for entity deletion
     Parameters:
       input poRequest as OpenEdge.Web.IWebRequest - The incoming web request
     Returns: integer - HTTP status code
     Notes:
       - Validates entity existence
       - Deletes specified entity
       - Returns appropriate status codes and error messages
    ------------------------------------------------------------------------------*/
    method override protected integer HandleDelete(input poRequest as OpenEdge.Web.IWebRequest):
        /* Request parameters */
        var character entityName = poRequest:GetPathParameter("entityname").
        var character id = poRequest:GetPathParameter("id").
        
        
        /* Response objects */
        var WebResponse response = new WebResponse().
        var WebResponseWriter writer = new WebResponseWriter(response).
        var JsonObject joError.
        var JsonObject joResult.
        var handle hDataSet, hQueryParams.
        var generics.FilterParams filter = new generics.FilterParams(entityName, ?, ?, id, ?, output table-handle hQueryParams).
        
        /* Business objects */
        var interfaces.CRUD dynClass.
        
        /* Initialize response */
        response:ContentType = "application/json".
        
        /* Validate request */
        if id = "" then
        do:
            response:StatusCode = 400.
            joError = CreateErrorResponse(400, "Missing entity ID", entityName, "", "").
            writer:write(joError:GetJsonText()).
            return response:StatusCode.
        end.
        
        /* Initialize entity class */
        dynClass = dynamic-new string("entities." + entityName) () no-error.
        
        if dynClass = ? then
        do:
            response:StatusCode = 422.
            joError = CreateErrorResponse(422, "Entity does not exist", entityName, "", id).
            writer:write(joError:GetJsonText()).
            return response:StatusCode.
        end.
        
        /* Delete entity */
        dynClass:Delete(filter, output dataset-handle hDataSet) no-error.
        if ERROR-STATUS:ERROR then
        do:
            response:StatusCode = 500.
            joError = CreateErrorResponse(500, "Error deleting entity", entityName, ERROR-STATUS:GET-MESSAGE(1), id).
            writer:write(joError:GetJsonText()).
        end.
        else do:
            response:StatusCode = 204.
            joResult = new JsonObject().
            joResult:Add("message", "Entity deleted successfully").
            joResult:Add("entity", entityName).
            joResult:Add("id", id).
            writer:write(joResult:GetJsonText()).
        end.
        
        writer:flush().
        writer:close().
        
        finally:
            delete object response no-error.
            delete object writer no-error.
            delete object joError no-error.
            delete object joResult no-error.
            delete object dynClass no-error.
        end.
        
    end method.

    method override protected integer HandleNotAllowedMethod( input poRequest as OpenEdge.Web.IWebRequest ):
        var WebResponse response = new WebResponse().
        var WebResponseWriter writer = new WebResponseWriter(response).
        var JsonObject joError. 
        
        response:StatusCode = 405. /* Method Not Allowed */
        response:ContentType = 'application/json'.
        
        joError = new JsonObject().
        joError:Add('error', 'Method not allowed').
        joError:Add('status', response:StatusCode).
        writer:write(joError:GetJsonText()).
        
        writer:flush().
        writer:close().
        
        finally:
            delete object response no-error.
            delete object writer no-error.
            delete object joError no-error.
        end.
        
    end method.

    /*------------------------------------------------------------------------------
     Purpose: Handles requests for HTTP methods that are not implemented
     Parameters:
       input poRequest as OpenEdge.Web.IWebRequest - The incoming web request
     Returns: integer - HTTP status code 501 (Not Implemented)
     Notes:
       - Called when a request is made with an unsupported HTTP method
       - Returns 501 Not Implemented status code
    ------------------------------------------------------------------------------*/
    method override protected integer HandleNotImplemented( input poRequest as OpenEdge.Web.IWebRequest ):
        var WebResponse response = new WebResponse().
        var WebResponseWriter writer = new WebResponseWriter(response).
        var JsonObject joError. 
        
        response:StatusCode = 501. /* Method Not Allowed */
        response:ContentType = 'application/json'.
        
        joError = new JsonObject().
        joError:Add('error', 'The requested method is not implemented').
        joError:Add('status', response:StatusCode).
        writer:write(joError:GetJsonText()).
        
        writer:flush().
        writer:close().
        
        finally:
            delete object response no-error.
            delete object writer no-error.
            delete object joError no-error.
        end.
    end method.

end class.