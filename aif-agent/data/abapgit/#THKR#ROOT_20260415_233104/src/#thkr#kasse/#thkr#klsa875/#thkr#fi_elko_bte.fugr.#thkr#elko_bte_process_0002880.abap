function /THKR/ELKO_BTE_PROCESS_0002880.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_SKIP_SCREEN) TYPE  CHAR1 OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_PICKED_ITEM) TYPE  FEBEP
*"  TABLES
*"      T_ITEMS STRUCTURE  FEBEP
*"      T_DOCS STRUCTURE  FEBKO
*"--------------------------------------------------------------------
  data: l_dd04v_wa    type dd04v,
        l_item_tab    type standard table of febep,
        h_item        type febep,
        l_lines       type i,
        l_added_lines type i,
        l_waers       like tcurc-waers,
        l_kwbtr       like bapicurr-bapicurr,
        l_bukrs       like febko-bukrs,                     "n1942790
        l_begru       like skb1-begru,                      "hw732749
        l_hkont       like febko-hkont.                     "hw732749

  data: lv_lok_flag   TYPE abap_bool.

  ranges: r_kukey for febep-kukey,
          r_kwbtr for febep-kwbtr.                          "hw703349
  field-symbols: <docs> type febko.

  refresh l_item_tab.
* get the texts for the selection screen -
* this is stupid and should be handable automatically

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'BUKRS'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_bukrs = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_bukrs = text-063.
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'HBKID'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_hbkid = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_hbkid = text-063.
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'HKTID'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_hktid = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_hktid = text-063.
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'VB1OK_EB_SL'                              "n1071126
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_vb1ok = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_vb1ok = text-063.
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'VB2OK_EB_SL'                              "n1071126
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_vb2ok = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_vb2ok = text-063.
  endif.

* Fill texts for new parameters in FEB_BSPROC
  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'VB1STAT'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.

  if sy-subrc eq 0.
    t_1_stat = l_dd04v_wa-scrtext_l.
  else.
    t_1_stat = 'Status Bankbuchhaltung'(300).
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'VB2STAT'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.

  if sy-subrc eq 0.
    t_2_stat = l_dd04v_wa-scrtext_l.
  else.
    t_2_stat = 'Status Nebenbuchhaltung'(301).
  endif.


  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'AZNUM_EB'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_aznum = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_aznum = text-063.
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'AZDAT_EB'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_azdat = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_azdat = text-063.
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'ASTAT_EB_SL'                              "n1071126
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_astat = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_astat = text-063.
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'WAERS'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_waers = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_waers = text-063.
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'GRPNR_EB'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_grpnr = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_grpnr = text-063.
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'BELNR_D'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_belnr = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_belnr = text-063.
  endif.

*START INSERTION note 943526
  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'NBBLN_EB'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_nbbln = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_nbbln = text-063.
  endif.
*END INSERTION note 943526


  t_belnr = text-302.
  t_nbbln = text-303.


  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'BUDAT'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_budat = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_budat = text-063.
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'KWBTR_EB'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_kwbtr = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_kwbtr = text-063.
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'VGINT_EB'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_vgint = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_vgint = text-063.
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'VGDEF_EB'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_vgdef = l_dd04v_wa-scrtext_l.                         "n1071126
  else.
    t_vgdef = text-063.
  endif.

*hier die eigenen Felder
  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'PASWI_EB'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_paswi = l_dd04v_wa-scrtext_l.
  else.
    t_paswi = text-063.
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'PAKTO_EB'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_pakto = l_dd04v_wa-scrtext_l.
  else.
    t_pakto = text-063.
  endif.
  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'PIBAN_EB'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_piban = l_dd04v_wa-scrtext_l.
  else.
    t_piban = text-063.
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'PARTN_EB'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.
  .
  if sy-subrc = 0.
    t_partn = l_dd04v_wa-scrtext_l.
  else.
    t_partn = text-063.
  endif.

  call function 'DDIF_DTEL_GET'
    exporting
      name     = 'GVCDEF_EB'
      state    = 'A'
      langu    = sy-langu
    importing
      dd04v_wa = l_dd04v_wa.

  if sy-subrc eq 0.
    t_gvcdef = l_dd04v_wa-scrtext_l.
  else.
    t_gvcdef = 'Geschäftsvorfallscode'(304).
  endif.


