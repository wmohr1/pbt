<cfquery name="q_GetLogInfo" datasource="#THIS.DSN#">
	SELECT
		*
	FROM
		PEDI_PBT_CONTROL
	<cfif find("ALL",MOD_ACTION) GT 0>
    WHERE
    	1=1
    <cfelse>
    WHERE 
		ORG_UNIT = #Variables.ORG_UNIT#
    </cfif>
</cfquery>
<cfloop query="q_GetLogInfo">
	<cfquery name="q_LogTransaction" datasource="#THIS.DSN#">
		INSERT INTO
			PEDI_PBT_CONTROL_LOG
				(BCM_ID,
				ORG_UNIT,
				HOME_DEPT_DESC,
				USERNAME,
				FI_SEC,
				TCH_OP_LIMIT,
				COLLEGE,
				HCHD,
				CSUPPORT,
				OVERALL,
				FIRST_NAME,
				LAST_NAME,
				SAL_LOCK,
				AF_LOCK,
				ADMINISTRATOR,
				<cfif len(trim(q_GetLogInfo.SAL_LOCKED_DATE)) GT 0>SAL_LOCKED_DATE,</cfif>
				<cfif len(trim(q_GetLogInfo.SAL_LOCKED_USER)) GT 0>SAL_LOCKED_USER,</cfif>
				<cfif len(trim(q_GetLogInfo.AF_LOCKED_DATE)) GT 0>AF_LOCKED_DATE,</cfif>
				<cfif len(trim(q_GetLogInfo.AF_LOCKED_USER)) GT 0>AF_LOCKED_USER,</cfif>
				MOD_ACTION,
                OWNER_ADMIN,
                LOCK_LEVEL,
                SAL_LVL1_LOCK,
                SAL_LVL1_LOCK_USER,
                SAL_LVL1_LOCK_DATE,
                SAL_LVL2_LOCK,
                SAL_LVL2_LOCK_USER,
                SAL_LVL2_LOCK_DATE,
                SAL_LVL3_LOCK,
                SAL_LVL3_LOCK_USER,
                SAL_LVL3_LOCK_DATE,
                AF_LVL1_LOCK,
                AF_LVL1_LOCK_USER,
                AF_LVL1_LOCK_DATE,
                AF_LVL2_LOCK,
                AF_LVL2_LOCK_USER,
                AF_LVL2_LOCK_DATE,
                AF_LVL3_LOCK,
                AF_LVL3_LOCK_USER,
                AF_LVL3_LOCK_DATE,
                LOCK_COMMENT)
			VALUES
				(#q_GetLogInfo.BCM_ID#,
				#q_GetLogInfo.ORG_UNIT#,
				'#q_GetLogInfo.HOME_DEPT_DESC#',
				'#q_GetLogInfo.USERNAME#',
				#q_GetLogInfo.FI_SEC#,
				#q_GetLogInfo.TCH_OP_LIMIT#,
				#q_GetLogInfo.COLLEGE#,
				#q_GetLogInfo.HCHD#,
				#q_GetLogInfo.CSUPPORT#,
				#q_GetLogInfo.OVERALL#,
				'#q_GetLogInfo.FIRST_NAME#',
				'#q_GetLogInfo.LAST_NAME#',
				#q_GetLogInfo.SAL_LOCK#,
				#q_GetLogInfo.AF_LOCK#,
				'#q_GetLogInfo.ADMINISTRATOR#',
				<cfif len(trim(q_GetLogInfo.SAL_LOCKED_DATE)) GT 0>TO_DATE('#DateFormat(q_GetLogInfo.SAL_LOCKED_DATE,"MM/DD/YYYY")#','MM/DD/YYYY'),</cfif>
				<cfif len(trim(q_GetLogInfo.SAL_LOCKED_USER)) GT 0>'#q_GetLogInfo.SAL_LOCKED_USER#',</cfif>
				<cfif len(trim(q_GetLogInfo.AF_LOCKED_DATE)) GT 0>TO_DATE('#DateFormat(q_GetLogInfo.AF_LOCKED_DATE,"MM/DD/YYYY")#','MM/DD/YYYY'),</cfif>
				<cfif len(trim(q_GetLogInfo.AF_LOCKED_USER)) GT 0>'#q_GetLogInfo.AF_LOCKED_USER#',</cfif>
				'#Variables.MOD_ACTION#',
                '#q_GetLogInfo.OWNER_ADMIN#',
                '#q_GetLogInfo.LOCK_LEVEL#',
                '#q_GetLogInfo.SAL_LVL1_LOCK#',
                '#q_GetLogInfo.SAL_LVL1_LOCK_USER#',
                TO_DATE('#DateFormat(q_GetLogInfo.SAL_LVL1_LOCK_DATE,"MM/DD/YYYY")#','MM/DD/YYYY'),
                '#q_GetLogInfo.SAL_LVL2_LOCK#',
                '#q_GetLogInfo.SAL_LVL2_LOCK_USER#',
                TO_DATE('#DateFormat(q_GetLogInfo.SAL_LVL2_LOCK_DATE,"MM/DD/YYYY")#','MM/DD/YYYY'),
                '#q_GetLogInfo.SAL_LVL3_LOCK#',
                '#q_GetLogInfo.SAL_LVL3_LOCK_USER#',
                TO_DATE('#DateFormat(q_GetLogInfo.SAL_LVL3_LOCK_DATE,"MM/DD/YYYY")#','MM/DD/YYYY'),
                '#q_GetLogInfo.AF_LVL1_LOCK#',
                '#q_GetLogInfo.AF_LVL1_LOCK_USER#',
                TO_DATE('#DateFormat(q_GetLogInfo.AF_LVL1_LOCK_DATE,"MM/DD/YYYY")#','MM/DD/YYYY'),
                '#q_GetLogInfo.AF_LVL2_LOCK#',
                '#q_GetLogInfo.AF_LVL2_LOCK_USER#',
                TO_DATE('#DateFormat(q_GetLogInfo.AF_LVL2_LOCK_DATE,"MM/DD/YYYY")#','MM/DD/YYYY'),
                '#q_GetLogInfo.AF_LVL3_LOCK#',
                '#q_GetLogInfo.AF_LVL3_LOCK_USER#',
                TO_DATE('#DateFormat(q_GetLogInfo.AF_LVL3_LOCK_DATE,"MM/DD/YYYY")#','MM/DD/YYYY'),
                '#q_GetLogInfo.LOCK_COMMENT#')
	</cfquery>
</cfloop>