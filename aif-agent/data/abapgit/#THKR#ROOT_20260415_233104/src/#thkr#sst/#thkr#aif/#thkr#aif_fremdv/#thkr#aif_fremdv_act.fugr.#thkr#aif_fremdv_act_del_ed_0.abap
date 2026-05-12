FUNCTION /thkr/aif_fremdv_act_del_ed_0 .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_AIF_SAP
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_AIF_SAP_AO
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------

  "Schreibe BIC-Datensätze mit Betrag 0 in die Tabelle.
  "Muss gespeichert werden, um sich die Finanzierungsparameter zu sichern.
  "SZU hat keine eigenen Finanzierungsparameter, sondern nur eine Referenz über ein Kassenzeichen.
  "Wenn eine SZU von EDAS / OASIS geliefert wird, wird diese Zeile später für die Finanzpositionen verwendet.
  DATA: ls_edas_0 TYPE /thkr/t_edas_0.
  DATA: lo_struc TYPE REF TO cl_abap_structdescr.
*"----------------------------------------------------------------------
  APPEND VALUE #( id         = 'KM'
                   number     = 418
                   type       = 'I'
                   message_v1 = '/THKR/AIF_FREMDV_ACT_DEL_ED_0' ) TO return_tab.
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
  DELETE from /thkr/t_edas_0
  WHERE kassz = @curr_line-xblnr.
  IF sy-subrc = 0.
    if 1 = 0. MESSAGE s060(/THKR/SST) with curr_line-xblnr '/THKR/T_EDAS_0'.endif.
    APPEND value bapiret2( id = '/THKR/SST'
                           number = 060
                           type = 'S'
                           message_v1 = curr_line-xblnr
                           message_v2 = '/THKR/T_EDAS_0'  ) to return_tab[].
    success = 'Y'.
  ELSE.
    "Aktualisierung Fehlertabelle nicht erfolgreich.
    success = 'N'.
  ENDIF.

ENDFUNCTION.
