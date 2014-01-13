<cfcomponent output="false" hint="Componente que interactúa como SDK para comunicarse con mercadopago">
	
	<cfset Variables.version = "0.0.1">
	<cfset Variables.client_id = "">
	<cfset Variables.client_secret = "">
	<cfset Variables.access_data = structNew()>
	<cfset Variables.sandbox = false>
	<cfset Variables.restClient =  createObject("component", "system.mercadopago.MPRestClient")>
	<!---
		   Constructor de la clase
	---->
	<cffunction name="init" access="public" returntype="MP" output="false" hint="Constructor">
		<cfargument name="client_id" type="string" required="true">
		<cfargument name="client_secret" type="string" required="true">

		<cfset Variables.client_id = Arguments.client_id>
		<cfset Variables.client_secret = Arguments.client_secret>

		<cfreturn this />
	</cffunction>

	<!---
		Metodo para establecer u obtener el modo sandbox
	---->
	<cffunction name="sandboxMode" access="public" returntype="boolean" output="false" hint="Modo Sandbox">
		<cfargument name="sandbox" type="boolean" required="false" default="#Variables.sandbox#">

		<cfset Variables.sandbox = Arguments.sandbox>

		<cfreturn Variables.sandbox />
	</cffunction>

	<!---
		Metodo para obtener el token de acceso y asi poder autentificarse con la API de mercadopago
	---->
	<cffunction name="getAccessToken" access="public" returntype="string" output="false" hint="Token">
		<cfset var form = structNew()>
		<cfset form['client_id'] = "#Variables.client_id#">
		<cfset form['client_secret'] = "#Variables.client_secret#">
		<cfset form['grant_type'] = "client_credentials">

		<cfset response = Variables.restClient.exec("POST", "/oauth/token", form, "application/x-www-form-urlencoded")>
		
		<cfif response.responseHeader.status_code IS "200">
			<cfset Variables.access_data=DeserializeJSON(response.fileContent.toString())>
			<cfreturn Variables.access_data['access_token']/>
		</cfif>
		<cfreturn "">
	</cffunction>

	<!---
		Metodo para crear una preferencia (botones para comprar por ejemplo)
	---->
	<cffunction name="createPreference" access="public" returnformat="JSON" output="false" hint="Crea preferencia">
		<cfargument name="preference" type="any" required="true">
		<cfset var access_token = getAccessToken()>

		<cfif len(access_token) GT 0>
			<cfset response = Variables.restClient.post("/checkout/preferences?access_token=#access_token#", Arguments.preference)>
			<cfreturn response.fileContent.toString()>
		</cfif>
	</cffunction>

	<!---
		Metodo para actualizar una preferencia
	---->
	<cffunction name="updatePreference" access="public" returnformat="JSON" output="false" hint="Actualiza preferencia">
		<cfargument name="id" type="string" required="true">
		<cfargument name="preference" type="any" required="true">

		<cfset var access_token = getAccessToken()>

		<cfif len(access_token) GT 0>
			<cfset response = Variables.restClient.put("/checkout/preferences/#Arguments.id#?access_token=#access_token#", Arguments.preference)>
			<cfreturn response.fileContent.toString()>
		</cfif>
	</cffunction>

	<!---
		Metodo para obtener una preferencia a base de un ID generado con el metodo createPreference
	---->
	<cffunction name="getPreference" access="public" returnformat="JSON" output="false" hint="Obtiene preferencia">
		<cfargument name="id" type="string" required="true">
		<cfset var access_token = getAccessToken()>

		<cfif len(access_token) GT 0>
			<cfset response = Variables.restClient.get("/checkout/preferences/#Arguments.id#?access_token=#access_token#")>
			<cfreturn response.fileContent.toString()>
		</cfif>
	</cffunction>	

	<!---
		Metodo para obtener la información de un pago a base de su ID
	---->
	<cffunction name="getPaymentInfo" access="public" returnformat="JSON" output="false" hint="Obtiene pago">
		<cfargument name="id" type="string" required="true">
		<cfset var access_token = getAccessToken()>
		<cfset var urlPrefix = "">

		<cfif sandboxMode() IS TRUE>
			<cfset urlPrefix = "/sandbox">
		</cfif>

		<cfif len(access_token) GT 0>
			<cfset response = Variables.restClient.get("#urlPrefix#/collections/notifications/#Arguments.id#?access_token=#access_token#")>
			<cfreturn response.fileContent.toString()>
		</cfif>

	</cffunction>

	<!---
		Metodo para buscar pagos a base de ciertos criterios
	---->
	<cffunction name="searchPayment" access="public" returnformat="JSON" output="false" hint="Hace una busqueda">
		<cfargument name="filters" type="struct" required="true">
		<cfargument name="offset" type="numeric" required="false" default="0">
		<cfargument name="limit" type="numeric" required="false" default="5">

		<cfset var access_token = getAccessToken()>
		<cfset var searchQuery = "">
		<cfset var urlPrefix = "">

		<cfif sandboxMode() IS TRUE>
			<cfset urlPrefix = "/sandbox">
		</cfif>

		<cfset filters["offset"] = Arguments.offset>
		<cfset filters["limit"] = Arguments.limit>

		<cfset searchQuery = buildQuery(filters)>

		<cfif len(access_token) GT 0>
			<cfset response = Variables.restClient.get("#urlPrefix#/collections/search?#searchQuery#&access_token=#access_token#")>
			<cfreturn response.fileContent.toString()>
		</cfif>

	</cffunction>

	<!---
		Metodo para construir una query de busqueda aceptada por la API de mercadopago
	---->
	<cffunction name="buildQuery" access="private" returntype="string" output="false" hint="Construye query de busqueda a partir de una estructura">
		<cfargument name="params" type="struct" required="true">
		<cfset var encoder = createObject("java","java.net.URLEncoder")>

		<cfset var resultQuery = "">

		<cfloop collection=#params# item="key">
    		<cfset resultQuery = resultQuery & key & "=" & encoder.encode(params[key], "UTF-8") & "&">
    	</cfloop>
		<cfset resultQuery = RemoveChars(resultQuery, len(resultQuery), 1)>

		<cfreturn resultQuery>
	</cffunction>


	<!--- INICIO Implementados pero no "probados" por no contar con métodos de sandbox para hacerlo, además no son requeridos para la integración actual --->

	<cffunction name="refundPayment" access="public" returnformat="JSON" output="false" hint="Reembolsa pago">
		<cfargument name="id" type="string" required="true">
		<cfset var access_token = getAccessToken()>

		<cfset var refundStatus = structNew()>
		<cfset refundStatus["status"] = "refunded">

		<cfif len(access_token) GT 0>
			<cfset response = Variables.restClient.put("/collections/#Arguments.id#?access_token=#access_token#", serializeJSON(refundStatus))>
			<cfreturn response.fileContent.toString()>
		</cfif>
	</cffunction>

	<cffunction name="cancelPayment" access="public" returnformat="JSON" output="false" hint="Cancela pago">
		<cfargument name="id" type="string" required="true">
		<cfset var access_token = getAccessToken()>

		<cfset var refundStatus = structNew()>
		<cfset refundStatus["status"] = "cancelled">

		<cfif len(access_token) GT 0>
			<cfset response = Variables.restClient.put("/collections/#Arguments.id#?access_token=#access_token#", serializeJSON(refundStatus))>
			<cfreturn response.fileContent.toString()>
		</cfif>
	</cffunction>

	<!--- FIN Implementados pero no "probados" por no contar con métodos de sandbox para hacerlo, además no son requeridos para la integración actual --->
	
	<!--- Metodo para crear usuarios de prueba --->
	<cffunction name="createTestUser" access="public" returnformat="JSON" output="false" hint="Crea usuarios de prueba para pagar">
		<cfargument name="preference" type="any" required="true">
		<cfset var access_token = getAccessToken()>

		<cfif len(access_token) GT 0>
			<cfset response = Variables.restClient.post("/users/test_user?access_token=#access_token#", Arguments.preference)>
			<cfreturn response.fileContent.toString()>
		</cfif>

	</cffunction>

</cfcomponent>