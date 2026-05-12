*&---------------------------------------------------------------------*
*& Include          Z_FI_AUSANN_VERR_F01
*&---------------------------------------------------------------------*
************************************************************************
* Routinen                                                  *
************************************************************************
*&---------------------------------------------------------------------*
*& Form CHECK_AUTHORITY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form check_authority .
* siehe Include .... F124_MERGE (Ausgleichprogramm)
* dort Buchungskreis und Kontoart hier nur Buchungskreis
*
  data: ls_bukrs     type ty_bukrs,
        l_auth_activ type fm_authact.
  if p_list  eq gc_on.
    l_auth_activ = c_auth_activ_03.
  endif.
  if p_buch  eq gc_on.
    l_auth_activ = c_auth_activ_10.
  endif.

  select bukrs from t001 into table @gt_bukrs
    where bukrs in @s_bukrs.
  sort gt_bukrs.
  loop at gt_bukrs into ls_bukrs.
* Company Code-Beleg:
    authority-check object 'F_BKPF_BUK'
     id 'ACTVT' field l_auth_activ
     id 'BUKRS' field ls_bukrs-bukrs.
    if sy-subrc ne 0 .
      delete gt_bukrs.
      message w107 with ls_bukrs-bukrs.
    endif.
  endloop.

endform.

*&---------------------------------------------------------------------*
*& Form AUSAO_LESEN
*&---------------------------------------------------------------------*
*& ermittelt die AuszahlungsAO und stellt diese in gt_beleg
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form ausao_lesen .

  data: lv_augbl_init type augbl,
        lv_stblg_init type stblg.


  data: ls_beleg type ty_beleg.
  data: lv_number type i,
        lv_ref    type xblnr.

  data: ls_xblnr type ty_xblnr,
        ls_lifnr type ty_lifnr.
  clear: lv_augbl_init,
         lv_stblg_init.


  if gt_bukrs[] is not initial.
    select
             kopf~bukrs,
             kopf~belnr,
             kopf~gjahr,
             kopf~blart,
             kopf~bldat,
             kopf~budat,
             kopf~cpudt,
             kopf~cputm,
*          kopf~bvorg "selten gefüllt
             kopf~xblnr,
*           kopf~stblg
             kopf~bktxt,
             kopf~waers,
             kopf~hwaer,
             op~lifnr,
             op~augdt,
             op~augbl,
             op~buzei,
             op~shkzg,
             op~wrbtr,
             op~dmbtr,
             op~zfbdt,
             op~zterm,
             op~zlsch,
             op~zlspr,
             op~rebzg,
             op~rebzj,
             op~rebzz

       from bsik_view as op
       inner join bkpf as kopf
       on
          op~bukrs =  kopf~bukrs
            and  op~belnr = kopf~belnr
             and op~gjahr = kopf~gjahr
      for all entries in @gt_bukrs
*    where op~bukrs in @s_bukrs
       where op~bukrs = @gt_bukrs-bukrs
        and op~lifnr in @s_lifnr
        and op~gjahr in @s_gjahr
*Repro_ROC20210108      and op~belnr in @s_belnr
        and op~budat in @s_budat
        and op~cpudt in @s_cpudt  " wird geändert mit Buchung !
        and op~xblnr in @s_xblnr "Repro_ROC20210108
        and op~zlsch = @p_zlsch
*      and op~zlspr = @gc_init_zlspr "REPRO-ROC
*   hier auch nur echte AuszahlungsAO nehmen
*      and kopf~psoty = gc_psoty_01
       and  kopf~bstat = @gc_off " nur gebuchte
       and  kopf~stblg is initial    "REPRO-ROC
           into corresponding fields of table @gt_beleg.
  endif.
* erfasst = cpudt ist das Datum an dem nach Freigabe - Buchen gewählt wird

* das Referenzkassenzeichen aus der Annahme
* ist ebenfalls Kassenzeichen
* steht nicht Kopftext (Konzeptversion 1)

  loop at gt_beleg into ls_beleg where xblnr is not initial.
*    condense ls_beleg-bktxt no-gaps.
*    ls_beleg-xblnr_ann = ls_beleg-bktxt.
*    modify gt_beleg from ls_beleg transporting xblnr_ann .
*    ls_xblnr-xblnr = ls_beleg-xblnr_ann.
    ls_xblnr-xblnr = ls_beleg-xblnr.
    collect ls_xblnr into gt_xblnr.
    move-corresponding  ls_beleg to  ls_lifnr.
    collect ls_lifnr into gt_lifnr.
  endloop.





* Tabelle mit den Referenzen: gt_xblnr

endform.
*
*&---------------------------------------------------------------------*
*& Form ANN_LESEN
*&---------------------------------------------------------------------*
*& liest die Annahmeanordnungen
*& hier allerdings keine
*& * brauchen nciht prüfen, dass der Beleg in einem Zahllauf steckt,
*&  da der Zahlweg I nicht in den Zahllauf geht
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form ann_lesen .
* die sind erst einmal vorhanden
* brauchen anschließend die Daten aus BSID
* hier kann auch so einiges verloren gehen, ggf R

  data: lv_augbl_init type augbl,
        lv_stblg_init type stblg.
  clear: lv_augbl_init.
  data: ls_beleg    type ty_beleg,
        ls_beleg_az type ty_beleg,
        lv_number   type i,
        lv_ref      type xblnr,
        ls_head     type zfi_verr_head,
        ls_kunnr    type ty_kunnr.

  data: begin of ls_message,
          xblnr    type xblnr,
          messages type standard table of ty_msg.
  data: end of ls_message.
  data: ls_mess type ty_msg .

  data: l_auth_activ type fm_authact .

  if p_list  eq gc_on.
    l_auth_activ = c_auth_activ_03.
  endif.
  if p_buch  eq gc_on.
    l_auth_activ = c_auth_activ_10.
  endif.


  if gt_xblnr[] is not initial.
    select
            kopf~bukrs
            kopf~belnr
            kopf~gjahr
            kopf~blart
            kopf~bldat
            kopf~budat
            kopf~cpudt
            kopf~cputm
            kopf~bvorg
            kopf~xblnr
            kopf~stblg
            kopf~bktxt
            kopf~waers
            kopf~hwaer
            op~kunnr
            op~augdt
            op~augbl
            op~buzei
            op~shkzg
            op~wrbtr
            op~dmbtr
            op~zfbdt
            op~zterm
            op~zlsch
            op~rebzg
            op~rebzj
            op~rebzz
      from bsid as op
      inner join bkpf as kopf
      on
            op~bukrs =  kopf~bukrs
           and  op~belnr = kopf~belnr
            and op~gjahr = kopf~gjahr
     into corresponding fields of table gt_beleg_ann
      for all entries in gt_xblnr
     where kopf~xblnr = gt_xblnr-xblnr
*      and xblnr in s_xblnr
*       and op~zlsch = p_zlsch
*   hier auch nur echte AnnahmeAO nehmen
*      and kopf~psoty = gc_psoty_01
*   keine Stornos - obwohl diese ja zu einem Ausgleich führen
      and  kopf~stblg = lv_stblg_init  "001
      and  kopf~bstat = gc_off. " nur gebuchte

  endif.

  sort gt_beleg_ann by xblnr cpudt cputm .

  loop at gt_beleg_ann into ls_beleg .
