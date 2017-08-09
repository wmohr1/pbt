    <cftry>
    	<cfset SkipIt = 0>

        <cfif session.pbt_PREF_DEF_FY EQ THIS.FY>
            <cfquery name="q_GetThisInfo" datasource="#THIS.DSN#">
                SELECT 
                    DESCRIPTION,
                    BP_START_DATE,
                    TERM_DATE,
                    SAL_CAP_REQUIRED,
                    BUS_AREA,
                    FUND_TYPE
                FROM 
                    PEDI_PBT_COA
                WHERE 
                    FUNDCENTER = '#arg_FUNDCENTER#'
            </cfquery>
            <cfoutput query="q_GetThisInfo">
                <cfscript>
                    spp_DESCRIPTION = q_GetThisInfo.DESCRIPTION;
                    spp_START_DATE = q_GetThisInfo.BP_START_DATE;
                    spp_TERM_DATE = q_GetThisInfo.TERM_DATE;
                    spp_SAL_CAP_REQUIRED = q_GetThisInfo.SAL_CAP_REQUIRED;
                    spp_BUS_AREA = q_GetThisInfo.BUS_AREA;
					spp_FUND_TYPE = q_GetThisInfo.FUND_TYPE;
                </cfscript>
            </cfoutput>
        <cfelse>
            <cfquery name="q_GetThisInfo" datasource="#THIS.DSN#">
                SELECT 
                    DESCRIPTION,
                    TERM_DATE,
                    BP_START_DATE,
                    SAL_CAP_REQUIRED,
                    BUS_AREA
                FROM 
                    PEDI_PBT_COA_FULL
                WHERE 
                    FUNDCENTER = '#arg_FUNDCENTER#'
            </cfquery>
            <cfoutput query="q_GetThisInfo">
                <cfscript>
                    spp_DESCRIPTION = q_GetThisInfo.DESCRIPTION;
                    spp_START_DATE = q_GetThisInfo.BP_START_DATE;
                    spp_TERM_DATE = q_GetThisInfo.TERM_DATE;
                    spp_SAL_CAP_REQUIRED = q_GetThisInfo.SAL_CAP_REQUIRED;
                    spp_BUS_AREA = q_GetThisInfo.BUS_AREA;
                </cfscript>
            </cfoutput>
            <cfif IsForecast>
				<cfscript>
                    spp_SAL_CAP_REQUIRED = THIS.Sal_Cap_Required;
                    spp_BUS_AREA = arg_BUS_AREA;
                </cfscript>
			</cfif>
        </cfif>
        <cfcatch type="database">
			<cfset SkipIt = 1>
            <cfset l_Error_Msg = ListAppend(l_Error_Msg,800)>
            <cfset ThisBadTermDate = THIS.FY_Start_Date>
            <cfset THISBADGRANT = arg_Fundcenter>
            <CFSET Validate = 0>
        </cfcatch>
    </cftry>