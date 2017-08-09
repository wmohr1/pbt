<cfquery name="q_GetTermDate" datasource="#THIS.DSN#">
  SELECT
      BP_START_DATE,
      TERM_DATE,
      FUND_TYPE
  FROM
      PEDI_PBT_COA
  WHERE
      FUNDCENTER = '#THIS_FUNDCENTER#'
</cfquery>

<cfloop query="q_GetTermDate">
	<cfif q_GetTermDate.FUND_TYPE IS "W">
		<cfset ThisTermDate = q_GetTermDate.TERM_DATE>
	  	<cfset ThisStartDate = q_GetTermDate.BP_START_DATE>
	<cfelse>
  		<cfset ThisStartDate = THIS.FY_Start_Date>
  		<cfset ThisTermDate = THIS.FY_End_Date>
	</cfif>
</cfloop>

<cfif ThisStartDate LT THIS.FY_Start_Date>
  <cfset ThisStartDate = THIS.FY_Start_Date>
</cfif>

<cfif ThisTermDate GT THIS.FY_End_Date>
  <cfset ThisTermDate = THIS.FY_End_Date>
</cfif>

<cfset WorkingDays = countArbitraryDays(ThisStartDate,ThisTermDate)>

<!--- Determine First month --->
<cfset ThisFirstMonth = datepart("m",ThisStartDate)>
<!--- Determine last Period --->
<cfswitch expression="#ThisFirstMonth#">
	<cfcase value="1">
		<cfset ThisFirstPeriod = 7>
	</cfcase>
	<cfcase value="2">
		<cfset ThisFirstPeriod = 8>
	</cfcase>
	<cfcase value="3">
		<cfset ThisFirstPeriod = 9>
	</cfcase>
	<cfcase value="4">
		<cfset ThisFirstPeriod = 10>
	</cfcase>
	<cfcase value="5">
		<cfset ThisFirstPeriod = 11>
	</cfcase>
	<cfcase value="6">
		<cfset ThisFirstPeriod = 12>
	</cfcase>
	<cfcase value="7">
		<cfset ThisFirstPeriod = 1>
	</cfcase>
	<cfcase value="8">
		<cfset ThisFirstPeriod = 2>
	</cfcase>
	<cfcase value="9">
		<cfset ThisFirstPeriod = 3>
	</cfcase>
	<cfcase value="10">
		<cfset ThisFirstPeriod = 4>
	</cfcase>
	<cfcase value="11">
		<cfset ThisFirstPeriod = 5>
	</cfcase>
	<cfcase value="12">
		<cfset ThisFirstPeriod = 6>
	</cfcase>
</cfswitch>

<!--- Determine Last month --->
<cfset ThisLastMonth = datepart("m",ThisTermDate)>
<!--- Determine last Period --->
<cfswitch expression="#ThisLastMonth#">
	<cfcase value="1">
		<cfset ThisLastPeriod = 7>
	</cfcase>
	<cfcase value="2">
		<cfset ThisLastPeriod = 8>
	</cfcase>
	<cfcase value="3">
		<cfset ThisLastPeriod = 9>
	</cfcase>
	<cfcase value="4">
		<cfset ThisLastPeriod = 10>
	</cfcase>
	<cfcase value="5">
		<cfset ThisLastPeriod = 11>
	</cfcase>
	<cfcase value="6">
		<cfset ThisLastPeriod = 12>
	</cfcase>
	<cfcase value="7">
		<cfset ThisLastPeriod = 1>
	</cfcase>
	<cfcase value="8">
		<cfset ThisLastPeriod = 2>
	</cfcase>
	<cfcase value="9">
		<cfset ThisLastPeriod = 3>
	</cfcase>
	<cfcase value="10">
		<cfset ThisLastPeriod = 4>
	</cfcase>
	<cfcase value="11">
		<cfset ThisLastPeriod = 5>
	</cfcase>
	<cfcase value="12">
		<cfset ThisLastPeriod = 6>
	</cfcase>
</cfswitch>