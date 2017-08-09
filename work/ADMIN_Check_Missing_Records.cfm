<cfquery name = "q_Get_Distribution" datasource = "#THIS.DSN#">
	SELECT
		Fundcenter,
		Bus_Area,
		REC_IDX,
		BCM_ID
	FROM
		PEDI_PBT_DISTRIBUTION
	WHERE
		substr(Fundcenter,8,1) < 6
	AND
		substr(Fundcenter,8,1) > 2
	AND
		FY = '#session.pbt_PREF_DEF_FY#'				
</cfquery>

<CFLOOP Query = "q_Get_Distribution">
	<cfscript>
		ThisFundcenter = q_Get_Distribution.Fundcenter;
		ThisBusArea = q_Get_Distribution.Bus_Area;
		ThisRecIDX = q_Get_Distribution.Rec_IDX;
		ThisBCMID = q_Get_Distribution.BCM_ID;
	</cfscript>
	<cfquery name="q_Check_COA" datasource = "#THIS.DSN#">
		SELECT
			BUS_AREA
		FROM
			PEDI_PBT_COA
		WHERE
			Fundcenter = '#ThisFundcenter#'
	</cfquery>
	
	<CFOUTPUT query = "q_Check_COA">
		<CFIF q_Check_COA.Bus_Area NEQ ThisBusArea>
			#ThisBCMID#,#ThisFundcenter#,#ThisBusArea#,#q_Check_COA.Bus_Area#,#ThisRecIDX#<br>
			
			<cfset COA_Bus_Area = q_Check_COA.Bus_Area>
			
			<cfquery name = "q_Fix_BA" datasource = "#THIS.DSN#">
				UPDATE
					PEDI_PBT_DISTRIBUTION
				SET
					BUS_AREA = #COA_Bus_Area#
				WHERE 
					REC_IDX = #ThisRecIDX#
			</cfquery>
		</CFIF>
	</CFOUTPUT>
</CFLOOP>