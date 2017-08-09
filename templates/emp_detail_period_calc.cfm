
<!--- NEW SECTION --->
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
<cfset Variables.Month_End = "07/31/" & THIS.FY - 1>

<!--- New Logic... --->
<cfif datecompare(Variables.Month_Start,Variables.Start_Date) GT 0>
	 <cfif datecompare(Variables.Month_Start,Variables.End_Date) GT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Month_Start>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
<cfelse>
	 <cfif datecompare(Variables.Month_End,Variables.Start_Date) LT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Start_Date>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
 </cfif>               			

<!--- Is the employee paid in this period? --->
<cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate) LTE 0>
   <!--- Test to see IF there is a salary change during this period --->
   <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
	   <!--- Test to see if the increase happens after the first of the month --->
	   <cfif variables.Eff_Date GT Variables.ThisPeriodStartDate>
		   <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
		   <!--- Calculate Number of Business days in this period --->
		   <cfset Variables.End_Period1 = variables.Eff_Date - 1>
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(ThisPeriodStartDate,Variables.End_Period1)>
		   
		   <!--- Calculate Fixed amounts - this is independent of any salary change --->
		   <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
		   <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
		   <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	   
		   <!--- Add all appropriate amounts to the FB_AMT_FP --->
		   <cfset Variables.salary_FP01 = round(ThisPeriodSalary)>
		   <cfset Variables.FB_AMT_FP01 = round(Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
		   <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP01>
		   <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP01>
		   
		   <!--- Now handle the 2nd part of the period at the NEW salary level --->
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Eff_Date,Variables.ThisPeriodEndDate)>
		   
		   <!--- Calculate Fixed component - this is independent of any salary change --->
		   <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * This_IT0027_EDIT / 100>
		   <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
		   <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
		   
		   <!--- Add all appropriate amounts to the FB_AMT_FP --->
		   <cfset Variables.salary_FP01 = round(Variables.salary_FP01 + ThisPeriodSalary)>
		   <cfset Variables.FB_AMT_FP01 = round(Variables.FB_AMT_FP01 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
		   <cfset This_Total_Salary1 = Variables.salary_FP01 - This_Total_Salary1>
		   <cfset This_Total_Fringe1 = Variables.FB_AMT_FP01 - This_Total_Fringe1>
	   <cfelse>
		   <!--- Calculate all amounts on New_salary --->
		   <!--- Calculate Number of Business days in this period --->
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
		   
		   <!--- Calculate Fixed component - this is independent of any salary change --->
		   <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
		   <cfset ThisPeriodSalary = Variables.NEW_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
		   <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
		   
		   <!--- Add all appropriate amounts to the FB_AMT_FP --->
		   <cfset Variables.salary_FP01 = round(Variables.salary_FP01 + ThisPeriodSalary)>
		   <cfset Variables.FB_AMT_FP01 = round(Variables.FB_AMT_FP01 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
		   <cfset This_Total_Salary1 = Variables.salary_FP01>
		   <cfset This_Total_Fringe1 = Variables.FB_AMT_FP01>
	   </cfif>
   <!--- Test to see IF there is a salary change BEFORE this period --->
   <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) LT 0>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
	  
	  <!--- Calculate Fixed component - this is independent of any salary change --->
	  <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
	  <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  
	  <!--- Add all appropriate amounts to the FB_AMT_FP --->
	  <cfset Variables.salary_FP01 = round(Variables.salary_FP01 + ThisPeriodSalary)>
	  <cfset Variables.FB_AMT_FP01 = round(Variables.FB_AMT_FP01 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
	  <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP01>
	  <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP01>

   <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
   <cfelse>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
	  <!--- Calculate Fixed component - this is independent of any salary change --->
	  <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
	  <cfset ThisPeriodSalary = Variables.Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * ThisFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  
	  <!--- Add all appropriate amounts to the FB_AMT_FP --->
	  <cfset Variables.salary_FP01 = round(Variables.salary_FP01 + ThisPeriodSalary)>
	  <cfset Variables.FB_AMT_FP01 = round(Variables.FB_AMT_FP01 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
	  <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP01>
	  <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP01>
   </cfif>
</cfif>

<!--- FP02 --->
<cfset Variables.Month_Start = "08/01/" & THIS.FY - 1>
<cfset Variables.FP02_End_Date = "08/31/" & THIS.FY - 1>
<cfset Variables.Month_End = "08/31/" & THIS.FY - 1>

<!--- New Logic... --->
<cfif datecompare(Variables.Month_Start,Variables.Start_Date) GT 0>
	 <cfif datecompare(Variables.Month_Start,Variables.End_Date) GT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Month_Start>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
<cfelse>
	 <cfif datecompare(Variables.Month_End,Variables.Start_Date) LT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Start_Date>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
 </cfif>               			

<!--- Is the employee paid in this period? --->
<cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate) LTE 0>
   <!--- Test to see IF there is a salary change during this period --->
   <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
	   <!--- Test to see if the increase happens after the first of the month --->
	   <cfif variables.Eff_Date GT Variables.ThisPeriodStartDate>
		   <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
		   <!--- Calculate Number of Business days in this period --->
		   <cfset Variables.End_Period1 = variables.Eff_Date - 1>
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(ThisPeriodStartDate,Variables.End_Period1)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Eff_Date,Variables.ThisPeriodEndDate)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
		   
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
   <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) LT 0>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
	  
	  <!--- Calculate Fixed component - this is independent of any salary change --->
	  <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
	  <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  
	  <!--- Add all appropriate amounts to the FB_AMT_FP --->
	  <cfset Variables.salary_FP02 = round(Variables.salary_FP02 + ThisPeriodSalary)>
	  <cfset Variables.FB_AMT_FP02 = round(Variables.FB_AMT_FP02 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
	  <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP02>
	  <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP02>

   <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
   <cfelse>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
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
<cfset Variables.Month_End = "09/30/" & THIS.FY - 1>
<cfset Variables.FP03_End_Date = "09/30/" & THIS.FY - 1>

<!--- New Logic... --->
<cfif datecompare(Variables.Month_Start,Variables.Start_Date) GT 0>
	 <cfif datecompare(Variables.Month_Start,Variables.End_Date) GT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Month_Start>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
<cfelse>
	 <cfif datecompare(Variables.Month_End,Variables.Start_Date) LT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Start_Date>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
 </cfif>               			

<!--- Is the employee paid in this period? --->
<cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate) LTE 0>
   <!--- Test to see IF there is a salary change during this period --->
   <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
	   <!--- Test to see if the increase happens after the first of the month --->
	   <cfif variables.Eff_Date GT Variables.ThisPeriodStartDate>
		   <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
		   <!--- Calculate Number of Business days in this period --->
		   <cfset Variables.End_Period1 = variables.Eff_Date - 1>
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(ThisPeriodStartDate,Variables.End_Period1)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Eff_Date,Variables.ThisPeriodEndDate)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
		   
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
   <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) LT 0>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
	  
	  <!--- Calculate Fixed component - this is independent of any salary change --->
	  <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
	  <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  
	  <!--- Add all appropriate amounts to the FB_AMT_FP --->
	  <cfset Variables.salary_FP03 = round(Variables.salary_FP03 + ThisPeriodSalary)>
	  <cfset Variables.FB_AMT_FP03 = round(Variables.FB_AMT_FP03 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
	  <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP03>
	  <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP03>

   <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
   <cfelse>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
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
<cfset Variables.Month_End = "10/31/" & THIS.FY - 1>

<!--- New Logic... --->
<cfif datecompare(Variables.Month_Start,Variables.Start_Date) GT 0>
	 <cfif datecompare(Variables.Month_Start,Variables.End_Date) GT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Month_Start>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
<cfelse>
	 <cfif datecompare(Variables.Month_End,Variables.Start_Date) LT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Start_Date>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
 </cfif>               			

<!--- Is the employee paid in this period? --->
<cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate) LTE 0>
   <!--- Test to see IF there is a salary change during this period --->
   <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
	   <!--- Test to see if the increase happens after the first of the month --->
	   <cfif variables.Eff_Date GT Variables.ThisPeriodStartDate>
		   <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
		   <!--- Calculate Number of Business days in this period --->
		   <cfset Variables.End_Period1 = variables.Eff_Date - 1>
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(ThisPeriodStartDate,Variables.End_Period1)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Eff_Date,Variables.ThisPeriodEndDate)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
		   
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
   <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) LT 0>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
	  
	  <!--- Calculate Fixed component - this is independent of any salary change --->
	  <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
	  <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  
	  <!--- Add all appropriate amounts to the FB_AMT_FP --->
	  <cfset Variables.salary_FP04 = round(Variables.salary_FP04 + ThisPeriodSalary)>
	  <cfset Variables.FB_AMT_FP04 = round(Variables.FB_AMT_FP04 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
	  <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP04>
	  <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP04>

   <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
   <cfelse>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
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
<cfset Variables.Month_End = "11/30/" & THIS.FY - 1>

<!--- New Logic... --->
<cfif datecompare(Variables.Month_Start,Variables.Start_Date) GT 0>
	 <cfif datecompare(Variables.Month_Start,Variables.End_Date) GT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Month_Start>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
<cfelse>
	 <cfif datecompare(Variables.Month_End,Variables.Start_Date) LT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Start_Date>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
 </cfif>               			

<!--- Is the employee paid in this period? --->
<cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate) LTE 0>
   <!--- Test to see IF there is a salary change during this period --->
   <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
	   <!--- Test to see if the increase happens after the first of the month --->
	   <cfif variables.Eff_Date GT Variables.ThisPeriodStartDate>
		   <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
		   <!--- Calculate Number of Business days in this period --->
		   <cfset Variables.End_Period1 = variables.Eff_Date - 1>
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(ThisPeriodStartDate,Variables.End_Period1)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Eff_Date,Variables.ThisPeriodEndDate)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
		   
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
   <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) LT 0>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
	  
	  <!--- Calculate Fixed component - this is independent of any salary change --->
	  <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
	  <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  
	  <!--- Add all appropriate amounts to the FB_AMT_FP --->
	  <cfset Variables.salary_FP05 = round(Variables.salary_FP05 + ThisPeriodSalary)>
	  <cfset Variables.FB_AMT_FP05 = round(Variables.FB_AMT_FP05 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
	  <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP05>
	  <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP05>

   <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
   <cfelse>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
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
<cfset Variables.Month_End = "12/31/" & THIS.FY - 1>

<!--- New Logic... --->
<cfif datecompare(Variables.Month_Start,Variables.Start_Date) GT 0>
	 <cfif datecompare(Variables.Month_Start,Variables.End_Date) GT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Month_Start>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
<cfelse>
	 <cfif datecompare(Variables.Month_End,Variables.Start_Date) LT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Start_Date>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
 </cfif>               			

<!--- Is the employee paid in this period? --->
<cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate) LTE 0>
   <!--- Test to see IF there is a salary change during this period --->
   <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
	   <!--- Test to see if the increase happens after the first of the month --->
	   <cfif variables.Eff_Date GT Variables.ThisPeriodStartDate>
		   <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
		   <!--- Calculate Number of Business days in this period --->
		   <cfset Variables.End_Period1 = variables.Eff_Date - 1>
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(ThisPeriodStartDate,Variables.End_Period1)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Eff_Date,Variables.ThisPeriodEndDate)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
		   
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
   <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) LT 0>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
	  
	  <!--- Calculate Fixed component - this is independent of any salary change --->
	  <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
	  <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  
	  <!--- Add all appropriate amounts to the FB_AMT_FP --->
	  <cfset Variables.salary_FP06 = round(Variables.salary_FP06 + ThisPeriodSalary)>
	  <cfset Variables.FB_AMT_FP06 = round(Variables.FB_AMT_FP06 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
	  <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP06>
	  <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP06>

   <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
   <cfelse>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
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
<cfset Variables.Month_End = "01/31/" & THIS.FY>

<!--- New Logic... --->
<cfif datecompare(Variables.Month_Start,Variables.Start_Date) GT 0>
	 <cfif datecompare(Variables.Month_Start,Variables.End_Date) GT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Month_Start>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
<cfelse>
	 <cfif datecompare(Variables.Month_End,Variables.Start_Date) LT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Start_Date>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
 </cfif>               			

<!--- Is the employee paid in this period? --->
<cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate) LTE 0>
   <!--- Test to see IF there is a salary change during this period --->
   <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
	   <!--- Test to see if the increase happens after the first of the month --->
	   <cfif variables.Eff_Date GT Variables.ThisPeriodStartDate>
		   <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
		   <!--- Calculate Number of Business days in this period --->
		   <cfset Variables.End_Period1 = variables.Eff_Date - 1>
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(ThisPeriodStartDate,Variables.End_Period1)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Eff_Date,Variables.ThisPeriodEndDate)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
		   
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
   <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) LT 0>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
	  
	  <!--- Calculate Fixed component - this is independent of any salary change --->
	  <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
	  <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  
	  <!--- Add all appropriate amounts to the FB_AMT_FP --->
	  <cfset Variables.salary_FP07 = round(Variables.salary_FP07 + ThisPeriodSalary)>
	  <cfset Variables.FB_AMT_FP07 = round(Variables.FB_AMT_FP07 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
	  <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP07>
	  <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP07>

   <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
   <cfelse>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
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
<cfif isleapyear(THIS.FY)>
	<cfset Variables.FP08_End_Date = "02/29/" & THIS.FY>
	<cfset Variables.Month_End = "02/29/" & THIS.FY>
<cfelse>
	<cfset Variables.FP08_End_Date = "02/28/" & THIS.FY>
	<cfset Variables.Month_End = "02/28/" & THIS.FY>
</cfif>               

<!--- New Logic... --->
<cfif datecompare(Variables.Month_Start,Variables.Start_Date) GT 0>
	 <cfif datecompare(Variables.Month_Start,Variables.End_Date) GT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Month_Start>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
<cfelse>
	 <cfif datecompare(Variables.Month_End,Variables.Start_Date) LT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Start_Date>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
 </cfif>               			

<!--- Is the employee paid in this period? --->
<cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate) LTE 0>
   <!--- Test to see IF there is a salary change during this period --->
   <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
	   <!--- Test to see if the increase happens after the first of the month --->
	   <cfif variables.Eff_Date GT Variables.ThisPeriodStartDate>
		   <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
		   <!--- Calculate Number of Business days in this period --->
		   <cfset Variables.End_Period1 = variables.Eff_Date - 1>
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(ThisPeriodStartDate,Variables.End_Period1)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Eff_Date,Variables.ThisPeriodEndDate)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
		   
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
   <!--- Test to see IF there is a salary change BEFORE this period --->
   <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) LT 0>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
	  
	  <!--- Calculate Fixed component - this is independent of any salary change --->
	  <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
	  <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  
	  <!--- Add all appropriate amounts to the FB_AMT_FP --->
	  <cfset Variables.salary_FP08 = round(Variables.salary_FP08 + ThisPeriodSalary)>
	  <cfset Variables.FB_AMT_FP08 = round(Variables.FB_AMT_FP08 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
	  <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP08>
	  <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP08>

   <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
   <cfelse>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
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
<cfset Variables.Month_End = "03/31/" & THIS.FY>

<!--- New Logic... --->
<cfif datecompare(Variables.Month_Start,Variables.Start_Date) GT 0>
	 <cfif datecompare(Variables.Month_Start,Variables.End_Date) GT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Month_Start>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
<cfelse>
	 <cfif datecompare(Variables.Month_End,Variables.Start_Date) LT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Start_Date>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
 </cfif>               			

<!--- Is the employee paid in this period? --->
<cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate) LTE 0>
   <!--- Test to see IF there is a salary change during this period --->
   <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
	   <!--- Test to see if the increase happens after the first of the month --->
	   <cfif variables.Eff_Date GT Variables.ThisPeriodStartDate>
		   <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
		   <!--- Calculate Number of Business days in this period --->
		   <cfset Variables.End_Period1 = variables.Eff_Date - 1>
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(ThisPeriodStartDate,Variables.End_Period1)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Eff_Date,Variables.ThisPeriodEndDate)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
		   
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
   <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) LT 0>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
	  
	  <!--- Calculate Fixed component - this is independent of any salary change --->
	  <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
	  <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  
	  <!--- Add all appropriate amounts to the FB_AMT_FP --->
	  <cfset Variables.salary_FP09 = round(Variables.salary_FP09 + ThisPeriodSalary)>
	  <cfset Variables.FB_AMT_FP09 = round(Variables.FB_AMT_FP09 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
	  <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP09>
	  <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP09>

   <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
   <cfelse>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
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
<cfset Variables.Month_End = "04/30/" & THIS.FY>

<!--- New Logic... --->
<cfif datecompare(Variables.Month_Start,Variables.Start_Date) GT 0>
	 <cfif datecompare(Variables.Month_Start,Variables.End_Date) GT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Month_Start>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
<cfelse>
	 <cfif datecompare(Variables.Month_End,Variables.Start_Date) LT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Start_Date>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
 </cfif>               			

<!--- Is the employee paid in this period? --->
<cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate) LTE 0>
   <!--- Test to see IF there is a salary change during this period --->
   <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
	   <!--- Test to see if the increase happens after the first of the month --->
	   <cfif variables.Eff_Date GT Variables.ThisPeriodStartDate>
		   <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
		   <!--- Calculate Number of Business days in this period --->
		   <cfset Variables.End_Period1 = variables.Eff_Date - 1>
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(ThisPeriodStartDate,Variables.End_Period1)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Eff_Date,Variables.ThisPeriodEndDate)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
		   
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
   <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) LT 0>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
	  
	  <!--- Calculate Fixed component - this is independent of any salary change --->
	  <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
	  <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  
	  <!--- Add all appropriate amounts to the FB_AMT_FP --->
	  <cfset Variables.salary_FP10 = round(Variables.salary_FP10 + ThisPeriodSalary)>
	  <cfset Variables.FB_AMT_FP10 = round(Variables.FB_AMT_FP10 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
	  <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP10>
	  <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP10>

   <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
   <cfelse>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
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
<cfset Variables.Month_End = "05/31/" & THIS.FY>

<!--- New Logic... --->
<cfif datecompare(Variables.Month_Start,Variables.Start_Date) GT 0>
	 <cfif datecompare(Variables.Month_Start,Variables.End_Date) GT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Month_Start>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
<cfelse>
	 <cfif datecompare(Variables.Month_End,Variables.Start_Date) LT 0>
		 <cfset Variables.ThisPeriodEndDate = "null">
	 <cfelse>
		 <cfset Variables.ThisPeriodStartDate = Variables.Start_Date>
		 <cfif datecompare(Variables.End_Date,Variables.Month_End) LT 0>
			 <cfset Variables.ThisPeriodEndDate = Variables.End_Date>
		 <cfelse>
			 <cfset Variables.ThisPeriodEndDate = Variables.Month_End>
		 </cfif>
	 </cfif>
 </cfif>               			

<!--- Is the employee paid in this period? --->
<cfif Variables.ThisPeriodEndDate is not "null" and datecompare(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate) LTE 0>
   <!--- Test to see IF there is a salary change during this period --->
   <cfif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) GTE 0 and datecompare(variables.Eff_Date,Variables.ThisPeriodEndDate) LTE 0>
	   <!--- Test to see if the increase happens after the first of the month --->
	   <cfif variables.Eff_Date GT Variables.ThisPeriodStartDate>
		   <!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
		   <!--- Calculate Number of Business days in this period --->
		   <cfset Variables.End_Period1 = variables.Eff_Date - 1>
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(ThisPeriodStartDate,Variables.End_Period1)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Eff_Date,Variables.ThisPeriodEndDate)>
		   
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
		   
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
   <cfelseif trim(len(variables.Action_Type)) GT 1 and datecompare(variables.Eff_Date,Variables.ThisPeriodStartDate) LT 0>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
	  
	  <!--- Calculate Fixed component - this is independent of any salary change --->
	  <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * This_IT0027_EDIT / 100>
	  <cfset ThisPeriodSalary = Variables.New_Annual_Salary * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  
	  <!--- Add all appropriate amounts to the FB_AMT_FP --->
	  <cfset Variables.salary_FP11 = round(Variables.salary_FP11 + ThisPeriodSalary)>
	  <cfset Variables.FB_AMT_FP11 = round(Variables.FB_AMT_FP11 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
	  <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP11>
	  <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP11>

   <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
   <cfelse>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.ThisPeriodStartDate,Variables.ThisPeriodEndDate)>
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
		   <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Eff_Date,Variables.ThisPeriodEndDate)>
		   
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
	  <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * ThisNEWFringeRate / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY * This_IT0027_EDIT / 100> 
	  
	  <!--- Add all appropriate amounts to the FB_AMT_FP --->
	  <cfset Variables.salary_FP12 = round(Variables.salary_FP12 + ThisPeriodSalary)>
	  <cfset Variables.FB_AMT_FP12 = round(Variables.FB_AMT_FP12 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount)>
	  <cfset This_Total_Salary1 = This_Total_Salary1 + Variables.salary_FP12>
	  <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP12>

   <!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
   <cfelse>
	 <cfif countArbitraryDays(Variables.Start_Date,Variables.Month_Start) LT 0>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Start_Date,Variables.ThisPeriodEndDate)>
	 <cfelse>
	  <!--- Calculate Number of Business days in this period --->
	  <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variables.Month_Start,Variables.ThisPeriodEndDate)>
	 </cfif>                     
	  
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
<cfif i EQ LastRecord and AllSalary_running NEQ Variables.Blended_Total_Salary>
	<cfset ThisDiff = AllSalary_running - Variables.Blended_Total_Salary>
	<cfset ThisDiff_Fringe = AllFringe_Running - Variables.Blended_Total_Fringe>
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
 </cfif>

<!--- END NEW SECTION --->