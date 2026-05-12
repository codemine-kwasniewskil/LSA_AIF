*"----------------------------------------------------------------------
* Ole Rosenau TSI 02.12.2025
*"----------------------------------------------------------------------
* Action führt eine Sachkontenbuchung aus
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_skont .
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
*"     REFERENCE(CURR_LINE)
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  DATA: ls_documentheader    TYPE bapiache09,
        ls_bookingnumber(10) TYPE c,
        lt_accountgl         TYPE STANDARD TABLE OF bapiacgl09,
        lt_currencyamount    TYPE STANDARD TABLE OF bapiaccr09,
        lt_return            TYPE bapiret2_tab,
        ls_return            TYPE bapiret2,
        ls_message           TYPE bal_s_msg,
        lv_success           TYPE abap_bool,
        ls_sender_kont       TYPE /thkr/s_dto_psm_ao_kont,
        ls_betrag            TYPE bapidoccur,
        ls_betrag_v          TYPE bapidoccur.

  FIELD-SYMBOLS: <ls_line> TYPE /thkr/s_aif_sap_vr.
*"--------------------------------------------------------------------
  ASSIGN curr_line TO <ls_line>.

  READ TABLE <ls_line>-t_sender_kont INTO ls_sender_kont INDEX 1.

* Belegkopf-Daten
  ls_documentheader-comp_code  = <ls_line>-bukrs. " Buchungskreis
  ls_documentheader-doc_date   = <ls_line>-bldat. " Belegdatum
  ls_documentheader-pstng_date = <ls_line>-budat. " Buchungsdatum
  ls_documentheader-doc_type   = <ls_line>-blart. " Belegart
  ls_documentheader-username = sy-uname. "Username
  ls_documentheader-header_txt = <ls_line>-sgtxt.  "Positionstext

  IF <ls_line>-xumvz = 'X'.
    "Ausgabe IBA
    ls_betrag = <ls_line>-wrbtr.
    ls_betrag_v = - <ls_line>-wrbtr.
  ELSE.
    "Einnahme IBE
    ls_betrag = - <ls_line>-wrbtr.
    ls_betrag_v = <ls_line>-wrbtr.
  ENDIF.

  APPEND VALUE #( itemno_acc = '0000000001'
                  gl_account = ls_sender_kont-hkont
                  costcenter = <ls_line>-kostl
                  tax_code = <ls_line>-mwskz
                  cmmt_item = ls_sender_kont-fipex
                  funds_ctr = <ls_line>-fistl
                  ) TO lt_accountgl.
  APPEND VALUE #( itemno_acc = '0000000001'
                  currency   = <ls_line>-waers
                  amt_doccur = ls_betrag
                  curr_type  = '00'
                  ) TO lt_currencyamount.

  APPEND VALUE #( itemno_acc = '0000000002'
                  gl_account = <ls_line>-hkont
                  costcenter = <ls_line>-kostl
                  ) TO lt_accountgl.
  APPEND VALUE #( itemno_acc = '0000000002'
                  currency   = <ls_line>-waers
                  amt_doccur = ls_betrag_v
                  curr_type  = '00'
                  ) TO lt_currencyamount.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader = ls_documentheader
    TABLES
      accountgl      = lt_accountgl
      currencyamount = lt_currencyamount
      return         = lt_return.

  LOOP AT lt_return INTO ls_return.
    IF ls_return-type = 'S'.
      success = 'Y'.
      ls_bookingnumber = ls_return-message_v2(10).
    ENDIF.
    APPEND ls_return TO return_tab.
  ENDLOOP.

  CLEAR ls_return.

  IF success = 'Y'.
    ls_return-type      = 'S'.
    ls_return-id        = '/THKR/SST'.
    ls_return-number    = '001'.
    ls_return-message_v1   = 'Datensatz erfolgreich gebucht -'.
    ls_return-message_v2 = 'Buchungsnummer:' && ls_bookingnumber.
    APPEND ls_return TO RETURN_tab.
  ELSE.
    success = 'N'.
    ls_return-type      = 'E'.
    ls_return-id        = '/THKR/SST'.
    ls_return-number    = '001'.
    ls_return-message_v1   = 'Fehler beim buchen - Sachkonto:' && ls_sender_kont-hkont.
    APPEND ls_return TO RETURN_tab.
  ENDIF.

ENDFUNCTION.
