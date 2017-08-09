<!---
AUTHOR: Bill M. Mohr
DATE: September 13, 2002

PURPOSE: Capture all URL and FORM variables and convert to LOCAL variables AND Hidden 
FORM variables to be passed on for cumulative filtering.

ATTRIBUTES:
	Exclusions="______"  (Comma delimited list of variable names to be excluded from conversion)

USAGE NOTES:
	<cf_Capture_VariablesToHidden Exclusions = "foo, id">
	
MODIFICATION LOG:
DATE		AUTHOR			MODIFICATION
=========	=============	=======================================================
--->

<!--- This is the body of the custom tag --->
<cfparam name="Attributes.Exclusions" default="">

<cfoutput>
	<!--- Convert URL variables first... --->
	<CFIF IsDefined("URL") AND NOT StructIsEmpty(URL)>
		<CFLOOP collection = #URL# item = "ThisItem">
			<CFIF NOT ListContains(Attributes.Exclusions, ThisItem)>
				<cfset AnItem = "URL." & ThisItem>
				<INPUT name = #ThisItem# type="Hidden" value = #URLEncodedFormat(evaluate(AnItem))#>
				<cfset tmp = SetVariable(ThisItem, #evaluate(AnItem)#)>
			</CFIF>
		</CFLOOP>
	</CFIF>
	
	<!--- Next Convert FORM variables... --->
	<CFIF IsDefined("FORM.FieldNames")>
		<CFLOOP collection = #FORM# item = "ListElement">
			<CFIF NOT ListContains(Attributes.Exclusions, trim(ListElement))>
				<CFSET URL_TEST = "URL." & ListElement>
				<CFIF NOT IsDefined("#URL_TEST#") AND #ListElement# IS NOT "Fieldnames">
					<INPUT name = "#ListElement#" type="Hidden" value = "#Evaluate(ListElement)#">
					<cfset AnItem = "FORM." & ListElement>
					<cfset tmp = SetVariable(ListElement, #evaluate(AnItem)#)>
				</CFIF>
			</CFIF>
		</CFLOOP>
	</CFIF>
</cfoutput>
<!-- This ends the body of the custom tag. -->

<!--- This part is in here for my current purposes, but should be removed before distributing or sharing this Custom tag --->
<!--- The Record_Type_Selection is stored as a session/session so that it can be used in all pages --->
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
<CFELSEIF IsDefined("session.pbt_Record_Type_Selection")>
	<CFSWITCH expression="#session.pbt_Record_Type_Selection#">
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
<CFELSE>
	<cfset session.pbt_Record_Type_Selection = 3>
</CFIF>
