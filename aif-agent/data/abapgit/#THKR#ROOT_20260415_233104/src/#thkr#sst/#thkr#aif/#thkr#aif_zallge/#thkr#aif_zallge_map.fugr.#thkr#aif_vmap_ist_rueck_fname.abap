FUNCTION /thkr/aif_vmap_ist_rueck_fname .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
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
  FIELD-SYMBOLS: <lt_rueck>   TYPE STANDARD TABLE,
                 <raw_struct> TYPE /thkr/s_aif_file_rueck.

  CLEAR value_out.

  ASSIGN COMPONENT 'T_RUECK' OF STRUCTURE raw_struct TO <lt_rueck>.
  ASSIGN raw_struct TO <raw_struct>.

  IF sy-subrc = 0.
    READ TABLE <lt_rueck> INDEX 1 ASSIGNING FIELD-SYMBOL(<ls_rueck>).
    IF sy-subrc = 0.
      ASSIGN COMPONENT 'FISTL' OF STRUCTURE <ls_rueck> TO FIELD-SYMBOL(<lv_fistl>).
      ASSIGN COMPONENT 'FIPEX' OF STRUCTURE <ls_rueck> TO FIELD-SYMBOL(<lv_fipex>).
      IF <lv_fistl> IS ASSIGNED AND <lv_fipex> IS ASSIGNED.
        IF <raw_struct>-sst = 'EDOA'.
          value_out = 'ZAHL_EIN_' && sy-datum+2 && '.ASC'.
        ELSE.
          value_out = 'BI' && <lv_fipex>(2) && '_' && sy-datum && |{ VALUE_in CASE = LOWER }| && '.' && <lv_fistl>(4) && '.txt'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
