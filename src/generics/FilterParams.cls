
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
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public FilterParams (   input pcentity as character,
                                        input pcentity2 as character,
                                        input pcquerystring as character,
                                        input pcid1 as character,
                                        input pcid2 as character,
                                        output table ttQueryParams 
                                           ):
        super ().
        
        
            if pcid1 > "" then
                this-object:id1 = pcid1.
            if pcid2 > "" then
                this-object:id2 = pcid2.
            if pcentity > "" then do:
                this-object:entityName = pcentity.
            end.
            if pcentity2 > "" then
                this-object:entityName2 = pcentity2.  
            if pcqueryString > "" then 
            do:
                this-object:filtered = true.
                this-object:BuildQueryString(pcquerystring, table ttQueryParams).
            end.


    
    end constructor.

    method public void BuildQueryString(input pcquerystring as character, output table ttQueryParams):
        define variable cParam as character no-undo.
        define variable i      as integer   no-undo.
        define variable cName  as character no-undo.
        define variable cWhere as character no-undo.
        define variable cValue as character no-undo.
        define variable idx    as integer   no-undo.
        
        do i = 1 to num-entries(pcqueryString, "&"):
            cParam = entry(i, pcqueryString, "&").
            idx = index(cParam, "=").
            if idx > 0 then 
            do:
                cName = substring(cParam, 1, idx - 1, "CHARACTER").
                cValue = OpenEdge.Net.URI:Decode(substring(cParam, idx + 1,-1,"CHARACTER")).
                case cName:
                    when "sort_by" then 
                        this-object:SortBy = entry(2,cParam,"=").
                    when "limit" then
                        this-object:TopRecs = integer(entry(2,cParam,"=")).
                    when "offset" then
                        this-object:SkipRecs = integer(entry(2,cParam,"=")).
                    when "id" then
                        this-object:rowid = entry(2,cParam,"=").
                    otherwise do:
                        this-object:FieldList = left-trim(this-object:FieldList + "," + cName, ",").
                        this-object:ValueList = left-trim(this-object:ValueList + "," + cValue, ",").
                        create ttQueryParams.
                        assign 
                            ttQueryParams.fieldname     = cName
                            ttQueryParams.fieldvalue    = cValue
                            .     
                    
                    if cWhere > "" then
                        cWhere = cWhere + " AND " + cName + "=" + QUOTER(cValue).
                    else
                        cWhere = cName + "=" + QUOTER(cValue).
                    end.    
                end case.        

                this-object:where = cWhere.
            end.
        end.
    end method.  
    
DESTRUCTOR PUBLIC FilterParams( ):
END DESTRUCTOR.
    
end class.