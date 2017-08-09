<CFIF NOT IsDefined("FORM.JOB_CODE") OR FORM.JOB_CODE EQ "">
	<CFSET Error_Code = THIS.Error_Ap&"LG220001">
	<CF_FetchError Error_Code = #Error_Code# ThisDatasource="#THIS.DSN#" Template_Name = #CGI.PATH_INFO# fatal_error = "yes">
</CFIF>

<cfquery name = "q_GetDesc" datasource = "#THIS.DSN#">
	SELECT Job_Code_Desc
	FROM PEDI_PBT_JOB_CODES
	WHERE JOB_CODE = '#FORM.JOB_CODE#'
</cfquery>
<cfoutput query="q_GetDesc">
	<cfset variables.JOB_CODE_DESC = q_GetDesc.JOB_CODE_DESC>
</cfoutput>
<!--- Convert FORM variables to local variables --->
<cfif IsDefined("FORM.JOB_CODE")>
	<cfset variables.Job_Code = FORM.JOB_CODE>
</cfif>
<cfif IsDefined("FORM.Eff_Date")>
	<cfset variables.Eff_Date = FORM.Eff_Date>
</cfif>
<cfif IsDefined("FORM.EMP_GROUP")>
	<cfset variables.EMP_GROUP = FORM.EMP_GROUP>
</cfif>
<cfif IsDefined("FORM.EMP_SUBGROUP")>
	<cfset variables.EMP_SUBGROUP = FORM.EMP_SUBGROUP>
</cfif>
<cfif IsDefined("FORM.PERS_SUBAREA")>
	<cfset variables.PERS_SUBAREA = FORM.PERS_SUBAREA>
</cfif>
<cfif IsDefined("FORM.FTE")>
	<cfset variables.FTE = FORM.FTE>
</cfif>

<CFINCLUDE Template="../templates/CheckGroups.cfm">

<CFSCRIPT>
	//-- GO assumes there are no data inconsistencies --//
	GO = 1; 	
	FTE_Change = 0;
	Violation = 0;
	//-- Variables.New_Hire = 0; (Removed this as it was causing trouble --//
</CFSCRIPT>

<cfif IsDefined("Form.Eff_Date_Year")>
	<cfset Variables.Eff_Date = CreateDate(Form.Eff_Date_Year, Form.Eff_Date_Month, Form.Eff_Date_Day)>
    <cfif Variables.Eff_Date LT THIS.FY_Start_Date>
    	<CFSET Error_Code = THIS.Error_Ap&"PL270022">
        <CFOUTPUT>
			<CF_FetchError Error_Code = #Error_Code# ThisDatasource="#THIS.DSN#" Template_Name = #CGI.PATH_INFO# fatal_error = "yes">
        </CFOUTPUT>
    <cfelseif Variables.Eff_Date GT THIS.FY_End_Date>>
    	<CFSET Error_Code = THIS.Error_Ap&"PL270022">
        <CFOUTPUT>
			<CF_FetchError Error_Code = #Error_Code# ThisDatasource="#THIS.DSN#" Template_Name = #CGI.PATH_INFO# fatal_error = "yes">
        </CFOUTPUT>
    </cfif>
</cfif>

<cfquery name="q_GetClass" datasource="#THIS.DSN#">
	SELECT 
    	EMP_CLASS
    FROM
    	PEDI_PBT_JOB_CODES
    WHERE
    	JOB_CODE = '#variables.Job_Code#'
</cfquery>

<cfoutput query="q_GetClass">
	<cfset EMP_CLASS = q_GetClass.EMP_CLASS>
</cfoutput>

<CFIF NOT IsDefined("Variables.EMP_GROUP") OR Variables.EMP_GROUP EQ 0>
	<CFSET Error_Code = THIS.Error_Ap&"LG220002">
	<cfoutput><CF_FetchError Error_Code = "#Error_Code#" ThisDatasource="#THIS.DSN#" Template_Name = "#CGI.PATH_INFO#" fatal_error = "yes"></cfoutput>
</CFIF>

<CFIF NOT IsDefined("Variables.EMP_SUBGROUP") OR Variables.EMP_SUBGROUP EQ 0>
	<CFSET Error_Code = THIS.Error_Ap&"LG220003">
	<cfoutput><CF_FetchError Error_Code = "#Error_Code#" ThisDatasource="#THIS.DSN#" Template_Name = "#CGI.PATH_INFO#" fatal_error = "yes"></cfoutput>
</CFIF>

