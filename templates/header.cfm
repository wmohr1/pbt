<!---  
Template: header.cfm
Documentation: Survivor_Work_Documentation.xlsx
Index: 5027
Created: ~2002
Author: Bill Mohr (wmohr@bcm.edu 832-824-6736)
Last Modified: 8/9/2017

Summary:  Main Header/Banner top menu for the Survivor Application.

Modifications:
07/26/2017: Adding Internal Documentation header info and commenting out the "Exp Summary" option, for now.
--->

<cfinclude template = "../templates/Check_Authentication.cfm">

<style type="text/css" media="print">
.landScape
{ 
 width: 100%; 
 height: 100%; 
 margin: 0% 0% 0% 0%; 
 filter: progid:DXImageTransform.Microsoft.BasicImage(Rotation=3);
} 
</style>

<CFIF NOT IsDefined("FORM.print")>
	<cfset tick = GetTickCount()>
    <head>
		 <cfquery name="q_GetFYInfo" datasource="#THIS.DSN#">
			 SELECT
				 *
			 FROM
				 PEDI_PBT_ARCHIVE
			 WHERE
				 BUDGET_FY = '#session.pbt_PREF_DEF_FY#'
		 </cfquery>
    
    <cfoutput query="q_GetFYInfo">
        <cfset ThisTitle = q_GetFYInfo.APPLICATION_NAME & " (FY_" & session.pbt_PREF_DEF_FY & ")">
        <title>#ThisTitle#</title>
    </cfoutput>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    
    <cfif IsDefined("session.pbt_archiver") and session.pbt_archiver>
        <STYLE TYPE="TEXT/CSS">
            BODY {
                BACKGROUND-COLOR: thistle;
                MARGIN-TOP: 0PX; MARGIN-RIGHT: 0PX; MARGIN-BOTTOM: 0PX; MARGIN-LEFT: 0PX;
                FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
            }
        </STYLE>
    <cfelse>
        <STYLE TYPE="TEXT/CSS">
            BODY {
                BACKGROUND-COLOR: 91b2e0;
                MARGIN-TOP: 0PX; MARGIN-RIGHT: 0PX; MARGIN-BOTTOM: 0PX; MARGIN-LEFT: 0PX;
                FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
            }
        </STYLE>
    </cfif>
    
    <STYLE TYPE="TEXT/CSS">
    P {
        FONT-SIZE: 80%;
        COLOR: #000080;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
        TEXT-ALIGN: JUSTIFY;
    }
    
    H1 {
        FONT-SIZE: 120%;
        FONT-WEIGHT: BOLD;
        COLOR: Green;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
    }
    
    H2 {
        FONT-SIZE : 100%;
        COLOR : #6a5acd;
        FONT-WEIGHT : BOLD;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
    }
    
    H3 {
        COLOR : Navy;
        FONT-SIZE : 80%;
        FONT-WEIGHT : BOLDER;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
    }
    
    H4 {
        COLOR: MAROON; 
        FONT-SIZE : 80%;
        FONT-WEIGHT : BOLDER;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
    }
    
    H5 {
        COLOR: PURPLE; 
        FONT-SIZE : 60%;
        FONT-WEIGHT : BOLD;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
    }
    
    INPUT {
        FONT-WEIGHT: BOLD;
        COLOR: #4B0082;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
        FONT-SIZE: 90%;
    }
    
    TEXTAREA {
        FONT-WEIGHT: BOLD;
        COLOR: #4B0082;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
        FONT-SIZE: 70%;
    }
    
    
    
    A:LINK {
        COLOR: #0000FF;
        TEXT-DECORATION: NONE;
        FONT-WEIGHT: BOLD;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
    }
    
    A:VISITED {
        COLOR: #4B0082;
        TEXT-DECORATION: NONE;
        FONT-WEIGHT: BOLD;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
    }
    
    A:HOVER {
        FONT-WEIGHT: BOLD;
        COLOR: #FF9933;
        TEXT-DECORATION: NONE;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
    }
    
    A:ACTIVE {
        FONT-WEIGHT: BOLD;
        COLOR: #0000FF;
        TEXT-DECORATION: NONE;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
    }
    
    A.TOPNAV:LINK {
        COLOR: Navy;
        FONT-WEIGHT: NORMAL;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
        FONT-SIZE: 90%;
    }
    
    A.TOPNAV:VISITED {
        COLOR: Navy;
        FONT-WEIGHT: NORMAL;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
        FONT-SIZE: 90%;
    }
    
    A.TOPNAV:HOVER {
        FONT-WEIGHT: BOLD;
        COLOR: Goldenrod;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
        FONT-SIZE: 90%;
    }
    
    A.TOPNAV:ACTIVE {
        FONT-WEIGHT: NORMAL;
        COLOR: Navy;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
        FONT-SIZE: 90%;
    }
    
    A.LHNAV:LINK {
        COLOR: #FFFF00;
        TEXT-DECORATION: UNDERLINE;
        FONT-WEIGHT: NORMAL;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
        FONT-SIZE: 70%;
    }
    
    A.LHNAV:VISITED {
        COLOR: #F0E68C;
        TEXT-DECORATION: NONE;
        FONT-WEIGHT: NORMAL;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
        FONT-SIZE: 70%;
    }
    
    A.LHNAV:HOVER {
        FONT-WEIGHT: NORMAL;
        COLOR: #FF9933;
        TEXT-DECORATION: UNDERLINE;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
        FONT-SIZE: 70%;
    }
    
    A.LHNAV:ACTIVE {
        FONT-WEIGHT: BOLD;
        COLOR: #FFFF00;
        TEXT-DECORATION: UNDERLINE;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
        FONT-SIZE: 70%;
    }
    
    TD {
        FONT-SIZE: 75%;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
    }
    
    TH {
        FONT-SIZE: 85%;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
        COLOR: #FFFF00;
        BACKGROUND-COLOR: #00008B;
    }
    
    
    .ERROR_RED {
        COLOR: RED;
    }
    
    .NO_REC {
        COLOR: YELLOW; 
        BACKGROUND-COLOR: BLACK; 
        FONT-WEIGHT: BOLD; 
        FONT-SIZE: LARGER;
    }
    
    .MMCOLTITLE {
        BACKGROUND-COLOR: SILVER; 
        COLOR: NAVY; 
        FONT-WEIGHT: BOLD; 
        FONT-STYLE: OBLIQUE; 
        TEXT-ALIGN: CENTER; 
        VERTICAL-ALIGN: BOTTOM;
    }
    
    .af_row_labels {font-size: 65%; font-family:Verdana, Arial, Helvetica, sans-serif;}
    .af_col_labels {font-size: 75%; font-family:Verdana, Arial, Helvetica, sans-serif; font-weight: bold;}
    
    .FOOTER {
        FONT-SIZE: 75%;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
        COLOR: #000080;
    }
    
    .BIG_HEADING {
        FONT-SIZE: 120%;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
        COLOR: #228B22;
    }
    
    .HANG {
        PADDING-LEFT: 2EM; 
        TEXT-INDENT: -2EM;
        FONT-FAMILY: VERDANA, ARIAL, HELVETICA, SANS-SERIF;
    }
    
    .noprint {display: none ;}
