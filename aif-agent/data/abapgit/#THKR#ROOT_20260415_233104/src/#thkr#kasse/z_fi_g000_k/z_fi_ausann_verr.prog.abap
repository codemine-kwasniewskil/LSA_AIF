*&---------------------------------------------------------------------*
*& Report Z_FI_AUSANN_VERR
*_______________________________________________________________________
* Funktion:
*
* Das Programm dient der Verrechnung von AuszahlungsAO und Annahme-Anord.
* mit dem Zahlweg I unter der Voraussetzung, das die entstandenen Belege
* betragsgleich sind
* Die Verrechnung findet über eine Umbuchung mit Ausgleich (Transaktion
* F-30; FB05)
* wir setzen voraus, dass die AnnahmeAO ohne Absetzungen vorhanden sind
* es gibt eine Tabelle mit den Referenzen
*_______________________________________________________________________
* Hinweise:
*
*_______________________________________________________________________
* Erstellt:
*
*	16.10.2019  dxc Roch Erstanlage
*_______________________________________________________________________
* Änderungen:
*
* 001   23.06.20202 REPRO-ROC: AuszahlungsAO mit Zahlsperre werden nicht
*                   selektiert; (Monatsabschluss)
*                   Im Call_Teil (F-30) wird das Konto zusätzlich
*                   übergeben
* 002   07.09.2020  REPRO-ROC: Auszahlungs AO bekommt die Refer. der Annahme
*                   AO ins Referenzfeld statt BKtext
*_______________________________________________________________________*


include z_fi_ausann_verr_top.                     "global data

* INCLUDE Z_FI_AUSANN_VERR_O01                    .  " PBO-Modules
* INCLUDE Z_FI_AUSANN_VERR_I01                    .  " PAI-Modules
include z_fi_ausann_verr_f01                    .  " FORM-Routines
include z_fi_ausann_verr_init_listtf01.          "Forms für die Liste

*----------------------------------------------------------------------*
*        V O R S C H L A G S W E R T E    INITIALISIEREN               *
*----------------------------------------------------------------------*
initialization.


* ggf. aus einer Customizing Tabelle ermitteln
  p_blart = gc_blart_zi.
*----------------------------------------------------------------------*
* Währung ermitteln-ggf aus dem Fianzkreis
* Tabelle FM01
*----------------------------------------------------------------------*
  select single waers
                periv
    from fm01 into ( gv_waers, gv_periv )
    where fikrs = gc_fikrs.


  p_waers = gv_waers.
  p_bldat = sy-datum.
  p_budat = sy-datum.


  clear: gv_once,
         gv_number,
         gv_number_error.

  perform init_listtool.
*----------------------------------------------------------------------*
*        S E L E K T I O N S B I L D      VERARBEITEN (PBO)            *
*----------------------------------------------------------------------*
at selection-screen output.
  loop at screen.
    if screen-name cs 'P_BLART'.
      screen-input = '0'.
      modify screen.
    endif.
  endloop.
************************************************************************
at selection-screen on p_budat.
************************************************************************
*
  perform gjahr_get using p_budat
                          gv_periv
                    changing gv_gjahr.


************************************************************************
at selection-screen.
************************************************************************
* Prüfung auf 1 Bukrs und 1 Gjahr bei Eingabe der Belegnummer
* Nummernkreisobjekt RF_BELEG ist jahresabhängig
* ES sollte schon mehrere Beleg aus einem Buchungskreis; gjahr umfassen


*Berechtigungsprüfung auf Transaktion laut Entwicklungsrichtlinie
  authority-check object 'S_TCODE' id 'TCD' field gv_tcode.
  if sy-subrc ne 0.
    message e101.
  endif.

  perform check_authority.

************************************************************************
start-of-selection.
************************************************************************
* Daten selektieren
  perform ausao_lesen  .  "--> Tabelle steht
  perform ann_lesen.
  perform adrs_get_kna1.
  perform adrs_get_lfa1.
**perform annao_lesen .
*
  if gt_xblnr[] is initial.
    message s013.
    return.
  endif.

************************************************************************
end-of-selection.
************************************************************************
  data: ls_lifnr type ty_lifnr,
        ls_kunnr type ty_kunnr,

        ls_beleg type ty_beleg,
        ls_xblnr type ty_xblnr,
        ls_item  type zfi_verr_item,
        ls_head  type zfi_verr_head,
        lv_sum   type wrshb,
        ls_sum1  type ty_sum_list,
        ls_sum2  type ty_sum_list.
  data: begin of ls_message,
          xblnr    type xblnr,
          messages type standard table of ty_msg.
  data: end of ls_message.
  data: ls_mess type ty_msg .


*  Tabelle gt_head mit den Referenzen, die auf Basis der AuszAO
*  gefunden wurden

  loop at gt_head into ls_head .
    add 1 to gv_number.

    if ls_head-fehler = gc_on.
      add 1 to gv_number_error.
*----------------------------------------------------------------------*
* falls die Zuordnung nicht korrekt_ keine rechnung
* werden nur die AZ-Belege gezeigt
*----------------------------------------------------------------------*
*      loop at gt_beleg into ls_beleg where xblnr_ann = ls_head-xblnr.
      loop at gt_beleg into ls_beleg where xblnr = ls_head-xblnr.
        move-corresponding ls_beleg to ls_item.
        if ls_beleg-shkzg = gc_char_s.
          ls_item-wrshb = ls_beleg-wrbtr.
        elseif ls_beleg-shkzg = gc_char_h.
          ls_item-wrshb = ls_beleg-wrbtr * ( -1 ).
        endif.
        append ls_item to gt_item.
      endloop.
