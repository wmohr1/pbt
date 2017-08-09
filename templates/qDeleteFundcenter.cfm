<cfif IsDefined("FORM.REC_IDX")>
	<cfset ThisOne = FORM.REC_IDX>
</cfif>

<cfset Variables.REC_IDX = ThisOne>
<cfset Variables.MOD_ACTION = "DELETED">
<cfinclude template="../templates/Log_Distribution.cfm">

<CFQUERY NAME="qDeleteFundcenter" datasource = "#THIS.DSN#">
	DELETE FROM
		PEDI_PBT_DISTRIBUTION
	WHERE
		REC_IDX = #ThisOne#
</CFQUERY>