<!---  
TEMPLATE NAME: q_GetActuals.cfm
CREATION DATE: 07/12/2016
AUTHOR: Bill Mohr (832.824.6736)
LAST MODIFIED: 07/12/2016
MODIFIED BY: Bill Mohr (832.824.6736)

SUMMARY:  This program queries the report tool to obtain actuals related to a selected Fundcenter.

SPECIAL NOTES:
07/12/2016: Will need to amalagate actuals grouped by commitment items related to budget rows.
--->

<!--- Create Period_Name list --->
<!--- We want to look at a 'rolling 12 months' and we need to be sure and pull data from months that are closed and, therefore, available in the report tool --->
<!--- What month and year is it right now? --->
<cfset ThisMonth = datepart("m",now())>
<cfset ThisYear = datepart("yyyy",now())>

<cfif val(ThisMonth) GT 2>
	<cfset LastPeriodName = ThisYear & NumberFormat((val(ThisMonth) - 2),"00")>
    <cfset EndingMonth = ThisMonth - 2>
<cfelse>
	<cfset LastPeriodName = (ThisYear - 1) & NumberFormat((val(ThisMonth) + 10),"00")>
    <cfset EndingMonth = ThisMonth + 10>
</cfif>

<cfswitch expression="#EndingMonth#">
	<cfcase value="1">
    	<cfset NextPeriodYear = ThisYear - 1>
        <cfset NextPeriodMonth = 12>
    	<cfset l_Period_Name = "(" & LastPeriodName & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth)),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 1),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 2),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 3),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 4),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 5),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 6),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 7),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 8),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 9),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 10),"00") & ")">
    </cfcase>
	<cfcase value="2">
    	<cfset NextPeriodYear = ThisYear - 1>
        <cfset NextPeriodMonth = 12>
    	<cfset l_Period_Name = "(" & LastPeriodName & "," & (LastPeriodName - 1) & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth)),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 1),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 2),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 3),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 4),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 5),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 6),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 7),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 8),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 9),"00") & ")">
    </cfcase>
	<cfcase value="3">
    	<cfset NextPeriodYear = ThisYear - 1>
        <cfset NextPeriodMonth = 12>
    	<cfset l_Period_Name = "(" & LastPeriodName & "," & (LastPeriodName - 1) & "," & (LastPeriodName - 2) & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth)),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 1),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 2),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 3),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 4),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 5),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 6),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 7),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 8),"00") & ")">
    </cfcase>
	<cfcase value="4">
    	<cfset NextPeriodYear = ThisYear - 1>
        <cfset NextPeriodMonth = 12>
    	<cfset l_Period_Name = "(" & LastPeriodName & "," & (LastPeriodName - 1) & "," & (LastPeriodName - 2) & "," & (LastPeriodName - 3) & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth)),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 1),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 2),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 3),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 4),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 5),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 6),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 7),"00") & ")">
    </cfcase>
	<cfcase value="5">
    	<cfset NextPeriodYear = ThisYear - 1>
        <cfset NextPeriodMonth = 12>
    	<cfset l_Period_Name = "(" & LastPeriodName & "," & (LastPeriodName - 1) & "," & (LastPeriodName - 2) & "," & (LastPeriodName - 3) & "," & (LastPeriodName - 4) & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth)),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 1),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 2),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 3),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 4),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 5),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 6),"00") & ")">
    </cfcase>
	<cfcase value="6">
    	<cfset NextPeriodYear = ThisYear - 1>
        <cfset NextPeriodMonth = 12>
    	<cfset l_Period_Name = "(" & LastPeriodName & "," & (LastPeriodName - 1) & "," & (LastPeriodName - 2) & "," & (LastPeriodName - 3) & "," & (LastPeriodName - 4) & "," & (LastPeriodName - 5) & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth)),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 1),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 2),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 3),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 4),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 5),"00") & ")">
    </cfcase>
	<cfcase value="7">
    	<cfset NextPeriodYear = ThisYear - 1>
        <cfset NextPeriodMonth = 12>
    	<cfset l_Period_Name = "(" & LastPeriodName & "," & (LastPeriodName - 1) & "," & (LastPeriodName - 2) & "," & (LastPeriodName - 3) & "," & (LastPeriodName - 4) & "," & (LastPeriodName - 5) & "," & (LastPeriodName - 6) & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth)),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 1),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 2),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 3),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 4),"00") & ")">
    </cfcase>
	<cfcase value="8">
    	<cfset NextPeriodYear = ThisYear - 1>
        <cfset NextPeriodMonth = 12>
    	<cfset l_Period_Name = "(" & LastPeriodName & "," & (LastPeriodName - 1) & "," & (LastPeriodName - 2) & "," & (LastPeriodName - 3) & "," & (LastPeriodName - 4) & "," & (LastPeriodName - 5) & "," & (LastPeriodName - 6) & "," & (LastPeriodName - 7) & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth)),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 1),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 2),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 3),"00") & ")">
    </cfcase>
	<cfcase value="9">
    	<cfset NextPeriodYear = ThisYear - 1>
        <cfset NextPeriodMonth = 12>
    	<cfset l_Period_Name = "(" & LastPeriodName & "," & (LastPeriodName - 1) & "," & (LastPeriodName - 2) & "," & (LastPeriodName - 3) & "," & (LastPeriodName - 4) & "," & (LastPeriodName - 5) & "," & (LastPeriodName - 6) & "," & (LastPeriodName - 7) & "," & (LastPeriodName - 8) & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth)),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 1),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 2),"00") & ")">
    </cfcase>
	<cfcase value="10">
    	<cfset NextPeriodYear = ThisYear - 1>
        <cfset NextPeriodMonth = 12>
    	<cfset l_Period_Name = "(" & LastPeriodName & "," & (LastPeriodName - 1) & "," & (LastPeriodName - 2) & "," & (LastPeriodName - 3) & "," & (LastPeriodName - 4) & "," & (LastPeriodName - 5) & "," & (LastPeriodName - 6) & "," & (LastPeriodName - 7) & "," & (LastPeriodName - 8) & "," & (LastPeriodName - 9) & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth)),"00") & "," & NextPeriodYear & NumberFormat((val(NextPeriodMonth) - 1),"00") & ")">
    </cfcase>
	<cfcase value="11">
    	<cfset NextPeriodYear = ThisYear - 1>
        <cfset NextPeriodMonth = 12>
    	<cfset l_Period_Name = "(" & LastPeriodName & "," & (LastPeriodName - 1) & "," & (LastPeriodName - 2) & "," & (LastPeriodName - 3) & "," & (LastPeriodName - 4) & "," & (LastPeriodName - 5) & "," & (LastPeriodName - 6) & "," & (LastPeriodName - 7) & "," & (LastPeriodName - 8) & "," & (LastPeriodName - 9) & "," & (LastPeriodName - 10) & "," & (NextPeriodYear - 1) & NumberFormat((val(NextPeriodMonth)),"00") & ")">
    </cfcase>
	<cfcase value="12">
    	<cfset NextPeriodYear = ThisYear - 1>
        <cfset NextPeriodMonth = 12>
    	<cfset l_Period_Name = "(" & LastPeriodName & "," & (LastPeriodName - 1) & "," & (LastPeriodName - 2) & "," & (LastPeriodName - 3) & "," & (LastPeriodName - 4) & "," & (LastPeriodName - 5) & "," & (LastPeriodName - 6) & "," & (LastPeriodName - 7) & "," & (LastPeriodName - 8) & "," & (LastPeriodName - 9) & "," & (LastPeriodName - 10) & "," & (LastPeriodName - 11) & ")">
    </cfcase>
