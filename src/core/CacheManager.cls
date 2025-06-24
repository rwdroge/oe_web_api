/*------------------------------------------------------------------------
    File        : CacheManager
    Purpose     : Application caching system
    Syntax      : 
    Description : Provides caching functionality for the application
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Caching framework for improved performance
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Json.ObjectModel.*.
using core.*.


block-level on error undo, throw.

class core.CacheManager:
    
    /* Singleton instance */
    var private static core.CacheManager Instance.
    
    /* Logger instance */
    var private core.Logger iLogger.
    
    /* Cache entries */
    define private temp-table CacheEntries no-undo
        field CacheKey as character
        field CacheValue as Progress.Lang.Object
        field ExpiryTime as datetime-tz
        index idx1 as primary unique CacheKey.
    
    /*------------------------------------------------------------------------------
     Purpose: Private constructor for singleton pattern
     Notes: Prevents direct instantiation
    ------------------------------------------------------------------------------*/
    constructor private CacheManager():
        super().
        
        /* Get logger instance */
        iLogger = core.Logger:GetInstance().
        
        /* Start cache cleanup timer */
        this-object:StartCleanupTimer().
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get singleton instance
     Returns: CacheManager instance
     Notes: Creates instance if it doesn't exist
    ------------------------------------------------------------------------------*/
    method public static CacheManager GetInstance():
        if not valid-object(Instance) then
            Instance = new CacheManager().
            
        return Instance.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Set cache entry
     Parameters:
       input pcKey - Cache key
       input poValue - Cache value
       input piExpirySeconds - Expiry time in seconds
     Notes: Sets cache entry with expiry time
    ------------------------------------------------------------------------------*/
    method public void Set(
        input pcKey as character,
        input poValue as Progress.Lang.Object,
        input piExpirySeconds as integer):
        
        var datetime-tz dtExpiry.
        
        /* Calculate expiry time */
        dtExpiry = add-interval(now, piExpirySeconds, "seconds").
        
        /* Check if entry exists */
        find CacheEntries where CacheEntries.CacheKey = pcKey no-error.
        if available CacheEntries then do:
            /* Update existing entry */
            CacheEntries.CacheValue = poValue.
            CacheEntries.ExpiryTime = dtExpiry.
        end.
        else do:
            /* Create new entry */
            create CacheEntries.
            assign
                CacheEntries.CacheKey = pcKey
                CacheEntries.CacheValue = poValue
                CacheEntries.ExpiryTime = dtExpiry.
        end.
        
        iLogger:Debug("Cache entry set: " + pcKey).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get cache entry
     Parameters:
       input pcKey - Cache key
     Returns: Cache value or ? if not found or expired
     Notes: Gets cache entry if exists and not expired
    ------------------------------------------------------------------------------*/
    method public Progress.Lang.Object Get(input pcKey as character):
        var Progress.Lang.Object oValue.
        
        /* Find cache entry */
        find CacheEntries where CacheEntries.CacheKey = pcKey no-error.
        if available CacheEntries then do:
            /* Check if expired */
            if CacheEntries.ExpiryTime < now then do:
                /* Delete expired entry */
                delete object CacheEntries.CacheValue no-error.
                delete CacheEntries.
                
                iLogger:Debug("Cache entry expired: " + pcKey).
                return ?.
            end.
            
            /* Return cache value */
            oValue = CacheEntries.CacheValue.
            
            iLogger:Debug("Cache hit: " + pcKey).
        end.
        else
            iLogger:Debug("Cache miss: " + pcKey).
        
        return oValue.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Remove cache entry
     Parameters:
       input pcKey - Cache key
     Notes: Removes cache entry if exists
    ------------------------------------------------------------------------------*/
    method public void Remove(input pcKey as character):
        /* Find cache entry */
        find CacheEntries where CacheEntries.CacheKey = pcKey no-error.
        if available CacheEntries then do:
            /* Delete cache entry */
            delete object CacheEntries.CacheValue no-error.
            delete CacheEntries.
            
            iLogger:Debug("Cache entry removed: " + pcKey).
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clear all cache entries
     Notes: Removes all cache entries
    ------------------------------------------------------------------------------*/
    method public void Clear():
        /* Delete all cache entries */
        for each CacheEntries:
            delete object CacheEntries.CacheValue no-error.
            delete CacheEntries.
        end.
        
        iLogger:Info("Cache cleared").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Start cache cleanup timer
     Notes: Starts timer to clean up expired cache entries
    ------------------------------------------------------------------------------*/
    method private void StartCleanupTimer():
        /* Run cleanup every 5 minutes */
        run CleanupExpiredEntries.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up expired cache entries
     Notes: Removes expired cache entries
    ------------------------------------------------------------------------------*/
    method private void CleanupExpiredEntries():
        var integer iCount.
        
        /* Find and delete expired entries */
        for each CacheEntries where CacheEntries.ExpiryTime < now:
            delete object CacheEntries.CacheValue no-error.
            delete CacheEntries.
            
            iCount = iCount + 1.
        end.
        
        if iCount > 0 then
            iLogger:Debug("Cleaned up " + string(iCount) + " expired cache entries").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public CacheManager():
        /* Clean up cache entries */
        for each CacheEntries:
            delete object CacheEntries.CacheValue no-error.
            delete CacheEntries.
        end.
    end destructor.
    
end class.