*&---------------------------------------------------------------------*
* für beide Belegarten (AnnAO unnd AusAO) wird ein Schlüsselfeld benötigt
* zur Verbindung von Kopf und Beleg benötigt
*&---------------------------------------------------------------------*
*    ls_beleg-xblnr_ann = ls_beleg-xblnr.
*    modify gt_beleg_ann from ls_beleg transporting xblnr_ann.
*&---------------------------------------------------------------------*
* Referenztabelle
*&---------------------------------------------------------------------*
    ls_head-xblnr = ls_beleg-xblnr.
    collect ls_head into gt_head.
**&---------------------------------------------------------------------*
**   Kundentabelle
**&---------------------------------------------------------------------*
****    move-corresponding  ls_beleg to  ls_kunnr.
****    collect ls_kunnr into gt_kunnr.
  endloop.

* Tabelle mit den Referenzen: gt_xblnr


  loop at gt_head into ls_head.
    clear lv_number.
*  loop at gt_beleg transporting no fields where xblnr_ann = ls_head-xblnr .
*  loop at gt_beleg into ls_beleg_az where xblnr_ann = ls_head-xblnr .
    loop at gt_beleg into ls_beleg_az where xblnr = ls_head-xblnr .
      lv_number = lv_number + 1.
    endloop.
    clear ls_message-messages[].
*&---------------------------------------------------------------------*
* Fehler : AuszahlungsAO nicht eindeutig
*&---------------------------------------------------------------------*
    if  lv_number ne 1.
      clear ls_mess.
      ls_mess-msgid  = gc_arbgb.
      ls_mess-msgno =  '102'.
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
      ls_message-xblnr = ls_head-xblnr.
      append ls_message to gt_messages.
      ls_head-fehler = gc_on.
      modify gt_head from ls_head transporting fehler.
      if 1 = 2.
        message e102(z_fi_nachr).
      endif.

    else.
*&---------------------------------------------------------------------*
* Fehler : Zahlsperre als Fehler - Änderung 001
*&---------------------------------------------------------------------*
      if  ls_beleg_az-zlspr ne gc_init_zlspr. "
        clear ls_mess.
        ls_mess-msgid  = gc_arbgb.
        ls_mess-msgno =  '106'.
        ls_mess-msgty = gc_char_e.
        call function 'K_MESSAGE_TRANSFORM'
          exporting
            par_msgid         = ls_mess-msgid
            par_msgno         = ls_mess-msgno
            par_msgty         = ls_mess-msgty
            par_msgv1         = ls_mess-msgv1
            par_msgv2         = ls_mess-msgv2
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
        ls_message-xblnr = ls_head-xblnr.
        append ls_message to gt_messages.
        ls_head-fehler = gc_on.
        modify gt_head from ls_head transporting fehler.
        if 1 = 2.
          message e106(z_fi_nachr).
        endif.
      endif.
      clear lv_number.

*&---------------------------------------------------------------------*
*hier werden alle anderen Fälle gelöscht
*
*&---------------------------------------------------------------------*
      loop at gt_beleg_ann transporting no fields  where xblnr = ls_head-xblnr
                             and  dmbtr ne  ls_beleg_az-dmbtr.
        delete gt_beleg_ann.
      endloop.
*      loop at gt_beleg_ann transporting no fields where xblnr = ls_head-xblnr .
*&---------------------------------------------------------------------*
* Suchen eine Annahme-Anordnung mit dem gleichen Betrag
*&---------------------------------------------------------------------*
      loop at gt_beleg_ann into ls_beleg where xblnr = ls_head-xblnr
                             and  dmbtr =  ls_beleg_az-dmbtr.
*&---------------------------------------------------------------------*
* Frage: muss hier noch das ls_beleg_az-gjahr (Fortschreibung nach budat)
* gegen das Fälligkeitsdatum  der AnnahmeAO geprüft werden?
*&---------------------------------------------------------------------*
        lv_number = lv_number + 1.
*&---------------------------------------------------------------------*
*   Kundentabelle
*&---------------------------------------------------------------------*
        move-corresponding  ls_beleg to  ls_kunnr.
        collect ls_kunnr into gt_kunnr.
      endloop.
*&---------------------------------------------------------------------*
* Fehler : keine Ann.AO
*&---------------------------------------------------------------------*
      if  sy-subrc ne 0.
        clear ls_mess.
        ls_mess-msgid  = gc_arbgb.
        ls_mess-msgno =  '103'.
        ls_mess-msgty = gc_char_e.
        ls_mess-msgv1 = ls_head-xblnr.
        write ls_beleg_az-dmbtr to ls_mess-msgv2.
        call function 'K_MESSAGE_TRANSFORM'
          exporting
            par_msgid         = ls_mess-msgid
            par_msgno         = ls_mess-msgno
            par_msgty         = ls_mess-msgty
            par_msgv1         = ls_mess-msgv1
            par_msgv2         = ls_mess-msgv2
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
        ls_message-xblnr = ls_head-xblnr.
        append ls_message to gt_messages.
        ls_head-fehler = gc_on.
        modify gt_head from ls_head transporting fehler.
        if 1 = 2.
          message e103(z_fi_nachr).
        endif.
      else.
*&---------------------------------------------------------------------*
* Fehler : AnnAO nicht eindeutig
*&---------------------------------------------------------------------*
        if  lv_number ne 1.
          clear ls_mess.
          ls_mess-msgid  = gc_arbgb.
          ls_mess-msgno =  '102'.
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
          ls_message-xblnr = ls_head-xblnr.
          append ls_message to gt_messages.
          if 1 = 2.
            message e102(z_fi_nachr).
          endif.
          ls_head-fehler = gc_on.
          modify gt_head from ls_head transporting fehler.
        endif.
*&---------------------------------------------------------------------*
* Berechtigung: Prüfung Buchungskreis Ann-AO
*&---------------------------------------------------------------------*
        if  lv_number = 1.

          authority-check object 'F_BKPF_BUK'
          id 'ACTVT' field l_auth_activ
          id 'BUKRS' field ls_beleg-bukrs.

          if sy-subrc ne 0 .
            clear ls_mess.
            ls_mess-msgid  = gc_arbgb.
            ls_mess-msgno =  '108'.
            ls_mess-msgty = gc_char_e.
            ls_mess-msgv1 = ls_head-xblnr.
            ls_mess-msgv2 = ls_beleg-bukrs.
            call function 'K_MESSAGE_TRANSFORM'
              exporting
                par_msgid         = ls_mess-msgid
                par_msgno         = ls_mess-msgno
                par_msgty         = ls_mess-msgty
                par_msgv1         = ls_mess-msgv1
                par_msgv2         = ls_mess-msgv2
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
            ls_message-xblnr = ls_head-xblnr.
            append ls_message to gt_messages.
            if 1 = 2.
              message e108(z_fi_nachr).
            endif.
            ls_head-fehler = gc_on.
            modify gt_head from ls_head transporting fehler.
          endif. "Berechtigungsfehler

        endif. "lv_number = 1
      endif.
    endif.

  endloop.
