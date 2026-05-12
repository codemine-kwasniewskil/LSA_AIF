*&---------------------------------------------------------------------*
*& Report /THKR/CO_ANLAGE_STAMMDATEN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/co_anlage_stammdaten.

************************************************************************
* Anlegen von Stammdaten für Kostenstelle, Aufträgen und stat.Kennzahlen
* aufgrund von einzulesenden SST-Dateien.
************************************************************************

TYPES: BEGIN OF ty_kst,
         kokrs        TYPE  kokrs,
         kostenstelle TYPE  kostl,
         gueltig_von  TYPE  datab,
         gueltig_bis  TYPE  datbi,
         bezeichnung  TYPE  ktext,
         beschreibung TYPE  kltxt,
         verantw      TYPE  verak,
         kst_art      TYPE  kosar,
         hierarchie   TYPE  khinr,
         bukrs        TYPE  bukrs,
         gsber        TYPE  gsber,
         waehrung     TYPE  waers,
         profitcenter TYPE  prctr,
         verb_menge   TYPE  mgefl,
         priko_ist    TYPE  bkzkp,
         priko_plan   TYPE  pkzkp,
         sekko_ist    TYPE  bkzks,
         sekko_plan   TYPE  pkzks,
         erloese_ist  TYPE  bkzer,
         erloese_plan TYPE  pkzer,
         obligo       TYPE  bkzob,
       END OF ty_kst.

DATA: gv_datei     TYPE string,
      gt_daten_kst TYPE TABLE OF /thkr/co_sst_kst,
      gt_daten_auf TYPE TABLE OF /thkr/co_sst_auftrag,
      gt_daten_stk TYPE TABLE OF /thkr/co_sst_stk.

data: gv_art(3)    type c,
      gv_rc(1)     TYPE c.



PARAMETERS: p_file  TYPE string OBLIGATORY.
PARAMETERS: p_simu(1) default 'X'.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  PERFORM get_filename CHANGING p_file.

************************************************************************
START-OF-SELECTION.

  WRITE: / 'Datei', p_file, 'wird verarbeitet.' .
  WRITE: /.

* trennen von Pfad und Dateiname
  CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
    EXPORTING
      full_name     = p_file
    IMPORTING
      stripped_name = gv_datei
    EXCEPTIONS
      x_error       = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    WRITE: / 'Dateiname aus', p_file, 'konnte nicht ermittelt werden.' COLOR 3.
    WRITE: /.
    EXIT.
  ELSE.
    IF NOT ( gv_datei(3) CP 'KST' OR gv_datei(3) CP 'AUF' OR gv_datei(3) CP 'STK' ).
      WRITE: / 'Dateiname', gv_datei, 'entspricht nicht der Vorgabe.' COLOR 3.
      WRITE: / 'Dateiname muss mit KST, AUF oder STK beginnen.' .
      WRITE: /.

      EXIT.
    ENDIF.
  ENDIF.

  gv_art = gv_datei(3).

* Einlesen der Datei und die Daten in die entsprechende Tabelle schreiben
  CALL METHOD /thkr/cl_co_anlage_stammdaten=>datei_einlesen
    EXPORTING
      i_dateiname = p_file
      i_art       = gv_art
    IMPORTING
      e_daten_kst = gt_daten_kst
      e_daten_auf = gt_daten_auf
      e_daten_stk = gt_daten_stk
      e_rc        = gv_rc.


* Prüfen und anlegen der CO-Stammdaten (KST, AUF und STK)
CASE gv_art.
  WHEN 'KST'.

    CALL METHOD /thkr/cl_co_anlage_stammdaten=>kst_anlegen
      EXPORTING
        i_daten_kst = gt_daten_kst
        i_simu      = p_simu .

  WHEN 'AUF'.

    CALL METHOD /thkr/cl_co_anlage_stammdaten=>auftrag_anlegen
      EXPORTING
        i_daten_auf = gt_daten_auf
        i_simu      = p_simu  .

  WHEN 'STK'.

    CALL METHOD /thkr/cl_co_anlage_stammdaten=>stk_anlegen
      EXPORTING
        i_daten_stk = gt_daten_stk
        i_simu      = p_simu.

  WHEN OTHERS.
ENDCASE.


****************************************************************************

FORM get_filename CHANGING cf_filename TYPE string.

  DATA:
    lt_filetable TYPE filetable,
    ls_filetable TYPE file_table,
    lf_action    TYPE i,
    lf_return    TYPE i.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
*     window_title            =
      default_extension       = 'CSV'
      file_filter             = '*.CSV'
      multiselection          = 'X'
*     with_encoding           =
    CHANGING
      file_table              = lt_filetable
      rc                      = lf_return
      user_action             = lf_action
*     file_encoding           =
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    " error handling
    MESSAGE ID   sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.
  " OK => use filename
  IF    lf_action = cl_gui_frontend_services=>action_ok
    AND lf_return = 1.
*     Determine file name
    READ TABLE lt_filetable INTO ls_filetable INDEX 1.
    IF sy-subrc IS INITIAL.
*       take over file name
      cf_filename = ls_filetable-filename.
    ENDIF.
  ENDIF.

ENDFORM.                    " get_filename
