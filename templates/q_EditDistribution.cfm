<!---
Template Name: q_EditDistribution.cfm
Create Date: 
Last Modification: 2/3/2016

Comments:
2/3/2016: This procedure is working fine in DEV/DSOA, but throwing an error in PROD/PSOA. I changed the datasource call from "#request.dsn#" to #THIS.dsn# in hopes it will resolve my issue.

--->

<cfstoredproc datasource="#THIS.dsn#" procedure="#request.proc#" blockfactor="45">
        <cfprocparam type="in" value="#spp_REC_IDX#" variable="REC_IDX" cfsqltype="cf_sql_integer">
        <cfprocparam type="in" value="#spp_FUNDCENTER#" variable="FUNDCENTER" cfsqltype="cf_sql_varchar">
        <cfprocparam type="in" value="#spp_IT0027#" variable="IT0027" cfsqltype="cf_sql_float">
        <cfprocparam type="in" value="#spp_IT9027#" variable="IT9027" cfsqltype="cf_sql_float">
        <cfprocparam type="in" value="#spp_BUS_AREA#" variable="BUS_AREA" cfsqltype="cf_sql_integer">
        <cfprocparam type="in" value="#spp_FORECAST_FC_ID#" variable="FORECAST_FC_ID" cfsqltype="cf_sql_integer">
        <cfprocparam type="in" value="#spp_Forecast_Description#" variable="Forecast_Description" cfsqltype="cf_sql_varchar">
        <cfprocparam type="in" value="#spp_TCH_FC_ID#" variable="TCH_FC_ID" cfsqltype="cf_sql_varchar">
        <cfprocparam type="in" value="#spp_TCH_Restricted#" variable="TCH_Restricted" cfsqltype="cf_sql_integer">
        <cfprocparam type="in" value="#spp_TCH_Description#" variable="TCH_Description" cfsqltype="cf_sql_varchar">
        <cfprocparam type="in" value="#createodbcdate(spp_START_DATE)#" variable="START_DATE" cfsqltype="CF_SQL_DATE">
        <cfprocparam type="in" value="#createodbcdate(spp_END_DATE)#" variable="END_DATE" cfsqltype="CF_SQL_DATE">
        <cfprocparam type="in" value="#spp_Description#" variable="Description" cfsqltype="cf_sql_varchar">
        <cfprocparam type="in" value="#spp_Internal_Order#" variable="Internal_Order" cfsqltype="cf_sql_varchar">
        <cfprocparam type="in" value="#spp_Company_Cd#" variable="Company_Cd" cfsqltype="cf_sql_varchar">
        <cfprocparam type="in" value="#spp_Salary#" variable="Salary" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_Fringe#" variable="FB_AMT" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_THISUSER#" variable="MOD_USERNAME" cfsqltype="cf_sql_varchar">
        <cfprocparam type="in" value="#spp_Acct_Type#" variable="Acct_Type" cfsqltype="cf_sql_varchar">
        <cfprocparam type="in" value="#spp_TBN_GL_REV_OFFSET#" variable="TBN_GL_REV_OFFSET" cfsqltype="cf_sql_varchar">
        <cfprocparam type="in" value="#spp_BUS_AREA_GROUP_COLUMN#" variable="BUS_AREA_GROUP_COLUMN" cfsqltype="cf_sql_integer">
        <cfprocparam type="in" value="#spp_salary_FP01#" variable="salary_FP01" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_salary_FP02#" variable="salary_FP02" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_salary_FP03#" variable="salary_FP03" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_salary_FP04#" variable="salary_FP04" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_salary_FP05#" variable="salary_FP05" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_salary_FP06#" variable="salary_FP06" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_salary_FP07#" variable="salary_FP07" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_salary_FP08#" variable="salary_FP08" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_salary_FP09#" variable="salary_FP09" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_salary_FP10#" variable="salary_FP10" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_salary_FP11#" variable="salary_FP11" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_salary_FP12#" variable="salary_FP12" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_FB_AMT_FP01#" variable="FB_AMT_FP01" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_FB_AMT_FP02#" variable="FB_AMT_FP02" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_FB_AMT_FP03#" variable="FB_AMT_FP03" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_FB_AMT_FP04#" variable="FB_AMT_FP04" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_FB_AMT_FP05#" variable="FB_AMT_FP05" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_FB_AMT_FP06#" variable="FB_AMT_FP06" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_FB_AMT_FP07#" variable="FB_AMT_FP07" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_FB_AMT_FP08#" variable="FB_AMT_FP08" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_FB_AMT_FP09#" variable="FB_AMT_FP09" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_FB_AMT_FP10#" variable="FB_AMT_FP10" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_FB_AMT_FP11#" variable="FB_AMT_FP11" cfsqltype="cf_sql_double">
        <cfprocparam type="in" value="#spp_FB_AMT_FP12#" variable="FB_AMT_FP12" cfsqltype="cf_sql_double">
</cfstoredproc>
