<cfcomponent output="false" hint="Componente que interactúa cliente REST para comunicarse con mercadopago">
	<cfset Variables.API_BASE_URL = "https://api.mercadolibre.com">

	<cffunction name="exec" access="public" returntype="any" output="false" hint="Ejecuta request">
		<cfargument name="method" type="string" required="true">
		<cfargument name="uri" type="string" required="true">
		<cfargument name="data" type="any" required="false" default="">
		<cfargument name="contentType" type="string" required="false" default="application/json">
		<cfset var length = 0>
		<cfif isStruct(data)>
			<cfset length = structCount(data)>
		<cfelse>
			<cfset length = len(data)>
		</cfif>

		<cfhttp method="#Arguments.method#" url="#Variables.API_BASE_URL##Arguments.uri#" result="httpResponse">
		    <cfhttpparam type="header" name="Content-Type" value="#Arguments.contentType#" />

		    <cfif length GT 0>
		    	<cfswitch expression="#Arguments.contentType#">
			    	<cfcase value="application/json">
			    		<cfhttpparam type="body" value="#data#">
			    	</cfcase>

			    	<cfcase value="application/x-www-form-urlencoded">
				    	<cfloop collection="#data#" item="dataItem">
				    		<cfhttpparam type="formfield" name="#dataItem#" value="#data[dataItem]#"/>
				    	</cfloop>
			    	</cfcase>

			    	<cfdefaultcase></cfdefaultcase>
		    	</cfswitch>		    
		    </cfif>
		</cfhttp>

		<cfreturn httpResponse>

	</cffunction>

	<cffunction name="get" access="public" returntype="any" output="false" hint="GET request">
		<cfargument name="uri" type="string" required="true">
		<cfargument name="contentType" type="string" required="false" default="application/json">

		<cfreturn this.exec(method="GET", uri=Arguments.uri, contentType=Arguments.contentType)>
	</cffunction>

	<cffunction name="post" access="public" returntype="any" output="false" hint="POST request">
		<cfargument name="uri" type="string" required="true">
		<cfargument name="data" type="any" required="true">
		<cfargument name="contentType" type="string" required="false" default="application/json">

		<cfreturn this.exec(method="POST", data=Arguments.data, uri=Arguments.uri, contentType=Arguments.contentType)>
	</cffunction> 

	<cffunction name="put" access="public" returntype="any" output="false" hint="PUT request">
		<cfargument name="uri" type="string" required="true">
		<cfargument name="data" type="any" required="true">
		<cfargument name="contentType" type="string" required="false" default="application/json">

		<cfreturn this.exec(method="PUT", data=Arguments.data, uri=Arguments.uri, contentType=Arguments.contentType)>
	</cffunction> 


</cfcomponent>
	