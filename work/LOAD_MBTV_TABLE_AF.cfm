<!--- Allow 10 minutes to complete --->
<cfsetting requestTimeOut = "60000" showdebugoutput="Yes">

<CFINCLUDE Template="../templates/header.cfm">

<!---  
TEMPLATE NAME: LOAD_MBTV_TABLE.cfm
CREATION DATE: 06/06/2012 
AUTHOR: Bill Mohr (832.824.6736)
LAST MODIFIED: 12/28/2015
MODIFIED BY: Bill Mohr (832.824.6736)

SUMMARY:  This is the first initialization program for the MBTV_TABLE. This table (or a view of it) will serve to both provide data to the BCM BPC (Budget Tool) and provide data for Pediatrics internal reports. The data here will never be edited directly by users, but rather, is reflected as changes are made in the Operating budget and Header and Distribution tables, etc.

SPECIAL NOTES:
12/28/2015 Moved SS percents to variables.cfm so they're easier to keep track of and scale.
06/06/2012 Creating program - trancribing notes on draft plan of program to this code base.
--->

<!--- Clear BPC_MBTV table for this Fundcenter --->
<cfquery name="q_DeleteRecords" datasource="#THIS.DSN#">
	DELETE FROM
    	PEDI_PBT_BPC_MBTV_TABLE
    WHERE
        FY = '#session.pbt_PREF_DEF_FY#'
    AND 
    	FUNDCENTER = '#Fundcenter#'
</cfquery>

<!--- Query AF and CAP, drop amounts into fiscal period buckets minding TERM_DATE --->
<cfquery name="q_GetAF" datasource="#THIS.DSN#">
	SELECT
    	*
    FROM
    	PEDI_PBT_AF
    WHERE
        FY = '#session.pbt_PREF_DEF_FY#'
    AND 
    	FUNDCENTER = '#Fundcenter#'
</cfquery>

<cfset colList = q_GetAF.ColumnList>
<cfset l_RevenueItems = "COLL_SUPP,MEDSVCS,AWARDS,IDC_INC,AFFIL_HOSP,ACAD_SVCS,ENDOW_INC,CONTRIBUTIONS,REV_TRN_RC,TUITION,OTHER_INC,49995100,49995110,49995120,49953000">
<cfset l_ExpenseItems = "65500000,MALP_FCLTY,MALP_STAFF,MALP_STDNT,SUPP_SVCS,TRAVEL,SUBCONTRAC,RECHARGE,DEPRECIATION,IDC_BCM,IDC_OFF,FACILITIES">
<cfset RunningTotal = 0>

