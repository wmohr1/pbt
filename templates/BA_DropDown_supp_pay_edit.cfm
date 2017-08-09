<cfquery name="q_GetBusAreas" datasource="#THIS.DSN#">
	SELECT
    	*
    FROM
    	PEDI_PBT_BUS_AREA
    ORDER By
    	Bus_Area
</cfquery>

<cfoutput>
<SELECT NAME="Bus_Area" SIZE="1" onChange="this.form.submit();">
	<option value="">
    <cfloop query="q_GetBusAreas">
		<option value="#q_GetBusAreas.BUS_AREA#" <cfif B_Area IS "#q_GetBusAreas.BUS_AREA#">SELECTED</cfif>>#q_GetBusAreas.BUS_AREA#</option>
	</cfloop>
</SELECT>
</cfoutput>