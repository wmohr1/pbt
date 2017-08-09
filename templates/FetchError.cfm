<!---
AUTHOR: Bill M. Mohr
DATE: May 10, 2002
PURPOSE: Centralize Error tracking, management, and display.  
Track Errors in an Application(s) and present custom error messages.
ATTRIBUTES:
	Error_Code="______"  (See Document "Error Codes Format Standard" for naming conventions)
	Template_Name="______" (Can be dynamically set in calling page using CGI.PATH_INFO)
	Fatal_Error="___" (If 1 or Yes, error stops processing when custom tag called.)
USAGE NOTES:
	<cf_FetchError Error_Code = #Error_Code# Template_Name= #CGI.PATH_INFO#>
	
	This Custom Tag requires that the PEDI_PBT_ERRORS exists in THIS.DSN
MODIFICATION LOG:
DATE		AUTHOR			MODIFICATION
=========	=============	=======================================================
--->

<CFQUERY NAME="Get_Error_Msg" datasource="#THIS.DSN#">
	SELECT      
		Error_Msg,
		Error_Count
	FROM         
		PEDI_PBT_ERRORS
	WHERE
		Error_Code = '#Attributes.Error_Code#'
</cfquery>

<CFIF Get_Error_Msg.RecordCount LT 1>
	SHOOT <cfoutput>Error Code: #Attributes.Error_Code# Not found.</cfoutput>
	<CFABORT>
</CFIF>
<cfif session.pbt_PREF_SOUND>
	<BGSOUND SRC="../media/doh.wav"> 
</cfif>

<CFOUTPUT Query = "Get_Error_Msg">
	<CFSCRIPT>
		Variables.FetchError_Error_Msg = Get_Error_Msg.Error_Msg;
		Variables.Error_Last_Date = #DateFormat(Now(),"MM/DD/YYYY")#;
		Variables.Error_Last_Time = #TimeFormat(Now(),"HH:mm:ss")#;
		Variables.Error_Count = Get_Error_Msg.Error_Count + 1;
		Variables.Error_Last_Template = Attributes.Template_Name;
	</CFSCRIPT>
</CFOUTPUT>

<CFQUERY NAME="Update_PEDI_PBT_ERRORS" datasource="#THIS.DSN#">
	UPDATE
		PEDI_PBT_ERRORS
	SET
		Error_Last_Date = '#Variables.Error_Last_Date#',
		Error_Last_Time = '#Variables.Error_Last_Time#',
		Error_Count = #Variables.Error_Count#,
		Error_Last_Template = '#Variables.Error_Last_Template#'
	WHERE
		Error_Code = '#Attributes.Error_Code#'
</cfquery>

<CFIF Attributes.Fatal_Error>
	<CFOUTPUT>
		<table align = "center">
			<tr>
				<td><h3 align = "center" style="color: Red; font-weight: bold;">DATA INCONSISTENCY DETECTED!  PLEASE CLICK YOUR BACK BUTTON AND REVIEW ENTRIES.</h3></td>
			</tr>
			<tr>
				<td><H4 align = "center" Style="color: Red; font-weight: bold;">#Variables.FetchError_Error_Msg#!</H4></td>
			</tr>		
			<br><br><br>
			<tr>
				<td><h5 align = "center">Error Code: #Attributes.Error_Code#</h5></td>
			</tr>
			<br><br>
		</table>
		<cfif NOT IsDefined("URL.Go")>
		<table align = "center">
			<tr>
				<td><cfinclude template = "../templates/footer.cfm"></td>
			</tr>
		</table>
		</cfif>

	</CFOUTPUT>
	<CFABORT>
<CFELSE>
	<cfoutput>
	<table align = "center">
		<tr>
			<td><h4 align = "center" style="color: Red; font-weight: bold;">DATA INCONSISTENCY DETECTED!  PLEASE CLICK YOUR BACK BUTTON AND REVIEW ENTRIES.</h4></td>
		</tr>
		<tr>
			<td><H5 align = "center" Style="color: Red; font-weight: bold;">#Variables.FetchError_Error_Msg#</H5></td>
		</tr>		
		<tr>
			<td><h6 align = "center">Error Code: #Attributes.Error_Code#</h6></td>
		</tr>
		<br><br>
	</table>
	</cfoutput>
	<CFEXIT>	
</CFIF>
