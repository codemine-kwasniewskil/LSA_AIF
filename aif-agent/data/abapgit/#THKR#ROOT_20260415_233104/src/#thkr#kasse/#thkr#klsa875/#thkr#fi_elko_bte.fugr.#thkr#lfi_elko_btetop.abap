FUNCTION-POOL /THKR/FI_ELKO_BTE MESSAGE-ID /thkr/FI_NACHR.
tables: /thkr/dynp_elko_bte.
*      the old febeba is just for F4 in the selection screen
*      -> should be replaced by value tables of the new structures
tables: febeba, febko, febep.

constants:
  gc_off    type c value ' ',
  gc_on     type c value 'X',
  gc_char_v type c value 'V',
  gc_fistl  type fistl value '5501000000', "LOK BW
  gc_0 type char3 value '   ',
  gc_25 type char3 value ' 25',
  gc_50 type char3 value ' 50',
  gc_75 type char3 value ' 75',
  gc_100 type char3 value '100'.
* gc_bavm type char6 value '+BAVM+'.
data:
  g_febep   type febep,
  g_febep_new  type febep,
  g_ok_code like sy-ucomm,
  g_status type ZFI_EL_BEARBKZ.

data: g_count type i.
data: ld_vb1ok_eb_sl TYPE vb1ok_eb_sl,                 "n1071126
      ld_vb2ok_eb_sl TYPE vb2ok_eb_sl,                 "n1071126
      ld_astat_eb_sl TYPE astat_eb_sl.                 "n1071126

*     selection screen for the first PBO or at definite request

selection-screen begin of screen 0060 as window title  titletxt.
selection-screen begin of block header with frame title text-061.

selection-screen begin of line.
selection-screen comment 1(26) t_bukrs for field sl_bukrs.
select-options sl_bukrs for febko-bukrs modif id lbv.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(26) t_hbkid for field sl_hbkid.
select-options sl_hbkid for febko-hbkid modif id lbv.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(26) t_hktid for field sl_hktid.
select-options sl_hktid for febko-hktid modif id lbv.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(26) t_aznum for field sl_aznum.
select-options sl_aznum for febko-aznum.  "matchcode object feb_aznum.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(26) t_azdat for field sl_azdat.
select-options sl_azdat for febko-azdat.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(26) t_astat  for field sl_astat.
select-options sl_astat for ld_astat_eb_sl.                 "n1071126
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(26) t_waers  for field sl_waers.
select-options sl_waers for febko-waers.
selection-screen end of line.

selection-screen end of block header.


selection-screen begin of block item with frame title text-062.

selection-screen begin of line.
selection-screen comment 1(26) t_vb1ok  for field sl_vb1ok modif id so.
select-options sl_vb1ok for ld_vb1ok_eb_sl modif id so.         "n1071126
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(26) t_vb2ok for field sl_vb2ok modif id so.
select-options sl_vb2ok for ld_vb2ok_eb_sl modif id so.         "n1071126
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 01(29) t_1_stat for field p_1_stat modif id pa.
parameters p_1_stat type vb1stat as listbox visible length 47 user-command enter obligatory modif id pa.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 01(29) t_2_stat for field p_2_stat modif id pa.
parameters p_2_stat type vb2stat as listbox visible length 47 user-command enter obligatory modif id pa.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(26) t_kwbtr for field sl_kwbtr.
select-options sl_kwbtr for febep-kwbtr.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(26) t_grpnr for field sl_grpnr.
select-options sl_grpnr for febep-grpnr.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(26) t_vgint for field sl_vgint.
select-options sl_vgint for febep-vgint.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(26) t_vgdef for field sl_vgdef modif id so.
select-options sl_vgdef for febep-vgdef modif id so.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 01(29) t_gvcdef for field p_gvcdef modif id pa.
parameters p_gvcdef type gvcdef_eb as listbox visible length 47 user-command enter obligatory modif id pa.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(26) t_belnr for field sl_belnr modif id bel.
select-options sl_belnr for febep-belnr modif id bel.
selection-screen end of line.

selection-screen begin of line.                                         "n943526
selection-screen comment 1(26) t_nbbln for field sl_nbbln modif id nbb. "n943526
select-options sl_nbbln for febep-nbbln modif id nbb.                   "n943526
selection-screen end of line.                                           "n943526

selection-screen begin of line.
selection-screen comment 1(26) t_budat for field sl_budat.
select-options sl_budat for febep-budat.
selection-screen end of line.

selection-screen begin of line.
selection-screen comment 1(26) t_paswi for field sl_paswi.
select-options sl_paswi for febep-paswi.
selection-screen end of line.
selection-screen begin of line.
selection-screen comment 1(26) t_pakto for field sl_pakto.
select-options sl_pakto for febep-pakto.
selection-screen end of line.
selection-screen begin of line.
selection-screen comment 1(26) t_piban for field sl_piban.
select-options sl_piban for febep-piban.
selection-screen end of line.
selection-screen begin of line.
selection-screen comment 1(26) t_partn for field sl_partn.
select-options sl_partn for febep-partn.
selection-screen end of line.
selection-screen end of block item.

