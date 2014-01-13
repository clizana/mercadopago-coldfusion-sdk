<!--- Mas info ver http://developers.mercadopago.com/documentacion/notificaciones-de-pago --->

<!--- Credenciales --->
<cfset Client_id = "">
<cfset Client_secret = "">

<!--- Inicializamos componente con las credenciales --->
<cfset mp = createObject("component", "system.mercadopago.MP").init(Client_id, Client_secret)/>

<cfif structKeyExists(Request.url.forms, "id")>
	<cfset mp.sandboxMode(true)>
	<cfset paymentInfo = mp.getPaymentInfo("#Request.url.forms.id#")>
	<cfif isJson(paymentInfo)>
		<cfdump var="#deserializeJson(paymentInfo)#">
	</cfif>
</cfif>

<form name="frmPaymentInfo" id="frmPaymentInfo" action="<cfoutput>#URLCreator('receiveIPN')#</cfoutput>" method="post">
	<input type="text" name="id" value="">
	<input type="submit" class="btn" id="btn" value="Revisar IPN">
</form>