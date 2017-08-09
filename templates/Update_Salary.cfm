	<!--- re-calculate salaries --->
	<CFQUERY Name="q_Get_CalcLine" datasource="#THIS.DSN#">
		SELECT 
			IT0027,
			Start_Date,
			End_Date,
			REC_IDX
		FROM
			PEDI_PBT_DISTRIBUTION
		WHERE
			BCM_ID = #FORM.BCM_ID#
		AND
			REC_TYPE <> 1					
		AND
			FY = '#session.pbt_PREF_DEF_FY#'	
        ORDER BY
        	Start_Date,
            End_Date			
	</cfquery>
    
    <cfif IsDefined("Variables.Org_Annual_Salary")>
		<cfset Variables.ANNUAL_SALARY = Variables.Org_Annual_Salary>
    <cfelseif IsDefined("FORM.Annual_Salary")>
    	<cfset Variables.ANNUAL_SALARY = FORM.Annual_Salary>
	</cfif>
    
    <cfloop query="q_Get_CalcLine">
        <cfif q_Get_CalcLine.currentrow eq 1>
            <cfset FY_Start_Date = q_Get_CalcLine.Start_Date>
        </cfif>
        <cfset FY_End_Date = q_Get_CalcLine.End_Date>
    </cfloop>
    <cfset This_Days_In_FY = Abs(DateDiff("d",#FY_Start_Date#,#FY_End_Date#) + 1)>

	<CFLOOP Query="q_Get_CalcLine">
		<CFOUTPUT>
			<CFSCRIPT>
				Variables.REC_IDX = q_Get_CalcLine.REC_IDX;
				Variables.IT0027 = q_Get_CalcLine.IT0027;
				Variables.Start_Date = q_Get_CalcLine.Start_Date;
				Variables.End_Date = q_Get_CalcLine.End_Date;
				Days_In_Period = Abs(DateDiff("d",Variables.Start_Date,Variables.End_Date) + 1);
				Annual_Daily_Salary = variables.NEW_ANNUAL_SALARY / THIS.Days_In_FY;
				//-- Variables.Salary = ((Variables.IT0027 * Annual_Daily_Salary * Days_In_Period) / 100); --//
				Variables.Salary = round(NumberFormat(((Variables.IT0027 * (Variables.ANNUAL_SALARY / This_Days_In_FY) * Abs(DateDiff("d",#Variables.Start_Date#,#Variables.End_Date#) + 1)) / 100),'999999.00'));
				Variables.Emp_Status = 3;
			</CFSCRIPT>
		</CFOUTPUT> 
		
		<CFQUERY NAME="ReCalc_Salary" datasource="#THIS.DSN#">
			UPDATE 
				PEDI_PBT_DISTRIBUTION
			SET	
				Salary = #Variables.Salary#,
				Validated = 0
			WHERE
				REC_IDX = #Variables.REC_IDX#
			AND
				REC_TYPE <> 1
		</CFQUERY>
	</CFLOOP> 
	<!--- end re-calc salaries --->

	<CFOUTPUT>
	<H1 align = "center">Record Updated for <cfif IsDefined("FORM.Name")>#FORM.Name#<cfelse>#variables.Name#</cfif></h1>
	</cfoutput>
