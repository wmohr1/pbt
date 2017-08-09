<!--- Add Employee button appears at top and bottom of screen --->
<cfif not session.pbt_archiver>
	<CFOUTPUT>
        <FORM ACTION="../work/emp_add_form.cfm" METHOD="POST">
            <cfinclude template="../templates/Capture_VariablesToHidden.cfm">
            <input type="image" src="../images/clothe0b.gif" alt="Add Employee" onClick="this.form.submit()">
        </FORM>	
    </CFOUTPUT>
</cfif>
