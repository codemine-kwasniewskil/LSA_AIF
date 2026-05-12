*&---------------------------------------------------------------------*
*& Report /THKR/VERRECHNUNG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*REPORT /thkr/verrechnung.
* Funktion:
*
* Das Programm dient der Verrechnung von AuszahlungsAO und Annahme-Anord.
* mit dem Zahlweg X unter der Voraussetzung, das die entstandenen Belege
* betragsgleich sind
* Die Verrechnung findet über eine Umbuchung mit Ausgleich (Transaktion
* F-30; FB05)
* wir setzen voraus, dass die AnnahmeAO ohne Absetzungen vorhanden sind
* es gibt eine Tabelle mit den Referenzen
*_______________________________________________________________________
* Hinweise:
* Voraussetzung ist, dass die AusAo im Belegkopftext das Kassenzeichen
* der AnnAo enthält. "geä. js
*_______________________________________________________________________

INCLUDE /thkr/fi_verrechnung_top.                     "global data
INCLUDE /thkr/fi_verrechnung_f01.                     " FORM-Routines
INCLUDE /thkr/fi_verrechnung_init_list.          "Forms für die Liste

*----------------------------------------------------------------------*
*        V O R S C H L A G S W E R T E    INITIALISIEREN               *
*----------------------------------------------------------------------*
INITIALIZATION.
* ggf. aus einer Customizing Tabelle ermitteln
  p_blart = gc_blart_zi.
*----------------------------------------------------------------------*
* Währung ermitteln-ggf aus dem Fianzkreis
* Tabelle FM01
*----------------------------------------------------------------------*
  SELECT SINGLE waers
                periv
    FROM fm01 INTO ( gv_waers, gv_periv )
    WHERE fikrs = gc_fikrs.


  p_waers = gv_waers.
  p_bldat = sy-datum.
  p_budat = sy-datum.

  CLEAR: gv_once,
         gv_number,
         gv_number_error.

  PERFORM init_listtool.
*----------------------------------------------------------------------*
*        S E L E K T I O N S B I L D      VERARBEITEN (PBO)            *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name CS 'P_BLART'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
************************************************************************
AT SELECTION-SCREEN ON p_budat.
************************************************************************
*
  PERFORM gjahr_get USING p_budat
                          gv_periv
                    CHANGING gv_gjahr.


************************************************************************
AT SELECTION-SCREEN.
************************************************************************
* Prüfung auf 1 Bukrs und 1 Gjahr bei Eingabe der Belegnummer
* Nummernkreisobjekt RF_BELEG ist jahresabhängig
* ES sollte schon mehrere Beleg aus einem Buchungskreis; gjahr umfassen


*Berechtigungsprüfung auf Transaktion laut Entwicklungsrichtlinie
  AUTHORITY-CHECK OBJECT 'S_TCODE' ID 'TCD' FIELD gv_tcode.
  IF sy-subrc NE 0.
    MESSAGE e101.
  ENDIF.

  PERFORM check_authority.

************************************************************************
START-OF-SELECTION.
************************************************************************
* Daten selektieren
  PERFORM ausao_lesen  .  "--> Tabelle steht
  PERFORM ann_lesen.
  PERFORM adrs_get_kna1.
  PERFORM adrs_get_lfa1.
**perform annao_lesen .
*
  IF gt_xblnr[] IS INITIAL.
    MESSAGE s013.
    RETURN.
  ENDIF.

************************************************************************
END-OF-SELECTION.
************************************************************************
  DATA: ls_lifnr TYPE ty_lifnr,
        ls_kunnr TYPE ty_kunnr,
        ls_beleg TYPE ty_beleg,
        ls_xblnr TYPE ty_xblnr,
        ls_item  TYPE /thkr/fi_verr_item,
        ls_head  TYPE /thkr/fi_verr_head,
        lv_sum   TYPE wrshb,
        ls_sum1  TYPE ty_sum_list,
        ls_sum2  TYPE ty_sum_list.
  DATA: BEGIN OF ls_message,
          xblnr    TYPE xblnr,
          messages TYPE STANDARD TABLE OF ty_msg.
  DATA: END OF ls_message.
  DATA: ls_mess TYPE ty_msg .


*  Tabelle gt_head mit den Referenzen, die auf Basis der AuszAO
*  gefunden wurden

  LOOP AT gt_head INTO ls_head .
    ADD 1 TO gv_number.

    IF ls_head-fehler = gc_on.
      ADD 1 TO gv_number_error.
*----------------------------------------------------------------------*
* falls die Zuordnung nicht korrekt_ keine rechnung
* werden nur die AZ-Belege gezeigt
*----------------------------------------------------------------------*
       loop at gt_beleg into ls_beleg where xblnr_ann = ls_head-xblnr. "geä. js
*     LOOP AT gt_beleg INTO ls_beleg WHERE xblnr = ls_head-xblnr. "geä. js
        MOVE-CORRESPONDING ls_beleg TO ls_item.
        IF ls_beleg-shkzg = gc_char_s.
          ls_item-wrshb = ls_beleg-wrbtr.
        ELSEIF ls_beleg-shkzg = gc_char_h.
          ls_item-wrshb = ls_beleg-wrbtr * ( -1 ).
        ENDIF.
        APPEND ls_item TO gt_item.
      ENDLOOP.
    ELSE.
      CLEAR lv_sum.
