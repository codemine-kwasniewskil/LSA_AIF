FUNCTION /THKR/AIF_VMAP_IST_XML_FNAME .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(VALUE_IN) TYPE  STRING
*"     REFERENCE(VALUE_IN2) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN3) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN4) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN5) TYPE  STRING OPTIONAL
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"     REFERENCE(VALUE_FOUND) TYPE  C OPTIONAL
*"     REFERENCE(RAW_LINE)
*"     REFERENCE(RAW_STRUCT)
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------
  FIELD-SYMBOLS: <lt_rueck> TYPE STANDARD TABLE.

  clear value_out.

  ASSIGN COMPONENT 'T_RUECK' of STRUCTURE raw_struct to <lt_rueck>.
  if sy-subrc = 0.
    READ TABLE <lt_rueck> INDEX 1 ASSIGNING FIELD-SYMBOL(<ls_rueck>).
    if sy-subrc = 0.
      ASSIGN COMPONENT 'FISTL' of STRUCTURE <ls_rueck> to FIELD-SYMBOL(<lv_fistl>).
      ASSIGN COMPONENT 'FIPEX' of STRUCTURE <ls_rueck> to FIELD-SYMBOL(<lv_fipex>).
      if <lv_fistl> is ASSIGNED and <lv_fipex> is ASSIGNED.
        value_out = 'BI' && <lv_fipex>(2) && '_' && sy-datum && |{ VALUE_in CASE = LOWER }| && '.' && <lv_fistl>(4) && '.xml'.
      endif.
    endif.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