* aus FB: FEB_GET_FOR_POST_PROCESSING
*repro     Default value for new parameter: only FEBEP items with VB2OK = SPACE
  sl_vb2ok-sign   = 'I'.
  sl_vb2ok-option = 'EQ'.
  append sl_vb2ok.


* set the bank data buffer application: statement, check deposit...
* aus first of all
***  get parameter id 'EBW' field g_anwnd.
***  if l_anwnd is initial.
***    l_anwnd = '0001'.
***  endif.

* Here, we fill the internal table which holds the bank
* statement data - the container.
  if i_skip_screen is initial.
    call selection-screen 0060  starting at 10 1 ending at 100 15.
    if sy-subrc = 4 and g_count  = 0.
      leave program.
    endif.
  endif.
*----------------------------------------------------------------------
* zur Behandlung des Verhaltens bei Abbruchtaste auf Selektionsdynpro
*----------------------------------------------------------------------
  g_count = 1.
*----------------------------------------------------------------------
* für Transaktion Z_FEB_BSPROC_LBV
* es sind nur bestimmte Daten erlaubt: 7000, BBS, 00000
*----------------------------------------------------------------------
  data:        lv_lbv type zfi_ta_lbv.
  get parameter id 'ZFI_TA_LBV' field lv_lbv.
  if lv_lbv = 'LBV'.
    clear: sl_bukrs[],
           sl_hbkid[],
           sl_hktid[].
    sl_bukrs-sign = 'I'.
    sl_bukrs-option  = 'EQ'.
    sl_bukrs-low  = '7000'.
    append sl_bukrs.


    sl_hbkid-sign = 'I'.
    sl_hbkid-option  = 'EQ'.
    sl_hbkid-low  = 'BBS'.
    append sl_hbkid.

    sl_hktid-sign = 'I'.
    sl_hktid-option  = 'EQ'.
    sl_hktid-low  = '00000'.
    append sl_hktid.
  endif.


  select  * from  febko into table t_docs
  where  astat  in sl_astat
  and    aznum  in sl_aznum
  and    azdat  in sl_azdat
  and    waers  in sl_waers
  and    hbkid  in sl_hbkid
  and    hktid  in sl_hktid
  and    kukey  in sl_kukey
  and    bukrs  in sl_bukrs
*** g_anwnd is set by transactions FEBA_BANK_STATEMENT, FEBA_CHECK_DEPOSIT
*** and FEBA_ACCOUNT_BALANCE to 0001, 0002 or 0004 respectively
*** Default is 0001 (bank statement)
**  and    anwnd = g_anwnd
  and    anwnd = '0001'
  and    estyp   ne 'P'             "still in process        hw819762
* order by hbkid hktid.                                     "hw732749
  order by hbkid hktid azidt emkey.                         "n2761509

* todo: what if we don't have any header criteria? Shall
* we dare a direct SELECT on the FEBEP?

* check if we have any line item selection criteria:
* if so, l_added_lines must be greater than zero
  describe table sl_vb1ok lines l_added_lines.
  describe table sl_vb2ok lines l_lines.
  l_added_lines = l_added_lines + l_lines.
  describe table sl_grpnr lines l_lines.
  l_added_lines = l_added_lines + l_lines.
  describe table sl_belnr lines l_lines.
  l_added_lines = l_added_lines + l_lines.
  describe table sl_nbbln lines l_lines.                    "n943526
  l_added_lines = l_added_lines + l_lines.                  "n943526
  describe table sl_budat lines l_lines.
  l_added_lines = l_added_lines + l_lines.
  describe table sl_kwbtr lines l_lines.
  l_added_lines = l_added_lines + l_lines.
  describe table sl_vgint lines l_lines.
  l_added_lines = l_added_lines + l_lines.
  describe table sl_vgdef lines l_lines.
  l_added_lines = l_added_lines + l_lines.
  describe table sl_esnum lines l_lines.
  l_added_lines = l_added_lines + l_lines.
