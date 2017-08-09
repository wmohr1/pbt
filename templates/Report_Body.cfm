<!--- 
Title: Report_Body.cfm
Purpose: This is the core of various reports showing the sourcing of personnel expenses.

Author: Bill M. Mohr
Created: A long time ago (2001?)

Modified:
2014-11-11: Adding NonPeds pay to report.
2014-10-21: Adding Supplemental pay to report.
--->


<CFPARAM name = "val_stat" default = "3">
<CFPARAM name = "Val_Class" default = "4">
<CFPARAM name = "Record_Type_Selection" default = "3">

<CFIF IsDefined("FORM.Val_Stat")>
	<cfset val_stat = FORM.Val_Stat>
<CFELSEIF IsDefined("URL.Val_Stat")>
	<cfset val_stat = URL.Val_Stat>
</CFIF>

<CFIF IsDefined("FORM.Val_Class")>
	<CFSET Val_Class = FORM.Val_Class>
<CFELSEIF IsDefined("URL.Val_Class")>
	<CFSET Val_Class = URL.Val_Class>
</CFIF>

<!--- "Show_SubDesc" is a boolean that determines whether or not to display TCH and Forecast details --->
<cfif IsDefined("URL.Show_SubDesc")>
	<CFSET Show_SubDesc = URL.Show_SubDesc>
	<cfif Show_SubDesc>
		<cfset TOGGLE_SHOW_SUBDESC = 0>
		<cfcookie name = "pbt_SHOW_SUBDESC" value = "1">
	<cfelse>
		<cfset TOGGLE_SHOW_SUBDESC = 1>
		<cfcookie name = "pbt_SHOW_SUBDESC" value = "0">
	</cfif>
<cfelse>
	<CFSET Show_SubDesc = session.pbt_SHOW_SUBDESC>
	<cfif session.pbt_SHOW_SUBDESC>
		<cfset TOGGLE_SHOW_SUBDESC = 0>
	<cfelse>
		<cfset TOGGLE_SHOW_SUBDESC = 1>
	</cfif>
</cfif>

<cfinclude template="../templates/Set_Section.cfm"> 

<CFIF IsDefined("URL.Invalid_Only")>
	<CFSET SQL_Validated = 0>
	<CFSET val_stat = 1>
<CFELSEIF Val_Stat IS 1>
	<CFSET SQL_Validated = 0>
<CFELSEIF Val_Stat IS 2>
	<CFSET SQL_Validated = 1>
</CFIF>

<CFIF IsDefined("session.pbt_Admin_Org_Unit") AND session.pbt_Admin_Org_Unit IS NOT "All">
	<CFSET SQL_ORG_UNIT = session.pbt_Admin_Org_Unit>
<CFELSEIF IsDefined("session.pbt_Admin_Org_Unit")>
	<CFSET SQL_ORG_UNIT = "ALL">
<CFELSE>
	<CFSET SQL_ORG_UNIT = session.pbt_ORG_UNIT>
</CFIF>

<CFIF IsDefined("session.pbt_Admin_FI_SEC") AND session.pbt_Admin_FI_SEC IS NOT "All">
	<CFSET session.pbt_admin_fi_sec = session.pbt_Admin_FI_SEC>
<CFELSEIF IsDefined("session.pbt_Admin_FI_SEC")>
	<CFSET session.pbt_admin_fi_sec = "ALL">
<CFELSE>
	<CFSET session.pbt_admin_fi_sec = session.pbt_FI_SEC>
</CFIF>

<!--- Begin Creation of Array of Selected Section Ees --->
<!--- Initialize Array to contain a list of Selected Section Ees --->
<CFSCRIPT>
	Last_BCM_ID = "Bob";
	Count = 0;
	AllSalary = 0;
	AllFringe = 0;
	AllSectionSalary = 0;
	AllSectionFringe = 0;
	NoUsage_AllSalary = 0;
	Operating_Sum = 0;
	Restricted_Sum = 0;
	Other_Sum = 0;
	Section_Locked = 1;	//--- Budgets have been submitted ---//
	l_SectionEes = '111';
</CFSCRIPT>

