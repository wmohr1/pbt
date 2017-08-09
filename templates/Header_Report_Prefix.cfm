<CFPARAM name = "val_stat" default = "3">
<CFPARAM name = "Val_Class" default = "4">
<CFPARAM name = "Record_Type_Selection" default = "1">
<CFPARAM name = "SECTION_LOCKED" default = "0">

<cfinclude template="../templates/Set_Section.cfm"> 

<CFIF IsDefined("session.pbt_Admin_Org_Unit") AND session.pbt_Admin_Org_Unit IS NOT "All">
	<CFSET SQL_ORG_UNIT = session.pbt_Admin_Org_Unit>
<CFELSEIF IsDefined("session.pbt_Admin_Org_Unit")>
	<CFSET SQL_ORG_UNIT = "ALL">
<CFELSE>
	<CFSET SQL_ORG_UNIT = session.pbt_ORG_UNIT>
</CFIF>

<cfquery name="Get_All" datasource="#THIS.DSN#">
	SELECT
		*
	FROM         
		<cfif session.pbt_archiver>
            PEDI_PBT_HEADERS_2011_SUB
        <cfelse>
            PEDI_PBT_HEADERS
        </cfif>
	WHERE
		Emp_Status = '3'
	AND
		FY = '#session.pbt_PREF_DEF_FY#'
	<cfinclude template = "../templates/Record_Type_Selection.cfm">
	<CFIF IsDefined("SQL_ORG_UNIT") AND SQL_ORG_UNIT IS NOT "ALL">
		AND
			Org_Unit = '#SQL_ORG_UNIT#'
	<CFELSEIF IsDefined("SQL_ORG_UNIT") AND session.pbt_ADMINISTRATOR IS "3_Dept">
	AND
		Org_Unit <> '99992107'
	</CFIF>
	<CFIF IsDefined("Variables.ASC")>
		AND
			#PreserveSingleQuotes(Variables.ASC)#
	</CFIF>
	ORDER BY
		Home_Dept_Desc,
		Last_Name
</cfquery>