<cfinclude template="../templates/header.cfm"> 

<head>
	<Title>ADMIN PEDI_PBT_COA Display</Title>
</head>

<body>

<cfquery name="Get_PEDI_PBT_COA" datasource="#THIS.DSN#">
	SELECT *
	FROM PEDI_PBT_COA
	WHERE FUNDCENTER = '#URL.Fundcenter#'
</cfquery>

<TABLE>
	<TR>
		<TD><STRONG><FONT COLOR="Navy"><EM>Fundcenter</EM></FONT></STRONG></TD>
		<TD><STRONG><FONT COLOR="Navy"><EM>Description</EM></FONT></STRONG></TD>
		<TD><STRONG><FONT COLOR="Navy"><EM>Fund Type</EM></FONT></STRONG></TD>
		<!---<TD><STRONG><FONT COLOR="Navy"><EM>College Support</EM></FONT></STRONG></TD>--->
	</TR>

	<CFOUTPUT Query = "Get_PEDI_PBT_COA">
		<CFFORM Action = "ADMIN_COA_Edit_Action.cfm" method="POST">
			<INPUT name="Fundcenter" type="hidden" value="#Get_PEDI_PBT_COA.Fundcenter#">
			<INPUT name="SORT" type="hidden" value="#URL.SORT#">
			<TR>
				<TD>#Get_PEDI_PBT_COA.Fundcenter#</TD>
				<TD><cfinput name="Description" value="#Get_PEDI_PBT_COA.Description#" required="Yes"></TD>
				<TD>#Get_PEDI_PBT_COA.FUND_TYPE#</TD>
				<!---<TD><input type="Checkbox" name="College_Support" <cfif Get_PEDI_PBT_COA.College_Support IS "1">CHECKED</cfif>></TD>--->
			</TR>
			<TR>
				<TD></TD>
				<TD></TD>
				<TD></TD>
				<TD></TD>
				<TD></TD>
				<TD></TD>
				<TD></TD>
				<TD><input type="submit" name="SUBMIT" value="SUBMIT"></TD>
				<TD></TD>
			</TR>
		</CFFORM>
	</CFOUTPUT>
</TABLE>

<br><br>
<cfinclude template="../templates/footer.cfm"> 
</body>
</html>
