<!---  
TEMPLATE NAME: Set_Section.cfm
CREATION DATE: ????
AUTHOR: Bill Mohr (832.824.6736)
LAST MODIFIED: 5/19/2014
MODIFIED BY: Bill Mohr (832.824.6736)

SUMMARY:  This template is called by many of the reports and screens in Survivor and serves to allow selection of working org unit.

SPECIAL NOTES:
5/19/2014: Updating for new lock levels.
--->
<SCRIPT LANGUAGE="JavaScript">
	<!-- Original:  CodeLifter.com (support@codelifter.com) -->
	<!-- Web Site:  http://www.codelifter.com -->
	
	<!-- This script and many more are available free online at -->
	<!-- The JavaScript Source!! http://javascript.internet.com -->
	
	<!-- Begin
	function printWindow() {
	bV = parseInt(navigator.appVersion);
	if (bV >= 4) window.print();
	}
	//  End -->
</script>

<cfset AF_SUPER_LOCK_LVL = 100>
<cfset AF_SECTION_LOCKED = 1>

<cfsetting enablecfoutputonly = "No" requesttimeout = "9999">

<CFIF IsDefined("URL.Invalid_Only")>
	<CFSET SQL_Validated = 0>
	<CFSET val_stat = 1>
<CFELSEIF IsDefined("Val_Stat") AND Val_Stat IS 1>
	<CFSET SQL_Validated = 0>
<CFELSEIF IsDefined("Val_Stat") AND Val_Stat IS 2>
	<CFSET SQL_Validated = 1>
<cfelse>
	<CFSET val_stat = 3>
</CFIF>

<cfif IsDefined("URL.Show_SubDesc")>
	<cfset session.pbt_Show_SubDesc = URL.Show_SubDesc>
</cfif>

<cfset RefreshAction = right(cgi.script_name,find("/",reverse(cgi.script_name)) - 1)>
<cfset RefreshAction = RefreshAction & "?RequestTimeout=9999">
<cfif IsDefined("URL.ReportTitle")>
	<cfset RefreshAction = RefreshAction & "&ReportTitle=" & URLEncodedFormat(URL.ReportTitle)>
</cfif>

