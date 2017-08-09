<CFINCLUDE Template="../templates/header.cfm">

<!---  
TEMPLATE NAME: emp_detail_autosubmit.cfm
CREATION DATE: 02/02/2014	
AUTHOR: Bill Mohr (832.824.6736)
LAST MODIFIED: 2/3/2014
MODIFIED BY: Bill Mohr (832.824.6736)

SUMMARY:  Calculate Salary and Fringe numbers on Dist record at a time.

SPECIAL NOTES:
--->

<!--- Use q_GetBCMIDS to customize return list of ID's to calculate salary and fringe for --->
<cfquery name="q_GetBCMIDS" datasource="#THIS.DSN#">
     SELECT
        BCM_ID,
        Annual_Salary,
        Benefit_Lvl,
        New_Annual_Salary,
        Action_Type,
        New_Hire,
        Pers_SubArea,
        Eff_Date
     FROM
        PEDI_PBT_HEADERS 
     WHERE
        FY = '2015'
     AND 
        REC_TYPE = 2
     AND
     	ORG_UNIT = '99995555'
</cfquery>

<CFLOOP query="q_GetBCMIDS">
	<!--- Set local variables from HEADERS query --->
	<cfscript>
		variables.BCM_ID = q_GetBCMIDS.BCM_ID;
		variables.Annual_Salary = q_GetBCMIDS.Annual_Salary;
		variables.New_Annual_Salary = q_GetBCMIDS.New_Annual_Salary;
		variables.Eff_Date = q_GetBCMIDS.Eff_Date;
		variables.Action_Type = q_GetBCMIDS.Action_Type;
		variables.New_Hire = q_GetBCMIDS.New_Hire;
		variables.Pers_SubArea = q_GetBCMIDS.Pers_SubArea;
		variables.Benefit_Lvl = q_GetBCMIDS.Benefit_Lvl;
		First_Period_Start_Date = createdate(val(session.pbt_PREF_DEF_FY-1),7,1);
		Last_Period_End_Date = createdate(val(session.pbt_PREF_DEF_FY),6,30);
		Last_Period_Start_Date = createdate(val(session.pbt_PREF_DEF_FY-1),7,1);
		Last_Record_End_Date = createdate(val(session.pbt_PREF_DEF_FY),6,30);
		Last_Record_Start_Date = createdate(val(session.pbt_PREF_DEF_FY-1),7,1);
		AllSalary_running = 0;
		AllFringe_running = 0;
	</cfscript>
    <cfoutput>Processing: #Variables.BCM_ID#<br /></cfoutput>
	 <!--- New Fringe Rate lookup method! Get Fringe Rate --->
     <cfquery name="q_GetFringeRate" datasource="#THIS.DSN#">
          SELECT
              *
          FROM
              PEDI_PBT_FRINGE_TABLE
          WHERE
              ANNUAL_SALARY <= #variables.Annual_Salary#
          ORDER BY
              ANNUAL_SALARY DESC
     </cfquery>
     
     <!--- Calculate Fixed Daily Amount --->
     <cfset ThisString = "THIS.Fringe_Fixed_00" & right(Variables.pers_subarea,2)>
     <cfscript>
          DailyFixedFringe = evaluate(ThisString) / THIS.Days_In_FY;
          TotalFixedFringe = evaluate(ThisString);
     </cfscript>
     
     <cfoutput query="q_GetFringeRate" maxrows="1">
     <cfset ThisVar = "q_GetFringeRate." & variables.Benefit_Lvl>
     <cfset ThisFringeRate = evaluate(ThisVar)>
     </cfoutput>
     
     <cfquery name="q_GetNEWFringeRate" datasource="#THIS.DSN#">
          SELECT
           *
          FROM
           PEDI_PBT_FRINGE_TABLE
          WHERE
           ANNUAL_SALARY <= #variables.NEW_Annual_Salary#
          ORDER BY
           ANNUAL_SALARY DESC
     </cfquery>
     
     <cfoutput query="q_GetNEWFringeRate" maxrows="1">
          <cfset ThisVar1 = "q_GetNEWFringeRate." & variables.Benefit_Lvl>
          <cfset ThisNEWFringeRate = evaluate(ThisVar1)>
     </cfoutput>    

     <!--- Now query Distribution and loop through updating Salary and fringe amounts --->
	 <cfquery name="q_GetDistribution" datasource="#THIS.DSN#">
     	SELECT
        	IT0027,
            START_DATE,
            END_DATE,
            REC_IDX
        FROM
        	PEDI_PBT_DISTRIBUTION
        WHERE
        	BCM_ID = '#variables.BCM_ID#'
        AND
        	FY = '2015'
        AND 
        	REC_TYPE = 2
		ORDER BY
             Start_Date,
             Fundcenter,
             Bus_Area
     </cfquery>
	<cfset i = 1>
    <cfset LastRecord = 0>
	<cfloop query="q_GetDistribution">
		 <cfif q_GetDistribution.currentrow EQ 1>
             <cfset First_Start_Date = q_GetDistribution.Start_Date>
         </cfif>
         
         <cfscript>
             Last_Start_Date = q_GetDistribution.Start_Date;
             Last_End_Date = q_GetDistribution.End_Date;
			 LastRecord = LastRecord + 1;
         </cfscript>
     </cfloop>

	 <!--- Check for Salary Increase and whether it occurs after start of FY. 1 FY salary if no increase or at start of FY, 2 FY Salaries if increase after start of FY --->
     <cfif trim(len(variables.Action_Type)) GT 1 and variables.eff_date GT THIS.FY_Start_Date>
          <!--- Calculate Two FY Salaries --->
          <!--- How many days from start of FY to Eff Date? (Segment 1) --->
          <cfset Segment_1_days = countArbitraryDays(THIS.FY_Start_Date,(Variables.Eff_Date - 1))>
          <cfset Segment_1_Daily_Salary = variables.Annual_Salary * (Segment_1_days / THIS.Days_In_FY) / Segment_1_days>
          <!--- Segment_2_days needs to end on Last_End_Date (was: <cfset Segment_2_days = countArbitraryDays(Variables.Eff_Date,THIS.FY_End_Date)>) --->
          <cfset Segment_2_days = countArbitraryDays(Variables.Eff_Date,Last_End_Date)>
          <cfif Segment_2_days GT 0>
             <cfset Segment_2_Daily_Salary = variables.New_Annual_Salary * (Segment_2_days / THIS.Days_In_FY) / Segment_2_days>
          <cfelse>
             <cfset Segment_2_Daily_Salary = 0>
             <cfset Segment_2_days = 0>
          </cfif>
          
          <!--- This is the new "Annual Salary" - a combination of the original Annual Salary and after the increase --->
          <cfset Variables.Fiscal_Year_Salary1 = Round(variables.Annual_Salary * (Segment_1_days / THIS.Days_In_FY))>
          <cfset Variables.Fiscal_Year_Salary2 = Round(variables.New_Annual_Salary * (Segment_2_days / THIS.Days_In_FY))>
          <cfset Blended_Total_Salary = variables.Annual_Salary * (Segment_1_days / THIS.Days_In_FY) + variables.New_Annual_Salary * (Segment_2_days / THIS.Days_In_FY)>
          <!--- Testing Output <cfoutput>Blended_Total_Salary = variables.Annual_Salary * (Segment_1_days / THIS.Days_In_FY) + variables.New_Annual_Salary * (Segment_2_days / THIS.Days_In_FY)<br>
          #Blended_Total_Salary# = #variables.Annual_Salary# * (#Segment_1_days# / #THIS.Days_In_FY#) + #variables.New_Annual_Salary# * (#Segment_2_days# / #THIS.Days_In_FY#)<br>
          #Blended_Total_Salary#</cfoutput><br> --->
     
          <cfset Variables.Fiscal_Year_Fringe1 = Round(variables.Annual_Salary * (ThisFringeRate/100) * (Segment_1_days / THIS.Days_In_FY)) + round(TotalFixedFringe * (Segment_1_days / THIS.Days_In_FY))>
          <cfset Variables.Fiscal_Year_Fringe2 = Round(variables.New_Annual_Salary * (ThisNEWFringeRate/100) * (Segment_2_days / THIS.Days_In_FY)) + round(TotalFixedFringe * (Segment_2_days / THIS.Days_In_FY))>
          <cfset Blended_Total_Fringe = Round(Variables.Fiscal_Year_Fringe1) + Round(Variables.Fiscal_Year_Fringe2)>
     <cfelseif New_Hire>
          <!--- Calculate One FY Salary --->
          <cfif First_Start_Date EQ Last_End_Date>
             <cfset Segment_1_days = 1>
          <cfelse>
             <cfset Segment_1_days = countArbitraryDays(First_Start_Date,Last_End_Date)>
          </cfif>
          
          <CFSET Variables.Fiscal_Year_Salary1 = Variables.ANNUAL_SALARY *  (Segment_1_days / THIS.Days_In_FY)>
          <cfset Variables.Fiscal_Year_Salary2 = 0>
          <CFSET Variables.Fiscal_Year_Fringe1 = Round(variables.Annual_Salary * (ThisFringeRate/100) * (Segment_1_days / THIS.Days_In_FY)) + round(TotalFixedFringe * (Segment_1_days / THIS.Days_In_FY))>
          <cfset Variables.Fiscal_Year_Fringe2 = 0>
     
          <cfset Segment_2_days = 0>
          <CFSET Variables.Daily_Salary = Variables.Fiscal_Year_Salary1 / Segment_1_days>	
          <cfif trim(len(variables.Action_Type)) GT 1>
             <cfset Blended_Total_Salary = variables.New_Annual_Salary>
          <cfelse>
             <cfset Blended_Total_Salary = Variables.Fiscal_Year_Salary1>
          </cfif>
          <cfset Blended_Total_Fringe = Variables.Fiscal_Year_Fringe1>
     <cfelse>
          <!--- Calculate One FY Salary --->
          <cfset Segment_1_days = countArbitraryDays(First_Start_Date,Last_End_Date)>
          <cfif trim(len(variables.Action_Type)) GT 1>
             <CFSET Variables.Fiscal_Year_Salary1 = Variables.NEW_ANNUAL_SALARY *  (Segment_1_days / THIS.Days_In_FY)>
             <cfset Variables.Fiscal_Year_Fringe1 = Round(variables.New_Annual_Salary * (ThisNEWFringeRate/100) * (Segment_1_days / THIS.Days_In_FY)) + round(TotalFixedFringe * (Segment_1_days / THIS.Days_In_FY))>
         <cfelse>
             <CFSET Variables.Fiscal_Year_Salary1 = Variables.ANNUAL_SALARY *  (Segment_1_days / THIS.Days_In_FY)>
             <cfset Variables.Fiscal_Year_Fringe1 = Round(variables.ANNUAL_SALARY * (ThisFringeRate/100) * (Segment_1_days / THIS.Days_In_FY)) + round(TotalFixedFringe * (Segment_1_days / THIS.Days_In_FY))>
         </cfif>
          
          <cfset Variables.Fiscal_Year_Salary2 = 0>
          <cfset Variables.Fiscal_Year_Fringe2 = 0>
          <cfset Segment_2_days = 0>
          
          <!--- I think that this formula should be <CFSET Variables.Daily_Salary = Variables.Fiscal_Year_Salary1 / Segment_1_days>	rather than <CFSET Variables.Daily_Salary = Variables.Fiscal_Year_Salary1 / Days_In_This_FY> --->
          <CFSET Variables.Daily_Salary = Variables.Fiscal_Year_Salary1 / Segment_1_days>	
         <cfset Blended_Total_Salary = Variables.Fiscal_Year_Salary1>
         <cfset Blended_Total_Fringe = Variables.Fiscal_Year_Fringe1>
     </cfif>
     
     <cfif First_Period_Start_Date EQ Last_Record_End_Date>
         <cfset Days_In_This_FY = 1>
     <cfelse>
         <CFSET Days_In_This_FY = countArbitraryDays(First_Period_Start_Date,Last_Record_End_Date)>	
     </cfif>
     <CFIF (DateCompare(Last_Record_End_Date,THIS.FY_End_Date) LT 0 OR DateCompare(First_Period_Start_Date,THIS.FY_Start_Date) GT 0) and spp_fy is THIS.FY>
     
         <!--- ANNUAL_SALARY becomes the total the employee will be paid during This FY --->
         <cfset Variables.Fiscal_Year_Salary = Variables.Fiscal_Year_Salary1 + Variables.Fiscal_Year_Salary2>
         <cfset Variables.Fiscal_Year_Fringe = Variables.Fiscal_Year_Fringe1 + Variables.Fiscal_Year_Fringe2>
         <CFSET Variables.Daily_Salary = Variables.Fiscal_Year_Salary / Days_In_This_FY>	
         <cfset PartialYear = 1>
     <CFELSE>
         <cfset PartialYear = 0>
         <CFSET Variables.Fiscal_Year_Salary = Blended_Total_Salary>
         <CFSET Variables.Fiscal_Year_Fringe = Blended_Total_Fringe>
     </CFIF>
          
     <cfloop query="q_GetDistribution">
		<cfscript>
			variables.This_IT0027_EDIT = q_GetDistribution.IT0027;
			variables.Start_Date = q_GetDistribution.Start_Date;
			variables.End_Date = q_GetDistribution.End_Date;
			variables.REC_IDX = q_GetDistribution.REC_IDX;
		</cfscript>

          <cfscript>
              FB_AMT_FP01 = 0;
              FB_AMT_FP02 = 0;
              FB_AMT_FP03 = 0;
              FB_AMT_FP04 = 0;
              FB_AMT_FP05 = 0;
              FB_AMT_FP06 = 0;
              FB_AMT_FP07 = 0;
              FB_AMT_FP08 = 0;
              FB_AMT_FP09 = 0;
              FB_AMT_FP10 = 0;
              FB_AMT_FP11 = 0;
              FB_AMT_FP12 = 0;
          
              salary_fp01 = 0;
              salary_fp02 = 0;
              salary_fp03 = 0;
              salary_fp04 = 0;
              salary_fp05 = 0;
              salary_fp06 = 0;
              salary_fp07 = 0;
              salary_fp08 = 0;
              salary_fp09 = 0;
              salary_fp10 = 0;
              salary_fp11 = 0;
              salary_fp12 = 0;
          </cfscript>
     
          <!--- Chronologically flow through calculating the totals for each period --->
          <!--- FP01 --->
          <cfset Variables.Month_Start = "07/01/" & THIS.FY - 1>
          <cfset Variables.FP01_End_Date = "07/31/" & THIS.FY - 1>
          <!--- Check the End Date to see if the period ends prior to the end of the FP --->
          <cfif datecompare(Variables.End_Date,Variables.FP01_End_Date) LT 0>
           <cfset Variables.ThisPeriodEndDate = "null">
          <cfelseif datecompare(Variables.End_Date,Variables.FP01_End_Date) EQ 0>
            <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
          <cfelse>
            <cfset Variables.ThisPeriodEndDate = Variables.FP01_End_Date>
          </cfif>
     
          <!--- Is the employee paid in this period? --->
          <cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.Start_Date,Variables.FP01_End_Date) LTE 0>
             <!--- Test to see IF there is a salary change during this period --->
             <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
                 <!--- Test to see if the increase happens after the first of the month --->
                 <cfif variables.Eff_Date GT Variables.Month_Start>
                     <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.End_Period1 = variables.Eff_Date - 1>
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Start_Date,Variables.End_Period1)>
     
                     <!--- Calculate Fixed amounts - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                 
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_fp01 = round(ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP01 = round(Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_fp01>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP01>
                     
                     <!--- Now handle the 2nd part of the period at the NEW salary level --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_fp01 = round(Variables.salary_fp01 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP01 = round(Variables.FB_AMT_FP01 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_fp01 - This_Total_Salary1>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP01 - This_Total_Fringe1>
                 <cfelse>
                     <!--- Calculate all amounts on New_salary --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Start_Date,Variables.ThisPeriodEndDate)>
     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_fp01 = round(Variables.salary_fp01 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP01 = round(Variables.FB_AMT_FP01 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_fp01>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP01>
                 </cfif>
          <!--- Test to see IF there is a salary change BEFORE this period --->
          <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) LT 0>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP01 = round(Variables.salary_FP01 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP01 = round(Variables.FB_AMT_FP01 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP01>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP01>
          
             <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
             <cfelse>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Start_Date,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_fp01 = round(Variables.salary_fp01 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP01 = round(Variables.FB_AMT_FP01 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = Variables.salary_fp01>
                <cfset This_Total_Fringe1 = Variables.FB_AMT_FP01>
            </cfif>
          </cfif>
     
          <!--- FP02 --->
          <cfset Variables.Month_Start = "08/01/" & THIS.FY - 1>
          <cfset Variables.FP02_End_Date = "08/31/" & THIS.FY - 1>
          <!--- Check the End Date to see if the period ends prior to the end of the FP --->
          <cfif datecompare(Variables.End_Date,Variables.FP02_End_Date) LT 0>
               <cfif datecompare(Variables.End_Date,Variables.Month_Start) LT 0>
                   <cfset Variables.ThisPeriodEndDate = "null">
               <cfelse>
                   <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
               </cfif>
          <cfelseif datecompare(Variables.End_Date,Variables.FP02_End_Date) EQ 0>
            <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
          <cfelse>
            <cfset Variables.ThisPeriodEndDate = Variables.FP02_End_Date>
          </cfif>
                         
          <!--- Is the employee paid in this period? --->
           <cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.Start_Date,Variables.FP02_End_Date) LTE 0>
             <!--- Test to see IF there is a salary change during this period --->
             <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
                 <!--- Test to see if the increase happens after the first of the month --->
                 <cfif variables.Eff_Date GT Variables.Month_Start>
                     <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.End_Period1 = variables.Eff_Date - 1>
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.End_Period1)>
                     
                     <!--- Calculate Fixed amounts - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                 
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP02 = round(ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP02 = round(Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP02>
                     <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP02>
                     
                     <!--- Now handle the 2nd part of the period at the NEW salary level --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP02 = round(Variables.salary_FP02 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP02 = round(Variables.FB_AMT_FP02 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP02 - This_Total_Salary1>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP02 - This_Total_Fringe1>
                 <cfelse>
                     <!--- Calculate all amounts on New_salary --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP02 = round(Variables.salary_FP02 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP02 = round(Variables.FB_AMT_FP02 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP02>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP02>
                 </cfif>
          <!--- Test to see IF there is a salary change BEFORE this period --->
          <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) LT 0>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP02 = round(Variables.salary_FP02 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP02 = round(Variables.FB_AMT_FP02 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP02>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP02>
          
             <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
             <cfelse>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP02 = round(Variables.salary_FP02 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP02 = round(Variables.FB_AMT_FP02 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP02>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP02>
            </cfif>
          </cfif>
          
          <!--- FP03 --->
          <cfset Variables.Month_Start = "09/01/" & THIS.FY - 1>
          <cfset Variables.FP03_End_Date = "09/30/" & THIS.FY - 1>
          <!--- Check the End Date to see if the period ends prior to the end of the FP --->
          <cfif datecompare(Variables.End_Date,Variables.FP03_End_Date) LT 0>
           <cfset Variables.ThisPeriodEndDate = "null">
          <cfelseif datecompare(Variables.End_Date,Variables.FP03_End_Date) EQ 0>
            <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
          <cfelse>
            <cfset Variables.ThisPeriodEndDate = Variables.FP03_End_Date>
          </cfif>
                         
          <!--- Is the employee paid in this period? --->
          <cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.Start_Date,Variables.FP03_End_Date) LTE 0>
             <!--- Test to see IF there is a salary change during this period --->
             <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
                 <!--- Test to see if the increase happens after the first of the month --->
                 <cfif variables.Eff_Date GT Variables.Month_Start>
                     <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.End_Period1 = variables.Eff_Date - 1>
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.End_Period1)>
                     
                     <!--- Calculate Fixed amounts - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                 
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP03 = round(ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP03 = round(Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP03>
                     <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP03>
                     
                     <!--- Now handle the 2nd part of the period at the NEW salary level --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP03 = round(Variables.salary_FP03 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP03 = round(Variables.FB_AMT_FP03 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP03 - This_Total_Salary1>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP03 - This_Total_Fringe1>
                 <cfelse>
                     <!--- Calculate all amounts on New_salary --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP03 = round(Variables.salary_FP03 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP03 = round(Variables.FB_AMT_FP03 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP03>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP03>
                 </cfif>
          <!--- Test to see IF there is a salary change BEFORE this period --->
          <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) LT 0>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP03 = round(Variables.salary_FP03 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP03 = round(Variables.FB_AMT_FP03 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP03>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP03>
          
             <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
             <cfelse>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP03 = round(Variables.salary_FP03 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP03 = round(Variables.FB_AMT_FP03 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP03>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP03>
            </cfif>
          </cfif>
          
          <!--- FP04 --->
          <cfset Variables.Month_Start = "10/01/" & THIS.FY - 1>
          <cfset Variables.FP04_End_Date = "10/31/" & THIS.FY - 1>
          <!--- Check the End Date to see if the period ends prior to the end of the FP --->
          <cfif datecompare(Variables.End_Date,Variables.FP04_End_Date) LT 0>
           <cfset Variables.ThisPeriodEndDate = "null">
          <cfelseif datecompare(Variables.End_Date,Variables.FP04_End_Date) EQ 0>
            <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
          <cfelse>
            <cfset Variables.ThisPeriodEndDate = Variables.FP04_End_Date>
          </cfif>
          
          <!--- Is the employee paid in this period? --->
          <cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.Start_Date,Variables.FP04_End_Date) LTE 0>
             <!--- Test to see IF there is a salary change during this period --->
             <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
                 <!--- Test to see if the increase happens after the first of the month --->
                 <cfif variables.Eff_Date GT Variables.Month_Start>
                     <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.End_Period1 = variables.Eff_Date - 1>
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.End_Period1)>
                     
                     <!--- Calculate Fixed amounts - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                 
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP04 = round(ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP04 = round(Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP04>
                     <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP04>
                     
                     <!--- Now handle the 2nd part of the period at the NEW salary level --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP04 = round(Variables.salary_FP04 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP04 = round(Variables.FB_AMT_FP04 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP04 - This_Total_Salary1>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP04 - This_Total_Fringe1>
                 <cfelse>
                     <!--- Calculate all amounts on New_salary --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP04 = round(Variables.salary_FP04 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP04 = round(Variables.FB_AMT_FP04 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP04>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP04>
                 </cfif>
          <!--- Test to see IF there is a salary change BEFORE this period --->
          <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) LT 0>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP04 = round(Variables.salary_FP04 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP04 = round(Variables.FB_AMT_FP04 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP04>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP04>
          
             <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
             <cfelse>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP04 = round(Variables.salary_FP04 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP04 = round(Variables.FB_AMT_FP04 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP04>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP04>
            </cfif>
          </cfif>
          
          <!--- FP05 --->
          <cfset Variables.Month_Start = "11/01/" & THIS.FY - 1>
          <cfset Variables.FP05_End_Date = "11/30/" & THIS.FY - 1>
          <!--- Check the End Date to see if the period ends prior to the end of the FP --->
          <cfif datecompare(Variables.End_Date,Variables.FP05_End_Date) LT 0>
           <cfset Variables.ThisPeriodEndDate = "null">
          <cfelseif datecompare(Variables.End_Date,Variables.FP05_End_Date) EQ 0>
            <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
          <cfelse>
            <cfset Variables.ThisPeriodEndDate = Variables.FP05_End_Date>
          </cfif>
          
          <!--- Is the employee paid in this period? --->
          <cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.Start_Date,Variables.FP05_End_Date) LTE 0>
             <!--- Test to see IF there is a salary change during this period --->
             <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
                 <!--- Test to see if the increase happens after the first of the month --->
                 <cfif variables.Eff_Date GT Variables.Month_Start>
                     <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.End_Period1 = variables.Eff_Date - 1>
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.End_Period1)>
                     
                     <!--- Calculate Fixed amounts - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                 
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP05 = round(ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP05 = round(Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP05>
                     <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP05>
                     
                     <!--- Now handle the 2nd part of the period at the NEW salary level --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP05 = round(Variables.salary_FP05 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP05 = round(Variables.FB_AMT_FP05 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP05 - This_Total_Salary1>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP05 - This_Total_Fringe1>
                 <cfelse>
                     <!--- Calculate all amounts on New_salary --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP05 = round(Variables.salary_FP05 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP05 = round(Variables.FB_AMT_FP05 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP05>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP05>
                 </cfif>
          <!--- Test to see IF there is a salary change BEFORE this period --->
          <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) LT 0>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP05 = round(Variables.salary_FP05 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP05 = round(Variables.FB_AMT_FP05 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP05>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP05>
          
             <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
             <cfelse>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP05 = round(Variables.salary_FP05 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP05 = round(Variables.FB_AMT_FP05 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP05>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP05>
            </cfif>
          </cfif> 
          
          <!--- FP06 --->
          <cfset Variables.Month_Start = "12/01/" & THIS.FY - 1>
          <cfset Variables.FP06_End_Date = "12/31/" & THIS.FY - 1>
          <!--- Check the End Date to see if the period ends prior to the end of the FP --->
          <cfif datecompare(Variables.End_Date,Variables.FP06_End_Date) LT 0>
           <cfset Variables.ThisPeriodEndDate = "null">
          <cfelseif datecompare(Variables.End_Date,Variables.FP06_End_Date) EQ 0>
            <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
          <cfelse>
            <cfset Variables.ThisPeriodEndDate = Variables.FP06_End_Date>
          </cfif>
          
          <!--- Is the employee paid in this period? --->
          <cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.Start_Date,Variables.FP06_End_Date) LTE 0>
             <!--- Test to see IF there is a salary change during this period --->
             <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
                 <!--- Test to see if the increase happens after the first of the month --->
                 <cfif variables.Eff_Date GT Variables.Month_Start>
                     <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.End_Period1 = variables.Eff_Date - 1>
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.End_Period1)>
                     
                     <!--- Calculate Fixed amounts - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                 
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP06 = round(ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP06 = round(Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP06>
                     <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP06>
                     
                     <!--- Now handle the 2nd part of the period at the NEW salary level --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP06 = round(Variables.salary_FP06 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP06 = round(Variables.FB_AMT_FP06 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP06 - This_Total_Salary1>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP06 - This_Total_Fringe1>
                 <cfelse>
                     <!--- Calculate all amounts on New_salary --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP06 = round(Variables.salary_FP06 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP06 = round(Variables.FB_AMT_FP06 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP06>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP06>
                 </cfif>
          <!--- Test to see IF there is a salary change BEFORE this period --->
          <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) LT 0>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP06 = round(Variables.salary_FP06 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP06 = round(Variables.FB_AMT_FP06 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP06>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP06>
          
             <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
             <cfelse>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP06 = round(Variables.salary_FP06 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP06 = round(Variables.FB_AMT_FP06 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP06>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP06>
            </cfif>
          </cfif>
                         
          <!--- FP07 --->
          <cfset Variables.Month_Start = "01/01/" & THIS.FY>
          <cfset Variables.FP07_End_Date = "01/31/" & THIS.FY>
          <!--- Check the End Date to see if the period ends prior to the end of the FP --->
          <cfif datecompare(Variables.End_Date,Variables.FP07_End_Date) LT 0>
           <cfset Variables.ThisPeriodEndDate = "null">
          <cfelseif datecompare(Variables.End_Date,Variables.FP07_End_Date) EQ 0>
            <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
          <cfelse>
            <cfset Variables.ThisPeriodEndDate = Variables.FP07_End_Date>
          </cfif>
          
          <!--- Is the employee paid in this period? --->
          <cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.Start_Date,Variables.FP07_End_Date) LTE 0>
             <!--- Test to see IF there is a salary change during this period --->
             <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
                 <!--- Test to see if the increase happens after the first of the month --->
                 <cfif variables.Eff_Date GT Variables.Month_Start>
                     <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.End_Period1 = variables.Eff_Date - 1>
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.End_Period1)>
                     
                     <!--- Calculate Fixed amounts - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                 
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP07 = round(ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP07 = round(Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP07>
                     <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP07>
                     
                     <!--- Now handle the 2nd part of the period at the NEW salary level --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP07 = round(Variables.salary_FP07 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP07 = round(Variables.FB_AMT_FP07 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP07 - This_Total_Salary1>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP07 - This_Total_Fringe1>
                 <cfelse>
                     <!--- Calculate all amounts on New_salary --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP07 = round(Variables.salary_FP07 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP07 = round(Variables.FB_AMT_FP07 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP07>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP07>
                 </cfif>
          <!--- Test to see IF there is a salary change BEFORE this period --->
          <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) LT 0>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP07 = round(Variables.salary_FP07 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP07 = round(Variables.FB_AMT_FP07 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP07>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP07>
          
             <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
             <cfelse>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP07 = round(Variables.salary_FP07 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP07 = round(Variables.FB_AMT_FP07 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP07>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP07>
            </cfif>
          </cfif>
          
          <!--- FP08 --->
          <cfset Variables.Month_Start = "02/01/" & THIS.FY>
          <cfset Variables.FP08_End_Date = "02/28/" & THIS.FY>
          <!--- Check the End Date to see if the period ends prior to the end of the FP --->
          <cfif datecompare(Variables.End_Date,Variables.FP08_End_Date) LT 0>
           <cfset Variables.ThisPeriodEndDate = "null">
          <cfelseif datecompare(Variables.End_Date,Variables.FP08_End_Date) EQ 0>
            <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
          <cfelse>
            <cfset Variables.ThisPeriodEndDate = Variables.FP08_End_Date>
          </cfif>
          
          <!--- Is the employee paid in this period? --->
          <cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.Start_Date,Variables.FP08_End_Date) LTE 0>
             <!--- Test to see IF there is a salary change during this period --->
             <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
                 <!--- Test to see if the increase happens after the first of the month --->
                 <cfif variables.Eff_Date GT Variables.Month_Start>
                     <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.End_Period1 = variables.Eff_Date - 1>
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.End_Period1)>
                     
                     <!--- Calculate Fixed amounts - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                 
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP08 = round(ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP08 = round(Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP08>
                     <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP08>
                     
                     <!--- Now handle the 2nd part of the period at the NEW salary level --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP08 = round(Variables.salary_FP08 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP08 = round(Variables.FB_AMT_FP08 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP08 - This_Total_Salary1>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP08 - This_Total_Fringe1>
                 <cfelse>
                     <!--- Calculate all amounts on New_salary --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP08 = round(Variables.salary_FP08 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP08 = round(Variables.FB_AMT_FP08 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP08>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP08>
                 </cfif>
             <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
          <!--- Test to see IF there is a salary change BEFORE this period --->
          <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) LT 0>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP08 = round(Variables.salary_FP08 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP08 = round(Variables.FB_AMT_FP08 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP08>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP08>
          
          <cfelse>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP08 = round(Variables.salary_FP08 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP08 = round(Variables.FB_AMT_FP08 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP08>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP08>
            </cfif>
          </cfif>
          
          <!--- FP09 --->
          <cfset Variables.Month_Start = "03/01/" & THIS.FY>
          <cfset Variables.FP09_End_Date = "03/31/" & THIS.FY>
          <!--- Check the End Date to see if the period ends prior to the end of the FP --->
          <cfif datecompare(Variables.End_Date,Variables.FP09_End_Date) LT 0>
           <cfset Variables.ThisPeriodEndDate = "null">
          <cfelseif datecompare(Variables.End_Date,Variables.FP09_End_Date) EQ 0>
            <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
          <cfelse>
            <cfset Variables.ThisPeriodEndDate = Variables.FP09_End_Date>
          </cfif>
          
          <!--- Is the employee paid in this period? --->
          <cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.Start_Date,Variables.FP09_End_Date) LTE 0>
             <!--- Test to see IF there is a salary change during this period --->
             <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
                 <!--- Test to see if the increase happens after the first of the month --->
                 <cfif variables.Eff_Date GT Variables.Month_Start>
                     <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.End_Period1 = variables.Eff_Date - 1>
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.End_Period1)>
                     
                     <!--- Calculate Fixed amounts - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                 
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP09 = round(ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP09 = round(Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP09>
                     <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP09>
                     
                     <!--- Now handle the 2nd part of the period at the NEW salary level --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP09 = round(Variables.salary_FP09 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP09 = round(Variables.FB_AMT_FP09 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP09 - This_Total_Salary1>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP09 - This_Total_Fringe1>
                 <cfelse>
                     <!--- Calculate all amounts on New_salary --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP09 = round(Variables.salary_FP09 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP09 = round(Variables.FB_AMT_FP09 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP09>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP09>
                 </cfif>
          <!--- Test to see IF there is a salary change BEFORE this period --->
          <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) LT 0>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP09 = round(Variables.salary_FP09 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP09 = round(Variables.FB_AMT_FP09 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP09>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP09>
          
             <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
             <cfelse>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP09 = round(Variables.salary_FP09 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP09 = round(Variables.FB_AMT_FP09 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP09>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP09>
            </cfif>
          </cfif>
          
          <!--- FP10 --->
          <cfset Variables.Month_Start = "04/01/" & THIS.FY>
          <cfset Variables.FP10_End_Date = "04/30/" & THIS.FY>
          <!--- Check the End Date to see if the period ends prior to the end of the FP --->
          <cfif datecompare(Variables.End_Date,Variables.FP10_End_Date) LT 0>
           <cfset Variables.ThisPeriodEndDate = "null">
          <cfelseif datecompare(Variables.End_Date,Variables.FP10_End_Date) EQ 0>
            <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
          <cfelse>
            <cfset Variables.ThisPeriodEndDate = Variables.FP10_End_Date>
          </cfif>
          
          <!--- Is the employee paid in this period? --->
          <cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.Start_Date,Variables.FP10_End_Date) LTE 0>
             <!--- Test to see IF there is a salary change during this period --->
             <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
                 <!--- Test to see if the increase happens after the first of the month --->
                 <cfif variables.Eff_Date GT Variables.Month_Start>
                     <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.End_Period1 = variables.Eff_Date - 1>
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.End_Period1)>
                     
                     <!--- Calculate Fixed amounts - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                 
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP10 = round(ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP10 = round(Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP10>
                     <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP10>
                     
                     <!--- Now handle the 2nd part of the period at the NEW salary level --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP10 = round(Variables.salary_FP10 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP10 = round(Variables.FB_AMT_FP10 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP10 - This_Total_Salary1>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP10 - This_Total_Fringe1>
                 <cfelse>
                     <!--- Calculate all amounts on New_salary --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP10 = round(Variables.salary_FP10 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP10 = round(Variables.FB_AMT_FP10 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP10>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP10>
                 </cfif>
          <!--- Test to see IF there is a salary change BEFORE this period --->
          <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) LT 0>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP10 = round(Variables.salary_FP10 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP10 = round(Variables.FB_AMT_FP10 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP10>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP10>
          
             <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
             <cfelse>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP10 = round(Variables.salary_FP10 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP10 = round(Variables.FB_AMT_FP10 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP10>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP10>
            </cfif>
          </cfif>
          
          <!--- FP11 --->
          <cfset Variables.Month_Start = "05/01/" & THIS.FY>
          <cfset Variables.FP11_End_Date = "05/31/" & THIS.FY>
          <!--- Check the End Date to see if the period ends prior to the end of the FP --->
          <cfif datecompare(Variables.End_Date,Variables.FP11_End_Date) LT 0>
           <cfset Variables.ThisPeriodEndDate = "null">
          <cfelseif datecompare(Variables.End_Date,Variables.FP11_End_Date) EQ 0>
            <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
          <cfelse>
            <cfset Variables.ThisPeriodEndDate = Variables.FP11_End_Date>
          </cfif>
          
          <!--- Is the employee paid in this period? --->
          <cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.Start_Date,Variables.FP11_End_Date) LTE 0>
             <!--- Test to see IF there is a salary change during this period --->
             <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
                 <!--- Test to see if the increase happens after the first of the month --->
                 <cfif variables.Eff_Date GT Variables.Month_Start>
                     <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.End_Period1 = variables.Eff_Date - 1>
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.End_Period1)>
                     
                     <!--- Calculate Fixed amounts - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                 
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP11 = round(ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP11 = round(Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP11>
                     <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP11>
                     
                     <!--- Now handle the 2nd part of the period at the NEW salary level --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP11 = round(Variables.salary_FP11 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP11 = round(Variables.FB_AMT_FP11 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP11 - This_Total_Salary1>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP11 - This_Total_Fringe1>
                 <cfelse>
                     <!--- Calculate all amounts on New_salary --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP11 = round(Variables.salary_FP11 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP11 = round(Variables.FB_AMT_FP11 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP11>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP11>
                 </cfif>
          <!--- Test to see IF there is a salary change BEFORE this period --->
          <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) LT 0>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP11 = round(Variables.salary_FP11 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP11 = round(Variables.FB_AMT_FP11 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP11>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP11>
          
             <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
             <cfelse>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP11 = round(Variables.salary_FP11 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP11 = round(Variables.FB_AMT_FP11 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP11>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP11>
            </cfif>
          </cfif>
          
          <!--- FP12 --->
          <cfset Variables.Month_Start = "06/01/" & THIS.FY>
          <cfset Variables.FP12_End_Date = "06/30/" & THIS.FY>
          <!--- Check the End Date to see if the period ends prior to the end of the FP --->
          <cfif datecompare(Variables.End_Date,Variables.FP12_End_Date) LT 0>
           <cfset Variables.ThisPeriodEndDate = "null">
          <cfelseif datecompare(Variables.End_Date,Variables.FP12_End_Date) EQ 0>
            <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
          <cfelse>
            <cfset Variables.ThisPeriodEndDate = Variables.FP12_End_Date>
          </cfif>
          
          <!--- Is the employee paid in this period? --->
          <cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.Start_Date,Variables.FP12_End_Date) LTE 0>
             <!--- Test to see IF there is a salary change during this period --->
             <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
                 <!--- Test to see if the increase happens after the first of the month --->
                 <cfif variables.Eff_Date GT Variables.Month_Start>
                     <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.End_Period1 = variables.Eff_Date - 1>
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.End_Period1)>
                     
                     <!--- Calculate Fixed amounts - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                 
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP12 = round(ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP12 = round(Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP12>
                     <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP12>
                     
                     <!--- Now handle the 2nd part of the period at the NEW salary level --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP12 = round(Variables.salary_FP12 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP12 = round(Variables.FB_AMT_FP12 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP12 - This_Total_Salary1>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP12 - This_Total_Fringe1>
                 <cfelse>
                     <!--- Calculate all amounts on New_salary --->
                     <!--- Calculate Number of Business days in this period --->
                     <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                     
                     <!--- Calculate Fixed component - this is independent of any salary change --->
                     <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                     <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                     
                     <!--- Add all appropriate amounts to the FB_AMT_FP --->
                     <cfset Variables.salary_FP12 = round(Variables.salary_FP12 + ThisPeriodSalary)>
                     <cfset Variables.FB_AMT_FP12 = round(Variables.FB_AMT_FP12 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                     <cfset This_Total_Salary1 = Variables.salary_FP12>
                     <cfset This_Total_Fringe1 = Variables.FB_AMT_FP12>
                 </cfif>
          <!--- Test to see IF there is a salary change BEFORE this period --->
          <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.Month_Start) LT 0>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP12 = round(Variables.salary_FP12 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP12 = round(Variables.FB_AMT_FP12 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP12>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP12>
     
             <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
             <cfelse>
                <!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
                
                <!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
                <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
                
                <!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.salary_FP12 = round(Variables.salary_FP12 + ThisPeriodSalary)>
                <cfset Variables.FB_AMT_FP12 = round(Variables.FB_AMT_FP12 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
                <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP12>
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP12>
            </cfif>
          
          </cfif>
     
          <cfset spp_salary = round(Variables.salary_FP01 + Variables.salary_FP02 + Variables.salary_FP03 + Variables.salary_FP04 + Variables.salary_FP05 + Variables.salary_FP06 + Variables.salary_FP07 + Variables.salary_FP08 + Variables.salary_FP09 + Variables.salary_FP10 + Variables.salary_FP11 + Variables.salary_FP12)>
          <cfset spp_fringe = round(Variables.FB_AMT_FP01 + Variables.FB_AMT_FP02 + Variables.FB_AMT_FP03 + Variables.FB_AMT_FP04 + Variables.FB_AMT_FP05 + Variables.FB_AMT_FP06 + Variables.FB_AMT_FP07 + Variables.FB_AMT_FP08 + Variables.FB_AMT_FP09 + Variables.FB_AMT_FP10 + Variables.FB_AMT_FP11 + Variables.FB_AMT_FP12)>
		  <cfset AllSalary_running = AllSalary_running + spp_salary>
          <cfset AllFringe_running = AllFringe_running + spp_fringe>
          <cfif i EQ LastRecord and AllSalary_running NEQ Variables.Fiscal_Year_Salary>
              <cfset ThisDiff = AllSalary_running - Variables.Fiscal_Year_Salary>
              <cfset ThisDiff_Fringe = AllFringe_Running - Variables.Fiscal_Year_Fringe>
              <!--- Check the end date to determine where to dump the delta --->
              <cfif Variables.ThisPeriodEndDate IS NOT "null" and datecompare(Variables.ThisPeriodEndDate,Variables.FP01_End_Date) GT 0>
               <cfif Variables.ThisPeriodEndDate IS NOT "null" and datecompare(Variables.ThisPeriodEndDate,Variables.FP02_End_Date) GT 0>
                   <cfif Variables.ThisPeriodEndDate IS NOT "null" and datecompare(Variables.ThisPeriodEndDate,Variables.FP03_End_Date) GT 0>
                       <cfif Variables.ThisPeriodEndDate IS NOT "null" and datecompare(Variables.ThisPeriodEndDate,Variables.FP04_End_Date) GT 0>
                           <cfif Variables.ThisPeriodEndDate IS NOT "null" and datecompare(Variables.ThisPeriodEndDate,Variables.FP05_End_Date) GT 0>
                               <cfif Variables.ThisPeriodEndDate IS NOT "null" and datecompare(Variables.ThisPeriodEndDate,Variables.FP06_End_Date) GT 0>
                                   <cfif Variables.ThisPeriodEndDate IS NOT "null" and datecompare(Variables.ThisPeriodEndDate,Variables.FP07_End_Date) GT 0>
                                       <cfif Variables.ThisPeriodEndDate IS NOT "null" and datecompare(Variables.ThisPeriodEndDate,Variables.FP08_End_Date) GT 0>
                                           <cfif Variables.ThisPeriodEndDate IS NOT "null" and datecompare(Variables.ThisPeriodEndDate,Variables.FP09_End_Date) GT 0>
                                               <cfif Variables.ThisPeriodEndDate IS NOT "null" and datecompare(Variables.ThisPeriodEndDate,Variables.FP10_End_Date) GT 0>
                                                   <cfif Variables.ThisPeriodEndDate IS NOT "null" and datecompare(Variables.ThisPeriodEndDate,Variables.FP11_End_Date) GT 0>
                                                       <cfset Variables.salary_FP12 = Variables.salary_FP12 - ThisDiff>
                                                       <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 - ThisDiff_Fringe>
                                                   <cfelse>
                                                       <cfset Variables.salary_FP11 = Variables.salary_FP11 - ThisDiff>
                                                       <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 - ThisDiff_Fringe>
                                                   </cfif>
                                               <cfelse>
                                                   <cfset Variables.salary_FP10 = Variables.salary_FP10 - ThisDiff>
                                                   <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 - ThisDiff_Fringe>
                                               </cfif>
                                           <cfelse>
                                               <cfset Variables.salary_FP09 = Variables.salary_FP09 - ThisDiff>
                                               <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 - ThisDiff_Fringe>
                                           </cfif>
                                       <cfelse>
                                           <cfset Variables.salary_FP08 = Variables.salary_FP08 - ThisDiff>
                                           <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 - ThisDiff_Fringe>
                                       </cfif>
                                   <cfelse>
                                       <cfset Variables.salary_FP07 = Variables.salary_FP07 - ThisDiff>
                                       <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 - ThisDiff_Fringe>
                                   </cfif>
                               <cfelse>
                                   <cfset Variables.salary_FP06 = Variables.salary_FP06 - ThisDiff>
                                   <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 - ThisDiff_Fringe>
                               </cfif>
                           <cfelse>
                               <cfset Variables.salary_FP05 = Variables.salary_FP05 - ThisDiff>
                               <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 - ThisDiff_Fringe>
                           </cfif>
                       <cfelse>
                           <cfset Variables.salary_FP04 = Variables.salary_FP04 - ThisDiff>
                           <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 - ThisDiff_Fringe>
                       </cfif>
                   <cfelse>
                       <cfset Variables.salary_FP03 = Variables.salary_FP03 - ThisDiff>
                       <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 - ThisDiff_Fringe>
                   </cfif>
               <cfelse>
                   <cfset Variables.salary_FP02 = Variables.salary_FP02 - ThisDiff>
                   <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 - ThisDiff_Fringe>
               </cfif>
           <cfelseif Variables.ThisPeriodEndDate IS NOT "null">
               <cfset Variables.salary_FP01 = Variables.salary_FP01 - ThisDiff>
               <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 - ThisDiff_Fringe>
           </cfif>
          <cfset spp_salary = round(Variables.salary_FP01 + Variables.salary_FP02 + Variables.salary_FP03 + Variables.salary_FP04 + Variables.salary_FP05 + Variables.salary_FP06 + Variables.salary_FP07 + Variables.salary_FP08 + Variables.salary_FP09 + Variables.salary_FP10 + Variables.salary_FP11 + Variables.salary_FP12)>
          <cfset spp_fringe = round(Variables.FB_AMT_FP01 + Variables.FB_AMT_FP02 + Variables.FB_AMT_FP03 + Variables.FB_AMT_FP04 + Variables.FB_AMT_FP05 + Variables.FB_AMT_FP06 + Variables.FB_AMT_FP07 + Variables.FB_AMT_FP08 + Variables.FB_AMT_FP09 + Variables.FB_AMT_FP10 + Variables.FB_AMT_FP11 + Variables.FB_AMT_FP12)>
           
               
              <!--- <cfset Variables.salary_FP12 = round(Variables.salary_FP12 - (This_Total_Salary1 - Variables.Fiscal_Year_Salary))> --->
           </cfif>
          <!--- Now that we have calculated fringe for all of our buckets. Let's update Distribution accordingly --->
          <cfquery name="q_UpdateDistribution" datasource="#THIS.DSN#">
            UPDATE
                PEDI_PBT_DISTRIBUTION
                SET 
                	salary = #spp_salary#,
                    FB_AMT = #spp_fringe#,
                     salary_FP01 = #round(Variables.salary_FP01)#,
                     salary_FP02 = #Round(Variables.salary_FP02)#,
                     salary_FP03 = #Round(Variables.salary_FP03)#,
                     salary_FP04 = #Round(Variables.salary_FP04)#,
                     salary_FP05 = #Round(Variables.salary_FP05)#,
                     salary_FP06 = #Round(Variables.salary_FP06)#,
                     salary_FP07 = #Round(Variables.salary_FP07)#,
                     salary_FP08 = #Round(Variables.salary_FP08)#,
                     salary_FP09 = #Round(Variables.salary_FP09)#,
                     salary_FP10 = #Round(Variables.salary_FP10)#,
                     salary_FP11 = #Round(Variables.salary_FP11)#,
                     salary_FP12 = #Round(Variables.salary_FP12)#,
          
                     FB_AMT_FP01 = #round(Variables.FB_AMT_FP01)#,
                     FB_AMT_FP02 = #Round(Variables.FB_AMT_FP02)#,
                     FB_AMT_FP03 = #Round(Variables.FB_AMT_FP03)#,
                     FB_AMT_FP04 = #Round(Variables.FB_AMT_FP04)#,
                     FB_AMT_FP05 = #Round(Variables.FB_AMT_FP05)#,
                     FB_AMT_FP06 = #Round(Variables.FB_AMT_FP06)#,
                     FB_AMT_FP07 = #Round(Variables.FB_AMT_FP07)#,
                     FB_AMT_FP08 = #Round(Variables.FB_AMT_FP08)#,
                     FB_AMT_FP09 = #Round(Variables.FB_AMT_FP09)#,
                     FB_AMT_FP10 = #Round(Variables.FB_AMT_FP10)#,
                     FB_AMT_FP11 = #Round(Variables.FB_AMT_FP11)#,
                     FB_AMT_FP12 = #Round(Variables.FB_AMT_FP12)#
            WHERE
                REC_IDX = '#Variables.REC_IDX#'
          </cfquery>
		<cfset i = i + 1>
     </cfloop>
 </CFLOOP>
          