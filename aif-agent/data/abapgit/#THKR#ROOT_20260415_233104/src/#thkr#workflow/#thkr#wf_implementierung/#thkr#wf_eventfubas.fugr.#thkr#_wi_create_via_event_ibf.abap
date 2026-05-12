FUNCTION /THKR/_WI_CREATE_VIA_EVENT_IBF.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(SENDER) TYPE  SIBFLPORB
*"     VALUE(EVENT) TYPE  SIBFEVENT
*"     VALUE(RECTYPE) TYPE  SWFERECTYP
*"     VALUE(HANDLER) TYPE  SIBFLPORB
*"     VALUE(EXCEPTIONS_ALLOWED) TYPE  SWEFLAGS-EXC_OK DEFAULT SPACE
*"     VALUE(XML_SIZE) TYPE  SWF_XMLSIZ
*"     VALUE(EVENT_CONTAINER) TYPE  SWF_XMLCNT
*"  EXPORTING
*"     VALUE(RESULT) TYPE  SWFREVRSLT
*"  EXCEPTIONS
*"      READ_FAILED
*"      CREATE_FAILED
*"----------------------------------------------------------------------
*
*---> Funktioniert nicht , anderen fuBa nehmen!!
*   Ausschließen der Endlosschleife im ändern-Fall bei BP

if sender-typeid = 'BUS1006'   and sender-catid = 'BO' and sy-uname = 'SAP_WFRT'.
Exit.
Endif.



  DATA(lo_timer) = cl_abap_runtime=>create_lr_timer( ).
  lo_timer->get_runtime( ).
  DATA(lv_log_subkey) = 'EVT_' && sender-typeid && '_' && event && '_' && sender-instid && '_' && rectype.

  LOG-POINT ID wf_workitem_create SUBKEY lv_log_subkey FIELDS VALUE ty_log_status( name = 'START' time = sy-timlo zonlo = sy-zonlo langu = sy-langu ).

  TRY.
      DATA(lo_event_container) = cl_swf_cnt_factory=>create_from_xml( EXPORTING im_xml_table = event_container
                                                                                im_xml_size  = xml_size ).
    CATCH cx_swf_utl_obj_create_failed INTO DATA(lx_obj_create).
      DATA(lo_stack_trace) = cl_swf_utl_stack_trace=>get_instance_for_event( iv_sender      = sender
                                                                             iv_event       = event
                                                                             iv_rectype     = rectype
                                                                             iv_method_name = 'SWW_WI_CREATE_VIA_EVENT_IBF'
                                                                             io_exception   = lx_obj_create ) ##NO_TEXT.
      lo_stack_trace->write( ).
      DATA(ls_message) = VALUE swr_mstruc( msgid = 'WL' msgty = 'E' msgno = '669' msgv1 = swfco_no_id ) ##NO_TEXT.
      IF exceptions_allowed NE space.
        MESSAGE ID ls_message-msgid TYPE ls_message-msgty NUMBER ls_message-msgno WITH ls_message-msgv1 RAISING read_failed.
      ELSE.
        CALL METHOD cl_swf_evt_services=>event_handler_error
          EXPORTING
            im_objcateg          = sender-catid
            im_rectype           = rectype
            im_objtype           = sender-typeid
            im_objkey            = sender-instid
            im_event             = event
            im_message           = ls_message
            im_send_notification = 'X'
            im_do_commit         = 'X'
            im_xml_size          = xml_size
            im_xml_container     = event_container.
        EXIT.
      ENDIF.
    CATCH cx_swf_utl_no_instance_found .
      DATA(ls_log_status) = VALUE ty_log_status(
        name = 'CONTAINER_CREATE_FAILED'
        time = sy-timlo
        zonlo = sy-zonlo
        duration = lo_timer->get_runtime( )
        langu = sy-langu
        excp_name = 'CX_SWF_UTL_NO_INSTANCE_FOUND'
      ) ##NO_TEXT.
      LOG-POINT ID wf_workitem_execute SUBKEY lv_log_subkey FIELDS ls_log_status.
  ENDTRY.

  TRY.
      CALL FUNCTION 'SWW_WI_CREATE_VIA_EVENT_INTERN'
        EXPORTING
          sender                 = sender
          event                  = event
          rectype                = rectype
          handler                = handler
          event_container_handle = lo_event_container
        IMPORTING
          result                 = result.
      LOG-POINT ID wf_workitem_create SUBKEY lv_log_subkey FIELDS VALUE ty_log_status( name = 'END' time = sy-timlo zonlo = sy-zonlo duration = lo_timer->get_runtime( ) langu = sy-langu ) result.
    CATCH cx_swf_ifs_exception INTO DATA(lx_ifs).
      lo_stack_trace = cl_swf_utl_stack_trace=>get_instance_for_event( iv_sender      = sender
                                                                       iv_event       = event
                                                                       iv_rectype     = rectype
                                                                       iv_method_name = 'SWW_WI_CREATE_VIA_EVENT_IBF'
                                                                       io_exception   = lx_ifs ).
      lo_stack_trace->write( ).
      DATA(lo_type) = cl_swf_utl_type_descriptor=>get_instance_by_handle( lx_ifs ).
*     --- try to get error information ---
      DATA(ls_t100_msg) = lx_ifs->get_t100_message( ).

      DATA(lv_log_status) = VALUE ty_log_status(
             name = 'CX_SWF_IFS_EXCEPTION'
             time = sy-timlo
             zonlo = sy-zonlo
             duration = lo_timer->get_runtime( )
             langu = sy-langu
             excp_name = lo_type->get_type_name( )
             excp_t100msg = lx_ifs->t100_msg
      ).
      LOG-POINT ID wf_workitem_execute SUBKEY lv_log_subkey FIELDS lv_log_status.
      IF exceptions_allowed NE space.
        MESSAGE ID ls_t100_msg-msgid TYPE 'E' NUMBER ls_t100_msg-msgno
                WITH ls_t100_msg-msgv1 ls_t100_msg-msgv2 ls_t100_msg-msgv3 ls_t100_msg-msgv4
                RAISING read_failed.
      ELSE.
        CALL FUNCTION 'SWW_EVENT_RECEIVE_ERROR_SIGNAL'
          EXPORTING
            object                 = sender
            event                  = event
            rectype                = CONV swe_rectyp( rectype )
            msgid                  = ls_t100_msg-msgid
            msgv1                  = ls_t100_msg-msgv1
            msgv2                  = ls_t100_msg-msgv2
            msgv3                  = ls_t100_msg-msgv3
            msgv4                  = ls_t100_msg-msgv4
            msgno                  = ls_t100_msg-msgno
            event_container_handle = lo_event_container.
      ENDIF.
  ENDTRY.

ENDFUNCTION.