<TABLE align="center" valign="top">
    <TR>
        <CFIF NOT IsDefined("FORM.print")>
            <td valign = "top" align = "center" title="Print this page.">
                <CFOUTPUT>
                    <FORM action = "#RefreshAction#" method="post">
                        <cf_Capture_VariablesToHidden>
                        <input name="print" value="1" type="hidden">
                        <input type="image" src="../images/print1.gif" alt="Print this page." onClick="this.form.submit()">
                    </form>
                </cfoutput>
            </td>
        </CFIF>
        <cfif session.pbt_administrator IS NOT "1_Admin" AND session.pbt_administrator IS NOT "3_Dept">
            <!--- q_Get_Authority generates a list of Org_Units the user has permission to access --->
            <cfquery name = "q_Get_Authority" datasource = "#THIS.DSN#">
                SELECT
                    ORG_UNIT,
                    HOME_DEPT_DESC,
                    FI_SEC
                FROM
                    PEDI_PBT_CONTROL
                WHERE
                    Username = '#session.pbt_thisuser#'
                Group by 
                    HOME_DEPT_DESC, ORG_UNIT, FI_SEC
                Order by 
                    HOME_DEPT_DESC
            </cfquery>
           
            <!--- Multi-Select Permission is granted to those with more than 1 section access --->
            <cfif q_get_authority.recordcount gt 1>
                <cfif isdefined("FORM.fi_sec")>
                	<cfset session.pbt_admin_fi_sec = FORM.fi_sec>
                    <cfquery name = "q_get_org_unit" datasource = "#THIS.DSN#">
                        SELECT
                            ORG_UNIT,
                            HOME_DEPT_DESC
                        FROM
                            PEDI_PBT_CONTROL
                        WHERE
                            FI_SEC = #FORM.FI_SEC#
                    </cfquery>
                    <cfoutput query = "q_get_org_unit">
                    	<cfset session.pbt_admin_org_unit = q_get_org_unit.org_unit>
                        <cfset session.pbt_admin_home_dept_desc = q_get_org_unit.home_dept_desc>
                    </cfoutput>
                <cfelseif IsDefined("session.pbt_admin_fi_sec")>
                    <cfquery name = "q_get_org_unit" datasource = "#THIS.DSN#">
                        SELECT
                            ORG_UNIT,
                            HOME_DEPT_DESC
                        FROM
                            PEDI_PBT_CONTROL
                        WHERE
                            FI_SEC = #session.pbt_admin_fi_sec#
                    </cfquery>
                    <cfoutput query = "q_get_org_unit">
                    	<cfset session.pbt_admin_org_unit = q_get_org_unit.org_unit>
                        <cfset session.pbt_admin_home_dept_desc = q_get_org_unit.home_dept_desc>
                    </cfoutput>
                <cfelse>
                    <cfquery name = "q_get_org_unit" datasource = "#THIS.DSN#">
                        SELECT
                            ORG_UNIT,
                            HOME_DEPT_DESC
                        FROM
                            PEDI_PBT_CONTROL
                        WHERE
                            ORG_UNIT = #session.pbt_ORG_UNIT#
                    </cfquery>
                   	<cfset session.pbt_admin_org_unit = q_get_org_unit.org_unit>
                    <cfset session.pbt_admin_home_dept_desc = q_get_org_unit.home_dept_desc>
                </cfif>
                <cfif not isdefined("url.go") AND NOT IsDefined("FORM.print")>
                    <TD title="SELECT SECTION/ORG_UNIT">
                        <cfoutput>
                            <FORM action = #RefreshAction# method="POST">
                                <cf_Capture_VariablesToHidden Exclusions = "FI_SEC">
                                <select name="fi_sec" onChange="this.form.submit()">
                                    <cfloop query="q_get_authority">
                                        <option value=#fi_sec# <cfif isdefined("session.pbt_admin_home_dept_desc") and '#session.pbt_admin_home_dept_desc#' is '#q_get_authority.home_dept_desc#'>selected</cfif>>#q_get_authority.home_dept_desc#
                                    </cfloop>
                                </select>						
                            </form>
                        </cfoutput>
                    </td>
                </cfif>
            <cfelse>
                <cfoutput query="q_get_authority">
                    <cfset session.pbt_admin_home_dept_desc = q_get_authority.home_dept_desc>
                    <cfif not isdefined("url.go") AND NOT IsDefined("FORM.print")>
                        <td align = "center" valign = "top">#q_get_authority.home_dept_desc#</td>
                    </cfif>
                </cfoutput>
            </cfif>
        <cfelse>
            <!--- this is the same query as for non-admin, but without the where clause --->
            <!--- q_get_authority generates a list of org_units the user has permission to access --->
            <cfquery name = "q_get_authority" datasource = "#THIS.DSN#">
                SELECT
                    ORG_UNIT,
                    HOME_DEPT_DESC,
                    FI_SEC
                FROM
                    PEDI_PBT_CONTROL
                <cfif session.pbt_administrator IS "3_Dept">
                WHERE
                    ORG_UNIT >= '99992420'
                </cfif>
                Group by 
                    HOME_DEPT_DESC, ORG_UNIT, FI_SEC
                Order by 
                    HOME_DEPT_DESC
            </cfquery>

            <cfif isdefined("form.fi_sec") and form.fi_sec is not "all">
				<cfset session.pbt_admin_fi_sec = form.fi_sec>
                <cfquery name = "q_get_org_unit" datasource = "#THIS.DSN#">
                    SELECT
                        ORG_UNIT,
                        HOME_DEPT_DESC
                    FROM
                        PEDI_PBT_CONTROL
                    WHERE
                        FI_SEC = #form.fi_sec#
                </cfquery>
                <cfoutput query = "q_get_org_unit">
                   	<cfset session.pbt_admin_org_unit = q_get_org_unit.org_unit>
                    <cfset session.pbt_admin_home_dept_desc = q_get_org_unit.home_dept_desc>
                </cfoutput>
            <cfelseif isdefined("form.fi_sec")>
            	<cfset session.pbt_admin_fi_sec = "ALL">
                <cfset session.pbt_admin_org_unit = "ALL">
                <cfset session.pbt_admin_HOME_DEPT_DESC = "ALL">
            <cfelseif not isdefined("session.pbt_admin_fi_sec")>
            	<cfset session.pbt_admin_fi_sec = "ALL">
                <cfset session.pbt_admin_org_unit = "ALL">
                <cfset session.pbt_admin_HOME_DEPT_DESC = "ALL">
            <cfelseif isdefined("session.pbt_admin_fi_sec") and session.pbt_admin_fi_sec is not "ALL">
				<cfset session.pbt_admin_fi_sec = session.pbt_admin_fi_sec>
                <cfset session.pbt_admin_org_unit = session.pbt_admin_org_unit>
                <cfquery name = "q_get_org_unit" datasource = "#THIS.DSN#">
                    SELECT
                        HOME_DEPT_DESC
                    FROM
                        PEDI_PBT_CONTROL
                    WHERE
                        FI_SEC = #session.pbt_admin_fi_sec#
                </cfquery>
                <cfoutput>
                    <cfset session.pbt_admin_home_dept_desc = "#q_get_org_unit.home_dept_desc#">
                </cfoutput>
            <cfelseif isdefined("session.pbt_admin_fi_sec")>
				<cfset session.pbt_admin_fi_sec = session.pbt_admin_fi_sec>
                <cfset session.pbt_admin_org_unit = session.pbt_admin_org_unit>
                <cfset session.pbt_admin_HOME_DEPT_DESC = "ALL">
            <cfelse>
            	<cfset session.pbt_admin_HOME_DEPT_DESC = q_get_org_unit.home_dept_desc>
            </cfif>
            
            <cfif not isdefined("url.go") AND NOT IsDefined("FORM.print")>
                <TD title="SELECT SECTION/ORG_UNIT">
                    <CFOUTPUT>
                        <FORM action = #RefreshAction# method="post">
                            <cf_capture_variablestohidden exclusions = "FI_SEC">
                            <select name="fi_sec" onChange="this.form.submit()">
                                <cfif isdefined("session.pbt_admin_fi_sec")><option value="all" <cfif isdefined("session.pbt_admin_fi_sec") and '#session.pbt_admin_fi_sec#' is "all">selected</cfif>>all</cfif>
                                    <cfloop query="q_get_authority">
                                        <option value=#fi_sec# <cfif isdefined("session.pbt_admin_fi_sec") and '#session.pbt_admin_fi_sec#' is '#q_get_authority.fi_sec#'>selected</cfif>>#q_get_authority.home_dept_desc#
                                    </cfloop>
                            </select>						
                        </form>
                    </cfoutput>
                </td>
            </cfif>
        </cfif>
        
        <!--- Get value of SAL_LOCK indicating whether this employee's distribution has been Locked --->
		<cfif session.pbt_Admin_Org_Unit IS NOT "ALL">
             <CFQUERY NAME="q_Get_Lock" datasource="#THIS.DSN#">
                 SELECT
                     SAL_LOCK,
                     SAL_LVL1_LOCK,
                     SAL_LVL2_LOCK,
                     SAL_LVL3_LOCK,
                     AF_LVL1_LOCK,
                     AF_LVL2_LOCK,
                     AF_LVL3_LOCK
                 FROM
                     PEDI_PBT_CONTROL
                 WHERE
                     ORG_UNIT = '#session.pbt_Admin_Org_Unit#'
             </CFQUERY>
        
			 <!--- Set value of LOCK_STOP to 1 if record is locked, 0 if not --->
             <CFOUTPUT Query="q_Get_Lock" maxrows = "1">
                 <cfif q_Get_Lock.SAL_LVL1_LOCK>
                     <cfset SAL_LOCK_LVL = 1>
                 <cfelseif q_Get_Lock.SAL_LVL2_LOCK>
                     <cfset SAL_LOCK_LVL = 2>
                 <cfelseif q_Get_Lock.SAL_LVL3_LOCK>
                     <cfset SAL_LOCK_LVL = 3>
                 <cfelse>
                     <cfset SAL_LOCK_LVL = 0>
                 </cfif>
     
                 <!--- Sum the locks to determine how many are in place --->
                 <cfif session.pbt_admin_org_unit IS NOT "ALL">
	                 <cfset SAL_SUPER_LOCK_LVL = q_Get_Lock.SAL_LVL1_LOCK + q_Get_Lock.SAL_LVL2_LOCK + q_Get_Lock.SAL_LVL3_LOCK>
                 <cfelse>
	                 <cfset SAL_SUPER_LOCK_LVL = 100>
				 </cfif>
     
                 <!--- Compare the Control lock(s) to the lock-level of the user --->
                 <cfswitch expression="#SAL_SUPER_LOCK_LVL#">
                     <cfcase value="0">
                         <cfset Lock_Level_Text = "UNLOCKED">
                         <cfset SECTION_LOCKED = 0>
                     </cfcase>
                     <cfcase value="1">
                         <cfset Lock_Level_Text = "LEVEL 3 LOCKED">
                         <cfswitch expression="#session.pbt_LOCK_LVL#">
                             <cfcase value="3">
                                 <cfset SECTION_LOCKED = 1>
                             </cfcase>
                             <cfdefaultcase>
                                 <cfset SECTION_LOCKED = 0>
                             </cfdefaultcase>
                         </cfswitch>
                     </cfcase>
                     <cfcase value="2">
                         <cfset Lock_Level_Text = "LEVEL 2 LOCKED">
                         <cfswitch expression="#session.pbt_LOCK_LVL#">
                             <cfcase value="3">
                                 <cfset SECTION_LOCKED = 1>
                             </cfcase>
                             <cfcase value="2">
                                 <cfset SECTION_LOCKED = 1>
                             </cfcase>
                             <cfdefaultcase>
                                 <cfset SECTION_LOCKED = 0>
                             </cfdefaultcase>
                         </cfswitch>
                     </cfcase>
                     <cfcase value="3">
                         <cfset Lock_Level_Text = "LEVEL 1 LOCKED">
                         <cfset SECTION_LOCKED = 1>
                     </cfcase>
                 </cfswitch>
                 
                 <cfif q_Get_Lock.AF_LVL1_LOCK>
                     <cfset AF_LOCK_LVL = 1>
                 <cfelseif q_Get_Lock.AF_LVL2_LOCK>
                     <cfset AF_LOCK_LVL = 2>
                 <cfelseif q_Get_Lock.AF_LVL3_LOCK>
                     <cfset AF_LOCK_LVL = 3>
                 <cfelse>
                     <cfset AF_LOCK_LVL = 0>
                 </cfif>
     
                 <!--- Sum the locks to determine how many are in place --->
                 <cfif session.pbt_admin_org_unit IS NOT "ALL">
	                 <cfset AF_SUPER_LOCK_LVL = q_Get_Lock.AF_LVL1_LOCK + q_Get_Lock.AF_LVL2_LOCK + q_Get_Lock.AF_LVL3_LOCK>
                 <cfelse>
	                 <cfset AF_SUPER_LOCK_LVL = 100>
				 </cfif>
     
                 <!--- Compare the Control lock(s) to the lock-level of the user --->
                 <cfswitch expression="#AF_SUPER_LOCK_LVL#">
                     <cfcase value="0">
                         <cfset AF_Lock_Level_Text = "UNLOCKED">
                         <cfset AF_SECTION_LOCKED = 0>
                     </cfcase>
                     <cfcase value="1">
                         <cfset AF_Lock_Level_Text = "LEVEL 3 LOCKED">
                         <cfswitch expression="#session.pbt_LOCK_LVL#">
                             <cfcase value="3">
                                 <cfset AF_SECTION_LOCKED = 1>
                             </cfcase>
                             <cfdefaultcase>
                                 <cfset AF_SECTION_LOCKED = 0>
                             </cfdefaultcase>
                         </cfswitch>
                     </cfcase>
                     <cfcase value="2">
                         <cfset AF_Lock_Level_Text = "LEVEL 2 LOCKED">
                         <cfswitch expression="#session.pbt_LOCK_LVL#">
                             <cfcase value="3">
                                 <cfset AF_SECTION_LOCKED = 1>
                             </cfcase>
                             <cfcase value="2">
                                 <cfset AF_SECTION_LOCKED = 1>
                             </cfcase>
                             <cfdefaultcase>
                                 <cfset AF_SECTION_LOCKED = 0>
                             </cfdefaultcase>
                         </cfswitch>
                     </cfcase>
                     <cfcase value="3">
                         <cfset AF_Lock_Level_Text = "LEVEL 1 LOCKED">
                         <cfset AF_SECTION_LOCKED = 1>
                     </cfcase>
                     <cfdefaultcase>
                        <cfset AF_Lock_Level_Text = "LOCKED">
						<cfset AF_SECTION_LOCKED = 1>                     
                     </cfdefaultcase>
                 </cfswitch>
             </CFOUTPUT>
        </cfif>
            
        <cfif not isdefined("url.go") AND NOT IsDefined("FORM.print")>
            <cfoutput>
                <TD valign = "center" align = "center">
                    <cfif session.pbt_PREF_DEF_FY is THIS.FY>
                             <FORM action = #RefreshAction# method="POST">
                            <cf_Capture_VariablesToHidden Exclusions = "RECORD_TYPE_SELECTION">
                            <CFIF IsDefined("FORM.Record_Type_Selection")>
                             <CFSWITCH expression="#FORM.Record_Type_Selection#">
                                 <CFCASE value=1>
                                     <cfset session.pbt_Record_Type_Selection = 1>
                                 </CFCASE>
                                 <CFCASE value=2>
                                     <cfset session.pbt_Record_Type_Selection = 2>
                                 </CFCASE>
                                 <CFCASE value=3>
                                     <cfset session.pbt_Record_Type_Selection = 3>
                                 </CFCASE>
                             </CFSWITCH>
                             </CFIF>
                            <select name = "Record_Type_Selection" onChange = "this.form.submit()">
                                <option value = "3" <CFIF session.pbt_Record_Type_Selection IS 3>SELECTED</CFIF>>FY #DateFormat(THIS.FY_END_DATE,"YYYY")#</option>
                                <option value = "1" <CFIF session.pbt_Record_Type_Selection IS 1>SELECTED</CFIF>>RAW 6/30 (Initial Data)</option>
                                <option value = "2" <CFIF session.pbt_Record_Type_Selection IS 2>SELECTED</CFIF>>7/1 Records Only</option>
                            </select>						
                        </FORM>
                    </cfif>
                </TD>
                <TD valign = "center" align = "center">
                    
                </TD>
                <td valign = "top" align = "center" title="User Application Preferences">
                    <a href="ADMIN_Console_prefs.cfm" target="_blank"><img src="../images/chklst.gif" alt="User Application Preferences" border="none" /></a>
                </td>
				 <CFIF IsDefined("Lock_Level_Text") AND Lock_Level_Text IS NOT "Unlocked">
                     <td valign = "top" class = "error_red">*** SALARY BUDGET #Lock_Level_Text# ***<br>****  AF BUDGET #AF_Lock_Level_Text# ****</TD>			
                 </CFIF>
            </cfoutput>
        </cfif>
    </TR>
</TABLE>

<CFIF IsDefined("FORM.print")>
	<body class="landScape" onLoad="javascript:printWindow()">
<CFELSE>
	<body>
</CFIF>