endform.
*&---------------------------------------------------------------------*
*& Form ADRS_GET_KNA1
*&---------------------------------------------------------------------*
*& ermittelt die Kurz-Adresse für lifnr or kunnr
*& macht daraus ADDR_SHORT in der gt_kunnr und der gt_lifnr
*& Die Adresse wird nicht weiter verwendet, dient nur der Info
*& hier alles nur für Inland - da Verrechnung
*& hier könnte noch andere Aufbereitungen geben
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form adrs_get_kna1 .
  types: begin of lty_kna1,

           kunnr      type kna1-kunnr,
           land1      type  kna1-land1,
           name1      type  kna1-name1,
           name2      type  kna1-name2,
           ort01      type  kna1-ort01,
           pstlz      type  kna1-pstlz,
           regio      type  kna1-regio,
           stras      type  kna1-stras,
           xcpdk      type  kna1-xcpdk, "001 CPD_Adresse
           pfach      type  kna1-pfach,
           pfort      type  kna1-pfort,
           pstl2      type  kna1-pstl2,
           addr_short type ad_line_s.
  types: end of lty_kna1.
  data: lt_kna1 type standard table of lty_kna1.
  data: ls_kna1 type lty_kna1.
  data: ls_kunnr type ty_kunnr.
  data: ls_beleg_ann    type ty_beleg.

  if gt_kunnr[] is not initial.
    select kunnr
           land1
           name1
           name2
           ort01
           pstlz
           regio
           stras
           xcpdk
           pfach
           pfort
           pstl2
         from kna1 into corresponding fields of table lt_kna1
          for all entries in gt_kunnr  where kunnr  = gt_kunnr-kunnr.


  endif.
*&---------------------------------------------------------------------*
* Trennung in Nicht - CPD-Adressen
*&---------------------------------------------------------------------*
  loop at lt_kna1 into ls_kna1 where   xcpdk = gc_off.

    clear adrs.
    adrs-name1 = ls_kna1-name1.
    adrs-name2 = ls_kna1-name2.
    adrs-stras = ls_kna1-stras .
    adrs-pfach = ls_kna1-pfach .
    adrs-pstl2 = ls_kna1-pstl2.
    adrs-land1 = ls_kna1-land1 .
    adrs-pstlz = ls_kna1-pstlz .
    adrs-pfort = ls_kna1-pfort .
    adrs-ort01 = ls_kna1-ort01 .
    adrs-pstl2 = ls_kna1-pstl2 .
    adrs-regio = ls_kna1-regio.
    adrs-inlnd = 'DE' .  "t001-land1'.
    adrs-anzzl = 2.

    call function 'ADDRESS_INTO_PRINTFORM'
      exporting
        adrswa_in            = adrs
      importing
        adrswa_out           = adrs
        address_short_form_s = ls_kna1-addr_short.

    modify lt_kna1 from ls_kna1 transporting addr_short.
    loop at gt_kunnr into ls_kunnr where kunnr = ls_kna1-kunnr.
      ls_kunnr-addr_short = ls_kna1-addr_short.
      modify gt_kunnr from ls_kunnr transporting addr_short.
    endloop.
  endloop.
*&---------------------------------------------------------------------*
* Trennung  CPD-Adressen
*&---------------------------------------------------------------------*
  loop at lt_kna1 into ls_kna1 where   xcpdk = gc_on.
    loop at gt_kunnr into ls_kunnr where kunnr = ls_kna1-kunnr.
      loop at gt_beleg_ann into ls_beleg_ann where bukrs = ls_kunnr-bukrs
                           and   xblnr = ls_kunnr-xblnr
                           and   kunnr = ls_kunnr-kunnr.
        clear adrs.
        select single
               name1
               name2
               ort01
               pstlz
               regio
               stras
               pfach
*           pfort
               pstl2
             from bsec into corresponding fields of adrs
             where bukrs = ls_beleg_ann-bukrs
              and belnr = ls_beleg_ann-belnr
              and gjahr = ls_beleg_ann-gjahr
              and buzei = ls_beleg_ann-buzei.


        adrs-pfort = adrs-ort01. "pfort nicht in bsec
        adrs-inlnd = 'DE' .  "t001-land1'.
        adrs-anzzl = 2.

        call function 'ADDRESS_INTO_PRINTFORM'
          exporting
            adrswa_in            = adrs
          importing
            adrswa_out           = adrs
            address_short_form_s = ls_kunnr-addr_short.

        exit.
      endloop.
      modify gt_kunnr from ls_kunnr transporting addr_short.
    endloop.
  endloop.
endform.

*&---------------------------------------------------------------------*
*& Form ADRS_GET_LFA1
*&---------------------------------------------------------------------*
*& ermittelt die Kurz-Adresse für lifnr or kunnr
*& macht daraus ADDR_SHORT in der gt_kunnr und der gt_lifnr
*& Die Adresse wird nicht weiter verwendet, dient nur der Info
*& hier alles nur für Inland - da Verrechnung
*& hier könnte noch andere Aufbereitungen geben
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form adrs_get_lfa1 .
  types: begin of lty_lfa1,

           lifnr      type lfa1-lifnr,
           land1      type  lfa1-land1,
           name1      type  lfa1-name1,
           name2      type  lfa1-name2,
           ort01      type  lfa1-ort01,
           pstlz      type  lfa1-pstlz,
           regio      type  lfa1-regio,
           stras      type  lfa1-stras,
           xcpdk      type  lfa1-xcpdk,
           pfach      type  lfa1-pfach,
           pfort      type  lfa1-pfort,
           pstl2      type  lfa1-pstl2,
           addr_short type ad_line_s.
  types: end of lty_lfa1.
  data: lt_lfa1 type standard table of lty_lfa1.
  data: ls_lfa1 type lty_lfa1.
  data: ls_lifnr type ty_lifnr,
        ls_beleg type ty_beleg.


  if gt_lifnr[] is not initial.
    select lifnr
           land1
           name1
           name2
           ort01
           pstlz
           regio
           stras
           xcpdk
           pfach
           pfort
           pstl2
         from lfa1 into corresponding fields of table lt_lfa1
          for all entries in gt_lifnr  where lifnr  = gt_lifnr-lifnr.


  endif.

  loop at lt_lfa1 into ls_lfa1 where   xcpdk = gc_off.


    clear adrs.
    adrs-name1 = ls_lfa1-name1.
    adrs-name2 = ls_lfa1-name2.
    adrs-stras = ls_lfa1-stras .
    adrs-pfach = ls_lfa1-pfach .
    adrs-pstl2 = ls_lfa1-pstl2.
    adrs-land1 = ls_lfa1-land1 .
    adrs-pstlz = ls_lfa1-pstlz .
    adrs-pfort = ls_lfa1-pfort .
    adrs-ort01 = ls_lfa1-ort01 .
    adrs-pstl2 = ls_lfa1-pstl2 .
    adrs-regio = ls_lfa1-regio.
    adrs-inlnd = 'DE' .  "t001-land1'.
    adrs-anzzl = 2.
    call function 'ADDRESS_INTO_PRINTFORM'
      exporting
        adrswa_in            = adrs
      importing
        adrswa_out           = adrs
        address_short_form_s = ls_lfa1-addr_short.

    modify lt_lfa1 from ls_lfa1 transporting addr_short.
    loop at gt_lifnr into ls_lifnr where lifnr = ls_lfa1-lifnr.
      ls_lifnr-addr_short = ls_lfa1-addr_short.
      modify gt_lifnr from ls_lifnr transporting addr_short.
    endloop.
  endloop.
