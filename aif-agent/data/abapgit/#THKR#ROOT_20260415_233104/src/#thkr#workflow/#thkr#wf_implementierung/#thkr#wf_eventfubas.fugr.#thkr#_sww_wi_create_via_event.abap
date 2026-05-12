FUNCTION /thkr/_sww_wi_create_via_event.
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
  CONSTANTS lc_00_00_15 TYPE sy-uzeit VALUE '000015'.
  CONSTANTS lc_15_00_00 TYPE sy-uzeit VALUE '160000'.

  DATA lv_bupa TYPE bu_partner.
  DATA lt_bpkind TYPE /thkr/tt_bu_bpkind.
  DATA lt_bpgroup TYPE /thkr/tt_bu_bpgroup.

  DATA lv_bpkind TYPE bu_bpkind.
  DATA lv_group TYPE bu_group.

  DATA lv_us_usname TYPE swp_initia.
  DATA lc_us_sapwfrt TYPE swp_initia VALUE 'USSAP_WFRT'.
  DATA lt_worklist TYPE STANDARD TABLE OF swr_wihdr.
  DATA ls_creator TYPE swhactor.
  DATA lt_felder_4ap TYPE STANDARD TABLE OF /thkr/cbpwfstart.
  DATA ls_felder_4ap TYPE /thkr/cbpwfstart.
  DATA lt_update_fields TYPE STANDARD TABLE OF /THKR/cbactfield.
  DATA ls_update_fields TYPE /THKR/cbactfield.
  DATA lv_4ap_needed TYPE abap_bool.
  DATA lt_cdhdr TYPE STANDARD TABLE OF cdhdr.
  DATA ls_cdhdr TYPE cdhdr.
  DATA lt_cdpos TYPE STANDARD TABLE OF cdpos.
  DATA ls_cdpos TYPE cdpos.
  DATA lv_yesterday TYPE sy-datum.
  DATA lv_15_sec_ago TYPE sy-uzeit.
  DATA lt_change_doc_timezone TYPE STANDARD TABLE OF /THKR/cbpwfchgdc.
  DATA lv_time_stamp TYPE timestamp.
  DATA lv_time_stamp_now_utc TYPE timestamp.
  DATA: lv_date TYPE d.
  DATA: lv_time TYPE t.
  DATA: lv_date_now_utc TYPE d.
  DATA: lv_time_now_utc TYPE t.
  DATA: lt_ret type STANDARD TABLE OF BAPIRET2.


  "Wenn das Event von SAP_WFRT erzeugt wurde, dann ignoriere das Event.

  IF line_exists( event_container[ element = '_EVT_CREATOR' ] ).
    lv_us_usname = event_container[ element = '_EVT_CREATOR' ]-value.
    ls_creator-otype = lv_us_usname(2).
    ls_creator-objid = lv_us_usname+2(12).
    IF lc_us_sapwfrt = lv_us_usname.
      EXIT.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'SAP_WAPI_WORKITEMS_TO_OBJECT'
    EXPORTING
*     OBJECT_POR               =
      objtype                  = objtype
      objkey                   = objkey
      top_level_items          = 'X'
      selection_status_variant = 0003
*     TIME                     =
*     TEXT                     = 'X'
*     OUTPUT_ONLY_TOP_LEVEL    = ' '
*     LANGUAGE                 = SY-LANGU
*     DETERMINE_TASK_FILTER    = 'X'
*     REMOVED_OBJECTS          = ' '
*   IMPORTING
*     RETURN_CODE              =
    TABLES
*     TASK_FILTER              =
      worklist                 = lt_worklist
*     MESSAGE_LINES            =
*     MESSAGE_STRUCT           =
    .
  IF lt_worklist IS NOT INITIAL.

    CALL FUNCTION 'SWE_EVENT_CREATE'
      EXPORTING
        objtype              = objtype
        objkey               = objkey
        event                = 'zrestarted'
        creator              = ls_creator
        start_recfb_synchron = 'X'
      EXCEPTIONS
        objtype_not_found    = 1
        OTHERS               = 2.

    EXIT.
  ENDIF.


*  IF sy-uname = 'SAP_WFRT'.
*    EXIT.
*  ENDIF.

* gegen Ausschluss prüfen

  CALL METHOD /thkr/cl_wf_bupa=>get_ausnahmen
    IMPORTING
      et_bpkind  = lt_bpkind
      et_bpgroup = lt_bpgroup.
  .

  IF lt_bpkind IS NOT INITIAL OR lt_bpgroup IS NOT INITIAL.

    lv_bupa = objkey.
    SELECT SINGLE bpkind, bu_group
      FROM but000
          WHERE partner = @lv_bupa
        INTO  ( @lv_bpkind, @lv_group ).


    READ TABLE lt_bpkind WITH KEY bpkind = lv_bpkind TRANSPORTING NO FIELDS .
    IF sy-subrc = 0.
      EXIT.
    ENDIF.
    READ TABLE lt_bpgroup WITH KEY Bp_GROUP = lv_group TRANSPORTING NO FIELDS .
    IF sy-subrc = 0.
      EXIT.
    ENDIF.
  ENDIF.
