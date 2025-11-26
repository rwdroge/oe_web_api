/*------------------------------------------------------------------------
    File        : remote-get-customer-count.p
    Purpose     : Get total customer count from Sports2020 database
    Description : Remote procedure that runs on AppServer
    Author(s)   : 
    Created     : 
    Notes       : Called remotely via APSV transport
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE OUTPUT PARAMETER piCount AS INTEGER NO-UNDO.

DEFINE BUFFER bCustomer FOR Customer.

/* Count customers */
FOR EACH bCustomer NO-LOCK:
    piCount = piCount + 1.
END.

RETURN.

CATCH e AS Progress.Lang.Error:
    MESSAGE "Error in remote-get-customer-count.p:" SKIP
            e:GetMessage(1).
    UNDO, THROW e.
END CATCH.