</STYLE>
    
    <!-- Fireworks MX Dreamweaver MX target.  Created Fri Aug 23 15:09:01 GMT-0500 (Central Standard Time) 2002-->
    <script language="JavaScript">
            <!--
            function MM_findObj(n, d) { //v4.01
              var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
                d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
              if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
              for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
              if(!x && d.getElementById) x=d.getElementById(n); return x;
            }
            function MM_swapImage() { //v3.0
              var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
               if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
            }
            function MM_swapImgRestore() { //v3.0
              var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
            }
            
            function MM_preloadImages() { //v3.0
             var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
               var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
               if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
            }
            
            //-->
             function chkForm(Frm)
             {
                if (Frm.EMP_GROUP.value=='0')
                {alert('You must select a valid Employee Group!');return false;}
    
                    else
                  
                        if (Frm.EMP_SUBGROUP.value=='0')
                        {alert('You must select a valid Employee SubGroup!');return false;}
    
                            else
                  
                                if (Frm.PERS_SUBAREA.value=='0')
                                {alert('You must select a valid Personnel SubArea!');return false;}
    
                                    else
                                            
                                        if (Frm.PAY_SCALE_GROUP.value=='')
                                        {alert('You must select a valid Pay Scale Group!');return false;}
                                        
    
                  else
                  {return true;}			  
             }
             
            <!--
            //- Populate Second Drop-down based on first -//
            var arrItems1 = new Array();
            var arrItemsGrp1 = new Array();
            
            //- Regular Employee - 1 -//
            arrItems1 [ 3 ]  = "Salaried FT Exempt";
            arrItemsGrp1 [ 3 ]  = 1;
            arrItems1 [ 4 ]  = "Salaried FT Non-Exempt";
            arrItemsGrp1 [ 4 ]  = 1;
            arrItems1 [ 5 ]  = "Salaried PT Exempt";
            arrItemsGrp1 [ 5 ]  = 1;
            arrItems1 [ 6 ]  = "Salaried PT Non-Exempt";
            arrItemsGrp1 [ 6 ]  = 1;
            arrItems1 [ 7 ]  = "Hourly Part-Time";
            arrItemsGrp1 [ 7 ]  = 1;
            arrItems1 [ 8 ]  = "Non-Paid";
            arrItemsGrp1 [ 8 ]  = 1;
            
            //- Temporary - 2 -//
            arrItems1 [ 9 ]  = "Salaried FT Exempt";
            arrItemsGrp1 [ 9 ]  = 2;
            arrItems1 [ 10 ]  = "Salaried FT Non-Exempt";
            arrItemsGrp1 [ 10 ]  = 2;
            arrItems1 [ 11 ]  = "Salaried PT Exempt";
            arrItemsGrp1 [ 11 ]  = 2;
            arrItems1 [ 12 ]  = "Salaried PT Non-Exempt";
            arrItemsGrp1 [ 12 ]  = 2;
            arrItems1 [ 13 ]  = "Hourly Full-Time";
            arrItemsGrp1 [ 13 ]  = 2;
            arrItems1 [ 14 ]  = "Hourly Part-Time";
            arrItemsGrp1 [ 14 ]  = 2;
            arrItems1 [ 15 ]  = "Non-Paid";
            arrItemsGrp1 [ 15 ]  = 2;
    
            //- Leave of Absence - 3 -//
            arrItems1 [ 16 ]  = "Salaried FT Exempt";
            arrItemsGrp1 [ 16 ]  = 3;
            arrItems1 [ 17 ]  = "Salaried FT Non-Exempt";
            arrItemsGrp1 [ 17 ]  = 3;
            arrItems1 [ 18 ]  = "Salaried PT Exempt";
            arrItemsGrp1 [ 18 ]  = 3;
            arrItems1 [ 19 ]  = "Salaried PT Non-Exempt";
            arrItemsGrp1 [ 19 ]  = 3;
            arrItems1 [ 20 ]  = "Hourly Part-Time";
            arrItemsGrp1 [ 20 ]  = 3;
            arrItems1 [ 21 ]  = "Non-Paid";
            arrItemsGrp1 [ 21 ]  = 3;
    
            //- Indep. Contractor - 6 -//
            arrItems1 [ 22 ]  = "Non-Paid";
            arrItemsGrp1 [ 22 ]  = 6;
            
            //- Voluntary - 7 -//
            arrItems1 [ 23 ]  = "Non-Paid";
            arrItemsGrp1 [ 23 ]  = 7;
            
            var arrItems2 = new Array();
            var arrItemsGrp2 = new Array();
            
            //- Regular Employee-Salaried FT Exempt - 3 -//
            arrItems2 [ 24 ]  = "Faculty0";
            arrItemsGrp2 [ 24 ]  = 3
            arrItems2 [ 25 ]  = "Faculty1";
            arrItemsGrp2 [ 25 ]  = 3
            arrItems2 [ 26 ]  = "Faculty2";
            arrItemsGrp2 [ 26 ]  = 3
            arrItems2 [ 27 ]  = "Staff0";
            arrItemsGrp2 [ 27 ]  = 3
            arrItems2 [ 28 ]  = "StaffR";
            arrItemsGrp2 [ 28 ]  = 3
            arrItems2 [ 29 ]  = "Staff1";
            arrItemsGrp2 [ 29 ]  = 3
            arrItems2 [ 30 ]  = "Staff2";
            arrItemsGrp2 [ 30 ]  = 3
            arrItems2 [ 31 ]  = "Other BCM Student";
            arrItemsGrp2 [ 31 ]  = 3
            arrItems2 [ 32 ]  = "Resident";
            arrItemsGrp2 [ 32 ]  = 3
            arrItems2 [ 33 ]  = "PDoc MD (Clincal)";
            arrItemsGrp2 [ 33 ]  = 3
            arrItems2 [ 34 ]  = "PDoc MD (Research)";
            arrItemsGrp2 [ 34 ]  = 3
            arrItems2 [ 35 ]  = "PDoc PhD (Research)";
            arrItemsGrp2 [ 35 ]  = 3
            
            //- Regular Employee-Salaried FT Non-Exempt - 4 -//
            arrItems2 [ 36 ]  = "Staff0";
            arrItemsGrp2 [ 36 ]  = 4
            arrItems2 [ 37 ]  = "StaffR";
            arrItemsGrp2 [ 37 ]  = 4
            
            //- Regular Employee-Salaried PT Exempt - 5 -//
            arrItems2 [ 38 ]  = "Faculty0";
            arrItemsGrp2 [ 38 ]  = 5
            arrItems2 [ 39 ]  = "Faculty2";
            arrItemsGrp2 [ 39 ]  = 5
            arrItems2 [ 40 ]  = "Staff0";
            arrItemsGrp2 [ 40 ]  = 5
            arrItems2 [ 41 ]  = "StaffR";
            arrItemsGrp2 [ 41 ]  = 5
            arrItems2 [ 42 ]  = "Staff2";
            arrItemsGrp2 [ 42 ]  = 5
            arrItems2 [ 43 ]  = "Grad Student";
            arrItemsGrp2 [ 43 ]  = 5
            arrItems2 [ 44 ]  = "Med Student";
            arrItemsGrp2 [ 44 ]  = 5
            arrItems2 [ 45 ]  = "Other BCM Student";
            arrItemsGrp2 [ 45 ]  = 5
            arrItems2 [ 46 ]  = "Non BCM Student";
            arrItemsGrp2 [ 46 ]  = 5
            arrItems2 [ 47 ]  = "Resident";
            arrItemsGrp2 [ 47 ]  = 5
            arrItems2 [ 48 ]  = "PDoc MD (Clincal)";
            arrItemsGrp2 [ 48 ]  = 5
            arrItems2 [ 49 ]  = "PDoc MD (Research)";
            arrItemsGrp2 [ 49 ]  = 5
            arrItems2 [ 50 ]  = "PDoc PhD (Research)";
            arrItemsGrp2 [ 50 ]  = 5
    
            //- Regular Employee-Salaried PT Non-Exempt - 6 -//
            arrItems2 [ 51 ]  = "Staff0";
            arrItemsGrp2 [ 51 ]  = 6
            arrItems2 [ 52 ]  = "StaffR";
            arrItemsGrp2 [ 52 ]  = 6
    
            //- Regular Employee-Hourly Part-Time - 7 -//
            arrItems2 [ 53 ]  = "Faculty0";
            arrItemsGrp2 [ 53 ]  = 7
            arrItems2 [ 54 ]  = "Staff0";
            arrItemsGrp2 [ 54 ]  = 7
            arrItems2 [ 55 ]  = "Med Student";
            arrItemsGrp2 [ 55 ]  = 7
            arrItems2 [ 56 ]  = "Other BCM Student";
            arrItemsGrp2 [ 56 ]  = 7
            arrItems2 [ 57 ]  = "Non BCM Student";
            arrItemsGrp2 [ 57 ]  = 7
    
            //- Regular Employee-Non-Paid - 8 -//
            arrItems2 [ 58 ]  = "Faculty0";
            arrItemsGrp2 [ 58 ]  = 8
            arrItems2 [ 59 ]  = "Staff0";
            arrItemsGrp2 [ 59 ]  = 8
            arrItems2 [ 60 ]  = "Grad Student";
            arrItemsGrp2 [ 60 ]  = 8
            arrItems2 [ 61 ]  = "Med Student";
            arrItemsGrp2 [ 61 ]  = 8
            arrItems2 [ 62 ]  = "Other BCM Student";
            arrItemsGrp2 [ 62 ]  = 8
            arrItems2 [ 63 ]  = "Non BCM Student";
            arrItemsGrp2 [ 63 ]  = 8
            arrItems2 [ 64 ]  = "Resident";
            arrItemsGrp2 [ 64 ]  = 8
            arrItems2 [ 65 ]  = "PDoc MD (Clincal)";
            arrItemsGrp2 [ 65 ]  = 8
            arrItems2 [ 66 ]  = "PDoc MD (Research)";
            arrItemsGrp2 [ 66 ]  = 8
            arrItems2 [ 67 ]  = "PDoc PhD (Research)";
            arrItemsGrp2 [ 67 ]  = 8
            
            //- Temporary - Salaried FT Exempt - 9 -//
            arrItems2 [ 68 ]  = "Faculty0";
            arrItemsGrp2 [ 68 ]  = 9
            arrItems2 [ 69 ]  = "Staff0";
            arrItemsGrp2 [ 69 ]  = 9
    
            //- Temporary - Salaried FT Non-Exempt - 10 -//
            arrItems2 [ 70 ]  = "Staff0";
            arrItemsGrp2 [ 70 ]  = 10
    
            //- Temporary - Salaried PT Exempt - 11 -//
            arrItems2 [ 71 ]  = "Faculty0";
            arrItemsGrp2 [ 71 ]  = 11
            arrItems2 [ 72 ]  = "Staff0";
            arrItemsGrp2 [ 72 ]  = 11
            arrItems2 [ 73 ]  = "Grad Student";
            arrItemsGrp2 [ 73 ]  = 11
            arrItems2 [ 75 ]  = "Other BCM Student";
            arrItemsGrp2 [ 75 ]  = 11
    
            //- Temporary - Salaried PT Non-Exempt - 12 -//
            arrItems2 [ 76 ]  = "Staff0";
            arrItemsGrp2 [ 76 ]  = 12
    
            //- Temporary - Hourly Full-Time - 13 -//
            arrItems2 [ 77 ]  = "Faculty0";
            arrItemsGrp2 [ 77 ]  = 13
            arrItems2 [ 78 ]  = "Staff0";
            arrItemsGrp2 [ 78 ]  = 13
            arrItems2 [ 79 ]  = "Non BCM Student";
            arrItemsGrp2 [ 79 ]  = 13
    
            //- Temporary - Hourly Part-Time - 14 -//
            arrItems2 [ 80 ]  = "Faculty0";
            arrItemsGrp2 [ 80 ]  = 14
            arrItems2 [ 81 ]  = "Staff0";
            arrItemsGrp2 [ 81 ]  = 14
            arrItems2 [ 82 ]  = "Med Student";
            arrItemsGrp2 [ 82 ]  = 14
            arrItems2 [ 83 ]  = "Other BCM Student";
            arrItemsGrp2 [ 83 ]  = 14
            arrItems2 [ 84 ]  = "Non BCM Student";
            arrItemsGrp2 [ 84 ]  = 14
    
            //- Temporary - Non-Paid - 15 -//
            arrItems2 [ 85 ]  = "Faculty0";
            arrItemsGrp2 [ 85 ]  = 15
            arrItems2 [ 86 ]  = "Staff0";
            arrItemsGrp2 [ 86 ]  = 15
            arrItems2 [ 87 ]  = "Grad Student";
            arrItemsGrp2 [ 87 ]  = 15
            arrItems2 [ 88 ]  = "Med Student";
            arrItemsGrp2 [ 88 ]  = 15
            arrItems2 [ 89 ]  = "Other BCM Student";
            arrItemsGrp2 [ 89 ]  = 15
            arrItems2 [ 90 ]  = "Non BCM Student";
            arrItemsGrp2 [ 90 ]  = 15
    
            //- Leave of Absence - Salaried FT Exempt - 16 -//
            arrItems2 [ 91 ]  = "Faculty0";
            arrItemsGrp2 [ 91 ]  = 16
            arrItems2 [ 92 ]  = "Faculty1";
            arrItemsGrp2 [ 92 ]  = 16
            arrItems2 [ 93 ]  = "Faculty2";
            arrItemsGrp2 [ 93 ]  = 16
            arrItems2 [ 94 ]  = "Staff0";
            arrItemsGrp2 [ 94 ]  = 16
            arrItems2 [ 95 ]  = "StaffR";
            arrItemsGrp2 [ 95 ]  = 16
            arrItems2 [ 96 ]  = "Staff1";
            arrItemsGrp2 [ 96 ]  = 16
            arrItems2 [ 97 ]  = "Staff2";
            arrItemsGrp2 [ 97 ]  = 16
            arrItems2 [ 98 ]  = "Other BCM Student";
            arrItemsGrp2 [ 98 ]  = 16
            arrItems2 [ 99 ]  = "Resident";
            arrItemsGrp2 [ 99 ]  = 16
            arrItems2 [ 100 ]  = "PDoc MD (Clincal)";
            arrItemsGrp2 [ 100 ]  = 16
            arrItems2 [ 101 ]  = "PDoc MD (Research)";
            arrItemsGrp2 [ 101 ]  = 16
            arrItems2 [ 102 ]  = "PDoc PhD (Research)";
            arrItemsGrp2 [ 102 ]  = 16
            
            //- Leave of Absence - Salaried FT Non-Exempt - 17 -//
            arrItems2 [ 103 ]  = "Staff0";
            arrItemsGrp2 [ 103 ]  = 17
            arrItems2 [ 104 ]  = "StaffR";
            arrItemsGrp2 [ 104 ]  = 17
            
            //- Leave of Absence -Salaried PT Exempt - 18 -//
            arrItems2 [ 105 ]  = "Faculty0";
            arrItemsGrp2 [ 105 ]  = 18
            arrItems2 [ 106 ]  = "Faculty2";
            arrItemsGrp2 [ 106 ]  = 18
            arrItems2 [ 107 ]  = "Staff0";
            arrItemsGrp2 [ 107 ]  = 18
            arrItems2 [ 108 ]  = "StaffR";
            arrItemsGrp2 [ 108 ]  = 18
            arrItems2 [ 109 ]  = "Staff2";
            arrItemsGrp2 [ 109 ]  = 18
            arrItems2 [ 110 ]  = "Grad Student";
            arrItemsGrp2 [ 110 ]  = 18
            arrItems2 [ 111 ]  = "Med Student";
            arrItemsGrp2 [ 111 ]  = 18
            arrItems2 [ 112 ]  = "Other BCM Student";
            arrItemsGrp2 [ 112 ]  = 18
            arrItems2 [ 113 ]  = "Non BCM Student";
            arrItemsGrp2 [ 113 ]  = 18
            arrItems2 [ 114 ]  = "Resident";
            arrItemsGrp2 [ 114 ]  = 18
            arrItems2 [ 115 ]  = "PDoc MD (Clincal)";
            arrItemsGrp2 [ 115 ]  = 18
            arrItems2 [ 116 ]  = "PDoc MD (Research)";
            arrItemsGrp2 [ 116 ]  = 18
            arrItems2 [ 117 ]  = "PDoc PhD (Research)";
            arrItemsGrp2 [ 117 ]  = 18
    
            //- Leave of Absence - Salaried PT Non-Exempt - 19 -//
            arrItems2 [ 118 ]  = "Staff0";
            arrItemsGrp2 [ 118 ]  = 19
            arrItems2 [ 119 ]  = "StaffR";
            arrItemsGrp2 [ 119 ]  = 19
    
            //- Leave of Absence - Hourly Part-Time - 20 -//
            arrItems2 [ 120 ]  = "Faculty0";
            arrItemsGrp2 [ 120 ]  = 20
            arrItems2 [ 121 ]  = "Staff0";
            arrItemsGrp2 [ 121 ]  = 20
            arrItems2 [ 122 ]  = "Med Student";
            arrItemsGrp2 [ 122 ]  = 20
            arrItems2 [ 123 ]  = "Other BCM Student";
            arrItemsGrp2 [ 123 ]  = 20
            arrItems2 [ 124 ]  = "Non BCM Student";
            arrItemsGrp2 [ 124 ]  = 20
    
            //- Leave of Absence - Non-Paid - 21 -//
            arrItems2 [ 125 ]  = "Other BCM Student";
            arrItemsGrp2 [ 125 ]  = 21
            arrItems2 [ 126 ]  = "Faculty0";
            arrItemsGrp2 [ 126 ]  = 21
    
            //- Indep. Contractor - Non-Paid - 22 -//
            arrItems2 [ 127 ]  = "Staff0";
            arrItemsGrp2 [ 127 ]  = 22
    
            //- Voluntary - Non-Paid - 23 -//
            arrItems2 [ 128 ]  = "Faculty0";
            arrItemsGrp2 [ 128 ]  = 23
            arrItems2 [ 129 ]  = "Staff0";
            arrItemsGrp2 [ 129 ]  = 23
    
            function selectChange(control, controlToPopulate, ItemArray, GroupArray)
            {
              var myEle ;
              var x ;
              // Empty the second drop down box of any choices
              for (var q=controlToPopulate.options.length;q>=0;q--) controlToPopulate.options [ q ] =null;
              if (control.name == "Group") {
                // Empty the third drop down box of any choices
                for (var q=add_ee_form.SubArea.options.length;q>=0;q--) add_ee_form.SubArea.options [ q ]  = null;
            }
              // ADD Default Choice - in case there are no values
              myEle = document.createElement("option") ;
              myEle.value = 0 ;
              myEle.text = "Select One" ;
              controlToPopulate.add(myEle) ;
              // Now loop through the array of individual items
              // Any containing the same child id are added to
              // the second dropdown box
              for ( x = 0 ; x < ItemArray.length  ; x++ )
                {
                  if ( GroupArray [ x ]  == control.value )
                    {
                      myEle = document.createElement("option") ;
                      myEle.value = x ;
                      myEle.text = ItemArray [ x ]  ;
                      controlToPopulate.add(myEle) ;
                    }
                }
            }
            //-->
        </script>
    </head>
    
    <div>
        <table border="0" cellpadding="0" cellspacing="0" align="center">
        <tr>
            <td valign="top"><a href="http://www.bcm.edu" target="_blank"><img name="menu_bar_1_r1_c2_trans" src="../images/menu_bar_1_r1_c2_trans.gif" width="80" height="80" border="0" alt=""></a></td>
            <cfset ThisLogoName = "../images/menu_bar_1_r1_c4_" & session.pbt_PREF_DEF_FY & ".gif">
            <cfoutput>
            <td valign="top"><img name="#ThisLogoName#" src="#ThisLogoName#" width="451" height="80" border="0" alt=""></td>
            </cfoutput>
        </tr>
    </table>
    <table border="0" cellpadding="0" cellspacing="0" align="center">
        <tr>
        <CFOUTPUT>
            <CFIF IsDefined("session.pbt_ORG_UNIT")>
                <td valign="top">
                    <FORM ACTION="Report_AF_Active.cfm?RequestTimeout=9999" METHOD="POST">
                        <a class="topnav" href="Report_AF_Active.cfm?RequestTimeout=9999" onsubmit="javascript:this.form.submit()">Home&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a>
                    </form>
                </td>
                <td valign="top">
                    <FORM ACTION="Main_Menu.cfm?RequestTimeout=9999" METHOD="POST">
                        <a class="topnav" href="Main_Menu.cfm?RequestTimeout=9999" onsubmit="javascript:this.form.submit()">Exp Summary&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a>
                    </form>
                </td>
                <td valign="top">
                    <FORM ACTION="Section_Emp_List.cfm?RequestTimeout=9999" METHOD="POST">
                        <a class="topnav" href="Section_Emp_List.cfm?RequestTimeout=9999" onsubmit="javascript:this.form.submit()">Employee List&nbsp;&nbsp;</a>
                    </form>
                </td>
                <td valign="top">
                    <FORM ACTION="Section_Emp_List_Detail.cfm?RequestTimeout=9999" METHOD="POST">
                        <input type="Hidden" name="ReportTitle" value="EMPLOYEE LIST">
                        <a class="topnav" href="Section_Emp_List_Detail.cfm?ReportTitle=EMPLOYEE LIST&RequestTimeout=9999" onsubmit="javascript:this.form.submit()">(Detail)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a>
                    </form>
                </td>
                <td valign="top">
                    <FORM ACTION="./Reports_Main.cfm" METHOD="POST">
                        <a class="topnav" href="./Reports_Main.cfm" onsubmit="javascript:this.form.submit()">Salary Reports&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a>
                    </form>
                </td>
                <td valign="top">
                    <FORM ACTION="Reports_AF.cfm" METHOD="POST">
                        <a class="topnav" href="Reports_AF.cfm" onsubmit="javascript:this.form.submit()">AF Reports&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a>
                    </form>
                </td>
                <td valign="top">
                    <a class="topnav" href="../media/users_guide.pdf" target="_blank">Survival Guide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a>
                </td>
                <td valign="top">
                    <FORM ACTION="Logout.cfm" METHOD="POST">
                        <a class="topnav" href="../logout.cfm" onsubmit="javascript:this.form.submit()">Logout</a>
                    </form>
                </td>
            </CFIF>
        </CFOUTPUT>
      </tr>
      <cfif session.pbt_PREF_DEF_FY EQ THIS.FY>
      <tr>
        <td colspan="6" align="center">
            <!--- <h2><a href="http://intranet.bcm.tmc.edu/?tmp=/finance/budget/index" target="_blank">Fiscal Year 2014 Operating and Capital Budget (BCM)</a></h2> --->
            <cfif session.pbt_archiver>
                <h1 class="ERROR_RED">ARCHIVED (SUBMITTED) VERSION - REPORTING ONLY - NO CHANGES</h1>
            </cfif>
        </td>
      </tr>
      </cfif>
    </table>
</cfif>
<br />

