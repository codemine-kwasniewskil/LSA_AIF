*&---------------------------------------------------------------------*
*& Include          /THKR/WF_BP_SPERRVERW_F01
*&---------------------------------------------------------------------*

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
* FORM get_bp
* Funktion: Diese Routine liest alle Geschäftspartner aus der Tabelle
* BUT000, welche sich in der Selektionsmenge auf dem Eingabefeld befinden.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM get_bp.

  CLEAR gt_bp.

  SELECT partner FROM but000
    INTO TABLE gt_bp
    WHERE partner IN so_bp.

  IF sy-subrc <> 0.

    MESSAGE 'Es konnte kein Geschäftspartner gefunden werden!' TYPE 'S' DISPLAY LIKE 'E'.
    GV_FEHlER = 'X'.
  ELSE.

    SORT gt_bp ASCENDING.
  ENDIF.

ENDFORM.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
* FORM process
* Funktion: Diese Routine steutert den Prozess in das Entsperren oder
* Sperren der Geschäftspartner. Außerdem füllt es das Log für den Testmodus
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM process.

  IF pa_test IS INITIAL.

    IF pa_sperr IS NOT INITIAL.

      PERFORM sperren.

    ELSEIF pa_entsp IS NOT INITIAL.

      PERFORM entsperren.

    ENDIF.

       COMMIT WORK.

  ELSE.

    LOOP AT gt_bp ASSIGNING <gf_bp>.

      gs_log-partner = <gf_bp>.
      IF pa_gp IS NOT INITIAL.
        gs_log-gp = 'X'.
      ENDIF.
      IF pa_kred IS NOT INITIAL.
        gs_log-kred = 'X'.
      ENDIF.
      IF pa_debi IS NOT INITIAL.
        gs_log-debi = 'X'.
      ENDIF.
      APPEND gs_log TO gt_log.
      CLEAR gs_log.

    ENDLOOP.

  ENDIF.



ENDFORM.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
* FORM sperren
* Funktion: Hier werden die Geschäftspartner entsprechend der Selektion
* gesperrt.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM sperren.
  DATA: lt_return TYPE bapiret2_t.

  LOOP AT gt_bp ASSIGNING <gf_bp>.
    gs_log-partner = <gf_bp>.
    "Geschäftspartner sperren
    IF pa_gp IS NOT INITIAL.

      CALL METHOD /thkr/cl_wf_bupa=>nonreleasekennz_exxen
        EXPORTING
          iv_businesspartner = <gf_bp>
        IMPORTING
          et_return          = lt_return.
      gs_log-gp = 'X'.
    ENDIF.
    "Debitor sperren
    IF pa_debi IS NOT INITIAL.
      CALL METHOD /thkr/cl_wf_bupa=>kna_sperre_exxen
        EXPORTING
          iv_businesspartner = <gf_bp>.
      gs_log-debi = 'X'.
    ENDIF.
    "Kreditor sperren
    IF pa_kred IS NOT INITIAL.

      CALL METHOD /thkr/cl_wf_bupa=>lfa_sperre_exxen
        EXPORTING
          iv_businesspartner = <gf_bp>.
      gs_log-kred = 'X'.
    ENDIF.

    APPEND gs_log TO gt_log.
    CLEAR gs_log.
  ENDLOOP.


ENDFORM.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
* FORM entsperren
* Funktion: Hier werden die Geschäftspartner entsprechend der Selektion
* entsperrt.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM entsperren.
  DATA: lt_return TYPE bapiret2_t.

  LOOP AT gt_bp ASSIGNING <gf_bp>.
    gs_log-partner = <gf_bp>.
    "Geschäftspartner entsperren
    IF pa_gp IS NOT INITIAL.

      CALL METHOD /thkr/cl_wf_bupa=>nonreleasekennz_entexxen
        EXPORTING
          iv_businesspartner = <gf_bp>
        IMPORTING
          et_return          = lt_return.
      gs_log-gp = 'X'.
    ENDIF.
    "Debitor entsperren
    IF pa_debi IS NOT INITIAL.
      CALL METHOD /thkr/cl_wf_bupa=>kna_sperreentexxen
        EXPORTING
          iv_businesspartner = <gf_bp>.
      gs_log-debi = 'X'.
    ENDIF.
    "Kreditor entsperren
    IF pa_kred IS NOT INITIAL.

      CALL METHOD /thkr/cl_wf_bupa=>lfa_sperreentexxen
        EXPORTING
          iv_businesspartner = <gf_bp>.
      gs_log-kred = 'X'.
    ENDIF.

    APPEND gs_log TO gt_log.
    CLEAR gs_log.
  ENDLOOP.

ENDFORM.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
* FORM show_log
* Funktion: Hier wird das Protokoll ausgegeben.
*
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM show_log.

  DATA: lo_alv       TYPE REF TO cl_salv_table,
        lo_functions TYPE REF TO cl_salv_functions_list,
        lo_columns   TYPE REF TO cl_salv_columns_table,
        lo_display   TYPE REF TO cl_salv_display_settings,
        lv_title     TYPE lvc_title.

*-----------------------------------------------------------------------
  IF gt_log IS NOT INITIAL.

* Instanz der Klasse cl_salv_table erzeugen
    cl_salv_table=>factory(
      IMPORTING r_salv_table = lo_alv
      CHANGING t_table = gt_log ).

* Funktionstasten (Sortieren, Filtern, Excel-Export etc.)
    lo_functions = lo_alv->get_functions( ).
    lo_functions->set_all( abap_true ).

* optimale Spaltenbreite
    lo_columns = lo_alv->get_columns( ).
    lo_columns->set_optimize( abap_true ).

* Titel und/oder Streifenmuster
    lo_display = lo_alv->get_display_settings( ).
    IF pa_sperr IS NOT INITIAL.
      lv_title = 'Protokoll: Sperren'.
    ELSEIF pa_entsp IS NOT INITIAL.
      lv_title = 'Protokoll: Entsperren'.
    ENDIF.
    lo_display->set_list_header( value = lv_title ).

* Liste anzeigen
    lo_alv->display( ).

  ENDIF.
ENDFORM.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
* FORM clear
* Funktion: Hier werden alle globalen Datenspeicher geleert.
*
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
FORM clear.

  CLEAR: gt_log,
         gs_log,
         gt_bp,
         gv_bp,
         gv_fehler.

ENDFORM.
