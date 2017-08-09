    <!--- From PERS_SUBAREA and JOB_CODE, we can derive the correct CLASS and BENEFIT_LVL --->
	<cfswitch expression="#val(variables.PERS_SUBAREA)#">
    	<cfcase value="1">
	        <cfset variables.BENEFIT_LVL = "FACULTY0">
	    	<cfset ThisClass = "FACULTY">
        </cfcase>
    	<cfcase value="2">
        	<cfset variables.BENEFIT_LVL = "FACULTY1">
	    	<cfset ThisClass = "FACULTY">
        </cfcase>
    	<cfcase value="3">
        	<cfset variables.BENEFIT_LVL = "FACULTY2">
	    	<cfset ThisClass = "FACULTY">
        </cfcase>
    	<cfcase value="4">
        	<cfset variables.BENEFIT_LVL = "STAFF0">
	    	<cfset ThisClass = "STAFF">
        </cfcase>
    	<cfcase value="5">
        	<cfset variables.BENEFIT_LVL = "STAFFR">
	    	<cfset ThisClass = "STAFF">
        </cfcase>
    	<cfcase value="6">
        	<cfset variables.BENEFIT_LVL = "STAFF1">
	    	<cfset ThisClass = "STAFF">
        </cfcase>
    	<cfcase value="7">
        	<cfset variables.BENEFIT_LVL = "STAFF2">
	    	<cfset ThisClass = "STAFF">
        </cfcase>
    	<cfcase value="8">
        	<cfswitch expression="#variables.JOB_KEY#">
				<cfcase value="1345">
		        	<cfset variables.BENEFIT_LVL = "ST_GRAD_STUDENT">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
				<cfcase value="1347">
		        	<cfset variables.BENEFIT_LVL = "ST_GRAD_STUDENT">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
				<cfcase value="1348">
		        	<cfset variables.BENEFIT_LVL = "ST_GRAD_STUDENT">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
				<cfcase value="1349">
		        	<cfset variables.BENEFIT_LVL = "ST_GRAD_STUDENT">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
				<cfcase value="1350">
		        	<cfset variables.BENEFIT_LVL = "ST_GRAD_STUDENT">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
				<cfcase value="1351">
		        	<cfset variables.BENEFIT_LVL = "ST_GRAD_STUDENT">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
				<cfcase value="1352">
		        	<cfset variables.BENEFIT_LVL = "ST_GRAD_STUDENT">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
                <cfdefaultcase>
		        	<cfset variables.BENEFIT_LVL = "GRAD_STUDENT">
			    	<cfset ThisClass = "FELLOW">
                </cfdefaultcase>
            </cfswitch>
        </cfcase>
    	<cfcase value="9">
        	<cfswitch expression="#variables.JOB_KEY#">
				<cfcase value="83325">
		        	<cfset variables.BENEFIT_LVL = "ST_MED_STUDENT">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
                <cfdefaultcase>
		        	<cfset variables.BENEFIT_LVL = "MED_STUDENT">
			    	<cfset ThisClass = "FELLOW">
                </cfdefaultcase>
            </cfswitch>
        </cfcase>
    	<cfcase value="10">
        	<cfset variables.BENEFIT_LVL = "OTHER_BCM_STUDENT">
	    	<cfset ThisClass = "STAFF">
        </cfcase>
    	<cfcase value="11">
			<cfswitch expression="#variables.JOB_KEY#">
				<cfcase value="939393">
		        	<cfset variables.BENEFIT_LVL = "RESIDENT">
			    	<cfset ThisClass = "FELLOW">
                </cfcase>
                <cfdefaultcase>
				  <cfset variables.BENEFIT_LVL = "NON_BCM_STUDENT">
        		  <cfset ThisClass = "STAFF">
                </cfdefaultcase>
            </cfswitch>        </cfcase>
    	<cfcase value="12">
        	<cfswitch expression="#variables.JOB_KEY#">
				<cfcase value="1336">
		        	<cfset variables.BENEFIT_LVL = "ST_RESIDENT">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
                <cfdefaultcase>
		        	<cfset variables.BENEFIT_LVL = "RESIDENT">
			    	<cfset ThisClass = "FELLOW">
                </cfdefaultcase>
            </cfswitch>
        </cfcase>
    	<cfcase value="13">
        	<cfswitch expression="#variables.JOB_KEY#">
				<cfcase value="1340">
		        	<cfset variables.BENEFIT_LVL = "ST_PDOC_MD_CLINICAL">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
				<cfcase value="1341">
		        	<cfset variables.BENEFIT_LVL = "ST_PDOC_MD_CLINICAL">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
				<cfcase value="1342">
		        	<cfset variables.BENEFIT_LVL = "ST_PDOC_MD_CLINICAL">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
				<cfcase value="109742">
		        	<cfset variables.BENEFIT_LVL = "ST_PDOC_MD_CLINICAL">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
                <cfdefaultcase>
		        	<cfset variables.BENEFIT_LVL = "PDOC_MD_CLINICAL">
			    	<cfset ThisClass = "FELLOW">
                </cfdefaultcase>
            </cfswitch>
        </cfcase>
    	<cfcase value="14">
        	<cfswitch expression="#variables.JOB_KEY#">
				<cfcase value="1340">
		        	<cfset variables.BENEFIT_LVL = "ST_PDOC_MD_RESEARCH">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
				<cfcase value="1341">
		        	<cfset variables.BENEFIT_LVL = "ST_PDOC_MD_RESEARCH">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
				<cfcase value="1342">
		        	<cfset variables.BENEFIT_LVL = "ST_PDOC_MD_RESEARCH">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
				<cfcase value="109742">
		        	<cfset variables.BENEFIT_LVL = "ST_PDOC_MD_RESEARCH">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
                <cfdefaultcase>
		        	<cfset variables.BENEFIT_LVL = "PDOC_MD_RESEARCH">
			    	<cfset ThisClass = "FELLOW">
                </cfdefaultcase>
            </cfswitch>
        </cfcase>
    	<cfcase value="15">
        	<cfswitch expression="#variables.JOB_KEY#">
				<cfcase value="1340">
		        	<cfset variables.BENEFIT_LVL = "ST_PDOC_PHD">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
				<cfcase value="1341">
		        	<cfset variables.BENEFIT_LVL = "ST_PDOC_PHD">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
				<cfcase value="1342">
		        	<cfset variables.BENEFIT_LVL = "ST_PDOC_PHD">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
				<cfcase value="109742">
		        	<cfset variables.BENEFIT_LVL = "ST_PDOC_PHD">
			    	<cfset ThisClass = "STAFF">
                </cfcase>
                <cfdefaultcase>
		        	<cfset variables.BENEFIT_LVL = "PDOC_PHD">
			    	<cfset ThisClass = "FELLOW">
                </cfdefaultcase>
            </cfswitch>
        </cfcase>
    </cfswitch>
    <!--- End of Setting CLASS and BENEFIT_LVL --->