*----------------------------------------------------------------------*
      "* Über die Auszahlungs-AO, die diese Referenz haben
*----------------------------------------------------------------------*
       loop at gt_beleg into ls_beleg where xblnr_ann = ls_head-xblnr. "geä. js
*     LOOP AT gt_beleg INTO ls_beleg WHERE xblnr = ls_head-xblnr. "geä. js
        MOVE-CORRESPONDING ls_beleg TO ls_item.
        IF ls_beleg-shkzg = gc_char_s.
          ls_item-wrshb = ls_beleg-wrbtr.
        ELSEIF ls_beleg-shkzg = gc_char_h.
          ls_item-wrshb = ls_beleg-wrbtr * ( -1 ).
        ENDIF.
*----------------------------------------------------------------------*
* Kontrollsumme
*----------------------------------------------------------------------*
        lv_sum = lv_sum + ls_item-wrshb.
*----------------------------------------------------------------------*
        APPEND ls_item TO gt_item.
*----------------------------------------------------------------------*
* Summen nur im Testlauf, sonst erst nach der Buchung
*----------------------------------------------------------------------*
        IF p_buch = gc_off.
          CLEAR ls_sum1.
          ls_sum1-bukrs = ls_beleg-bukrs.
          ls_sum1-wrbtra = ls_beleg-wrbtr.
        ENDIF.
      ENDLOOP.

*----------------------------------------------------------------------*
*  Über die Annahme-AO, die diese Referenz haben
*----------------------------------------------------------------------*
      LOOP AT gt_beleg_ann INTO ls_beleg WHERE xblnr = ls_head-xblnr.
        MOVE-CORRESPONDING ls_beleg TO ls_item.
        IF ls_beleg-shkzg = gc_char_s.
          ls_item-wrshb = ls_beleg-wrbtr.
        ELSEIF ls_beleg-shkzg = gc_char_h.
          ls_item-wrshb = ls_beleg-wrbtr * ( -1 ).
        ENDIF.
*----------------------------------------------------------------------*
* Kontrollsumme
*----------------------------------------------------------------------*
        lv_sum = lv_sum + ls_item-wrshb.
*----------------------------------------------------------------------*
        APPEND ls_item TO gt_item.
*----------------------------------------------------------------------*
* Summen nur im Testlauf, sonst erst nach der Buchung
*----------------------------------------------------------------------*
        IF p_buch = gc_off.
          CLEAR ls_sum2.
          ls_sum2-bukrs = ls_beleg-bukrs.
          ls_sum2-wrbtre = ls_beleg-wrbtr.
        ENDIF.
*----------------------------------------------------------------------*
      ENDLOOP.
*&---------------------------------------------------------------------*
* Fehler : keine Betragsübereinstimmung
*&---------------------------------------------------------------------*
      IF lv_sum = 0.
        IF p_buch = gc_off.
          COLLECT ls_sum1 INTO gt_sum.
          COLLECT ls_sum2 INTO gt_sum.
        ENDIF.
      ELSE.

        ls_message-xblnr = ls_head-xblnr.
        CLEAR ls_message-messages[].
        ls_mess-msgid  = gc_arbgb.
        ls_mess-msgno = '104'.
        ls_mess-msgty = gc_char_e.
        ls_mess-msgv1 = ls_head-xblnr.
        CALL FUNCTION 'K_MESSAGE_TRANSFORM'
          EXPORTING
            par_msgid         = ls_mess-msgid
            par_msgno         = ls_mess-msgno
            par_msgty         = ls_mess-msgty
            par_msgv1         = ls_mess-msgv1
          IMPORTING
            par_msgtx         = ls_mess-msgtx
          EXCEPTIONS
            no_message_found  = 1
            par_msgid_missing = 2
            par_msgno_missing = 3
            par_msgty_missing = 4
            OTHERS            = 5.
        IF sy-subrc <> 0.
          ls_mess-msgtx = TEXT-e10.
        ENDIF.
        APPEND ls_mess TO ls_message-messages.
        APPEND ls_message TO gt_messages.
        IF 1 = 2.
          MESSAGE e104(z_fi_nachr).
        ENDIF.
        ls_head-fehler = gc_on.
        MODIFY gt_head FROM ls_head TRANSPORTING fehler.
        ADD 1 TO gv_number_error.
      ENDIF.

    ENDIF.

  ENDLOOP.

*&---------------------------------------------------------------------*
* Falls Buchung
*&---------------------------------------------------------------------*

  IF p_buch = gc_on.

    PERFORM f30_call.

  ENDIF.

* g_user_command --> nur bei eigener Interaktion
  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program      = g_repid
      is_layout               = gs_layout
      it_fieldcat             = gt_fieldcat[]
      i_save                  = g_save
      is_variant              = g_variant_main
      it_events               = gt_events
      i_tabname_header        = g_tabname_header
      i_tabname_item          = g_tabname_item
      i_structure_name_header = '/THKR/FI_VERR_HEAD'
      i_structure_name_item   = '/THKR/FI_VERR_ITEM'
      is_keyinfo              = gs_keyinfo
    TABLES
      t_outtab_header         = gt_head
      t_outtab_item           = gt_item.
