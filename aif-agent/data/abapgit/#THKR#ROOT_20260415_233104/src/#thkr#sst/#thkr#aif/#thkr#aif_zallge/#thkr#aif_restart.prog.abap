*&---------------------------------------------------------------------*
*& Report /THKR/AIF_RESTART
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/aif_restart.

DATA: go_reproc         TYPE REF TO /thkr/cl_aif_reproc.
DATA: gr_appl_engine    TYPE REF TO /aif/if_application_engine.
DATA: gr_lfa_enabler    TYPE REF TO /aif/cl_lfa_enabler.
DATA: gs_pers_queue_key TYPE /aif/pers_s_queue_key.
DATA: gs_xmlparse       TYPE /aif/xmlparse_data.
DATA: gt_return         TYPE bapiret2_tt.
DATA: lv_lines          TYPE i.
DATA: lv_key1           TYPE rsecadmval.
DATA: lv_sel_type       TYPE char1.
DATA: cr_queue          TYPE REF TO /aif/cl_pers_queue.
DATA: lv_msgid          TYPE /aif/sxmssmguid .
DATA: lx_exc            TYPE REF TO cx_root.
DATA: lt_msg            TYPE /aif/tt_msgguid.
DATA: lv_status         TYPE /aif/pers_qmsg_status.
DATA: lv_error          TYPE abap_bool.
DATA: lv_jobcount       TYPE tbtcjob-jobcount.
DATA: lv_released       TYPE btch0000-char1.
DATA: lv_return         TYPE i.
DATA: lt_seltab         TYPE STANDARD TABLE OF rsparams .
DATA: lv_resend_msg     TYPE flag.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.
  PARAMETERS: p_ns  TYPE /aif/ns OBLIGATORY.
  PARAMETERS: p_ifname TYPE /aif/ifname OBLIGATORY.
  PARAMETERS: p_ifvers TYPE /aif/ifversion OBLIGATORY.
  PARAMETERS: p_msg    TYPE /aif/sxmssmguid.
  PARAMETERS: p_in_pro AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b01.
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-t02.
  PARAMETERS: p_struc  TYPE typename OBLIGATORY.
  PARAMETERS: p_lines  RADIOBUTTON GROUP so.
  SELECT-OPTIONS: so_lines FOR lv_lines.
  PARAMETERS: p_keys  RADIOBUTTON GROUP so.
  PARAMETERS: p_key1 TYPE /cpd/pws_mp_itm_okey.
  SELECT-OPTIONS: so_key1 FOR lv_key1.
  PARAMETERS: p_key2 TYPE /cpd/pws_mp_itm_okey.
  SELECT-OPTIONS: so_key2 FOR lv_key1.
  PARAMETERS: p_key3 TYPE /cpd/pws_mp_itm_okey.
  SELECT-OPTIONS: so_key3 FOR lv_key1.
SELECTION-SCREEN END OF BLOCK b02.
SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-t03.
  PARAMETERS: p_show AS CHECKBOX.
  PARAMETERS: p_sh_f AS CHECKBOX.
  PARAMETERS: p_sh_s AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b03.
SELECTION-SCREEN BEGIN OF BLOCK b04 WITH FRAME TITLE TEXT-t04.
  PARAMETERS: p_batch AS CHECKBOX DEFAULT abap_true.
  PARAMETERS: p_jobnam TYPE tbtcjob-jobname DEFAULT 'AIF_RESTART_MSGS'.
  PARAMETERS: p_qns  TYPE /aif/pers_rtcfgr_ns DEFAULT 'FREMDV'.
  PARAMETERS: p_qname  TYPE /aif/pers_rtcfgr_name DEFAULT 'REP'.
  PARAMETERS: p_user  TYPE sy-uname OBLIGATORY.
  PARAMETERS: p_cancl  AS CHECKBOX.
  PARAMETERS: p_trans AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b04.

START-OF-SELECTION.

  CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
    EXPORTING
      curr_report     = sy-cprog