*EXIT.
**  "Auslesen der Änderungsbelege für EVENT CHANGED
**  "FRAGE: Muss diese Änderung freigegeben werden?
**  """"""""""""""""""""""""""""""""""""""""""""""""""
**

  GET TIME STAMP FIELD lv_time_stamp_now_utc.
    CONVERT TIME STAMP lv_time_stamp_now_utc TIME ZONE 'UTC'
    INTO DATE lv_date_now_utc TIME lv_time_now_utc.
    lv_15_sec_ago = lv_time_now_utc - 15.
DO 10 TIMES.
  DATA: lv_partner_4_lock type bu_partner.
    Move objkey to lv_partner_4_lock.
    CALL FUNCTION 'BUPA_ENQUEUE'
     EXPORTING
       IV_PARTNER                = lv_partner_4_lock
*       IV_PARTNER_GUID           =
*       IV_CHECK_NOT_NUMBER       =
*       IV_REQ_BLK_MSG            =
      TABLES
        et_return                 = lt_ret
     EXCEPTIONS
       BLOCKED_PARTNER           = 1
       OTHERS                    = 2
              .
    IF sy-subrc = 0.
      EXIT.
    ENDIF.

    CALL FUNCTION 'ENQUE_SLEEP'
      EXPORTING
        seconds              = 1
     EXCEPTIONS
       SYSTEM_FAILURE       = 1
       OTHERS               = 2
              .
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    ENDDO.

  IF event CP 'CHANGED'.
    "Lese Customizingtabelle aus.
    SELECT * FROM /thkr/cbpwfstart INTO TABLE lt_felder_4ap.
    if sy-subrc = 0.
    SELECT * FROM /thkr/cbactfield INTO TABLE lt_update_fields.
    SELECT * FROM /THKR/cbpwfchgdc INTO TABLE lt_change_doc_timezone.
    "Hilfsvariablen füllen
    lv_yesterday = sy-datum - 1.
    """"""""
    "TimeStamp bauen
    """"""""
    "Warte 3 Sekunden
    Wait UP TO 3 SECONDS.

    "Lese alle Änderungsbelegköpfe von heute und von gestern ab 11:59:45 aus
    "für alle definierten Änderungsbelege in unserer Customizingtabelle
    SELECT * FROM cdhdr INTO TABLE @lt_cdhdr
      FOR ALL ENTRIES IN @lt_felder_4ap
      WHERE objectclas = @lt_felder_4ap-object
*        AND objectid = @objkey
      AND ( udate = @sy-datum OR
      udate = @lv_yesterday AND utime >= @lc_15_00_00 )
      AND username = @ls_creator-objid .
    "Es wurde mindestens ein Änderungsbeleg gefunden
    IF sy-subrc = 0.
      LOOP AT lt_cdhdr ASSIGNING FIELD-SYMBOL(<fs_cd_time>).

        READ TABLE lt_change_doc_timezone WITH KEY object = <fs_cd_time>-objectclas
        ASSIGNING FIELD-SYMBOL(<fs_time_zone>).
        IF sy-subrc = 0.
          IF <fs_time_zone>-time_zone = 'UTC'.
            CONTINUE.
          ENDIF.

          CONVERT DATE <fs_cd_time>-udate TIME <fs_cd_time>-utime
          INTO TIME STAMP lv_time_stamp TIME ZONE <fs_time_zone>-time_zone.

          CONVERT TIME STAMP lv_time_stamp TIME ZONE 'UTC'
          INTO DATE <fs_cd_time>-udate TIME <fs_cd_time>-utime.
          "Wenn kein Eintrag gefunden, dann gehen wir davon aus,
          "dass der Beleg in CET geschrieben wird.
         ELSE.
           CONVERT DATE <fs_cd_time>-udate TIME <fs_cd_time>-utime
          INTO TIME STAMP lv_time_stamp TIME ZONE 'CET'.

          CONVERT TIME STAMP lv_time_stamp TIME ZONE 'UTC'
          INTO DATE <fs_cd_time>-udate TIME <fs_cd_time>-utime.
        ENDIF.

      ENDLOOP.
      "Sortieren der Daten und ermitteln der neuesten Änderung
      SORT lt_cdhdr BY udate DESCENDING utime DESCENDING.
      READ TABLE lt_cdhdr INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_newest_change>).
      IF sy-subrc = 0.
        "Wenn die Änderung nach 00:00:15 geschehen ist, dann
        "lösche alle Datensätze von gestern und alle Datensätze von heute,
        "die älter als 15 Sekunden sind
        IF <fs_newest_change>-utime => lc_00_00_15.
          DELETE lt_cdhdr WHERE udate = lv_yesterday OR
          ( udate = sy-datum AND utime < lv_15_sec_ago ) .
          "Ansonsten lösche alle Datensätze, die älter als 15 Sekunden sind und somit
          "gestern geschehen sind.
        ELSE.
          DELETE lt_cdhdr WHERE udate = lv_yesterday AND utime < lv_15_sec_ago.
        ENDIF.
        "Wenn noch mindestens eine Änderung da ist, dann mach weiter.
        IF lines( lt_cdhdr ) => 1.
          "Auslesen aller Änderungsbelegpositionen zu unseren Änderungsbelegköpfen
          SELECT * FROM cdpos INTO TABLE @lt_cdpos
            FOR ALL ENTRIES IN @lt_cdhdr
            WHERE objectclas = @lt_cdhdr-objectclas
            AND objectid = @lt_cdhdr-objectid
            AND changenr = @lt_cdhdr-changenr.
          IF sy-subrc = 0.

