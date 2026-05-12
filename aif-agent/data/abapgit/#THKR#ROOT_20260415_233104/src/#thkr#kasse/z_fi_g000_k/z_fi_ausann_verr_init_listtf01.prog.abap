*----------------------------------------------------------------------*
***INCLUDE Z_FI_AUSANN_VERR_INIT_LISTTF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form INIT_LISTTOOL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
form init_listtool .
*&---------------------------------------------------------------------*
*soweit der Standard
***  G_REPID = SY-REPID.
***  G_TABNAME_HEADER = 'GT_SCARR'.
***  G_TABNAME_ITEM   = 'GT_SPFLI'.
**** define keyinfo
***  CLEAR GS_KEYINFO.
***  GS_KEYINFO-HEADER01 = 'CARRID'.
***  GS_KEYINFO-ITEM01   = 'CARRID'.
***  GS_KEYINFO-HEADER02 = SPACE.
***  GS_KEYINFO-ITEM02   = 'CONNID'.
****
***  PERFORM E01_FIELDCAT_INIT  USING GT_FIELDCAT[].
***  PERFORM E03_EVENTTAB_BUILD USING GT_EVENTS[].
***  PERFORM E04_COMMENT_BUILD  USING GT_LIST_TOP_OF_PAGE[].
***  PERFORM E07_SP_GROUP_BUILD USING GT_SP_GROUP[].
**** Schalter Varianten benutzerspezifisch/allgemein speicherbar setzen
**** Set Options: save variants userspecific or general
***  G_SAVE = 'A'.
***  PERFORM VARIANT_INIT.
**** Get default variant
***  GX_VARIANT = G_VARIANT.
***  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
***       EXPORTING
***            I_SAVE     = G_SAVE
***       CHANGING
***            CS_VARIANT = GX_VARIANT
***       EXCEPTIONS
***            NOT_FOUND  = 2.
***  IF SY-SUBRC = 0.
***    P_VARI = GX_VARIANT-VARIANT.
***  ENDIF.
*&---------------------------------------------------------------------*
  g_repid                    = sy-repid.

  gs_print-no_print_selinfos  = 'X'.
  gs_print-no_coverpage       = 'X'.
  gs_print-no_print_listinfos = 'X'.

  clear gs_keyinfo.
  gs_keyinfo-header01 = 'XBLNR'.
* gs_keyinfo-item01   = 'XBLNR_ANN'.
   gs_keyinfo-item01   = 'XBLNR'.
  gs_keyinfo-header02 = space.
  gs_keyinfo-item02   = 'BUKRS'.
  gs_keyinfo-header03 = space.
  gs_keyinfo-item03   = 'BELNR'.
  gs_keyinfo-header04 = space.
  gs_keyinfo-item04   = 'GJAHR'.
*
  perform fieldcat_init tables gt_fieldcat.
*PERFORM fieldcat_init_sum  TABLES gt_fieldcat_sum.


  perform layout_init   changing gs_layout.
***  PERFORM layout_init_sum CHANGING gs_layout_sum.
***  PERFORM sort_init     TABLES   gt_sort_main.
* PERFORM sort_init_sum TABLES   gt_sort_sum.

  perform eventtab_init      tables gt_events.
*  PERFORM eventtab_init_sum  TABLES gt_events_sum.

*Benötigt???  PERFORM event_exit_init    TABLES gt_event_exit.
endform.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT_MAIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT  text                                          *
*----------------------------------------------------------------------*
form fieldcat_init tables   pt_fieldcat type slis_t_fieldcat_alv.



  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
    exporting
*     i_program_name         = g_repid
      i_internal_tabname     = g_tabname_header
      i_structure_name       = 'ZFI_VERR_HEAD'
*     i_inclname             = g_inclname
      i_client_never_display = 'X'
    changing
      ct_fieldcat            = pt_fieldcat[].


* machen den Schlüssel zum technischen Feld
  loop at pt_fieldcat where tabname eq g_tabname_header.

*    if pt_fieldcat-fieldname = 'XBLNR'.
*      pt_fieldcat-tech = 'X'.
*      modify pt_fieldcat.
*    endif.
*    if pt_fieldcat-fieldname = 'ANN_WRSHB'.
*      pt_fieldcat-ctabname   = g_tabname_header.
*      pt_fieldcat-cfieldname = 'ANN_WAERS'.
*      pt_fieldcat-currency = gv_waers.
*      modify pt_fieldcat.
**    elseif  pt_fieldcat-fieldname = 'XBLNR_ANN'.
**      pt_fieldcat-tech = 'X'.
**      modify pt_fieldcat.
*
*    endif.
    if pt_fieldcat-fieldname = 'ZXBLNR'.
      pt_fieldcat-text_fieldname  = 'Referenz Ausgleich'(L80).
      pt_fieldcat-reptext_ddic  = 'Referenz Ausgleich'(L80).
      pt_fieldcat-seltext_l = 'Referenz Ausgleich'(L80).
      pt_fieldcat-seltext_m = 'Referenz Ausgl'(L85).
      pt_fieldcat-seltext_s = 'Referenz Ausgl'(L85).
      modify pt_fieldcat.
