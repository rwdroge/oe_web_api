/*------------------------------------------------------------------------
    File        : remote-test-proc.p
    Purpose     : Simple remote procedure for APSV transport testing
    Description : This procedure runs on the AppServer to verify connectivity
    Author(s)   : 
    Created     : 
    Notes       : Called remotely from test-apsv-connection.p
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE OUTPUT PARAMETER pcMessage AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER piTimestamp AS INTEGER NO-UNDO.

/* Set output parameters */
pcMessage = "Remote procedure executed successfully on AppServer".
piTimestamp = MTIME.

/* Log execution */
MESSAGE "[" STRING(NOW) "]" 
        "Remote procedure executed - Session ID:" SESSION:SERVER-CONNECTION-ID
        VIEW-AS ALERT-BOX INFORMATION.

RETURN.
