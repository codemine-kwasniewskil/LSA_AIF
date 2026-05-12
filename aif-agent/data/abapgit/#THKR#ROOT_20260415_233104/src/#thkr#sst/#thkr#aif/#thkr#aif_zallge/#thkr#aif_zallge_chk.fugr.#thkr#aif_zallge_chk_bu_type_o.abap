FUNCTION /THKR/AIF_ZALLGE_CHK_BU_TYPE_O .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(DATA_STRUCT)
*"     REFERENCE(DATA_LINE)
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

  "Set error as default
    "Set error as default
  error = abap_true.

  DATA(lv_name) = value1 && value2.

  "Get name indicators for organisations.
  SELECT FIELDVALUE
    FROM /AIF/T_TFIX
   WHERE ns = @value3
     AND fixvaluename = @value4
  into TABLE @DATA(lt_org).

  if sy-subrc = 0.
    Loop at lt_org ASSIGNING FIELD-SYMBOL(<ls_org>).
      if lv_name CS <ls_org>.
        "Part of company indicator found in name
        "Leave loop
        "Set BU_TYPE to 2 in condition or field mapping
        error = abap_false.
        exit.
      else.
        error = abap_true.
      endif.
    ENDLOOP.
  else.
    error = abap_true.
  endif.
ENDFUNCTION.
