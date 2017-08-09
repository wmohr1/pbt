<CFINCLUDE Template="../templates/Check_Authentication.cfm">
<CFINCLUDE Template="../templates/Get_Header_Info.cfm">

<cfset Variables.Name = UCase(Variables.FIRST_NAME) & " " & UCase(Variables.Last_Name)>

<CFIF Variables.ANNUAL_SALARY NEQ 0>
	<CFSET Daily_Salary = Variables.ANNUAL_SALARY / THIS.Days_In_FY>		
	<CFSET Days_In_This_FY = THIS.Days_In_FY>	
</cfif>

<cfif IsDefined("session.pbt_Admin_Org_Unit") AND session.pbt_Admin_Org_Unit NEQ Variables.Org_Unit>
	<cfset OneOfUs = 0>
<cfelseif IsDefined("session.pbt_Admin_Org_Unit") AND session.pbt_Admin_Org_Unit EQ Variables.Org_Unit>
	<cfset OneOfUs = 1>
<cfelseif Variables.Org_Unit EQ session.pbt_Org_Unit>
	<cfset OneOfUs = 1>
<cfelseif Variables.Org_Unit NEQ session.pbt_Org_Unit>
	<cfset OneOfUs = 0>
</cfif>

<!--- Check if this is a Faculty person (display effort?) --->
<cfif Variables.EMP_CLASS IS "FACULTY" or variables.NEW_CLASS IS "FACULTY">
	<cfset IsFaculty = 1>
<cfelse>
	<cfset IsFaculty = 0>
</cfif>

