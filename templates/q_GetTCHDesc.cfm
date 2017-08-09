                                                             <CFQUERY NAME="q_Lookup_TCH_Desc_Dist" datasource="#THIS.DSN#">
                                                                  SELECT
                                                                      TCH_DESCRIPTION
                                                                  FROM
                                                                      PEDI_PBT_DISTRIBUTION
                                                                  WHERE
                                                                      TCH_FC_ID = '#Variables.TCH_FC_ID#'
                                                                  AND
                                                                      FY = '#session.pbt_PREF_DEF_FY#'
                                                                  GROUP BY
                                                                      TCH_DESCRIPTION
                                                                  ORDER BY
                                                                      TCH_DESCRIPTION
                                                              </CFQUERY>
                                                             <CFQUERY NAME="q_Lookup_TCH_Desc_Supp" datasource="#THIS.DSN#">
                                                                  SELECT
                                                                      TCH_DESCRIPTION
                                                                  FROM
                                                                      PEDI_PBT_SUPP_PAY
                                                                  WHERE
                                                                      TCH_FC_ID = '#Variables.TCH_FC_ID#'
                                                                  AND
                                                                      FY = '#session.pbt_PREF_DEF_FY#'
                                                                  GROUP BY
                                                                      TCH_DESCRIPTION
                                                                  ORDER BY
                                                                      TCH_DESCRIPTION
                                                              </CFQUERY>
                                                             <CFQUERY NAME="q_Lookup_TCH_Desc_NonPed" datasource="#THIS.DSN#">
                                                                  SELECT
                                                                      TCH_DESCRIPTION
                                                                  FROM
                                                                      PEDI_PBT_BPC_NONPEDS
                                                                  WHERE
                                                                      TCH_FC_ID = '#Variables.TCH_FC_ID#'
                                                                  AND
                                                                      FY = '#session.pbt_PREF_DEF_FY#'
                                                                  GROUP BY
                                                                      TCH_DESCRIPTION
                                                                  ORDER BY
                                                                      TCH_DESCRIPTION
                                                              </CFQUERY>
                                                              <cfquery name="q_query1" dbtype="query">
                                                                  SELECT
                                                                      TCH_DESCRIPTION
                                                                  FROM
                                                                      q_Lookup_TCH_Desc_Dist
                                                                  UNION
                                                                  SELECT
                                                                      TCH_DESCRIPTION
                                                                  FROM
                                                                      q_Lookup_TCH_Desc_Supp
                                                              </CFQUERY>
                                                              <cfquery name="q_Lookup_TCH_Desc" dbtype="query">
                                                                  SELECT
                                                                      TCH_DESCRIPTION
                                                                  FROM
                                                                      q_query1
                                                                  UNION
                                                                  SELECT
                                                                      TCH_DESCRIPTION
                                                                  FROM
                                                                      q_Lookup_TCH_Desc_NonPed
                                                                  ORDER BY
                                                                  		TCH_DESCRIPTION
                                                              </CFQUERY>
