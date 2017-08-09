<!---  
TEMPLATE NAME: q_LogAFEntry.cfm
CREATION DATE: ~2014
AUTHOR: Bill Mohr (832.824.6736)
LAST MODIFIED: 07/19/2016
MODIFIED BY: Bill Mohr (832.824.6736)

SUMMARY:  Originally, this program logged all changes from the original AF Form, but as there were so many fields and comparisons, it took way to long to run and was disabled. Recently, we changed the AF entry form so that just a single value is entered at a time making the logging much easier and this log now just records the one change.

SPECIAL NOTES:
07/07/2016: In addition to 'logging' the change to PEDI_PBT_AF, the program was modified along with the new AF form to go ahead and update the appropriate value in the table itself.
--->

  <!--- Update AF --->
  <cfset ThisCOMMITMENT_ITEM = ThisBUS_AREA & "_" & ThisGL>

   <cfquery name="q_Update_AF" datasource="#THIS.DSN#">
       UPDATE
          PEDI_PBT_AF
       SET
          #ThisCOMMITMENT_ITEM# = '#ThisAmount#',
          AF_UPDATED_DATE = #CreateODBCDateTime(NOW())#,
          AF_UPDATED_BY = '#session.pbt_THISUSER#'
       WHERE
           Fundcenter = '#ThisFUNDCENTER#'			
       AND
           FY = '#session.pbt_PREF_DEF_FY#'
   </cfquery>

<cfif OldAmount IS 0>
  <cfset variables.MOD_ACTION = "NEW ENTRY">
<cfelseif ThisAmount IS 0>
  <cfset variables.MOD_ACTION = "AMOUNT CLEARED">
<cfelseif OldAmount LT ThisAmount>
  <cfset variables.MOD_ACTION = "AMOUNT INCREASED">
<cfelse>
  <cfset variables.MOD_ACTION = "AMOUNT DECREASED">
</cfif>        

<cfquery name="q_LogAF" datasource="#THIS.DSN#">
  INSERT INTO
      PEDI_PBT_AF_LOG
          (FUNDCENTER,
          BUS_AREA,
          GL,
          FY,
          ORIGINAL_AMOUNT,
          NEW_AMOUNT,
          MOD_ACTION,
          MOD_USERNAME,
          MOD_DATE)
      VALUES
          ('#ThisFUNDCENTER#',
          '#ThisBUS_AREA#',
          '#ThisGL#',
          '#session.pbt_PREF_DEF_FY#',
          '#OldAmount#',
          '#ThisAmount#',
          '#Variables.MOD_ACTION#',
          '#session.pbt_THISUSER#',
          #CreateODBCDateTime(NOW())#)
</cfquery>