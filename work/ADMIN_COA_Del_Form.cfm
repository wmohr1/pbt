<cfinclude template="../templates/header.cfm"> 

<head>
	<Title>ADMIN COA Delete</Title>
</head>

<body>

<CFPARAM name="SORT" default="NONE">

<CFIF IsDefined("FORM.SORT")>
	<CFSET SORT = FORM.SORT>
<CFELSEIF IsDefined("URL.SORT")>
	<CFSET SORT = URL.SORT>
</CFIF>

<cfquery name="DEL_FC" datasource="#THIS.DSN#">
	DELETE FROM PEDI_PBT_COA
	WHERE FUNDCENTER = '#URL.FUNDCENTER#'
</cfquery>

<cflocation url="ADMIN_COA_Display.cfm?SORT=#SORT#">

<cfinclude template="../templates/footer.cfm"> 
</body>
</html>
