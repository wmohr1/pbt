<!---  
TEMPLATE NAME: LOAD_MBTV_TABLE_AF_pers.cfm
CREATION DATE: 07/19/2016
AUTHOR: Bill Mohr (832.824.6736)
LAST MODIFIED: 07/19/2016
MODIFIED BY: Bill Mohr (832.824.6736)

SUMMARY:  This is a revised version of the original LOAD_MBTV_TABLE_AF_new.cfm program. This program updates the PEDI_PBT_BPC_MBTV_TABLE table which serves to both provide data to the BCM BPC (Budget Tool) and provide data for Pediatrics internal reports. The data here will never be edited directly by users, but rather, is reflected as changes are made in the Operating budget and Header and Distribution tables, etc. This program ONLY updates personnel info in that table.

SPECIAL NOTES:
--->

<!--- Test for incoming variables --->
<cfif IsDefined("URL.FUNDCENTER")>
	<cfset THIS_FUNDCENTER = URL.FUNDCENTER>
	<cfset THIS_BUS_AREA = URL.THIS_BUS_AREA>
    <cfset THIS_GL = URL.THIS_GL>
    <cfset THIS_AF_FIELD = URL.THIS_AF_FIELD>
    <cfset THIS_REV_EXP = "EXP">
<cfelse>
	<cfset THIS_FUNDCENTER = ThisFUNDCENTER>
	<cfset THIS_BUS_AREA = ThisBUS_AREA>
    <cfset THIS_GL = ThisGL>
    <cfset THIS_AF_FIELD = ThisUpdateField>
    <cfset THIS_REV_EXP = "EXP">
</cfif>

<!--- Clear BPC_MBTV table for this Fundcenter / GL / BUS_AREA --->
<cfquery name="q_DeleteRecords" datasource="#THIS.DSN#">
	DELETE FROM
		PEDI_PBT_BPC_MBTV_TABLE
	WHERE
		FY = '#session.pbt_PREF_DEF_FY#'
	AND 
		FUNDCENTER = '#THIS_FUNDCENTER#'
	AND
		BUS_AREA = '#THIS_BUS_AREA#'
	AND
		GL = '#THIS_GL#'
</cfquery>

<!--- Query AF and CAP, drop amounts into fiscal period buckets minding TERM_DATE --->
<!--- NEED VALUE FOR THIS_AF_ENTRY PASSED IN --->
<cfquery name="q_GetAF" datasource="#THIS.DSN#">
	SELECT
    	#THIS_AF_FIELD# AS AF_AMOUNT
    FROM
    	PEDI_PBT_AF
    WHERE
        FY = '#session.pbt_PREF_DEF_FY#'
    AND 
    	FUNDCENTER = '#THIS_FUNDCENTER#'
</cfquery>

<cfset RunningTotal = 0>

