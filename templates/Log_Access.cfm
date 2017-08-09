<cfquery name="q_LogTransaction" datasource="#THIS.DSN#">
    INSERT INTO
        PEDI_PBT_ACCESS_LOG
            (ORG_UNIT,
            USERNAME,
            FI_SEC,
            ACCESS_DATE,
            FY)
        VALUES
            ('#session.pbt_ORG_UNIT#',
            '#session.pbt_THISUSER#',
            '#session.pbt_FI_SEC#',
            sysdate,
            '#THIS.FY#')
</cfquery>