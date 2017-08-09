<cfstoredproc datasource="#request.dsn#" procedure="#request.proc#" blockfactor="50">
	<cfprocparam type="in" value="#spp_BCM_ID#" dbvarname="bcmid" cfsqltype="cf_sql_varchar">
	<cfprocparam type="in" value="#spp_rec_type#" dbvarname="rectype" cfsqltype="cf_sql_integer">
	<cfprocparam type="in" value="#spp_fy#" dbvarname="fy" cfsqltype="cf_sql_integer">
	<cfprocresult name="getrecord"/>
</cfstoredproc>