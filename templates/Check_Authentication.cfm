    <cfparam name="session.loggedin" default="false" />

	 <CFIF NOT session.loggedin>
          <HEAD>
              <TITLE>SURVIVOR XV</TITLE>
              <STYLE TYPE="TEXT/CSS">
                  * {margin: 0; padding: 0}
                  #bg_image {
                  width: 100%;
                  height: 100%;
                  left: 0px;
                  top: 0px;
                  position: absolute;
                  z-index: 0;
                  }
                  #contents {
                  padding-left: 150px;
                  z-index: 1;
                  position: absolute;
                  }
                  P {
                  FONT-SIZE: 100%;
                  COLOR: 000066;
                  FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
                  TEXT-ALIGN: Left;
                  }
                  
                  H1 {
                      FONT-SIZE: 140%;
                      FONT-WEIGHT: BOLD;
                      COLOR: 333399;
                      FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
                  }
                  
                  H2 {
                      color: cc6600;
                      FONT-SIZE : 120%;
                      FONT-WEIGHT : BOLD;
                      FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
                  }
                  
                  H3 {
                      COLOR : 23044b;
                      FONT-SIZE : 100%;
                      FONT-WEIGHT : BOLDER;
                      FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
                  }
                  
                  H4 {
                      COLOR: MAROON; 
                      FONT-SIZE : 100%;
                      FONT-WEIGHT : BOLDER;
                      FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
                  }
                  
                  H5 {
                      COLOR: PURPLE; 
                      FONT-SIZE : 100%;
                      FONT-WEIGHT : BOLDER;
                      FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
                  }
                  
                  cfinput {
                      FONT-WEIGHT: BOLD;
                      COLOR: #4B0082;
                      FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
                      FONT-SIZE: 8PT;
                  }
                  
                  TD {
                      FONT-SIZE: 75%;
                      FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
                  }
                  
                  .ERROR_RED {
                      COLOR: RED;
                  }
                  
                  .FOOTER {
                      FONT-SIZE: 75%;
                      FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
                      COLOR: 000080;
                  }
                  
                  .BIG_HEADING {
                      FONT-SIZE: 200%;
                      FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
                      COLOR: #228B22;
                  }
                  
                  .HANG {
                      PADDING-LEFT: 2EM; 
                      TEXT-INDENT: -2EM;
                      FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
                  }
                  
                  .NOPRINT {
                      DISPLAY: NONE 
                  }
              </STYLE> 
          </HEAD>
          <body style="bgcolor: #879DDA; FONT-FAMILY: 'VERDANA, ARIAL, HELVETICA, SANS-SERIF'; FONT-SIZE: LARGEST; FONT-WEIGHT: BOLD; color: #000066;" onLoad="self.focus(); document.login.username.focus()"> 
              <!-- this creates the background image -->
          <div id="bg_image"> 
              <img src="../images/Islandmoves1.jpg" style="width: 100%; height: 100%;">
          </div>
          <div id="contents">
         <CFOUTPUT>
             <CFIF ISDEFINED("session.pbt_first_name")><CFSET FIRST_NAME = 0></CFIF>
             <CFIF ISDEFINED("session.pbt_THISUSER")><CFSET THISUSER = 0></CFIF>
             <CFIF ISDEFINED("session.pbt_ORG_UNIT")><CFSET ORG_UNIT = 0></CFIF>
             <CFIF ISDEFINED("session.pbt_FI_SEC")><CFSET FI_SEC = 0></CFIF>
             <CFIF ISDEFINED("session.pbt_ADMIN_FI_SEC")><CFSET ADMIN_FI_SEC = 0></CFIF>
             <CFIF ISDEFINED("session.pbt_ADMIN_ORG_UNIT")><CFSET ADMIN_ORG_UNIT = 0></CFIF>
             <CFIF ISDEFINED("session.pbt_ADMINISTRATOR")><CFSET ADMINISTRATOR = 0></CFIF>
         </CFOUTPUT>
         <BODY BACKGROUND="/IMAGES/BRICKWALL1.JPG">
         <TABLE ALIGN="CENTER" VALIGN="TOP">
             <TR>
                 <TD ALIGN="CENTER"><H3 STYLE = "COLOR: RED; FONT-SIZE: 12 PT;"><STRONG><EM>RESTRICTED ACCESS</EM></STRONG><BR><BR><BR> IF YOU WERE LOGGED ON, YOUR SESSION HAS TIMED OUT.<BR>  PLEASE LOG IN AGAIN WITH VALID USER ID AND PASSWORD.</H3></TD>
             </TR>
         </TABLE>
         <META HTTP-EQUIV="REFRESH" CONTENT="3; URL=../login_form.cfm">
         <CFABORT>
         </BODY>
          </div>
     </CFIF>
