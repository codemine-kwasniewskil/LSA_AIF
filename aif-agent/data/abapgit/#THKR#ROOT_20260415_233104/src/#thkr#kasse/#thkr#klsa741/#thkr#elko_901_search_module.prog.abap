*&---------------------------------------------------------------------*
*& Include          /THKR/ELKO_901_SEARCH_MODULE
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
 MODULE status_0100 OUTPUT.
   SET PF-STATUS 'SCREEN_0100'.
   SET TITLEBAR  'SCREEN_0100'.
 ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  init_processing  OUTPUT
*&---------------------------------------------------------------------*
 MODULE init_processing_0100 OUTPUT.
   DATA: ls_disvar   TYPE disvariant,
         lt_fieldcat TYPE lvc_t_fcat,
         ls_variant  TYPE slis_vari.

   IF gt_ausgabe IS INITIAL.
     MESSAGE e000 WITH TEXT-004.
     LEAVE SCREEN.

   ENDIF.

   IF     gr_cont IS INITIAL   AND
     NOT gt_ausgabe IS INITIAL.
     IF sy-batch EQ abap_false.
       CREATE OBJECT gr_cont
         EXPORTING
           container_name = 'CONTAINER1'.
     ENDIF.

     CREATE OBJECT gr_alv
       EXPORTING
         i_parent = gr_cont.

     ls_disvar-report   = sy-cprog.
     ls_disvar-variant  = '/RG'.

     IF pa_layo IS NOT INITIAL.
       ls_disvar-variant = pa_layo.
     ELSE.
       ls_disvar-variant = '/STANDARD'.
     ENDIF.

     SET HANDLER lcl_eventhandler=>on_double_click     FOR gr_alv.

     PERFORM fieldcat_init CHANGING lt_fieldcat.

     SORT gt_ausgabe BY kukey kwbtr DESCENDING.

     CALL METHOD gr_alv->set_table_for_first_display
       EXPORTING
         i_structure_name = '/THKR/TS_901_SEARCH'
         is_variant       = ls_disvar
         i_save           = 'X'
         i_default        = 'X'
       CHANGING
         it_fieldcatalog  = lt_fieldcat
         it_outtab        = gt_ausgabe.
   ENDIF.

 ENDMODULE.                 " init_processing  OUTPUT

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
 ENDMODULE.                 " USER_COMMAND_0100  INPUT