*-------------------------------------
  describe table sl_paswi lines l_lines.  "Repro
  l_added_lines = l_added_lines + l_lines.
  describe table sl_pakto lines l_lines.
  l_added_lines = l_added_lines + l_lines.
  describe table sl_partn lines l_lines.
  l_added_lines = l_added_lines + l_lines.
  describe table sl_piban lines l_lines.
  l_added_lines = l_added_lines + l_lines.
*-----------------------------------------
* todo: select into a reference variable to improve performance
* Falls weiterhin Performance Probleme, Select Single in Loop durch initiales Select mit Read Table tauschen

   AUTHORITY-CHECK OBJECT 'F_FEBB_BUK'
    ID 'BUKRS' FIELD '7000'
    ID 'ACTVT' FIELD '03'.
  IF sy-subrc NE 0.
    lv_lok_flag = abap_false.
  ELSE.
    lv_lok_flag = abap_true.
  ENDIF.


  r_kukey-sign = 'I'.
  r_kukey-option = 'EQ'.
  loop at t_docs assigning <docs>.                          "hw732749
    IF lv_lok_flag EQ abap_false.                           "Keine LOK Person, dann AUTH CHECK durchführen

     authority-check object 'F_FEBB_BUK'
     id 'BUKRS' field <docs>-bukrs                         "hw732749
     id 'ACTVT' field '03'.
     if sy-subrc <> 0.
       delete t_docs.
       continue.
* authority check for account display                       "hw732749
     else.
       if <docs>-hkont <> l_hkont
         or <docs>-bukrs <> l_bukrs.                         "n1942790
         l_hkont = <docs>-hkont.
         l_bukrs = <docs>-bukrs.                             "n1942790
         clear l_begru.
         select single begru from skb1 into l_begru
           where bukrs = <docs>-bukrs
             and saknr = <docs>-hkont.
       endif.
       if not l_begru is initial.
         authority-check object 'F_BKPF_BES'
                  id 'BRGRU' field l_begru
                  id 'ACTVT' field '03'.
         if sy-subrc <> 0.
           delete t_docs.
           continue.
         endif.
       endif.
* end of authority check for account display                "hw732749
     endif.
     r_kukey-low = <docs>-kukey.                             "hw732749
     append r_kukey.

    ELSE.

      r_kukey-low = <docs>-kukey.                             "hw732749
      append r_kukey.
    ENDIF.
  endloop.
  describe table r_kukey lines l_lines.
  check l_lines > 0.
* Begin of currency conversion for amount selection        "hw703349
  describe table sl_waers lines l_lines.
  if l_lines = 1.
    read table sl_waers index 1.
    if sl_waers-high is initial.
      loop at sl_kwbtr.
        l_kwbtr = sl_kwbtr-low.
        l_waers = sl_waers-low.
        call function 'BAPI_CURRENCY_CONV_TO_INTERNAL'
          exporting
            currency             = l_waers
            amount_external      = l_kwbtr
            max_number_of_digits = 23
          importing
            amount_internal      = sl_kwbtr-low.
        if not sl_kwbtr-high is initial.
          l_kwbtr = sl_kwbtr-high.
          call function 'BAPI_CURRENCY_CONV_TO_INTERNAL'
            exporting
              currency             = l_waers
              amount_external      = l_kwbtr
              max_number_of_digits = 23
            importing
              amount_internal      = sl_kwbtr-high.
        endif.
        append sl_kwbtr to r_kwbtr.
      endloop.
    else.
      r_kwbtr[] = sl_kwbtr[].
    endif.
  else.
    r_kwbtr[] = sl_kwbtr[].
  endif.