*     IMPORTING
*     SP              =
    TABLES
      selection_table = lt_seltab[]
*     SELECTION_TABLE_255       =
    EXCEPTIONS
      not_found       = 1
      no_report       = 2
      OTHERS          = 3.


  "Der Report läuft online
  "Soll aber einen Hintergrundprozess starten.
  "Der Hintergrundprozess wird für den Schnittstellenuser benötigt.
  IF p_batch = abap_true AND sy-batch = abap_false.
    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = p_jobnam
        jobclass         = 'A'
      IMPORTING
        jobcount         = lv_jobcount
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.


    SUBMIT (sy-cprog) WITH SELECTION-TABLE lt_seltab VIA JOB p_jobnam NUMBER lv_jobcount USER p_user AND RETURN .

    IF sy-subrc = 0.

      CALL FUNCTION 'JOB_CLOSE'
        EXPORTING
          jobcount             = lv_jobcount
          jobname              = p_jobnam
          strtimmed            = 'X'
*         sdlstrtdt            = lv_startdate
*         sdlstrttm            = lv_starttime
        IMPORTING
          job_was_released     = lv_released
        CHANGING
          ret                  = lv_return
        EXCEPTIONS
          cant_start_immediate = 1
          invalid_startdate    = 2
          jobname_missing      = 3
          job_close_failed     = 4
          job_nosteps          = 5
          job_notex            = 6
          lock_failed          = 7
          invalid_target       = 8
          OTHERS               = 9.
    ENDIF.
  ELSE.
    TRY.
        go_reproc = NEW /thkr/cl_aif_reproc( ).
        "Nachrichteneigenschaften setzen
        "Wird benötigt, um die Single-Index-Tabelle zu ermitteln.
        go_reproc->set_aif_properties(
          iv_ns       = p_ns                 " Namensraum
          iv_ifname   = p_ifname                " Schnittstellenname
          iv_ifvers   = p_ifvers                 " Schnittstellenversion
          iv_msg_guid = p_msg                " Einzelne Nachrichten-ID
        ).

        "alle fehlerhaften Nachrichten zur Schnittstelle ermitteln
        lt_msg = go_reproc->get_failed_msgs_for_interface(
                         EXPORTING
                           iv_msg_guid   = p_msg                 " Globally Unique Identifier
                           iv_msg_in_process = p_in_pro
                         CHANGING
                           ct_return_tab = gt_return                 " Returntabelle
                       ).


        LOOP AT lt_msg ASSIGNING FIELD-SYMBOL(<ls_msg>).
          IF 1 = 0.MESSAGE i111(/thkr/sst) WITH <ls_msg>. ENDIF.
          APPEND VALUE bapiret2( id = '/THKR/SST'
                                 number = 111
                                 type = 'I'
                                 message_v1 = <ls_msg> ) TO gt_return.

          "Nachrichteneigenschaften setzen, die während des Prozesses immer wieder gebraucht werden
          "zum Beispiel für die Findung der Single-Index-Tabelle
          "das Auslesen der Nachricht.
          go_reproc->set_aif_properties(
            iv_ns       = p_ns                 " Namensraum
            iv_ifname   = p_ifname                " Schnittstellenname
            iv_ifvers   = p_ifvers                 " Schnittstellenversion
            iv_msg_guid = CONV /aif/sxmssmguid( <ls_msg> )                " Einzelne Nachrichten-ID
          ).
          "Neustart nur beginnen, wenn die Nachricht auch Fehler enthält.
          "Abgebrochene oder erfolgreich verarbeitete Nachrichten können nicht neu gestartet werden
          IF go_reproc->check_aif_message_status(
               EXPORTING
                 iv_msg_in_process = p_in_pro
               IMPORTING
                 et_return = gt_return
             ) = abap_true.
            gs_xmlparse = go_reproc->get_aif_message( ).
            ASSIGN gs_xmlparse-xi_data->* TO FIELD-SYMBOL(<ls_data>).

            lv_sel_type = go_reproc->set_sel_typye(
                            iv_lines = p_lines                 " allgemeines flag
                            iv_keys  = p_keys                 " allgemeines flag
                          ).

            "Origialnachricht auf die Fehlerhaften Daten beschränken
            "Zum einen durch Eingabe der Zeilennummer oder des Schlüssels
            "zum anderen durch Abgleich mit Objektschlüsselstatus über /THRK/T_AIF_OBJ
            "lv_resend_msg legt fest, ob eine Nachricht fachlich nochmal wiederverarbeitet werden darf.
            "Das muss pro Nachicht neu entschieden werden.
            CLEAR: lv_resend_msg.
            go_reproc->reduce_message(
              EXPORTING
                iv_struc       = p_struc                 " Name des Dictionary Typs
                iv_sel_type    = lv_sel_type
                it_sel_lines   = so_lines[]
                iv_sel_keyname1 = CONV string( p_key1 )
                it_sel_keys1    = so_key1[]
                iv_sel_keyname2 = CONV string( p_key2 )
                it_sel_keys2    = so_key2[]
                iv_sel_keyname3 = CONV string( p_key3 )
                it_sel_keys3    = so_key3[]
              CHANGING
                cv_resend_message = lv_resend_msg
                cs_data = <ls_data>
                ct_return = gt_return
            ).

            APPEND VALUE #( msg_guid_old = <ls_msg>
                  msg_content = gs_xmlparse-xi_data ) TO go_reproc->mt_msg_for_prot.

            IF p_trans = abap_true AND lv_resend_msg = abap_true.

              go_reproc->update_pers_cgr(
                EXPORTING
                  iv_user   = p_user                 " Hintergrundbenutzername für Berechtigungsprüfung
                  iv_qns    = p_qns                 " Persistenz: Namensraum der Laufzeit-Konfigurationsgruppe
                  iv_qname  = p_qname                 " ID der Laufzeit-Konfigurationsgruppe
                CHANGING
                  ct_return = gt_return
              ).

              CLEAR gs_pers_queue_key.
              gs_pers_queue_key-queue_ns = p_qns.
              gs_pers_queue_key-queue_name = p_qname.

              TRY.
                  CLEAR gr_lfa_enabler.
                  gr_lfa_enabler = /aif/cl_lfa_enabler=>create_instance( is_pers_queue_key = gs_pers_queue_key ).
                CATCH cx_root INTO DATA(lr_root).
                  /aif/cl_lfa_error_collection=>add_exception_static( EXPORTING
                                                                        ir_exception = lr_root
                                                                      CHANGING
                                                                        ct_errors    = gt_return ).
                  /aif/cl_util=>show_messages( it_message = gt_return ).
                  LEAVE LIST-PROCESSING.
              ENDTRY.
              gr_lfa_enabler->start( IMPORTING
                             ev_error   = lv_error
                           CHANGING
                             ct_bapiret = gt_return ).
              IF lv_error = abap_true.
                /aif/cl_util=>show_messages( it_message = gt_return ).
                LEAVE LIST-PROCESSING.
              ENDIF.
              TRY.
                  gr_lfa_enabler->transfer_to_aif( EXPORTING
                                                   is_any_structure = <ls_data>
                                                 IMPORTING
                                                   ev_msgguid       = lv_msgid ).
                CATCH cx_root INTO lr_root.
                  /aif/cl_lfa_error_collection=>add_exception_static( EXPORTING
                                                                        ir_exception = lr_root
                                                                      CHANGING
                                                                        ct_errors    = gt_return ).

              ENDTRY.

              gr_lfa_enabler->end( CHANGING
                       ct_bapiret = gt_return ).
              go_reproc->mt_msg_for_prot[ msg_guid_old = <ls_msg> ]-msg_guid_new = lv_msgid.


            ELSE.
              IF 1 = 0.MESSAGE i106(/thkr/sst). ENDIF.
              APPEND VALUE bapiret2( id = '/THKR/SST'
                                     number = 106
                                     type = 'I') TO gt_return.
            ENDIF.

          ENDIF.
          IF 1 = 0.MESSAGE i112(/thkr/sst) WITH <ls_msg>. ENDIF.
          APPEND VALUE bapiret2( id = '/THKR/SST'
                                 number = 112
                                 type = 'I'
                                 message_v1 = <ls_msg> ) TO gt_return.
        ENDLOOP.

        IF p_cancl = abap_true.
          "alte Nachrichten löschen
          LOOP AT go_reproc->mt_msg_for_prot ASSIGNING FIELD-SYMBOL(<ls_cancel_msg>) WHERE msg_guid_new IS NOT INITIAL.

            TRY.
                go_reproc->cancel_old_message( iv_msg_guid = <ls_cancel_msg>-msg_guid_old  ).
                IF 1 = 0. MESSAGE i107(/thkr/sst) WITH  <ls_msg>. ENDIF.
                APPEND VALUE bapiret2( id = '/THKR/SST'
                                       number = 107
                                       type = 'I'
                                       message_v1 = <ls_msg> ) TO gt_return.
              CATCH /aif/cx_error_handling_general INTO lx_exc.
              CATCH /aif/cx_message_statistics INTO lx_exc.
                APPEND VALUE bapiret2( id = '/THKR/SST'
                                       number = 001
                                       type = 'E'
                                       message_v1 = lx_exc->get_text( ) ) TO gt_return.

            ENDTRY.

          ENDLOOP.
        ELSE.
          IF 1 = 0. MESSAGE i108(/thkr/sst) WITH <ls_msg>. ENDIF.
          APPEND VALUE bapiret2( id = '/THKR/SST'
                                 number = 108
                                 type = 'I'
                                 message_v1 = <ls_msg> ) TO gt_return.
        ENDIF.

      CATCH /aif/cx_inf_det_base INTO lx_exc.
      CATCH /aif/cx_enabler_base INTO lx_exc.
      CATCH /aif/cx_aif_engine_not_found INTO lx_exc.
      CATCH /aif/cx_error_handling_general INTO lx_exc.
      CATCH /aif/cx_aif_engine_base INTO lx_exc.
      CATCH /aif/cx_message_statistics INTO lx_exc.
        APPEND VALUE bapiret2( id = '/THKR/SST'
                               number = 001
                               type = 'E'
                               message_v1 = lx_exc->get_text( ) ) TO gt_return.

    ENDTRY.
  ENDIF.

