/*------------------------------------------------------------------------
    File        : createItem.p
    Purpose     : Create a new item using the items entity class
    Syntax      : 
    Description : Demonstrates using the items entity to create a new item
    Author(s)   : 
    Created     : 2025-06-23
    Notes       : 
  ----------------------------------------------------------------------*/

/* Use block-level error handling */
block-level on error undo, throw.

/* Include required definitions */
using Progress.Json.ObjectModel.*.
using entities.items.

/* Include the dataset definition */
{entities/inc/items.i}

/* Create a JsonObject for the new item data */
define variable oJson as Progress.Json.ObjectModel.JsonObject no-undo.
var handle hDs.
var JsonObject aJson = new JsonObject().
oJson = new JsonObject().

/* Populate the JSON object with item data */
oJson:Add("Itemnum", 9999).
oJson:Add("ItemName", "Test Item").
oJson:Add("Price", 99.99).
oJson:Add("Onhand", 100).
oJson:Add("Category1", "Test Category").

aJson:Add("dsItem", oJson).

aJson:WriteFile('test.json').

/* Create a new items entity */
define variable oItems as items no-undo.
oItems = new items().

/* Create the item and get the result dataset */
    /* Create the item */
    oItems:Create(aJson, output dataset-handle hDs).
    message "do I return here?".
    /* Write the result to a JSON file */
    if valid-handle(hDs) then do:
        hDs:write-json('file', 'test2.json').
        message "Item created successfully and saved to test.json".
    end.
    else
        message "Failed to create item - invalid dataset handle".
        
catch e as Progress.Lang.Error:
    message "Error creating item: " + e:GetMessage(1).
end.

/* Clean up */
finally:
    delete object oItems no-error.
    delete object oJson no-error.
end.
