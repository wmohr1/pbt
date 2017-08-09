<cftry>
	<cfstoredproc datasource="#request.dsn#" procedure="SP_CONTROL_SELECT" blockfactor="1">
		<cfprocparam type="out" variable="spp_SAL_LOCK" dbvarname="SAL_LOCK" cfsqltype="cf_sql_integer">
		<cfprocparam type="out" variable="spp_FIRST_NAME" dbvarname="FIRST_NAME" cfsqltype="cf_sql_varchar">
		<cfprocparam type="out" variable="spp_LAST_NAME" dbvarname="LAST_NAME" cfsqltype="cf_sql_varchar">
		<cfprocparam type="out" variable="spp_HOME_DEPT_DESC" dbvarname="HOME_DEPT_DESC" cfsqltype="cf_sql_varchar">
		<cfprocparam type="in" value="#arg_FISEC#" dbvarname="FI_SEC" cfsqltype="cf_sql_varchar">
	</cfstoredproc>
	<cfcatch type="database">
		<cfif session.pbt_PREF_SOUND>
			<BGSOUND SRC="../media/doh.wav">
		</cfif>
		<cfoutput>
			#arg_FISEC#
        	<CF_FetchError Error_Code = "SDDC270002" ThisDatasource="#THIS.DSN#" Template_Name = "#CGI.PATH_INFO#" Fatal_Error = "Yes">
        </cfoutput>
        <br><br>
        <cfinclude template = "../templates/footer.cfm">
        <cfabort>
	</cfcatch>
</cftry>