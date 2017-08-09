<CFINCLUDE Template="../templates/header.cfm">
<cfinclude template="../templates/Set_Section.cfm">

<table width="600" align="center">
	<tr>
    	<td><h2>Please enter valid BCM ID, First and Last name, and Social Security <br />number (e.g. 123-45-6789) to convert your New Hire to a valid active BCM employee</h2>
        </td>
    </tr>
</table>
<table onload = "add_ee.JOB_CODE_DESC.focus()" align = "center">
	<cfform action = "emp_convert_action.cfm" name="convert_ee_form" method="post" onSubmit = "return chkForm(this.form);">
    	<cfoutput>
            <input type="hidden" name="Original_BCM_ID" value="#FORM.Original_BCM_ID#" />
            <tr>
                <td colspan="4">
            </td>
            <tr>
            	<th></th>
                <th>BCMID</th>
                <th>POSITION</th>
                <th>FIRST</th>
                <th>LAST</th>
                <th>SSNO</th>
            </tr>
            <tr>
            	<th>ORIGINAL</th>
                <td>#FORM.Original_BCM_ID#</td>
                <td>#FORM.Original_Position#</td>
                <td>#FORM.Original_FIRST_NAME#</td>
                <td>#FORM.Original_LAST_NAME#</td>
                <td>#FORM.Original_SOC_SEC_NO#</td>
            </tr>
            <tr>
            	<th>NEW</th>
                <td title="You Must Enter a valid and unique BCM ID">
                    <cfinput type="Text" name="BCM_ID" range="10000,999999" message="You Must Enter a valid and unique BCM ID (5 or 6 digits)" validate="integer" required="Yes" size="6" maxlength="6" style="background-color: Yellow;" value="#FORM.Original_BCM_ID#">
                </td>
                <td title="You Must Enter a valid POSITION">
                    <cfinput type="Text" name="POSITION" range="1000,999999" message="You Must Enter a valid position (4 to 6 digits)" validate="integer" required="Yes" size="6" maxlength="6" style="background-color: Yellow;" value="#FORM.Original_Position#">
                </td>
                <td title = "You Must Enter a valid First Name">
                    <cfinput type = "text" name = "FIRST_NAME" maxlength = "50" style = "background-color: Yellow;" required = "yes" message = "You Must Enter a valid First Name" value="#FORM.Original_FIRST_NAME#">
                </td>
                <td title = "You Must Enter a valid Last Name">
                    <cfinput type = "Text" name = "LAST_NAME" style = "background-color: Yellow;" message = "You Must Enter a valid Last Name" required = "Yes" maxlength = "50" value="#FORM.Original_LAST_NAME#">
                </td>
                <td title = "You Must Enter a valid Social Security Number">
                    <cfinput type = "Text" name="SOC_SEC_NO" style="background-color: Yellow;" message="You Must Enter a Valid Social Security Number" validate="social_security_number" required="Yes" value="#FORM.Original_SOC_SEC_NO#">
                </td>
            </tr>
            <tr>
                <td colspan = "6" align = "Right"><input type="submit" value="CONVERT FROM NEW HIRE" style="background-color: Navy; color: Yellow;" title="ADD RECORD"></td>
            </tr>
        </cfoutput>
	</cfform>
</table>

<br><br><br><br>
<cfif NOT IsDefined("URL.Go")>
<table align = "center">
	<tr>
		<td><cfinclude template = "../templates/footer.cfm"></td>
	</tr>
</table>
</cfif>
</body>