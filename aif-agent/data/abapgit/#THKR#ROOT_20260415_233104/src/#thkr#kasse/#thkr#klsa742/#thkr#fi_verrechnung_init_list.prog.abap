*&---------------------------------------------------------------------*
*& Include /THKR/FI_VERRECHNUNG_INIT_LIST
*&---------------------------------------------------------------------*
*& Form INIT_LISTTOOL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_listtool .
*&---------------------------------------------------------------------*
  g_repid                    = sy-repid.

  gs_print-no_print_selinfos  = 'X'.
  gs_print-no_coverpage       = 'X'.
  gs_print-no_print_listinfos = 'X'.

  CLEAR gs_keyinfo.
  gs_keyinfo-header01 = 'XBLNR'.
  gs_keyinfo-item01   = 'XBLNR'.
  gs_keyinfo-header02 = space.
  gs_keyinfo-item02   = 'BUKRS'.
  gs_keyinfo-header03 = space.
  gs_keyinfo-item03   = 'BELNR'.
  gs_keyinfo-header04 = space.
  gs_keyinfo-item04   = 'GJAHR'.
*
  PERFORM fieldcat_init TABLES gt_fieldcat.


  PERFORM layout_init   CHANGING gs_layout.

  PERFORM eventtab_init      TABLES gt_events.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT_MAIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FIELDCAT  text                                          *
*----------------------------------------------------------------------*
FORM fieldcat_init TABLES   pt_fieldcat TYPE slis_t_fieldcat_alv.



  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_internal_tabname     = g_tabname_header
      i_structure_name       = 'ZFI_VERR_HEAD'
      i_client_never_display = 'X'
    CHANGING
      ct_fieldcat            = pt_fieldcat[].


* machen den Schlüssel zum technischen Feld
  LOOP AT pt_fieldcat WHERE tabname EQ g_tabname_header.
    IF pt_fieldcat-fieldname = 'ZXBLNR'.
      pt_fieldcat-text_fieldname  = 'Referenz Ausgleich'(l80).
      pt_fieldcat-reptext_ddic  = 'Referenz Ausgleich'(l80).
      pt_fieldcat-seltext_l = 'Referenz Ausgleich'(l80).
      pt_fieldcat-seltext_m = 'Referenz Ausgl'(l85).
      pt_fieldcat-seltext_s = 'Referenz Ausgl'(l85).
      MODIFY pt_fieldcat.

    ELSEIF pt_fieldcat-fieldname = 'BVORG'.
      pt_fieldcat-text_fieldname  = 'Belnr Ausgleich'(l90).
      pt_fieldcat-reptext_ddic  = 'Belnr Ausgleich'(l90).
      pt_fieldcat-seltext_l = 'Belnr Ausgleich'(l90).
      pt_fieldcat-seltext_m = 'Belnr Ausgl'(l95).
      pt_fieldcat-seltext_s = 'Belnr Ausgl'(l95).
      MODIFY pt_fieldcat.

    ELSEIF pt_fieldcat-fieldname = 'BUKRS'.
      pt_fieldcat-no_out = gc_on.
      MODIFY pt_fieldcat.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
*     i_program_name         = g_repid
      i_internal_tabname     = g_tabname_item
      i_structure_name       = 'ZFI_VERR_ITEM'
*     i_inclname             = g_inclname
      i_client_never_display = 'X'
    CHANGING
      ct_fieldcat            = pt_fieldcat[].



  LOOP AT pt_fieldcat WHERE tabname EQ g_tabname_item.
    IF pt_fieldcat-fieldname = 'WRSHB'.
      pt_fieldcat-seltext_l = 'Betrag'(l70).
      pt_fieldcat-seltext_m = 'Betrag'(l70).
      pt_fieldcat-seltext_s = 'Betrag'(l70).

      pt_fieldcat-text_fieldname  = 'Betrag'(l70).
      pt_fieldcat-reptext_ddic  = 'Betrag'(l70).
      pt_fieldcat-outputlen = 20.
      pt_fieldcat-ctabname   = g_tabname_item.
      pt_fieldcat-cfieldname = 'WAERS'.
      pt_fieldcat-currency = gv_waers.
      MODIFY pt_fieldcat.
*    elseif  pt_fieldcat-fieldname = 'XBLNR_ANN'.
*      pt_fieldcat-tech = 'X'.
*      modify pt_fieldcat.
    ENDIF.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GS_LAYOUT  text                                            *
*----------------------------------------------------------------------*
FORM layout_init CHANGING ps_layout TYPE slis_layout_alv.
  ps_layout-header_text       = 'Referenz'.
  ps_layout-item_text         = 'Belege'.
  ps_layout-zebra            = 'X'.
  ps_layout-no_totalline     = 'X'.
  ps_layout-min_linesize     = 255.
  ps_layout-group_change_edit = 'X'.
ENDFORM.                               " LAYOUT_INIT.


*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS  text                                            *
*----------------------------------------------------------------------*
FORM eventtab_init TABLES   pt_events TYPE slis_t_event.

  DATA lt_events TYPE slis_t_event WITH HEADER LINE.

  REFRESH pt_events.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 1
    IMPORTING
      et_events   = lt_events[].
*----------------------------------------------------------------------*
* Listkopf
*----------------------------------------------------------------------*
  READ TABLE lt_events WITH KEY name = slis_ev_top_of_page.
  IF sy-subrc EQ 0.
    lt_events-form = 'TOP_OF_PAGE'.
    APPEND lt_events TO pt_events.
  ENDIF.
*----------------------------------------------------------------------*
* nach jedem Kopf : Kontoangaben ausgeben
*----------------------------------------------------------------------*
  READ TABLE lt_events WITH KEY name = slis_ev_after_line_output.
  IF sy-subrc EQ 0.
    lt_events-form = 'AFTER_LINE_OUTPUT'.
    APPEND lt_events TO pt_events.
  ENDIF.
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Listenende
*----------------------------------------------------------------------*
*----Ausgabe der Gesamtsummen
*----------------------------------------------------------------------*
  READ TABLE lt_events WITH KEY name = slis_ev_end_of_list.
  IF sy-subrc EQ 0.
    lt_events-form = 'END_OF_LIST'.
    APPEND lt_events TO pt_events.
  ENDIF.
ENDFORM.                               " EVENTTAB_INIT
