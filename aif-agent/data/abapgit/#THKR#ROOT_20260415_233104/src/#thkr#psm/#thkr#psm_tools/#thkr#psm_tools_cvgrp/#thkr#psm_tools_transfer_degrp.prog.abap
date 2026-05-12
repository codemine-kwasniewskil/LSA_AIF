*&---------------------------------------------------------------------*
*& Report /THKR/TOOLS_TRANSFER_DEGRP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/psm_tools_transfer_degrp.
DATA: lv_cgaddrind TYPE fmce_cgaddrind.

SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE TEXT-001.
  SELECTION-SCREEN : BEGIN OF LINE.
    PARAMETERS: p_dwn  RADIOBUTTON GROUP rbg DEFAULT 'X' USER-COMMAND flag.
    SELECTION-SCREEN COMMENT 03(10) TEXT-s11.
    SELECTION-SCREEN POSITION 15.
    PARAMETERS: p_up  RADIOBUTTON GROUP rbg.
    SELECTION-SCREEN COMMENT 17(10) TEXT-s12.
  SELECTION-SCREEN : END OF LINE.
  SELECTION-SCREEN : BEGIN OF LINE .
    PARAMETERS: p_ful  RADIOBUTTON GROUP rb2 DEFAULT 'X' USER-COMMAND flag MODIF ID bl1.
    SELECTION-SCREEN COMMENT 03(10) TEXT-s21 MODIF ID bl1.
    SELECTION-SCREEN POSITION 15.
    PARAMETERS: p_prt  RADIOBUTTON GROUP rb2 MODIF ID bl1.
    SELECTION-SCREEN COMMENT 17(10) TEXT-s22 MODIF ID bl1.
  SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN END OF BLOCK part1.

SELECTION-SCREEN BEGIN OF BLOCK part1a WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_fikrs TYPE fikrs  DEFAULT '1000' MODIF ID bl2
             ,p_gjahr TYPE gjahr  DEFAULT '2025' MODIF ID bl2
             ,p_led   TYPE bubas_ldnr            MODIF ID bl2
             ,p_cvg   TYPE fmce_cvrgrp           MODIF ID bl2.
  SELECT-OPTIONS: s_cgadd FOR lv_cgaddrind MODIF ID bl2.
SELECTION-SCREEN END OF BLOCK part1a.

SELECTION-SCREEN BEGIN OF BLOCK part1b WITH FRAME TITLE TEXT-003.
  PARAMETERS: p_dgtyp TYPE fmce_cgautoind DEFAULT 'R' MODIF ID bl3.
SELECTION-SCREEN END OF BLOCK part1b.

SELECTION-SCREEN BEGIN OF BLOCK part2 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_path TYPE string.
SELECTION-SCREEN END OF BLOCK part2.

SELECTION-SCREEN BEGIN OF BLOCK part3 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_test TYPE xflag DEFAULT 'X' AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK part3.

INITIALIZATION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  TRY.
      CASE abap_true.
        WHEN p_dwn. "" Download process
          p_path = /thkr/cl_report_file_helper=>gui_download_dialog( |DeckungsGrp_{ sy-datum }_{ sy-uzeit }.txt| ).
        WHEN p_up. "" Upload Process
          p_path = /thkr/cl_report_file_helper=>gui_upload_dialog( ).
      ENDCASE.
    CATCH /thkr/cx_report_file_helper INTO DATA(err). " Exception Class
* "" Just an empty path
  ENDTRY.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'BL1'. " show/hide full/partly
        screen-active = COND #( WHEN p_dwn = abap_true THEN '1' ELSE '0' ).
      WHEN 'BL2'. " show/hide cover ggp details
        screen-active = COND #( WHEN p_dwn = abap_true AND p_prt = abap_true THEN '1' ELSE '0' ).
      WHEN 'BL3'. " show/hide cover ggp type
        screen-active = COND #( WHEN p_dwn = abap_true AND p_prt = abap_false THEN '1' ELSE '0' ).
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

