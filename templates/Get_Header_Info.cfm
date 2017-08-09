<!--- 
	Title:  Get_Header_Info.cfm
	Author:  Bill M. Mohr
	Creation Date: 06/03/2002
	Modified Date: 03/12/2003
		
	The Get_Header_Info Template captures basic Header information for a variety of 
	Pages in the Budget tool.  It also sets local variables including Variables.Name
	which concatenates First_Name, Middle_Name, and Last_Name 
	
	3/12/2003 Modification: Re-integrating this snippet into the budget tool by compacting the code and
			incorporating the output query in this template so that all query variables (from a single 
			record) can be stored as local variables by the calling page.
--->
<CFIF IsDefined("FORM.BCM_ID")>
	<CFSET Variables.BCM_ID = FORM.BCM_ID>
<CFELSEIF IsDefined("URL.BCM_ID")>
	<CFSET Variables.BCM_ID = URL.BCM_ID>
</CFIF>

<CFQUERY name = "q_Get_Header_Info" datasource = "#THIS.DSN#">
	SELECT 
		*
	FROM
		<cfif session.pbt_archiver>
            PEDI_PBT_HEADERS_2011_SUB
        <cfelse>
            PEDI_PBT_HEADERS
        </cfif>
	WHERE
		BCM_ID = '#Variables.BCM_ID#'
	AND
		FY = '#session.pbt_PREF_DEF_FY#'
	<cfinclude template = "../templates/Record_Type_Selection.cfm">
</CFQUERY>

<cfif q_Get_Header_Info.RecordCount EQ 0>
	<h2 align="center">Error:  No Records Found for this selection.</h2>
	<cfif NOT IsDefined("URL.Go")>
		<table align = "center">
			<tr>
				<td><cfinclude template = "../templates/Legend_footer.cfm"></td>
			</tr>
			<tr>
				<td><cfinclude template = "../templates/footer.cfm"></td>
			</tr>
		</table>
	</cfif>
	<cfabort>
</cfif>

<!--- We only want to output the values for one segment, so the below code checks if the current 
	Record_Type_Selection is "3" (the only value that might return multiple records), then, if it
	is 3, we set the boolean "Type3Only" to True - else false --->
<cfif session.pbt_Record_Type_Selection IS 3 AND q_Get_Header_Info.RecordCount GT 1>
	<cfset Type3Only = 1>
<cfelse>
	<cfset Type3Only = 0>
</cfif>

<CFOUTPUT Query = "q_Get_Header_Info">
	<!--- Check to see if this is a NonPeds Employee (in which case, we will allow manual overwrite of Fringe) --->
    <cfset This_Org_Unit = q_Get_Header_Info.ORG_UNIT>
    <cfset This_Home_Dept_Desc = q_Get_Header_Info.HOME_DEPT_DESC>
    <cfset IsNewHire = q_Get_Header_Info.New_Hire>
    <cfif left(q_Get_Header_Info.LAST_NAME,3) IS "TBN">
    	<cfset IsTBN = 1>
    <cfelse>
    	<cfset IsTBN = 0>
    </cfif>
    
    <cfquery name="q_CheckIfNonPeds" datasource="#THIS.DSN#">
    	SELECT
        	HOME_DEPT_DESC as OFFICIAL_HDD_NAME
        FROM
        	PEDI_PBT_CONTROL
        WHERE
        	ORG_UNIT = '#This_Org_Unit#'
    </cfquery>
    
    <cfif find("PEDIATRICS-",This_Home_Dept_Desc) EQ 0>
    	<cfset NonPeds = 1>
    <cfelse>
		<cfset NonPeds = 0>
    </cfif>
    
	<!--- OutputRecord Boolean --->
	<CFIF session.pbt_Record_Type_Selection IS NOT 3>
		<cfset OutputRecord = 1>
	<cfelse>
		<cfif Type3Only>
			<cfif q_Get_Header_Info.Rec_Type IS 3>
				<cfset OutputRecord = 1>
			<cfelseif q_Get_Header_Info.Rec_Type IS 2>
				<cfset OutputRecord = 1>
			<cfelse>
				<cfset OutputRecord = 0>
			</cfif>
		<cfelse>
			<cfset OutputRecord = 1>
		</cfif>
	</CFIF>
	<cfif OutputRecord>
		<cfloop index = "ThisItem" list = "#q_Get_Header_Info.ColumnList#">
			<cfscript>
				temp = SetVariable("Variables.#ThisItem#", Evaluate(ThisItem));
			</cfscript>
		</cfloop>
	</cfif>
    
	 <!--- Check if this is a Faculty person (display effort?) --->
     <cfif Variables.EMP_CLASS IS "FACULTY" or variables.NEW_CLASS IS "FACULTY">
         <cfset IsFaculty = 1>
     <cfelse>
         <cfset IsFaculty = 0>
     </cfif>
</cfoutput>