<cfquery name = "q_Get_Dist" datasource = "#THIS.DSN#">
	SELECT
		H.HOME_DEPT_DESC AS HOME_DEPT_DESC, 
        H.ORG_UNIT AS ORG_UNIT,
		H.FIRST_NAME || ' ' || H.LAST_NAME AS EMPLOYEE_NAME,		
        TO_CHAR(H.BCM_ID,'99999999') AS BCM_ID,
		H.JOB_CODE_DESC AS JOB_CODE_DESC,
		H.DEGREE_1 || ' ' || H.DEGREE_2 AS DEGREES,
		TO_CHAR(H.PDOC_LEVEL) AS PDOC_LEVEL,
        H.FTE AS FTE,
		H.NEW_HIRE AS NEW_HIRE,
		H.RFA AS RFA,		
		D.FUNDCENTER AS FUNDCENTER,
		D.SALARY AS SALARY,
        D.FB_AMT AS FRINGE,
		D.IT0027 AS IT0027,
		D.IT9027 AS IT9027,
		D.TCH_RESTRICTED AS TCH_RESTRICTED,
		D.TCH_FC_ID AS TCH_FC_ID,
		D.TCH_DESCRIPTION AS TCH_DESCRIPTION, 
		D.FORECAST_DESCRIPTION AS FORECAST_DESCRIPTION,
		D.START_DATE AS START_DATE,
        D.FORECAST_FC_ID AS FISCAL_PERIOD,
		D.END_DATE AS END_DATE,
		D.BUS_AREA AS BUS_AREA,
		D.VALIDATED AS VALIDATED,
		D.REC_IDX AS D_REC_IDX,
        D.INTERNAL_ORDER AS INTERNAL_ORDER

	FROM         
		<cfif session.pbt_archiver>
            PEDI_PBT_HEADERS_2011_SUB H,
            PEDI_PBT_DISTRIBUTION_2011_SUB D
        <cfelse>
            PEDI_PBT_HEADERS H,
            PEDI_PBT_DISTRIBUTION D
        </cfif>
	WHERE
		H.Emp_Status = '3'
	AND	
		D.FY = '#session.pbt_PREF_DEF_FY#'
	AND
		D.FY = H.FY
	AND
		D.BCM_ID = H.BCM_ID
	<CFIF IsDefined("SQL_Validated")>
	AND
		H.Validated = #SQL_Validated#
	</CFIF>
	   <CFIF IsDefined("session.pbt_admin_fi_sec") and session.pbt_admin_fi_sec is not "ALL">
       AND
           SUBSTR(D.Fundcenter,1,#len(session.pbt_admin_fi_sec)#) = '#session.pbt_admin_fi_sec#'
       </CFIF>
	<!--- <CFIF IsDefined("SQL_ORG_UNIT") AND SQL_ORG_UNIT IS NOT "ALL">
	AND
		H.Org_Unit = '#SQL_ORG_UNIT#'
	<CFELSEIF IsDefined("SQL_ORG_UNIT") AND session.pbt_ADMINISTRATOR IS "3_Dept">
	AND
		H.Org_Unit <> '99992107'
	</CFIF> --->

	<cfinclude template = "../templates/Val_Class_Selection.cfm">
	<CFSWITCH expression = "#Record_Type_Selection#">
		<CFCASE value="1">
			AND
				D.REC_TYPE = 1
			AND
				H.REC_TYPE = 1
		</CFCASE>
		<CFCASE value="2">
			AND
				D.REC_TYPE = 2
			AND
				H.REC_TYPE = 2
		</CFCASE>
		<CFCASE value="3">
			AND
				D.REC_TYPE <> 1
			AND
				H.REC_TYPE <> 1
		</CFCASE>
	</CFSWITCH>
	<CFIF IsDefined("SQL_Validated")>
	AND
		D.Validated = #SQL_Validated#
	</CFIF>
	<CFIF IsDefined("Variables.ASC")>
		AND
			#PreserveSingleQuotes(Variables.ASC)#
	</CFIF>
	ORDER BY
		H.HOME_DEPT_DESC,
		H.Last_Name,
        H.First_Name,
		H.BCM_ID,		
		D.Start_Date,
        D.Fundcenter
</cfquery>

<cfquery name="q_Get_Supp" datasource="#THIS.DSN#">
	SELECT
		H.HOME_DEPT_DESC AS HOME_DEPT_DESC, 
        H.ORG_UNIT AS ORG_UNIT,
		H.FIRST_NAME || ' ' || H.LAST_NAME AS EMPLOYEE_NAME,		
        TO_CHAR(H.BCM_ID,'99999999') AS BCM_ID,
		H.JOB_CODE_DESC AS JOB_CODE_DESC,
		H.DEGREE_1 || ' ' || H.DEGREE_2 AS DEGREES,
		TO_CHAR(H.PDOC_LEVEL) AS PDOC_LEVEL,
        H.FTE AS FTE,
		H.NEW_HIRE AS NEW_HIRE,
		H.RFA AS RFA,
        H.VALIDATED AS VALIDATED,		

      	D.FUNDCENTER,
      	D.SUPP_AMOUNT AS SALARY,
	    D.FB_AMT AS FRINGE,
		TO_NUMBER('0','999.99') AS IT0027,
		TO_NUMBER('0','999.99') AS IT9027,
	    D.MOD_DATE AS START_DATE,
    	D.MOD_DATE AS END_DATE,
	    D.BUS_AREA,
    	D.TCH_FC_ID,
		D.TCH_DESCRIPTION, 
        D.INTERNAL_ORDER,
	    D.TCH_RESTRICTED,
    	D.FORECAST_DESCRIPTION,
		D.FISCAL_PERIOD
	FROM         
    	PEDI_PBT_HEADERS H,
	    PEDI_PBT_SUPP_PAY D
	WHERE
      	H.FY = '#session.pbt_PREF_DEF_FY#'
    AND
    	H.FY = D.FY
	AND
		H.Emp_Status = '3'

	AND
		D.BCM_ID = H.BCM_ID
   	<CFIF IsDefined("Val_Class")>
	<CFSWITCH expression = "#Val_Class#">
		<CFCASE value = "1">
			AND 
				D.EMP_CLASS = 'FACULTY'
		</CFCASE>
		<CFCASE value = "2">
			AND 
				D.EMP_CLASS = 'STAFF'
		</CFCASE>
		<CFCASE value = "3">
			AND 
				D.EMP_CLASS = 'FELLOW'
		</CFCASE>
	</CFSWITCH>
</CFIF>

  <CFIF IsDefined("Variables.ASC")>
       AND
           #PreserveSingleQuotes(ASC)#
  </CFIF>
	<CFIF IsDefined("SQL_Validated")>
	AND
		H.Validated = #SQL_Validated#
	</CFIF>
  <CFIF IsDefined("session.pbt_admin_fi_sec") and session.pbt_admin_fi_sec is not "ALL">
  AND
      SUBSTR(D.Fundcenter,1,#len(session.pbt_admin_fi_sec)#) = '#session.pbt_admin_fi_sec#'
  </CFIF>
	<CFSWITCH expression = "#Record_Type_Selection#">
		<CFCASE value="1">
			AND
				H.REC_TYPE = 1
		</CFCASE>
		<CFCASE value="2">
			AND
				H.REC_TYPE = 2
		</CFCASE>
		<CFCASE value="3">
			AND
				H.REC_TYPE <> 1
		</CFCASE>
	</CFSWITCH>
	ORDER BY
      HOME_DEPT_DESC,
      EMPLOYEE_NAME
</cfquery>

<cfquery name="q_Get_Nonpeds" datasource="#THIS.DSN#">
	SELECT
		D.HOME_DEPT_DESC, 
        D.ORG_UNIT,
        D.EMPLOYEE_NAME,
		D.BCM_ID,
		D.BENEFIT_LEVEL AS JOB_CODE_DESC,
		'' AS DEGREES,
		'0' AS PDOC_LEVEL,
		TO_NUMBER('0','999.99') AS FTE,
		TO_NUMBER('0') AS NEW_HIRE,
		'0' AS RFA,		
		TO_NUMBER('1') AS VALIDATED,
        TO_NUMBER('0','999.99') AS IT0027,
        TO_NUMBER('0','999.99') AS IT9027,
        D.END_DATE,
		D.FUNDCENTER,
		D.SALARY,
        D.FRINGE,
        D.TCH_RESTRICTED,
		D.TCH_FC_ID,
        D.TCH_DESCRIPTION,
		D.FORECAST_DESCRIPTION,
        D.FORECAST_FC_ID AS FISCAL_PERIOD,
		D.START_DATE,
		D.BUS_AREA,
		D.REC_IDX AS D_REC_IDX,
        '0' AS INTERNAL_ORDER
	FROM         
		PEDI_PBT_BPC_NONPEDS D
	WHERE
		D.FY = '#session.pbt_PREF_DEF_FY#'
	<CFIF IsDefined("session.pbt_admin_fi_sec") AND session.pbt_admin_fi_sec IS NOT "ALL">
	AND
		SUBSTR(D.Fundcenter,1,#len(session.pbt_admin_fi_sec)#) = '#session.pbt_admin_fi_sec#'
	</CFIF>
	<CFIF IsDefined("Val_Class")>
	<CFSWITCH expression = "#Val_Class#">
		<CFCASE value = "1">
			AND 
				D.BENEFIT_LEVEL LIKE 'F%'
		</CFCASE>
		<CFCASE value = "2">
			AND 
				D.BENEFIT_LEVEL LIKE 'S%'
		</CFCASE>
		<CFCASE value = "3">
			AND 
				D.BENEFIT_LEVEL NOT LIKE 'F%'
			AND 
				D.BENEFIT_LEVEL NOT LIKE 'S%'
		</CFCASE>
	</CFSWITCH>
</CFIF>
	<CFIF IsDefined("Variables.ASC")>
		AND
			#PreserveSingleQuotes(Variables.ASC)#
	</CFIF>
</cfquery>

<cfset q_query1 = queryNew("HOME_DEPT_DESC, ORG_UNIT, EMPLOYEE_NAME, DEGREES, PDOC_LEVEL, JOB_CODE_DESC, FUNDCENTER, BCM_ID, SALARY, FRINGE, ITOO27, IT9O27, START_DATE, END_DATE, BUS_AREA, TCH_RESTRICTED, TCH_DESCRIPTION, FORECAST_FC_ID, FORECAST_DESCRIPTION, FISCAL_PERIOD, FTE, INTERNAL_ORDER, VALIDATED, NEW_HIRE, RFA", "CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_INTEGER, CF_SQL_INTEGER, CF_SQL_DECIMAL, CF_SQL_DECIMAL, CF_SQL_DATE, CF_SQL_DATE, CF_SQL_VARCHAR, CF_SQL_INTEGER, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_INTEGER, CF_SQL_DECIMAL, CF_SQL_VARCHAR, CF_SQL_INTEGER, CF_SQL_INTEGER, CF_SQL_VARCHAR")>

<cfset q_Get_Report_Data = queryNew("HOME_DEPT_DESC, ORG_UNIT, EMPLOYEE_NAME, DEGREES, PDOC_LEVEL, JOB_CODE_DESC, FUNDCENTER, BCM_ID, SALARY, FRINGE, ITOO27, IT9O27, START_DATE, END_DATE, BUS_AREA, TCH_RESTRICTED, TCH_DESCRIPTION, FORECAST_FC_ID, FORECAST_DESCRIPTION, FISCAL_PERIOD, FTE, INTERNAL_ORDER, VALIDATED, NEW_HIRE, RFA", "CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_INTEGER, CF_SQL_INTEGER, CF_SQL_DECIMAL, CF_SQL_DECIMAL, CF_SQL_DATE, CF_SQL_DATE, CF_SQL_VARCHAR, CF_SQL_INTEGER, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_VARCHAR, CF_SQL_INTEGER, CF_SQL_DECIMAL, CF_SQL_VARCHAR, CF_SQL_INTEGER, CF_SQL_INTEGER, CF_SQL_VARCHAR")>

<cfquery name="q_query1" dbtype="query">
	SELECT
      HOME_DEPT_DESC,
      ORG_UNIT,
      EMPLOYEE_NAME,
      DEGREES,
      PDOC_LEVEL,
      JOB_CODE_DESC,
      FUNDCENTER,
      BCM_ID,
      SALARY,
      FRINGE,
      IT0027,
      IT9027,
      START_DATE,
      END_DATE,
      BUS_AREA,
      TCH_RESTRICTED,
      TCH_DESCRIPTION, 
      TCH_FC_ID,
      FORECAST_DESCRIPTION,
      FISCAL_PERIOD,
      FTE,
      INTERNAL_ORDER,
      VALIDATED,
      NEW_HIRE,
      RFA
  FROM 
  	q_Get_Dist
  UNION ALL
	SELECT
      HOME_DEPT_DESC,
      ORG_UNIT,
      EMPLOYEE_NAME,
      DEGREES,
      PDOC_LEVEL,
      JOB_CODE_DESC,
      FUNDCENTER,
      BCM_ID,
      SALARY,
      FRINGE,
      IT0027,
      IT9027,
      START_DATE,
      END_DATE,
      BUS_AREA,
      TCH_RESTRICTED,
      TCH_DESCRIPTION, 
      TCH_FC_ID,
      FORECAST_DESCRIPTION,
      FISCAL_PERIOD,
      FTE,
      INTERNAL_ORDER,
      VALIDATED,
      NEW_HIRE,
      RFA
  FROM 
  	q_Get_Nonpeds
	ORDER BY
		HOME_DEPT_DESC,
		EMPLOYEE_NAME,
		START_DATE
</cfquery>

<cfquery name="q_Get_Report_Data" dbtype="query">
	SELECT
      HOME_DEPT_DESC,
      ORG_UNIT,
      EMPLOYEE_NAME,
      DEGREES,
      PDOC_LEVEL,
      JOB_CODE_DESC,
      FUNDCENTER,
      BCM_ID,
      SALARY,
      FRINGE,
      IT0027,
      IT9027,
      START_DATE,
      END_DATE,
      BUS_AREA,
      TCH_RESTRICTED,
      TCH_DESCRIPTION, 
      TCH_FC_ID,
      FORECAST_DESCRIPTION,
      FISCAL_PERIOD,
      FTE,
      INTERNAL_ORDER,
      VALIDATED,
      NEW_HIRE,
      RFA
  FROM 
  	q_query1
  UNION ALL
	SELECT
      HOME_DEPT_DESC,
      ORG_UNIT,
      EMPLOYEE_NAME,
      DEGREES,
      PDOC_LEVEL,
      JOB_CODE_DESC,
      FUNDCENTER,
      BCM_ID,
      SALARY,
      FRINGE,
      IT0027,
      IT9027,
      START_DATE,
      END_DATE,
      BUS_AREA,
      TCH_RESTRICTED,
      TCH_DESCRIPTION, 
      TCH_FC_ID,
      FORECAST_DESCRIPTION,
      FISCAL_PERIOD,
      FTE,
      INTERNAL_ORDER,
      VALIDATED,
      NEW_HIRE,
      RFA
  FROM 
  	q_Get_Supp
	ORDER BY
		HOME_DEPT_DESC,
		EMPLOYEE_NAME,
		Start_Date
</cfquery>

<CFIF NOT IsDefined("FORM.print")>
	<cfif IsDefined("URL.Go")>
        <!--- This link should enable the user to download the displayed report to an Excel file --->
        <cfcontent TYPE="application/vnd.ms-excel"> 
    <cfelse>
        <!--- Add Employee button appears at top and bottom of screen, Select Validation Status --->
        <TABLE align="center" valign="top">
            <tr>
                <td>
                    <CFOUTPUT>
                        <a href="#CGI.PATH_INFO#?Go=1&val_stat=#Val_Stat#&val_class=#val_class#&ReportTitle=#URLEncodedFormat(ReportTitle)#&RequestTimeout=9999"><img src="../images/button05_excel.gif" alt="DOWNLOAD REPORT to EXCEL!" border="0"></a>
                    </CFOUTPUT>
                </td>
                <td valign="top" ><cfoutput>#URLDecode(ReportTitle)#</cfoutput> - </TD>
                <TD>
                    <form action = #CGI.PATH_INFO# method = "post" name = "Report Selection" id = "Report Selection">
        
                        <cfif IsDefined("FORM.Fieldnames")>
                            <cfset l_Exclusions = "FIELDNAMES, VAL_STAT">
                        <cfelse>
                            <cfset l_Exclusions = "VAL_STAT">
                        </cfif>
        
                        <cf_Capture_VariablesToHidden Exclusions = #l_Exclusions#> 					
        
                        <cfif NOT IsDefined("URL.Go")>
                            <select name = "Val_Stat" onChange = "this.form.submit()">
                                <option value = "1" <CFIF Val_Stat IS 1>SELECTED</CFIF>>NON-VALIDATED</option>
                                <option value = "2" <CFIF Val_Stat IS 2>SELECTED</CFIF>>VALIDATED</option>
                                <option value = "3" <CFIF Val_Stat IS 3>SELECTED</CFIF>>ALL</option>
                            </select>		
                        <cfelse>
                            <CFSWITCH expression = #Val_Stat#>
                                <CFCASE value = "1">NON-VALIDATED</CFCASE>
                                <CFCASE value = "2">VALIDATED</CFCASE>
                                <CFCASE value = "3">VALIDATED AND NON-VALIDATED RECORDS - </CFCASE>
                            </CFSWITCH>
                        </cfif>
                    </form>				
                </TD>
                <TD>
                    <form action = #CGI.PATH_INFO# method = "post" name = "Report Selection" id = "Report Selection">
                        <cfif IsDefined("FORM.Fieldnames")>
                            <cfset l_Exclusions = "FIELDNAMES, VAL_CLASS">
                        <cfelse>
                            <cfset l_Exclusions = "VAL_CLASS">
                        </cfif>
                        <cf_Capture_VariablesToHidden Exclusions = #l_Exclusions#>		
                        <cfif NOT IsDefined("URL.Go")>
                            <select name = "Val_Class" onChange = "this.form.submit()">
                                <option value = "1" <CFIF Val_Class IS 1>SELECTED</CFIF>>FACULTY ONLY</option>
                                <option value = "2" <CFIF Val_Class IS 2>SELECTED</CFIF>>STAFF ONLY</option>
                                <option value = "3" <CFIF Val_Class IS 3>SELECTED</CFIF>>FELLOWS ONLY</option>
                                <option value = "4" <CFIF Val_Class IS 4>SELECTED</CFIF>>ALL CLASSES</option>
                            </select>		
                        <cfelse>
                            <CFSWITCH expression = #Val_Class#>
                                <CFCASE value = "1">FACULTY ONLY</CFCASE>
                                <CFCASE value = "2">STAFF ONLY</CFCASE>
                                <CFCASE value = "3">FELLOWS ONLY</CFCASE>
                                <CFCASE value = "4">ALL CLASSES</CFCASE>
                            </CFSWITCH>
                        </cfif>
                    </form>				
                </td>
                <td>
                    <cfif NOT IsDefined("URL.Go")>
                        <CFIF NOT Variables.Section_Locked and session.pbt_Record_Type_Selection NEQ 2 and session.pbt_PREF_DEF_FY IS THIS.FY>
                            <cfinclude template="../templates/Emp_Add_Button.cfm">	
                        </CFIF>
                    </cfif>
                </td>
            </tr>
        </TABLE>
    </cfif>
</CFIF>
<CFOUTPUT>
	<TABLE width="87%" CELLSPACING="1" CELLPADDING="3" align="center">
		<TR BGCOLOR="6666cc">
			<TH align = "left">Section</TH>
			<TH align = "left">Name</TH>
			<TH>Title</TH>
			<TH align = "center">Fundcenter <cfoutput><A Href="#RefreshAction#&Show_SubDesc=#TOGGLE_SHOW_SUBDESC#"><img src="../images/arrw01_43c.gif" alt="Toggle Ext Desc" border="none"></A></cfoutput></TH>
			<CFIF session.pbt_Show_SubDesc>
				<TH align = "center">Ext. Description</TH>
			</CFIF> 
			<TH align = "center">BCMID</TH>
			<TH align = "center">FTE</TH>
			<TH>Source Amt</TH>
			<TH>Fringe</TH>
			<TH>% of SAL</TH>		
			<TH>% of EFT</TH>		
			<TH>Start Date</TH>
			<TH>End Date</TH>				
			<TH align = "center">Business Area</TH>	
			<TH align = "center">Internal Order</TH>	
			<cfif session.pbt_PREF_DEF_FY IS THIS.FY and not session.pbt_archiver>
				<CFIF NOT SECTION_LOCKED AND Record_Type_Selection NEQ 1 AND THIS.FY IS session.pbt_PREF_DEF_FY>
					<TH align = "center">Edit</TH>				
					<TH align = "center">Delete</TH>		
				</CFIF> 
			</cfif>
		</TR>
		<tr style="color: Yellow; background-color: Black; font-weight: bold; font-size: larger;"></tr>	
		<CFSCRIPT>
			Last_BCM_ID = "Bob";
			ThisRecord = 1;
			OneOfUs = 1;
		</CFSCRIPT>
		<!--- Main report body - employees IN user's section --->
		<CFLOOP query="q_Get_Report_Data">
			<CFIF q_Get_Report_Data.BCM_ID IS NOT LAST_BCM_ID and q_Get_Report_Data.Salary GT 0 >
				<tr style="background-color:330099; color: 330099; border-color: 330099; border-top: thick 330099;">
					<TD></TD>
					<TD></TD>
					<TD></TD>
					<TD></TD>
					<TD></TD>
					<TD></TD>
					<TD></TD>
					<TD></TD>
					<TD></TD>
				   <CFIF session.pbt_Show_SubDesc>
                       <TD></TD>
                   </CFIF>
					<TD></TD>
					<TD></TD>
					<TD></TD>
					<TD></TD>
					<TD></TD>
				<CFIF NOT SECTION_LOCKED AND Record_Type_Selection NEQ 1 and not session.pbt_archiver>
					<TD></TD>
					<TD></TD>
				</cfif>
				</tr>
			</CFIF>
            <!--- Test to see if this employee belongs to this ORG_UNIT --->
            <cfif q_Get_Report_Data.ORG_UNIT IS NOT SQL_ORG_UNIT>
            	<cfset OneOfUs = 0>
            <cfelse>
            	<cfset OneOfUs = 1>
            </cfif>
            <TR 
                <CFIF right(left(q_Get_Report_Data.Fundcenter,10),5) eq "00100">
                    BGCOLOR="RED"
                <CFELSEIF NOT q_Get_Report_Data.Validated>
                    BGCOLOR="LIGHTGREY"
                <CFELSEIF q_Get_Report_Data.New_Hire>
                    BGCOLOR="Yellow"
                <CFELSEIF q_Get_Report_Data.RFA IS "10">
                    BGCOLOR = "lightGreen"
                <CFELSEIF IsDefined("session.pbt_admin_fi_sec") AND Left(q_Get_Report_Data.Fundcenter,len(session.pbt_admin_fi_sec)) NEQ '#session.pbt_admin_fi_sec#'>
                    BGCOLOR="PaleVioletRed"
                <CFELSEIF NOT OneOfUs>
                    BGCOLOR="CC99FF"
                </CFIF>>
                <TD align="left" nowrap>#q_Get_Report_Data.HOME_DEPT_DESC#</TD>
                <td nowrap>
                    <A Href="emp_detail.cfm?BCM_ID=#q_Get_Report_Data.BCM_ID#">#UCase(q_Get_Report_Data.EMPLOYEE_NAME)#</A>
                </td>
                <td align="center" nowrap>#q_Get_Report_Data.JOB_CODE_DESC#</td>
                <cfset FC_Item_Report = q_Get_Report_Data.Fundcenter & " ACCOUNT SALARY USAGE REPORT">
                <TD align="left" nowrap><A Href = "FC_Item_Report.cfm?ReportTitle=#URLEncodedFormat(FC_Item_Report)#&Fundcenter=#q_Get_Report_Data.Fundcenter#&RequestTimeout=9999">#NumberFormat(q_Get_Report_Data.Fundcenter, 9999999999)#</a></TD>
                <CFIF session.pbt_Show_SubDesc>
                    <TD><cfif val(q_Get_Report_Data.TCH_FC_ID) GT 1>#q_Get_Report_Data.TCH_FC_ID#<cfelseif len(trim(q_Get_Report_Data.FORECAST_DESCRIPTION)) GT 1>#q_Get_Report_Data.Forecast_Description#</cfif></TD>
                </CFIF>
                <TD align="left" nowrap>#q_Get_Report_Data.BCM_ID#</TD>
                <TD align="left" nowrap><CFIF q_Get_Report_Data.FTE NEQ 0>#q_Get_Report_Data.FTE#</CFIF></TD>
                <CFSET AllSalary = AllSalary + q_Get_Report_Data.Salary>
                <CFSET AllFringe = AllFringe + q_Get_Report_Data.Fringe>
                <cfif IsDefined("session.pbt_admin_fi_sec") and session.pbt_admin_fi_sec is not "ALL">
                    <cfif left(q_Get_Report_Data.Fundcenter,len(session.pbt_admin_fi_sec)) IS session.pbt_admin_fi_sec>
                        <CFSET AllSectionSalary = AllSectionSalary + q_Get_Report_Data.Salary>
                        <CFSET AllSectionFringe = AllSectionFringe + q_Get_Report_Data.Fringe>
                    </CFIF>
                </cfif>
                <td align="right" nowrap>#NumberFormat(q_Get_Report_Data.Salary,"$999,999,999")#</td>		
                <td align="right" nowrap>#NumberFormat(q_Get_Report_Data.Fringe,"$999,999,999")#</td>		
                <!--- Test if this is SUPP --->
                <cfif q_Get_Report_Data.Start_Date EQ q_Get_Report_Data.End_Date and q_Get_Report_Data.FISCAL_PERIOD GT 0 and q_Get_Report_Data.FISCAL_PERIOD LTE 12 AND q_Get_Report_Data.IT0027 EQ 0>
                	<cfset IsSUPP = 1>
                <cfelse>
                	<cfset IsSUPP = 0>
                </cfif>
                <cfif IsSUPP>
	                <td align="right" nowrap></td>
	                <td align="right" nowrap></td>
        	        <td align="center" nowrap>FP: #NumberFormat(q_Get_Report_Data.FISCAL_PERIOD,"99")#</td>
	                <td align="right" nowrap></td>
                <cfelse>
	                <td align="right" nowrap><CFIF q_Get_Report_Data.FTE NEQ 0 and OneOfUs>#NumberFormat(q_Get_Report_Data.IT0027,"999.99")#%<cfelse>******</CFIF></td>
    	            <td align="right" nowrap><CFIF q_Get_Report_Data.FTE NEQ 0 and OneOfUs>#NumberFormat(q_Get_Report_Data.IT9027,"999.99")#%<cfelse>******</CFIF></td>		
        	        <td align="center" nowrap>#DateFormat(q_Get_Report_Data.Start_Date,"MM/DD/YY")#</td>
            	    <td align="center" nowrap>#DateFormat(q_Get_Report_Data.End_Date,"MM/DD/YY")#</td>
                </cfif>
                <td align="center" nowrap>#q_Get_Report_Data.Bus_Area#</td>
                <td align="center" nowrap>#NumberFormat(right(q_Get_Report_Data.INTERNAL_ORDER,6),"000000")#</td>
                <CFIF NOT SECTION_LOCKED AND Record_Type_Selection NEQ 1 and not session.pbt_archiver>
                    <TD><A Href="fc_edit_form.cfm?REC_IDX=#q_Get_Report_Data.D_REC_IDX#&ANNUAL_SALARY=#q_Get_Report_Data.ANNUAL_SALARY#">Edit</A></TD>
                    <TD><A Href="fc_del_form.cfm?REC_IDX=#q_Get_Report_Data.D_REC_IDX#">Delete</A></TD>		
                </cfif>
            </TR>
			<CFSCRIPT>
                tmp = listfind(l_SectionEes,q_Get_Report_Data.BCM_ID);
                if (tmp eq 0)
                    l_SectionEes = listappend(l_SectionEes,q_Get_Report_Data.BCM_ID);
                LAST_BCM_ID = q_Get_Report_Data.BCM_ID;
                ThisRecord = ThisRecord + 1;
            </CFSCRIPT>
		</CFLOOP>
	</table>
	<br><br>
</cfoutput>