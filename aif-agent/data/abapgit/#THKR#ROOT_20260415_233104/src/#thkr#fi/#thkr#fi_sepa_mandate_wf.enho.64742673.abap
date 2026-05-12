"Name: \PR:SAPLSEPA_MANDATE_UI\FO:MANDATE_CHANGE\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/FI_SEPA_MANDATE_WF.
TYPES: BEGIN OF lty_sepa_key,
         creditorid LIKE sepa_mandate-origin_rec_crdid,
         mandateid  LIKE sepa_mandate-origin_mndid,
       END OF lty_sepa_key.
DATA: lt_messages_enh             TYPE bapiret1_list,
      ls_messages_enh             TYPE bapiret1,
      lt_mandates_enh             TYPE sepa_mandate_list,
      l_tab_data_mandate_chng_enh TYPE sepa_tab_data_mandate_chng,
      l_str_data_mandate_chng_enh TYPE sepa_str_data_mandate_chng.
DATA: l_dtype_enh LIKE t100c-msgts,
      l_msgnr_enh LIKE t100c-msgnr.

DATA: ls_objkey   LIKE sweinstcou-objkey,
      lv_event    TYPE  swo_event,
      lv_objtype  TYPE swo_objtyp,
      ls_sepa_key TYPE lty_sepa_key,
      lt_worklist TYPE STANDARD TABLE OF swr_wihdr,
      lv_no_wf    TYPE abap_bool.

* check the mandate
PERFORM mandate_check USING rcode 'CHANGE'.
IF rcode NE 0.
  SET SCREEN sy-dynnr.
  LEAVE SCREEN.
ENDIF.

* append the mandate
MOVE-CORRESPONDING rfsepa_wa TO l_str_data_mandate_chng_enh.
APPEND l_str_data_mandate_chng_enh TO l_tab_data_mandate_chng_enh.

* change
CALL FUNCTION 'SEPA_MANDATES_API_CHANGE'
  EXPORTING
    i_authority_check              = 'X'
    i_update_task                  = tstat-utask
    i_buffer_only                  = tstat-buffer
    i_tab_data_mandate_chng        = l_tab_data_mandate_chng_enh
    i_only_1_change_version_in_luw = 'X'
    i_already_checked              = 'X'
  IMPORTING
    et_messages                    = lt_messages_enh.

CLEAR lv_no_wf.
IF NOT lt_messages_enh IS INITIAL.
  READ TABLE lt_messages_enh INTO ls_messages_enh INDEX 1.
  IF ls_messages_enh-id = 'SEPA' AND ls_messages_enh-number = '205'.
    lv_no_wf = 'X'.
    CLEAR ls_messages_enh.
  ENDIF.

  READ TABLE lt_messages_enh INTO ls_messages_enh INDEX 1.
  IF ls_messages_enh-id = 'SEPA' AND ls_messages_enh-number = '205'
    AND tstat-fullscreen IS INITIAL
    AND g_gos_commithandler->g_gos_commit_required EQ 'X'.
    CLEAR lt_messages_enh.
  ELSE.
    MESSAGE ID ls_messages_enh-id
            TYPE ls_messages_enh-type
            NUMBER ls_messages_enh-number
            WITH ls_messages_enh-message_v1 ls_messages_enh-message_v2
                 ls_messages_enh-message_v3 ls_messages_enh-message_v4.
    IF ls_messages_enh-type CA 'EAX'.
      SET SCREEN sy-dynnr.
      LEAVE SCREEN.
    ENDIF.
  ENDIF.
ENDIF.

* message
IF lt_messages_enh IS INITIAL.
  IF tstat-do_commit NE space.
    l_msgnr_enh = 156.
    IF tstat-fullscreen IS INITIAL.
      l_dtype_enh = 'I'.
    ELSE.
      l_dtype_enh = 'S'.
    ENDIF.
  ELSE.
    l_msgnr_enh = 178.
    IF tstat-fullscreen IS INITIAL.
      l_dtype_enh = 'I'.
    ELSE.
      l_dtype_enh = 'S'.
    ENDIF.
  ENDIF.
  IF 1 = 2. "just for where-used list
    MESSAGE i156 WITH rfsepa_wa-mndid.
    MESSAGE i178 WITH rfsepa_wa-mndid.
  ENDIF.
  CALL FUNCTION 'CUSTOMIZED_MESSAGE'
    EXPORTING
      i_arbgb = 'SEPA'
      i_dtype = l_dtype_enh
      i_msgnr = l_msgnr_enh
      i_var01 = rfsepa_wa-mndid.
ENDIF.

* print if required
IF p_ucomm = 'PRINT'.
  PERFORM okcode_print USING 'X'.
ENDIF.

* COMMIT WORK (if wanted) and dequeue
  IF tstat-do_commit NE space.
  PERFORM check_for_update USING 'X' '' tstat-utask.
  COMMIT WORK.

  PERFORM mandate_dequeue USING rfsepa_wa-anwnd
                                rfsepa_wa-origin_mndid
                                rfsepa_wa-origin_rec_crdid
                                rfsepa_wa-snd_id.
ELSE.
  tstat-req_commit = 'X'.
ENDIF.

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  IF lv_no_wf is INITIAL AND tstat-do_commit NE space.
  "Ergeinis für Workflow auslösen.
  LOOP AT l_tab_data_mandate_chng_enh ASSIGNING FIELD-SYMBOL(<fs_mandt>).
    ls_sepa_key-creditorid = <fs_mandt>-origin_rec_crdid.
    ls_sepa_key-mandateid = <fs_mandt>-origin_mndid.
    EXIT.
  ENDLOOP.

  MOVE ls_sepa_key TO ls_objkey.
*MOVE rfsepa_wa-MGUID to ls_objkey.
  lv_objtype = 'SEPAMANDAT'.
  "Prüfen, ob bereits ein WF vorhanden ist
  CALL FUNCTION 'SAP_WAPI_WORKITEMS_TO_OBJECT'
    EXPORTING
      objtype                  = lv_objtype
      objkey                   = ls_objkey
      top_level_items          = 'X'
      selection_status_variant = 0001
    TABLES
      worklist                 = lt_worklist.
  "Wenn ja, dann löse Event RESTARTED aus.
  IF lt_worklist IS NOT INITIAL.
    lv_event = 'zrestarted'.
    CALL FUNCTION 'SWE_EVENT_CREATE'
      EXPORTING
        objtype              = lv_objtype
        objkey               = ls_objkey
        event                = lv_event
        start_recfb_synchron = 'X'
      EXCEPTIONS
        objtype_not_found    = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
    "Wenn nein, dann löse Event Changed aus
  ELSE.
    lv_event = 'zchanged'.
    CALL FUNCTION 'SWE_EVENT_CREATE'
      EXPORTING
        objtype              = lv_objtype
        objkey               = ls_objkey
        event                = lv_event
        start_recfb_synchron = 'X'
      EXCEPTIONS
        objtype_not_found    = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.
  ENDIF.
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

* restore publication of generic object services
PERFORM swu_restore.

* return to caller (only in popup mode?)
SET SCREEN 0.
LEAVE SCREEN.
EXIT.

ENDENHANCEMENT.
