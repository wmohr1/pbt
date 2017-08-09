<cfinclude template="../templates/header.cfm"> 

<head>
	<Title>ADMIN COA Action</Title>
</head>

<body>

<CFIF IsDefined("FORM.College_Support")>
	<CFSET College_Support = 1>
<CFELSE>
	<CFSET College_Support = 0>
</CFIF>

<cfquery name="Get_PEDI_PBT_COA" datasource="#THIS.DSN#">
	UPDATE 
		PEDI_PBT_COA
	SET
		DESCRIPTION = '#FORM.DESCRIPTION#'
		<!---College_Support = '#College_Support#'--->
	WHERE FUNDCENTER = #FORM.FUNDCENTER#
</cfquery>

<cflocation url="ADMIN_COA_Display.cfm">

<br><br>
<cfinclude template="../templates/footer.cfm"> 
</body>
</html>
