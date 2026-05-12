*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Anordnung"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_ao_wf .
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
*"     REFERENCE(CURR_LINE)
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  DATA: lt_ausao  TYPE /thkr/t_aord_bukrs.
  DATA: lt_annao  TYPE /thkr/t_aord_bukrs.
  DATA: lv_anz    TYPE i VALUE 0.
*"----------------------------------------------------------------------
  APPEND VALUE #( id         = 'KM'
                   number     = 418
                   type       = 'I'
                   message_v1 = '/THKR/AIF_ZALLGE_ACT_AO_WF' ) TO return_tab.
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
  LOOP AT data-ao ASSIGNING FIELD-SYMBOL(<ls_ao>) WHERE psoxb IS INITIAL AND ao_proc_status = 'S'.
    CASE <ls_ao>-psoty.
      WHEN: '01'.
        "Auszahlungsanordnung
        APPEND VALUE /thkr/s_aord_bukrs( lotzk = <ls_ao>-lotkz
                                         bukrs = <ls_ao>-bukrs ) TO lt_ausao.
      WHEN: '02'.
        "Annahmeanordnung
        APPEND VALUE /thkr/s_aord_bukrs( lotzk = <ls_ao>-lotkz
                                         bukrs = <ls_ao>-bukrs ) TO lt_annao.
    ENDCASE.
    lv_anz += 1.
  ENDLOOP.
  IF lt_ausao IS NOT INITIAL.
    "WF für Auszahlung
    CALL FUNCTION '/THKR/WF_AORD_SST_CREATE_EVENT'
      TABLES
        t_aord = lt_ausao.
  ENDIF.
  IF lt_annao IS NOT INITIAL.
    "WF für Annahme
    CALL FUNCTION '/THKR/WF_AORD_SST_CREATE_EVENT'
      TABLES
        t_aord = lt_annao.
  ENDIF.
  success = 'Y'.
  IF 1 = 0. MESSAGE i020(/thkr/sst) WITH lv_anz. ENDIF.
  APPEND VALUE bapiret2( id = '/THKR/SST'
                         number = 020
                         type = 'I'
                         message_v1 = lv_anz ) TO return_tab[].

*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
