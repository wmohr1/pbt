<!---  
TEMPLATE NAME: Log_Distribution.cfm
CREATION DATE: ?? (2010 or earlier)
AUTHOR: Bill Mohr (832.824.6736)
LAST MODIFIED: 11/8/2016
MODIFIED BY: Bill Mohr (832.824.6736)

SUMMARY:  This template records changes to cost/effort distribution and updates AF to reflect that changes have been made.

SPECIAL NOTES:
11/08/2016: Added an update query to set PEDI_PBT_AF.BUDGET_STATUS = "AVAILABLE IN PROCESS" whenever changes are made.
--->

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
		REC_IDX = #Variables.REC_IDX#
</cfquery>

<!--- Testing
<cfoutput>  
	Log_Distribution.cfm<br />                      
	#Variables.MOD_ACTION#: #Variables.REC_IDX#
	<cfdump var="#q_GetLogInfo#">
</cfoutput>
<cfabort> --->
<cfloop query="q_GetLogInfo">
	<cfif right(q_GetLogInfo.FUNDCENTER,3) IS NOT "100">
		<!--- Check if this fundcenter is available in AF --->
        <cfquery name="q_CheckAF" datasource="#THIS.DSN#">
            SELECT
                FUNDCENTER
            FROM
                PEDI_PBT_AF
            WHERE
                FUNDCENTER = '#q_GetLogInfo.FUNDCENTER#'
            AND
                FY = '#session.pbt_PREF_DEF_FY#'        	
        </cfquery>
        
        <cfif q_CheckAF.Recordcount GT 0> 
            <!--- Update AF to reflect fundcenter is in process --->
            <CFQUERY NAME="Update_AF" datasource="#THIS.DSN#">
                 UPDATE 
                     PEDI_PBT_AF
                 SET
                     BUDGET_STATUS = 'AVAILABLE IN PROCESS',
                     AF_UPDATED_DATE = sysdate,
                     AF_UPDATED_BY = '#SESSION.pbt_THISUSER#'
                 WHERE
                     Fundcenter='#q_GetLogInfo.FUNDCENTER#'
                 AND
                     FY = '#session.pbt_PREF_DEF_FY#'				
            </CFQUERY>	
        <cfelse>
            <cfquery name="q_ActivateAF" datasource="#THIS.DSN#">
               INSERT INTO
                 PEDI_PBT_AF
                    (FUNDCENTER,
                    AF_UPDATED_DATE,
                    AF_UPDATED_BY,
                    BUDGET_STATUS,
                    FY)
               VALUES
                    ('#q_GetLogInfo.FUNDCENTER#',
                    SYSDATE,
                    '#session.pbt_THISUSER#',
                   'AVAILABLE IN PROCESS',
                   '#session.pbt_PREF_DEF_FY#')
            </cfquery>
        </cfif>
    </cfif>

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
				MOD_DATE,
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
				#CreateODBCDateTime(NOW())#,
				'#session.pbt_THISUSER#',
				'#Variables.MOD_ACTION#',
				'#q_GetLogInfo.FY#')
	</cfquery>
</cfloop>