*    elseif  pt_fieldcat-fieldname = 'XBLNR_ANN'.
*      pt_fieldcat-tech = 'X'.
*      modify pt_fieldcat.

    elseif pt_fieldcat-fieldname = 'BVORG'.
      pt_fieldcat-text_fieldname  = 'Belnr Ausgleich'(L90).
      pt_fieldcat-reptext_ddic  = 'Belnr Ausgleich'(L90).
      pt_fieldcat-seltext_l = 'Belnr Ausgleich'(L90).
      pt_fieldcat-seltext_m = 'Belnr Ausgl'(L95).
      pt_fieldcat-seltext_s = 'Belnr Ausgl'(L95).
      modify pt_fieldcat.

    elseif pt_fieldcat-fieldname = 'BUKRS'.
      pt_fieldcat-no_out = gc_on.
      modify pt_fieldcat.
    endif.
  endloop.

  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
    exporting
*     i_program_name         = g_repid
      i_internal_tabname     = g_tabname_item
      i_structure_name       = 'ZFI_VERR_ITEM'
*     i_inclname             = g_inclname
      i_client_never_display = 'X'
    changing
      ct_fieldcat            = pt_fieldcat[].



  loop at pt_fieldcat where tabname eq g_tabname_item.
    if pt_fieldcat-fieldname = 'WRSHB'.
      pt_fieldcat-seltext_l = 'Betrag'(L70).
      pt_fieldcat-seltext_m = 'Betrag'(L70).
      pt_fieldcat-seltext_s = 'Betrag'(L70).

      pt_fieldcat-text_fieldname  = 'Betrag'(L70).
      pt_fieldcat-reptext_ddic  = 'Betrag'(L70).
      pt_fieldcat-outputlen = 20.
      pt_fieldcat-ctabname   = g_tabname_item.
      pt_fieldcat-cfieldname = 'WAERS'.
      pt_fieldcat-currency = gv_waers.
      modify pt_fieldcat.
*    elseif  pt_fieldcat-fieldname = 'XBLNR_ANN'.
*      pt_fieldcat-tech = 'X'.
*      modify pt_fieldcat.
    endif.

  endloop.
endform.
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GS_LAYOUT  text                                            *
*----------------------------------------------------------------------*
form layout_init changing ps_layout type slis_layout_alv.
  ps_layout-header_text       = 'Referenz'.
  ps_layout-item_text         = 'Belege'.
*     ps_layout-no_keyfix        = 'X'.
  ps_layout-zebra            = 'X'.
  ps_layout-no_totalline     = 'X'.
* ps_layout-expand_fieldname = 'XBLNR'. "only in maintenance mode
  ps_layout-min_linesize     = 255.
* ps_layout-list_append      = 'X'.
  ps_layout-group_change_edit = 'X'.
endform.                               " LAYOUT_INIT.


*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS  text                                            *
*----------------------------------------------------------------------*
form eventtab_init tables   pt_events type slis_t_event.

  data lt_events type slis_t_event with header line.

  refresh pt_events.

  call function 'REUSE_ALV_EVENTS_GET'
    exporting
      i_list_type = 1
    importing
      et_events   = lt_events[].
*----------------------------------------------------------------------*
* Listkopf
*----------------------------------------------------------------------*
  read table lt_events with key name = slis_ev_top_of_page.
  if sy-subrc eq 0.
    lt_events-form = 'TOP_OF_PAGE'.
    append lt_events to pt_events.
  endif.
*----------------------------------------------------------------------*
*  READ TABLE lt_events WITH KEY name = slis_ev_top_of_list.
*  IF sy-subrc EQ 0.
*    lt_events-form = 'TOP_OF_LIST'.
*    APPEND lt_events TO pt_events.
*  ENDIF.
*
  "  READ TABLE lt_events WITH KEY name = slis_ev_before_line_output.
  "  IF sy-subrc EQ 0.
  "    lt_events-form = 'BEFORE_LINE_OUTPUT'.
  "    APPEND lt_events TO pt_events.
  "  ENDIF.
*
*----------------------------------------------------------------------*
* nach jedem Kopf : Kontoangaben ausgeben
*----------------------------------------------------------------------*
  read table lt_events with key name = slis_ev_after_line_output.
  if sy-subrc eq 0.
    lt_events-form = 'AFTER_LINE_OUTPUT'.
    append lt_events to pt_events.
  endif.
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Listenende
*----------------------------------------------------------------------*
*----Ausgabe der Gesamtsummen
*----------------------------------------------------------------------*
  read table lt_events with key name = slis_ev_end_of_list.
  if sy-subrc eq 0.
    lt_events-form = 'END_OF_LIST'.
    append lt_events to pt_events.
  endif.



endform.                               " EVENTTAB_INIT
****&---------------------------------------------------------------------*
****& Form SORT_INIT
****&---------------------------------------------------------------------*
****& text
****&---------------------------------------------------------------------*
****&      --> GT_SORT
****&---------------------------------------------------------------------*
***form sort_init  tables   pt_sort type  slis_t_sortinfo_alv.
***
***  PT_SORT-FIELDNAME = 'XBLNR'.
***  pt_SORT-tabNAME = 'ZFI_VERR_HEAD'.
***  pT_SORT-SPOS      = '1'.
***  pT_SORT-UP        = 'X'.
***  APPEND pT_SORT.
***  PT_SORT-FIELDNAME = 'BLART'.
***  PT_SORT-tabNAME = 'ZFI_VERR_ITEM'.
***  PT_SORT-SPOS      = '2'.
***  pT_SORT-UP        = 'X'.
***
***  APPEND PT_SORT.
***endform.
