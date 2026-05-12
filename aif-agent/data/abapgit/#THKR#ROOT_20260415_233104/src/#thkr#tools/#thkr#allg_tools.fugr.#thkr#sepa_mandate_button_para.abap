FUNCTION /thkr/sepa_mandate_button_para .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_BUTTON_ID) TYPE  SEPA_PARAM_ID
*"     REFERENCE(I_PROGNAME) TYPE  PROGNAME
*"     REFERENCE(I_DYNNR) TYPE  SYDYNNR
*"  EXPORTING
*"     REFERENCE(ES_BUTTON_PARAMS) TYPE  SMP_DYNTXT
*"     REFERENCE(E_BUTTON_FNAME) TYPE  FUNCNAME
*"     REFERENCE(EX_BUTTON_HIDE) TYPE  BOOLEAN
*"--------------------------------------------------------------------

  DATA lv_op_system  TYPE abap_bool VALUE abap_undefined.

*For On Promise, do not need OM button.
  TEST-SEAM fetch_system_environment.
    lv_op_system = cl_fap_opr_utilities=>is_simplified_suite( ).
  END-TEST-SEAM.

  CHECK lv_op_system = abap_true.

* Example of setup of the adjustable buttons and of the print button
  CLEAR: es_button_params, e_button_fname, ex_button_hide.

* Print program
  IF i_button_id = 'PRI'.
    MESSAGE 'Bitte SEPA-Vordruck ORIGINAL verwenden!' TYPE 'I'.
*    e_button_fname  = 'FFO_SEPA_MANDATE_PRINT'.
  ENDIF.

* Display OM Print Preview
  IF i_button_id = 'CUST1'.
    es_button_params-text      = 'Output Overview'(001).
    es_button_params-icon_text = 'Output Overview'(001).
    es_button_params-icon_id   = '@3G@'.
    es_button_params-quickinfo = 'Output Overview'(001).
    e_button_fname             = 'FFO_SEPA_MANDATE_OM_PREVIEW'.
  ENDIF.

ENDFUNCTION.
