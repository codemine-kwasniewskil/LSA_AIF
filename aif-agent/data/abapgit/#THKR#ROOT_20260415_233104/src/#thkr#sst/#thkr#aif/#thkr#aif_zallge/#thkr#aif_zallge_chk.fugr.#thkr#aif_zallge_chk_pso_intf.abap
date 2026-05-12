FUNCTION /THKR/AIF_ZALLGE_CHK_PSO_INTF .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_DE_PSO_XML_FILE
*"     REFERENCE(RETURN_TAB_MAPPING) TYPE  BAPIRETTAB
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  EXPORTING
*"     REFERENCE(CLEAR_ERROR_MESSAGES) TYPE  BOOLEAN
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(OUT_STRUCT)
*"----------------------------------------------------------------------
*"----------------------------------------------------------------------
  "Prüfung Zeitstempel:
  DATA: lo_init_check TYPE REF TO /thkr/cl_if_initial_check.

 /thkr/cl_pso_xml_processing=>get_instance( )->check_file_order(
   EXPORTING
     iv_tstmp  =  raw_struct-values-tstmp                " Nicht näher def. Bereich, evtl. für Patchlevels verwendbar
   CHANGING
     ct_return = RETURN_TAB[]
 ).

ENDFUNCTION.
