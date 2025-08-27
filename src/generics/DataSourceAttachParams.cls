/*------------------------------------------------------------------------
    File        : DataSourceAttachParams
    Purpose     : Parameter object for DataAccess.attachSource method
    Syntax      : 
    Description : Encapsulates parameters for data source attachment operations
    Author(s)   : 
    Created     : Tue Aug 27 11:50:00 UTC 2025
    Notes       : Part of parameter object refactoring to reduce method complexity
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING generics.FilterParams.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS generics.DataSourceAttachParams:
    
    /* Buffer names for the dataset */
    DEFINE PUBLIC PROPERTY Buffers AS CHARACTER NO-UNDO
        GET.
        SET.
    
    /* Fields to include in the query */
    DEFINE PUBLIC PROPERTY dsFields AS CHARACTER NO-UNDO
        GET.
        SET.
    
    /* Data source names */
    DEFINE PUBLIC PROPERTY Sources AS CHARACTER NO-UNDO
        GET.
        SET.
    
    /* Key fields for the data sources */
    DEFINE PUBLIC PROPERTY SourceKeys AS CHARACTER NO-UNDO
        GET.
        SET.
    
    /* Value for key field filtering */
    DEFINE PUBLIC PROPERTY KeyValue AS CHARACTER NO-UNDO
        GET.
        SET.
    
    /* Filter parameters (sorting, paging, where clause) */
    DEFINE PUBLIC PROPERTY Filter AS FilterParams NO-UNDO
        GET.
        SET.
    
    /* Handle to the target dataset */
    DEFINE PUBLIC PROPERTY dsDataSet AS HANDLE NO-UNDO
        GET.
        SET.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a new instance with default values
     Notes: All properties are initialized to appropriate defaults
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC DataSourceAttachParams():
        SUPER().
        
        /* Initialize with safe defaults */
        Buffers = "".
        dsFields = "".
        Sources = "".
        SourceKeys = "".
        KeyValue = "".
        Filter = ?.
        dsDataSet = ?.
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a new instance with all parameters
     Parameters: All the parameters needed for data source attachment
     Notes: Convenience constructor for full initialization
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC DataSourceAttachParams(
        INPUT buffers AS CHARACTER,
        INPUT dsfields AS CHARACTER,
        INPUT sources AS CHARACTER,
        INPUT sourceKeys AS CHARACTER,
        INPUT keyValue AS CHARACTER,
        INPUT filter AS FilterParams,
        INPUT dsDataSet AS HANDLE):
        
        THIS-OBJECT().
        
        ASSIGN
            THIS-OBJECT:Buffers = buffers
            THIS-OBJECT:dsFields = dsfields
            THIS-OBJECT:Sources = sources
            THIS-OBJECT:SourceKeys = sourceKeys
            THIS-OBJECT:KeyValue = keyValue
            THIS-OBJECT:Filter = filter
            THIS-OBJECT:dsDataSet = dsDataSet.
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
     Purpose: Validates that all required parameters are set
     Returns: TRUE if all required parameters are valid, FALSE otherwise
     Notes: Checks for non-empty strings and valid handles where required
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL IsValid():
        RETURN (Buffers > "" AND
                Sources > "" AND
                SourceKeys > "" AND
                VALID-HANDLE(dsDataSet)).
    END METHOD.
    
END CLASS.
