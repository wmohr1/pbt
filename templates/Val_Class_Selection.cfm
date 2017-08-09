<!--- AND TO_NUMBER(SUBSTR(JOB_CODE,1,4)) BETWEEN 1000 AND 1400 --->
<CFIF IsDefined("Val_Class")>
	<CFSWITCH expression = "#Val_Class#">
		<CFCASE value = "1">
			AND 
				EMP_CLASS = 'FACULTY'
		</CFCASE>
		<CFCASE value = "2">
			AND 
				EMP_CLASS = 'STAFF'
		</CFCASE>
		<CFCASE value = "3">
			AND 
				EMP_CLASS = 'FELLOW'
		</CFCASE>
	</CFSWITCH>
</CFIF>