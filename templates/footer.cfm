<CFIF NOT IsDefined("FORM.print")>
    <table align = "left"  id = "noprint" border = "0" Valign = "Bottom" name = "Footer" cellspacing="0" cellpadding="0" width = "800">
        <!--- <TR>
            <TD align = "Center">
                
                    <cfif IsDefined("session.pbt_Realm") AND session.pbt_Realm IS NOT "99999999"><cfoutput><a class = "footer" href="index.cfm?Realm=#session.pbt_Realm#&Template_Name=PEDI_PBT_home.cfm"></cfoutput>Section Home</a>&nbsp;&nbsp;</cfif><cfset LoopCounter = 1><cfset BreakLength = 0><cfoutput Query = "q_Get_Buttons"><cfif NOT q_Get_Buttons.INTRANET OR IsAuthenticated><cfset StringLength = len(trim(q_Get_Buttons.BUTTON_NAME)) + 3><cfif (BreakLength + StringLength) GT 118><cfset BreakLength = 0></cfif><a class = "footer" href="#q_Get_Buttons.LINK#">#q_Get_Buttons.BUTTON_NAME#</a>&nbsp;&nbsp;&nbsp;<cfset BreakLength = BreakLength + StringLength></cfif><cfset LoopCounter = LoopCounter + 1></cfoutput>&nbsp;<cfoutput><a class = "footer" href="index.cfm?Realm=#session.pbt_Realm#&This_Template=PEDI_PBT_contact_us.cfm">Contact Section</a></cfoutput>
                
            </TD>
        </TR> --->
        <TR>
            <TD align = "Center">
                <cfoutput>
                    <a class = "footer" href="http://www.bcm.edu/pediatrics" target="_blank">PEDIATRICS HOME</a>&nbsp;|&nbsp;<a class = "footer" href="https://www.bcm.edu/departments/pediatrics/about-us" target="_blank">ABOUT US</a>&nbsp;|&nbsp;<a class = "footer" href="https://www.bcm.edu/departments/pediatrics/sections-divisions-centers" target="_blank">SECTIONS & CENTERS</a>
                </cfoutput>
            </TD> 
        </TR>
        <tr>
            <TD align = "Center">
                <a class = "footer" href="http://www.bcm.edu" target="_blank">BCM HOME</a>&nbsp;|&nbsp;<a class = "footer" href="http://www.bcm.edu/privacynotices.html" title="Click here for privacy notices." target="_blank">PRIVACY NOTICES</a>&nbsp;|&nbsp;<a class = "footer" href="http://www.texaschildrenshospital.org" target="_blank">TCH HOME</a>
            </td>
        </tr>
        <tr>
            <TD align = "Center">
                <a class = "footer" href="http://www.bcm.edu" title="Baylor College of Medicine Welcome Page" target="_blank">&copy; <cfoutput>#dateformat(now(),"YYYY")#</cfoutput>, Baylor College of Medicine, One Baylor Plaza Houston, Texas  77030</a>
            </td>
        </tr>
        <tr>
            <TD align = "Center" class="Footer">
                (Modified <!--- <cf_PageMod contentpath = "#CGI.Path_Translated#" BaseTemplate = "#CGI.Path_Translated#"> --->)
            </td> 
        </tr>
    </Table>
    </div>
    <cfset tock = GetTickCount()>
    <cfif session.pbt_THISUSER IS "wmohr"> 
        <cfif IsDefined("tick")>
            <cfset time = tock-tick>
            <cfoutput>it took #time# ms</cfoutput>
        <cfelse>
            stopwatch broke...
        </cfif>    
    </cfif>
</CFIF>