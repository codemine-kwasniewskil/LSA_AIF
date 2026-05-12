*&---------------------------------------------------------------------*
*& Report /THKR/WF_CHECK_KOMPL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/WF_CHECK_KOMPL.

************************************************************************
*          Deklaration der Daten                                       *
************************************************************************
INCLUDE /THKR/WF_kompl_data.

************************************************************************
*            GUI mit Reitern(SELECTION-SCREEN)                         *
************************************************************************
* Definition der einzelnen Masken: 2*
SELECTION-SCREEN BEGIN OF SCREEN 1002  AS SUBSCREEN.
  PARAMETERS p_obj2 TYPE hrp1001-otype.
  SELECT-OPTIONS s_objid2   FOR hrp1001-objid.
  PARAMETERS: p_begda2 LIKE hrp1001-begda,
              p_endda2 LIKE hrp1001-endda DEFAULT '99991231'.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_par3 RADIOBUTTON GROUP rad2 USER-COMMAND flag DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) lv_par3 FOR FIELD p_par3.
    PARAMETERS: p_par4 RADIOBUTTON GROUP rad2.
    SELECTION-SCREEN COMMENT (15) lv_par4 FOR FIELD p_par4.
    PARAMETERS: p_par5 AS CHECKBOX USER-COMMAND flag5.
    SELECTION-SCREEN COMMENT (25) lv_par5 FOR FIELD p_par5.
*    PARAMETERS: p_job TYPE flag.
*    SELECTION-SCREEN COMMENT (25) lv_job FOR FIELD p_job.
  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF SCREEN 1002.

* Definition der einzelnen Masken: 3*
SELECTION-SCREEN BEGIN OF SCREEN 1003 AS SUBSCREEN.
  PARAMETERS      p_obj3    TYPE hrp1001-otype.
  SELECT-OPTIONS  s_objid3  FOR  hrp1001-objid.
  PARAMETERS: p_begda3 LIKE hrp1001-begda,
              p_endda3 LIKE hrp1001-endda DEFAULT '99991231'.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: p_par6 RADIOBUTTON GROUP rad3 USER-COMMAND flag DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (15) lv_par6 FOR FIELD p_par6.
    PARAMETERS:  p_par7 RADIOBUTTON GROUP rad3.
    SELECTION-SCREEN COMMENT (15) lv_par7 FOR FIELD p_par7.
    PARAMETERS: p_par8 AS CHECKBOX USER-COMMAND flag6.
    SELECTION-SCREEN COMMENT (30) lv_par8 FOR FIELD p_par8.
  SELECTION-SCREEN END OF LINE.
*  SELECTION-SCREEN ULINE.
*  SELECTION-SCREEN SKIP 1.
*  SELECTION-SCREEN COMMENT /1(81) lb26.
*  SELECTION-SCREEN COMMENT /1(81) lb27.
*  SELECTION-SCREEN COMMENT /1(81) lb28.
SELECTION-SCREEN END OF SCREEN 1003.

************************************************************************
*            Definition der TabStrip-Maske + UserCommand               *
************************************************************************
SELECTION-SCREEN:
BEGIN OF TABBED BLOCK reiter_nummer FOR 5 LINES,
TAB (30) t_zwei USER-COMMAND t_zwei DEFAULT SCREEN 1002,
TAB (30) t_drei USER-COMMAND t_drei DEFAULT SCREEN 1003,
END OF BLOCK reiter_nummer.


" INCLUDE zom_check_class.
************************************************************************
*          Gui-Fenster bzw. Reitern werden initialisiert               *
************************************************************************

INITIALIZATION.

  SELECTION-SCREEN FUNCTION KEY 1.

  ls_textfield-text      = 'Info'.
  ls_textfield-icon_id   = '@0S@'.
  ls_textfield-icon_text = 'Info'.
  ls_textfield-quickinfo = 'Information'.
  sscrfields-functxt_01  = ls_textfield.

  " Transaktion Berechtigungsprüfung
  AUTHORITY-CHECK OBJECT 'S_TCODE'
                  ID 'TCD' FIELD gc_tcode.
  IF sy-subrc <> 0.
    MESSAGE e172(00) WITH gc_tcode.
  ENDIF.

