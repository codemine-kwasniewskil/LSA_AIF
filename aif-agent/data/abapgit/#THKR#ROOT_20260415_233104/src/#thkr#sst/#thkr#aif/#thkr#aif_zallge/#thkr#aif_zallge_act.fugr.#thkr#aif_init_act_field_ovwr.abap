FUNCTION /THKR/AIF_INIT_ACT_FIELD_OVWR .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(CONTEXT) TYPE  STRING OPTIONAL
*"     REFERENCE(FINF) TYPE  /AIF/T_FINF
*"     REFERENCE(ACTION) TYPE  /AIF/IFACTION OPTIONAL
*"     REFERENCE(TESTRUN) TYPE  /AIF/IFTESTRUN OPTIONAL
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) OPTIONAL
*"  EXCEPTIONS
*"      CANCEL
*"----------------------------------------------------------------------

 DATA: lo_field_ovwr  TYPE REF TO /thkr/cl_init_action_field_ovw.

 lo_field_ovwr = new /thkr/cl_init_action_field_ovw( ).

 lo_field_ovwr->overwrite_fields(
   CHANGING
     cs_data = data
     ct_return = return_tab[]
 ).

ENDFUNCTION.
