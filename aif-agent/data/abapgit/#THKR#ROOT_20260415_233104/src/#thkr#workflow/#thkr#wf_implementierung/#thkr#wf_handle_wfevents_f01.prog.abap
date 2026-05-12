*&---------------------------------------------------------------------*
*& Include          /THKR/WF_HANDLE_WFEVENTS_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form build_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- CT_FIELDCAT1
*&---------------------------------------------------------------------*
FORM build_fieldcat CHANGING ct_fieldcat TYPE lvc_t_fcat.

  " Aufbau der Feldleiste aus dem Dictionary
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'SWFDVEVTYP'
    CHANGING
      ct_fieldcat      = ct_fieldcat.

  " Aufbereitung der Ausgabe
  LOOP AT ct_fieldcat ASSIGNING FIELD-SYMBOL(<ls_fieldcat>).
*   Ausgabeeigenschaften für Felder
    CASE <ls_fieldcat>-fieldname.
      WHEN 'OBJTYPE'.
        <ls_fieldcat>-col_pos = 1.
      WHEN 'EVENT'.
        <ls_fieldcat>-col_pos = 2.
      WHEN 'RECTYPE'.
        <ls_fieldcat>-col_pos = 3.
      WHEN 'ENABLED'.
        <ls_fieldcat>-col_pos = 4.
        <ls_fieldcat>-edit = /thkr/cl_wf_constants=>gc_x.
      WHEN OTHERS.
        <ls_fieldcat>-tech = /thkr/cl_wf_constants=>gc_x.            " Keine Ausgabe
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form build_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <--> CS_LAYOUT
*&---------------------------------------------------------------------*
FORM build_layout CHANGING cs_layout TYPE lvc_s_layo.

  " Aufbereitung des Layouts
  CLEAR cs_layout.
  cs_layout-zebra = /thkr/cl_wf_constants=>gc_x.       " Zeileneinfärbung
  cs_layout-cwidth_opt = /thkr/cl_wf_constants=>gc_x.  " Optimale Breite
  cs_layout-sel_mode = 'A'.                          " SelectionMode

ENDFORM.
*&---------------------------------------------------------------------*
*& Form exclude_tb_functions
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <--> CT_EXCLUDE
*&---------------------------------------------------------------------*
FORM exclude_tb_functions CHANGING ct_exclude TYPE ui_functions.

* Aufbereitung der Funktionsleiste
  APPEND cl_gui_alv_grid=>mc_fc_auf TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_average TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_back_classic TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_call_abc TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_call_chain TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_call_crbatch TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_call_crweb TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_call_lineitems TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_call_master_data TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_call_more TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_call_report TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_call_xint TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_call_xml_export TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_call_xxl TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_check TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_col_invisible TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_col_optimize TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_count TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_current_variant TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_data_save TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_delete_filter TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_deselect_all TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_detail TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_excl_all TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_expcrdesig TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_expcrtempl TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_expmdb TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_extend TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_f4 TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_filter TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_find TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_find_more TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_fix_columns TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_graph TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_help TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_html TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_info TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_load_variant TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_cut TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_move_row TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_loc_paste TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste_new_row TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_loc_undo TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_maintain_variant TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_maximum TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_minimum TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_pc_file TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_print TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_print_back TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_print_prev TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_refresh TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_reprep TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_save_variant TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_select_all TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_send TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_sort TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_sort_asc TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_sort_dsc TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_subtot TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_sum TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_to_office TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_to_rep_tree TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_unfix_columns TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_url_copy_to_clipboard TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_variant_admin TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_fc_views TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_view_crystal TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_view_excel TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_view_grid TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_view_lotus TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_word_processor TO ct_exclude.

  " Aufbereitung Menüs
*  APPEND cl_gui_alv_grid=>mc_mb_export TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_mb_filter TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_mb_paste TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_mb_subtot TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_mb_sum TO ct_exclude.
*  APPEND cl_gui_alv_grid=>mc_mb_variant TO ct_exclude.
  APPEND cl_gui_alv_grid=>mc_mb_view TO ct_exclude.

  " Löschen aller Trennstriche
  APPEND cl_gui_alv_grid=>mc_fc_separator TO ct_exclude.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ermittle_aenderungen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM ermittle_aenderungen .

  " Datendefinitionen
  DATA: lt_row_no TYPE lvc_t_row.


  " Ermitteln der markierten Zeilen
  CALL METHOD go_grid1->get_selected_rows
    IMPORTING
      et_index_rows = lt_row_no.
  IF lt_row_no[] IS INITIAL.
    MESSAGE e108.
  ENDIF.

  " Aufbau Arbeitsvorrat
  FREE: gt_events_chg.
  LOOP AT lt_row_no ASSIGNING FIELD-SYMBOL(<ls_row_no>).

    " Filtern der zu bearbeitenden Einträge
    READ TABLE gt_events ASSIGNING FIELD-SYMBOL(<ls_events>) INDEX <ls_row_no>-index. "#EC CI_NOORDER
    IF sy-subrc = 0.
      " Aufnahme in Arbeitsvorrat
      APPEND <ls_events> TO gt_events_chg.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_events
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM handle_events .

  DATA(lv_update_ok) = abap_true.

  " Aufbau der Selektion für den LOAD
  LOOP AT gt_events_chg ASSIGNING FIELD-SYMBOL(<ls_events>).

    " Setzen/Löschen der Aktivflags
    TRY.
        CALL METHOD cl_swf_evt_type_linkage=>update_activation
          EXPORTING
            im_objcateg   = <ls_events>-objcateg
            im_objtype    = <ls_events>-objtype
            im_event      = <ls_events>-event
            im_rectype    = <ls_events>-rectype
            im_activation = <ls_events>-enabled
            im_transport  = ' '.

      CATCH cx_swf_evt_transport_failed.
      CATCH cx_swf_evt_transport_cancelled.
      CATCH cx_swf_utl_obj_upd_failed.
        lv_update_ok = abap_false.
        EXIT.
    ENDTRY.

  ENDLOOP.

  IF lv_update_ok IS INITIAL.
    MESSAGE e109.
  ELSE.
    MESSAGE i110.
  ENDIF.

ENDFORM.
