/*------------------------------------------------------------------------
    File        : MockRequest
    Purpose     : Mock request implementation for testing
    Syntax      : 
    Description : Simulates HTTP request for unit tests
    Author(s)   : 
    Created     : Tue Jul 08 11:01:23 UTC 2025
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Core.Collections.StringStringMap.
USING OpenEdge.Web.IWebRequest.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.ObjectModelParser.
USING OpenEdge.Net.HTTP.Cookie.
USING OpenEdge.Core.Memptr.
USING OpenEdge.Net.URI.
USING OpenEdge.Net.HTTP.HttpHeader.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS tests.mocks.MockRequest IMPLEMENTS IWebRequest:
    
    var CHARACTER[] pathSegments.
    var StringStringMap queryParams.
    var CHARACTER requestBody.
    var StringStringMap pathParameters.
    var StringStringMap contextValues.
    var Progress.Lang.Object entityObject.
    VAR INTEGER count = 0.
    VAR JsonObject jsonObj.
    VAR ObjectModelParser jsonParser.
    VAR CHARACTER httpMethod = "GET".
    VAR OpenEdge.Net.URI requestUri.
    
    
    CONSTRUCTOR PUBLIC MockRequest(INPUT path AS CHARACTER):
        VAR INTEGER i.
        VAR INTEGER numEntries = NUM-ENTRIES(path, "/").
        VAR INTEGER segmentIndex = 0.
        var character segment.
        
        queryParams = NEW StringStringMap().
        pathParameters = NEW StringStringMap().
        contextValues = NEW StringStringMap().
        jsonParser = NEW ObjectModelParser().
        
        /* Initialize URI with the provided path */
        requestUri = NEW OpenEdge.Net.URI("http://localhost" + path).
        
        /* Split path into segments using ENTRY and NUM-ENTRIES */
        
        
        
        /* Count non-empty segments */
        DO i = 1 TO numEntries:
            IF ENTRY(i, path, "/") NE "" THEN count = count + 1.
        END.
        
        /* Set extent and populate pathSegments array */
        EXTENT(pathSegments) = count.
        count = 0.
        
        DO i = 1 TO numEntries:
            segment = ENTRY(i, path, "/").
            IF segment NE "" THEN DO:
                count = count + 1.
                pathSegments[count] = segment.
            END.
        END.
    END CONSTRUCTOR.
    
    method public character GetPathSegment(INPUT segmentIndex AS INTEGER):
        IF segmentIndex > 0 AND segmentIndex <= EXTENT(pathSegments) THEN
            RETURN pathSegments[segmentIndex].
        ELSE
            RETURN "".
    end method.
    
    method public void AddQueryParameter(INPUT paramName AS CHARACTER, INPUT paramValue AS CHARACTER):
        queryParams:Put(paramName, paramValue).
    end method.
    
    method public longchar GetQueryParameter(INPUT paramName AS CHARACTER):
        return queryParams:Get(paramName).
    end method.
    
    method public void SetRequestBody(INPUT body AS CHARACTER):
        requestBody = body.
    end method.
    
    method public void SetHttpMethod(INPUT method AS CHARACTER):
        httpMethod = method.
    end method.
    
    method public character GetRequestBody():
        RETURN requestBody.
    END METHOD.
    
    /* IWebRequest interface methods */
    method public character GetPathParameter(INPUT paramName AS CHARACTER):
        VAR LONGCHAR longValue = pathParameters:Get(paramName).
        IF longValue = ? THEN
            RETURN ?.
        ELSE
            RETURN STRING(longValue).
    end method.
    
    method public void SetPathParameter(INPUT paramName AS CHARACTER, INPUT paramValue AS CHARACTER):
        pathParameters:Put(paramName, paramValue).
    end method.
    
    method public longchar GetContextValue(INPUT contextName AS CHARACTER):
        RETURN contextValues:Get(contextName).
    end method.
    
    METHOD PUBLIC VOID SetContextValue(INPUT contextName AS CHARACTER, INPUT contextValue AS CHARACTER):
        contextValues:Put(contextName, contextValue).
    END METHOD.
    
    /* Entity property for JSON request body */
    DEFINE PUBLIC PROPERTY Entity AS Progress.Lang.Object NO-UNDO
        GET:
            IF requestBody > "" THEN DO:
                jsonObj = CAST(jsonParser:Parse(requestBody), JsonObject).
                RETURN jsonObj.
            END.
            RETURN entityObject.
        END GET.
        SET(INPUT paramValue AS Progress.Lang.Object):
            entityObject = paramValue.
        END SET.
    
    /* Required IWebRequest properties - minimal implementation */
    DEFINE PUBLIC PROPERTY PathInfo AS CHARACTER NO-UNDO 
        GET:
            RETURN "".
        END GET.
    
    DEFINE PUBLIC PROPERTY PathParameterNames AS CHARACTER NO-UNDO 
        GET:
            RETURN "".
        END GET.
    
    DEFINE PUBLIC PROPERTY ContextNames AS CHARACTER NO-UNDO 
        GET:
            RETURN "".
        END GET.
    
    DEFINE PUBLIC PROPERTY LocalAddress AS CHARACTER NO-UNDO 
        GET:
            RETURN "127.0.0.1".
        END GET.
    
    DEFINE PUBLIC PROPERTY LocalHost AS CHARACTER NO-UNDO 
        GET:
            RETURN "localhost".
        END GET.
    
    DEFINE PUBLIC PROPERTY LocalPort AS INTEGER NO-UNDO 
        GET:
            RETURN 8080.
        END GET.
    
    DEFINE PUBLIC PROPERTY RemoteAddress AS CHARACTER NO-UNDO 
        GET:
            RETURN "127.0.0.1".
        END GET.
    
    DEFINE PUBLIC PROPERTY RemoteHost AS CHARACTER NO-UNDO 
        GET:
            RETURN "localhost".
        END GET.
    
    DEFINE PUBLIC PROPERTY RemotePort AS INTEGER NO-UNDO 
        GET:
            RETURN 0.
        END GET.
    
    DEFINE PUBLIC PROPERTY RemoteUser AS CHARACTER NO-UNDO 
        GET:
            RETURN "".
        END GET.
    
    DEFINE PUBLIC PROPERTY ResolvedTransportPath AS CHARACTER NO-UNDO 
        GET:
            RETURN "".
        END GET.
    
    DEFINE PUBLIC PROPERTY ResolvedWebAppPath AS CHARACTER NO-UNDO 
        GET:
            RETURN "".
        END GET.
    
    DEFINE PUBLIC PROPERTY ServerSoftware AS CHARACTER NO-UNDO 
        GET:
            RETURN "".
        END GET.
    
    DEFINE PUBLIC PROPERTY TransportPath AS CHARACTER NO-UNDO 
        GET:
            RETURN "".
        END GET.
    
    DEFINE PUBLIC PROPERTY UriTemplate AS CHARACTER NO-UNDO 
        GET:
            RETURN "".
        END GET.
    
    DEFINE PUBLIC PROPERTY WebAppPath AS CHARACTER NO-UNDO 
        GET:
            RETURN "".
        END GET.
    
    DEFINE PUBLIC PROPERTY DefaultCookieDomain AS CHARACTER NO-UNDO 
        GET:
            RETURN "".
        END GET.
    
    DEFINE PUBLIC PROPERTY DefaultCookiePath AS CHARACTER NO-UNDO 
        GET:
            RETURN "".
        END GET.
    
    /* Required IHttpRequest properties */
    DEFINE PUBLIC PROPERTY Method AS CHARACTER NO-UNDO 
        GET:
            RETURN httpMethod.
        END GET.
        SET(INPUT methodValue AS CHARACTER):
            httpMethod = methodValue.
        END SET.
    
    DEFINE PUBLIC PROPERTY URI AS OpenEdge.Net.URI NO-UNDO 
        GET:
            RETURN requestUri.
        END GET.
        SET(INPUT uriValue AS OpenEdge.Net.URI):
            requestUri = uriValue.
        END SET.
    
    /* Required IHttpMessage properties */
    DEFINE PUBLIC PROPERTY Version AS CHARACTER NO-UNDO 
        GET:
            RETURN "HTTP/1.1".
        END GET.
        SET(INPUT versionValue AS CHARACTER):
            /* No-op for mock - could store if needed */
        END SET.
    
    DEFINE PUBLIC PROPERTY CharacterEncoding AS CHARACTER NO-UNDO 
        GET:
            RETURN "UTF-8".
        END GET.
        SET(INPUT encodingValue AS CHARACTER):
            /* No-op for mock - could store if needed */
        END SET.
    
    DEFINE PUBLIC PROPERTY ContentLength AS INT64 NO-UNDO 
        GET:
            IF requestBody > "" THEN
                RETURN LENGTH(requestBody, "RAW").
            ELSE
                RETURN 0.
        END GET.
        SET(INPUT lengthValue AS INT64):
            /* No-op for mock - could store if needed */
        END SET.
    
    DEFINE PUBLIC PROPERTY ContentMD5 AS RAW NO-UNDO 
        GET:
            RETURN ?.
        END GET.
        SET(INPUT md5Value AS RAW):
            /* No-op for mock - could store if needed */
        END SET.
    
    DEFINE PUBLIC PROPERTY ContentType AS CHARACTER NO-UNDO 
        GET:
            RETURN "application/json".
        END GET.
        SET(INPUT typeValue AS CHARACTER):
            /* No-op for mock - could store if needed */
        END SET.
    
    DEFINE PUBLIC PROPERTY TransferEncoding AS CHARACTER NO-UNDO 
        GET:
            RETURN "".
        END GET.
        SET(INPUT encodingValue AS CHARACTER):
            /* No-op for mock - could store if needed */
        END SET.
    
    /* Required IHttpMessage methods for cookie and header handling */
    method public void ClearCookies():
        /* No-op for mock */
    end method.
    
    method public void ClearHeaders():
        /* No-op for mock */
    end method.
    
    method public OpenEdge.Net.HTTP.Cookie GetCookie(INPUT cookieName AS CHARACTER):
        return ?.
    end method.
    
    method public INTEGER GetCookies(output cookies AS OpenEdge.Net.HTTP.Cookie EXTENT):
        RETURN 0.
    end method.
    
    method public OpenEdge.Net.HTTP.HttpHeader GetHeader(INPUT headerName AS CHARACTER):
        RETURN ?.
    end method.
    
    method public INTEGER GetHeaders(output headers AS OpenEdge.Net.HTTP.HttpHeader EXTENT):
        RETURN 0.
    end method.
    
    method public logical HasCookie(INPUT cookieName AS CHARACTER):
        RETURN FALSE.
    end method.
    
    method public logical HasCookie(INPUT cookieObj AS OpenEdge.Net.HTTP.Cookie):
        RETURN FALSE.
    end method.
    
    method public logical HasHeader(INPUT headerName AS CHARACTER):
        RETURN FALSE.
    end method.
    
    method public void RemoveCookie(INPUT cookieName AS CHARACTER):
        /* No-op for mock */
    end method.
    
    method public void RemoveCookie(INPUT cookieObj AS OpenEdge.Net.HTTP.Cookie):
        /* No-op for mock */
    end method.
    
    method public void RemoveHeader(INPUT headerName AS CHARACTER):
        /* No-op for mock */
    end method.
    
    method public void SetCookie(INPUT cookieObj AS OpenEdge.Net.HTTP.Cookie):
        /* No-op for mock */
    end method.
    
    method public void SetCookies(INPUT cookies AS OpenEdge.Net.HTTP.Cookie EXTENT):
        /* No-op for mock */
    end method.
    
    method public void SetHeader(INPUT headerObj AS OpenEdge.Net.HTTP.HttpHeader):
        /* No-op for mock */
    end method.
    
    method public void SetHeaders(INPUT headers AS OpenEdge.Net.HTTP.HttpHeader EXTENT):
        /* No-op for mock */
    end method.
    
    method public OpenEdge.Core.Memptr GetRawEntity():
        VAR OpenEdge.Core.Memptr rawData.
        return rawData.
    end method.
    
    method public progress.lang.object GetTypedEntity():
        RETURN Entity.
    END METHOD.
    
END CLASS.