****      loop at gt_beleg_ann into ls_beleg where xblnr = ls_head-xblnr.
****        move-corresponding ls_beleg to ls_item.
****        append ls_item to gt_item.
****      endloop.
    else.
      clear lv_sum.
*----------------------------------------------------------------------*
      "* Über die Auszahlungs-AO, die diese Referenz haben
*----------------------------------------------------------------------*
*      loop at gt_beleg into ls_beleg where xblnr_ann = ls_head-xblnr.
        loop at gt_beleg into ls_beleg where xblnr = ls_head-xblnr.
        move-corresponding ls_beleg to ls_item.
        if ls_beleg-shkzg = gc_char_s.
          ls_item-wrshb = ls_beleg-wrbtr.
        elseif ls_beleg-shkzg = gc_char_h.
          ls_item-wrshb = ls_beleg-wrbtr * ( -1 ).
        endif.
*----------------------------------------------------------------------*
* Kontrollsumme
*----------------------------------------------------------------------*
        lv_sum = lv_sum + ls_item-wrshb.
*----------------------------------------------------------------------*
        append ls_item to gt_item.
*----------------------------------------------------------------------*
* Summen nur im Testlauf, sonst erst nach der Buchung
*----------------------------------------------------------------------*
        if p_buch = gc_off.
          clear ls_sum1.
          ls_sum1-bukrs = ls_beleg-bukrs.
          ls_sum1-wrbtra = ls_beleg-wrbtr.
        endif.
      endloop.

*----------------------------------------------------------------------*
*  Über die Annahme-AO, die diese Referenz haben
*----------------------------------------------------------------------*
      loop at gt_beleg_ann into ls_beleg where xblnr = ls_head-xblnr.
        move-corresponding ls_beleg to ls_item.
        if ls_beleg-shkzg = gc_char_s.
          ls_item-wrshb = ls_beleg-wrbtr.
        elseif ls_beleg-shkzg = gc_char_h.
          ls_item-wrshb = ls_beleg-wrbtr * ( -1 ).
        endif.
*----------------------------------------------------------------------*
* Kontrollsumme
*----------------------------------------------------------------------*
        lv_sum = lv_sum + ls_item-wrshb.
*----------------------------------------------------------------------*
        append ls_item to gt_item.
*----------------------------------------------------------------------*
* Summen nur im Testlauf, sonst erst nach der Buchung
*----------------------------------------------------------------------*
        if p_buch = gc_off.
          clear ls_sum2.
          ls_sum2-bukrs = ls_beleg-bukrs.
          ls_sum2-wrbtre = ls_beleg-wrbtr.
        endif.
*----------------------------------------------------------------------*
      endloop.
*&---------------------------------------------------------------------*
* Fehler : keine Betragsübereinstimmung
*&---------------------------------------------------------------------*
      if lv_sum = 0.
        if p_buch = gc_off.
          collect ls_sum1 into gt_sum.
          collect ls_sum2 into gt_sum.
        endif.
      else.

        ls_message-xblnr = ls_head-xblnr.
        clear ls_message-messages[].
        ls_mess-msgid  = gc_arbgb.
        ls_mess-msgno = '104'.
        ls_mess-msgty = gc_char_e.
        ls_mess-msgv1 = ls_head-xblnr.
        call function 'K_MESSAGE_TRANSFORM'
          exporting
            par_msgid         = ls_mess-msgid
            par_msgno         = ls_mess-msgno
            par_msgty         = ls_mess-msgty
            par_msgv1         = ls_mess-msgv1
          importing
            par_msgtx         = ls_mess-msgtx
          exceptions
            no_message_found  = 1
            par_msgid_missing = 2
            par_msgno_missing = 3
            par_msgty_missing = 4
            others            = 5.
        if sy-subrc <> 0.
          ls_mess-msgtx = text-e10.
        endif.
        append ls_mess to ls_message-messages.
        append ls_message to gt_messages.
        if 1 = 2.
          message e104(z_fi_nachr).
        endif.
        ls_head-fehler = gc_on.
        modify gt_head from ls_head transporting fehler.
        add 1 to gv_number_error.
      endif.

    endif.

  endloop.

*&---------------------------------------------------------------------*
* Falls Buchung
*&---------------------------------------------------------------------*

  if p_buch = gc_on.

    perform f30_call.

  endif.




* g_user_command --> nur bei eigener Interaktion
  call function 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    exporting
      i_callback_program      = g_repid
*     i_callback_user_command = g_user_command
      is_layout               = gs_layout
      it_fieldcat             = gt_fieldcat[]
*     it_sort                 = gt_sort_main[]
      i_save                  = g_save
      is_variant              = g_variant_main
      it_events               = gt_events
*     it_event_exit           = gt_event_exit[]
      i_tabname_header        = g_tabname_header
      i_tabname_item          = g_tabname_item
      i_structure_name_header = 'ZFI_VERR_HEAD'
      i_structure_name_item   = 'ZFI_VERR_ITEM'
      is_keyinfo              = gs_keyinfo
*     is_print                = gs_print
*     it_excluding            = gt_extab[]
*     I_BYPASSING_BUFFER      = 'X'
    tables
      t_outtab_header         = gt_head
      t_outtab_item           = gt_item.
