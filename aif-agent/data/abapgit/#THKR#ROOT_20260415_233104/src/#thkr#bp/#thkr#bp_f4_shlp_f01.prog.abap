*&---------------------------------------------------------------------*
*& Include          /THKR/BP_F4_SHLP_F01
*&---------------------------------------------------------------------*
"Auslesen Tabelle /THKR/CBPF4STDEX
FORM get_stdexit_names.

  SELECT * FROM /thkr/cbpf4stdex INTO TABLE @std_exits.

ENDFORM.
