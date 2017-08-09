<CFIF NOT IsDefined("FORM.JOB_CODE") OR FORM.JOB_CODE EQ "">
	<CFSET Error_Code = THIS.Error_Ap&"LG220001">
	<CF_FetchError Error_Code = #Error_Code# ThisDatasource="#THIS.DSN#" Template_Name = #CGI.PATH_INFO# fatal_error = "yes">
</CFIF>

<CFINCLUDE Template="../templates/CheckGroups.cfm">

<CFSCRIPT>
	//-- GO assumes there are no data inconsistencies --//
	GO = 1; 	
	FTE_Change = 0;
	Violation = 0;
	Variables.New_Hire = 0;
	Variables.Eff_Date = DateFormat(THIS.FY_Start_Date,"MM/DD/YYYY");
</CFSCRIPT>

<CFIF NOT IsDefined("FORM.GROUP") OR FORM.GROUP EQ 0>
	<CFSET Error_Code = THIS.Error_Ap&"LG220002">
	<CF_FetchError Error_Code = #Error_Code# ThisDatasource="#THIS.DSN#" Template_Name = #CGI.PATH_INFO# fatal_error = "yes">
</CFIF>

<CFIF NOT IsDefined("FORM.SUBGROUP") OR FORM.SUBGROUP EQ 0>
	<CFSET Error_Code = THIS.Error_Ap&"LG220003">
	<CF_FetchError Error_Code = #Error_Code# ThisDatasource="#THIS.DSN#" Template_Name = #CGI.PATH_INFO# fatal_error = "yes">
</CFIF>

<CFIF NOT IsDefined("FORM.SUBAREA") OR FORM.SUBAREA EQ 0>
	<CFSET Error_Code = THIS.Error_Ap&"LG220004">
	<CF_FetchError Error_Code = #Error_Code# ThisDatasource="#THIS.DSN#" Template_Name = #CGI.PATH_INFO# fatal_error = "yes">
</CFIF>

<!--- BELOW ARE SOME RULES THAT MUST BE FOLLOWED WHEN MAKING CHANGES TO EMPLOYEES --->		
<!--- Class must match Personnel SubArea Selection --->
<cfinclude template="../templates/set_class_benefitlvl.cfm">
<cfset EMP_CLASS = ThisClass>

<!--- FT FTE must be 100%, PT FTE cannot be 100% --->
<CFIF Variables.EMP_SUBGROUP IS "U1" AND FORM.FTE LT 100>
	<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270001">
<CFELSEIF Variables.EMP_SUBGROUP IS "U2" AND FORM.FTE LT 100>	
	<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270001">
<CFELSEIF Variables.EMP_SUBGROUP IS "U5" AND FORM.FTE LT 100>	
	<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270001">
<CFELSEIF Variables.EMP_SUBGROUP IS "U3" AND FORM.FTE EQ 100>	
	<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270001">
<CFELSEIF Variables.EMP_SUBGROUP IS "U4" AND FORM.FTE EQ 100>	
	<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270001">
