FUNCTION /thkr/aif_zallge_chk_wrbtr .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(DATA_STRUCT) TYPE  /THKR/S_AIF_SAP
*"     REFERENCE(DATA_LINE) TYPE  /THKR/S_AIF_SAP_AO
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
*"      DATA_TABLE TYPE  /THKR/T_DTO_PSM_AO_BEL_CREATE
*"  CHANGING
*"     REFERENCE(ERROR) TYPE  CHAR01
*"----------------------------------------------------------------------
  "Prüfung, ob der Betrag initial ist
  LOOP AT data_line-t_kont TRANSPORTING NO FIELDS WHERE wrbtr IS INITIAL.
    "Es gibt Beträge mit 0.
    "SAP meldet solche Belege als erfolgreich zurück. Es zieht auch Nummern für AO und FI-Beleg.
    "Allerdings wird die Anordnung trotz Erfolgsmeldung nicht angelegt. Es kommt zu Folgefehlern
    error = abap_true.
    LOOP AT data_table ASSIGNING FIELD-SYMBOL(<ls_line>) WHERE glblid = data_line-glblid.
      IF 1 = 0. MESSAGE e045(/thkr/sst).ENDIF.
      APPEND VALUE bapiret2( id = '/THKR/SST'
                             number = 45
                             type = 'E' ) TO <ls_line>-msg.
      APPEND LINES OF <ls_line>-msg TO return_tab[].
    ENDLOOP.
  ENDLOOP.

  IF sy-subrc <> 0.
    "Kein Betrag mit 0.
    "Kein Fehler
    error = abap_false.
  ENDIF.
ENDFUNCTION.