<cfoutput>
	<TABLE>
		<TR>
		<TD>
		<TABLE>
		<TR>
        	<!--- Display NEW title for those that have one --->
            
			<FORM action="Report_by_Title.cfm" method="post">
				<td  class = "big_heading" title="ID: #Variables.BCM_ID# *** POSITION: #Variables.Position#"><a href="emp_detail.cfm?BCM_ID=#Variables.BCM_ID#">#UCase(Variables.First_Name)# #UCase(Variables.Last_Name)#</a> - (#Variables.BCM_ID#)</td>
				<TD><cfif trim(len(variables.Action_Type)) GT 1 and session.pbt_Record_Type_Selection NEQ 1><INPUT name="JOB_CODE_DESC" type="submit" value="#Variables.NEW_JOB_CODE_DESC#" title="Click for a REPORT of all employees in your section with Title: #Variables.NEW_JOB_CODE_DESC# (Job Code: #Variables.NEW_JOB_CODE#)."><cfelse><INPUT name="JOB_CODE_DESC" type="submit" value="#Variables.JOB_CODE_DESC#" title="Click for a REPORT of all employees in your section with Title: #Variables.JOB_CODE_DESC# (Job Code: #Variables.JOB_CODE#)."></cfif>
			</FORM></TD><td>
			<!--- <cfif session.pbt_ADMINISTRATOR is "1_Admin" and not session.pbt_archiver> --->
				<FORM action="admin_edit_header_rec.cfm" method="post">
					<input name="This_BCM_ID" type="hidden" value="#Variables.BCM_ID#" />
					<input name="EDIT_HEADER_REC" type="submit" value="EDIT HEADER REC" />
				</FORM>
			<!--- </cfif> --->
			</td>
		</TR>
		</TABLE>
		</TD>
		</TR>
		<TR>
		<TD>
		<TABLE>
		<TR>
			<td >
				<!--- Employee Group --->		 
				<cfif trim(len(variables.Action_Type)) GT 1 and session.pbt_Record_Type_Selection NEQ 1>
                     <FORM action="Report_by_Group.cfm" method="post">
                         <CFSWITCH expression="#trim(Variables.NEW_EMP_GROUP)#">
                             <CFCASE value="1"><INPUT name="EMP_GROUP" type="hidden" value="#Variables.NEW_EMP_GROUP#"><INPUT name="EMP_GROUP_DESCRIPTION" type="submit" value="Regular Employee" Title="Click for REPORT of all Regular Employees in your section."> -</CFCASE>
                             <CFCASE value="2"><INPUT name="EMP_GROUP" type="hidden" value="#Variables.NEW_EMP_GROUP#"><INPUT name="EMP_GROUP_DESCRIPTION" type="submit" value="Temporary" Title="Click for REPORT of all Temporary Employees in your section."> - </CFCASE>
                             <CFCASE value="3"><INPUT name="EMP_GROUP" type="hidden" value="#Variables.NEW_EMP_GROUP#"><INPUT name="EMP_GROUP_DESCRIPTION" type="submit" value="Leave of Absence" Title="Click for REPORT of all Leave of Absence Employees in your section."> - </CFCASE>
                             <CFCASE value="4"><INPUT name="EMP_GROUP" type="hidden" value="#Variables.NEW_EMP_GROUP#"><INPUT name="EMP_GROUP_DESCRIPTION" type="submit" value="Retired" Title="Click for REPORT of all Retired Employees in your section."> - </CFCASE>
                             <CFCASE value="5"><INPUT name="EMP_GROUP" type="hidden" value="#Variables.NEW_EMP_GROUP#"><INPUT name="EMP_GROUP_DESCRIPTION" type="submit" value="Disabled" Title="Click for REPORT of all Disabled Employees in your section."> - </CFCASE>
                             <CFCASE value="6"><INPUT name="EMP_GROUP" type="hidden" value="#Variables.NEW_EMP_GROUP#"><INPUT name="EMP_GROUP_DESCRIPTION" type="submit" value="Indep. Contractor" Title="Click for REPORT of all Indep. Contractor Employees in your section."> - </CFCASE>
                             <CFCASE value="7"><INPUT name="EMP_GROUP" type="hidden" value="#Variables.NEW_EMP_GROUP#"><INPUT name="EMP_GROUP_DESCRIPTION" type="submit" value="Voluntary" Title="Click for REPORT of all Voluntary Employees in your section."> - </CFCASE>
                         </CFSWITCH>
                     </FORM>
                <cfelse>
                     <FORM action="Report_by_Group.cfm" method="post">
                         <CFSWITCH expression="#trim(Variables.EMP_GROUP)#">
                             <CFCASE value="1"><INPUT name="EMP_GROUP" type="hidden" value="#Variables.EMP_GROUP#"><INPUT name="EMP_GROUP_DESCRIPTION" type="submit" value="Regular Employee" Title="Click for REPORT of all Regular Employees in your section."> -</CFCASE>
                             <CFCASE value="2"><INPUT name="EMP_GROUP" type="hidden" value="#Variables.EMP_GROUP#"><INPUT name="EMP_GROUP_DESCRIPTION" type="submit" value="Temporary" Title="Click for REPORT of all Temporary Employees in your section."> - </CFCASE>
                             <CFCASE value="3"><INPUT name="EMP_GROUP" type="hidden" value="#Variables.EMP_GROUP#"><INPUT name="EMP_GROUP_DESCRIPTION" type="submit" value="Leave of Absence" Title="Click for REPORT of all Leave of Absence Employees in your section."> - </CFCASE>
                             <CFCASE value="4"><INPUT name="EMP_GROUP" type="hidden" value="#Variables.EMP_GROUP#"><INPUT name="EMP_GROUP_DESCRIPTION" type="submit" value="Retired" Title="Click for REPORT of all Retired Employees in your section."> - </CFCASE>
                             <CFCASE value="5"><INPUT name="EMP_GROUP" type="hidden" value="#Variables.EMP_GROUP#"><INPUT name="EMP_GROUP_DESCRIPTION" type="submit" value="Disabled" Title="Click for REPORT of all Disabled Employees in your section."> - </CFCASE>
                             <CFCASE value="6"><INPUT name="EMP_GROUP" type="hidden" value="#Variables.EMP_GROUP#"><INPUT name="EMP_GROUP_DESCRIPTION" type="submit" value="Indep. Contractor" Title="Click for REPORT of all Indep. Contractor Employees in your section."> - </CFCASE>
                             <CFCASE value="7"><INPUT name="EMP_GROUP" type="hidden" value="#Variables.EMP_GROUP#"><INPUT name="EMP_GROUP_DESCRIPTION" type="submit" value="Voluntary" Title="Click for REPORT of all Voluntary Employees in your section."> - </CFCASE>
                         </CFSWITCH>
                     </FORM>
                </cfif>
			</td>
			<td>
				<cfif trim(len(variables.Action_Type)) GT 1 and session.pbt_Record_Type_Selection NEQ 1>
					 <!--- Employee SubGroup --->
                     <FORM action="Report_by_SubGroup.cfm" method="post">
                         <CFSWITCH expression="#trim(Variables.NEW_EMP_SUBGROUP)#">
                             <CFCASE value="U1"><INPUT name="EMP_SUBGROUP" type="hidden" value="#Variables.NEW_EMP_SUBGROUP#"><INPUT name="EMP_SUBGROUP_DESCRIPTION" type="submit" value="Salaried FT Exempt" Title="Click for REPORT of all Salaried FT Exempt Employees in your section."> - </CFCASE>
                             <CFCASE value="U2"><INPUT name="EMP_SUBGROUP" type="hidden" value="#Variables.NEW_EMP_SUBGROUP#"><INPUT name="EMP_SUBGROUP_DESCRIPTION" type="submit" value="Salaried FT NonExmpt" Title="Click for REPORT of all Salaried FT NonExmpt Employees in your section."> - </CFCASE>
                             <CFCASE value="U3"><INPUT name="EMP_SUBGROUP" type="hidden" value="#Variables.NEW_EMP_SUBGROUP#"><INPUT name="EMP_SUBGROUP_DESCRIPTION" type="submit" value="Salaried PT Exempt" Title="Click for REPORT of all Salaried PT Exempt Employees in your section."> - </CFCASE>
                             <CFCASE value="U4"><INPUT name="EMP_SUBGROUP" type="hidden" value="#Variables.NEW_EMP_SUBGROUP#"><INPUT name="EMP_SUBGROUP_DESCRIPTION" type="submit" value="Salaried PT NonExmpt" Title="Click for REPORT of all Salaried PT NonExmpt Employees in your section."> - </CFCASE>
                             <CFCASE value="U5"><INPUT name="EMP_SUBGROUP" type="hidden" value="#Variables.NEW_EMP_SUBGROUP#"><INPUT name="EMP_SUBGROUP_DESCRIPTION" type="submit" value="Hourly Full-Time" Title="Click for REPORT of all Hourly Full-Time Employees in your section."> - </CFCASE>
                             <CFCASE value="U6"><INPUT name="EMP_SUBGROUP" type="hidden" value="#Variables.NEW_EMP_SUBGROUP#"><INPUT name="EMP_SUBGROUP_DESCRIPTION" type="submit" value="Hourly Part-time" Title="Click for REPORT of all Hourly Part-time Employees in your section."> - </CFCASE>
                             <CFCASE value="U7"><INPUT name="EMP_SUBGROUP" type="hidden" value="#Variables.NEW_EMP_SUBGROUP#"><INPUT name="EMP_SUBGROUP_DESCRIPTION" type="submit" value="Non-Paid" Title="Click for REPORT of all Non-Paid Employees in your section."> - </CFCASE>
                         </CFSWITCH>
                     </FORM>
                <cfelse>
					 <!--- Employee SubGroup --->
                     <FORM action="Report_by_SubGroup.cfm" method="post">
                         <CFSWITCH expression="#trim(Variables.EMP_SUBGROUP)#">
                             <CFCASE value="U1"><INPUT name="EMP_SUBGROUP" type="hidden" value="#Variables.EMP_SUBGROUP#"><INPUT name="EMP_SUBGROUP_DESCRIPTION" type="submit" value="Salaried FT Exempt" Title="Click for REPORT of all Salaried FT Exempt Employees in your section."> - </CFCASE>
                             <CFCASE value="U2"><INPUT name="EMP_SUBGROUP" type="hidden" value="#Variables.EMP_SUBGROUP#"><INPUT name="EMP_SUBGROUP_DESCRIPTION" type="submit" value="Salaried FT NonExmpt" Title="Click for REPORT of all Salaried FT NonExmpt Employees in your section."> - </CFCASE>
                             <CFCASE value="U3"><INPUT name="EMP_SUBGROUP" type="hidden" value="#Variables.EMP_SUBGROUP#"><INPUT name="EMP_SUBGROUP_DESCRIPTION" type="submit" value="Salaried PT Exempt" Title="Click for REPORT of all Salaried PT Exempt Employees in your section."> - </CFCASE>
                             <CFCASE value="U4"><INPUT name="EMP_SUBGROUP" type="hidden" value="#Variables.EMP_SUBGROUP#"><INPUT name="EMP_SUBGROUP_DESCRIPTION" type="submit" value="Salaried PT NonExmpt" Title="Click for REPORT of all Salaried PT NonExmpt Employees in your section."> - </CFCASE>
                             <CFCASE value="U5"><INPUT name="EMP_SUBGROUP" type="hidden" value="#Variables.EMP_SUBGROUP#"><INPUT name="EMP_SUBGROUP_DESCRIPTION" type="submit" value="Hourly Full-Time" Title="Click for REPORT of all Hourly Full-Time Employees in your section."> - </CFCASE>
                             <CFCASE value="U6"><INPUT name="EMP_SUBGROUP" type="hidden" value="#Variables.EMP_SUBGROUP#"><INPUT name="EMP_SUBGROUP_DESCRIPTION" type="submit" value="Hourly Part-time" Title="Click for REPORT of all Hourly Part-time Employees in your section."> - </CFCASE>
                             <CFCASE value="U7"><INPUT name="EMP_SUBGROUP" type="hidden" value="#Variables.EMP_SUBGROUP#"><INPUT name="EMP_SUBGROUP_DESCRIPTION" type="submit" value="Non-Paid" Title="Click for REPORT of all Non-Paid Employees in your section."> - </CFCASE>
                         </CFSWITCH>
                     </FORM>
				</cfif>                
			</td>	
			<td>
				<cfif trim(len(variables.Action_Type)) GT 1 and session.pbt_Record_Type_Selection NEQ 1>
                <FORM action="Report_by_PersSubArea.cfm" method="post">
					<!--- Employee Personal SubArea --->
					<CFSWITCH expression="#trim(Variables.NEW_PERS_SUBAREA)#">
						<CFCASE value="1"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.NEW_PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Faculty0" Title="Click for REPORT of all Faculty0 Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
						<CFCASE value="2"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.NEW_PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Faculty1" Title="Click for REPORT of all Faculty1 Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
						<CFCASE value="3"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.NEW_PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Faculty2" Title="Click for REPORT of all Faculty2 Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
						<CFCASE value="4"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.NEW_PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Staff0" Title="Click for REPORT of all Staff0 Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
						<CFCASE value="5"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.NEW_PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="StaffR" Title="Click for REPORT of all StaffR Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
						<CFCASE value="6"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.NEW_PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Staff1" Title="Click for REPORT of all Staff1 Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
						<CFCASE value="7"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.NEW_PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Staff2" Title="Click for REPORT of all Staff2 Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
						<CFCASE value="8"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.NEW_PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Grad Student" Title="Click for REPORT of all Grad Student Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
						<CFCASE value="9"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.NEW_PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Med Student" Title="Click for REPORT of all Med Student Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
						<CFCASE value="10"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.NEW_PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Other BCM Student" Title="Click for REPORT of all Other BCM Student Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
						<CFCASE value="11"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.NEW_PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Non BCM Student" Title="Click for REPORT of all Voluntary Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
						<CFCASE value="12"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.NEW_PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Resident" Title="Click for REPORT of all Resident Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
						<CFCASE value="13"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.NEW_PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="PDoc MD (Clinical)" Title="Click for REPORT of all PDoc MD (Clinical) Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
						<CFCASE value="14"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.NEW_PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="PDoc MD (Research)" Title="Click for REPORT of all PDoc MD (Research) Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
						<CFCASE value="15"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.NEW_PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="PDoc PhD (Research)" Title="Click for REPORT of all PDoc PhD (Research) Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
					</CFSWITCH>
				</FORM>
				<cfelse>
                     <FORM action="Report_by_PersSubArea.cfm" method="post">
                         <!--- Employee Personal SubArea --->
                         <CFSWITCH expression="#trim(Variables.PERS_SUBAREA)#">
                             <CFCASE value="1"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Faculty0" Title="Click for REPORT of all Faculty0 Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
                             <CFCASE value="2"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Faculty1" Title="Click for REPORT of all Faculty1 Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
                             <CFCASE value="3"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Faculty2" Title="Click for REPORT of all Faculty2 Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
                             <CFCASE value="4"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Staff0" Title="Click for REPORT of all Staff0 Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
                             <CFCASE value="5"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="StaffR" Title="Click for REPORT of all StaffR Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
                             <CFCASE value="6"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Staff1" Title="Click for REPORT of all Staff1 Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
                             <CFCASE value="7"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Staff2" Title="Click for REPORT of all Staff2 Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
                             <CFCASE value="8"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Grad Student" Title="Click for REPORT of all Grad Student Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
                             <CFCASE value="9"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Med Student" Title="Click for REPORT of all Med Student Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
                             <CFCASE value="10"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Other BCM Student" Title="Click for REPORT of all Other BCM Student Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
                             <CFCASE value="11"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Non BCM Student" Title="Click for REPORT of all Voluntary Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
                             <CFCASE value="12"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="Resident" Title="Click for REPORT of all Resident Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
                             <CFCASE value="13"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="PDoc MD (Clinical)" Title="Click for REPORT of all PDoc MD (Clinical) Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
                             <CFCASE value="14"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="PDoc MD (Research)" Title="Click for REPORT of all PDoc MD (Research) Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
                             <CFCASE value="15"><INPUT name="PERS_SUBAREA" type="hidden" value="#Variables.PERS_SUBAREA#"><INPUT name="PERS_SUBAREA_DESCRIPTION" type="submit" value="PDoc PhD (Research)" Title="Click for REPORT of all PDoc PhD (Research) Employees in your section."><cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103"> - </cfif></CFCASE>
                         </CFSWITCH>
                     </FORM>
				</cfif>                
			</td>
			<td align="right">
				<cfif Variables.JOB_CODE IS "8105" OR Variables.JOB_CODE IS "8103">
                	
					<h5>PDOC_LEVEL <cfif len(variables.NEW_PDOC_LEVEL) GT 0>#Variables.NEW_PDOC_LEVEL#<cfelse>#Variables.PDOC_LEVEL#</cfif></h5>
				</cfif>
			</td>
			<td>
				<cfif IsNewHire>
					<form action="emp_convert_form.cfm" method="post">
						<input type="hidden" name="Original_BCM_ID" value="#Variables.BCM_ID#" />
						<input type="hidden" name="Original_POSITION" value="#Variables.POSITION#" />
						<input type="hidden" name="Original_FIRST_NAME" value="#Variables.FIRST_NAME#" />
						<input type="hidden" name="Original_LAST_NAME" value="#Variables.LAST_NAME#" />
						<input type="hidden" name="Original_SOC_SEC_NO" value="#Variables.SOC_SEC_NO#" />
						<input type="submit" name="submit" value="Convert from New Hire" />
					</form>
				</cfif>
			</td>
		</TR>
		</TABLE>
		</TD>
		</TR>
	</table>
</cfoutput>