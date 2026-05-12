FUNCTION /thkr/wf_aord_create_via_event.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(EVENT) LIKE  SWETYPECOU-EVENT
*"     VALUE(RECTYPE) LIKE  SWETYPECOU-RECTYPE
*"     VALUE(OBJTYPE) LIKE  SWETYPECOU-OBJTYPE
*"     VALUE(OBJKEY) LIKE  SWEINSTCOU-OBJKEY
*"     VALUE(EXCEPTIONS_ALLOWED) LIKE  SWEFLAGS-EXC_OK DEFAULT SPACE
*"  EXPORTING
*"     VALUE(REC_ID) LIKE  SWELOG-RECID
*"  TABLES
*"      EVENT_CONTAINER STRUCTURE  SWCONT
*"  EXCEPTIONS
*"      READ_FAILED
*"      CREATE_FAILED
*"----------------------------------------------------------------------
  DATA lc_us_sapwfrt TYPE swp_initia VALUE 'USSAP_WFRT'.
  DATA lv_us_usname TYPE swp_initia.
  DATA ls_creator TYPE swhactor.
  DATA lv_uname TYPE uname.

  IF line_exists( event_container[ element = '_EVT_CREATOR' ] ).
    lv_us_usname = event_container[ element = '_EVT_CREATOR' ]-value.
    ls_creator-otype = lv_us_usname(2).
    ls_creator-objid = lv_us_usname+2(12).
    IF lc_us_sapwfrt = lv_us_usname.
      EXIT.
    ENDIF.
    IF ls_creator-objid IS NOT INITIAL.
      SELECT SINGLE uname FROM /thkr/cwfaosstus
      INTO lv_uname WHERE uname = ls_creator-objid.
      IF sy-subrc = 0.
        EXIT.
      ENDIF.
    ENDIF.

  ENDIF.

  DATA(lo_timer) = cl_abap_runtime=>create_lr_timer( ).
  lo_timer->get_runtime( ).
  DATA(lv_log_subkey) = 'EVT_' && objtype && '_' && event && '_' && objkey && '_' && rectype.
  LOG-POINT ID wf_workitem_create SUBKEY lv_log_subkey FIELDS VALUE ty_log_status( name = 'START' time = sy-timlo zonlo = sy-zonlo langu = sy-langu ).

  TRY.
      DATA(ls_sender) = VALUE sibflporb( catid  = swfco_objtype_bor typeid = objtype instid = objkey ).
      DATA(lo_event_container) = cl_swf_cnt_factory=>create_from_bor_container( EXPORTING im_values   = CONV swconttab( event_container[] ) ).
    CATCH cx_swf_utl_obj_create_failed INTO DATA(lx_obj_create).
      DATA(lo_stack_trace) = cl_swf_utl_stack_trace=>get_instance_for_event( iv_sender      = ls_sender
                                                                             iv_event       = event
                                                                             iv_rectype     = CONV swferectyp( rectype )
                                                                             iv_method_name = 'SWW_WI_CREATE_VIA_EVENT'
                                                                             io_exception   = lx_obj_create ) ##NO_TEXT.
      lo_stack_trace->write( ).
      DATA(ls_message) = VALUE swr_mstruc( msgid = 'WL' msgty = 'E' msgno = '599' ) ##NO_TEXT.
      IF exceptions_allowed NE space.
        MESSAGE ID ls_message-msgid TYPE ls_message-msgty NUMBER ls_message-msgno RAISING read_failed.
      ELSE.
        CALL METHOD cl_swf_evt_services=>event_handler_error
          EXPORTING
            im_objcateg          = ls_sender-catid
            im_rectype           = CONV swferectyp( rectype )
            im_objtype           = ls_sender-typeid
            im_objkey            = ls_sender-instid
            im_event             = event
            im_message           = ls_message
            im_send_notification = 'X'
            im_do_commit         = 'X'
            im_bor_container     = CONV swconttab( event_container[] ).
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
      DATA ls_result TYPE swfrevrslt.
      CALL FUNCTION 'SWW_WI_CREATE_VIA_EVENT_INTERN'
        EXPORTING
          sender                 = ls_sender
          event                  = event
          rectype                = CONV swferectyp( rectype )
          handler                = VALUE sibflporb( )
          event_container_handle = lo_event_container
        IMPORTING
          result                 = ls_result.
      rec_id = ls_result-handler-instid.
      LOG-POINT ID wf_workitem_create SUBKEY lv_log_subkey FIELDS VALUE ty_log_status( name = 'END' time = sy-timlo zonlo = sy-zonlo duration = lo_timer->get_runtime( ) langu = sy-langu ) ls_result.
    CATCH cx_swf_ifs_exception INTO DATA(lx_ifs).
      lo_stack_trace = cl_swf_utl_stack_trace=>get_instance_for_event( iv_sender      = ls_sender
                                                                       iv_event       = event
                                                                       iv_rectype     = CONV swferectyp( rectype )
                                                                       iv_method_name = 'SWW_WI_CREATE_VIA_EVENT'
                                                                       io_exception   = lx_ifs ) ##NO_TEXT.
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
            object                 = ls_sender
            event                  = event
            rectype                = rectype
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
