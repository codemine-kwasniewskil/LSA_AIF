"Name: \PR:SAPLSEPA_MANDATE_UI\FO:MANDATE_CREATE\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/FI_SEPA_MANDATE_WF.
TYPES: BEGIN OF lty_sepa_key,
         creditorid LIKE sepa_mandate-origin_rec_crdid,
         mandateid  LIKE sepa_mandate-origin_mndid,
       END OF lty_sepa_key.

DATA: lt_messages_enh               TYPE bapiret1_list,
      ls_messages_enh               TYPE bapiret1,
      ls_message_help_enh           TYPE bapiret1,
      lt_mandates_enh               TYPE sepa_mandate_list,
      l_tab_data_mandate_create_enh TYPE sepa_tab_mandate_create,
      l_str_data_mandate_create_enh TYPE sepa_str_mandate_create,
      ls_mandate_data_enh           TYPE sepa_str_data_mandate_data,
      lt_mandate_data_enh           TYPE sepa_tab_data_mandate_data.
DATA: l_dtype_enh LIKE t100c-msgts,
      l_msgnr_enh LIKE t100c-msgnr.

DATA: ls_objkey   LIKE sweinstcou-objkey,
      lv_event    TYPE  swo_event,
      lv_objtype  TYPE swo_objtyp,
      ls_sepa_key TYPE lty_sepa_key,
      lt_worklist TYPE STANDARD TABLE OF swr_wihdr.

* set application
rfsepa_wa-anwnd = gs_ctrl-anwnd.

* check the mandate
PERFORM mandate_check USING rcode 'CREATE'.
IF rcode NE 0.
  SET SCREEN sy-dynnr.
  LEAVE SCREEN.
ENDIF.

* determine ID later within FM SEPA_MANDATES_API_CREATE
*  IF rfsepa_wa-mndid IS INITIAL.
*    PERFORM default_mndid.
*  ENDIF.

* append the mandate
MOVE-CORRESPONDING rfsepa_wa TO l_str_data_mandate_create_enh.
APPEND l_str_data_mandate_create_enh TO l_tab_data_mandate_create_enh.

* create mandate
CALL FUNCTION 'SEPA_MANDATES_API_CREATE'
  EXPORTING
    i_update_task         = tstat-utask
    i_buffer_only         = tstat-buffer
    i_authority_check     = 'X'
    i_tab_mandates_create = l_tab_data_mandate_create_enh
    i_already_checked     = 'X'
  IMPORTING
    et_mandates_data      = lt_mandate_data_enh
*   ET_MANDATES_FAILED    =
    et_messages           = lt_messages_enh.

* messages
IF NOT lt_messages_enh IS INITIAL.
  LOOP AT lt_messages_enh INTO ls_messages_enh.
    PERFORM prioritize_message USING ls_messages_enh ls_message_help_enh
                               CHANGING ls_message_help_enh.
  ENDLOOP.
  ls_messages_enh = ls_message_help_enh.
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

CLEAR ls_mandate_data_enh.
READ TABLE lt_mandate_data_enh INTO ls_mandate_data_enh INDEX 1.
rfsepa_wa-mndid = ls_mandate_data_enh-mndid.
rfsepa_wa-rec_crdid = ls_mandate_data_enh-rec_crdid.
rfsepa_wa-snd_id = ls_mandate_data_enh-snd_id.
IF tstat-do_commit NE space.
  l_msgnr_enh = 154.
  IF tstat-fullscreen IS INITIAL.
    l_dtype_enh = 'I'.
  ELSE.
    l_dtype_enh = 'S'.
  ENDIF.
ELSE.
  l_msgnr_enh = 177.
  IF tstat-fullscreen IS INITIAL.
    l_dtype_enh = 'I'.
  ELSE.
    l_dtype_enh = 'S'.
  ENDIF.
ENDIF.
IF 1 = 2. "just for where-used list
  MESSAGE i154 WITH rfsepa_wa-mndid.
  MESSAGE i177 WITH rfsepa_wa-mndid.
ENDIF.
CALL FUNCTION 'CUSTOMIZED_MESSAGE'
  EXPORTING
    i_arbgb = 'SEPA'
    i_dtype = l_dtype_enh
    i_msgnr = l_msgnr_enh
    i_var01 = rfsepa_wa-mndid.

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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Erzeugen Ereignis für SEPA-Mandat
LOOP AT lt_mandate_data_enh INTO ls_mandate_data_enh.

  ls_sepa_key-creditorid = ls_mandate_data_enh-origin_rec_crdid.
  ls_sepa_key-mandateid = ls_mandate_data_enh-origin_mndid.
  EXIT.

ENDLOOP.
MOVE ls_sepa_key TO ls_objkey.

lv_objtype = 'SEPAMANDAT'.
"Prüfen, ob bereits ein WF zu diesem Objekt existiert, wenn ja, dann
"löse Event ZRESTARTED aus, ansonsten löse EVENT ZCREATED aus.
CALL FUNCTION 'SAP_WAPI_WORKITEMS_TO_OBJECT'
  EXPORTING
    objtype                  = lv_objtype
    objkey                   = ls_objkey
    top_level_items          = 'X'
    selection_status_variant = 0003
  TABLES
    worklist                 = lt_worklist.
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

ELSE.
  lv_event = 'zcreated'.
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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


* return to caller (only in popup mode?)
SET SCREEN 0.
LEAVE SCREEN.

EXIT.
ENDENHANCEMENT.
