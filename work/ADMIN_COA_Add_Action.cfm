<cfinclude template="../templates/header.cfm"> 

<head>
	<Title>ADMIN COA Add Action</Title>
</head>

<body>

<CFIF IsDefined("FORM.College_Support")>
	<CFSET College_Support = 1>
<CFELSE>
	<CFSET College_Support = 0>
</CFIF>

<cfquery name="Add_Fundcenter" datasource="#THIS.DSN#">
	INSERT INTO
		PEDI_PBT_COA
		(FUNDCENTER,
		DESCRIPTION,
		FUND_TYPE)
	VALUES
		('#FORM.FUNDCENTER#',
		'#FORM.DESCRIPTION#',
		'#FORM.FUND_TYPE#')
</cfquery>

<cflocation url="ADMIN_COA_Display.cfm">

<br><br>
<cfinclude template="../templates/footer.cfm"> 
</body>
</html>
