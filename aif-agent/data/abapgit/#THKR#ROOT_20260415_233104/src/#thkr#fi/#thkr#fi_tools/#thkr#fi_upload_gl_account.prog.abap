*&---------------------------------------------------------------------*
*& Report /thkr/FI_UPLOAD_GL_ACCOUNT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/fi_upload_gl_account.

SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_bukrs TYPE bukrs OBLIGATORY DEFAULT 'ZZ99'.
  PARAMETERS: p_pathl TYPE ibipparms-path OBLIGATORY.
  SELECTION-SCREEN : BEGIN OF LINE.
    PARAMETERS: p_ins RADIOBUTTON GROUP rbg DEFAULT 'X'.SELECTION-SCREEN COMMENT 03(10) text-s11. SELECTION-SCREEN POSITION 15.
    PARAMETERS: p_chg RADIOBUTTON GROUP rbg. SELECTION-SCREEN COMMENT 17(10) text-s12.
  SELECTION-SCREEN : END OF LINE.
  PARAMETERS: p_test  TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
  PARAMETERS: p_eonly  TYPE abap_bool AS CHECKBOX.
  SELECTION-SCREEN COMMENT /1(79) comm1.
  SELECTION-SCREEN COMMENT /1(79) comm2.
  SELECTION-SCREEN COMMENT /1(79) comm3.
  SELECTION-SCREEN COMMENT /1(79) comm4.
SELECTION-SCREEN END OF BLOCK part1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pathl.
  DATA: lv_rc TYPE i.
  DATA: lt_file_table TYPE filetable.
  cl_gui_frontend_services=>file_open_dialog( EXPORTING window_title = 'Select a file'
                                              CHANGING  file_table   = lt_file_table
                                                        rc           = lv_rc ).
  IF lv_rc <> -1.
    TRY.
        p_pathl = lt_file_table[ 1 ]-filename .
      CATCH cx_sy_itab_line_not_found.
        MESSAGE i001(/thkr/fi_init) DISPLAY LIKE 'E'.
        EXIT.
    ENDTRY.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  comm1 = 'Die Exceldatei sollte folgenden Aufbau haben:'.
  comm2 = 'Zeile 1 + 2: Frei wählbar, Überschriften'.
  comm3 = 'Zeile 3:     Technischer Feldname z.B. KTOPL,SAKRN'.
  comm4 = 'Zeile 4..x:  Sachkontendefinition'.


START-OF-SELECTION.

  TRY.
      NEW /thkr/cl_fi_upload_gl_account( )->process( bukrs    = p_bukrs
                                                    path     = CONV string( p_pathl )
                                                    testmode = p_test
                                                    mode     = COND #( WHEN p_ins = abap_true THEN /thkr/cl_fi_upload_gl_account=>insert
                                                                                              ELSE /thkr/cl_fi_upload_gl_account=>change  ) ).
    CATCH /thkr/cx_fi_init INTO DATA(err). " Fehlerkasse Init.
      LOOP AT err->bapiret2_tab INTO DATA(bapiret2).
        CHECK p_eonly = abap_false OR bapiret2-type = 'E'.
        WRITE: |Type { bapiret2-type }: { bapiret2-message } |. NEW-LINE.
      ENDLOOP.
  ENDTRY.