END-OF-SELECTION.

  IF go_reproc IS NOT INITIAL.
    IF p_show = abap_true.
      go_reproc->show_reduced_message(
        iv_show_struc  = p_sh_s                 " allgemeines flag
        iv_show_fields = p_sh_f                 " allgemeines flag
      ).
    ENDIF.

    NEW-PAGE.
    WRITE: 'Protokoll'.
    ULINE.
    LOOP AT go_reproc->mt_msg_for_prot ASSIGNING FIELD-SYMBOL(<msgs>).
      IF 1 = 0. MESSAGE i110(/thkr/sst) WITH <msgs>-msg_guid_old <msgs>-msg_guid_new.ENDIF.
      MESSAGE ID '/THKR/SST' TYPE 'I' NUMBER 110 WITH <msgs>-msg_guid_old <msgs>-msg_guid_new INTO DATA(lv_message).
      WRITE: lv_message.
      NEW-LINE.
    ENDLOOP.
    DELETE ADJACENT DUPLICATES FROM gt_return.
    LOOP AT gt_return ASSIGNING FIELD-SYMBOL(<gs_return>).
      MESSAGE ID <gs_return>-id TYPE <gs_return>-type NUMBER <gs_return>-number WITH <gs_return>-message_v1 <gs_return>-message_v2 <gs_return>-message_v3 <gs_return>-message_v4 INTO lv_message.
      WRITE: lv_message.
      NEW-LINE.
    ENDLOOP.
    ULINE.
  ELSE.

    WRITE: 'Programm im Hintergund ausgeführt. Bitte Spoolliste prüfen.'.
  ENDIF.
