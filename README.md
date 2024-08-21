# <h1>GenericService</h1>

An implementation of a generic WebHandler that implements a more 'normal' REST
api than the JSDO implementation.

This example is based on the Sports2020 db (of course :)).
It supports paging ("limit" and "offset"), sorting ("sort_by") and basic 
filtering by using whatever field available for a certain object/business entity.

It also supports viewing of meta data of a certain entity (field names and data types).
With that information you can see what you should offer as input whenever you are updating or creating records via the api.
This can be done by using /api/<b>meta</b>/ as URI.
If you just want to get data, you should use /api/<b>data</b>/

<h2>It performs checks:</h2>

- if fields used in the filter actually exist for a certain object.
- if entities exist (either as a main entity or as combined entities i.e. 
  customers orders eq. customers/id/orders)

<h2>Important files:</h2>

<b>WebHandler</b>
- GenericService.cls    (the actual webhandler)

<b>Filters/Query</b>
- FilterParams.cls      (object that handles the filter)

<b>Interfaces</b>
- CRUD.cls (Full CRUD support)
- RO.cls (ReadOnly)  

<b>Includes</b>
- metadata.i (used for field checks and creating a object representation)

<b>Data Access</b>
- DataAccess.cls      (generic methods: count/paging/field check)

<b>Note:</b>

You will need to create a new OpenEdge Project of type 'Server', 'PAS for OpenEdge' and with transport 'WEB'. 

Then you will need to create the Resource URI(s) (mappings) for the WebHandler accordingly:

    1. /api/{apitype}/{entityname}/{id1}/{entityname2}/{id2}
    2. /api/{apitype}/{entityname}/{id1}/{entityname2}
    3. /api/{apitype}/{entityname}/{id1}
    4. /api/{apitype}/{entityname}

<h2>Usage</h2>

<H3>GET</h3>

<b>MetaData</b>

    http(s)://<servername>:<portnumber>/<webappname>/api/meta/<entityname>

<b>Data</b>

    Get all customers: 
    http(s)://<servername>:<portnumber>/<webappname>/api/data/customers

    Get one customer:
    http(s)://<servername>:<portnumber>/<webappname>/api/data/customers/1
    
    Get filtered customer(s):
    http(s)://<servername>:<portnumber>/<webappname>/api/data/customers?SalesRep=BBB&city=Oslo
    
    Use paging:
    http(s)://<servername>:<portnumber>/<webappname>/api/data/customers?limit=10&offset=5
    
<H3>PUT</h3>

<b>Data</b>

    Update one customer:
    http(s)://<servername>:<portnumber>/<webappname>/api/data/customers/1
    

<H3>POST</h3>

<b>Data</b>

    Create one customer:
    http(s)://<servername>:<portnumber>/<webappname>/api/data/customers
