*----------------------------------------------------------------------*
***INCLUDE /THKR/LEA_FORMSI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  /THKR/EDIT_FORM_ABS_TEXT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE /thkr/edit_form_abs_text INPUT.
  PERFORM /thkr/edit_fo_abs_text.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  /THKR/EDIT_FO_TB_TEXT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE /thkr/edit_fo_tb_text INPUT.
  PERFORM /thkr/edit_fo_tb_text.
ENDMODULE.

*&---------------------------------------------------------------------*
FORM /thkr/edit_fo_abs_text .
  DATA: ls_header TYPE thead,
        lt_tlines TYPE TABLE OF tline,
        lv_field  TYPE string,
        lv_value  TYPE string,
        lv_line   TYPE i,
        oref      TYPE REF TO cx_root,
        text      TYPE string.

  CLEAR: lv_field, lv_value, lv_line, ls_header.

  CASE ok_code.
    WHEN 'ZZORT' OR 'ZZKOP' OR 'ZZADR' OR 'ZZRUE' OR 'ZZFUS'.
      GET CURSOR FIELD  lv_field
                 VALUE  lv_value
                 LINE   lv_line.
* Cursor auslesen --> Topline + gewählte Zeile (-1)
      lv_line = tctrl_/thkr/ea_fo_abs-top_line + lv_line - 1.
* ausgewählte Zeile lesen
      READ TABLE extract INTO extract INDEX lv_line.
      IF sy-subrc EQ 0.
        /thkr/ea_fo_abs = extract.
* Text übernehmen
        ls_header-tdobject = 'TEXT'.
        CASE ok_code.
          WHEN 'ZZORT'.
            ls_header-tdname   =  /thkr/ea_fo_abs-txnam_ort.
          WHEN 'ZZKOP'.
            ls_header-tdname   =  /thkr/ea_fo_abs-txnam_kop.
          WHEN 'ZZADR'.
            ls_header-tdname   =  /thkr/ea_fo_abs-txnam_adr.
          WHEN 'ZZRUE'.
            ls_header-tdname   =  /thkr/ea_fo_abs-txnam_rue.
          WHEN 'ZZFUS'.
            ls_header-tdname   =  /thkr/ea_fo_abs-txnam_fus.
        ENDCASE.
* Text ID vorbelegen falls leer
        ls_header-tdid     =  /thkr/ea_fo_abs-tdid .
        IF ls_header-tdid  IS INITIAL.
          ls_header-tdid = 'FIKO'.
        ENDIF.
* Sprache vorhanden
        ls_header-tdspras  =  /thkr/ea_fo_abs-tdspras .
        IF ls_header-tdspras IS INITIAL.
          ls_header-tdspras = sy-langu.
        ENDIF.
* Textname prüfen
        IF NOT ls_header-tdname IS INITIAL.
          TRY.
* Text anlegen/ändern im Dialog
              CALL FUNCTION 'TEXT_EDIT'
                EXPORTING
                  i_header = ls_header
                TABLES
                  t_lines  = lt_tlines.
* Exception abfangen
            CATCH cx_root INTO oref.
              text = oref->get_text( ).
          ENDTRY.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ZZ_EDIT_FO_TB_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM /thkr/edit_fo_tb_text .

  DATA: ls_header TYPE thead,
        lt_tlines TYPE TABLE OF tline,
        lv_field  TYPE string,
        lv_value  TYPE string,
        lv_line   TYPE i,
        oref      TYPE REF TO cx_root,
        text      TYPE string.

  CLEAR: lv_field, lv_value, lv_line, ls_header.

  IF ok_code IS INITIAL AND function ='ZZTEXT'.

    GET CURSOR FIELD  lv_field
               VALUE  lv_value
               LINE   lv_line.
* Cursor auslesen --> Topline + gewählte Zeile (-1)
    lv_line = tctrl_/thkr/ea_fo_tb-top_line + lv_line - 1.
* ausgewählte Zeile lesen
    READ TABLE extract INTO extract INDEX lv_line.
    IF sy-subrc EQ 0.
      /thkr/ea_fo_tb = extract.
* Text übernehmen
      ls_header-tdobject = 'TEXT'.
      ls_header-tdname   =  /thkr/ea_fo_tb-tdname.
* Text ID vorbelegen falls leer
      ls_header-tdid     =  /thkr/ea_fo_tb-tdid .
      IF ls_header-tdid  IS INITIAL.
        ls_header-tdid = 'FIKO'.
      ENDIF.
* Sprache vorhanden
      ls_header-tdspras  =  /thkr/ea_fo_tb-tdspras .
      IF ls_header-tdspras IS INITIAL.
        ls_header-tdspras = sy-langu.
      ENDIF.
* Textname prüfen
      IF NOT /thkr/ea_fo_tb-tdname IS INITIAL.
        TRY.
* Text anlegen/ändern im Dialog
            CALL FUNCTION 'TEXT_EDIT'
              EXPORTING
                i_header = ls_header
              TABLES
                t_lines  = lt_tlines.
* Exception abfangen
          CATCH cx_root INTO oref.
            text = oref->get_text( ).
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.
