/*------------------------------------------------------------------------
    File        : compile_all.p
    Purpose     : Compile all application code for production
    Description : Recursively compiles all .cls and .p files
    Author(s)   : 
    Created     : 
    Notes       : Run with database connection for proper compilation
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE cSourceDir AS CHARACTER NO-UNDO INITIAL "src".
DEFINE VARIABLE cFile AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFullPath AS CHARACTER NO-UNDO.
DEFINE VARIABLE iFilesCompiled AS INTEGER NO-UNDO.
DEFINE VARIABLE iFilesFailed AS INTEGER NO-UNDO.
DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.

OUTPUT TO "logs/compile.log" APPEND.

MESSAGE "========================================" SKIP
        "Compilation started at" STRING(NOW) SKIP
        "========================================" SKIP.

/* Compile all .cls files */
MESSAGE SKIP "Compiling .cls files..." SKIP.

INPUT FROM OS-DIR(cSourceDir).
REPEAT:
    IMPORT cFile.
    
    IF cFile BEGINS "." THEN NEXT.
    
    IF INDEX(cFile, ".cls") > 0 THEN DO:
        cFullPath = cSourceDir + "/" + cFile.
        
        MESSAGE "Compiling:" cFullPath.
        
        COMPILE VALUE(cFullPath) SAVE NO-ERROR.
        
        IF ERROR-STATUS:ERROR THEN DO:
            MESSAGE "  ✗ FAILED:" ERROR-STATUS:GET-MESSAGE(1).
            iFilesFailed = iFilesFailed + 1.
        END.
        ELSE DO:
            MESSAGE "  ✓ SUCCESS".
            iFilesCompiled = iFilesCompiled + 1.
        END.
    END.
END.
INPUT CLOSE.

/* Compile all .p files */
MESSAGE SKIP "Compiling .p files..." SKIP.

INPUT FROM OS-DIR(cSourceDir).
REPEAT:
    IMPORT cFile.
    
    IF cFile BEGINS "." THEN NEXT.
    
    IF INDEX(cFile, ".p") > 0 THEN DO:
        cFullPath = cSourceDir + "/" + cFile.
        
        MESSAGE "Compiling:" cFullPath.
        
        COMPILE VALUE(cFullPath) SAVE NO-ERROR.
        
        IF ERROR-STATUS:ERROR THEN DO:
            MESSAGE "  ✗ FAILED:" ERROR-STATUS:GET-MESSAGE(1).
            iFilesFailed = iFilesFailed + 1.
        END.
        ELSE DO:
            MESSAGE "  ✓ SUCCESS".
            iFilesCompiled = iFilesCompiled + 1.
        END.
    END.
END.
INPUT CLOSE.

/* Compile subdirectories */
DEFINE VARIABLE cSubDirs AS CHARACTER NO-UNDO EXTENT 20.
DEFINE VARIABLE iDirCount AS INTEGER NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO.

ASSIGN
    cSubDirs[1] = "src/core"
    cSubDirs[2] = "src/data"
    cSubDirs[3] = "src/entities"
    cSubDirs[4] = "src/errors"
    cSubDirs[5] = "src/generics"
    cSubDirs[6] = "src/interfaces"
    cSubDirs[7] = "src/mcp"
    cSubDirs[8] = "src/services"
    cSubDirs[9] = "src/tests"
    cSubDirs[10] = "src/validations"
    cSubDirs[11] = "src/webhandlers"
    iDirCount = 11.

DO i = 1 TO iDirCount:
    IF cSubDirs[i] <> "" AND cSubDirs[i] <> ? THEN DO:
        MESSAGE SKIP "Compiling directory:" cSubDirs[i] SKIP.
        
        INPUT FROM OS-DIR(cSubDirs[i]).
        REPEAT:
            IMPORT cFile.
            
            IF cFile BEGINS "." THEN NEXT.
            
            IF INDEX(cFile, ".cls") > 0 OR INDEX(cFile, ".p") > 0 THEN DO:
                cFullPath = cSubDirs[i] + "/" + cFile.
                
                MESSAGE "Compiling:" cFullPath.
                
                COMPILE VALUE(cFullPath) SAVE NO-ERROR.
                
                IF ERROR-STATUS:ERROR THEN DO:
                    MESSAGE "  ✗ FAILED:" ERROR-STATUS:GET-MESSAGE(1).
                    iFilesFailed = iFilesFailed + 1.
                END.
                ELSE DO:
                    MESSAGE "  ✓ SUCCESS".
                    iFilesCompiled = iFilesCompiled + 1.
                END.
            END.
        END.
        INPUT CLOSE.
    END.
END.

/* Summary */
MESSAGE SKIP
        "========================================" SKIP
        "Compilation Summary" SKIP
        "========================================" SKIP
        "Files compiled successfully:" iFilesCompiled SKIP
        "Files failed:" iFilesFailed SKIP
        "Completed at:" STRING(NOW) SKIP
        "========================================" SKIP.

OUTPUT CLOSE.

IF iFilesFailed > 0 THEN DO:
    MESSAGE "⚠ Compilation completed with errors. Check logs/compile.log".
    RETURN ERROR.
END.
ELSE
    MESSAGE "✓ All files compiled successfully!".

CATCH e AS Progress.Lang.Error:
    MESSAGE "Error during compilation:" SKIP
            e:GetMessage(1).
    OUTPUT CLOSE.
    RETURN ERROR.
END CATCH.
