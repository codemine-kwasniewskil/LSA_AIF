*&---------------------------------------------------------------------*
*& Report /THKR/MIG_EXT_IF_IMPORT (Vorlage)
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/mig_import.



TABLES: sscrfields.

DATA: gs_func TYPE smp_dyntxt.

DATA: gt_filetable TYPE filetable,
      gs_filetable TYPE file_table,
      g_retc       TYPE i,
      g_dir        TYPE string.

DATA: g_help_infos TYPE help_info.
DATA: g_xsel.
DATA: g_selvalue TYPE dynfieldvalue.
DATA: gt_dselc TYPE STANDARD TABLE OF dselc,
      gt_dval  TYPE STANDARD TABLE OF dval.
DATA: it_val TYPE vrm_values.



*----------------------------------------------------------------------*
SELECTION-SCREEN FUNCTION KEY 1.                               "Ablageverzeichnisse
SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_type   TYPE /thkr/process_type_mig AS LISTBOX VISIBLE LENGTH 30 OBLIGATORY USER-COMMAND refr,
              p_objekt TYPE /thkr/migrationsobjekt AS LISTBOX VISIBLE LENGTH 30 OBLIGATORY DEFAULT 'SSTE'  USER-COMMAND refr,
              p_update TYPE xfeld MODIF ID upd,
              p_epl    TYPE /thkr/mig_epl.

SELECTION-SCREEN END OF BLOCK 001.


SELECTION-SCREEN BEGIN OF BLOCK 004 WITH FRAME TITLE TEXT-004.
  PARAMETERS: p_fe     TYPE xfeld DEFAULT 'X' USER-COMMAND fe,
              p_tfile  TYPE /thkr/file_w_path LOWER CASE,
              p_archiv TYPE xfeld MODIF ID arc,
              p_afile  TYPE /thkr/file_w_path DEFAULT '/daten/migration/Daten/Archiv' MODIF ID arc,
              p_detail TYPE xfeld.


SELECTION-SCREEN END OF BLOCK 004.

*--------------------------------------------------------------------*
INITIALIZATION.
*--------------------------------------------------------------------*
  CLEAR: it_val.

* Domänenwerte holen
  cl_reca_ddic_doma=>get_values( EXPORTING id_name   = '/THKR/PROCESS_TYPE_MIG'
                                 IMPORTING et_values = DATA(it_dval) ).



  IF lines( it_dval ) > 0.
* wenn Werte vorhanden, dann Auswahlliste erstellen
    it_val = VALUE vrm_values( FOR v IN it_dval ( key  = v-domvalue_l
                                                  text = v-ddtext ) ).

* Auswahlliste setzen
    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = 'P_TYPE'
        values          = it_val
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.

    IF sy-subrc = 0.
* Vorselektion 'Punkt eins'
      p_type = it_val[ 1 ]-key.
    ENDIF.
  ENDIF.


*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*----------------------------------------------------------------------*
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'ARC'.
        " Wenn Frontende dann Archiv Ordner/Flag deaktivieren
        IF p_fe IS INITIAL.
          screen-input = 1.
        ELSE.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.

      WHEN 'UPD'.
        IF ( p_type = 'MIG_AO' AND ( p_objekt = 'IOS' OR p_objekt = 'VSA' ) )
            OR (  p_type = 'MIG_RK' AND p_objekt = 'RK' ).
          screen-active = 1.
          screen-input = 1.
        ELSE.
          screen-active = 0.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.

      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.


*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_type.
*----------------------------------------------------------------------*
  g_help_infos-call    = 'V'.
  g_help_infos-object  = 'F'.
  g_help_infos-program = 'RSSYSTDB'.
  g_help_infos-dynpro  = '1000'.
  g_help_infos-tabname = 'ZJVA_PROCESS_TYPE_I'.

  CALL FUNCTION 'DD_SHLP_CALL_FROM_DYNP'
    EXPORTING
      help_infos   = g_help_infos
    IMPORTING
      selection    = g_xsel
      select_value = g_selvalue
    TABLES
      dynpselect   = gt_dselc
      dynpvaluetab = gt_dval.


*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_tfile.
*----------------------------------------------------------------------*
  CLEAR: gt_filetable, g_retc.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      initial_directory       = CONV #( p_tfile ) "g_dir
    CHANGING
      file_table              = gt_filetable
      rc                      = g_retc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  READ TABLE gt_filetable INTO gs_filetable INDEX 1.
  IF sy-subrc EQ 0.
    p_tfile = gs_filetable-filename.
  ENDIF.


**----------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_afile.
**----------------------------------------------------------------------*



*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
********
  IF p_objekt EQ 'LIF' AND p_epl IS INITIAL.
    MESSAGE i029(/thkr/mig) DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF p_objekt EQ 'MVW' AND p_epl IS INITIAL.
    MESSAGE i029(/thkr/mig) DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

********
  IF p_tfile IS INITIAL.
    MESSAGE i020(/thkr/mig) DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF p_archiv = abap_true AND p_afile IS INITIAL.
    MESSAGE i021(/thkr/mig) DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  DATA(def) = /thkr/cl_mig_def=>get_instance( ).

  DATA(chk_upd) = xsdbool( p_update = 'X' AND p_type = 'MIG_AO' AND ( p_objekt = 'IOS' OR p_objekt = 'VSA' ) ).

  /thkr/cl_mig_appl=>get_instance( )->process_import(
      EXPORTING
        i_process_type    = p_type
        i_objekt_type     = p_objekt
        i_filename        = p_tfile
        i_frontend        = p_fe
        i_move_archiv     = p_archiv
        i_archiv_directory = p_afile
        i_epl             = p_epl
        i_prot_detail     = p_detail
        i_update_allowed  = p_update
        ).


* akt. Selektion der ComboBox heraussuchen
  TRY.
      DATA(s) = it_val[ key = p_type ].

      WRITE: / s-key, s-text.
    CATCH cx_root.
  ENDTRY.


  MESSAGE i000(/thkr/eif).