*&---------------------------------------------------------------------*
* Trennung  CPD-Adressen
*&---------------------------------------------------------------------*
  loop at lt_lfa1 into ls_lfa1 where  xcpdk = gc_on.

    loop at gt_lifnr into ls_lifnr where lifnr = ls_lfa1-lifnr.

      loop at gt_beleg into ls_beleg  where bukrs = ls_lifnr-bukrs
*                           and   xblnr_ann = ls_lifnr-xblnr_ann
                           and   xblnr = ls_lifnr-xblnr
                           and   lifnr = ls_lifnr-lifnr.
        clear adrs.
        select single
               name1
               name2
               ort01
               pstlz
               regio
               stras
               pfach
*           pfort
               pstl2
             from bsec into corresponding fields of adrs
             where bukrs = ls_beleg-bukrs
              and belnr = ls_beleg-belnr
              and gjahr = ls_beleg-gjahr
              and buzei = ls_beleg-buzei.


        adrs-pfort = adrs-ort01. "pfort nicht in bsec
        adrs-inlnd = 'DE' .  "t001-land1'.
        adrs-anzzl = 2.

        call function 'ADDRESS_INTO_PRINTFORM'
          exporting
            adrswa_in            = adrs
          importing
            adrswa_out           = adrs
            address_short_form_s = ls_lifnr-addr_short.

        exit.
      endloop.
      modify gt_lifnr from ls_lifnr transporting addr_short.
    endloop.
  endloop.
endform.
*--------------------------------------------------------------------------------
*
* in Anlehnung an top_of_page_132(RFZ30FOR)
*--------------------------------------------------------------------------------
form top_of_page.                                           "#EC CALLED

  data: lc_laufd(10) type c,
        lc_text(100) type c,
        lc_title1    like rfpdo-allgline.
  .

  data: li_len  type i,
        li_len2 type i,
        li_len3 type i,
        li_pos  type i,
        li_pos2 type i,
        li_pos3 type i.
*        li_pos4 TYPE i.
  data: l_time type i.

*-----------------------------------------------------
* fill the central title lines
*-----------------------------------------------------
  if p_list eq gc_on.
    lc_text = text-l10.
  elseif p_buch eq gc_on.
    if p_test eq gc_on.
      lc_text = text-l30.
    else.
      lc_text = text-l20.
    endif.
  endif.

*hier
*  lc_title2 = p_title2.

  format intensified on.

* calculate output positions
  perform output_length using text-l04 li_len.
  perform output_length using text-l05 li_len2.
  if li_len2 < li_len.
    li_len2 = li_len.
  endif.
  perform output_length using text-l06 li_len.
  if li_len2 < li_len.
    li_len2 = li_len.
  endif.                        " li_len2 = maxlen( text-004, 005, 006)

  li_len3 = strlen( sy-uname ).
  if li_len3 lt 10.                    " username shorter than date
    li_len3 = 10.
  endif.

  li_pos2 = 126 - li_len3 - li_len2.   " position for text-004, 005, 006
  li_pos3 = 130 - li_len3.             " position for name, date, time

*  if gx_noexpa eq 'X'." Hier kürzer gemacht
  li_pos2 = li_pos2 - 10. "???
  li_pos3 = li_pos3 - 10. "???
*  endif.

  perform output_length using lc_text li_len.
  li_pos  = 60 - ( li_len / 2 ).

***  PERFORM output_length USING lc_title2 li_len.
***  li_pos4 = 60 - ( li_len / 2 ).


  write at li_pos(75) lc_text .
  write: at li_pos2 sy-datum dd/mm/yyyy, '/ '.

  l_time = li_pos3 - li_pos2.
  if l_time < 12 .
    l_time = li_pos2 + 13.
    write at l_time(li_len3) sy-uzeit.
  else.
    write at li_pos3(li_len3) sy-uzeit.
  endif.
  new-line.

* second line
  lc_title1 = sy-title.
  if lc_title1 ne space.
    perform output_length using lc_title1 li_pos.
    li_pos = 60 - li_pos / 2.
    write at li_pos lc_title1.
  endif.
  write at li_pos2(li_len2) text-l04.
  write at li_pos3(li_len3) sy-uname.
  new-line.

* third line.

  write: at 1(*) text-l51, sy-mandt.
  write: at li_pos2 text-l50, at li_pos3 sy-pagno left-justified.
* lc_t
*  WRITE AT li_pos4 lc_title2.


endform.                    "top_of_page
*---------------------------------------------------------------------*
*       FORM OUTPUT_LENGTH                                            *
*---------------------------------------------------------------------*
*       Get output length of texts from textpool                      *
*       Get correct values for double-byte characters also            *
*---------------------------------------------------------------------*
*  -->  P_TEXT                                                        *
*  <--  P_LENGTH                                                      *
*---------------------------------------------------------------------*
form output_length using p_text p_length.

  call method cl_abap_list_utilities=>dynamic_output_length
    exporting
      field = p_text
    receiving
      len   = p_length.

endform.                    "output_length
*---------------------------------------------------------------------*
*       FORM after_line_output                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  rs_lineinfo                                                   *
*---------------------------------------------------------------------*
form after_line_output using rs_lineinfo type slis_lineinfo. "#EC CALLED


* is the actual line an item line
  if rs_lineinfo-tabname eq g_tabname_header.
    perform message_output using rs_lineinfo.
    perform adress_write using rs_lineinfo.
* Einmalig für die Gesamtsummen die Listbreite merken
    if gv_once = gc_off.
      gv_linsz = rs_lineinfo-linsz.
      gv_once = gc_on.
    endif.
  endif.



endform.                    "after_line_output
*&---------------------------------------------------------------------*
*& Form MESSAGE_OUTPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> RS_LINEINFO
*&---------------------------------------------------------------------*
form message_output    using is_lineinfo type slis_lineinfo.
  data: ls_head type zfi_verr_head.
  data: ls_messages like line of gt_messages.
  data: ls_message type ty_msg,
        lv_linsz   type i,
        lv_len     type i.

  if not is_lineinfo-tabindex is initial.
* Zum Index die Referenz lesen
    read table gt_head into ls_head index is_lineinfo-tabindex.
    if sy-subrc eq 0 .
      lv_linsz = is_lineinfo-linsz - 1.
      read table gt_messages into ls_messages  with table key xblnr = ls_head-xblnr.
      if ls_messages-xblnr  = ls_head-xblnr.
        lv_len = strlen( ls_message-msgtx ).
* neues Format
        format color col_negative intensified off.
**   Leerzeile--------------------------------------------
        new-line.
        write: sy-vline.
        write: at 2 text-l60.
        write at is_lineinfo-linsz sy-vline.
* Zeile mit Kreditor
        loop at gt_messages into ls_messages  where xblnr = ls_head-xblnr.
          loop at ls_messages-messages into ls_message .
            new-line.
            write: sy-vline.
            write: at 2 ls_message-msgtx(lv_linsz).
            write at is_lineinfo-linsz sy-vline.
            lv_len = lv_len - lv_linsz.
