*&---------------------------------------------------------------------*
*& Report /THKR/AIF_TOOL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/aif_tool LINE-SIZE 255.
*&---------------------------------------------------------------------*
TABLES: /aif/t_fmap.
*&---------------------------------------------------------------------*
DATA: l_/aif/t_fmap TYPE /aif/t_fmap.

PARAMETERS: p_ns     TYPE /aif/ns.
SELECT-OPTIONS s_ifname FOR /aif/t_fmap-ifname.
PARAMETERS: p_field    TYPE /aif/sapfieldname.
PARAMETERS: ak_test AS CHECKBOX.
*&---------------------------------------------------------------------*
SELECT * FROM /aif/t_fmap INTO l_/aif/t_fmap
  WHERE ns     = p_ns
    AND ifname IN s_ifname
    AND fieldname = p_field
  ORDER BY ifname.

  WRITE: /1 l_/aif/t_fmap-ns,
            l_/aif/t_fmap-ifname,
            l_/aif/t_fmap-ifversion,
            l_/aif/t_fmap-rectype(20),
            l_/aif/t_fmap-smapnr,
            l_/aif/t_fmap-fieldname(20),
            l_/aif/t_fmap-sap_fieldname1(20),
            l_/aif/t_fmap-sap_fieldname2(20),
            l_/aif/t_fmap-sap_fieldname3(20),
            l_/aif/t_fmap-sap_fieldname4(20).
ENDSELECT.
*&---------------------------------------------------------------------*
