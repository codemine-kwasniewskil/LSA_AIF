FUNCTION /thkr/aif_zallge_chk_belnr_sto .
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
  "VALUE1 = SAP Belegnummer
  "VALUE2 = Kassenzeichen aus Fremdverfahren

  "Funktionsbaustein notwendig, um Meldung ins AIF-Log zu schreiben.
  FIELD-SYMBOLS: <ls_curr> TYPE /thkr/s_aif_sap_storno.
  FIELD-SYMBOLS: <lt_tab> TYPE /thkr/t_dto_psm_storno.
  FIELD-SYMBOLS: <lt_data> TYPE /thkr/t_dto_psm_storno.

  ASSIGN data_line TO <ls_curr>.
  ASSIGN data_table TO <lt_data>.

  READ TABLE <lt_data> with key glblid = <ls_curr>-glblid ASSIGNING FIELD-SYMBOL(<ls_storno>).
  IF sy-subrc = 0.
    IF value1 IS INITIAL.
      "Keine Belegnummer anhand des Kassenzeichen gefunden.
      IF 1 = 0. MESSAGE e016(/thkr/sst) WITH value2.ENDIF.

      LOOP AT <lt_data> ASSIGNING FIELD-SYMBOL(<ls_line>) WHERE belnr IS INITIAL
                                                           AND proc_status IS INITIAL.
        <ls_line>-proc_status = 'E'.
      ENDLOOP.

      APPEND VALUE bapiret2( type = 'E'
                             id = '/THKR/SST'
                             number = 016
                             message_v1 = value2 ) TO return_tab[].
      APPEND VALUE bapiret2( type = 'E'
                             id = '/THKR/SST'
                             number = 016
                             message_v1 = value2 ) TO <ls_storno>-msg.
      IF value2 IS INITIAL.
        "kein Kassenzeichen vom Fremdverfahren erhalten
        IF 1 = 0. MESSAGE e019(/thkr/sst).ENDIF.
        APPEND VALUE bapiret2( type = 'E'
                               id = '/THKR/SST'
                               number = 019 ) TO return_tab[].
        APPEND VALUE bapiret2( type = 'E'
                              id = '/THKR/SST'
                              number = 019 ) TO <ls_storno>-msg.
      ENDIF.
      error = abap_true.
    ELSE.
      error = abap_false.
    ENDIF.
  ELSE.
    error = abap_true.
  ENDIF.
ENDFUNCTION.
