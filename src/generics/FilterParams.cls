
/*------------------------------------------------------------------------
    File        : FilterParams
    Author(s)   : rdroge
    Created     : Jan 10, 2019 8:45:21 AM 2019
    Notes       : Input parameters for filtering 
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

using OpenEdge.Net.URI.*.
using interfaces.RO.*.

class generics.FilterParams:

    define public property entityName   as character    no-undo get. set.
    define public property entityName2  as character    no-undo get. set.
    define public property TopRecs      as integer      initial 0 no-undo get. set.
    define public property SkipRecs     as integer      initial 0 no-undo get. set.
    define public property Where        as character    no-undo get. set.
    define public property SortBy       as character    no-undo get. set.
    define public property FieldList    as character    no-undo get. set.
    define public property ValueList    as character    no-undo get. set.
    define public property id1          as character    no-undo get. set.
    define public property id2          as character    no-undo get. set.
    define public property rowid        as character    no-undo get. set.
    define public property filtered     as logical      initial false no-undo get. set.
        
    define temp-table ttQueryParams
    field fieldname   as character 
    field fieldvalue  as character 
    index fieldname is primary unique fieldname ascending
    .  

    /*------------------------------------------------------------------------------
     Purpose: Constructor with all parameters
     Notes: Initializes filter with entity names, IDs, and query string
    ------------------------------------------------------------------------------*/
    constructor public FilterParams(
        input pcentity as character,
        input pcentity2 as character,
        input pcquerystring as character,
        input pcid1 as character,
        input pcid2 as character,
        output table ttQueryParams):
        
        super().
        
        /* Initialize entity names and IDs */
        this-object:InitializeBasicParams(pcentity, pcentity2, pcid1, pcid2).
        
        /* Build query string if provided */
        if pcqueryString > "" then 
        do:
            this-object:filtered = true.
            this-object:BuildQueryString(pcquerystring, table ttQueryParams).
        end.
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Helper method to initialize basic parameters
     Parameters:
       input pcentity - Entity name
       input pcentity2 - Second entity name
       input pcid1 - First ID
       input pcid2 - Second ID
    ------------------------------------------------------------------------------*/
    method private void InitializeBasicParams(
        input pcentity as character,
        input pcentity2 as character,
        input pcid1 as character,
        input pcid2 as character):
        
        if pcid1 > "" then
            this-object:id1 = pcid1.
        if pcid2 > "" then
            this-object:id2 = pcid2.
        if pcentity > "" then
            this-object:entityName = pcentity.
        if pcentity2 > "" then
            this-object:entityName2 = pcentity2.
    end method.

    method public void BuildQueryString(input pcquerystring as character, output table ttQueryParams):
        var character cParam, cName, cValue, cWhere.
        var integer i, idx.
        
        do i = 1 to num-entries(pcqueryString, "&"):
            cParam = entry(i, pcqueryString, "&").
            idx = index(cParam, "=").
            
            if idx > 0 then 
            do:
                cName = substring(cParam, 1, idx - 1, "CHARACTER").
                cValue = OpenEdge.Net.URI:Decode(substring(cParam, idx + 1, -1, "CHARACTER")).
                
                /* Process parameter */
                this-object:ProcessQueryParameter(cName, cValue, table ttQueryParams, input-output cWhere).
            end.
        end.
        
        this-object:where = cWhere.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Process individual query parameter
     Parameters:
       input pcName - Parameter name
       input pcValue - Parameter value
       output table ttQueryParams - Query parameters table
       input-output pcWhere - WHERE clause being built
    ------------------------------------------------------------------------------*/
    method private void ProcessQueryParameter(
        input pcName as character,
        input pcValue as character,
        output table ttQueryParams,
        input-output pcWhere as character):
        
        case pcName:
            when "sort_by" then 
                this-object:SortBy = pcValue.
            when "limit" then
                this-object:TopRecs = integer(pcValue).
            when "offset" then
                this-object:SkipRecs = integer(pcValue).
            when "id" then
                this-object:rowid = pcValue.
            otherwise
                this-object:AddCustomParameter(pcName, pcValue, table ttQueryParams, input-output pcWhere).
        end case.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Add custom parameter to query
     Parameters:
       input pcName - Parameter name
       input pcValue - Parameter value
       output table ttQueryParams - Query parameters table
       input-output pcWhere - WHERE clause being built
    ------------------------------------------------------------------------------*/
    method private void AddCustomParameter(
        input pcName as character,
        input pcValue as character,
        output table ttQueryParams,
        input-output pcWhere as character):
        
        /* Add to field and value lists */
        this-object:FieldList = left-trim(this-object:FieldList + "," + pcName, ",").
        this-object:ValueList = left-trim(this-object:ValueList + "," + pcValue, ",").
        
        /* Create query parameter record */
        create ttQueryParams.
        assign 
            ttQueryParams.fieldname = pcName
            ttQueryParams.fieldvalue = pcValue.
        
        /* Build WHERE clause */
        if pcWhere > "" then
            pcWhere = pcWhere + " AND " + pcName + "=" + QUOTER(pcValue).
        else
            pcWhere = pcName + "=" + QUOTER(pcValue).
    end method.  
    
DESTRUCTOR PUBLIC FilterParams( ):
END DESTRUCTOR.
    
end class.