*&---------------------------------------------------------------------*
*& Include          /THKR/GP_CHANGE_GSBER_SCR
*&---------------------------------------------------------------------*

************************************************************************
* Selektionsbildschirm                                                 *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE a1_titel.
  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN: BEGIN OF BLOCK b1.
    PARAMETERS: p_file TYPE string LOWER CASE,
                p_head TYPE xchar AS CHECKBOX DEFAULT 'X'.
  SELECTION-SCREEN: END OF BLOCK b1.
  SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF BLOCK a1.

************************************************************************
* Wertehilfe: Datei auswählen                                          *
************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title      = 'Select CSV File'
      default_extension = '*.csv'
      file_filter       = 'CSV-Dateien (*.csv)|*.csv|'
      multiselection    = abap_false
    CHANGING
      file_table        = gt_filetable
      rc                = gv_rc.
  IF sy-subrc <> 0.
    MESSAGE 'Fehler in Dateiauswahl'
    TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.
  IF gt_filetable IS NOT INITIAL.
    READ TABLE gt_filetable INDEX 1 INTO DATA(gs_filetable).
    p_file = gs_filetable-filename.
  ENDIF.