* Bezeichnung der Reiter/Parameters *
  t_zwei  =  'Prüfung Workflow-Elemente' ##NO_TEXT .
   t_drei  =  'Prüfung Stammdaten' ##NO_TEXT .
  lv_par3 =  'Einzelabfrage' ##NO_TEXT.
  lv_par4 =  'Top Down'  ##NO_TEXT.
  lv_par5 =  'Nur fehlerhafte Datensätze' ##NO_TEXT.     "'Geerbte Attribute ausblenden' ##NO_TEXT.
    lv_par6 =  'Einzelabfrage' ##NO_TEXT.
  lv_par7 =  'Top Down'  ##NO_TEXT.
  lv_par8 =  'Nur fehlerhafte Datensätze' ##NO_TEXT.
*  lv_job  =  'Reiter als Job einplannen' ##NO_TEXT.

  INCLUDE /THKR/WF_read_cust.


  " Suchhilfe
  IMPORT reiter_nummer FROM MEMORY ID 'ABC_ACTIVE'.


AT SELECTION-SCREEN: ON VALUE-REQUEST FOR  s_objid2-low.
  PERFORM z_f4_suchhilfe USING s_objid2-low.

AT SELECTION-SCREEN: ON VALUE-REQUEST FOR  s_objid2-high.
  PERFORM z_f4_suchhilfe USING s_objid2-high.

  AT SELECTION-SCREEN: ON VALUE-REQUEST FOR  s_objid3-low.
  PERFORM z_f4_suchhilfe USING s_objid3-low.

  AT SELECTION-SCREEN: ON VALUE-REQUEST FOR  s_objid3-high.
  PERFORM z_f4_suchhilfe USING s_objid3-high.


************************************************************************
*          Gui-Verwaltung                                              *
************************************************************************
AT SELECTION-SCREEN.

  IF sy-ucomm EQ 'T_ZWEI'.
    reiter_nummer-prog      = sy-cprog.
    reiter_nummer-dynnr     = 1002.
    reiter_nummer-activetab = 'T_ZWEI'.
  ENDIF.

   IF reiter_nummer-activetab EQ 'T_DREI'.
    reiter_nummer-prog      = sy-cprog.
    reiter_nummer-dynnr     = 1003.
    reiter_nummer-activetab = 'T_DREI'.
  ENDIF.

  CASE sy-ucomm.
    WHEN 'FC01'.
      CALL FUNCTION 'DSYS_SHOW_FOR_F1HELP'
        EXPORTING
          application      = ' '
          dokclass         = 'TX'
          "doklangu         = ''
          dokname          = 'ZOM_CHECK_KOMPL'
        EXCEPTIONS
          class_unknown    = 1
          object_not_found = 2
          OTHERS           = 3.

      IF sy-subrc NE 0.
        MESSAGE |Keine Dokumentation gefunden, bitte eine in SE61 erstellen oder aktivieren.| TYPE 'S' DISPLAY LIKE 'W'.
      ENDIF.
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.

  PERFORM z_sel_screen_out.


************************************************************************
*          Anfang der Logik/Programmstart                              *
************************************************************************
START-OF-SELECTION.

*--------------------------------------------------------------------*
*  12.06.2023 2 Jobs die im Reiter 2 ausgeführt werden können        *
*--------------------------------------------------------------------*
*  zcl_check_kompl=>job_init( iv_job_name = p_job ).

************************************************************************
*      Strukturelle Berechtigung laut T77UA und T77PR                  *
************************************************************************
  INCLUDE /THKR/WF_check_auth.


  EXPORT reiter_nummer TO MEMORY ID 'ABC_ACTIVE'.

************************************************************************
*          Reiter 2, T_ZWEI                                            *
************************************************************************
 IF reiter_nummer-activetab = 'T_ZWEI'.

    INCLUDE /THKR/WF_reiter.


************************************************************************
*          Reiter 3, T_DREI                                            *
************************************************************************
  ELSEIF reiter_nummer-activetab = 'T_DREI'.

    INCLUDE /THKR/STAMMDAT_REITER.
    "zom_reiter_stammdat.



    ENDIF.


*&---------------------------------------------------------------------*
*&   Suchhilfe F4                                                      *
*&---------------------------------------------------------------------*