*&---------------------------------------------------------------------*
* falls - Meldungstext länger als Liste--> weiter
*&---------------------------------------------------------------------*
            if lv_len gt 0.
              new-line.
              write: sy-vline.
              write: at 2 ls_message-msgtx+lv_linsz(lv_linsz).
              write at is_lineinfo-linsz sy-vline.
              lv_len = lv_len - lv_linsz.
            endif.
*&---------------------------------------------------------------------*
* falls - Meldungstext länger --> weiter
*&---------------------------------------------------------------------*
            if lv_len gt 0.
              new-line.
              write: sy-vline.
              write: at 2 ls_message-msgtx+lv_linsz(lv_linsz).
              write at is_lineinfo-linsz sy-vline.
              lv_len = lv_len - lv_linsz.
            endif.
          endloop.
        endloop.
      endif.
    endif.
  endif.
endform.
*&---------------------------------------------------------------------*
*& Form ADRESS_WRITE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> RS_LINEINFO
*&---------------------------------------------------------------------*
form adress_write    using is_lineinfo type slis_lineinfo.
  data: ls_head type zfi_verr_head.
  data: ls_lifnr type ty_lifnr,
        ls_kunnr type ty_kunnr.

  if not is_lineinfo-tabindex is initial.
* Zum Index die Referenz lesen
    read table gt_head into ls_head index is_lineinfo-tabindex.
    if sy-subrc eq 0.
* neues Format
      format color col_background intensified off.
**   Leerzeile--------------------------------------------
      new-line.
      write: sy-vline.
      write: at 2 text-l40.
      write at is_lineinfo-linsz sy-vline.
* Zeile mit Kreditor
*      loop at gt_lifnr into ls_lifnr where xblnr_ann = ls_head-xblnr.
      loop at gt_lifnr into ls_lifnr where xblnr = ls_head-xblnr.
        new-line.
        write: sy-vline.
        write: at 2 ls_lifnr-bukrs,
              at 10 ls_lifnr-lifnr,
              at 25 'K', " hier fest setzen, am besten wenn Anschrift
              at 30 ls_lifnr-addr_short.
        write at is_lineinfo-linsz sy-vline.
      endloop.
* Zeile mit Debitor
      loop at gt_kunnr into ls_kunnr where xblnr = ls_head-xblnr.
        new-line.
        write: sy-vline.
        write: at 2 ls_kunnr-bukrs,
              at 10 ls_kunnr-kunnr,
              at 25 'D', " hier fest setzen, am besten wenn Anschrift
              at 30 ls_kunnr-addr_short.
        write at is_lineinfo-linsz sy-vline.
      endloop.
**   Leerzeile--------------------------------------------
      new-line.
      write: sy-vline.
      write at is_lineinfo-linsz sy-vline.

    endif.
  endif.
endform.
*---------------------------------------------------------------------*
*       FORM END_OF_LIST                                              *
*---------------------------------------------------------------------*
****       Als Summen in diesem Protokoll  werden vorgesehen:
***	 Gesamtanzahl der Fälle
***	 Anzahl der verarbeiteten Fälle
***  Falls wir mit Mappen arbeiten - Anzahl der Buchungen in der Mappe
***  ausgeben
***	 Anzahl der Fehler
***	 Gesamtbetrag der verarbeiteten Fälle
***	 Betragssummen (Einnahme/Ausgabe) je Buchungskreis
***                                                      *
*---------------------------------------------------------------------*
form end_of_list.                                           "#EC CALLED

  data: ls_sum_list type ty_sum_list.
  data: lv_number2 type i.

*falls keine Listausgabe -
  if gv_linsz = 0.
    gv_linsz = 100.
  endif.
*
  lv_number2 = gv_number - gv_number_error.
  format color col_background intensified off.
  new-line.
  write: sy-uline(gv_linsz).
  new-line.
  write: sy-vline.
  write: at 2 text-s01.
  write at gv_linsz sy-vline.
  write: / sy-vline.
  write: at 2  text-s02.
  write: at 35 gv_number.
  write at gv_linsz sy-vline.

*Sätze in der BI-Mappe
  if p_mode = gc_char_b.
    write: / sy-vline.
    write: at 2  text-s09.
    write: at 35 gv_bi_cnt_tcode.
    write at gv_linsz sy-vline.
  else.
    write: / sy-vline.
    write: at 2  text-s03.
    write: at 35 lv_number2.
    write at gv_linsz sy-vline.
  endif.

  write: / sy-vline.
  write: at 2  text-s04.
  write: at 35 gv_number_error.
  write at gv_linsz sy-vline.
* Sätze wegen Fehler in der Mappe
  if p_mode = gc_char_c.
    write: / sy-vline.
    write: at 2  text-s09.
    write: at 35 gv_bi_cnt_tcode.
    write at gv_linsz sy-vline.
  endif.
  new-line.
  write: sy-uline(gv_linsz).
* Überschrift Buchungkreis

  format color col_total intensified on.

  write: / sy-vline.
  write: at 2  text-s05.
  write: at 15 sy-vline.
  write: at 29  text-s06.
  write at 47 sy-vline.
  write: at 62  text-s07.
  write at 79 sy-vline.
  new-line.

* NUR MUSTER DER AUSGABE
***  lv_wrbtr = '10.90'.
***  lv_wrbtr2 = '100010.88'.
  loop at gt_sum into ls_sum_list.
    format color col_background intensified off.
    write: / sy-vline.
    write: ls_sum_list-bukrs under text-s05.
    write: at 15 sy-vline.
    write: at 17 ls_sum_list-wrbtra currency gv_waers .
    write at 47 sy-vline.
    write: at 49 ls_sum_list-wrbtre currency gv_waers ."ändern
    write at 79 sy-vline.
    write: / sy-uline(79).  "???
  endloop.
  new-line.


endform.
*&---------------------------------------------------------------------*
*& Form F30_CALL
*&---------------------------------------------------------------------*
*&  Call Transaktion Aufruf für die Verrechnung
*&  Falls Call nicht erfolgreich wird der Satz in die Batch-Input Mappe gestellt
*&  ??? sollten auch das Geschäftsjahr eingeben...
*&  kommt aus dem Buchungsdatum - FI_PERIOD_DETERMINE
*&---------------------------------------------------------------------*
*& -->  p_test entscheidet, ob nur Simulation
*& <--  p2        text
*&---------------------------------------------------------------------*
form f30_call .
  data: ls_beleg   type ty_beleg,
        ls_xblnr   type ty_xblnr,
        ls_item    type zfi_verr_item,
        ls_head    type zfi_verr_head,
        lv_xblnr   type bkpf-xblnr,
        lv_bktxt   type bkpf-bktxt,
        lv_belnr_d type bkpf-belnr,
        lv_belnr_k type bkpf-belnr,
        lv_bukrs_d type bkpf-bukrs,
        lv_bukrs_k type bkpf-bukrs,
        lv_kunnr   type kunnr,
        lv_lifnr   type lifnr,