selection-screen begin of block view with frame title text-064.
parameters: p_area type buber_feban modif id so.
selection-screen end of block view.

* hidden parameters for external call (import from memory)
select-options sl_kukey for febep-kukey no-display.
select-options sl_esnum for febep-esnum no-display.


selection-screen end of screen 0060.

*-------------------------------------------------------------------
* AT SELECTION-SCREEN OUTPUT
*-------------------------------------------------------------------
at selection-screen output.
*----------------------------------------------------------------------
* für Transaktion Z_FEB_BSPROC_LBV
* es sind nur bestimmte Daten erlaubt: 7000, BBS, 00000
*----------------------------------------------------------------------
  data:        lv_lbv type zfi_ta_lbv.
*  get parameter id 'ZFI_TA_LBV' field lv_lbv.
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



* Fill new parameters from select options (the latter always have priority)
  if ' ' in sl_vb1ok and 'X' in sl_vb1ok.
    p_1_stat = '1'.
  elseif ' ' in sl_vb1ok.
    p_1_stat = '2'.
  elseif 'X' in sl_vb1ok.
    p_1_stat = '3'.
  else.
    p_1_stat = '1'.
  endif.
  if ' ' in sl_vb2ok and 'X' in sl_vb2ok.
    p_2_stat = '1'.
  elseif ' ' in sl_vb2ok.
    p_2_stat = '2'.
  elseif 'X' in sl_vb2ok.
    p_2_stat = '3'.
  else.
    p_2_stat = '1'.
  endif.
  if ' ' in sl_vgdef and 'X' in sl_vgdef.
    p_gvcdef = '1'.
  elseif 'X' in sl_vgdef.
    p_gvcdef = '2'.
  elseif ' ' in sl_vgdef.
    p_gvcdef = '3'.
  else.
    p_gvcdef = '1'.
  endif.

* In FEBAN: Show old select options for VB1OK and VB2OK
* In FEB_BSPROC: Show new parameters (drop down list boxes)
  loop at screen.
*    if g_caller eq 'FEB_BSPROC'.
      if screen-group1 eq 'SO'.
        screen-active = 0.
        modify screen.
      endif.
*    else.
*      if screen-group1 eq 'PA'.
*        screen-active = 0.
*        modify screen.
*      endif.
*    endif.
    if p_1_stat = 2.
      if screen-group1 eq 'BEL'.
        screen-active = 0.
        modify screen.
      endif.
    endif.
    if p_2_stat = 2.
      if screen-group1 eq 'NBB'.
        screen-active = 0.
        modify screen.
      endif.
    endif.
*----------------------------------------------------------------------
* für Transaktion Z_FEB_BSPROC_LBV
* es sind nur bestimmte Daten erlaubt: 7000, BBS, 00000
*----------------------------------------------------------------------
    if screen-group1 eq 'LBV' and  lv_lbv = 'LBV'.
         screen-input = 0.
        modify screen.
    endif .
*----------------------------------------------------------------------
  endloop.

**  if g_caller eq 'FEB_BSPROC'.
    titletxt = 'Auswahl der Kontoauszugspositionen'(310).
**  else.
**    titletxt = text-060.
**  endif.

*-------------------------------------------------------------------
* AT SELECTION-SCREEN
*-------------------------------------------------------------------
at selection-screen.

* Only if called from FEB_BSPROC: Fill select options from new parameters
**  if g_caller eq 'FEB_BSPROC'.
    clear:
      sl_vb1ok, sl_vb1ok[],
      sl_vb2ok, sl_vb2ok[].
    sl_vb1ok-sign   = sl_vb2ok-sign   = 'I'.
    sl_vb1ok-option = sl_vb2ok-option = 'EQ'.
    case p_1_stat.
      when '2'.
        append sl_vb1ok.
        clear: sl_belnr, sl_belnr[].
      when '3'.
        sl_vb1ok-low = 'X'.
        append sl_vb1ok.
    endcase.
    case p_2_stat.
      when '2'.
        append sl_vb2ok.
        clear: sl_nbbln, sl_nbbln[].
      when '3'.
        sl_vb2ok-low = 'X'.
        append sl_vb2ok.
    endcase.

    clear:
      sl_vgdef, sl_vgdef[].
    sl_vgdef-sign   = 'I'.
    sl_vgdef-option = 'EQ'.
    case p_gvcdef.
      when '2'.
        sl_vgdef-low = 'X'.
        append sl_vgdef.
      when '3'.
        append sl_vgdef.
    endcase.

**  endif.

*-------------------------------------------------------------------
* AT SELECTION-SCREEN ON VALUE-REQUEST
*-------------------------------------------------------------------
at selection-screen on value-request for sl_aznum-low.
   perform f4_aznum.





* INCLUDE LZ_FI_ELKO_BTED...                 " Local class definition
