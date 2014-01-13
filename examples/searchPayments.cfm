<!--- Mas info ver http://developers.mercadopago.com/documentacion/busqueda-de-pagos-recibidos --->

<!--- Credenciales --->
<cfset Client_id = "">
<cfset Client_secret = "">

<!--- Estructura para filtros de busqueda --->
<cfset filtros = structNew()>
<!--- Filtro para buscar pagos en Argentina --->
<cfset structInsert(filtros, "site_id", "MLA")>
<cfset structInsert(filtros, "status", "approved")>
<!--- <cfset structInsert(filtros, "external_reference", "id externo")> --->


<!--- Inicializamos componente con las credenciales --->
<cfset mp = createObject("component", "system.mercadopago.MP").init(Client_id, Client_secret)/>
<!--- Sandbox Mode --->
<cfset mp.sandboxMode(True)>

<!--- Buscamos --->
<cfset result = mp.searchPayment(filtros)>

<!--- Desplegamos los resultados de forma "ordenada" en una estructura --->
<cfif isJson(result)>
	<cfset resultStruct = deserializeJSON(result)>
	<cfdump var="#resultStruct#">
<cfelse>
	<cfdump var="#result#">
</cfif>