<CFELSEIF Variables.EMP_SUBGROUP IS "U6" AND FORM.FTE EQ 100>	
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
	
    <cfquery name="q_CheckJCDESC" datasource="#THIS.DSN#">
    	SELECT
        	JOB_CODE_DESC
        FROM
        	PEDI_PBT_JOB_CODES
        WHERE
        	JOB_CODE = '#form.job_code#'
    </cfquery>
    
    <cfloop query="q_CheckJCDESC">
    	<cfset Variables.This_Job_Code_Desc = q_CheckJCDESC.JOB_CODE_DESC>
		<cfset CheckDirector = find("DIR",Variables.This_Job_Code_Desc)>
        <cfif CheckDirector GT 0>
        	<cfset IsaDirector = 1>
        <cfelse>
        	<cfset IsaDirector = 0>
        </cfif>
    </cfloop>
    
    <!--- All Staff that are Salary are StaffR --->				
	<CFIF EMP_CLASS IS "STAFF" AND form.job_code IS NOT "4270" AND form.job_code IS NOT "8109" and NOT IsaDirector>
		<CFIF Variables.EMP_SUBGROUP IS "U1" AND Variables.PERS_SUBAREA  NEQ 5 AND form.job_code IS NOT "4270">
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270004">
		<CFELSEIF Variables.EMP_SUBGROUP IS "U2" AND Variables.PERS_SUBAREA  NEQ 5>				
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270004">
		<CFELSEIF Variables.EMP_SUBGROUP IS "U3" AND Variables.PERS_SUBAREA  NEQ 5 AND form.job_code IS NOT "8206">
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270004">
		<CFELSEIF Variables.EMP_SUBGROUP IS "U4" AND Variables.PERS_SUBAREA  NEQ 5>						
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270004">
		</CFIF>
	</CFIF>
	
	<!--- Faculty0 is Hourly Faculty or Voluntary --->
	<CFIF Variables.PERS_SUBAREA  EQ 1 AND Variables.EMP_SUBGROUP IS "U1">
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270005">
	<CFELSEIF Variables.PERS_SUBAREA  EQ 1 AND Variables.EMP_SUBGROUP IS "U2">
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270005">
	<CFELSEIF Variables.PERS_SUBAREA  EQ 1 AND Variables.EMP_SUBGROUP IS "U3">
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270005">
	<CFELSEIF Variables.PERS_SUBAREA  EQ 1 AND Variables.EMP_SUBGROUP IS "U4">
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270005">
	</CFIF> 

	<!--- Faculty1 are FT Associate Professors or FT Professors --->
	<CFIF Variables.PERS_SUBAREA EQ 2 AND VAL(FORM.FTE) NEQ 100>
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270006">
	<CFELSEIF Variables.PERS_SUBAREA  EQ 2>
			<CFIF Left(FORM.JOB_CODE,4) IS NOT "1202" AND Left(FORM.JOB_CODE,6) IS NOT "120210" AND Left(FORM.JOB_CODE,6) IS NOT "120220" AND Left(FORM.JOB_CODE,4) IS NOT "1212" AND Left(FORM.JOB_CODE,6) IS NOT "121210" AND Left(FORM.JOB_CODE,6) IS NOT "121220" AND Left(FORM.JOB_CODE,6) IS NOT "121230" AND Left(FORM.JOB_CODE,6) IS NOT "121240" AND Left(FORM.JOB_CODE,4) IS NOT "1299" AND Left(FORM.JOB_CODE,4) IS NOT "1102" AND Left(FORM.JOB_CODE,4) IS NOT "1305" AND Left(FORM.JOB_CODE,4) IS NOT "1280">
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270006">
		</cfif>
	</CFIF>
	
	<!--- Faculty2 is instructor, asst professor, PT assoc professors or PT professors --->
	<CFIF Variables.PERS_SUBAREA  EQ 3>
		<CFIF Left(FORM.JOB_CODE,4) IS "1222">
        <CFELSEIF Left(FORM.JOB_CODE,6) IS "122230">
		<CFELSEIF Left(FORM.JOB_CODE,6) IS "122240">
		<CFELSEIF Left(FORM.JOB_CODE,4) IS "1232">
		<CFELSEIF Left(FORM.JOB_CODE,4) IS "1233">
		<CFELSEIF Left(FORM.JOB_CODE,4) IS "1235">
		<CFELSEIF Left(FORM.JOB_CODE,4) IS "1238">
		<CFELSEIF Left(FORM.JOB_CODE,4) IS "1242">
		<CFELSEIF Left(FORM.JOB_CODE,4) IS "1252">
		<CFELSEIF Left(FORM.JOB_CODE,4) IS "1262">
		<CFELSEIF Left(FORM.JOB_CODE,4) IS "1299">
		<CFELSEIF Left(FORM.JOB_CODE,4) IS "1102">
		<CFELSEIF FORM.FTE LT 100>
			<CFIF Left(FORM.JOB_CODE,4) IS NOT "1202" AND Left(FORM.JOB_CODE,4) IS NOT "120210" AND Left(FORM.JOB_CODE,4) IS NOT "120220" AND Left(FORM.JOB_CODE,4) IS NOT "1212" AND Left(FORM.JOB_CODE,6) IS NOT "121210" AND Left(FORM.JOB_CODE,6) IS NOT "121220" AND Left(FORM.JOB_CODE,6) IS NOT "121230" AND Left(FORM.JOB_CODE,6) IS NOT "121240" AND Left(FORM.JOB_CODE,4) IS NOT "1299" AND Left(FORM.JOB_CODE,4) IS NOT "1102" AND Left(FORM.JOB_CODE,4) IS NOT "1305" AND Left(FORM.JOB_CODE,4) IS NOT "1280">
				<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270007">
			</cfif>	
		<CFELSE>
				<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270007">
		</CFIF>	
	</CFIF>

	<!--- PDocs have specific JOB_CODEs --->		
	<CFIF Variables.PERS_SUBAREA  EQ 13 AND Left(FORM.JOB_CODE,4) IS NOT "8105">
		<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270008">
	<CFELSEIF Left(FORM.JOB_CODE,4) IS "8106" AND Variables.PERS_SUBAREA NEQ 14>
		<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270008">
	<CFELSEIF Variables.PERS_SUBAREA  EQ 15>
		<CFIF Left(FORM.JOB_CODE,4) IS NOT "8107" AND Left(FORM.JOB_CODE,4) IS NOT "8109" AND Left(FORM.JOB_CODE,4) IS NOT "8460" AND Left(FORM.JOB_CODE,4) IS NOT "4424">
			<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270008">
		</CFIF>
	</CFIF>
	
	<!--- Staff0 is HOURLY Staff --->		
	<CFIF Variables.PERS_SUBAREA  EQ 4 AND Variables.EMP_SUBGROUP IS "U5">
	<CFELSEIF Variables.PERS_SUBAREA  EQ 4 AND Variables.EMP_SUBGROUP IS "U6">	
	<CFELSEIF Variables.PERS_SUBAREA  EQ 4>
		<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL270009">
	<CFELSE>
	</CFIF>
	
	<CFIF ListContains(("U2,U4,U5,U6,U7"), Variables.EMP_SUBGROUP) NEQ 0>
		<cfset Variables.EXEMPT_INDICATOR = "Non-Exempt">
	<CFELSEIF ListContains(("U1,U3"), Variables.EMP_SUBGROUP) NEQ 0>
		<cfset Variables.EXEMPT_INDICATOR = "Exempt">
	</CFIF>
    
    <cfif Variables.EXEMPT_INDICATOR IS "Exempt" AND FORM.ANNUAL_SALARY LT THIS.Exempt_Minimum>
		<CFSET GO=0><CFSET Error_Code = THIS.Error_Ap&"PL240007">
	</cfif>