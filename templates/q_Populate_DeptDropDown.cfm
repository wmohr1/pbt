<!--- Check if user is in 'Report Only' FY --->
<cfquery name="q_CheckArchive" datasource="#THIS.DSN#">
	SELECT
    	REPORT_ONLY
    FROM
    	PEDI_PBT_ARCHIVE
    WHERE
    	BUDGET_FY = '#session.pbt_PREF_DEF_FY#'
</cfquery>

<cfif q_CheckArchive.Report_Only>
	<!--- This Query simply selects the Fundcenters from PEDI_PBT_COA that the user may select from --->
    <cfquery name="q_Populate_DeptDropDown" datasource="#THIS.DSN#">
        SELECT
            A.FUNDCENTER,
            C.DESCRIPTION
        FROM
            PEDI_PBT_AF A,
            PEDI_PBT_COA C
        WHERE
            A.FUNDCENTER = C.FUNDCENTER
        <cfif session.pbt_admin_fi_sec
     IS NOT "ALL">
        AND				
            A.FUNDCENTER LIKE '#session.pbt_admin_fi_sec
    #%'
        <cfelse>
        AND (A.FUNDCENTER LIKE '253%'
        OR
            A.FUNDCENTER LIKE '890%')
        </cfif>
        AND 
            A.FY = '#session.pbt_PREF_DEF_FY#'
        GROUP BY
            A.FUNDCENTER,
            C.DESCRIPTION
        ORDER BY
            A.FUNDCENTER,
            C.DESCRIPTION
    </cfquery>

<cfelse>
	<!--- This Query simply selects the Fundcenters from PEDI_PBT_COA that the user may select from --->
    <cfquery name="q_Populate_DeptDropDown" datasource="#THIS.DSN#">
        SELECT
            A.FUNDCENTER,
            C.DESCRIPTION
        FROM
            PEDI_PBT_AF A,
            PEDI_PBT_COA C
        WHERE
            A.FUNDCENTER = C.FUNDCENTER
        <cfif session.pbt_admin_fi_sec
     IS NOT "ALL">
        AND				
            A.FUNDCENTER LIKE '#session.pbt_admin_fi_sec
    #%'
        <cfelse>
        AND (A.FUNDCENTER LIKE '253%'
        OR
            A.FUNDCENTER LIKE '890%')
        </cfif>
        AND 
            A.FY = '#session.pbt_PREF_DEF_FY#'
        AND
            A.BUDGET_STATUS LIKE 'AVAILABLE%'
        GROUP BY
            A.FUNDCENTER,
            C.DESCRIPTION
        ORDER BY
            A.FUNDCENTER,
            C.DESCRIPTION
    </cfquery>
</cfif>