FORM z_f4_suchhilfe USING objid.

  CLEAR lt_dynpfields.

  CLEAR lf_dynpfields.
  IF reiter_nummer-activetab = 'T_EINS'.
    MOVE 'P_OBJ1' TO lf_dynpfields-fieldname.
  ELSEIF reiter_nummer-activetab = 'T_ZWEI'.
    MOVE 'P_OBJ2' TO lf_dynpfields-fieldname.
  ELSEIF reiter_nummer-activetab = 'T_DREI'.
    MOVE 'P_OBJ3' TO lf_dynpfields-fieldname.
  ENDIF.

  APPEND lf_dynpfields TO lt_dynpfields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = sy-repid
      dynumb     = sy-dynnr
    TABLES
      dynpfields = lt_dynpfields
    EXCEPTIONS
      OTHERS     = 99.

  IF sy-subrc IS NOT INITIAL.
    " MESSAGE 'Bitte geben Sie O oder S ein.' TYPE 'E' ##NO_TEXT.
  ENDIF.

  TRY.
      CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
        EXPORTING
          shlpname = '/ISDFPS/HRBAS00OBJID_F'
          shlptype = 'SH'
        IMPORTING
          shlp     = lv_shlp.

      LOOP AT lv_shlp-interface ASSIGNING FIELD-SYMBOL(<fs_interface>) WHERE shlpfield = 'PLVAR' OR
                                                                             shlpfield = 'OTYPE' OR
                                                                             shlpfield = 'OBJID'.
        IF <fs_interface>-shlpfield = 'PLVAR'.
          <fs_interface>-valfield = abap_true.
          <fs_interface>-value = '01'.
        ELSEIF <fs_interface>-shlpfield = 'OTYPE'.
          READ TABLE lt_dynpfields ASSIGNING FIELD-SYMBOL(<fs_otype>) INDEX 1.
          IF sy-subrc = 0.
            <fs_interface>-valfield = abap_true.
            <fs_interface>-value = <fs_otype>-fieldvalue.
          ENDIF.
        ELSEIF <fs_interface>-shlpfield = 'OBJID'.
          <fs_interface>-valfield = abap_true.
        ENDIF.
      ENDLOOP.


      CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
        EXPORTING
          shlp          = lv_shlp
          disponly      = abap_false
          maxrecords    = 0           " alle Ergebnisse auflisten
          multisel      = abap_false  " Einfachauswahl
        IMPORTING
          rc            = f_rc
        TABLES
          return_values = it_values.  " Rückgabewerte

      IF f_rc = 0.

        objid = it_values[ fieldname = 'OBJID' ]-fieldval.
*        IF reiter_nummer-activetab = 'T_EINS'.
*          s_objid1-low = it_values[ fieldname = 'OBJID' ]-fieldval.
*        ELSEIF reiter_nummer-activetab = 'T_ZWEI'.
*          s_objid2-low = it_values[ fieldname = 'OBJID' ]-fieldval.
*        ELSEIF reiter_nummer-activetab = 'T_DREI'.
*          s_objid3-low = it_values[ fieldname = 'OBJID' ]-fieldval.
*        ENDIF.
      ENDIF.

    CATCH cx_root INTO DATA(e_txt).
      MESSAGE e_txt->get_text( ) TYPE 'S' DISPLAY LIKE 'E'.
  ENDTRY.

ENDFORM.


*&---------------------------------------------------------------------*
*&       Job-Feld ein.- bzw ausblenden                                 *
*&---------------------------------------------------------------------*

FORM z_sel_screen_out .

  DATA: callstack TYPE  abap_callstack.

  CLEAR callstack.

  LOOP AT SCREEN.

*    IF screen-name = 'P_JOB'.
*
*      " Feld Job nur für Varianten-Erstellung gedacht
*      " Nur für SCC - Benutzergruppe editierbar
*      IF sy-uname IS NOT INITIAL.
*        SELECT SINGLE class
*          FROM usr02
*          WHERE bname = @sy-uname  AND
*                gltgv LE @sy-datum AND
*                gltgb GE @sy-datum
*          INTO @DATA(lv_class).
*
*        IF sy-subrc IS INITIAL AND
*           lv_class EQ 'SCC'.
*
*          screen-input = 1.
*          MODIFY SCREEN.
*        ELSE.
*          screen-input = 0.
*          MODIFY SCREEN.
*        ENDIF.
*
*      ENDIF.


    IF screen-name = 'P_BEGDA'  OR
           screen-name = 'P_ENDDA'  OR
           screen-name = 'P_BEGDA2' OR
           screen-name = 'P_ENDDA2' OR
           screen-name = 'P_BEGDA3' OR
           screen-name = 'P_ENDDA3'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
