*&---------------------------------------------------------------------*
*& Report /THKR/CHANGE_GRPNR_IN_FEBEP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/change_grpnr_in_febep.
DATA: gs_febep TYPE febep.
DATA: ok_code  TYPE ok_code.
* Zeiger
DATA: gr_cont TYPE REF TO cl_gui_custom_container,
      gr_alv  TYPE REF TO cl_gui_alv_grid.


SELECTION-SCREEN BEGIN OF BLOCK 1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_kukey FOR gs_febep-kukey,
                  s_esnum FOR gs_febep-esnum.
SELECTION-SCREEN END OF BLOCK 1.

SELECTION-SCREEN BEGIN OF BLOCK 2 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_test AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK 2.


START-OF-SELECTION.
  SELECT * FROM febep INTO TABLE @DATA(lt_febep)
    WHERE kukey IN @s_kukey
      AND esnum IN @s_esnum
      AND zz_iban NE @space.

  LOOP AT lt_febep ASSIGNING FIELD-SYMBOL(<ls_febep>).
    CALL METHOD /thkr/cl_elko_appl=>set_iban_2_into_grpnr
      CHANGING
        xs_febep = <ls_febep>.
  ENDLOOP.

END-OF-SELECTION.

  IF p_test IS  INITIAL.
    IF lt_febep IS NOT INITIAL.
      MODIFY febep FROM TABLE lt_febep.
    ENDIF.
  ENDIF.

  CALL SCREEN '0100'.
  CLEAR: lt_febep.


*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*

MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR  '0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'BACK' OR
         'EXIT' OR
         'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module INIT_PROCESSING_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE init_processing_0100 OUTPUT.
  IF gr_cont IS INITIAL   AND
     lt_febep IS NOT INITIAL.
    IF sy-batch EQ abap_false.
      CREATE OBJECT gr_cont
        EXPORTING
          container_name = 'CONTAINER1'.
    ENDIF.

    CREATE OBJECT gr_alv
      EXPORTING
        i_parent = gr_cont.



    CALL METHOD gr_alv->set_table_for_first_display
      EXPORTING
        i_structure_name = 'FEBEP'
      CHANGING
        it_outtab        = lt_febep.
  ENDIF.
ENDMODULE.
