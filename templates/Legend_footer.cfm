<CFIF NOT IsDefined("FORM.print")>
	<!---Begin footer --->
    <table border="5" cellspacing="2" cellpadding="2" align="right" frame="box">
        <tr>
            <td style="color: White; font-weight: bold; background-color: Navy; font-size: smallest">Color Legend</td>
        </tr>
        <tr>
            <td style="background-color: Red; font-weight: bold; font-size: smallest">Default Fundcenter</td>
        </tr>
        <tr>
            <td style="background-color: Silver; font-weight: bold; font-size: smallest">Non-Validated Record</td>
        </tr>
        <tr>
            <td style="background-color: Yellow; font-weight: bold; font-size: smallest">New Employee</td>
        </tr>
        <tr>
            <td style="background-color: lightgreen; font-weight: bold; font-size: smallest">Promotion</td>
        </tr> 
        <tr>
            <td style="background-color: CC99FF; font-weight: bold; font-size: smallest">Non-Section Employee</td>
        </tr>
        <tr>
            <td style="background-color:PaleVioletRed; font-weight: bold; font-size: smallest">Non-Section Source</td>
        </tr>
        <tr>
            <td style="font-weight: bold; font-size: smallest">None of Above</td>
        </tr>
    </table>
</CFIF>