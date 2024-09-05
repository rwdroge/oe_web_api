/*------------------------------------------------------------------------
   File        : GenericService
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : rdroge
   Created     : Jan 10, 2019 8:45:21 AM 2019
   Notes       : 
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


    method override protected integer HandleGet(input poRequest as OpenEdge.Web.IWebRequest):
        var logical 
            lOk = true.
        var longchar 
            body,
            lcModel.
        var char 
            entityName  = poRequest:GetPathParameter("entityname"),
            entityName2 = poRequest:GetPathParameter("entityname2"),
            id1         = poRequest:GetPathParameter("id1"),
            id2         = poRequest:GetPathParameter("id2"),
            apiType     = poRequest:GetPathParameter("apitype"),
            queryString = poRequest:GetContextValue("QUERY_STRING"),
            oFieldlist, 
            oValuelist.
        
        var handle hDataSet, hTempTable, hQueryParams, hQuery.  
        var WebResponse response = new WebResponse(). 
        var WebResponseWriter writer = new WebResponseWriter(response).
        var generics.FilterParams filter.
        
        var interfaces.CRUD dynClass.
        var interfaces.RO dynClass2.
        var JsonObject joError, joResult.
        var JsonArray jaError, jaResult.
        
        if apiType = "data" then
        do:
            filter = new generics.FilterParams(entityName, entityName2, querystring, id1, id2, output table-handle hQueryParams).
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
                        def var iii as integer no-undo.
                        def var listItem as character no-undo.
                        
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
                define variable ii as integer no-undo.
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
            dynClass:CreateEntityModel(output lcModel).
            body = lcModel.
        end.    
                
        response:ContentType = "application/json".
        writer:write(body).
        writer:flush().
        writer:close().        
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
    
    method override protected integer HandlePost(input poRequest as OpenEdge.Web.IWebRequest):
    
        define variable response    as WebResponse       no-undo.
        define variable writer      as WebResponseWriter no-undo.
        define variable body        as jsonObject        no-undo.
        
        define variable entityName  as character         no-undo.
        define variable id1         as character         no-undo.
        define variable queryString as character         no-undo.        
        define variable oFieldlist  as character         no-undo.
        define variable lcModel     as longchar          no-undo.   
        define variable apiType     as character         no-undo.   
        define variable responseBody as longchar         no-undo.
        
        define variable filter      as generics.FilterParams      no-undo.
        define variable lOk         as logical           no-undo initial true.   
        
        define variable dynClass    as interfaces.CRUD   no-undo.
        define variable dynClass2   as interfaces.CRUD   no-undo.
        
        define variable hDataSet    as handle            no-undo.
        
        define variable jsonObject  as JsonObject        no-undo.       
        define variable jsonArray   as JsonArray         no-undo.
        
        response    = new WebResponse().        
        writer      = new WebResponseWriter(response).
        entityName  = poRequest:GetPathParameter("entityname").
        apiType     = poRequest:GetPathParameter("apitype").
        
        body        = cast(poRequest:Entity, JsonObject).
        
        dynClass = dynamic-new string("entities." + entityName) () no-error.
        
        if dynClass = ? then
        do:
                response:StatusCode = 400.
                jsonObject = new JsonObject().
                jsonObject:Add("Error", "Following entities or combination of these entities do not exist for this api").
                jsonObject:Add("Entity", right-trim(left-trim(entityName + ","))).
                
                responseBody = jsonObject:GetJsonText().
        end.
        else do:
            dynClass:Create(body, output dataset-handle hDataSet).
            hDataSet:write-json('longchar', responseBody, true, ?, true, true ).
        end.
        
        response:ContentType = "application/json".
        writer:write(responseBody).
        writer:flush().
        writer:close().
        
    end method.
    
    method override protected integer HandlePut(input poRequest as OpenEdge.Web.IWebRequest):
    
        define variable response    as WebResponse       no-undo.
        define variable writer      as WebResponseWriter no-undo.
        define variable body        as jsonObject        no-undo.
        
        define variable entityName as character no-undo.
        define variable entityName2 as character         no-undo.
        define variable id1         as character         no-undo.
        define variable queryString as character         no-undo.        
        define variable oFieldlist  as character         no-undo.
        define variable apiType     as character         no-undo.   
        define variable responseBody as longchar         no-undo.
        
        define variable filter      as generics.FilterParams      no-undo.
        define variable lOk         as logical           no-undo initial true.   
        
        define variable dynClass    as interfaces.CRUD   no-undo.
        
        define variable hDataSet    as handle            no-undo.
        define variable hQueryParams as handle no-undo.
        
        define variable jsonObject  as JsonObject        no-undo.       
        define variable jsonArray   as JsonArray         no-undo.
        
        response    = new WebResponse().        
        writer      = new WebResponseWriter(response).
        entityName  = poRequest:GetPathParameter("entityname").
        apiType     = poRequest:GetPathParameter("apitype").
        id1         = poRequest:GetPathParameter("id1").
        
        body        = cast(poRequest:Entity, JsonObject).
        
        filter = new generics.FilterParams(entityName, "", "", id1, "", table-handle hQueryParams).
        
        dynClass = dynamic-new string("entities." + entityName) () no-error.
        
        if dynClass = ? then
        do:
                response:StatusCode = 400.
                jsonObject = new JsonObject().
                jsonObject:Add("Error", "Following entities or combination of these entities do not exist for this api").
                jsonObject:Add("Entity", right-trim(left-trim(entityName + "," + entityName2, ","), ",")).
                
                responseBody = jsonObject:GetJsonText().
        end.
        else do:
            dynClass:Update(filter, body, output dataset-handle hDataSet).
            hDataSet:write-json('longchar', responseBody ).
        end.
        
        response:ContentType = "application/json".
        writer:write(responseBody).
        writer:flush().
        writer:close().
        
    end method.
    
    method override protected integer HandleDelete(input poRequest as OpenEdge.Web.IWebRequest):
    
        define variable response    as WebResponse       no-undo.
        define variable writer      as WebResponseWriter no-undo.
        define variable body        as jsonObject        no-undo.
        
        define variable entityName  as character         no-undo.
        define variable id1         as character         no-undo.
        define variable queryString as character         no-undo.        
        define variable oFieldlist  as character         no-undo.
        define variable apiType     as character         no-undo.   
        define variable responseBody as longchar         no-undo.
        
        define variable filter      as generics.FilterParams      no-undo.
        define variable lOk         as logical           no-undo initial true.   
        
        define variable dynClass    as interfaces.CRUD   no-undo.
        
        define variable hDataSet    as handle            no-undo.
        define variable hQueryParams as handle           no-undo. 
        
        define variable jsonObject  as JsonObject        no-undo.       
        define variable jsonArray   as JsonArray         no-undo.
        
        response    = new WebResponse().        
        writer      = new WebResponseWriter(response).
        entityName  = poRequest:GetPathParameter("entityname").
        apiType     = poRequest:GetPathParameter("apitype").
        id1         = poRequest:GetPathParameter("id1").
        
        body        = cast(poRequest:Entity, JsonObject).
        
        filter = new generics.FilterParams(entityName, "", "", id1, "", table-handle hQueryParams).
        
        dynClass = dynamic-new string("entities." + entityName) () no-error.
        
        if dynClass = ? then
        do:
                response:StatusCode = 400.
                jsonObject = new JsonObject().
                jsonObject:Add("Error", "Following entity does not exist for this api").
                jsonObject:Add("Entity", right-trim(left-trim(entityName + ","), ",")).
                
                responseBody = jsonObject:GetJsonText().
        end.
        else do:
            dynClass:Delete(filter, output dataset-handle hDataSet).
            hDataSet:write-json('longchar', responseBody ).
        end.
        
        response:ContentType = "application/json".
        writer:write(responseBody).
        writer:flush().
        writer:close().
        
    end method.
    
    method override protected integer HandleNotAllowedMethod( input poRequest as OpenEdge.Web.IWebRequest ):
        
        undo, throw new Progress.Lang.AppError("This method is not allowed").
    end method.

    method override protected integer HandleNotImplemented( input poRequest as OpenEdge.Web.IWebRequest ):
        
        undo, throw new Progress.Lang.AppError("This method is not implemented").
    end method.
    
end class.