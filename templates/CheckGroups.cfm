<cfif IsDefined("FORM.Emp_Group")>
	<cfset Variables.Emp_Group = FORM.Emp_Group>
<cfelse>
	<cfset Variables.Emp_Group = FORM.Group>
</cfif>

<cfif IsDefined("FORM.EMP_SUBGROUP")>
	<cfset Variables.EMP_SUBGROUP = FORM.EMP_SUBGROUP>
<cfelse>
	<cfset Variables.EMP_SUBGROUP = FORM.SubGroup>
</cfif>

<cfif IsDefined("FORM.PERS_SUBAREA")>
	<cfset Variables.PERS_SUBAREA = FORM.PERS_SUBAREA>
<cfelse>
	<cfset Variables.PERS_SUBAREA = FORM.SubArea>
</cfif>

		<!-- group-EMP_SUBGROUP-subarea assignment -->
		<CFSWITCH expression="#Variables.EMP_SUBGROUP#">
			<CFCASE value="3"><CFSET Variables.EMP_SUBGROUP = "U1"></CFCASE>
			<CFCASE value="9"><CFSET Variables.EMP_SUBGROUP = "U1"></CFCASE>
			<CFCASE value="16"><CFSET Variables.EMP_SUBGROUP = "U1"></CFCASE>
			
			<CFCASE value="4"><CFSET Variables.EMP_SUBGROUP = "U2"></CFCASE>
			<CFCASE value="10"><CFSET Variables.EMP_SUBGROUP = "U2"></CFCASE>
			<CFCASE value="17"><CFSET Variables.EMP_SUBGROUP = "U2"></CFCASE>
			
			<CFCASE value="5"><CFSET Variables.EMP_SUBGROUP = "U3"></CFCASE>
			<CFCASE value="11"><CFSET Variables.EMP_SUBGROUP = "U3"></CFCASE>
			<CFCASE value="18"><CFSET Variables.EMP_SUBGROUP = "U3"></CFCASE>
			
			<CFCASE value="6"><CFSET Variables.EMP_SUBGROUP = "U4"></CFCASE>
			<CFCASE value="12"><CFSET Variables.EMP_SUBGROUP = "U4"></CFCASE>
			<CFCASE value="19"><CFSET Variables.EMP_SUBGROUP = "U4"></CFCASE>
			
			<CFCASE value="13"><CFSET Variables.EMP_SUBGROUP = "U5"></CFCASE>
			
			<CFCASE value="7"><CFSET Variables.EMP_SUBGROUP = "U6"></CFCASE>
			<CFCASE value="14"><CFSET Variables.EMP_SUBGROUP = "U6"></CFCASE>
			<CFCASE value="20"><CFSET Variables.EMP_SUBGROUP = "U6"></CFCASE>
			
			<CFCASE value="8"><CFSET Variables.EMP_SUBGROUP = "U7"></CFCASE>
			<CFCASE value="15"><CFSET Variables.EMP_SUBGROUP = "U7"></CFCASE>
			<CFCASE value="21"><CFSET Variables.EMP_SUBGROUP = "U7"></CFCASE>
			<CFCASE value="22"><CFSET Variables.EMP_SUBGROUP = "U7"></CFCASE>
			<CFCASE value="23"><CFSET Variables.EMP_SUBGROUP = "U7"></CFCASE>
		</CFSWITCH>
		
		<!--- Employee Personal SubArea --->
		<CFSWITCH expression="#Variables.PERS_SUBAREA#">
			<CFCASE value="24"><CFSET Variables.PERS_SUBAREA = "0001"></CFCASE>
			<CFCASE value="38"><CFSET Variables.PERS_SUBAREA = "0001"></CFCASE>
			<CFCASE value="53"><CFSET Variables.PERS_SUBAREA = "0001"></CFCASE>
			<CFCASE value="58"><CFSET Variables.PERS_SUBAREA = "0001"></CFCASE>
			<CFCASE value="68"><CFSET Variables.PERS_SUBAREA = "0001"></CFCASE>
			<CFCASE value="71"><CFSET Variables.PERS_SUBAREA = "0001"></CFCASE>
			<CFCASE value="77"><CFSET Variables.PERS_SUBAREA = "0001"></CFCASE>
			<CFCASE value="80"><CFSET Variables.PERS_SUBAREA = "0001"></CFCASE>
			<CFCASE value="85"><CFSET Variables.PERS_SUBAREA = "0001"></CFCASE>
			<CFCASE value="91"><CFSET Variables.PERS_SUBAREA = "0001"></CFCASE>
			<CFCASE value="105"><CFSET Variables.PERS_SUBAREA = "0001"></CFCASE>
			<CFCASE value="120"><CFSET Variables.PERS_SUBAREA = "0001"></CFCASE>
			<CFCASE value="126"><CFSET Variables.PERS_SUBAREA = "0001"></CFCASE>
			<CFCASE value="128"><CFSET Variables.PERS_SUBAREA = "0001"></CFCASE>
			
			<CFCASE value="25"><CFSET Variables.PERS_SUBAREA = "0002"></CFCASE>
			<CFCASE value="92"><CFSET Variables.PERS_SUBAREA = "0002"></CFCASE>
			
			<CFCASE value="26"><CFSET Variables.PERS_SUBAREA = "0003"></CFCASE>
			<CFCASE value="39"><CFSET Variables.PERS_SUBAREA = "0003"></CFCASE>
			<CFCASE value="93"><CFSET Variables.PERS_SUBAREA = "0003"></CFCASE>
			<CFCASE value="106"><CFSET Variables.PERS_SUBAREA = "0003"></CFCASE>
			
			<CFCASE value="27"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="36"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="40"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="51"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="54"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="59"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="69"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="70"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="72"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="76"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="78"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="81"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="86"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="94"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="103"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="107"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="118"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="121"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="127"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			<CFCASE value="129"><CFSET Variables.PERS_SUBAREA = "0004"></CFCASE>
			
			<CFCASE value="28"><CFSET Variables.PERS_SUBAREA = "0005"></CFCASE>
			<CFCASE value="37"><CFSET Variables.PERS_SUBAREA = "0005"></CFCASE>
			<CFCASE value="41"><CFSET Variables.PERS_SUBAREA = "0005"></CFCASE>
			<CFCASE value="52"><CFSET Variables.PERS_SUBAREA = "0005"></CFCASE>
			<CFCASE value="95"><CFSET Variables.PERS_SUBAREA = "0005"></CFCASE>
			<CFCASE value="104"><CFSET Variables.PERS_SUBAREA = "0005"></CFCASE>
			<CFCASE value="108"><CFSET Variables.PERS_SUBAREA = "0005"></CFCASE>
			<CFCASE value="119"><CFSET Variables.PERS_SUBAREA = "0005"></CFCASE>
			
			<CFCASE value="29"><CFSET Variables.PERS_SUBAREA = "0006"></CFCASE>
			<CFCASE value="96"><CFSET Variables.PERS_SUBAREA = "0006"></CFCASE>
				
			<CFCASE value="30"><CFSET Variables.PERS_SUBAREA = "0007"></CFCASE>
			<CFCASE value="42"><CFSET Variables.PERS_SUBAREA = "0007"></CFCASE>
			<CFCASE value="97"><CFSET Variables.PERS_SUBAREA = "0007"></CFCASE>
			<CFCASE value="109"><CFSET Variables.PERS_SUBAREA = "0007"></CFCASE>
			
			<CFCASE value="43"><CFSET Variables.PERS_SUBAREA = "0008"></CFCASE>
			<CFCASE value="60"><CFSET Variables.PERS_SUBAREA = "0008"></CFCASE>
			<CFCASE value="73"><CFSET Variables.PERS_SUBAREA = "0008"></CFCASE>
			<CFCASE value="87"><CFSET Variables.PERS_SUBAREA = "0008"></CFCASE>
			<CFCASE value="110"><CFSET Variables.PERS_SUBAREA = "0008"></CFCASE>
			
			<CFCASE value="44"><CFSET Variables.PERS_SUBAREA = "0009"></CFCASE>
			<CFCASE value="55"><CFSET Variables.PERS_SUBAREA = "0009"></CFCASE>
			<CFCASE value="61"><CFSET Variables.PERS_SUBAREA = "0009"></CFCASE>
			<CFCASE value="82"><CFSET Variables.PERS_SUBAREA = "0009"></CFCASE>
			<CFCASE value="88"><CFSET Variables.PERS_SUBAREA = "0009"></CFCASE>
			<CFCASE value="111"><CFSET Variables.PERS_SUBAREA = "0009"></CFCASE>
			<CFCASE value="122"><CFSET Variables.PERS_SUBAREA = "0009"></CFCASE>
			
			<CFCASE value="31"><CFSET Variables.PERS_SUBAREA = "0010"></CFCASE>
			<CFCASE value="45"><CFSET Variables.PERS_SUBAREA = "0010"></CFCASE>
			<CFCASE value="56"><CFSET Variables.PERS_SUBAREA = "0010"></CFCASE>
			<CFCASE value="62"><CFSET Variables.PERS_SUBAREA = "0010"></CFCASE>
			<CFCASE value="75"><CFSET Variables.PERS_SUBAREA = "0010"></CFCASE>
			<CFCASE value="83"><CFSET Variables.PERS_SUBAREA = "0010"></CFCASE>
			<CFCASE value="89"><CFSET Variables.PERS_SUBAREA = "0010"></CFCASE>
			<CFCASE value="98"><CFSET Variables.PERS_SUBAREA = "0010"></CFCASE>
			<CFCASE value="112"><CFSET Variables.PERS_SUBAREA = "0010"></CFCASE>
			<CFCASE value="123"><CFSET Variables.PERS_SUBAREA = "0010"></CFCASE>
			<CFCASE value="125"><CFSET Variables.PERS_SUBAREA = "0010"></CFCASE>
			
			<CFCASE value="46"><CFSET Variables.PERS_SUBAREA = "0011"></CFCASE>
			<CFCASE value="57"><CFSET Variables.PERS_SUBAREA = "0011"></CFCASE>
			<CFCASE value="63"><CFSET Variables.PERS_SUBAREA = "0011"></CFCASE>
			<CFCASE value="79"><CFSET Variables.PERS_SUBAREA = "0011"></CFCASE>
			<CFCASE value="84"><CFSET Variables.PERS_SUBAREA = "0011"></CFCASE>
			<CFCASE value="90"><CFSET Variables.PERS_SUBAREA = "0011"></CFCASE>
			<CFCASE value="113"><CFSET Variables.PERS_SUBAREA = "0011"></CFCASE>
			<CFCASE value="124"><CFSET Variables.PERS_SUBAREA = "0011"></CFCASE>
			
			<CFCASE value="32"><CFSET Variables.PERS_SUBAREA = "0012"></CFCASE>
			<CFCASE value="47"><CFSET Variables.PERS_SUBAREA = "0012"></CFCASE>
			<CFCASE value="64"><CFSET Variables.PERS_SUBAREA = "0012"></CFCASE>
			<CFCASE value="99"><CFSET Variables.PERS_SUBAREA = "0012"></CFCASE>
			<CFCASE value="114"><CFSET Variables.PERS_SUBAREA = "0012"></CFCASE>
			
			<CFCASE value="33"><CFSET Variables.PERS_SUBAREA = "0013"></CFCASE>
			<CFCASE value="48"><CFSET Variables.PERS_SUBAREA = "0013"></CFCASE>
			<CFCASE value="65"><CFSET Variables.PERS_SUBAREA = "0013"></CFCASE>
			<CFCASE value="100"><CFSET Variables.PERS_SUBAREA = "0013"></CFCASE>
			<CFCASE value="115"><CFSET Variables.PERS_SUBAREA = "0013"></CFCASE>
			
			<CFCASE value="34"><CFSET Variables.PERS_SUBAREA = "0014"></CFCASE>
			<CFCASE value="49"><CFSET Variables.PERS_SUBAREA = "0014"></CFCASE>
			<CFCASE value="66"><CFSET Variables.PERS_SUBAREA = "0014"></CFCASE>
			<CFCASE value="101"><CFSET Variables.PERS_SUBAREA = "0014"></CFCASE>
			<CFCASE value="116"><CFSET Variables.PERS_SUBAREA = "0014"></CFCASE>
			
			<CFCASE value="35"><CFSET Variables.PERS_SUBAREA = "0015"></CFCASE>
			<CFCASE value="50"><CFSET Variables.PERS_SUBAREA = "0015"></CFCASE>
			<CFCASE value="67"><CFSET Variables.PERS_SUBAREA = "0015"></CFCASE>
			<CFCASE value="102"><CFSET Variables.PERS_SUBAREA = "0015"></CFCASE>
			<CFCASE value="117"><CFSET Variables.PERS_SUBAREA = "0015"></CFCASE>
		</CFSWITCH>
		<!-- end -->
