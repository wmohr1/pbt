<cfquery name="q_GetLogInfo" datasource="#THIS.DSN#">
	SELECT
		*
	FROM
		<cfif session.pbt_archiver>
            PEDI_PBT_DISTRIBUTION_2011_SUB
        <cfelse>
            PEDI_PBT_DISTRIBUTION
        </cfif>
	WHERE 
		BCM_ID = '#Variables.bcm_id#'
</cfquery>
<cfloop query="q_GetLogInfo">
	<cfquery name="q_LogTransaction" datasource="#THIS.DSN#">
		INSERT INTO
			PEDI_PBT_DISTRIBUTION_LOG
				(REC_TYPE,
				BCM_ID,
				FUNDCENTER,
				DESCRIPTION,
				<cfif IsDefined("q_GetLogInfo.FORECAST_FC_ID") and len(trim(q_GetLogInfo.FORECAST_FC_ID)) GT 0>FORECAST_FC_ID,</cfif>
				<cfif IsDefined("q_GetLogInfo.FORECAST_DESCRIPTION") and len(trim(q_GetLogInfo.FORECAST_DESCRIPTION)) GT 0>FORECAST_DESCRIPTION,</cfif>
				<cfif IsDefined("q_GetLogInfo.TCH_FC_ID") and len(trim(q_GetLogInfo.TCH_FC_ID)) GT 0>TCH_FC_ID,</cfif>
				<cfif IsDefined("q_GetLogInfo.TCH_RESTRICTED") and len(trim(q_GetLogInfo.TCH_RESTRICTED)) GT 0>TCH_RESTRICTED,</cfif>
				BUS_AREA,
				IT0027,
				SALARY,
				<cfif IsDefined("q_GetLogInfo.FB_AMT") and len(trim(q_GetLogInfo.FB_AMT)) GT 0>FB_AMT,</cfif>
				START_DATE,
				END_DATE,
				<cfif IsDefined("q_GetLogInfo.NTG_ALTERNATE") and len(trim(q_GetLogInfo.NTG_ALTERNATE)) GT 0>NTG_ALTERNATE,</cfif>
				LOCKED,
				IT9027,
				<cfif IsDefined("q_GetLogInfo.COMPANY_CD") and len(trim(q_GetLogInfo.COMPANY_CD)) GT 0>COMPANY_CD,</cfif>
				<cfif IsDefined("q_GetLogInfo.ACCT_TYPE") and len(trim(q_GetLogInfo.ACCT_TYPE)) GT 0>ACCT_TYPE,</cfif>
				<cfif IsDefined("q_GetLogInfo.INTERNAL_ORDER") and len(trim(q_GetLogInfo.INTERNAL_ORDER)) GT 0>INTERNAL_ORDER,</cfif>
				<cfif IsDefined("q_GetLogInfo.NTG") and len(trim(q_GetLogInfo.NTG)) GT 0>NTG,</cfif>
				VALIDATED,
				<cfif IsDefined("q_GetLogInfo.MOD_DATE") and q_GetLogInfo.MOD_DATE GT 0>MOD_DATE,</cfif>
				MOD_USERNAME,
				MOD_ACTION,
				FY)
			VALUES
				(#q_GetLogInfo.REC_TYPE#,
				'#q_GetLogInfo.BCM_ID#',
				'#q_GetLogInfo.FUNDCENTER#',
				'#q_GetLogInfo.DESCRIPTION#',
				<cfif IsDefined("q_GetLogInfo.FORECAST_FC_ID") and len(trim(q_GetLogInfo.FORECAST_FC_ID)) GT 0>#q_GetLogInfo.FORECAST_FC_ID#,</cfif>
				<cfif IsDefined("q_GetLogInfo.FORECAST_DESCRIPTION") and len(trim(q_GetLogInfo.FORECAST_DESCRIPTION)) GT 0>'#q_GetLogInfo.FORECAST_DESCRIPTION#',</cfif>
				<cfif IsDefined("q_GetLogInfo.TCH_FC_ID") and len(trim(q_GetLogInfo.TCH_FC_ID)) GT 0>'#q_GetLogInfo.TCH_FC_ID#',</cfif>
				<cfif IsDefined("q_GetLogInfo.TCH_RESTRICTED") and len(trim(q_GetLogInfo.TCH_RESTRICTED)) GT 0>#q_GetLogInfo.TCH_RESTRICTED#,</cfif>
				#q_GetLogInfo.BUS_AREA#,
				#q_GetLogInfo.IT0027#,
				#q_GetLogInfo.SALARY#,
				<cfif IsDefined("q_GetLogInfo.FB_AMT") and len(trim(q_GetLogInfo.FB_AMT)) GT 0>#q_GetLogInfo.FB_AMT#,</cfif>
				#CreateODBCDate(q_GetLogInfo.START_DATE)#,
				#CreateODBCDate(q_GetLogInfo.END_DATE)#,
				<cfif IsDefined("q_GetLogInfo.NTG_ALTERNATE") and len(trim(q_GetLogInfo.NTG_ALTERNATE)) GT 0>'#q_GetLogInfo.NTG_ALTERNATE#',</cfif>
				#q_GetLogInfo.LOCKED#,
				#q_GetLogInfo.IT9027#,
				<cfif IsDefined("q_GetLogInfo.COMPANY_CD") and len(trim(q_GetLogInfo.COMPANY_CD)) GT 0>'#q_GetLogInfo.COMPANY_CD#',</cfif>
				<cfif IsDefined("q_GetLogInfo.ACCT_TYPE") and len(trim(q_GetLogInfo.ACCT_TYPE)) GT 0>'#q_GetLogInfo.ACCT_TYPE#',</cfif>
				<cfif IsDefined("q_GetLogInfo.INTERNAL_ORDER") and len(trim(q_GetLogInfo.INTERNAL_ORDER)) GT 0>'#q_GetLogInfo.INTERNAL_ORDER#',</cfif>
				<cfif IsDefined("q_GetLogInfo.NTG") and len(trim(q_GetLogInfo.NTG)) GT 0>#q_GetLogInfo.NTG#,</cfif>
				#q_GetLogInfo.VALIDATED#,
				<cfif IsDefined("q_GetLogInfo.MOD_DATE") and q_GetLogInfo.MOD_DATE GT 0>#CreateODBCDateTime(q_GetLogInfo.MOD_DATE)#,</cfif>
				'#q_GetLogInfo.MOD_USERNAME#',
				'#Variables.MOD_ACTION#',
				'#q_GetLogInfo.FY#')
	</cfquery>
</cfloop>