</cfswitch>

<!--- Query PEDI_RPT_ECPCA for actuals --->
<cfquery name="q_GetActuals" datasource="#THIS.DSN#">
	SELECT
    	SUM(E.TRANS_AMT) AS THIS_TOTAL,
        E.FUNDCENTER,
        
        G.GL_COMM_ITEM
    FROM
    	PEDI_RPT_ECPCA E,
        PEDI_RPT_GL_ACCTS G
    WHERE
    	E.FUNDCENTER = '#ThisFundcenter#'
    AND
    	G.GL_ACCT = E.GL_ACCT
    AND
    	E.PERIOD_NAME IN #trim(l_Period_Name)#
    <cfif THIS_GL_COMM_ITEM IS "SUPP_SVCS">
	    AND
    		G.GL_COMM_ITEM = 'SUPP_SVC'
	<cfelse>
	    AND
    		G.GL_COMM_ITEM = '#THIS_GL_COMM_ITEM#'
    </cfif>
    GROUP BY
    	E.FUNDCENTER,
        G.GL_COMM_ITEM
</cfquery>

<cfif q_GetActuals.RecordCount GT 0>
	<cfset THIS_ACTUAL_TOTAL = round(q_GetActuals.THIS_TOTAL)>
<cfelse>
	<cfset THIS_ACTUAL_TOTAL = 0>
</cfif>