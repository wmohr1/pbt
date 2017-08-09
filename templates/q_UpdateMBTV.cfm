<!--- Calculate Daily Amounts for IDC --->
<cfscript>
	THIS_AMOUNT_DAILY = THIS_AMOUNT / WorkingDays;
	THIS_RUNNING_TOTAL = THIS_AMOUNT;
</cfscript>
  
<!--- Create a record for each period 1 - 12 --->
<cfloop from="1" to="12" index="ThisPeriod">
    <cfswitch expression="#ThisPeriod#">
        <cfcase value="1">
            <cfif ThisFirstPeriod GT 1>
                <cfset ThisPeriod_AMOUNT = 0>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,31) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,31)>
                <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,31)>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisStartDate,ThisPeriodTermDate)>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 1>
                    <cfset ThisPeriod_AMOUNT = ThisPeriod_AMOUNT>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,1)>
                <cfset ThisPeriodTermDate = ThisTermDate>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 1>
                    <cfset ThisPeriod_AMOUNT = ThisPeriod_AMOUNT>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelse>
                <cfset ThisPeriod_AMOUNT = 0>
            </cfif>
        </cfcase>
        <cfcase value="2">
            <cfif ThisFirstPeriod GT 2>
                <cfset ThisPeriod_AMOUNT = 0>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,31) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,31)>
                <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,31)>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 2>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,1)>
                <cfset ThisPeriodTermDate = ThisTermDate>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 2>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelse>
                <cfset ThisPeriod_AMOUNT = 0>
                <cfset ThisPeriod_IDC_OFF_AMOUNT = 0>
            </cfif>
        </cfcase>
        <cfcase value="3">
            <cfif ThisFirstPeriod GT 3>
                <cfset ThisPeriod_AMOUNT = 0>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,30) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,30)>
                <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,30)>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 3>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1)>
                <cfset ThisPeriodTermDate = ThisTermDate>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 3>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelse>
                <cfset ThisPeriod_AMOUNT = 0>
            </cfif>
        </cfcase>
        <cfcase value="4">
            <cfif ThisFirstPeriod GT 4>
                <cfset ThisPeriod_AMOUNT = 0>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,31) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,31)>
                <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,31)>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 4>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1)>
                <cfset ThisPeriodTermDate = ThisTermDate>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 4>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelse>
                <cfset ThisPeriod_AMOUNT = 0>
            </cfif>
        </cfcase>
        <cfcase value="5">
            <cfif ThisFirstPeriod GT 5>
                <cfset ThisPeriod_AMOUNT = 0>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,30) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,30)>
                <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,30)>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 5>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1)>
                <cfset ThisPeriodTermDate = ThisTermDate>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 5>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelse>
                <cfset ThisPeriod_AMOUNT = 0>
            </cfif>
        </cfcase>
        <cfcase value="6">
            <cfif ThisFirstPeriod GT 6>
                <cfset ThisPeriod_AMOUNT = 0>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,31) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,31)>
                <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,31)>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 6>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1)>
                <cfset ThisPeriodTermDate = ThisTermDate>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 6>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelse>
                <cfset ThisPeriod_AMOUNT = 0>
            </cfif>
        </cfcase>
        <cfcase value="7">
            <cfif ThisFirstPeriod GT 7>
                <cfset ThisPeriod_AMOUNT = 0>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,31) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,31)>
                <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,31)>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
                <cfif ThisLastPeriod IS 7>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1)>
                <cfset ThisPeriodTermDate = ThisTermDate>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 7>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelse>
                <cfset ThisPeriod_AMOUNT = 0>
            </cfif>
        </cfcase>
        <cfcase value="8">
            <cfif ThisFirstPeriod GT 8>
                <cfset ThisPeriod_AMOUNT = 0>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,28) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,28)>
                <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,28)>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
                <cfif ThisLastPeriod IS 8>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1)>
                <cfset ThisPeriodTermDate = ThisTermDate>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 8>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelse>
                <cfset ThisPeriod_AMOUNT = 0>
            </cfif>
        </cfcase>
        <cfcase value="9">
            <cfif ThisFirstPeriod GT 9>
                <cfset ThisPeriod_AMOUNT = 0>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,31) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,31)>
                <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,31)>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
                <cfif ThisLastPeriod IS 9>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1)>
                <cfset ThisPeriodTermDate = ThisTermDate>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 9>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelse>
                <cfset ThisPeriod_AMOUNT = 0>
            </cfif>
        </cfcase>
        <cfcase value="10">
            <cfif ThisFirstPeriod GT 10>
                <cfset ThisPeriod_AMOUNT = 0>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,30) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,30)>
                <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,30)>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
                <cfif ThisLastPeriod IS 10>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1)>
                <cfset ThisPeriodTermDate = ThisTermDate>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 10>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelse>
                <cfset ThisPeriod_AMOUNT = 0>
            </cfif>
        </cfcase>
        <cfcase value="11">
            <cfif ThisFirstPeriod GT 11>
                <cfset ThisPeriod_AMOUNT = 0>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,31) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,31)>
                <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,31)>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
                <cfif ThisLastPeriod IS 11>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1)>
                <cfset ThisPeriodTermDate = ThisTermDate>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 11>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelse>
                <cfset ThisPeriod_AMOUNT = 0>
            </cfif>
        </cfcase>
        <cfcase value="12">
            <cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,30) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,30)>
                <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,30)>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
                <cfif ThisLastPeriod IS 12>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,1)>
                <cfset ThisPeriodTermDate = ThisTermDate>
                <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,1)>
                    <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,1)>
                <cfelse>
                    <cfset ThisPeriodStartDate = ThisStartDate>
                </cfif>
                <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
                <cfset ThisPeriod_AMOUNT = round(ThisPeriodWorkingDays * THIS_AMOUNT_DAILY)>
                <cfif ThisLastPeriod IS 12>
                    <cfset ThisPeriod_AMOUNT = THIS_RUNNING_TOTAL>
                </cfif>
                <cfset THIS_RUNNING_TOTAL = THIS_RUNNING_TOTAL - ThisPeriod_AMOUNT>
            <cfelse>
                <cfset ThisPeriod_AMOUNT = 0>
            </cfif>
            <!--- Add logic to populate TCH FY FP13-15 --->
            <!--- FP13 --->
            <cfset ThisTCHPeriod = 13>
            <cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),7,31)>
            <cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),7,1)>
            <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
            <cfif ThisTermDate GTE THIS.FY_End_Date>
                <cfset ThisTCHPeriodAmount = THIS_AMOUNT_DAILY * ThisPeriodWorkingDays>
            <cfelse>
                <cfset ThisTCHPeriodAmount = 0>
            </cfif>                        
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
                    '#THIS_BA_LIST_ITEM#',
        		    '#THIS_GL_COMM_ITEM#',
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
            <cfif ThisTermDate GTE THIS.FY_End_Date>
                <cfset ThisTCHPeriodAmount = THIS_AMOUNT_DAILY * ThisPeriodWorkingDays>
            <cfelse>
                <cfset ThisTCHPeriodAmount = 0>
            </cfif>                        
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
                    '#THIS_BA_LIST_ITEM#',
		            '#THIS_GL_COMM_ITEM#',
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
            <cfif ThisTermDate GTE THIS.FY_End_Date>
                <cfset ThisTCHPeriodAmount = THIS_AMOUNT_DAILY * ThisPeriodWorkingDays>
            <cfelse>
                <cfset ThisTCHPeriodAmount = 0>
            </cfif>                        
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
                    '#THIS_BA_LIST_ITEM#',
		            '#THIS_GL_COMM_ITEM#',
                    #ROUND(ThisTCHPeriodAmount)#,
                    0,
                    '#THIS_REV_EXP#',
                    '#ThisTCHPeriod#',
                    '#session.pbt_PREF_DEF_FY#')
            </cfquery>

        </cfcase>
    </cfswitch>
    <cfquery name="q_UpdateTable_" datasource="#THIS.DSN#">
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
            '#THIS_BA_LIST_ITEM#',
            '#THIS_GL_COMM_ITEM#',
            #ROUND(ThisPeriod_AMOUNT)#,
            0,
            '#THIS_REV_EXP#',
            '#ThisPeriod#',
            '#session.pbt_PREF_DEF_FY#')
    </cfquery>
    <cfset ThisPeriod = ThisPeriod + 1>
</cfloop>