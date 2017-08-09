<!---  
TEMPLATE NAME: post_periods.cfm
CREATION DATE: 12/20/2013 (or earlier)
AUTHOR: Bill Mohr (832.824.6736)
LAST MODIFIED: 12/20/2013 
MODIFIED BY: Bill Mohr (832.824.6736)

SUMMARY:  This subroutine is used to post the salary and fringe for each period to the appropriate 'bucket' in the PEDI_PBT_DISTRIBUTION table.

SPECIAL NOTES:
12/20/2013: Copied much code from the calc_fringe.cfm template only this one is much simplified.
--->

<!--- Initialize Running totals for fringe components --->
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

	This_Total_Fringe1 = 0;
	This_Total_Fringe2 = 0;
		
	ThisFP = 1;
</cfscript>
<!--- Loop through q_Get_Report_Data calculating and updating amounts --->
<cfloop query="q_Get_Report_Data">
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

		Variables.REC_IDX = q_Get_Report_Data.REC_IDX;
		TotalVarFringe = q_Get_Report_Data.FB_AMT - TotalFixedFringe;
    </cfscript>
	<!--- Chronologically flow through calculating the totals for each period --->
    <!--- FP01 --->
	<cfset Variables.Month_Start = "07/01/" & THIS.FY - 1>
    <cfset Variables.FP01_End_Date = "07/31/" & THIS.FY - 1>
    
    <!--- Is the employee paid in this period? --->
    <cfif q_Get_Report_Data.Start_Date LTE Variables.FP01_End_Date>
    	<!--- Check the End Date to see if the period ends prior to the end of the FP --->
        <cfif q_Get_Report_Data.End_Date LTE Variables.FP01_End_Date>
        	<cfset Variables.ThisPeriodEndDate = q_Get_Report_Data.End_Date>
        <cfelse>
        	<cfset Variables.ThisPeriodEndDate = Variables.FP01_End_Date>
        </cfif>
        
		<!--- Test to see IF there is a salary change during this period --->
        <cfif variables.SalChange and variables.Eff_Date GTE Variables.Month_Start and variables.Eff_Date LTE Variables.ThisPeriodEndDate>
        	<!--- Test to see if the increase happens after the first of the month --->
            <cfif variables.Eff_Date GT Variables.Month_Start>
				<!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
				<!--- Calculate Number of Business days in this period --->
            	<cfset Variables.End_Period1 = variables.Eff_Date - 1>
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.End_Period1)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP01 = Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodFAC>
                </cfif>
                
                <cfset This_Total_Fringe1 = Variables.FB_AMT_FP01>
				
                <!--- Now handle the 2nd part of the period at the NEW salary level --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
					<cfset Variables.MAXFICA_Diff = THIS.Fringe_MAX_FICA - Variables.Running_FICA>
                    <cfset Variables.Running_FICA = Variables.Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Variables.Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = Variables.MAXFICA_Diff>
                        <cfset Variables.Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
					<cfset Variables.MAXRET_Diff = THIS.Fringe_MAX_Retirement - Variables.Running_retirement>
                    <cfset Variables.Running_retirement = Variables.Running_retirement + Variables.ThisPeriodRET>
                    <cfif Variables.Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = Variables.MAXRET_Diff>
                        <cfset Variables.Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXCOMM_Diff = THIS.Fringe_MAX_Commuter - Variables.Running_commuter>
                    <cfset Variables.Running_commuter = Variables.Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Variables.Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = Variables.MAXCOMM_Diff>
                        <cfset Variables.Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXVAC_Diff = THIS.Fringe_MAX_Vacation - Variables.Running_vacation>
                    <cfset Variables.Running_vacation = Variables.Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Variables.Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = Variables.MAXVAC_Diff>
                        <cfset Variables.Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXEMER_Diff = THIS.Fringe_MAX_EmerElder - Variables.Running_emChildCare>
                    <cfset Variables.Running_emChildCare = Variables.Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Variables.Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = Variables.MAXEMER_Diff>
                        <cfset Variables.Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
					<cfset Variables.MAXFAC_Diff = THIS.Fringe_MAX_FacChSch - Variables.Running_FacultyScholarship>
                    <cfset Variables.Running_FacultyScholarship = Variables.Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Variables.Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = Variables.MAXFAC_Diff>
                        <cfset Variables.Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodFAC>
                </cfif>

                <cfset This_Total_Fringe2 = Variables.FB_AMT_FP01 - This_Total_Fringe1>
            <cfelse>
				<!--- Calculate all amounts on New_salary --->
				<!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.New_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.New_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.New_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.New_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodFAC>
                </cfif>

                <cfset This_Total_Fringe1 = Variables.FB_AMT_FP01>
            </cfif>
		<!--- Since this is the FIRST period, if there was no increase during the first period, we will calculate fringe using org salary --->
        <cfelse>
		   <!--- Calculate all amounts on Current Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP01 = Variables.FB_AMT_FP01 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe1 = Variables.FB_AMT_FP01>
       </cfif>
    </cfif>

    <!--- FP02 --->
	<cfset Variables.Month_Start = "08/01/" & THIS.FY - 1>
    <cfset Variables.FP02_End_Date = "08/31/" & THIS.FY - 1>
    
    <!--- Is the employee paid in this period? --->
    <cfif q_Get_Report_Data.Start_Date LTE Variables.FP02_End_Date and q_Get_Report_Data.End_Date GTE Variables.Month_Start>
    	<!--- Check the End Date to see if the period ends prior to the end of the FP --->
        <cfif q_Get_Report_Data.End_Date LTE Variables.FP02_End_Date>
        	<cfset Variables.ThisPeriodEndDate = q_Get_Report_Data.End_Date>
        <cfelse>
        	<cfset Variables.ThisPeriodEndDate = Variables.FP02_End_Date>
        </cfif>
        
		<!--- Test to see IF there is a salary change during this period --->
        <cfif variables.SalChange and variables.Eff_Date GTE Variables.Month_Start and variables.Eff_Date LTE Variables.ThisPeriodEndDate>
        	<!--- Test to see if the increase happens after the first of the month --->
            <cfif variables.Eff_Date GT Variables.Month_Start>
				<!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
				<!--- Calculate Number of Business days in this period --->
            	<cfset Variables.End_Period1 = variables.Eff_Date - 1>
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.End_Period1)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP02 = Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodFAC>
                </cfif>
				
                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP02>

                <!--- Now handle the 2nd part of the period at the NEW salary level --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
					<cfset Variables.MAXFICA_Diff = THIS.Fringe_MAX_FICA - Variables.Running_FICA>
                    <cfset Variables.Running_FICA = Variables.Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Variables.Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = Variables.MAXFICA_Diff>
                        <cfset Variables.Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
					<cfset Variables.MAXRET_Diff = THIS.Fringe_MAX_Retirement - Variables.Running_retirement>
                    <cfset Variables.Running_retirement = Variables.Running_retirement + Variables.ThisPeriodRET>
                    <cfif Variables.Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = Variables.MAXRET_Diff>
                        <cfset Variables.Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXCOMM_Diff = THIS.Fringe_MAX_Commuter - Variables.Running_commuter>
                    <cfset Variables.Running_commuter = Variables.Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Variables.Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = Variables.MAXCOMM_Diff>
                        <cfset Variables.Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXVAC_Diff = THIS.Fringe_MAX_Vacation - Variables.Running_vacation>
                    <cfset Variables.Running_vacation = Variables.Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Variables.Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = Variables.MAXVAC_Diff>
                        <cfset Variables.Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXEMER_Diff = THIS.Fringe_MAX_EmerElder - Variables.Running_emChildCare>
                    <cfset Variables.Running_emChildCare = Variables.Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Variables.Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = Variables.MAXEMER_Diff>
                        <cfset Variables.Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
					<cfset Variables.MAXFAC_Diff = THIS.Fringe_MAX_FacChSch - Variables.Running_FacultyScholarship>
                    <cfset Variables.Running_FacultyScholarship = Variables.Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Variables.Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = Variables.MAXFAC_Diff>
                        <cfset Variables.Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodFAC>
                </cfif>

                <cfset This_Total_Fringe2 = Variables.FB_AMT_FP02 - This_Total_Fringe1>
            <cfelse>
				<!--- Calculate all amounts on New_salary --->
				<!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.New_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.New_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.New_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.New_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodFAC>
                </cfif>

                <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP02>
            </cfif>
		<!--- Test to see IF there is a salary change BEFORE this period --->
        <cfelseif variables.SalChange and variables.Eff_Date LT Variables.Month_Start>
		   <!--- Calculate all amounts on NEW Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe2 = This_Total_Fringe2 + Variables.FB_AMT_FP02>
		<!--- Either there is an increase AFTER this period, or no increase, either way - use current salary for now --->
        <cfelse>
		   <!--- Calculate all amounts on Current Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP02 = Variables.FB_AMT_FP02 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP02>
        </cfif>
    </cfif>

    <!--- FP03 --->
	<cfset Variables.Month_Start = "09/01/" & THIS.FY - 1>
    <cfset Variables.FP03_End_Date = "09/30/" & THIS.FY - 1>
    
    <!--- Is the employee paid in this period? --->
    <cfif q_Get_Report_Data.Start_Date LTE Variables.FP03_End_Date and q_Get_Report_Data.End_Date GTE Variables.Month_Start>
    	<!--- Check the End Date to see if the period ends prior to the end of the FP --->
        <cfif q_Get_Report_Data.End_Date LTE Variables.FP03_End_Date>
        	<cfset Variables.ThisPeriodEndDate = q_Get_Report_Data.End_Date>
        <cfelse>
        	<cfset Variables.ThisPeriodEndDate = Variables.FP03_End_Date>
        </cfif>
        
		<!--- Test to see IF there is a salary change during this period --->
        <cfif variables.SalChange and variables.Eff_Date GTE Variables.Month_Start and variables.Eff_Date LTE Variables.ThisPeriodEndDate>
        	<!--- Test to see if the increase happens after the first of the month --->
            <cfif variables.Eff_Date GT Variables.Month_Start>
				<!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
				<!--- Calculate Number of Business days in this period --->
            	<cfset Variables.End_Period1 = variables.Eff_Date - 1>
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.End_Period1)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP03 = Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodFAC>
                </cfif>
				
			    <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP03>

                <!--- Now handle the 2nd part of the period at the NEW salary level --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
					<cfset Variables.MAXFICA_Diff = THIS.Fringe_MAX_FICA - Variables.Running_FICA>
                    <cfset Variables.Running_FICA = Variables.Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Variables.Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = Variables.MAXFICA_Diff>
                        <cfset Variables.Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
					<cfset Variables.MAXRET_Diff = THIS.Fringe_MAX_Retirement - Variables.Running_retirement>
                    <cfset Variables.Running_retirement = Variables.Running_retirement + Variables.ThisPeriodRET>
                    <cfif Variables.Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = Variables.MAXRET_Diff>
                        <cfset Variables.Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXCOMM_Diff = THIS.Fringe_MAX_Commuter - Variables.Running_commuter>
                    <cfset Variables.Running_commuter = Variables.Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Variables.Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = Variables.MAXCOMM_Diff>
                        <cfset Variables.Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXVAC_Diff = THIS.Fringe_MAX_Vacation - Variables.Running_vacation>
                    <cfset Variables.Running_vacation = Variables.Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Variables.Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = Variables.MAXVAC_Diff>
                        <cfset Variables.Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXEMER_Diff = THIS.Fringe_MAX_EmerElder - Variables.Running_emChildCare>
                    <cfset Variables.Running_emChildCare = Variables.Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Variables.Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = Variables.MAXEMER_Diff>
                        <cfset Variables.Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
					<cfset Variables.MAXFAC_Diff = THIS.Fringe_MAX_FacChSch - Variables.Running_FacultyScholarship>
                    <cfset Variables.Running_FacultyScholarship = Variables.Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Variables.Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = Variables.MAXFAC_Diff>
                        <cfset Variables.Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe2 = Variables.FB_AMT_FP03 - This_Total_Fringe1>
            <cfelse>
				<!--- Calculate all amounts on New_salary --->
				<!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.New_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.New_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.New_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.New_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP03>
            </cfif>
		<!--- Test to see IF there is a salary change BEFORE this period --->
        <cfelseif variables.SalChange and variables.Eff_Date LT Variables.Month_Start>
		   <!--- Calculate all amounts on NEW Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe2 = This_Total_Fringe2 + Variables.FB_AMT_FP03>
		<!--- Either there is an increase AFTER this period, or no increase, either way - use current salary for now --->
        <cfelse>
		   <!--- Calculate all amounts on Current Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP03 = Variables.FB_AMT_FP03 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP03>
        </cfif>
    </cfif>

    <!--- FP04 --->
	<cfset Variables.Month_Start = "10/01/" & THIS.FY - 1>
    <cfset Variables.FP04_End_Date = "10/31/" & THIS.FY - 1>
    
    <!--- Is the employee paid in this period? --->
    <cfif q_Get_Report_Data.Start_Date LTE Variables.FP04_End_Date and q_Get_Report_Data.End_Date GTE Variables.Month_Start>
    	<!--- Check the End Date to see if the period ends prior to the end of the FP --->
        <cfif q_Get_Report_Data.End_Date LTE Variables.FP04_End_Date>
        	<cfset Variables.ThisPeriodEndDate = q_Get_Report_Data.End_Date>
        <cfelse>
        	<cfset Variables.ThisPeriodEndDate = Variables.FP04_End_Date>
        </cfif>
        
		<!--- Test to see IF there is a salary change during this period --->
        <cfif variables.SalChange and variables.Eff_Date GTE Variables.Month_Start and variables.Eff_Date LTE Variables.ThisPeriodEndDate>
        	<!--- Test to see if the increase happens after the first of the month --->
            <cfif variables.Eff_Date GT Variables.Month_Start>
				<!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
				<!--- Calculate Number of Business days in this period --->
            	<cfset Variables.End_Period1 = variables.Eff_Date - 1>
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.End_Period1)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP04 = Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodFAC>
                </cfif>
				
	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP04>

                <!--- Now handle the 2nd part of the period at the NEW salary level --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
					<cfset Variables.MAXFICA_Diff = THIS.Fringe_MAX_FICA - Variables.Running_FICA>
                    <cfset Variables.Running_FICA = Variables.Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Variables.Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = Variables.MAXFICA_Diff>
                        <cfset Variables.Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
					<cfset Variables.MAXRET_Diff = THIS.Fringe_MAX_Retirement - Variables.Running_retirement>
                    <cfset Variables.Running_retirement = Variables.Running_retirement + Variables.ThisPeriodRET>
                    <cfif Variables.Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = Variables.MAXRET_Diff>
                        <cfset Variables.Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXCOMM_Diff = THIS.Fringe_MAX_Commuter - Variables.Running_commuter>
                    <cfset Variables.Running_commuter = Variables.Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Variables.Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = Variables.MAXCOMM_Diff>
                        <cfset Variables.Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXVAC_Diff = THIS.Fringe_MAX_Vacation - Variables.Running_vacation>
                    <cfset Variables.Running_vacation = Variables.Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Variables.Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = Variables.MAXVAC_Diff>
                        <cfset Variables.Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXEMER_Diff = THIS.Fringe_MAX_EmerElder - Variables.Running_emChildCare>
                    <cfset Variables.Running_emChildCare = Variables.Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Variables.Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = Variables.MAXEMER_Diff>
                        <cfset Variables.Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
					<cfset Variables.MAXFAC_Diff = THIS.Fringe_MAX_FacChSch - Variables.Running_FacultyScholarship>
                    <cfset Variables.Running_FacultyScholarship = Variables.Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Variables.Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = Variables.MAXFAC_Diff>
                        <cfset Variables.Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe2 = Variables.FB_AMT_FP04 - This_Total_Fringe1>
            <cfelse>
				<!--- Calculate all amounts on New_salary --->
				<!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.New_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.New_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.New_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.New_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP04>
            </cfif>
		<!--- Test to see IF there is a salary change BEFORE this period --->
        <cfelseif variables.SalChange and variables.Eff_Date LT Variables.Month_Start>
		   <!--- Calculate all amounts on NEW Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe2 = This_Total_Fringe2 + Variables.FB_AMT_FP04>
		<!--- Either there is an increase AFTER this period, or no increase, either way - use current salary for now --->
        <cfelse>
		   <!--- Calculate all amounts on Current Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP04 = Variables.FB_AMT_FP04 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP04>
        </cfif>
    </cfif>

    <!--- FP05 --->
	<cfset Variables.Month_Start = "11/01/" & THIS.FY - 1>
    <cfset Variables.FP05_End_Date = "11/30/" & THIS.FY - 1>
    
    <!--- Is the employee paid in this period? --->
    <cfif q_Get_Report_Data.Start_Date LTE Variables.FP05_End_Date and q_Get_Report_Data.End_Date GTE Variables.Month_Start>
    	<!--- Check the End Date to see if the period ends prior to the end of the FP --->
        <cfif q_Get_Report_Data.End_Date LTE Variables.FP05_End_Date>
        	<cfset Variables.ThisPeriodEndDate = q_Get_Report_Data.End_Date>
        <cfelse>
        	<cfset Variables.ThisPeriodEndDate = Variables.FP05_End_Date>
        </cfif>
        
		<!--- Test to see IF there is a salary change during this period --->
        <cfif variables.SalChange and variables.Eff_Date GTE Variables.Month_Start and variables.Eff_Date LTE Variables.ThisPeriodEndDate>
        	<!--- Test to see if the increase happens after the first of the month --->
            <cfif variables.Eff_Date GT Variables.Month_Start>
				<!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
				<!--- Calculate Number of Business days in this period --->
            	<cfset Variables.End_Period1 = variables.Eff_Date - 1>
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.End_Period1)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP05 = Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodFAC>
                </cfif>
				
	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP05>

                <!--- Now handle the 2nd part of the period at the NEW salary level --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
					<cfset Variables.MAXFICA_Diff = THIS.Fringe_MAX_FICA - Variables.Running_FICA>
                    <cfset Variables.Running_FICA = Variables.Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Variables.Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = Variables.MAXFICA_Diff>
                        <cfset Variables.Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
					<cfset Variables.MAXRET_Diff = THIS.Fringe_MAX_Retirement - Variables.Running_retirement>
                    <cfset Variables.Running_retirement = Variables.Running_retirement + Variables.ThisPeriodRET>
                    <cfif Variables.Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = Variables.MAXRET_Diff>
                        <cfset Variables.Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXCOMM_Diff = THIS.Fringe_MAX_Commuter - Variables.Running_commuter>
                    <cfset Variables.Running_commuter = Variables.Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Variables.Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = Variables.MAXCOMM_Diff>
                        <cfset Variables.Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXVAC_Diff = THIS.Fringe_MAX_Vacation - Variables.Running_vacation>
                    <cfset Variables.Running_vacation = Variables.Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Variables.Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = Variables.MAXVAC_Diff>
                        <cfset Variables.Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXEMER_Diff = THIS.Fringe_MAX_EmerElder - Variables.Running_emChildCare>
                    <cfset Variables.Running_emChildCare = Variables.Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Variables.Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = Variables.MAXEMER_Diff>
                        <cfset Variables.Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
					<cfset Variables.MAXFAC_Diff = THIS.Fringe_MAX_FacChSch - Variables.Running_FacultyScholarship>
                    <cfset Variables.Running_FacultyScholarship = Variables.Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Variables.Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = Variables.MAXFAC_Diff>
                        <cfset Variables.Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe2 = Variables.FB_AMT_FP05 - This_Total_Fringe1>
            <cfelse>
				<!--- Calculate all amounts on New_salary --->
				<!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.New_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.New_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.New_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.New_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP05>
            </cfif>
		<!--- Test to see IF there is a salary change BEFORE this period --->
        <cfelseif variables.SalChange and variables.Eff_Date LT Variables.Month_Start>
		   <!--- Calculate all amounts on NEW Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe2 = This_Total_Fringe2 + Variables.FB_AMT_FP05>
		<!--- Either there is an increase AFTER this period, or no increase, either way - use current salary for now --->
        <cfelse>
		   <!--- Calculate all amounts on Current Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP05 = Variables.FB_AMT_FP05 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP05>
        </cfif>
    </cfif>

    <!--- FP06 --->
	<cfset Variables.Month_Start = "12/01/" & THIS.FY - 1>
    <cfset Variables.FP06_End_Date = "12/31/" & THIS.FY - 1>
    
    <!--- Is the employee paid in this period? --->
    <cfif q_Get_Report_Data.Start_Date LTE Variables.FP06_End_Date and q_Get_Report_Data.End_Date GTE Variables.Month_Start>
    	<!--- Check the End Date to see if the period ends prior to the end of the FP --->
        <cfif q_Get_Report_Data.End_Date LTE Variables.FP06_End_Date>
        	<cfset Variables.ThisPeriodEndDate = q_Get_Report_Data.End_Date>
        <cfelse>
        	<cfset Variables.ThisPeriodEndDate = Variables.FP06_End_Date>
        </cfif>
        
		<!--- Test to see IF there is a salary change during this period --->
        <cfif variables.SalChange and variables.Eff_Date GTE Variables.Month_Start and variables.Eff_Date LTE Variables.ThisPeriodEndDate>
        	<!--- Test to see if the increase happens after the first of the month --->
            <cfif variables.Eff_Date GT Variables.Month_Start>
				<!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
				<!--- Calculate Number of Business days in this period --->
            	<cfset Variables.End_Period1 = variables.Eff_Date - 1>
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.End_Period1)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP06 = Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodFAC>
                </cfif>
				
	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP06>

                <!--- Now handle the 2nd part of the period at the NEW salary level --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
					<cfset Variables.MAXFICA_Diff = THIS.Fringe_MAX_FICA - Variables.Running_FICA>
                    <cfset Variables.Running_FICA = Variables.Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Variables.Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = Variables.MAXFICA_Diff>
                        <cfset Variables.Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
					<cfset Variables.MAXRET_Diff = THIS.Fringe_MAX_Retirement - Variables.Running_retirement>
                    <cfset Variables.Running_retirement = Variables.Running_retirement + Variables.ThisPeriodRET>
                    <cfif Variables.Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = Variables.MAXRET_Diff>
                        <cfset Variables.Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXCOMM_Diff = THIS.Fringe_MAX_Commuter - Variables.Running_commuter>
                    <cfset Variables.Running_commuter = Variables.Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Variables.Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = Variables.MAXCOMM_Diff>
                        <cfset Variables.Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXVAC_Diff = THIS.Fringe_MAX_Vacation - Variables.Running_vacation>
                    <cfset Variables.Running_vacation = Variables.Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Variables.Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = Variables.MAXVAC_Diff>
                        <cfset Variables.Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXEMER_Diff = THIS.Fringe_MAX_EmerElder - Variables.Running_emChildCare>
                    <cfset Variables.Running_emChildCare = Variables.Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Variables.Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = Variables.MAXEMER_Diff>
                        <cfset Variables.Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
					<cfset Variables.MAXFAC_Diff = THIS.Fringe_MAX_FacChSch - Variables.Running_FacultyScholarship>
                    <cfset Variables.Running_FacultyScholarship = Variables.Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Variables.Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = Variables.MAXFAC_Diff>
                        <cfset Variables.Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe2 = Variables.FB_AMT_FP06 - This_Total_Fringe1>
            <cfelse>
				<!--- Calculate all amounts on New_salary --->
				<!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.New_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.New_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.New_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.New_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP06>
            </cfif>
		<!--- Test to see IF there is a salary change BEFORE this period --->
        <cfelseif variables.SalChange and variables.Eff_Date LT Variables.Month_Start>
		   <!--- Calculate all amounts on NEW Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe2 = This_Total_Fringe2 + Variables.FB_AMT_FP06>
		<!--- Either there is an increase AFTER this period, or no increase, either way - use current salary for now --->
        <cfelse>
		   <!--- Calculate all amounts on Current Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP06 = Variables.FB_AMT_FP06 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP06>
        </cfif>
    </cfif>

    <!--- FP07 --->
	<cfset Variables.Month_Start = "01/01/" & THIS.FY>
    <cfset Variables.FP07_End_Date = "01/31/" & THIS.FY>
    
    <!--- Is the employee paid in this period? --->
    <cfif q_Get_Report_Data.Start_Date LTE Variables.FP07_End_Date and q_Get_Report_Data.End_Date GTE Variables.Month_Start>
    	<!--- Check the End Date to see if the period ends prior to the end of the FP --->
        <cfif q_Get_Report_Data.End_Date LTE Variables.FP07_End_Date>
        	<cfset Variables.ThisPeriodEndDate = q_Get_Report_Data.End_Date>
        <cfelse>
        	<cfset Variables.ThisPeriodEndDate = Variables.FP07_End_Date>
        </cfif>
        
		<!--- Test to see IF there is a salary change during this period --->
        <cfif variables.SalChange and variables.Eff_Date GTE Variables.Month_Start and variables.Eff_Date LTE Variables.ThisPeriodEndDate>
        	<!--- Test to see if the increase happens after the first of the month --->
            <cfif variables.Eff_Date GT Variables.Month_Start>
				<!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
				<!--- Calculate Number of Business days in this period --->
            	<cfset Variables.End_Period1 = variables.Eff_Date - 1>
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.End_Period1)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP07 = Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodFAC>
                </cfif>
				
	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP07>

                <!--- Now handle the 2nd part of the period at the NEW salary level --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
					<cfset Variables.MAXFICA_Diff = THIS.Fringe_MAX_FICA - Variables.Running_FICA>
                    <cfset Variables.Running_FICA = Variables.Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Variables.Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = Variables.MAXFICA_Diff>
                        <cfset Variables.Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
					<cfset Variables.MAXRET_Diff = THIS.Fringe_MAX_Retirement - Variables.Running_retirement>
                    <cfset Variables.Running_retirement = Variables.Running_retirement + Variables.ThisPeriodRET>
                    <cfif Variables.Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = Variables.MAXRET_Diff>
                        <cfset Variables.Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXCOMM_Diff = THIS.Fringe_MAX_Commuter - Variables.Running_commuter>
                    <cfset Variables.Running_commuter = Variables.Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Variables.Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = Variables.MAXCOMM_Diff>
                        <cfset Variables.Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXVAC_Diff = THIS.Fringe_MAX_Vacation - Variables.Running_vacation>
                    <cfset Variables.Running_vacation = Variables.Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Variables.Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = Variables.MAXVAC_Diff>
                        <cfset Variables.Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXEMER_Diff = THIS.Fringe_MAX_EmerElder - Variables.Running_emChildCare>
                    <cfset Variables.Running_emChildCare = Variables.Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Variables.Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = Variables.MAXEMER_Diff>
                        <cfset Variables.Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
					<cfset Variables.MAXFAC_Diff = THIS.Fringe_MAX_FacChSch - Variables.Running_FacultyScholarship>
                    <cfset Variables.Running_FacultyScholarship = Variables.Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Variables.Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = Variables.MAXFAC_Diff>
                        <cfset Variables.Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe2 = Variables.FB_AMT_FP07 - This_Total_Fringe1>
            <cfelse>
				<!--- Calculate all amounts on New_salary --->
				<!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.New_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.New_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.New_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.New_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP07>
            </cfif>
		<!--- Test to see IF there is a salary change BEFORE this period --->
        <cfelseif variables.SalChange and variables.Eff_Date LT Variables.Month_Start>
		   <!--- Calculate all amounts on NEW Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe2 = This_Total_Fringe2 + Variables.FB_AMT_FP07>
		<!--- Either there is an increase AFTER this period, or no increase, either way - use current salary for now --->
        <cfelse>
		   <!--- Calculate all amounts on Current Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP07 = Variables.FB_AMT_FP07 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP07>
        </cfif>
    </cfif>

    <!--- FP08 --->
	<cfset Variables.Month_Start = "02/01/" & THIS.FY>
    <cfset Variables.FP08_End_Date = "02/28/" & THIS.FY>
    
    <!--- Is the employee paid in this period? --->
    <cfif q_Get_Report_Data.Start_Date LTE Variables.FP08_End_Date and q_Get_Report_Data.End_Date GTE Variables.Month_Start>
    	<!--- Check the End Date to see if the period ends prior to the end of the FP --->
        <cfif q_Get_Report_Data.End_Date LTE Variables.FP08_End_Date>
        	<cfset Variables.ThisPeriodEndDate = q_Get_Report_Data.End_Date>
        <cfelse>
        	<cfset Variables.ThisPeriodEndDate = Variables.FP08_End_Date>
        </cfif>
        
		<!--- Test to see IF there is a salary change during this period --->
        <cfif variables.SalChange and variables.Eff_Date GTE Variables.Month_Start and variables.Eff_Date LTE Variables.ThisPeriodEndDate>
        	<!--- Test to see if the increase happens after the first of the month --->
            <cfif variables.Eff_Date GT Variables.Month_Start>
				<!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
				<!--- Calculate Number of Business days in this period --->
            	<cfset Variables.End_Period1 = variables.Eff_Date - 1>
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.End_Period1)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP08 = Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodFAC>
                </cfif>
				
	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP08>

                <!--- Now handle the 2nd part of the period at the NEW salary level --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
					<cfset Variables.MAXFICA_Diff = THIS.Fringe_MAX_FICA - Variables.Running_FICA>
                    <cfset Variables.Running_FICA = Variables.Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Variables.Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = Variables.MAXFICA_Diff>
                        <cfset Variables.Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
					<cfset Variables.MAXRET_Diff = THIS.Fringe_MAX_Retirement - Variables.Running_retirement>
                    <cfset Variables.Running_retirement = Variables.Running_retirement + Variables.ThisPeriodRET>
                    <cfif Variables.Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = Variables.MAXRET_Diff>
                        <cfset Variables.Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXCOMM_Diff = THIS.Fringe_MAX_Commuter - Variables.Running_commuter>
                    <cfset Variables.Running_commuter = Variables.Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Variables.Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = Variables.MAXCOMM_Diff>
                        <cfset Variables.Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXVAC_Diff = THIS.Fringe_MAX_Vacation - Variables.Running_vacation>
                    <cfset Variables.Running_vacation = Variables.Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Variables.Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = Variables.MAXVAC_Diff>
                        <cfset Variables.Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXEMER_Diff = THIS.Fringe_MAX_EmerElder - Variables.Running_emChildCare>
                    <cfset Variables.Running_emChildCare = Variables.Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Variables.Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = Variables.MAXEMER_Diff>
                        <cfset Variables.Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
					<cfset Variables.MAXFAC_Diff = THIS.Fringe_MAX_FacChSch - Variables.Running_FacultyScholarship>
                    <cfset Variables.Running_FacultyScholarship = Variables.Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Variables.Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = Variables.MAXFAC_Diff>
                        <cfset Variables.Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe2 = Variables.FB_AMT_FP08 - This_Total_Fringe1>
            <cfelse>
				<!--- Calculate all amounts on New_salary --->
				<!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.New_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.New_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.New_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.New_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP08>
            </cfif>
		<!--- Test to see IF there is a salary change BEFORE this period --->
        <cfelseif variables.SalChange and variables.Eff_Date LT Variables.Month_Start>
		   <!--- Calculate all amounts on NEW Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe2 = This_Total_Fringe2 + Variables.FB_AMT_FP08>
		<!--- Either there is an increase AFTER this period, or no increase, either way - use current salary for now --->
        <cfelse>
		   <!--- Calculate all amounts on Current Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>

                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP08 = Variables.FB_AMT_FP08 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP08>
        </cfif>
    </cfif>

    <!--- FP09 --->
	<cfset Variables.Month_Start = "03/01/" & THIS.FY>
    <cfset Variables.FP09_End_Date = "03/31/" & THIS.FY>
    
    <!--- Is the employee paid in this period? --->
    <cfif q_Get_Report_Data.Start_Date LTE Variables.FP09_End_Date and q_Get_Report_Data.End_Date GTE Variables.Month_Start>
    	<!--- Check the End Date to see if the period ends prior to the end of the FP --->
        <cfif q_Get_Report_Data.End_Date LTE Variables.FP09_End_Date>
        	<cfset Variables.ThisPeriodEndDate = q_Get_Report_Data.End_Date>
        <cfelse>
        	<cfset Variables.ThisPeriodEndDate = Variables.FP09_End_Date>
        </cfif>
        
		<!--- Test to see IF there is a salary change during this period --->
        <cfif variables.SalChange and variables.Eff_Date GTE Variables.Month_Start and variables.Eff_Date LTE Variables.ThisPeriodEndDate>
        	<!--- Test to see if the increase happens after the first of the month --->
            <cfif variables.Eff_Date GT Variables.Month_Start>
				<!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
				<!--- Calculate Number of Business days in this period --->
            	<cfset Variables.End_Period1 = variables.Eff_Date - 1>
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.End_Period1)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP09 = Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodFAC>
                </cfif>
				
	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP09>

                <!--- Now handle the 2nd part of the period at the NEW salary level --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
					<cfset Variables.MAXFICA_Diff = THIS.Fringe_MAX_FICA - Variables.Running_FICA>
                    <cfset Variables.Running_FICA = Variables.Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Variables.Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = Variables.MAXFICA_Diff>
                        <cfset Variables.Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
					<cfset Variables.MAXRET_Diff = THIS.Fringe_MAX_Retirement - Variables.Running_retirement>
                    <cfset Variables.Running_retirement = Variables.Running_retirement + Variables.ThisPeriodRET>
                    <cfif Variables.Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = Variables.MAXRET_Diff>
                        <cfset Variables.Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXCOMM_Diff = THIS.Fringe_MAX_Commuter - Variables.Running_commuter>
                    <cfset Variables.Running_commuter = Variables.Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Variables.Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = Variables.MAXCOMM_Diff>
                        <cfset Variables.Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXVAC_Diff = THIS.Fringe_MAX_Vacation - Variables.Running_vacation>
                    <cfset Variables.Running_vacation = Variables.Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Variables.Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = Variables.MAXVAC_Diff>
                        <cfset Variables.Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXEMER_Diff = THIS.Fringe_MAX_EmerElder - Variables.Running_emChildCare>
                    <cfset Variables.Running_emChildCare = Variables.Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Variables.Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = Variables.MAXEMER_Diff>
                        <cfset Variables.Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
					<cfset Variables.MAXFAC_Diff = THIS.Fringe_MAX_FacChSch - Variables.Running_FacultyScholarship>
                    <cfset Variables.Running_FacultyScholarship = Variables.Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Variables.Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = Variables.MAXFAC_Diff>
                        <cfset Variables.Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe2 = Variables.FB_AMT_FP09 - This_Total_Fringe1>
            <cfelse>
				<!--- Calculate all amounts on New_salary --->
				<!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.New_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.New_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.New_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.New_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP09>
            </cfif>
		<!--- Test to see IF there is a salary change BEFORE this period --->
        <cfelseif variables.SalChange and variables.Eff_Date LT Variables.Month_Start>
		   <!--- Calculate all amounts on NEW Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe2 = This_Total_Fringe2 + Variables.FB_AMT_FP09>
		<!--- Either there is an increase AFTER this period, or no increase, either way - use current salary for now --->
        <cfelse>
		   <!--- Calculate all amounts on Current Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>

                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP09 = Variables.FB_AMT_FP09 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP09>
        </cfif>
    </cfif>

    <!--- FP10 --->
	<cfset Variables.Month_Start = "04/01/" & THIS.FY>
    <cfset Variables.FP10_End_Date = "04/30/" & THIS.FY>
    
    <!--- Is the employee paid in this period? --->
    <cfif q_Get_Report_Data.Start_Date LTE Variables.FP10_End_Date and q_Get_Report_Data.End_Date GTE Variables.Month_Start>
    	<!--- Check the End Date to see if the period ends prior to the end of the FP --->
        <cfif q_Get_Report_Data.End_Date LTE Variables.FP10_End_Date>
        	<cfset Variables.ThisPeriodEndDate = q_Get_Report_Data.End_Date>
        <cfelse>
        	<cfset Variables.ThisPeriodEndDate = Variables.FP10_End_Date>
        </cfif>
        
		<!--- Test to see IF there is a salary change during this period --->
        <cfif variables.SalChange and variables.Eff_Date GTE Variables.Month_Start and variables.Eff_Date LTE Variables.ThisPeriodEndDate>
        	<!--- Test to see if the increase happens after the first of the month --->
            <cfif variables.Eff_Date GT Variables.Month_Start>
				<!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
				<!--- Calculate Number of Business days in this period --->
            	<cfset Variables.End_Period1 = variables.Eff_Date - 1>
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.End_Period1)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP10 = Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodFAC>
                </cfif>
				
	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP10>

                <!--- Now handle the 2nd part of the period at the NEW salary level --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
					<cfset Variables.MAXFICA_Diff = THIS.Fringe_MAX_FICA - Variables.Running_FICA>
                    <cfset Variables.Running_FICA = Variables.Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Variables.Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = Variables.MAXFICA_Diff>
                        <cfset Variables.Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
					<cfset Variables.MAXRET_Diff = THIS.Fringe_MAX_Retirement - Variables.Running_retirement>
                    <cfset Variables.Running_retirement = Variables.Running_retirement + Variables.ThisPeriodRET>
                    <cfif Variables.Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = Variables.MAXRET_Diff>
                        <cfset Variables.Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXCOMM_Diff = THIS.Fringe_MAX_Commuter - Variables.Running_commuter>
                    <cfset Variables.Running_commuter = Variables.Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Variables.Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = Variables.MAXCOMM_Diff>
                        <cfset Variables.Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXVAC_Diff = THIS.Fringe_MAX_Vacation - Variables.Running_vacation>
                    <cfset Variables.Running_vacation = Variables.Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Variables.Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = Variables.MAXVAC_Diff>
                        <cfset Variables.Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXEMER_Diff = THIS.Fringe_MAX_EmerElder - Variables.Running_emChildCare>
                    <cfset Variables.Running_emChildCare = Variables.Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Variables.Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = Variables.MAXEMER_Diff>
                        <cfset Variables.Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
					<cfset Variables.MAXFAC_Diff = THIS.Fringe_MAX_FacChSch - Variables.Running_FacultyScholarship>
                    <cfset Variables.Running_FacultyScholarship = Variables.Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Variables.Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = Variables.MAXFAC_Diff>
                        <cfset Variables.Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe2 = Variables.FB_AMT_FP10 - This_Total_Fringe1>
            <cfelse>
				<!--- Calculate all amounts on New_salary --->
				<!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.New_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.New_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.New_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.New_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP10>
            </cfif>
		<!--- Test to see IF there is a salary change BEFORE this period --->
        <cfelseif variables.SalChange and variables.Eff_Date LT Variables.Month_Start>
		   <!--- Calculate all amounts on NEW Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe2 = This_Total_Fringe2 + Variables.FB_AMT_FP10>
		<!--- Either there is an increase AFTER this period, or no increase, either way - use current salary for now --->
        <cfelse>
		   <!--- Calculate all amounts on Current Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>

                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP10 = Variables.FB_AMT_FP10 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP10>
        </cfif>
    </cfif>

    <!--- FP11 --->
	<cfset Variables.Month_Start = "05/01/" & THIS.FY>
    <cfset Variables.FP11_End_Date = "05/31/" & THIS.FY>
    
    <!--- Is the employee paid in this period? --->
    <cfif q_Get_Report_Data.Start_Date LTE Variables.FP11_End_Date and q_Get_Report_Data.End_Date GTE Variables.Month_Start>
    	<!--- Check the End Date to see if the period ends prior to the end of the FP --->
        <cfif q_Get_Report_Data.End_Date LTE Variables.FP11_End_Date>
        	<cfset Variables.ThisPeriodEndDate = q_Get_Report_Data.End_Date>
        <cfelse>
        	<cfset Variables.ThisPeriodEndDate = Variables.FP11_End_Date>
        </cfif>
        
		<!--- Test to see IF there is a salary change during this period --->
        <cfif variables.SalChange and variables.Eff_Date GTE Variables.Month_Start and variables.Eff_Date LTE Variables.ThisPeriodEndDate>
        	<!--- Test to see if the increase happens after the first of the month --->
            <cfif variables.Eff_Date GT Variables.Month_Start>
				<!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
				<!--- Calculate Number of Business days in this period --->
            	<cfset Variables.End_Period1 = variables.Eff_Date - 1>
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.End_Period1)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP11 = Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodFAC>
                </cfif>
				
	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP11>

                <!--- Now handle the 2nd part of the period at the NEW salary level --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
					<cfset Variables.MAXFICA_Diff = THIS.Fringe_MAX_FICA - Variables.Running_FICA>
                    <cfset Variables.Running_FICA = Variables.Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Variables.Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = Variables.MAXFICA_Diff>
                        <cfset Variables.Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
					<cfset Variables.MAXRET_Diff = THIS.Fringe_MAX_Retirement - Variables.Running_retirement>
                    <cfset Variables.Running_retirement = Variables.Running_retirement + Variables.ThisPeriodRET>
                    <cfif Variables.Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = Variables.MAXRET_Diff>
                        <cfset Variables.Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXCOMM_Diff = THIS.Fringe_MAX_Commuter - Variables.Running_commuter>
                    <cfset Variables.Running_commuter = Variables.Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Variables.Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = Variables.MAXCOMM_Diff>
                        <cfset Variables.Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXVAC_Diff = THIS.Fringe_MAX_Vacation - Variables.Running_vacation>
                    <cfset Variables.Running_vacation = Variables.Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Variables.Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = Variables.MAXVAC_Diff>
                        <cfset Variables.Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXEMER_Diff = THIS.Fringe_MAX_EmerElder - Variables.Running_emChildCare>
                    <cfset Variables.Running_emChildCare = Variables.Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Variables.Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = Variables.MAXEMER_Diff>
                        <cfset Variables.Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
					<cfset Variables.MAXFAC_Diff = THIS.Fringe_MAX_FacChSch - Variables.Running_FacultyScholarship>
                    <cfset Variables.Running_FacultyScholarship = Variables.Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Variables.Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = Variables.MAXFAC_Diff>
                        <cfset Variables.Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe2 = Variables.FB_AMT_FP11 - This_Total_Fringe1>
            <cfelse>
				<!--- Calculate all amounts on New_salary --->
				<!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.New_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.New_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.New_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.New_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP11>
            </cfif>
		<!--- Test to see IF there is a salary change BEFORE this period --->
        <cfelseif variables.SalChange and variables.Eff_Date LT Variables.Month_Start>
		   <!--- Calculate all amounts on NEW Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe2 = This_Total_Fringe2 + Variables.FB_AMT_FP11>
		<!--- Either there is an increase AFTER this period, or no increase, either way - use current salary for now --->
        <cfelse>
		   <!--- Calculate all amounts on Current Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>

                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP11 = Variables.FB_AMT_FP11 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP11>
        </cfif>
    </cfif>

    <!--- FP12 --->
	<cfset Variables.Month_Start = "06/01/" & THIS.FY>
    <cfset Variables.FP12_End_Date = "06/30/" & THIS.FY>
    
    <!--- Is the employee paid in this period? --->
    <cfif q_Get_Report_Data.Start_Date LTE Variables.FP12_End_Date and q_Get_Report_Data.End_Date GTE Variables.Month_Start>
    	<!--- Check the End Date to see if the period ends prior to the end of the FP --->
        <cfif q_Get_Report_Data.End_Date LTE Variables.FP12_End_Date>
        	<cfset Variables.ThisPeriodEndDate = q_Get_Report_Data.End_Date>
        <cfelse>
        	<cfset Variables.ThisPeriodEndDate = Variables.FP12_End_Date>
        </cfif>
        
		<!--- Test to see IF there is a salary change during this period --->
        <cfif variables.SalChange and variables.Eff_Date GTE Variables.Month_Start and variables.Eff_Date LTE Variables.ThisPeriodEndDate>
        	<!--- Test to see if the increase happens after the first of the month --->
            <cfif variables.Eff_Date GT Variables.Month_Start>
				<!--- Calculate amounts on Current_Salary from Start of period until day before Eff_date, then New_salary after --->
				<!--- Calculate Number of Business days in this period --->
            	<cfset Variables.End_Period1 = variables.Eff_Date - 1>
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.End_Period1)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP12 = Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodFAC>
                </cfif>
				
	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP12>

                <!--- Now handle the 2nd part of the period at the NEW salary level --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(Variablese.Eff_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
					<cfset Variables.MAXFICA_Diff = THIS.Fringe_MAX_FICA - Variables.Running_FICA>
                    <cfset Variables.Running_FICA = Variables.Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Variables.Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = Variables.MAXFICA_Diff>
                        <cfset Variables.Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
					<cfset Variables.MAXRET_Diff = THIS.Fringe_MAX_Retirement - Variables.Running_retirement>
                    <cfset Variables.Running_retirement = Variables.Running_retirement + Variables.ThisPeriodRET>
                    <cfif Variables.Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = Variables.MAXRET_Diff>
                        <cfset Variables.Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXCOMM_Diff = THIS.Fringe_MAX_Commuter - Variables.Running_commuter>
                    <cfset Variables.Running_commuter = Variables.Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Variables.Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = Variables.MAXCOMM_Diff>
                        <cfset Variables.Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXVAC_Diff = THIS.Fringe_MAX_Vacation - Variables.Running_vacation>
                    <cfset Variables.Running_vacation = Variables.Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Variables.Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = Variables.MAXVAC_Diff>
                        <cfset Variables.Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
					<cfset Variables.MAXEMER_Diff = THIS.Fringe_MAX_EmerElder - Variables.Running_emChildCare>
                    <cfset Variables.Running_emChildCare = Variables.Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Variables.Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = Variables.MAXEMER_Diff>
                        <cfset Variables.Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
					<cfset Variables.MAXFAC_Diff = THIS.Fringe_MAX_FacChSch - Variables.Running_FacultyScholarship>
                    <cfset Variables.Running_FacultyScholarship = Variables.Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Variables.Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = Variables.MAXFAC_Diff>
                        <cfset Variables.Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe2 = Variables.FB_AMT_FP12 - This_Total_Fringe1>
            <cfelse>
				<!--- Calculate all amounts on New_salary --->
				<!--- Calculate Number of Business days in this period --->
                <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
                
				<!--- Calculate Fixed component - this is independent of any salary change --->
                <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
                
				<!--- Calculate Variable components --->
                <cfset Variables.ThisPeriodFICA = Variables.New_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodRET = Variables.New_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodCOMM = Variables.New_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodVAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodEMER = Variables.New_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                <cfset Variables.ThisPeriodFAC = Variables.New_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
                
                <cfset Variables.ThisPeriodNOMAX = Variables.New_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

				<!--- Add all appropriate amounts to the FB_AMT_FP --->
                <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

				<!--- Apply FICA --->
                <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
                    <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
                    <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                    	<cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                        <cfset Running_FICA = THIS.Fringe_MAX_FICA>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodFICA>
                </cfif>

				<!--- Apply Retirement --->
                <cfif right(Variables.pers_subarea,2) LT 8>
                    <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
                    <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                    	<cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                        <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodRET>
                </cfif>

				<!--- Apply Commuter --->
                <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
                    <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                    	<cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                        <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodCOMM>
                </cfif>

				<!--- Apply Vacation --->
                <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
                    <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                    	<cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                        <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodVAC>
                </cfif>
                
				<!--- Apply EmerElder --->
                <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
                    <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
                    <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                    	<cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                        <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodEMER>
                </cfif>

				<!--- Apply FacChSch --->
                <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
                    <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
                    <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                    	<cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                        <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
                    </cfif>
                    <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodFAC>
                </cfif>

	            <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP12>
            </cfif>
		<!--- Test to see IF there is a salary change BEFORE this period --->
        <cfelseif variables.SalChange and variables.Eff_Date LT Variables.Month_Start>
		   <!--- Calculate all amounts on NEW Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.NEW_Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.NEW_Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>
                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe2 = This_Total_Fringe2 + Variables.FB_AMT_FP12>
		<!--- Either there is an increase AFTER this period, or no increase, either way - use current salary for now --->
        <cfelse>
		   <!--- Calculate all amounts on Current Salary --->
           <!--- Calculate Number of Business days in this period --->
           <cfset Variables.DaysInThisPeriod = countArbitraryDays(q_Get_Report_Data.Start_Date,Variables.ThisPeriodEndDate)>
           
           <!--- Calculate Fixed component - this is independent of any salary change --->
           <cfset ThisPeriodFixedAmount = Variables.DaysInThisPeriod * Variables.DailyFixedFringe * q_Get_Report_Data.IT0027 / 100>
           
           <!--- Calculate Variable components --->
           <cfset Variables.ThisPeriodFICA = Variables.Annual_Salary * THIS.Fringe_Rate_FICA / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodRET = Variables.Annual_Salary * THIS.Fringe_Rate_Ret1_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodCOMM = Variables.Annual_Salary * THIS.Fringe_Rate_Commuter / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodVAC = Variables.Annual_Salary * THIS.Fringe_Rate_Vacation / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodEMER = Variables.Annual_Salary * THIS.Fringe_Rate_EmerElder / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           <cfset Variables.ThisPeriodFAC = Variables.Annual_Salary * THIS.Fringe_Rate_FacChSch / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>
           
           <cfset Variables.ThisPeriodNOMAX = Variables.Annual_Salary * Variables.NOMAX_Rate / 100 * q_Get_Report_Data.IT0027 / 100 * Variables.DaysInThisPeriod / THIS.Days_In_FY>

           <!--- Add all appropriate amounts to the FB_AMT_FP --->
           <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodNOMAX + ThisPeriodFixedAmount>

           <!--- Apply FICA --->
           <cfif right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 10>
               <cfset Running_FICA = Running_FICA + Variables.ThisPeriodFICA>
               <cfif Running_FICA GT THIS.Fringe_MAX_FICA>
                   <cfset Variables.ThisPeriodFICA = THIS.Fringe_MAX_FICA>
                   <cfset Running_FICA = THIS.Fringe_MAX_FICA>
               </cfif>
               <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodFICA>
           </cfif>

           <!--- Apply Retirement --->
           <cfif right(Variables.pers_subarea,2) LT 8>
               <cfset Running_retirement = Running_retirement + Variables.ThisPeriodRET>
               <cfif Running_retirement GT THIS.Fringe_MAX_Retirement>
                   <cfset Variables.ThisPeriodRET = THIS.Fringe_MAX_Retirement>
                   <cfset Running_retirement = THIS.Fringe_MAX_Retirement>
               </cfif>
               <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodRET>
           </cfif>

           <!--- Apply Commuter --->
           <cfif (right(Variables.pers_subarea,2) LT 9 OR right(Variables.pers_subarea,2) GT 13) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_commuter = Running_commuter + Variables.ThisPeriodCOMM>
               <cfif Running_commuter GT THIS.Fringe_MAX_Commuter>
                   <cfset Variables.ThisPeriodCOMM = THIS.Fringe_MAX_Commuter>
                   <cfset Running_commuter = THIS.Fringe_MAX_Commuter>
               </cfif>
               <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodCOMM>
           </cfif>

           <!--- Apply Vacation --->
           <cfif right(Variables.pers_subarea,2) LT 9 AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_vacation = Running_vacation + Variables.ThisPeriodVAC>
               <cfif Running_vacation GT THIS.Fringe_MAX_Vacation>
                   <cfset Variables.ThisPeriodVAC = THIS.Fringe_MAX_Vacation>
                   <cfset Running_vacation = THIS.Fringe_MAX_Vacation>
               </cfif>
               <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodVAC>
           </cfif>
           
           <!--- Apply EmerElder --->
           <cfif (right(Variables.pers_subarea,2) LT 8 OR right(Variables.pers_subarea,2) GT 11) AND right(Variables.pers_subarea,2) NEQ '01' AND right(Variables.pers_subarea,2) NEQ '04'>
               <cfset Running_emChildCare = Running_emChildCare + Variables.ThisPeriodEMER>
               <cfif Running_emChildCare GT THIS.Fringe_MAX_EmerElder>
                   <cfset Variables.ThisPeriodEMER = THIS.Fringe_MAX_EmerElder>
                   <cfset Running_emChildCare = THIS.Fringe_MAX_EmerElder>
               </cfif>
               <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodEMER>
           </cfif>

           <!--- Apply FacChSch --->
           <cfif right(Variables.pers_subarea,2) IS '06' OR right(Variables.pers_subarea,2) IS '02'>
               <cfset Running_FacultyScholarship = Running_FacultyScholarship + Variables.ThisPeriodFAC>
               <cfif Running_FacultyScholarship GT THIS.Fringe_MAX_FacChSch>
                   <cfset Variables.ThisPeriodFAC = THIS.Fringe_MAX_FacChSch>

                   <cfset Running_FacultyScholarship = THIS.Fringe_MAX_FacChSch>
               </cfif>
               <cfset Variables.FB_AMT_FP12 = Variables.FB_AMT_FP12 + Variables.ThisPeriodFAC>
           </cfif>

           <cfset This_Total_Fringe1 = This_Total_Fringe1 + Variables.FB_AMT_FP12>
        </cfif>
    </cfif>
    
	<!--- Now that we have calculated fringe for all of our buckets. Let's update Distribution accordingly --->
    <cfquery name="q_UpdateDistribution" datasource="#THIS.DSN#">
       UPDATE
           PEDI_PBT_DISTRIBUTION
           SET 
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
</cfloop>