* End of currency conversion                               "hw703349
* Verbesserungsvorschlag, falls Laufzeit aufgrund von for all entries in schwächelt
* Sofern keine Kopfdaten angegeben, direkt auf FEBEP springen ohne Selektion auf FEBKO

  select * from  febep into table t_items
    for all entries in r_kukey                              " \TP 733548
    where  kukey  =  r_kukey-low                            " \TP 733548
    and    vb1ok  in sl_vb1ok
    and    vb2ok  in sl_vb2ok
    and    grpnr  in sl_grpnr
    and    belnr  in sl_belnr
    and    nbbln  in sl_nbbln                               "n943526
    and    budat  in sl_budat
    and    kwbtr  in r_kwbtr                                "hw703349
    and    vgint  in sl_vgint
    and    vgdef  in sl_vgdef
    and    paswi  in sl_paswi  "Repro
    and    pakto  in sl_pakto  "Repro
    and    partn  in sl_partn  "Repro
    and    piban  in sl_piban  "Repro
    and    esnum  in sl_esnum.
  sort t_items by kukey esnum.                              "n1410804

  if l_added_lines > 0.
    loop at t_docs assigning <docs>.
      read table t_items transporting no fields
        with key kukey = <docs>-kukey.
      if sy-subrc <> 0.
*  no items found for bank statement AND there
*  are item selection criteria -> delete the header also
        delete t_docs.
      endif.
    endloop.
  endif.

*AUS SAPLNEW_FEBA
* do a pre-selection
* 1) is there already a unique selection done by the user?
*    re-fill it with all data since it may only contain
*    the key fields kukey and esnum
****  describe table g_picked_items lines l_lines.
****  if l_lines le 1.
****    clear h_item.
****    read table g_picked_items index 1 into h_item.
****    refresh g_picked_items.
****    read table g_items into h_item
****       with key kukey = h_item-kukey
****                esnum = h_item-esnum.
****    if sy-subrc = 0.
****      append h_item to g_picked_items.
****    else.
***** 2) if not, select an unprocessed item.
****      if not g_picked_item_header is initial.               "hw696532
*****       VB1OK same kukey                                    "hw791771
****        read table g_items into h_item
****          with key vb1ok = ' '
****                   kukey = g_picked_item_header-kukey.
****        if sy-subrc = 0.
****          append h_item to g_picked_items.
****          read table g_docs into g_picked_item_header
****            with key kukey = h_item-kukey.
****        else.
*****         VB2OK same kukey
****          read table g_items into h_item                    "hw696532
****          with key vb2ok = ' '                              "hw696532
****                   kukey = g_picked_item_header-kukey.      "hw696532
****          if sy-subrc = 0.                                  "hw696532
****            append h_item to g_picked_items.                "hw696532
****            read table g_docs into g_picked_item_header     "hw696532
****              with key kukey = h_item-kukey.                "hw696532
****          endif.                                            "hw696532
****        endif.                                              "hw696532
****      endif.
****      if sy-subrc <> 0 or g_picked_item_header is initial.  "hw696532
*****       VB1OK all kukey                                     "hw791771
****        read table g_items into h_item
****          with key vb1ok = ' '.
****        if sy-subrc = 0.
****          append h_item to g_picked_items.
****          read table g_docs into g_picked_item_header
****            with key kukey = h_item-kukey.
****        else.
*****         VB2OK all kukey                                   "hw791771
****          read table g_items into h_item
****            with key vb2ok = ' '.
****          if sy-subrc = 0.
****            append h_item to g_picked_items.
****            read table g_docs into g_picked_item_header     "hw696532
****              with key kukey = h_item-kukey.                "hw696532
****          endif.
****        endif.
****      endif.
****    endif.
***** 3) if the user has selected more than 1 item, omit
*****    the pre-selection
****  endif.

* set a pre-selection: not posted in posting area 2
  loop at t_items into h_item
    where vb2ok = ' '.
    e_picked_item = h_item.
    exit.
  endloop.
*----------------------------------------------------------------------
* hier noch für die Selektion die BAVM - Vormerkungen realisieren
* --> neue Selektion bringt Aktualisierung
*----------------------------------------------------------------------
  call function 'Z_FI_ELKO_BAVM_UPD'
    exporting
*     I_ALL   =
      i_enq   = gc_on
    tables
      t_items = t_items.

endfunction.