*Ausgleichsdaten -----------------------------------
        lv_belnr_a type bkpf-belnr,
        lv_bukrs_a type bkpf-bukrs.


  data: ls_return type bapiret2.
  data: lv_mode(1) type c.
  data: lv_error  type xfeld,
        lv_error2 type xfeld,
        ls_sum1   type ty_sum_list,
        ls_sum2   type ty_sum_list.
  lv_mode = 'N'.

  data: lv_dynbegin like gc_on,
        lv_program  type bdcdata-program,
        lv_dynpro   type bdcdata-dynpro.


  data: lt_messtab type table of bdcmsgcoll,
        ls_messtab type bdcmsgcoll.
  clear gt_bdctab[].

  loop at gt_head into ls_head where fehler = gc_off.

*----------------------------------------------------------------------*
    "* Über die Annahme-AO, die diese Referenz haben
*----------------------------------------------------------------------*
    loop at gt_beleg_ann into ls_beleg where xblnr = ls_head-xblnr.

      lv_dynbegin = gc_on.
      lv_dynpro = '0122'.
      lv_program = 'SAPMF05A'.
      perform dynpro using lv_dynbegin lv_program lv_dynpro.
      lv_dynbegin = gc_off.
      perform dynpro using lv_dynbegin  'BDC_OKCODE' '=SL'.
      perform dynpro using lv_dynbegin  'BKPF-BLDAT' p_bldat.
      perform dynpro using lv_dynbegin  'BKPF-BUDAT' p_budat.
      perform dynpro using lv_dynbegin  'BKPF-BLART' p_blart.
      perform dynpro using lv_dynbegin  'BKPF-WAERS' gv_waers.
* ???---------------------------------------------------------------
*     Gjahr übernehmen?
* ???---------------------------------------------------------------


* Bleiben im Buchungskreis der Einnahme
      concatenate ls_beleg-belnr ls_beleg-bukrs ls_beleg-gjahr+2(2) into lv_xblnr.
* Belegnummer auf Deb-Seite
      lv_belnr_d = ls_beleg-belnr.
      lv_bukrs_d = ls_beleg-bukrs.
      lv_kunnr = ls_beleg-kunnr.

      perform dynpro using lv_dynbegin  'BKPF-BUKRS' ls_beleg-bukrs.
      perform dynpro using lv_dynbegin  'BKPF-XBLNR' lv_xblnr.

      clear ls_sum2.
      ls_sum2-bukrs = ls_beleg-bukrs.
      ls_sum2-wrbtre = ls_beleg-wrbtr.
    endloop.
*----------------------------------------------------------------------*
* Auszahlungen
*----------------------------------------------------------------------*
*    loop at gt_beleg into ls_beleg where xblnr_ann = ls_head-xblnr.
    loop at gt_beleg into ls_beleg where xblnr = ls_head-xblnr.
      concatenate ls_beleg-belnr ls_beleg-bukrs ls_beleg-gjahr+2(2) into lv_bktxt.
      lv_belnr_k = ls_beleg-belnr.
      lv_bukrs_k = ls_beleg-bukrs.
      lv_lifnr = ls_beleg-lifnr.
      perform dynpro using lv_dynbegin  'BKPF-BKTXT' lv_bktxt.
      clear ls_sum1.
      ls_sum1-bukrs = ls_beleg-bukrs.
      ls_sum1-wrbtra = ls_beleg-wrbtr.
    endloop.


*Dynpro Belegnummer eingeben----------------------
* ggf. kann hier noch geprüft werden, ob die Belegnummer an der 3. Pos steht
*
    lv_dynbegin = gc_on.
    lv_dynpro = '0710'.
    lv_program = 'SAPMF05A'.
    perform dynpro using lv_dynbegin lv_program lv_dynpro.
    lv_dynbegin = gc_off.
    perform dynpro using lv_dynbegin  'BDC_OKCODE' '/00'.
    perform dynpro using lv_dynbegin  'RF05A-AGBUK' lv_bukrs_d.
    perform dynpro using lv_dynbegin  'RF05A-AGKOA' gc_char_d.
    perform dynpro using lv_dynbegin  'RF05A-AGKON' lv_kunnr.  "Repro-ROC 20200623
    perform dynpro using lv_dynbegin  'RF05A-XNOPS' gc_on.
    perform dynpro using lv_dynbegin 'RF05A-XPOS1(01)' gc_off.
    perform dynpro using lv_dynbegin 'RF05A-XPOS1(03)'  gc_on.



    lv_dynbegin = gc_on.
    lv_dynpro = '0731'.
    lv_program = 'SAPMF05A'.
    perform dynpro using lv_dynbegin lv_program lv_dynpro.
    lv_dynbegin = gc_off.
    perform dynpro using lv_dynbegin  'BDC_OKCODE' '/00'.
    perform dynpro using lv_dynbegin  'RF05A-SEL01(01)' lv_belnr_d.

    lv_dynbegin = gc_on.
    lv_dynpro = '0731'.
    lv_program = 'SAPMF05A'.
    perform dynpro using lv_dynbegin lv_program lv_dynpro.
    lv_dynbegin = gc_off.
    perform dynpro using lv_dynbegin  'BDC_OKCODE' '=SLK'.

    lv_dynbegin = gc_on.
    lv_dynpro = '0710'.
    lv_program = 'SAPMF05A'.
    perform dynpro using lv_dynbegin lv_program lv_dynpro.
    lv_dynbegin = gc_off.
    perform dynpro using lv_dynbegin  'BDC_OKCODE' '/00'.
    perform dynpro using lv_dynbegin  'RF05A-AGBUK' lv_bukrs_k.
    perform dynpro using lv_dynbegin  'RF05A-AGKOA' gc_char_k.
    perform dynpro using lv_dynbegin  'RF05A-AGKON' lv_lifnr. "Repro-ROC 20200623
    perform dynpro using lv_dynbegin  'RF05A-XNOPS' gc_on.
    perform dynpro using lv_dynbegin 'RF05A-XPOS1(01)' gc_off.
    perform dynpro using lv_dynbegin 'RF05A-XPOS1(03)'  gc_on.


    lv_dynbegin = gc_on.
    lv_dynpro = '0731'.
    lv_program = 'SAPMF05A'.
    perform dynpro using lv_dynbegin lv_program lv_dynpro.
    lv_dynbegin = gc_off.
    perform dynpro using lv_dynbegin  'BDC_OKCODE' '=PA'.
    perform dynpro using lv_dynbegin  'RF05A-SEL01(01)' lv_belnr_k.



* das ist die Simulation
    lv_dynbegin = gc_on.
    lv_dynpro = '3100'.
    lv_program = 'SAPDF05X'.
    perform dynpro using lv_dynbegin lv_program lv_dynpro.
    lv_dynbegin = gc_off.
    perform dynpro using lv_dynbegin  'BDC_OKCODE' '=BS'.

*----------------------------------------------------------------------*
* Buchungen
*----------------------------------------------------------------------*
    if p_test = gc_off.
*----------------------------------------------------------------------*
* Fall buchungskreisübergreifend
*----------------------------------------------------------------------*
      if lv_bukrs_d ne lv_bukrs_k.