<!--- Next Output Contents --->
<cfoutput query="q_GetAF">
	<cfset THIS_AMOUNT = q_GetAF.AF_AMOUNT>
	<cfset Variables.FundType = left(right(THIS_FUNDCENTER,3),1)>
    
    <cfif Variables.FundType GT 2 and Variables.FundType LT 6>
        <cfquery name="q_GetTermDate" datasource="#THIS.DSN#">
            SELECT
            	BP_START_DATE,
                TERM_DATE
            FROM
                PEDI_PBT_COA
            WHERE
                FUNDCENTER = '#THIS_FUNDCENTER#'
        </cfquery>
        <cfloop query="q_GetTermDate">
            <cfset ThisTermDate = q_GetTermDate.TERM_DATE>
            <cfset ThisStartDate = q_GetTermDate.BP_START_DATE>
        </cfloop>
    <cfelse>
    	<cfset ThisStartDate = THIS.FY_Start_Date>
		<cfset ThisTermDate = THIS.FY_End_Date>
    </cfif>
    
    <cfif ThisStartDate LT THIS.FY_Start_Date>
    	<cfset ThisStartDate = THIS.FY_Start_Date>
    </cfif>

    <cfif ThisTermDate GT THIS.FY_End_Date>
    	<cfset ThisTermDate = THIS.FY_End_Date>
    </cfif>
    
	
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

	<cfset ThisDate = ThisStartDate>
    <cfset WorkingDays = countArbitraryDays(ThisStartDate,ThisTermDate)>
	<cfset DailyAmount = THIS_AMOUNT / WorkingDays>
    <cfset RunningTotal = THIS_AMOUNT>
	<cfset ThisPeriod = 0>

	<!--- If the total amount is 0, no calculations necessary --->
	<cfif DailyAmount NEQ 0>
        <!--- Create a record for each period 1 - 12 --->
        <cfloop from="1" to="12" index="ThisPeriod">
            <cfswitch expression="#ThisPeriod#">
                <cfcase value="1">
                    <cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,31) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,31)>
                        <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,31)>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 1>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                        <cfset RunningTotal = RunningTotal - ThisPeriodAmount>
                    <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,1) and ThisFirstPeriod LTE 1>
                        <cfset ThisPeriodTermDate = ThisTermDate>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 1>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                    <cfelse>
                        <cfset ThisPeriodAmount = 0>
                    </cfif>
                </cfcase>
                <cfcase value="2">
                    <cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,31) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,31)>
                        <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,31)>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 2>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                        <cfset RunningTotal = RunningTotal - ThisPeriodAmount>
                    <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,1) and ThisFirstPeriod LTE 2>
                        <cfset ThisPeriodTermDate = ThisTermDate>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 2>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                    <cfelse>
                        <cfset ThisPeriodAmount = 0>
                    </cfif>
                </cfcase>
                <cfcase value="3">
                    <cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,30)>
                        <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,30)>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 3>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                        <cfset RunningTotal = RunningTotal - ThisPeriodAmount>
                    <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1) and ThisFirstPeriod LTE 3>
                        <cfset ThisPeriodTermDate = ThisTermDate>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 3>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                    <cfelse>
                        <cfset ThisPeriodAmount = 0>
                    </cfif>
                </cfcase>
                <cfcase value="4">
                    <cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,31)>
                        <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,31)>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 4>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                        <cfset RunningTotal = RunningTotal - ThisPeriodAmount>
                    <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1) and ThisFirstPeriod LTE 4>
                        <cfset ThisPeriodTermDate = ThisTermDate>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 4>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                    <cfelse>
                        <cfset ThisPeriodAmount = 0>
                    </cfif>
                </cfcase>
                <cfcase value="5">
                    <cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,30)>
                        <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,30)>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 5>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                        <cfset RunningTotal = RunningTotal - ThisPeriodAmount>
                    <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1) and ThisFirstPeriod LTE 5>
                        <cfset ThisPeriodTermDate = ThisTermDate>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 5>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                    <cfelse>
                        <cfset ThisPeriodAmount = 0>
                    </cfif>
                </cfcase>
                <cfcase value="6">
                    <cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,31)>
                        <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,31)>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 6>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                        <cfset RunningTotal = RunningTotal - ThisPeriodAmount>
                    <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1) and ThisFirstPeriod LTE 6>
                        <cfset ThisPeriodTermDate = ThisTermDate>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 6>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                    <cfelse>
                        <cfset ThisPeriodAmount = 0>
                    </cfif>
                </cfcase>
                <cfcase value="7">
                    <cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,31)>
                        <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,31)>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 7>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                        <cfset RunningTotal = RunningTotal - ThisPeriodAmount>
                    <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1) and ThisFirstPeriod LTE 7>
                        <cfset ThisPeriodTermDate = ThisTermDate>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 7>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                    <cfelse>
                        <cfset ThisPeriodAmount = 0>
                    </cfif>
                </cfcase>
                <cfcase value="8">
                    <cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,28)>
                        <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,28)>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 8>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                        <cfset RunningTotal = RunningTotal - ThisPeriodAmount>
                    <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1) and ThisFirstPeriod LTE 8>
                        <cfset ThisPeriodTermDate = ThisTermDate>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 8>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                    <cfelse>
                        <cfset ThisPeriodAmount = 0>
                    </cfif>
                </cfcase>
                <cfcase value="9">
                    <cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,31)>
                        <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,31)>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 9>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                        <cfset RunningTotal = RunningTotal - ThisPeriodAmount>
                    <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1) and ThisFirstPeriod LTE 9>
                        <cfset ThisPeriodTermDate = ThisTermDate>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 9>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                    <cfelse>
                        <cfset ThisPeriodAmount = 0>
                    </cfif>
                </cfcase>
                <cfcase value="10">
                    <cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,30)>
                        <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,30)>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 10>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                        <cfset RunningTotal = RunningTotal - ThisPeriodAmount>
                    <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1) and ThisFirstPeriod LTE 10>
                        <cfset ThisPeriodTermDate = ThisTermDate>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 10>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                    <cfelse>
                        <cfset ThisPeriodAmount = 0>
                    </cfif>
                </cfcase>
                <cfcase value="11">
                    <cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,31)>
                        <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,31)>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 11>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                        <cfset RunningTotal = RunningTotal - ThisPeriodAmount>
                    <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1) and ThisFirstPeriod LTE 11>
                        <cfset ThisPeriodTermDate = ThisTermDate>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 11>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                    <cfelse>
                        <cfset ThisPeriodAmount = 0>
                    </cfif>
                </cfcase>
                <cfcase value="12">
                    <cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,30)>
                        <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,30)>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfset ThisPeriodAmount = round(RunningTotal)>
                        <cfset ThisDailyAmount = ThisPeriodAmount / ThisPeriodWorkingDays>
                    <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,1)>
                        <cfset ThisPeriodTermDate = ThisTermDate>
                        <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,1)>
                            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,1)>
                        <cfelse>
                            <cfset ThisPeriodStartDate = ThisStartDate>
                        </cfif>
                        <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                        <cfif ThisLastPeriod IS 12>
                            <cfset ThisPeriodAmount = RunningTotal>
                        <cfelse>
                            <cfset ThisPeriodAmount = round(ThisPeriodWorkingDays * DailyAmount)>
                        </cfif>
                    <cfelse>
                        <cfset ThisPeriodAmount = 0>
                        <cfset ThisDailyAmount = 0>
                    </cfif>
                    
                    <!--- Add logic to populate TCH FY FP13-15 --->
					<!--- FP13 --->
                    <cfset ThisTCHPeriod = 13>
					<cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),7,31)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),7,1)>
                    <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                    <cfset ThisTCHPeriodAmount = ThisDailyAmount * ThisPeriodWorkingDays>
                      <cfquery name="q_UpdateTable" datasource="#THIS.DSN#">
                          INSERT INTO
                              PEDI_PBT_BPC_MBTV_TABLE
                              (FUNDCENTER,
                              BUS_AREA,
                              GL,
                              AMOUNT,
                              TBN,
                              REV_EXP,
                              PERIOD,
                              FY)
                              
                              VALUES
                              ('#THIS_FUNDCENTER#',
                              '#THIS_BUS_AREA#',
                              '#THIS_GL#',
                              #ROUND(ThisTCHPeriodAmount)#,
                              0,
                              '#THIS_REV_EXP#',
                              '#ThisTCHPeriod#',
                              '#session.pbt_PREF_DEF_FY#')
                      </cfquery>
					<!--- FP14 --->
                    <cfset ThisTCHPeriod = 14>
					<cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),8,31)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),8,1)>
                    <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                    <cfset ThisTCHPeriodAmount = ThisDailyAmount * ThisPeriodWorkingDays>
                      <cfquery name="q_UpdateTable" datasource="#THIS.DSN#">
                          INSERT INTO
                              PEDI_PBT_BPC_MBTV_TABLE
                              (FUNDCENTER,
                              BUS_AREA,
                              GL,
                              AMOUNT,
                              TBN,
                              REV_EXP,
                              PERIOD,
                              FY)
                              
                              VALUES
                              ('#THIS_FUNDCENTER#',
                              '#THIS_BUS_AREA#',
                              '#THIS_GL#',
                              #ROUND(ThisTCHPeriodAmount)#,
                              0,
                              '#THIS_REV_EXP#',
                              '#ThisTCHPeriod#',
                              '#session.pbt_PREF_DEF_FY#')
                      </cfquery>
					<!--- FP15 --->
                    <cfset ThisTCHPeriod = 15>
					<cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),9,30)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),9,1)>
                    <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                    <cfset ThisTCHPeriodAmount = ThisDailyAmount * ThisPeriodWorkingDays>
                      <cfquery name="q_UpdateTable" datasource="#THIS.DSN#">
                          INSERT INTO
                              PEDI_PBT_BPC_MBTV_TABLE
                              (FUNDCENTER,
                              BUS_AREA,
                              GL,
                              AMOUNT,
                              TBN,
                              REV_EXP,
                              PERIOD,
                              FY)
                              
                              VALUES
                              ('#THIS_FUNDCENTER#',
                              '#THIS_BUS_AREA#',
                              '#THIS_GL#',
                              #ROUND(ThisTCHPeriodAmount)#,
                              0,
                              '#THIS_REV_EXP#',
                              '#ThisTCHPeriod#',
                              '#session.pbt_PREF_DEF_FY#')
                      </cfquery>
                </cfcase>
            </cfswitch>
            <cfquery name="q_UpdateTable" datasource="#THIS.DSN#">
                INSERT INTO
                    PEDI_PBT_BPC_MBTV_TABLE
                    (FUNDCENTER,
                    BUS_AREA,
                    GL,
                    AMOUNT,
                    TBN,
                    REV_EXP,
                    PERIOD,
                    FY)
                    
                    VALUES
                    ('#THIS_FUNDCENTER#',
                    '#THIS_BUS_AREA#',
                    '#THIS_GL#',
                    #ROUND(ThisPeriodAmount)#,
                    0,
                    '#THIS_REV_EXP#',
                    '#ThisPeriod#',
                    '#session.pbt_PREF_DEF_FY#')
            </cfquery>
            <cfset ThisPeriod = ThisPeriod + 1>
        </cfloop>
     </cfif>
</cfoutput>