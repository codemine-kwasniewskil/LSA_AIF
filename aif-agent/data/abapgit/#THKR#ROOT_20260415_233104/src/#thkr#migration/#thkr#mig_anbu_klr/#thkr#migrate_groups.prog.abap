*&---------------------------------------------------------------------*
*& Report /THKR/MIGRATE_GROUPS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/migrate_groups.

DATA: bapiret TYPE bapiret2.

SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_pathl TYPE ibipparms-path.
  PARAMETERS: p_kokrs TYPE kokrs OBLIGATORY DEFAULT '1000' MODIF ID kkr.
  PARAMETERS: p_ktopl TYPE ktopl OBLIGATORY DEFAULT 'VKP' MODIF ID kpl.
SELECTION-SCREEN END OF BLOCK part1.

SELECTION-SCREEN BEGIN OF BLOCK part2 WITH FRAME TITLE TEXT-001.
  SELECTION-SCREEN : BEGIN OF LINE.
    PARAMETERS: p_kst  RADIOBUTTON GROUP rbg DEFAULT 'X' USER-COMMAND flag.
    SELECTION-SCREEN COMMENT 03(12) TEXT-s11.
    SELECTION-SCREEN POSITION 15.
    PARAMETERS: p_ua  RADIOBUTTON GROUP rbg.
    SELECTION-SCREEN COMMENT 17(12) TEXT-s12.
    SELECTION-SCREEN POSITION 30.
    PARAMETERS: p_ce  RADIOBUTTON GROUP rbg.
    SELECTION-SCREEN COMMENT 32(12) TEXT-s13.
  SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN END OF BLOCK part2.
SELECTION-SCREEN BEGIN OF BLOCK part3 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_test  TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
  PARAMETERS: p_eonly  TYPE abap_bool AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK part3.
SELECTION-SCREEN BEGIN OF BLOCK part4 WITH FRAME TITLE TEXT-001.
  SELECTION-SCREEN COMMENT /1(75) comm1.
  SELECTION-SCREEN COMMENT /1(75) comm5.
  SELECTION-SCREEN COMMENT /1(75) comm2.
  SELECTION-SCREEN COMMENT /1(75) comm3.
  SELECTION-SCREEN COMMENT /1(75) comm4.
SELECTION-SCREEN END OF BLOCK part4.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pathl.
  DATA: lv_rc TYPE i.
  DATA: lt_file_table TYPE filetable.
  cl_gui_frontend_services=>file_open_dialog( EXPORTING window_title = 'Datei auswählen' CHANGING file_table = lt_file_table rc = lv_rc ).
  IF lv_rc <> -1.
    TRY.
        p_pathl = lt_file_table[ 1 ]-filename .
      CATCH cx_sy_itab_line_not_found.
        MESSAGE i001(/thkr/fi_init) DISPLAY LIKE 'E'.
        EXIT.
    ENDTRY.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  comm1 = 'Die Exceldatei sollte folgenden Aufbau haben:'.
  comm5 = '!! Es wird das erste Tabellenblatt verwendet!!'.
  comm2 = 'Zeile 1 - Tag: Kostenstellgruppe ODER Auftragsgruppe'.
  comm3 = 'Zeile 2:  Ebene1  Ebene2 Ebene3 <Wert>  Bezeichnung'.
  comm4 = 'Zeile 3..x:  Definition'.

  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'KKR'.
        IF p_kst  = 'X'.
          screen-active = '1'.
        ELSE .
          screen-active = '0'.
        ENDIF.
        MODIFY SCREEN.
      WHEN 'KPL'.
        IF p_ce  = 'X'.
          screen-active = '1'.
        ELSE .
          screen-active = '0'.
        ENDIF.
        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.

START-OF-SELECTION.
  TRY.
      DATA(mapper) = NEW /thkr/cl_migr_grps( path = CONV string( p_pathl ) kokrs = p_kokrs testmode = p_test ).
      " Get hierachy
      DATA(sethier) = mapper->get_hier_results( ).
      DATA(setvals) = mapper->get_value_results( ).

      CASE abap_true.
        WHEN p_kst. "" Kostenstellengruppe
          /thkr/cl_migr_grps_processor=>costcenter_groups(
            values    = setvals
            hierarchy = sethier
            testmode  = p_test
            kokrs     = p_kokrs ).
        WHEN p_ua. "" Innenauftragsgruppe
          /thkr/cl_migr_grps_processor=>internalorder_groups(
            values    = setvals    "  Intervalle in der Hierarchie
            hierarchy = sethier " Gruppen - Hierarchietabelle
            testmode  = p_test ).
        WHEN p_ce. ""Kostenartengruppe
          /thkr/cl_migr_grps_processor=>costelement_groups(
            values    = setvals    "  Intervalle in der Hierarchie
            hierarchy = sethier " Gruppen - Hierarchietabelle
            ktopl     = p_ktopl
            testmode  = p_test ).
        WHEN OTHERS.
          " Upps!
      ENDCASE.
      "" Output
      IF p_eonly = abap_false.
        WRITE: 'Groups:'. NEW-LINE.
        DATA(value_index) = 0.
        LOOP AT sethier ASSIGNING FIELD-SYMBOL(<hier>).
          WRITE:  |{ <hier>-groupname }, { <hier>-hierlevel }, { <hier>-valcount }, { <hier>-descript }| COLOR = 1 . NEW-LINE.
          IF  <hier>-valcount IS NOT INITIAL.
            LOOP AT setvals ASSIGNING FIELD-SYMBOL(<val>) FROM value_index TO value_index + <hier>-valcount.
              WRITE: |  { <val>-valfrom } - { <val>-descr } | . NEW-LINE.
            ENDLOOP.
            value_index += <hier>-valcount.
          ENDIF.
        ENDLOOP.
      ENDIF.
    CATCH /thkr/cx_fi_init INTO DATA(err). " Fehlerkasse Init.
      WRITE: |Fehler|. NEW-LINE.
      IF err->bapiret2 IS NOT INITIAL.
        WRITE: |Type { err->bapiret2-type }: { err->bapiret2-message } |. NEW-LINE.
      ENDIF.
      IF err->previous IS BOUND.
        WRITE: |Type { err->previous->get_text( ) }|. NEW-LINE.
      ENDIF.
  ENDTRY.