*----------------------------------------------------------------------*
        lv_dynbegin = gc_on.
        lv_dynpro = '0701'.
        lv_program = 'SAPMF05A'.
        perform dynpro using lv_dynbegin lv_program lv_dynpro.
        lv_dynbegin = gc_off.
        perform dynpro using lv_dynbegin  'BDC_OKCODE' '=BU'.
*----------------------------------------------------------------------*
* falls beide GP in einem Buchungskreis
*----------------------------------------------------------------------*
      else.
        lv_dynbegin = gc_on.
        lv_dynpro = '0700'.
        lv_program = 'SAPMF05A'.
        perform dynpro using lv_dynbegin lv_program lv_dynpro.
        lv_dynbegin = gc_off.
        perform dynpro using lv_dynbegin  'BDC_OKCODE' '=BU'.
      endif.



    endif.
    clear lv_error.
    if p_mode = gc_char_c.
      clear lt_messtab[].
      clear:  lv_belnr_a,
              lv_bukrs_a.
      call transaction gv_tcode with authority-check
        using    gt_bdctab
         mode lv_mode
* update 'S' ???
         messages into lt_messtab.

*      if sy-subrc <> 0.
* Alle Fehlermeldungen in die Liste
      loop at lt_messtab into ls_messtab where
                               msgtyp = 'A' or
                               msgtyp = 'E' or
                               msgtyp = 'X'.
        lv_error = gc_on.
        perform message_append using ls_head-xblnr
                                     ls_messtab.
      endloop.
*     endif.
*----------------------------------------------------------------------*
* im Erfolgsfall soll aus der Meldung F5(312) die Belegnummer
* ermittelt werden und mit in die Liste gehen
*----------------------------------------------------------------------*
      if sy-subrc ne 0.
        loop at lt_messtab into ls_messtab where
          msgid = 'F5' and msgnr = '312'.
          shift  ls_messtab-msgv1 left deleting leading gc_off.
          lv_belnr_a =  ls_messtab-msgv1.
          shift  ls_messtab-msgv2 left deleting leading gc_off.
          lv_bukrs_a =  ls_messtab-msgv2.
        endloop.
*----------------------------------------------------------------------*
* bei Erfolg: Summen aktualisieren
*----------------------------------------------------------------------*
        if  lv_belnr_a is not initial.
          collect ls_sum1 into gt_sum.
          collect ls_sum2 into gt_sum.

*----------------------------------------------------------------------*
*  Vereinheitlichung: es wir die Belegnummer aus der
*  Meldungstabelle ausgegeben, damit braucht nicht für
*  Ermittlung der übergreifenden Belegnummer gewartet werden
*----------------------------------------------------------------------*
          wait up to 1 seconds.

*** Belegnummer zum ausgeben
*** Beleg & wurde im Buchungskreis & gebucht
*** ggf sollen noch andere Daten ermittelt werden
**        if lv_bukrs_d ne lv_bukrs_k.
**          select single bvorg
**                 from   bkpf
**                 into   ls_head-bvorg
**                 where  bukrs = lv_bukrs_a
**                 and    belnr = lv_belnr_a
**                 and    gjahr = gv_gjahr.
***falls das  nicht gelingt --
**          if sy-subrc ne 0.
**            ls_head-bvorg = 'XXXXXXXXXXXXXXXX'.
**          endif.
***
**        else.
          concatenate lv_belnr_a lv_bukrs_a gv_gjahr+2(2) into ls_head-bvorg.
**        endif.

          ls_head-bktxt =  lv_bktxt.
          ls_head-zxblnr = lv_xblnr.
          ls_head-bukrs = lv_bukrs_a.

          modify gt_head from ls_head transporting bktxt zxblnr bukrs bvorg.
*----------------------------------------------------------------------*
* falls keine Belegnummer aus der Meldung erzeugt wurde
* gibt es einen unbekannten Fehler aus dem BI
* wahrscheinlich : andere Bildfolge im BI
*----------------------------------------------------------------------*
        else.
          if p_test = gc_off.
            lv_error = gc_on.
            ls_messtab-msgtyp = gc_char_e.
            ls_messtab-msgid = gc_arbgb.
            ls_messtab-msgnr = '002'.
            ls_messtab-msgv1 = text-e70.
            perform message_append using ls_head-xblnr
                                         ls_messtab.
          endif.
        endif.
      endif. "keine Fehlermeldungen aus call

    endif.
*----------------------------------------------------------------------*
* falls CALL nicht erfolgreich oder Modus für BI-Mappe
*----------------------------------------------------------------------*
    if p_mode = gc_char_b or lv_error = gc_on.
      clear lv_error2.
* message with mappe into ct_return
      if  gv_bci_mappe eq gc_on.
        perform bdc_insert using ls_head-xblnr
                                 gv_tcode
                           changing lv_error2.



      else.
        perform bdc_open_group using ls_head-xblnr.
*----------------------------------------------------------------------*
*         falls die Mappe nicht geöffnet werden kann--Abbruch
*----------------------------------------------------------------------*
        if  gv_bci_mappe eq gc_off.
          exit.
        endif.
*----------------------------------------------------------------------*
        perform bdc_insert using ls_head-xblnr
                                 gv_tcode
                           changing lv_error2.

      endif.
    endif.

*----------------------------------------------------------------------*
*   falls nur ein Satz nicht in die Mappe geht : lv_error2
*----------------------------------------------------------------------*
    if lv_error = gc_on or lv_error2 = gc_on.
      ls_head-fehler = gc_on.
      modify gt_head from ls_head transporting fehler.
      add 1 to gv_number_error.
    endif.
    clear gt_bdctab[].

  endloop.

*Falls eine  Mappe geöffnet wurde- muss diese geschlossen werden
  if  gv_bci_mappe = gc_on.
    perform bdc_close_group using ls_head-xblnr.
  endif.

endform.
*
*---------------------------------------------------------------------*
*       FORM DYNPRO                                                   *
*---------------------------------------------------------------------*
*e      put bdc data into bdc table                                   *
*---------------------------------------------------------------------*
*  -->  DYNBEGIN                                                      *
*  -->  NAME                                                          *
*  -->  VALUE                                                         *
*---------------------------------------------------------------------*
form dynpro using p_dynbegin
                  p_name
                  p_value.

  data: lv_typ type c,
        ls_bdc type bdcdata.


  if p_dynbegin = gc_on.
    clear ls_bdc.
    move: p_name  to ls_bdc-program,
          p_value to ls_bdc-dynpro,
          gc_on   to ls_bdc-dynbegin.
    append ls_bdc to gt_bdctab.
  else.
    clear ls_bdc.
    describe field p_value type lv_typ.
    move  p_name   to ls_bdc-fnam.
    case lv_typ.
      when 'P' or 'F' or 'I' or 'X'.
        write p_value to ls_bdc-fval left-justified.
      when 'D'.
        write p_value to ls_bdc-fval dd/mm/yy.
      when 'T'.
        write p_value to ls_bdc-fval left-justified.
      when others.
        move  p_value to ls_bdc-fval.
    endcase.
    append ls_bdc to gt_bdctab.
  endif.
endform.                    "DYNPRO
*&---------------------------------------------------------------------*


