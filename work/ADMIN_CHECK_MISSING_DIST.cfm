<cfquery name = "q_Get_Entire_Section" datasource = "#THIS.DSN#">
	SELECT
		HOME_DEPT_DESC,
		LAST_NAME,
		FIRST_NAME,
		BCM_ID
	FROM         
		PEDI_PBT_HEADERS
	WHERE
		NEW_HIRE <> 1
	AND
		REC_TYPE = 1
	AND
		FY = '#session.pbt_PREF_DEF_FY#'			
</cfquery>

<table>
	<tr>
		<th>SECTION</th>
		<th>BCM_ID</th>
		<th>First_Name</th>
		<th>Last_Name</th>
	</tr>
	<cfloop query = "q_Get_Entire_Section">
		<cfset Variables.bcm_id = q_Get_Entire_Section.bcm_id>
		<cfset Variables.First_Name = q_Get_Entire_Section.First_Name>
		<cfset Variables.Last_Name = q_Get_Entire_Section.Last_Name>
		<cfset Variables.HOME_DEPT_DESC = q_Get_Entire_Section.HOME_DEPT_DESC>
		<cfquery name = "q_Get_dist" datasource = "#THIS.DSN#">
			SELECT
				BCM_ID
			FROM
				PEDI_PBT_DISTRIBUTION
			WHERE
				REC_TYPE = 1 
			AND
				BCM_ID = #Variables.BCM_ID#
			AND
				FY = '#session.pbt_PREF_DEF_FY#'			
		</cfquery>

		<cfif q_Get_dist.RecordCount EQ 0>
			<CFOUTPUT>
				<tr>
					<td>#Variables.HOME_DEPT_DESC#</td>
					<td>#Variables.BCM_ID#</td>
					<td>#Variables.First_Name#</td>
					<td>#Variables.Last_Name#</td>
				</tr>
			</CFOUTPUT>
		</cfif>
	</cfloop>
</table>