START-OF-SELECTION.

  IF p_path IS NOT INITIAL.
    DATA(cvgrp_helper) = NEW /thkr/cl_psm_degrp_helper( p_test ).
    TRY.
        CASE abap_true.
          WHEN p_dwn. "" Download process
            IF p_ful = abap_true. "" Download complete
              CLEAR: s_cgadd[].
              DATA(cvgrps_data) = cvgrp_helper->get_all_covergrps( cvgrp_type = p_dgtyp it_so_cgaddrind = s_cgadd[] ).
            ELSE. "" Download single
              IF p_fikrs IS INITIAL OR p_gjahr IS INITIAL OR p_led IS INITIAL OR p_cvg IS INITIAL.
                MESSAGE 'Bitte alle Felder füllen' TYPE 'S' DISPLAY LIKE 'E'.
              ELSE.
                cvgrps_data = VALUE #( ( cvgrp_helper->get_covergrp( fm_area = p_fikrs fiscyear = p_gjahr ledger = p_led cvgrp = p_cvg it_so_cgaddrind = s_cgadd[] ) ) ).
              ENDIF.
            ENDIF.
            IF cvgrps_data IS NOT INITIAL.
              DATA(json) = /ui2/cl_json=>serialize( data = cvgrps_data pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
              /thkr/cl_report_file_helper=>gui_ascii_download( filepath = p_path data_tab = VALUE #( ( json ) ) ).
            ENDIF.
          WHEN p_up. "" Upload Process
            DATA(uploaded_data) = /thkr/cl_report_file_helper=>gui_ascii_upload( filepath = p_path ).
            DATA cvgrps_from_json TYPE /thkr/psm_deckgrps_transfer.
            /ui2/cl_json=>deserialize( EXPORTING json        = uploaded_data[ 1 ]
                                                 pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                       CHANGING  data        = cvgrps_from_json ).
            cvgrp_helper->set_covergrps( cvgrps_from_json ).
        ENDCASE.
      CATCH  /thkr/cx_psm_tools INTO DATA(err). " Exception Class
        DATA resultlist TYPE /thkr/psm_tool_results.
        IF err->bapiret2_tab IS NOT INITIAL.
          LOOP AT err->bapiret2_tab INTO DATA(ret).
            MESSAGE ID ret-id TYPE ret-type NUMBER ret-number WITH  ret-message_v1 ret-message_v2 ret-message_v3 ret-message_v4 INTO DATA(msgtext).
            resultlist = VALUE #( BASE resultlist (
                                  type    = ret-type
                                  message = msgtext
                                  light   = COND #(
                                  WHEN ret-type = 'E' THEN '@0A@'   "RED
                                  WHEN ret-type CA 'IW' THEN '@09@'                  "YELLOW
                                  ELSE '@08@' ) ) ).                                 "GREEN
          ENDLOOP.
          TRY.
              cl_salv_table=>factory( IMPORTING r_salv_table = DATA(salv)
                                      CHANGING  t_table      = resultlist ).
              DATA(header) = COND #( WHEN p_test = abap_true THEN ' - TESTMODE -' ).
              salv->get_display_settings( )->set_list_header( |Upload Deckungsgruppe { header }| ).
              salv->get_display_settings( )->set_striped_pattern( abap_true ).
              salv->get_functions( )->set_all( abap_true ).
              salv->get_columns( )->set_optimize( abap_true ).
              salv->display( ).

            CATCH cx_salv_error INTO DATA(alverr).
              MESSAGE alverr->get_text( ) TYPE 'E'.
          ENDTRY.
        ENDIF.
      CATCH /thkr/cx_report_file_helper  INTO DATA(err2).
        MESSAGE err2->get_text( ) TYPE 'I' DISPLAY LIKE 'I'.
    ENDTRY.
  ELSE.
    MESSAGE 'Bitte einen Pfad angeben' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
