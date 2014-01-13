<!--- Credenciales --->
<cfset Client_id = "">
<cfset Client_secret = "">

<!--- Estructura para generar usuario de prueba
<cfset usuarioPrueba = structNew()>
<cfset usuarioPrueba["site_id"] = "MLA">
<cfset prefUser = serializeJSON(usuarioPrueba)>
<cfdump var="#mp.createTestUser(prefUser)#">
 --->

<!--- Estructura para las urls de resultado 
<cfset backUrls = structNew()>
<cfset backUrls['failure'] = UrlCreator('checkoutButton','estado:-1')>
<cfset backUrls['pending'] = UrlCreator('checkoutButton','estado:0')>
<cfset backUrls['success'] = UrlCreator('checkoutButton','estado:1')>
--->

<!--- Inicializamos componente con las credenciales --->
<cfset mp = createObject("component", "system.mercadopago.MP").init(Client_id, Client_secret)/>

<!--- Creamos estructura del producto --->
<cfset producto = structNew()>
<cfset producto['title'] = 'sdk-coldfusion'>
<cfset producto['unit_price'] = 10.5>
<cfset producto['quantity'] = javaCast("int", 1)>
<cfset producto['currency_id'] = 'ARS'>


<!--- Agregamos el producto a una lista --->
<cfset lista = arraynew(1)>
<cfset arrayAppend(lista, producto)>
<!--- Insertamos la lista en una estructura con un solo item llamado "item" --->
<cfset structData = StructNew()>
<cfset structData['items'] = lista>
<cfset structData['external_reference'] = javaCast("int", 12504)>
<!--- <cfset structData['back_urls'] = backUrls> --->

<!--- Serializamos el JSON de las preferencias (productos) --->
<cfset preferencia = serializeJson(structData)>

<cfset resultado = mp.createPreference(preferencia)>

<cfif IsJson(resultado) IS TRUE>
	<cfset preferenceResult = deserializeJSON(resultado)>
</cfif>

<a href="<cfoutput>#preferenceResult["sandbox_init_point"]#</cfoutput>" name="MP-Checkout" class="orange-ar-m-sq-arall">Pagar</a>
<script type="text/javascript" src="http://mp-tools.mlstatic.com/buttons/render.js"></script>