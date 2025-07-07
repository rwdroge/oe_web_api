 /*------------------------------------------------------------------------
    File        : Suppliers
    Purpose		:
    Syntax      : 
    Description :
    Author(s)   : rdroge
    Created     : Mon Jun 16 11:40:26 CEST 2025
    Notes       : 
  ----------------------------------------------------------------------*/
  
  /* ***************************  Definitions  ************************** */
  
  /* ********************  Preprocessor Definitions  ******************** */
  
  /* ***************************  Main Block  *************************** */
  
  /** Dynamically generated schema file **/
   

define temp-table ttSupplier serialize-name "suppliers" before-table bttSupplier
field SupplierIDNum as integer initial "0" label "Supplier ID"
field Name as character label "Name"
field Address as character label "Address"
field Address2 as character label "Address2"
field City as character label "City"
field State as character label "State"
field Country as character initial "USA" label "Country"
field Phone as character label "Phone"
field Password as character label "Password"
field LoginDate as date label "Login Date"
field Comments as character label "Comments"
field ShipAmount as integer initial "100" label "Ship Amount"
field PostalCode as character label "Postal Code"
field Discount as integer initial "0" label "Discount"
field id as character
field seq as integer
index SupplierID is primary unique SupplierIDNum ascending
index Name Name ascending
index Country Country ascending. 


define dataset dsSupplier for ttSupplier.
