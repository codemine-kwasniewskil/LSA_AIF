*----------------------------------------------------------------------*
***INCLUDE /THKR/LEA_FORMSO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module /THKR/EDIT_FORM_ABS_PBO OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE /thkr/edit_form_abs_pbo OUTPUT.
  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'ZZORT' OR 'ZZKOP' OR 'ZZADR' OR 'ZZRUE' OR 'ZZFUS'.
        screen-input = 1.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module /THKR/EDIT_FO_TB_TEXT_PBO OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE /thkr/edit_fo_tb_text_pbo OUTPUT.
  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'ZZTEXT'.
        screen-input = 1.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.
