  
 /*------------------------------------------------------------------------
    File        : items 
    Syntax      : 
    Author(s)   : rdroge
    Created     : Thu Dec 13 10:02:58 CET 2018
    Notes       : 
  ----------------------------------------------------------------------*/


using Progress.Lang.*.
using OpenEdge.BusinessLogic.BusinessEntity.
using Progress.Json.ObjectModel.*.
using data.*.

block-level on error undo, throw.

class entities.items inherits BusinessEntity implements interfaces.CRUD:
    /*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    
    {"entities/inc/items.i"}
     
    define public property ttName as character no-undo initial "ttitem" get. set. 
    define public property piName as character no-undo initial "itemnum" get. set.
    define public property dbName as character no-undo initial "item" get. set.
    
    var integer iSeq.
    var DataAccess dao.
    /*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    constructor public items():
        super (dataset dsItem:HANDLE).
        
    end constructor.
   
        method public void Read(input filter as generics.FilterParams, output dataset-handle hDataSet):
        this-object:GetItems(filter, output dataset dsItem by-reference).
        hDataSet = dataset dsItem:handle.    
    end method.
    
    method public void Create(input jsonObject as JsonObject, output dataset-handle hDataSet):
        dao = new DataAccess().
        dao:attachSource("ttitem", "itemnum", "item", "itemnum", "", ?, input-output dataset dsItem by-reference).
        dataset dsItem:read-json('JsonObject', jsonObject) no-error.
        dao:CommitChanges(piName, dataset dsItem by-reference).
        hDataSet = dataset dsItem:handle.
    
    end method.
    
    method public void update(input filter as generics.FilterParams, input jsonObject as JsonObject, output dataset-handle hDataSet):
        this-object:updateItems(filter, input-output dataset dsItem by-reference).
        hDataSet = dataset dsItem:handle.
    end method.
    
    method public void Delete(input filter as generics.FilterParams, output dataset-handle hDataSet):
        dao = new DataAccess().
        dao:attachSource("ttitem", "itemnum", "item", "itemnum", filter:id1, filter, input-output dataset dsItem by-reference).
        this-object:Deleteitem(input-output dataset dsItem by-reference).
        hDataSet = dataset dsItem:handle.
        dao:detachSource(dataset dsItem by-reference).
    
    end method.
        
    /*------------------------------------------------------------------------------
            Purpose:  Get one or more records, based on a filter string                                                                     
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    method private void GetItems( input filter as generics.FilterParams, output DATASET dsItem ):
        dao = new DataAccess().
        dao:attachSource(this-object:ttName, this-object:piName, this-object:dbName, this-object:piName, filter:id1, filter, input-output dataset dsItem by-reference).
        dao:detachSource(dataset dsItem by-reference).    

    end method.
    
    {entities/inc/metadata.i &entity=item}
    
    /*------------------------------------------------------------------------------
            Purpose:  Update one or more records                                                                  
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    method public void Updateitems(input filter as generics.FilterParams, input-output DATASET dsItem):            
        dao = new DataAccess().
        dao:CommitChanges(piName, input-output dataset dsItem by-reference).
              
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose:    Delete a record                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    method public void Deleteitem(input-output DATASET dsItem):                    
    end method.     

    destructor public items():
        delete object dao.
        delete ttitem no-error.
    end destructor.
    
end class.