*----------------------------------------------------------------------*
*       FORM BDC_OPEN_GROUP                                            *
*----------------------------------------------------------------------*
*de     Batch-Input-Mappe eroeffnen                                    *
*e      open batch input session                                       *
*----------------------------------------------------------------------*
form bdc_open_group using u_xblnr type xblnr.


  data: lv_bi_mandt  type sy-mandt,
        lv_bi_sperre type boole_d,
        lv_bi_halten type boole_d.

  data: ls_messtab type bdcmsgcoll.


  constants: c_grpid(5) type c value 'VERR_'.


  lv_bi_mandt  = sy-mandt.            "Mappen-Mandant




  clear gv_groupid.
*--- Name Fehlermappe
  concatenate c_grpid sy-datum+2(6) into gv_groupid.

  call function 'BDC_OPEN_GROUP'
    exporting
      client              = lv_bi_mandt
      group               = gv_groupid
      user                = sy-uname
*      IMPORTING
*     QID                 =
    exceptions
      client_invalid      = 1
      destination_invalid = 2
      group_invalid       = 3
      group_is_locked     = 4
      holddate_invalid    = 5
      internal_error      = 6
      queue_error         = 7
      running             = 8
      system_lock_error   = 9
      user_invalid        = 10
      others              = 11.



  if sy-subrc is initial.
    message s305(00) with  text-e30 gv_groupid text-e20.
*& Mappe(n) & &


    gv_bci_mappe = gc_on.          "allg. Kennung eine Mappe offen

  else.

    ls_messtab-msgid = gc_arbgb.
    ls_messtab-msgnr = '105'.
    ls_messtab-msgtyp = gc_char_e.
    ls_messtab-msgv1 = text-e15.
    ls_messtab-msgv2 = gv_groupid.
    if 1 = 2.
      message e105(z_fi_nachr).
    endif.
    perform message_append
      using u_xblnr ls_messtab.


  endif.
endform.                    "BDC_OPEN_GROUP

*----------------------------------------------------------------------*
*       FORM BDC_INSERT                                                *
*----------------------------------------------------------------------*
*de     Mappe aus int. Tabelle BI1 erzeugen                            *
*e      create session from internal table BI1                         *
*----------------------------------------------------------------------*
form bdc_insert using u_xblnr type xblnr
                      u_bi_tcode type tcode
                changing c_error type xfeld.

  data: ls_messtab type bdcmsgcoll.

  call function 'BDC_INSERT'
    exporting
      tcode            = u_bi_tcode
*     POST_LOCAL       = NOVBLOCAL
*     PRINTING         = NOPRINT
*     SIMUBATCH        = ' '
*     CTUPARAMS        = ' '
    tables
      dynprotab        = gt_bdctab
    exceptions
      internal_error   = 1
      not_open         = 2
      queue_error      = 3
      tcode_invalid    = 4
      printing_invalid = 5
      posting_invalid  = 6
      others           = 7.


  if sy-subrc <> 0.
    c_error = gc_on.
    clear ls_messtab.
    ls_messtab-msgtyp = sy-msgty.
    ls_messtab-msgid = sy-msgid.
    ls_messtab-msgnr = sy-msgno.
    ls_messtab-msgv1 = sy-msgv1.
    ls_messtab-msgv2 = sy-msgv2.
    ls_messtab-msgv3 = sy-msgv3.
    ls_messtab-msgv4 = sy-msgv4.

    perform message_append
        using u_xblnr ls_messtab.


  else.
    clear gt_bdctab[].
    gv_bi_cnt_tcode = gv_bi_cnt_tcode + 1.
  endif.

endform.                    "BDC_INSERT

*----------------------------------------------------------------------*
*       FORM BDC_CLOSE_GROUP                                           *
*----------------------------------------------------------------------*
*de     Batch-Input-Mappe schliessen                                   *
*e      close batch input session                                      *
*----------------------------------------------------------------------*
form bdc_close_group using u_xblnr type xblnr.

  data: ls_messtab type bdcmsgcoll.




  call function 'BDC_CLOSE_GROUP'
    exceptions
      not_open    = 1
      queue_error = 2
      others      = 3.


  if sy-subrc <> 0.
    ls_messtab-msgid = gc_arbgb.
    ls_messtab-msgnr = '307'.
    ls_messtab-msgtyp = gc_char_e.
    ls_messtab-msgv1 = text-e50.
    ls_messtab-msgv2 = gv_groupid.
    if 1 = 2.
      message e307(00).
    endif.
*Fehler beim &  der Mappe  & &
    perform message_append
      using u_xblnr ls_messtab.

  else.
* Meldung für Job-Protokoll
    message s305(00) with  text-e30 gv_groupid text-e40.
*& Mappe(n) & &
  endif.

endform.                    "BDC_CLOSE_GROUP

*&---------------------------------------------------------------------*
*& Form MESSAGE_APPEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_HEAD_XBLNR
*&      --> LS_MESSTAB
*&---------------------------------------------------------------------*
form message_append  using    uv_head_xblnr type xblnr
                              us_messtab type bdcmsgcoll.
  data: begin of ls_message,
          xblnr    type xblnr,
          messages type standard table of ty_msg.
  data: end of ls_message.
  data: ls_mess type ty_msg .



  ls_message-xblnr = uv_head_xblnr.
  ls_mess-msgid  = us_messtab-msgid.
  ls_mess-msgno = us_messtab-msgnr.
  ls_mess-msgty = us_messtab-msgtyp.
  ls_mess-msgv1 = us_messtab-msgv1.
  ls_mess-msgv2 = us_messtab-msgv2.
  ls_mess-msgv3 = us_messtab-msgv3.
  ls_mess-msgv4 = us_messtab-msgv4.


  call function 'K_MESSAGE_TRANSFORM'
    exporting
      par_msgid         = ls_mess-msgid
      par_msgno         = ls_mess-msgno
      par_msgty         = ls_mess-msgty
      par_msgv1         = ls_mess-msgv1
      par_msgv2         = ls_mess-msgv2
      par_msgv3         = ls_mess-msgv3
      par_msgv4         = ls_mess-msgv4
* über diesen Parameter kann man an den Text au
*    par_total
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

endform.
*&---------------------------------------------------------------------*
*& Form GJAHR_GET
*&---------------------------------------------------------------------*
*& ermitteln das Geschäftsjahr
*&---------------------------------------------------------------------*
*&      --> P_BUDAT Buchungsdatum
*&      --> p_Periv aus dem Finanzkreis
*&      <-- GV_GJAHR Geschäftsjahr
*&---------------------------------------------------------------------*
form gjahr_get  using    uv_budat type budat
                         uv_periv type periv
                changing cv_gjahr type gjahr.

  call function 'FI_PERIOD_DETERMINE'
    exporting
      i_budat        = uv_budat
*     I_BUKRS        = ' '
*     I_RLDNR        = ' '
      i_periv        = uv_periv
*     I_GJAHR        = 0000
*     I_MONAT        = 00
*     X_XMO16        = ' '
    importing
      e_gjahr        = cv_gjahr
*     E_MONAT        =
*     E_POPER        =
    exceptions
      fiscal_year    = 1
      period         = 2
      period_version = 3
      posting_period = 4
      special_period = 5
      version        = 6
      posting_date   = 7
      others         = 8.
  if sy-subrc <> 0.
    message e002 with text-e60.
  endif.


endform.
