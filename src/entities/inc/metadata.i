 
 /*------------------------------------------------------------------------
    File        : CheckMetaData
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : rdroge
    Created     : Fri Jan 04 15:55:52 CET 2019
    Notes       : 
  ----------------------------------------------------------------------*/

 method public void CheckFieldList (input fieldlist as character, output oFieldList as character, output lOk as logical):
        define variable cFieldList  as character no-undo.
        define variable ii          as integer no-undo.
        define variable cNotListed  as character no-undo.
        
        lOk = true.
        
        create tt{&entity}.
        
        do ii = 1 to buffer tt{&entity}:num-fields:
            cFieldList = right-trim(buffer tt{&entity}:buffer-field(ii):name + "," + cFieldList, ",").
        end.
        
        
        ii = 0.
        
        do ii = 1 to num-entries(fieldlist, ","):
            if lookup(entry(ii,fieldlist),cFieldList) = 0 then do:
                cNotListed = left-trim(cNotListed + "," + entry(ii, fieldlist), ",").
                
            end.
            if cNotListed > "" then
            lOk = false.
        end.
        
        oFieldList = cNotListed.
        delete tt{&entity}.
        
    end method.

    method public void CheckValueList (input table-handle QueryParams, output oKeyValuePair as character, output lOk as logical):
        define variable cdataType       as character no-undo.
        define variable cFieldName      as character no-undo.
        define variable cValue          as character no-undo.
        define variable hQuery          as handle no-undo.
        define variable bQueryParams    as handle no-undo.

        lOk = true.
        //Create an empty temp-table of the requested entity to be able to validate fields and values in querystring
        create tt{&entity}.

        bQueryParams = QueryParams:default-buffer-handle.
        
        create query hQuery.
        hQuery:set-buffers(bQueryParams).
        hQuery:query-prepare("for each ttQueryParams").
        hQuery:query-open.
        
        // Go through all query string parameters and check their values for incorrect datatypes
        repeat:
            hQuery:get-next().
            if hQuery:query-off-end then leave.
            if bQueryParams:available then do:
                cFieldName   = bQueryParams:buffer-field("fieldname"):buffer-value().
                cValue       = bQueryParams:buffer-field("fieldvalue"):buffer-value().
                cdataType = buffer tt{&entity}:buffer-field(cFieldName):data-type.
                case cdataType:
                   when "integer" then integer(cValue) no-error.
                   when "decimal" then decimal(cValue) no-error.    
                   when "logical" then logical(cValue) no-error.
                   when "date"    then date(cValue) no-error.
                end.
                if error-status:error then do:
                    oKeyValuePair = oKeyValuePair + cFieldName + "/" + cValue + "/" + cdataType + "/" + ",".
                        lOk = false.
                end.
            end.
        end.
        
        //delete object hQuery.
        //delete object bQueryParams.
    end method.    
    
    method public void CreateEntityModel (output lcModel as longchar ):
        define variable ii as integer no-undo.
        define variable joModel as JsonObject no-undo.
        
        joModel = new JsonObject().
        create tt{&entity}.       
    
        do ii = 1 to buffer tt{&entity}:num-fields:
            define variable cdataType as character no-undo.
            
            case  buffer tt{&entity}:buffer-field(ii):data-type:
                when "character"    then cdataType = "string".
                when "decimal"      then cdataType = "number".
                when "logical"      then cdataType = "boolean".
                otherwise
                    cdataType = buffer tt{&entity}:buffer-field(ii):data-type.
            end case.
                     
            if (buffer tt{&entity}:buffer-field(ii):name <> "seq" and buffer tt{&entity}:buffer-field(ii):name <> "id") then
            joModel:add(buffer tt{&entity}:buffer-field(ii):name, cdataType).
        end.
        
        lcModel = joModel:GetJsonText().
        delete tt{&entity}.
        delete object joModel.
        
    end method.   
