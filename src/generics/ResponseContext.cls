/*------------------------------------------------------------------------
    File        : ResponseContext
    Purpose     : Encapsulates response-related objects for HTTP handlers
    Syntax      : 
    Description : Container for WebResponse, WebResponseWriter, and JsonObject
    Author(s)   : Cascade AI
    Created     : Wed Nov 27 09:47:00 UTC 2025
    Notes       : Reduces duplication in HTTP handler methods
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Net.HTTP.*.
using OpenEdge.Web.*.
using Progress.Json.ObjectModel.*.

block-level on error undo, throw.

class generics.ResponseContext:
    
    /* HTTP response object */
    define public property Response as WebResponse no-undo get. set.
    
    /* Response writer */
    define public property Writer as WebResponseWriter no-undo get. set.
    
    /* JSON response object */
    define public property JsonResponse as JsonObject no-undo get. set.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a new response context with initialized objects
     Notes: Sets ContentType to application/json by default
    ------------------------------------------------------------------------------*/
    constructor public ResponseContext():
        super().
        
        /* Initialize response objects */
        Response = new WebResponse().
        Writer = new WebResponseWriter(Response).
        JsonResponse = ?.
        
        /* Set default content type */
        Response:ContentType = "application/json".
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Cleans up all response objects
     Notes: Safe to call multiple times
    ------------------------------------------------------------------------------*/
    method public void Cleanup():
        delete object JsonResponse no-error.
        delete object Response no-error.
        delete object Writer no-error.
    end method.
    
end class.
