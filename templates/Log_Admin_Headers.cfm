<cfquery name="q_GetLogInfo" datasource="#THIS.DSN#">
	SELECT
		*
	FROM
		PEDI_PBT_HEADERS
	WHERE 
		BCM_ID = '#Variables.bcm_id#'
</cfquery>
<cfloop query="q_GetLogInfo">
	
	<cfquery name="q_LogTransaction" datasource="#THIS.DSN#">
		INSERT INTO
			PEDI_PBT_HEADERS_LOG
				(Rec_Type,
				LAST_NAME,
				<cfif len(trim(q_GetLogInfo.FIRST_NAME)) GT 0>FIRST_NAME,</cfif>
				<cfif len(trim(q_GetLogInfo.MIDDLE_NAME)) GT 0>MIDDLE_NAME,</cfif>
				<cfif len(trim(q_GetLogInfo.DEGREE_1)) GT 0>DEGREE_1,</cfif>
				<cfif len(trim(q_GetLogInfo.DEGREE_2)) GT 0>DEGREE_2,</cfif>
				<cfif len(trim(q_GetLogInfo.CHIEF)) GT 0>CHIEF,</cfif>
				<cfif len(trim(q_GetLogInfo.BIRTH_DATE)) GT 0>BIRTH_DATE,</cfif>
				<cfif len(trim(q_GetLogInfo.SOC_SEC_NO)) GT 0>SOC_SEC_NO,</cfif>
				EMP_GROUP,
				EMP_SUBGROUP,
				PERS_SUBAREA,
				<cfif len(trim(q_GetLogInfo.CHIEF)) GT 0>PAY_SCALE_GROUP,</cfif>
				JOB_CODE_DESC,
				ANNUAL_SALARY,
				ORG_UNIT,
				HOME_DEPT_DESC,
				BCM_ID,
				POSITION,
				JOB_CODE,
				FTE,
				CAP_UTIL,
				EMP_STATUS,
				<cfif len(trim(q_GetLogInfo.RFA)) GT 0>RFA,</cfif>
				<cfif len(trim(q_GetLogInfo.ACTION_TYPE)) GT 0>ACTION_TYPE,</cfif>
				<cfif len(trim(q_GetLogInfo.EFF_DATE)) GT 0>EFF_DATE,</cfif>
				NEW_HIRE,
				<cfif len(trim(q_GetLogInfo.INC_PERCENT)) GT 0>INC_PERCENT,</cfif>
				<cfif len(trim(q_GetLogInfo.INC_EXP)) GT 0>INC_EXP,</cfif>
				JOB_KEY,
				<cfif len(trim(q_GetLogInfo.PDOC_LEVEL)) GT 0>PDOC_LEVEL,</cfif>
				EMPLOY_DATE_LAST,
				EXEMPT_INDICATOR,
				EMP_CLASS,
				MOD_DATE,
				MOD_USERNAME,
                MOD_COMMENT,
				MOD_ACTION,
				PAF,
				PAF_DESCRIPTION,
				EMPLOYEE_TYPE,
				PAF_REPL_POSITION,
				BENEFIT_LVL,
				FY)
			VALUES
				(#q_GetLogInfo.Rec_Type#,
				'#q_GetLogInfo.LAST_NAME#',
				<cfif len(trim(q_GetLogInfo.FIRST_NAME)) GT 0>'#q_GetLogInfo.FIRST_NAME#',</cfif>
				<cfif len(trim(q_GetLogInfo.MIDDLE_NAME)) GT 0>'#q_GetLogInfo.MIDDLE_NAME#',</cfif>
				<cfif len(trim(q_GetLogInfo.DEGREE_1)) GT 0>'#q_GetLogInfo.DEGREE_1#',</cfif>
				<cfif len(trim(q_GetLogInfo.DEGREE_2)) GT 0>'#q_GetLogInfo.DEGREE_2#',</cfif>
				<cfif len(trim(q_GetLogInfo.CHIEF)) GT 0>#q_GetLogInfo.CHIEF#,</cfif>
				<cfif len(trim(q_GetLogInfo.BIRTH_DATE)) GT 0>'#q_GetLogInfo.BIRTH_DATE#',</cfif>
				<cfif len(trim(q_GetLogInfo.SOC_SEC_NO)) GT 0>'#q_GetLogInfo.SOC_SEC_NO#',</cfif>
				#q_GetLogInfo.EMP_GROUP#,
				'#q_GetLogInfo.EMP_SUBGROUP#',
				'#q_GetLogInfo.PERS_SUBAREA#',
				<cfif len(trim(q_GetLogInfo.CHIEF)) GT 0>'#q_GetLogInfo.PAY_SCALE_GROUP#',</cfif>
				'#q_GetLogInfo.JOB_CODE_DESC#',
				#q_GetLogInfo.ANNUAL_SALARY#,
				'#q_GetLogInfo.ORG_UNIT#',
				'#q_GetLogInfo.HOME_DEPT_DESC#',
				'#q_GetLogInfo.BCM_ID#',
				'#q_GetLogInfo.POSITION#',
				'#q_GetLogInfo.JOB_CODE#',
				#q_GetLogInfo.FTE#,
				#q_GetLogInfo.CAP_UTIL#,
				'#q_GetLogInfo.EMP_STATUS#',
				<cfif len(trim(q_GetLogInfo.RFA)) GT 0>'#q_GetLogInfo.RFA#',</cfif>
				<cfif len(trim(q_GetLogInfo.ACTION_TYPE)) GT 0>'#q_GetLogInfo.ACTION_TYPE#',</cfif>
				<cfif len(trim(q_GetLogInfo.EFF_DATE)) GT 0>'#q_GetLogInfo.EFF_DATE#',</cfif>
				#q_GetLogInfo.NEW_HIRE#,
				<cfif len(trim(q_GetLogInfo.INC_PERCENT)) GT 0>#q_GetLogInfo.INC_PERCENT#,</cfif>
				<cfif len(trim(q_GetLogInfo.INC_EXP)) GT 0>'#q_GetLogInfo.INC_EXP#',</cfif>
				'#q_GetLogInfo.JOB_KEY#',
				<cfif len(trim(q_GetLogInfo.PDOC_LEVEL)) GT 0>#q_GetLogInfo.PDOC_LEVEL#,</cfif>
				'#DateFormat(q_GetLogInfo.EMPLOY_DATE_LAST,"MM/DD/YYYY")#',
				'#q_GetLogInfo.EXEMPT_INDICATOR#',
				'#q_GetLogInfo.EMP_CLASS#',
				sysdate,
				'#session.pbt_THISUSER#',
				'#q_GetLogInfo.MOD_COMMENT#',
				'#Variables.MOD_ACTION#',
				'#q_GetLogInfo.PAF#',
				'#q_GetLogInfo.PAF_DESCRIPTION#',
				'#q_GetLogInfo.EMPLOYEE_TYPE#',
				'#q_GetLogInfo.PAF_REPL_POSITION#',
				'#q_GetLogInfo.BENEFIT_LVL#',
				'#session.pbt_PREF_DEF_FY#')
	</cfquery>
</cfloop>