<CFIF NOT IsDefined("Variables.PERS_SUBAREA") OR Variables.PERS_SUBAREA EQ 0>
	<CFSET Error_Code = THIS.Error_Ap&"LG220004">
	<cfoutput><CF_FetchError Error_Code = "#Error_Code#" ThisDatasource="#THIS.DSN#" Template_Name = "#CGI.PATH_INFO#" fatal_error = "yes"></cfoutput>
</CFIF>

<!--- BELOW ARE SOME RULES THAT MUST BE FOLLOWED WHEN MAKING CHANGES TO EMPLOYEES --->		
<!--- Class must match Personnel SubArea Selection --->
<cfoutput>
	<CFSWITCH expression = #Trim(EMP_CLASS)#>
		<CFCASE value = "FACULTY">
			<CFIF Variables.Pers_SubArea GT 3><CFSET GO = 0><CFSET Error_Code = THIS.Error_Ap&"PL270010"></CFIF>
		</CFCASE>
		<CFCASE value = "FELLOW">
			<CFIF Variables.Pers_SubArea LT 12>
				<cfif Variables.Pers_SubArea NEQ 8>
					<CFSET GO = 0><CFSET Error_Code = THIS.Error_Ap&"PL270010">
				</CFIF>
            </CFIF>
		</CFCASE>
		<CFCASE value = "STAFF">
			<CFIF (Variables.Pers_SubArea LT 4 OR Variables.Pers_SubArea GT 13) AND Variables.Job_Code IS NOT "8109"><CFSET GO = 0><CFSET Error_Code = THIS.Error_Ap&"PL270010"></CFIF>
		</CFCASE>						
	</CFSWITCH>
</cfoutput>

<!--- FT FTE must be 100%, PT FTE cannot be 100% --->
<CFIF Variables.EMP_SUBGROUP IS "U1" AND variables.FTE LT 100>
	<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270001">
<CFELSEIF Variables.EMP_SUBGROUP IS "U2" AND variables.FTE LT 100>	
	<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270001">
<CFELSEIF Variables.EMP_SUBGROUP IS "U5" AND variables.FTE LT 100>	
	<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270001">
<CFELSEIF Variables.EMP_SUBGROUP IS "U3" AND variables.FTE EQ 100>	
	<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270001">
<CFELSEIF Variables.EMP_SUBGROUP IS "U4" AND variables.FTE EQ 100>	
	<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270001">
<CFELSEIF Variables.EMP_SUBGROUP IS "U6" AND variables.FTE EQ 100>	
	<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270001">
