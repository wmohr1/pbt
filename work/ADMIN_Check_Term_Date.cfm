<cfquery name = "q_Get_COA_FULL" datasource = "#THIS.DSN#">
	SELECT
		Fundcenter
	FROM
		PEDI_PBT_COA_FULL
	WHERE
		TERM_DATE >= #THIS.FY_Start_Date#
</cfquery>

<CFLOOP Query = "q_Get_COA_FULL">
	<cfscript>
		ThisFundcenter = q_Get_COA_FULL.Fundcenter;
	</cfscript>
	<cfquery name="q_Check_COA" datasource = "#THIS.DSN#">
		SELECT
			FUNDCENTER
		FROM
			PEDI_PBT_COA
		WHERE
			Fundcenter = '#ThisFundcenter#'
	</cfquery>
	
	<cfif q_Check_COA.RecordCount EQ 0>
		<CFOUTPUT query = "q_Check_COA">
			#q_Check_COA.Fundcenter# <br>
		</CFOUTPUT>
	</cfif>	
</CFLOOP>