<CFSET AllSalary=0>
<TABLE width="87%" CELLSPACING="1" CELLPADDING="3" align="center" valign="top">
<TR BGCOLOR="#6666cc">
		<TD><STRONG><FONT COLOR="Silver"><EM><STRONG>SECTION</STRONG></EM></FONT></STRONG></TD>		
		<TD><STRONG><FONT COLOR="Silver"><EM><STRONG>Name</STRONG></EM></FONT></STRONG></TD>
		<TD align="center"><STRONG><FONT COLOR="Silver"><STRONG><EM>BCMID</EM></STRONG></FONT></STRONG></TD>
		<TD align="center"><STRONG><FONT COLOR="Silver"><STRONG><EM>FTE</EM></STRONG></FONT></STRONG></TD>
		<TD><STRONG><FONT COLOR="Silver"><STRONG><EM>Annual Salary</EM></STRONG></FONT></STRONG></TD>
		<cfif IsDefined("variables.PERS_SUBAREA") AND variables.PERS_SUBAREA IS "13">
			<TD><STRONG><FONT COLOR="Silver"><STRONG><EM>LEVEL</EM></STRONG></FONT></STRONG></TD>
		</cfif>
		<cfif IsDefined("variables.job_code_desc") AND (variables.job_code_desc IS "CLIN POSTDOC FELLOW" OR variables.job_code_desc IS "MEDICAL RESIDENT")>
			<TD><STRONG><FONT COLOR="Silver"><STRONG><EM>LEVEL</EM></STRONG></FONT></STRONG></TD>
			<TD><STRONG><FONT COLOR="Silver"><STRONG><EM>EFF DATE</EM></STRONG></FONT></STRONG></TD>
			<TD><STRONG><FONT COLOR="Silver"><STRONG><EM>New Stipend</EM></STRONG></FONT></STRONG></TD>
			<TD><STRONG><FONT COLOR="Silver"><STRONG><EM>New Level</EM></STRONG></FONT></STRONG></TD>
		</cfif>
	</TR>
		<tr style="color: Yellow; background-color: Black; font-weight: bold; font-size: larger;"><CFIF Get_All.RecordCount IS "0">YOUR QUERY RETURNED NO RECORDS - PLEASE MODIFY YOUR REQUEST AND TRY AGAIN</cfif></tr>	
<cfoutput query="Get_All" group="BCM_ID">
	<cfif Get_All.Org_Unit IS session.pbt_ORG_UNIT OR session.pbt_Administrator IS "1_Admin"><CFSET AllSalary=AllSalary+Get_All.ANNUAL_SALARY></cfif>
	<TR <CFIF NOT Get_All.Validated>BGCOLOR="LIGHTGREY"<CFELSEIF Get_All.New_Hire>BGCOLOR="Yellow"</CFIF>>
		<TD>#Get_All.HOME_DEPT_DESC#</TD>
		<td><cfif NOT IsDefined("URL.Go")><A Href="emp_detail.cfm?BCM_ID=#Get_All.BCM_ID#"></cfif>#UCase(Get_All.Last_Name)#, #UCase(Get_All.First_Name)#<cfif NOT IsDefined("URL.Go")></A></cfif></td>
		<TD align="center">#Get_All.BCM_ID#</TD>		
		<TD align="center">#Get_All.FTE#</TD>		
		<TD align="right"><CFIF session.pbt_Administrator IS "1_Admin">#NumberFormat(Get_All.ANNUAL_SALARY,"$999,999,999")#<CFELSEIF #Get_All.Org_Unit# NEQ #session.pbt_ORG_UNIT#>masked<CFELSE>#NumberFormat(Get_All.ANNUAL_SALARY,"$999,999,999")#</cfif></td>		
		<cfif IsDefined("variables.PERS_SUBAREA") AND (variables.PERS_SUBAREA IS "13" OR variables.PERS_SUBAREA IS "12")>
			<TD align="center">#Get_All.PDOC_LEVEL#</TD>
		</cfif>			
		<cfif IsDefined("variables.job_code_desc") AND (variables.job_code_desc IS "CLIN POSTDOC FELLOW" OR variables.job_code_desc IS "MEDICAL RESIDENT")>
			<TD align="center">#Get_All.PDOC_LEVEL#</TD>
			<TD align="center">#DATEFORMAT(Get_All.EFF_DATE,"MM/DD/YYYY")#</TD>
			<TD align="right"><CFIF session.pbt_Administrator IS "1_Admin">#NumberFormat(Get_All.NEW_ANNUAL_SALARY,"$999,999,999")#<CFELSEIF #Get_All.Org_Unit# NEQ #session.pbt_ORG_UNIT#>masked<CFELSE>#NumberFormat(Get_All.NEW_ANNUAL_SALARY,"$999,999,999")#</cfif></td>		
			<TD align="center">#Get_All.NEW_PDOC_LEVEL#</TD>
		</cfif>

	</TR>
</CFOUTPUT>
</table>
<br>
<table align="center" valign="top">
	<TR>
		<TD>
			<cfif NOT IsDefined("URL.Go") AND NOT Variables.Section_Locked and session.pbt_PREF_DEF_FY IS THIS.FY>
				<cfinclude template="../templates/Emp_Add_Button.cfm">
			</CFIF>
		</TD>
		<TD>
			<CFOUTPUT>
				<STRONG>
					<cfif session.pbt_Administrator IS "1_Admin" AND NOT IsDefined("session.pbt_Admin_Org_Unit")>Sum of Annual Salaries in PEDIATRICS<CFELSE>Sum of Annual Salaries in #session.pbt_admin_home_dept_desc#</cfif> = <FONT COLOR="RoyalBlue">#NumberFormat(AllSalary,"$999,999,999")#</font>
				</strong>
			</cfoutput>
		</TD>
	</TR>
	<tr>
		<td colspan="2">
			<cfif NOT IsDefined("URL.Go")>
				<br><br>
				<div style="clear:all;">
				<cfinclude template="../templates/Legend_footer.cfm">
				</div>
			</cfif>
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<div style="clear:all;"></div>
			<div style="float: center;">
				<CFINCLUDE Template="../templates/footer.cfm">
			</div>
		</td>
	</tr>
</table>