</CFIF>
	
	<!--- Indep. Contractors are considered NON-PAID --->
	<cfif Variables.Emp_Group EQ 7 AND Variables.EMP_SUBGROUP IS NOT "U7">
		<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270002">
	</cfif>
	
	<!--- All Faculty are EXEMPT --->
	<CFIF EMP_CLASS IS "FACULTY" AND Variables.EMP_SUBGROUP IS "U2">
		<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270003">
	<CFELSEIF EMP_CLASS IS "FACULTY" AND Variables.EMP_SUBGROUP IS "U4">
		<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270003">
	</CFIF>
	
	<CFIF EMP_CLASS IS "FACULTY">
		<CFSET Variables.Exempt_Indicator = "Exempt">
	</CFIF>

	<!--- All Staff that are Salary are StaffR --->				
	<CFIF EMP_CLASS IS "STAFF">
    	<CFIF FIND("DIR",variables.JOB_CODE_DESC) EQ 0>
			<CFIF Variables.EMP_SUBGROUP IS "U1" AND Variables.Pers_SubArea NEQ 5 AND Variables.Job_Code IS NOT "8109" AND Variables.Job_Code IS NOT "4270" AND Variables.Job_Code IS NOT "4424">
                <CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270004">
            <CFELSEIF Variables.EMP_SUBGROUP IS "U2" AND Variables.Pers_SubArea NEQ 5>				
                <CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270004">
            <CFELSEIF Variables.EMP_SUBGROUP IS "U3" AND Variables.PERS_SUBAREA  NEQ 5 AND Variables.Job_Code IS NOT "8206">
                <CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270004">
            <CFELSEIF Variables.EMP_SUBGROUP IS "U4" AND Variables.Pers_SubArea NEQ 5>						
                <CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270004">
            </CFIF>
        </CFIF>
	</CFIF>
	
	<!--- Faculty0 is Hourly Faculty or Voluntary --->
	<CFIF Variables.Pers_SubArea EQ 1 AND Variables.EMP_SUBGROUP IS "U1">
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270005">
	<CFELSEIF Variables.Pers_SubArea EQ 1 AND Variables.EMP_SUBGROUP IS "U2">
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270005">
	<CFELSEIF Variables.Pers_SubArea EQ 1 AND Variables.EMP_SUBGROUP IS "U3">
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270005">
	<CFELSEIF Variables.Pers_SubArea EQ 1 AND Variables.EMP_SUBGROUP IS "U4">
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270005">
	</CFIF> 

	<!--- Faculty1 are FT Associate Professors or FT Professors --->
	<CFIF Variables.Pers_SubArea EQ 2 AND VAL(Variables.FTE) NEQ 100>
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270006">
	<CFELSEIF Variables.Pers_SubArea EQ 2>
			<CFIF Left(Variables.JOB_CODE,4) IS NOT "1202" AND Left(Variables.JOB_CODE,4) IS NOT "120210" AND Left(Variables.JOB_CODE,4) IS NOT "120220" AND Left(Variables.JOB_CODE,4) IS NOT "1212" AND Left(Variables.JOB_CODE,4) IS NOT "121210" AND Left(Variables.JOB_CODE,4) IS NOT "121220" AND Left(Variables.JOB_CODE,4) IS NOT "121230" AND Left(Variables.JOB_CODE,4) IS NOT "121240" AND Left(FORM.JOB_CODE,4) IS NOT "1299" AND Left(FORM.JOB_CODE,4) IS NOT "1102" AND Left(FORM.JOB_CODE,4) IS NOT "1305" AND Left(FORM.JOB_CODE,4) IS NOT "1280">
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270006">
		</cfif>
	</CFIF>
	
	<!--- Faculty2 is instructor, asst professor, PT assoc professors or PT professors --->
	<CFIF Variables.Pers_SubArea EQ 3>
		<CFIF Left(Variables.JOB_CODE,4) IS "1222">
		<CFELSEIF Left(Variables.JOB_CODE,4) IS "1232">
		<CFELSEIF Left(Variables.JOB_CODE,4) IS "1235">
		<CFELSEIF Left(Variables.JOB_CODE,4) IS "1299">
		<CFELSEIF Left(Variables.JOB_CODE,4) IS "1102">
		<CFELSEIF Left(Variables.JOB_CODE,4) IS "1242">
		<CFELSEIF Left(Variables.JOB_CODE,4) IS "1252">
		<CFELSEIF Left(Variables.JOB_CODE,4) IS "1262">
		<CFELSEIF Variables.FTE LT 100>
			<CFIF Left(Variables.JOB_CODE,4) IS NOT "1202" AND Left(Variables.JOB_CODE,4) IS NOT "1212" AND Left(FORM.JOB_CODE,4) IS NOT "1299" AND Left(FORM.JOB_CODE,4) IS NOT "1102" AND Left(FORM.JOB_CODE,4) IS NOT "1305" AND Left(FORM.JOB_CODE,4) IS NOT "1280" AND Left(FORM.JOB_CODE,4) IS NOT "1242">
				<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270007">
			</cfif>	
		<CFELSE>
				<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270007">
		</CFIF>	
	</CFIF>

	<!--- PDocs have specific JOB_CODEs --->		
	<CFIF Variables.Pers_SubArea EQ 13 AND Left(Variables.JOB_CODE,4) IS NOT "8105">
		<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270008">
	<CFELSEIF Variables.Pers_SubArea EQ 14 AND Left(Variables.JOB_CODE,4) IS NOT "8106">
		<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270008">
	<CFELSEIF Variables.Pers_SubArea EQ 15>
		<CFIF Left(Variables.JOB_CODE,4) IS NOT "8107" AND Left(Variables.JOB_CODE,4) IS NOT "8109" AND Left(Variables.JOB_CODE,4) IS NOT "4424">
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270008">
		</CFIF>
	</CFIF>
	
	<!--- Staff0 is HOURLY Staff --->		
	<CFIF Variables.Pers_SubArea EQ 4 AND Variables.EMP_SUBGROUP IS "U5">
	<CFELSEIF Variables.Pers_SubArea EQ 4 AND Variables.EMP_SUBGROUP IS "U6">	
	<CFELSEIF Variables.Pers_SubArea EQ 4>
		<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270009">
	<CFELSE>
	</CFIF>
	
	<CFIF ListContains(("U2,U4,U5,U6,U7"), Variables.EMP_SUBGROUP) NEQ 0>
		<cfset Variables.EXEMPT_INDICATOR = "Non-Exempt">
	<CFELSEIF ListContains(("U1,U3"), Variables.EMP_SUBGROUP) NEQ 0>
		<cfset Variables.EXEMPT_INDICATOR = "Exempt">
	</CFIF>
    
    <cfif Variables.EXEMPT_INDICATOR IS "Exempt" AND FORM.ANNUAL_SALARY LT THIS.Exempt_Minimum>
		<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL260002">
	</cfif>