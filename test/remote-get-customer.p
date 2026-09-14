/*------------------------------------------------------------------------
    File        : remote-get-customer.p
    Purpose     : Get customer by ID from Sports2020 database
    Description : Remote procedure that runs on AppServer
    Author(s)   : 
    Created     : 
    Notes       : Called remotely via APSV transport
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE INPUT PARAMETER piCustNum AS INTEGER NO-UNDO.
DEFINE OUTPUT PARAMETER pcCustomerName AS CHARACTER NO-UNDO.

DEFINE BUFFER bCustomer FOR Customer.

/* Find customer */
FIND FIRST bCustomer NO-LOCK
    WHERE bCustomer.CustNum = piCustNum NO-ERROR.

IF AVAILABLE bCustomer THEN
    pcCustomerName = bCustomer.Name.
ELSE
    pcCustomerName = "Customer not found".

RETURN.

CATCH e AS Progress.Lang.Error:
    MESSAGE "Error in remote-get-customer.p:" SKIP
            e:GetMessage(1).
    UNDO, THROW e.
END CATCH.
