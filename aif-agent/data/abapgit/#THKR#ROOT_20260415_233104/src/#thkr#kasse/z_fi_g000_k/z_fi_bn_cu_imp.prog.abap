*&---------------------------------------------------------------------*
*& Report Z_FI_BN_CU_IMP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_fi_bn_cu_imp MESSAGE-ID z_fi_nachr.

* Globale Daten
DATA: lv_file_path  TYPE dxfields-longpath,
      lv_search_dir TYPE dxfields-longpath,
      lv_server     TYPE msxxlist-name,
      lv_locflag    TYPE dxfields-location,
      lv_kzdata     TYPE char01.

DATA: lo_oerror   TYPE REF TO cx_root,
      lo_fi_err   TYPE REF TO zcx_fi_gen,
      lo_fi_appl  TYPE REF TO zcl_fi_appl,
      lv_txterror TYPE string.

***********************************************************
* Selektionsbild
***********************************************************

SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME TITLE TEXT-b01.
SELECTION-SCREEN BEGIN OF BLOCK 004 WITH FRAME TITLE TEXT-b04.
PARAMETERS: p_ftxt    TYPE c RADIOBUTTON GROUP art DEFAULT 'X'.
PARAMETERS: p_empf    TYPE c RADIOBUTTON GROUP art.
PARAMETERS: p_aktn    TYPE c RADIOBUTTON GROUP art.
SELECTION-SCREEN END OF BLOCK 004.
SELECTION-SCREEN BEGIN OF BLOCK 003 WITH FRAME TITLE TEXT-b03.
PARAMETERS: p_fnampc  LIKE dxfields-longpath LOWER CASE.
SELECTION-SCREEN END OF BLOCK 003.
SELECTION-SCREEN BEGIN OF BLOCK 002 WITH FRAME TITLE TEXT-b02.
PARAMETERS: p_fnamap  LIKE dxfields-longpath LOWER CASE.
SELECTION-SCREEN END OF BLOCK 002.
SELECTION-SCREEN END OF BLOCK 001.


***********************************************************
* File vom Applikationsserver
***********************************************************

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fnamap.

  lv_locflag = 'A'.
  lv_search_dir = '/usr/sap/tmp'.


  CALL FUNCTION 'F4_DXFILENAME_TOPRECURSION'
    EXPORTING
      i_location_flag = lv_locflag
      i_server        = ' '
      i_path          = lv_search_dir
    IMPORTING
      o_path          = lv_file_path
    EXCEPTIONS
      rfc_error       = 1
      OTHERS          = 2.
  IF sy-subrc EQ 0.
    p_fnamap = lv_file_path.
  ENDIF.

***********************************************************
* File vom Präsentationsserver (PC)
***********************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fnampc.

  lv_locflag = 'P'.
  lv_search_dir = 'C:\Users\Krebs\Documents\TPK_DATA'.

  CALL FUNCTION 'F4_DXFILENAME_TOPRECURSION'
    EXPORTING
      i_location_flag = lv_locflag
      i_server        = ' '
      i_path          = lv_search_dir
    IMPORTING
      o_path          = lv_file_path
    EXCEPTIONS
      rfc_error       = 1
      OTHERS          = 2.
  IF sy-subrc EQ 0.
    p_fnampc = lv_file_path.
  ENDIF.

************************************************************
START-OF-SELECTION.
************************************************************

* AUTHORITY-CHECK OBJECT 'S_TCODE' ID 'TCD' FIELD ''.
*  IF sy-subrc <> 0.
*    MESSAGE e101(zbau_bw) WITH sy-cprog.
*  ENDIF.

  IF ( p_fnamap IS NOT INITIAL AND p_fnampc IS NOT INITIAL ) OR
     ( p_fnamap IS INITIAL AND p_fnampc IS INITIAL ).
    MESSAGE i202.
    EXIT.
  ENDIF.

  IF p_fnamap IS NOT INITIAL.
    lv_locflag = 'A'.
    lv_file_path = p_fnamap.
  ELSE.
    lv_locflag = 'P'.
    lv_file_path = p_fnampc.
  ENDIF.

  TRY.

      IF p_ftxt IS NOT INITIAL.
        lv_kzdata = 'F'.
      ELSEIF p_empf IS NOT INITIAL.
        lv_kzdata = 'E'.
      ELSEIF p_aktn IS NOT INITIAL.
        lv_kzdata = 'A'.
      ENDIF.

*      zcl_fi_appl=>get_instance( )->process_imp_data(
*        EXPORTING
*            i_location = lv_locflag
*            i_filepath = lv_file_path
*            i_kzdata   = lv_kzdata ).

    CATCH zcx_fi_gen INTO lo_fi_err.
      lv_txterror = lo_fi_err->get_text( ).
      MESSAGE lv_txterror TYPE 'E' DISPLAY LIKE 'I'.
      EXIT.

    CATCH cx_root INTO lo_oerror.
      lv_txterror = lo_oerror->get_text( ).
      IF sy-batch IS INITIAL.
        MESSAGE lv_txterror TYPE 'E' DISPLAY LIKE 'I'.
      ENDIF.

  ENDTRY.

  MESSAGE i201 WITH TEXT-end.