*              "Erst alle Tabellen verpoben, bei den ein Insert wichtig ist
            LOOP AT lt_felder_4ap ASSIGNING FIELD-SYMBOL(<fs_felder>)
              WHERE aktion = 'I' OR aktion = 'D'.
*
              READ TABLE lt_cdpos ASSIGNING FIELD-SYMBOL(<fs_cdpos>)
              WITH KEY objectclas = <fs_felder>-object
              tabname = <fs_felder>-tabname
              fname = 'KEY'
              chngind = <fs_felder>-aktion.
              IF sy-subrc = 0.
                lv_4ap_needed = 'X'.
                EXIT.
              ENDIF.
            ENDLOOP.
            "      wenn noch kein Feld gefunden wurde, dann mach weiter.

            "wenn noch kein Feld gefunden wurde, dann mach weiter
            IF lv_4ap_needed IS INITIAL.
              "Jetzt alle Tabellen prüfen, bei denen ein Update wichtig ist. Dafür
              "verwenden wir die zweite Schicht der Tabelle
              LOOP AT lt_felder_4ap ASSIGNING <fs_felder>
             WHERE aktion = 'U' OR aktion = 'E' OR aktion = 'J'.
                "Alle Felder prüfen, egal was für eine Änderung
                LOOP AT lt_update_fields ASSIGNING FIELD-SYMBOL(<fs_upd_fields>) WHERE
                  object = <fs_felder>-object AND
                  tabname = <fs_felder>-tabname AND
                  aktion = <fs_felder>-aktion.

                  READ TABLE lt_cdpos ASSIGNING <fs_cdpos>
                 WITH KEY objectclas = <fs_upd_fields>-object
                 tabname = <fs_upd_fields>-tabname
                 fname = <fs_upd_fields>-fieldname
                 chngind = <fs_upd_fields>-aktion.
                  IF sy-subrc = 0.
                    IF <fs_upd_fields>-only_fill IS INITIAL
                      AND <fs_upd_fields>-only_clear IS INITIAL.
                      lv_4ap_needed = 'X'.
                      EXIT.
                    ELSEIF <fs_upd_fields>-only_fill IS NOT INITIAL
                      AND <fs_upd_fields>-only_clear IS INITIAL AND
                      <fs_cdpos>-value_old IS INITIAL AND
                      <fs_cdpos>-value_new IS NOT INITIAL.
                      lv_4ap_needed = 'X'.
                      EXIT.
                    ELSEIF <fs_upd_fields>-only_fill IS INITIAL
                      AND <fs_upd_fields>-only_clear IS NOT INITIAL AND
                      <fs_cdpos>-value_old IS NOT INITIAL AND
                      <fs_cdpos>-value_new IS INITIAL.
                      lv_4ap_needed = 'X'.
                      EXIT.
                    ENDIF.
                  ENDIF.
                ENDLOOP.

                IF lv_4ap_needed IS NOT INITIAL.
                  EXIT.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    "Wenn keine Einträge gefunden, dann müssen alle Änderungen freigegeben werden.
  ELSE.
    lv_4ap_needed = 'X'.
  ENDIF.
  IF lv_4ap_needed IS INITIAL.
    CALL FUNCTION 'BUPA_DEQUEUE'
     EXPORTING
       IV_PARTNER                = lv_partner_4_lock
*       IV_PARTNER_GUID           =
*       IV_CHECK_NOT_NUMBER       =
*       IV_REQ_BLK_MSG            =
      TABLES
        et_return                 = lt_ret
     EXCEPTIONS
       BLOCKED_PARTNER           = 1
       OTHERS                    = 2
              .
    EXIT.
  ENDIF.
ENDIF.
*  """"""""""""""""""""""""""""""""""""""""""""""""""
"Kurz warten, um Sperre von Transaktion BP zu vermeiden
WAIT UP TO 3 SECONDS.

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
