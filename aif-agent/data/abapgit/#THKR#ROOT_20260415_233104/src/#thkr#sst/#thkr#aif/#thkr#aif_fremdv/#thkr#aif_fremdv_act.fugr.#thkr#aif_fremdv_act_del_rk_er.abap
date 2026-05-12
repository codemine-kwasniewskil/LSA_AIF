FUNCTION /thkr/aif_fremdv_act_del_rk_er .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA)
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_AIF_BIC_ZEILE
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------

  "Lese Anordnungsstatus aus Datenverarbeitung aus
  "Wenn erfolgreich (AO_STATUS = S), dann übergebe Datensatz an Polizei
  "Wenn fehlerhaft, dann Leere Datenzeile
  "Ein Löschen des Datensatzes aus data-rko_polizei-line geht nicht,
  "Weil AIF Zeilenweise verarbeitet und am Ende mit einem
  "Feldsymbol nicht zugewiesen Fehler abbricht.
  DATA: ls_error_line TYPE /thkr/t_rko_err.
  DATA: lo_struc TYPE REF TO cl_abap_structdescr.
*"----------------------------------------------------------------------
  APPEND VALUE #( id         = 'KM'
                   number     = 418
                   type       = 'I'
                   message_v1 = '/THKR/AIF_FREMDV_ACT_DEL_RK_ER' ) TO return_tab.
*"----------------------------------------------------------------------
* Check if Actions are allowed.
  CALL FUNCTION '/THKR/AIF_ZALLGE_ACT_OFF'
    TABLES
      return_tab = return_tab
    EXCEPTIONS
      off        = 1
      OTHERS     = 2.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.
*"----------------------------------------------------------------------
  "Erstmal prüfen, ob es einen Fehlerhaften Datensatz gab.
  SELECT SINGLE *
    FROM /thkr/t_rko_err
   WHERE btyp = @curr_line-01_btyp
   AND merkm = @curr_line-02_merkm
   AND firma = @curr_line-03_firma
   AND hhj = @curr_line-04_hhj
   AND quelle = @curr_line-05_quelle
   AND qbelnr = @curr_line-06_qbelnr
  INTO @DATA(ls_rko_err).
  IF sy-subrc = 0.
    "Es gab einen, dann Löschen.
    DELETE /thkr/t_rko_err from ls_rko_err.
    IF sy-subrc = 0.
      IF 1 = 0. MESSAGE e042(/thkr/sst) WITH '/THKR/T_RKO_ERR' curr_line-01_btyp curr_line-05_quelle curr_line-06_qbelnr.ENDIF.
      APPEND VALUE bapiret2( id         = '/THKR/SST'
                    number     = 042
                    type       = 'I'
                    message_v1 = '/THKR/T_RKO_ERR'
                    message_v2 = curr_line-01_btyp
                    message_v3 = curr_line-05_quelle
                    message_v4 = curr_line-06_qbelnr ) TO return_tab.
      success = 'Y'.
    ELSE.
      IF 1 = 0. MESSAGE e043(/thkr/sst) WITH '/THKR/T_RKO_ERR' curr_line-01_btyp curr_line-05_quelle curr_line-06_qbelnr.ENDIF.
      APPEND VALUE bapiret2( id         = '/THKR/SST'
                    number     = 043
                    type       = 'E'
                    message_v1 = '/THKR/T_RKO_ERR'
                    message_v2 = curr_line-01_btyp
                    message_v3 = curr_line-05_quelle
                    message_v4 = curr_line-06_qbelnr ) TO return_tab.
      success = 'N'.
    ENDIF.
    else.
      "Kein Eintrag in Fehlertabelle.
      "Also erfolgreich
      success = 'Y'.
  ENDIF.
ENDFUNCTION.
