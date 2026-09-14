/*------------------------------------------------------------------------
    File        : FilterConstructorParams
    Purpose     : Parameter object for FilterParams constructor
    Syntax      : 
    Description : Encapsulates parameters for FilterParams constructor to reduce parameter count
    Author(s)   : 
    Created     : Wed Aug 28 07:18:00 UTC 2025
    Notes       : Part of parameter object refactoring to reduce method complexity
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS generics.FilterConstructorParams:
    
    /* Entity name for the filter */
    DEFINE PUBLIC PROPERTY Entity AS CHARACTER NO-UNDO
        GET.
        SET.
    
    /* Secondary entity name */
    DEFINE PUBLIC PROPERTY Entity2 AS CHARACTER NO-UNDO
        GET.
        SET.
    
    /* Query string for filtering */
    DEFINE PUBLIC PROPERTY QueryString AS CHARACTER NO-UNDO
        GET.
        SET.
    
    /* Primary ID value */
    DEFINE PUBLIC PROPERTY Id1 AS CHARACTER NO-UNDO
        GET.
        SET.
    
    /* Secondary ID value */
    DEFINE PUBLIC PROPERTY Id2 AS CHARACTER NO-UNDO
        GET.
        SET.
    
    /* Handle to query parameters temp-table */
    DEFINE PUBLIC PROPERTY QueryParamsHandle AS HANDLE NO-UNDO
        GET.
        SET.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a new instance with default values
     Notes: All properties are initialized to appropriate defaults
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC FilterConstructorParams():
        SUPER().
        
        /* Initialize with safe defaults */
        Entity = "".
        Entity2 = "".
        QueryString = "".
        Id1 = "".
        Id2 = "".
        QueryParamsHandle = ?.
    END CONSTRUCTOR.
    
    
    /*------------------------------------------------------------------------------
     Purpose: Validates that all required parameters are set
     Returns: TRUE if all required parameters are valid, FALSE otherwise
     Notes: Checks for non-empty entity name as minimum requirement
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL IsValid():
        RETURN (Entity > "").
    END METHOD.
    
END CLASS.
