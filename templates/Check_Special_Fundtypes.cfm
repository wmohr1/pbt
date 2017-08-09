<!--- Check for special Fundcenter Types --->
<!--- Initialize Special Types: --->
<CFSCRIPT>
	IsForecast = 0;
	IsTCH = 0;
	IsDefault = 0;
</CFSCRIPT>

<CFSWITCH expression = "#Right(Left(Variables.Fundcenter,10),3)#">
	<CFCASE value = "100">
		<CFSET Variables.IsDefault = 1>
	</CFCASE>
      <CFCASE value="099,199,299,399,499,599">
		<cfif session.pbt_PREF_DEF_FY LT 2018>
          <cfif Left(variables.Fundcenter,3) IS "253" OR left(variables.Fundcenter,3) is "890">
              <CFSET IsForecast = 1>
              
               <cfif len(trim(variables.Forecast_Description)) LT 2>
                 	 <cfif IsDefined("l_Error_Msg")>
	                     <cfset l_Error_Msg = ListAppend(l_Error_Msg,900)>
                     <cfelse>
                     	<cfset l_Error_Msg = 900>
                     </cfif>
               </cfif>
              <CFQUERY NAME="q_Lookup_Forecast_in_q_Get_Distribution" datasource="#THIS.DSN#">
                SELECT
                    Forecast_FC_ID,
                    Forecast_Description
                FROM
                    PEDI_PBT_DISTRIBUTION
                WHERE
                    Fundcenter = '#variables.Fundcenter#'
                AND
                    FY = '#session.pbt_PREF_DEF_FY#'				
                GROUP BY
                    Forecast_Description,Forecast_FC_ID
                ORDER BY
                    Forecast_Description,Forecast_FC_ID
              </CFQUERY>
			  
          </cfif>
          </cfif>
     </CFCASE>
</CFSWITCH>

<!--- New Part to test for TCH Accounts --->
<cfif left(right(variables.Fundcenter,3),1) IS "6" and right(variables.Fundcenter,3) IS NOT "675">
	<!--- Query COA to see if CUST NO is TCH --->
    <cfquery name="q_CheckForTCHCustNo" datasource="#THIS.DSN#">
    	SELECT
        	CUSTOMER_NO
        FROM
        	PEDI_PBT_COA
        WHERE
        	FUNDCENTER = '#variables.Fundcenter#'
    </cfquery>
    
    <cfloop query="q_CheckForTCHCustNo">
    	<cfif LEN(q_CheckForTCHCustNo.CUSTOMER_NO) GT 1 and find(q_CheckForTCHCustNo.CUSTOMER_NO,THIS.l_TCH_Cust_nos)>
        	<CFSET Variables.IsTCH = 1>
			<cfif len(trim(variables.TCH_FC_ID)) LT 2>
                <cfif IsDefined("l_Error_Msg")>
                    <cfset l_Error_Msg = ListAppend(l_Error_Msg,110)>
                <cfelse>
                   <cfset l_Error_Msg = 110>
                </cfif>
            </cfif>
            <CFQUERY NAME="q_Lookup_TCH" datasource="#THIS.DSN#">
                SELECT
                    TCH_FC_ID
                FROM
                    PEDI_PBT_DISTRIBUTION
                WHERE
                    substr(Fundcenter,1,5) = '#left(variables.Fundcenter,5)#'
                AND
                    TCH_FC_ID <> '0'
                AND
                    FY = '#session.pbt_PREF_DEF_FY#'			
                GROUP BY
                    TCH_FC_ID
                ORDER BY
                    TCH_FC_ID
            </CFQUERY>
        </cfif>
	</cfloop>
</cfif>