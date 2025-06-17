/*********************************************************************
 * File: wait20seconds.p
 * Description: ABL procedure that waits for 20 seconds before returning to caller
 * Author: Cascade AI
 * Created: 2025-06-06
 *********************************************************************/

/* This procedure demonstrates how to create a delay in ABL */
PROCEDURE wait20seconds:
    
    DEFINE VARIABLE startTime AS DATETIME NO-UNDO.
    DEFINE VARIABLE endTime   AS DATETIME NO-UNDO.
    DEFINE VARIABLE waitMsg   AS CHARACTER NO-UNDO.
    
    /* Get the current time */
    startTime = NOW.
    
    /* Display start message */
    waitMsg = "Starting wait at " + STRING(startTime).
    MESSAGE waitMsg.
    
    /* Use PAUSE statement to wait for 20 seconds */
    PAUSE 20 NO-MESSAGE.
    
    /* Get the end time */
    endTime = NOW.
    
    /* Display completion message */
    waitMsg = "Wait completed at " + STRING(endTime) + 
              ". Total wait time: " + 
              STRING(INTERVAL(endTime, startTime, "seconds")) + 
              " seconds.".
    MESSAGE waitMsg.
    
END PROCEDURE.

/* Call the procedure to execute it */
RUN wait20seconds.
