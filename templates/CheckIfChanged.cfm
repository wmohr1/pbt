<!--- Modified 01/26/2007:  Bill Jones found that could not copy block on a new employee with a type 3 header record.  Modified "Get_Increase" query to order by REC_TYPE to fix.  --->

<!--- Check to see if anything has really changed or not --->
<CFQUERY NAME="Get_RAW" datasource="#THIS.DSN#">
	SELECT      
		EMP_GROUP,
		EMP_SUBGROUP,
		PERS_SUBAREA,
		ANNUAL_SALARY,
		FTE
	FROM         
		PEDI_PBT_HEADERS
	WHERE
		BCM_ID = #FORM.BCM_ID#
	AND
		REC_TYPE = 1
	AND
		FY = '#session.pbt_PREF_DEF_FY#'
</cfquery>

<CFQUERY NAME="Get_Increase" datasource="#THIS.DSN#">
	SELECT      
		ANNUAL_SALARY,
		New_Hire,
		FTE,
		EMP_GROUP,
		EMP_SUBGROUP,
		PERS_SUBAREA,
		INC_PERCENT
	FROM         
		PEDI_PBT_HEADERS
	WHERE
		BCM_ID = #FORM.BCM_ID#
	AND
		FY = '#session.pbt_PREF_DEF_FY#'
    AND 
    	REC_TYPE <> 1
	Order By
		REC_TYPE
</cfquery>

<CFOUTPUT Query="Get_Increase" maxrows=1>
	<!--- Check if Employee was Added Manually (a projected New Hire) --->
	<CFIF Get_Increase.New_Hire>
		<CFSET Variables.New_Hire = 1>
	<cfelse>
		<CFSET Variables.New_Hire = 0>
	</CFIF>
	<CFSCRIPT>
		PEDI_PBT_HEADERS_Sal = Get_Increase.ANNUAL_SALARY;
		PEDI_PBT_HEADERS_FTE = Get_Increase.FTE;
		PEDI_PBT_HEADERS_INC = Get_Increase.INC_PERCENT;
	</CFSCRIPT>
</CFOUTPUT>

<CFIF NOT Variables.New_Hire>
	<cfif IsDefined("FORM.FTE")>
		<cfset ThisFTE = FORM.FTE>
		<CFOUTPUT Query="Get_RAW">
			<CFSCRIPT>
				New_ANNUAL_SALARY = (ThisFTE / 100) * (100 / Get_RAW.FTE) * Get_RAW.ANNUAL_SALARY * (1 + (PEDI_PBT_HEADERS_INC / 100));
				//-- New_ANNUAL_SALARY = VAL(ThisFTE / Get_RAW.FTE * PEDI_PBT_HEADERS_Sal  * (1 + (PEDI_PBT_HEADERS_INC / 100))); --//
				if (ThisFTE NEQ Get_RAW.FTE)
					FTE_Change = 1;
			</CFSCRIPT>
		</cfoutput>
	<cfelse>
		<CFOUTPUT Query="Get_Increase">
			<cfset ThisFTE = Get_Increase.FTE>
			<CFSCRIPT>
				New_ANNUAL_SALARY = (ThisFTE / 100) * (100 / Get_RAW.FTE) * Get_RAW.ANNUAL_SALARY * (1 + (PEDI_PBT_HEADERS_INC / 100));
				//-- New_ANNUAL_SALARY = VAL(ThisFTE / Get_Increase.FTE * Get_Increase.ANNUAL_SALARY * (1 + (PEDI_PBT_HEADERS_INC / 100))); --//
			</CFSCRIPT>
		</cfoutput>
	</CFIF>
<cfelse>
	<cfset New_ANNUAL_SALARY = PEDI_PBT_HEADERS_Sal>
</CFIF>