<!--- Next Output Contents --->
<cfoutput query="q_GetAF">
	<cfset Variables.FundType = left(right(Fundcenter,3),1)>
    
    <cfif FundType GT 2 and FundType LT 6>
        <cfquery name="q_GetTermDate" datasource="#THIS.DSN#">
            SELECT
            	BP_START_DATE,
                TERM_DATE
            FROM
                PEDI_PBT_COA
            WHERE
                FUNDCENTER = '#Fundcenter#'
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

    <cfloop index="ColName" list="#colList#">
		<cfswitch expression="#colName#">
			<!--- Exclude these AF GL's from handling --->
			<cfcase value="FUNDCENTER"></cfcase>
			<cfcase value="FY"></cfcase>
			<cfcase value="LOCK_LVL1"></cfcase>
			<cfcase value="LOCK_LVL2"></cfcase>
			<cfcase value="LOCK_LVL3"></cfcase>
			<cfcase value="GIFTS_TEMP"></cfcase>
			<!--- Process all others --->
			<cfdefaultcase>
				<cfset ThisBus_Area = left(colName,find("_",colName)-1)>
				<cfset ThisGL = right(colName,len(colName)-(find("_",colName)))>
				
                <cfif ThisGL IS "MED_SVCS">
                	<cfset ThisREV_EXP = "REV">
				<cfelseif find(ThisGL,l_RevenueItems) GT 0>
 					<cfset ThisREV_EXP = "REV">
				<cfelse>
					<cfset ThisREV_EXP = "EXP">
				</cfif>

				<cfif find("FB_",colName) GT 0>
				<cfelseif find("SAL_",colName) GT 0>
				<cfelseif find("STIPENDS",colName) GT 0>
                <cfelseif find("SPREAD_METHOD",colName) GT 0>
				<cfelseif find("AF_",colName) EQ 0>
					<cfset ThisDate = ThisStartDate>
					
                    <cfset WorkingDays = countArbitraryDays(ThisStartDate,ThisTermDate)>
                    
                    <!--- <cfdump var="#q_GetAF#"><cfabort> --->
					<cfset DailyAmount = Evaluate("q_GetAF." & colName) / WorkingDays>
                    <cfset RunningTotal = Evaluate("q_GetAF." & colName)>
					<cfset ThisPeriod = 0>

					<!--- If the total amount is 0, no calculations necessary --->
					<cfif DailyAmount NEQ 0>
						<!--- Special Handling for SUPP_SVCS --->
						<cfif ThisGL IS "SUPP_SVCS">
							<!--- Split out SUPP_SVCS --->
							<!--- SSO Factors based on Dept --->
							<cfif left(Fundcenter,5) EQ '25311'>
								<cfset SS_SUPP_FACTOR = THIS.SS_SUPP_FACTOR_RETRO>
								<cfset SS_SVCS_FACTOR = THIS.SS_SVCS_FACTOR_RETRO>
								<cfset SS_OTHER_FACTOR = THIS.SS_OTHER_FACTOR_RETRO>
							<cfelseif left(Fundcenter,3) EQ '890'>
								<cfset SS_SUPP_FACTOR = THIS.SS_SUPP_FACTOR_BIPAI>
								<cfset SS_SVCS_FACTOR = THIS.SS_SVCS_FACTOR_BIPAI>
								<cfset SS_OTHER_FACTOR = THIS.SS_OTHER_FACTOR_BIPAI>
							<cfelse>
								<cfset SS_SUPP_FACTOR = THIS.SS_SUPP_FACTOR>
								<cfset SS_SVCS_FACTOR = THIS.SS_SVCS_FACTOR>
								<cfset SS_OTHER_FACTOR = THIS.SS_OTHER_FACTOR>
							</cfif>
							<!--- Create a record for each period 1 - 12 --->
							<cfloop from="1" to="12" index="ThisPeriod">
								<cfswitch expression="#ThisPeriod#">
									<cfcase value="1">
										<cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,31) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,31)>
											<cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,31)>
											<!--- <cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))> --->
                                            <cfset ThisPeriodWorkingDays = countArbitraryDays(ThisStartDate,ThisPeriodTermDate)>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 1>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
											<cfset RunningTotal = RunningTotal - (ThisPeriodSUPP + ThisPeriodSVCS + ThisPeriodOTHER)>
										<cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,1)>
	                                        <cfset ThisPeriodTermDate = ThisTermDate>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),7,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 1>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
										<cfelse>
											<cfset ThisPeriodSUPP = 0>
											<cfset ThisPeriodSVCS = 0>
											<cfset ThisPeriodOTHER = 0>
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
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 2>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
											<cfset RunningTotal = RunningTotal - (ThisPeriodSUPP + ThisPeriodSVCS + ThisPeriodOTHER)>
										<cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,1)>
	                                        <cfset ThisPeriodTermDate = ThisTermDate>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),8,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 2>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
										<cfelse>
											<cfset ThisPeriodSUPP = 0>
											<cfset ThisPeriodSVCS = 0>
											<cfset ThisPeriodOTHER = 0>
										</cfif>
									</cfcase>
									<cfcase value="3">
										<cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,30) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,30)>
											<cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,30)>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 3>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
											<cfset RunningTotal = RunningTotal - (ThisPeriodSUPP + ThisPeriodSVCS + ThisPeriodOTHER)>
										<cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1)>
	                                        <cfset ThisPeriodTermDate = ThisTermDate>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),9,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 3>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
										<cfelse>
											<cfset ThisPeriodSUPP = 0>
											<cfset ThisPeriodSVCS = 0>
											<cfset ThisPeriodOTHER = 0>
										</cfif>
									</cfcase>
									<cfcase value="4">
										<cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,31) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,31)>
											<cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,31)>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 4>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
											<cfset RunningTotal = RunningTotal - (ThisPeriodSUPP + ThisPeriodSVCS + ThisPeriodOTHER)>
										<cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1)>
	                                        <cfset ThisPeriodTermDate = ThisTermDate>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),10,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 4>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
										<cfelse>
											<cfset ThisPeriodSUPP = 0>
											<cfset ThisPeriodSVCS = 0>
											<cfset ThisPeriodOTHER = 0>
										</cfif>
									</cfcase>
									<cfcase value="5">
										<cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,30) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,30)>
											<cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,30)>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 5>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
											<cfset RunningTotal = RunningTotal - (ThisPeriodSUPP + ThisPeriodSVCS + ThisPeriodOTHER)>
										<cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1)>
	                                        <cfset ThisPeriodTermDate = ThisTermDate>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),11,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 5>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
										<cfelse>
											<cfset ThisPeriodSUPP = 0>
											<cfset ThisPeriodSVCS = 0>
											<cfset ThisPeriodOTHER = 0>
										</cfif>
									</cfcase>
									<cfcase value="6">
										<cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,31) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,31)>
											<cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,31)>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 6>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
											<cfset RunningTotal = RunningTotal - (ThisPeriodSUPP + ThisPeriodSVCS + ThisPeriodOTHER)>
										<cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1)>
	                                        <cfset ThisPeriodTermDate = ThisTermDate>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_Start_Date#"),12,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 6>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
										<cfelse>
											<cfset ThisPeriodSUPP = 0>
											<cfset ThisPeriodSVCS = 0>
											<cfset ThisPeriodOTHER = 0>
										</cfif>
									</cfcase>
									<cfcase value="7">
										<cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,31) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,31)>
											<cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,31)>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 7>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
											<cfset RunningTotal = RunningTotal - (ThisPeriodSUPP + ThisPeriodSVCS + ThisPeriodOTHER)>
										<cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1)>
	                                        <cfset ThisPeriodTermDate = ThisTermDate>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),1,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 7>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
										<cfelse>
											<cfset ThisPeriodSUPP = 0>
											<cfset ThisPeriodSVCS = 0>
											<cfset ThisPeriodOTHER = 0>
										</cfif>
									</cfcase>
									<cfcase value="8">
										<cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,28) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,28)>
											<cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,28)>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 8>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
											<cfset RunningTotal = RunningTotal - (ThisPeriodSUPP + ThisPeriodSVCS + ThisPeriodOTHER)>
										<cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1)>
	                                        <cfset ThisPeriodTermDate = ThisTermDate>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),2,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 8>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
										<cfelse>
											<cfset ThisPeriodSUPP = 0>
											<cfset ThisPeriodSVCS = 0>
											<cfset ThisPeriodOTHER = 0>
										</cfif>
									</cfcase>
									<cfcase value="9">
										<cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,31) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,31)>
											<cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,31)>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 9>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
											<cfset RunningTotal = RunningTotal - (ThisPeriodSUPP + ThisPeriodSVCS + ThisPeriodOTHER)>
										<cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1)>
	                                        <cfset ThisPeriodTermDate = ThisTermDate>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),3,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 9>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
										<cfelse>
											<cfset ThisPeriodSUPP = 0>
											<cfset ThisPeriodSVCS = 0>
											<cfset ThisPeriodOTHER = 0>
										</cfif>
									</cfcase>
									<cfcase value="10">
										<cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,30) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,30)>
											<cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,30)>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 10>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
											<cfset RunningTotal = RunningTotal - (ThisPeriodSUPP + ThisPeriodSVCS + ThisPeriodOTHER)>
										<cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1)>
	                                        <cfset ThisPeriodTermDate = ThisTermDate>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),4,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 10>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
										<cfelse>
											<cfset ThisPeriodSUPP = 0>
											<cfset ThisPeriodSVCS = 0>
											<cfset ThisPeriodOTHER = 0>
										</cfif>
									</cfcase>
									<cfcase value="11">
										<cfif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,31) and ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,31)>
											<cfset ThisPeriodTermDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,31)>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1),CreateDate(datepart("yyyy","#ThisPeriodTermDate#"),datepart("m","#ThisPeriodTermDate#"),datepart("d","#ThisPeriodTermDate#")))>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 11>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
											<cfset RunningTotal = RunningTotal - (ThisPeriodSUPP + ThisPeriodSVCS + ThisPeriodOTHER)>
										<cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1)>
	                                        <cfset ThisPeriodTermDate = ThisTermDate>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),5,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 11>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
										<cfelse>
											<cfset ThisPeriodSUPP = 0>
											<cfset ThisPeriodSVCS = 0>
											<cfset ThisPeriodOTHER = 0>
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
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 12>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
											<cfset RunningTotal = RunningTotal - (ThisPeriodSUPP + ThisPeriodSVCS + ThisPeriodOTHER)>
										<cfelseif ThisTermDate GTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,1)>
	                                        <cfset ThisPeriodTermDate = ThisTermDate>
                                            <cfif ThisStartDate LTE CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,1)>
                                            	<cfset ThisPeriodStartDate = CreateDate(datepart("yyyy","#THIS.FY_End_Date#"),6,1)>
                                            <cfelse>
                                            	<cfset ThisPeriodStartDate = ThisStartDate>
                                            </cfif>
											<cfset ThisPeriodWorkingDays = countArbitraryDays(ThisPeriodStartDate,ThisPeriodTermDate)>
											<cfset ThisPeriodSVCS = round(ThisPeriodWorkingDays * DailyAmount * SS_SVCS_FACTOR)>
											<cfset ThisPeriodOTHER = round(ThisPeriodWorkingDays * DailyAmount * SS_OTHER_FACTOR)>
                                            <cfif ThisLastPeriod IS 12>
												<cfset ThisPeriodSUPP = RunningTotal - (ThisPeriodSVCS + ThisPeriodOTHER)>
                                            <cfelse>
												<cfset ThisPeriodSUPP = round(ThisPeriodWorkingDays * DailyAmount * SS_SUPP_FACTOR)>
                                            </cfif>
										<cfelse>
											<cfset ThisPeriodSUPP = 0>
											<cfset ThisPeriodSVCS = 0>
											<cfset ThisPeriodOTHER = 0>
										</cfif>
									</cfcase>
								</cfswitch>
                                <cfquery name="q_UpdateTable_SUP" datasource="#THIS.DSN#">
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
                                        ('#Fundcenter#',
                                        '#ThisBus_Area#',
                                        'SUPPLIES',
                                        #ROUND(ThisPeriodSUPP)#,
                                        0,
                                        'EXP',
                                        '#ThisPeriod#',
                                        '#session.pbt_PREF_DEF_FY#')
                                </cfquery>
                                <cfquery name="q_UpdateTable_SVC" datasource="#THIS.DSN#">
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
                                        ('#Fundcenter#',
                                        '#ThisBus_Area#',
                                        'SERVICES',
                                        #ROUND(ThisPeriodSVCS)#,
                                        0,
                                        'EXP',
                                        '#ThisPeriod#',
                                        '#session.pbt_PREF_DEF_FY#')
                                </cfquery>
                                <cfquery name="q_UpdateTable_OTH" datasource="#THIS.DSN#">
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
                                        ('#Fundcenter#',
                                        '#ThisBus_Area#',
                                        'OTHER_EXP',
                                        #ROUND(ThisPeriodOTHER)#,
                                        0,
                                        'EXP',
                                        '#ThisPeriod#',
                                        '#session.pbt_PREF_DEF_FY#')
                                </cfquery>
								<cfset ThisPeriod = ThisPeriod + 1>
							</cfloop>
						<cfelse>				
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
										</cfif>
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
                                        ('#Fundcenter#',
                                        '#ThisBus_Area#',
                                        '#ThisGL#',
                                        #ROUND(ThisPeriodAmount)#,
                                        0,
                                        '#ThisREV_EXP#',
                                        '#ThisPeriod#',
                                        '#session.pbt_PREF_DEF_FY#')
                                </cfquery>
								<cfset ThisPeriod = ThisPeriod + 1>
							</cfloop>
                        </cfif>
					<cfelse>
						<!--- Special Handling for SUPP_SVCS --->
						<cfif ThisGL IS "SUPP_SVCS">
							<!--- Just enter Periods 1 - 12 as zeroes --->
							<cfset ThisPeriod = 1>
							<cfloop from="1" to="12" index="ThisPeriod">
								<cfquery name="q_UpdateTable_SUP" datasource="#THIS.DSN#">
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
										('#Fundcenter#',
										'#ThisBus_Area#',
										'SUPPLIES',
										0,
										0,
										'EXP',
										'#ThisPeriod#',
										'#session.pbt_PREF_DEF_FY#')
								</cfquery>
								<cfquery name="q_UpdateTable_SVC" datasource="#THIS.DSN#">
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
										('#Fundcenter#',
										'#ThisBus_Area#',
										'SERVICES',
										0,
										0,
										'EXP',
										'#ThisPeriod#',
										'#session.pbt_PREF_DEF_FY#')
								</cfquery>
								<cfquery name="q_UpdateTable_OTH" datasource="#THIS.DSN#">
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
										('#Fundcenter#',
										'#ThisBus_Area#',
										'OTHER_EXP',
										0,
										0,
										'EXP',
										'#ThisPeriod#',
										'#session.pbt_PREF_DEF_FY#')
								</cfquery>
								<cfset ThisPeriod = ThisPeriod + 1>
							</cfloop>
						<cfelse>				
							<!--- Just enter Periods 1 - 12 as zeroes --->
							<cfset ThisPeriod = 1>
							<cfloop from="1" to="12" index="ThisPeriod">
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
										('#Fundcenter#',
										'#ThisBus_Area#',
										'#ThisGL#',
										0,
										0,
										'#ThisREV_EXP#',
										'#ThisPeriod#',
										'#session.pbt_PREF_DEF_FY#')
								</cfquery>
								<cfset ThisPeriod = ThisPeriod + 1>
							</cfloop>
						</cfif>
					</cfif>
				</cfif> 	
			</cfdefaultcase>
		</cfswitch>
	</cfloop>
</cfoutput>

<!--- <cflocation url="LOAD_MBTV_TABLE_NONPEDS_2015.cfm?Fundcenter=#URL.Fundcenter#&Execute=#URL.EXECUTE#"> --->

<cflocation url="Reports_AF.cfm">

<CFIF NOT IsDefined("FORM.Print")>
	<br><br>
<table align = "center">
	<tr>
		<td><cfinclude template = "../templates/footer.cfm"></td>
	</tr>
</table>
</cfif>