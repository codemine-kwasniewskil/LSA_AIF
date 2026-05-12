FUNCTION /thkr/aif_ifdef_init_functions .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(CONTEXT) TYPE  STRING OPTIONAL
*"     REFERENCE(FINF) TYPE  /AIF/T_FINF
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"         OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) OPTIONAL
*"     REFERENCE(RAW_STRUCT) OPTIONAL
*"  EXCEPTIONS
*"      CANCEL
*"--------------------------------------------------------------------

  DATA: lo_ifdef  TYPE REF TO /thkr/cl_ifdef_functions.

  lo_ifdef = NEW /thkr/cl_ifdef_functions( ).

  lo_ifdef->anonymisation(
    EXPORTING
      is_finf      = finf                 " Schnittstellendefintion
    CHANGING
      cs_raw_struc = raw_struct
  ).

ENDFUNCTION.
