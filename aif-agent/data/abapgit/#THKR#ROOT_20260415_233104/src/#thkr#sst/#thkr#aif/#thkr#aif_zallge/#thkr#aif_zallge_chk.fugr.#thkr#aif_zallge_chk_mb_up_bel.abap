FUNCTION /thkr/aif_zallge_chk_mb_up_bel .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(DATA_STRUCT) TYPE  /THKR/S_AIF_SAP
*"     REFERENCE(DATA_LINE) TYPE  /THKR/S_AIF_SAP_MV_UP
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
*"      DATA_TABLE TYPE  /THKR/T_DTO_PSM_MV_UP_CREATE
*"  CHANGING
*"     REFERENCE(ERROR) TYPE  CHAR01
*"----------------------------------------------------------------------
  "Prüfung, ob Belegnummer leer ist.
  "Wenn ja, Meldung erzeugen.


  error = COND flag( WHEN data_line-belnr IS INITIAL THEN abap_true
                     ELSE abap_false ).
  IF error = abap_true.
    IF 1 = 0. MESSAGE e041(/thkr/sst).ENDIF.
    READ TABLE data_table ASSIGNING FIELD-SYMBOL(<ls_data>) WITH KEY glblid = data_line-glblid.
    IF sy-subrc = 0.
      APPEND VALUE bapiret2( id = '/THKR/SST'
                              type = 'E'
                              number = 041 ) TO <ls_data>-msg.
      APPEND VALUE bapiret2( id = '/THKR/SST'
                              type = 'E'
                              number = 041 ) TO return_tab.
    ENDIF.
  ENDIF.
ENDFUNCTION.
