<cfquery name="q_GetBusAreas" datasource="#THIS.DSN#">
	SELECT
    	*
    FROM
    	PEDI_PBT_BUS_AREA
    ORDER By
    	Bus_Area
</cfquery>

<cfif IsDefined("getrecord.REC_IDX")>
	<cfoutput>
    <SELECT NAME="Bus_Area#getrecord.REC_IDX#" SIZE="1"<cfif session.pbt_PREF_ONCHANGE_SUBMIT> onChange="this.form.submit();"</cfif>>
        <option value="">
        <cfloop query="q_GetBusAreas">
            <option value="#q_GetBusAreas.BUS_AREA#" <cfif B_Area IS "#q_GetBusAreas.BUS_AREA#">SELECTED</cfif>>#q_GetBusAreas.BUS_AREA#</option>
        </cfloop>
    </SELECT>
    </cfoutput>
<cfelse>
	<cfoutput>
    <SELECT NAME="Bus_Area" SIZE="1">
        <option value="">
        <cfloop query="q_GetBusAreas">
            <option value="#q_GetBusAreas.BUS_AREA#">#q_GetBusAreas.BUS_AREA#</option>
        </cfloop>
    </SELECT>
    </cfoutput>
</cfif>