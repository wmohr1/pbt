<CFSWITCH expression = "#session.pbt_Record_Type_Selection#">
	<CFCASE value="1">
		AND
			REC_TYPE = 1
	</CFCASE>
	<CFCASE value="2">
		AND
			REC_TYPE = 2
	</CFCASE>
	<CFCASE value="3">
		AND
			REC_TYPE <> 1
	</CFCASE>
</CFSWITCH>