FUNCTION /thkr/aif_zallge_chk_gp_pso02 .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(DATA_STRUCT) TYPE  /THKR/S_DE_PSO_XML_FILE
*"     REFERENCE(DATA_LINE) TYPE  /THKR/S_DE_PSO_FMBSEC
*"     REFERENCE(DATA_FIELD)
*"     REFERENCE(MSGTY) TYPE  SYMSGTY DEFAULT 'E'
*"     REFERENCE(VALUE1) TYPE  STRING
*"     REFERENCE(VALUE2) TYPE  STRING
*"     REFERENCE(VALUE3) TYPE  STRING
*"     REFERENCE(VALUE4) TYPE  STRING
*"     REFERENCE(VALUE5) TYPE  STRING
*"     REFERENCE(T_IFCHECK) TYPE  /AIF/T_IFCHECK OPTIONAL
*"     REFERENCE(T_IFACT) TYPE  /AIF/T_IFACT OPTIONAL
*"     REFERENCE(T_ACCHECK) TYPE  /AIF/T_ACCHECK OPTIONAL
*"     REFERENCE(T_FUNC) TYPE  /AIF/T_FUNC OPTIONAL
*"     REFERENCE(T_FMAPCOND) TYPE  /AIF/T_FMAPCOND OPTIONAL
*"     REFERENCE(T_CHECK) TYPE  /AIF/T_CHECK
*"     REFERENCE(T_TABCHK) TYPE  /AIF/T_TABCHK
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"      DATA_TABLE
*"  CHANGING
*"     REFERENCE(ERROR) TYPE  CHAR01
*"----------------------------------------------------------------------
  "Value1 = BELNR

  TRY.
      IF data_struct-values-items[ key-belnr = data_line-bsec-belnr key-gjahr = data_line-bsec-gjahr ]-lt_pso02 IS INITIAL.
        error = abap_true.
      ELSE.
        error = abap_false.
      ENDIF.
    CATCH cx_sy_itab_line_not_found.
      error = abap_true.
  ENDTRY.

ENDFUNCTION.
