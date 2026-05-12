*&---------------------------------------------------------------------*
*& Report /THKR/WF_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/wf_test.

INCLUDE /thkr/wf_test_top.

INCLUDE /thkr/wf_test_scr.


AT SELECTION-SCREEN OUTPUT.
  "Für die Transaktion 'ZOM_WF_CHECKUSER' werden Reiter 2,4,5,6 des Selektionsbildes ausgeblendet
  "und stehen somit nicht zur Verfügung.
  IF sy-tcode = gc_tcode_opek.
    LOOP AT SCREEN.

      IF screen-name = 'BUTTON2'
      OR screen-name = 'BUTTON4'
      OR screen-name = 'BUTTON5'
      OR screen-name = 'BUTTON6'.

        screen-active = 0.
        MODIFY SCREEN.

      ENDIF.

    ENDLOOP.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_funk.

  SELECT DISTINCT funktion FROM /thkr/wf_control INTO TABLE lt_step.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield   = 'FUNKTION'   "field of internal table
      value_org  = 'S'
    TABLES
      value_tab  = lt_step
      return_tab = lt_return.

  WRITE lt_return-fieldval TO p_funk.
  CLEAR lt_return.

AT SELECTION-SCREEN.
  CASE sy-dynnr.
    WHEN 1000.
      CASE sscrfields-ucomm.
        WHEN 'PUSH1'.
          mytab-dynnr = 100.
          lv_active_tab = '1'.
        WHEN 'PUSH2'.
          mytab-dynnr = 200.
          lv_active_tab = '2'.
        WHEN 'PUSH3'.
          mytab-dynnr = 300.
          lv_active_tab = '3'.
        WHEN 'PUSH4'.
          mytab-dynnr = 400.
          lv_active_tab = '4'.
        WHEN 'PUSH5'.
          mytab-dynnr = 500.
          lv_active_tab = '5'.
        WHEN 'PUSH6'.
          mytab-dynnr = 600.
          lv_active_tab = '6'.
        WHEN 'PBUT1'.
          mytab-dynnr = 601.
          lv_active_tab = '6'.
          lv_storno = 'MM'.
        WHEN 'PBUT2'.
          mytab-dynnr = 602.
          lv_active_tab = '6'.
          lv_storno = 'FI'.
        WHEN 'PBUT3'.
          mytab-dynnr = 603.
          lv_active_tab = '6'.
          lv_storno = 'FO'.
        WHEN 'PBUT4'.
          mytab-dynnr = 604.
          lv_active_tab = '6'.
          lv_storno = 'SD'.
        WHEN 'PBACK'.
          mytab-dynnr = 600.
          lv_active_tab = '6'.
          lv_storno = ''.
        WHEN OTHERS.

      ENDCASE.
      lv_tab_save = lv_active_tab.

      IF p_funk IS NOT INITIAL  AND lv_active_tab = '2'.

        CLEAR: p_attr1, p_attr2, p_attr3, p_attr4, p_attr5, p_attr6, p_attr7.
        SELECT DISTINCT attribut FROM /thkr/wf_control INTO TABLE lt_attr WHERE workflow = p_wf AND funktion = p_funk.
        SORT lt_attr BY attrib.
        LOOP AT lt_attr ASSIGNING FIELD-SYMBOL(<ls_step>).
          DATA(lv_ref) = 'P_ATTR' && sy-tabix.
          ASSIGN (lv_ref) TO FIELD-SYMBOL(<lv_ref>).
          CHECK sy-subrc IS INITIAL.
          <lv_ref> = <ls_step>-attrib.
        ENDLOOP.

      ENDIF.

  ENDCASE.

INITIALIZATION.
  "Der zuletzt geöffnete Reiter wird aus dem Memory Speicher geladnen
  IMPORT mytab-dynnr FROM MEMORY ID gv_tbl_memory.

  " Transaktion Berechtigungsprüfung

  CASE sy-tcode.
    WHEN gc_tcode_all.

      AUTHORITY-CHECK OBJECT 'S_TCODE'
                ID 'TCD' FIELD '/THKR/WF_TEST'.
      IF sy-subrc <> 0.
        MESSAGE e172(00) WITH '/THKR/WF_TEST'.
      ENDIF.

    WHEN gc_tcode_opek.

      AUTHORITY-CHECK OBJECT 'S_TCODE'
                ID 'TCD' FIELD gc_tcode_opek .
      IF sy-subrc <> 0.
        MESSAGE e172(00) WITH 'ZOM_WF_CHECKUSER'.
      ENDIF.

  ENDCASE.

  " Prüfung auf Usergruppen NSI und SCC für die
  "allumfassende Transaktion
*  IF sy-tcode = gc_tcode_all.
*    SELECT SINGLE class INTO @DATA(lv_class) FROM usr02 WHERE bname = @sy-uname.
*    IF sy-subrc <> 0.
*      " Ausgabe einer Fehlermeldung
*      MESSAGE e110(z_om_messg).
*    ELSEIF lv_class <> 'NSI' AND lv_class <> 'SCC'.
*      " Ausgabe einer Fehlermeldung
*      MESSAGE e110(z_om_messg) WITH lv_class.
*    ENDIF.
*  ENDIF.

  button1 = 'Mit Beleg'.
  button2 = 'Mit Funk. und Attribut'.
  button3 = 'Workitem zu Beleg'.
  button4 = 'Mit Workitem'.
  button5 = 'RE-FX'.
  button6 = 'FI Änderung + Storno'.
  pbut1   = 'MM-Rechnungen (VIM)'.
  pbut2   = 'FI-Rechnungen (VIM)'.
  pbut3   = 'FI-Beleg aus Föbis'.
  pbut4   = 'SD-Faktura'.
*  pback1  = 'Zurück'.
*  pback2  = 'Zurück'.
*  pback3  = 'Zurück'.
*  pback4  = 'Zurück'.
  mytab-prog = sy-repid.
  "Beim ersten Aufrufen des Reports wird der Subscreen 100 (Reiter 1) geöffnet.
  IF mytab-dynnr IS INITIAL.
    mytab-dynnr = 100.
    mytab-activetab = 'PUSH1'.
    lv_active_tab = '1'.
    "Ansonsten wird der zuletzt geöffnete Reiter aufgerufen
  ELSE.
    lv_active_tab = mytab-dynnr(1).
    CONCATENATE 'PUSH' lv_active_tab INTO mytab-activetab.
  ENDIF.
*  mytab-dynnr = 100.
*  mytab-activetab = 'PUSH1'.
*  lv_active_tab = '1'.



START-OF-SELECTION.
  "Der aktuelle Reiter wird im Memory Speicher hinterlegt,
  "damit er später wieder aufgerufen werden kann
  EXPORT mytab-dynnr TO MEMORY ID gv_tbl_memory.

  CREATE OBJECT lo_wf.

*  DATA(lo_util) = NEW zcl_om_wf_util( ).

  CASE lv_active_tab.

    WHEN '1'. "Mit Beleg

*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          input  = p_doc
*        IMPORTING
*          output = p_doc.
*      """"""""""""""
*      "RePro BW Dring. Änd.: 5000000584
*      "Wenn der Report über die Transaktion ZOM_WF_CHECKUSER geöffnet wird,
*      "dann werden die Kontierungsmerkmale der Belegnummer mit dem Berechtigungsobjekt
*      "Z_FICA_TRG überprüft.
*      "Dabei sind nur Belege vom Type BEST, BESP, BANF und BANP zulässig.
*      IF sy-tcode = gc_tcode_opek.
*        CLEAR ld_subrc.
*        PERFORM check_belnr CHANGING ld_subrc.
*      ENDIF.
*      "Wenn der Report über die Transaktion ZOM_WF_TEST aufgerufen wird oder
*      "die Berechtigungsprüfung auf die Kontierungsmerkmale erfolgreich war
*      "und die Belegnummer zum gewählten Workflow gehört,
*      "dann wird die Genehmigerfindung regulär ausgegeben
*      IF ld_subrc = 0 OR sy-tcode = gc_tcode_all.
*        """"""""""""""""""
*        WRITE :/ 'Beleg ', p_doc.
*        WRITE :/ .
*
*        " Ermittle aktuellen Genehmigungsschritt
*        DATA(lv_step) = NEW zcl_om_wf_util( )->get_current_wf_step( iv_object_id = CONV #( p_doc ) ).   " Objekt-ID
*        IF lv_step IS NOT INITIAL.
*          WRITE :/ 'Schritt:  ', lv_step.
*        ENDIF.
*
*        DATA(lv_wi_id) = NEW zcl_om_wf_util( )->get_wi_id_ready( EXPORTING iv_object_id = CONV #( p_doc ) IMPORTING ev_wi_text = lv_wi_text ).   " Objekt-ID
*        IF lv_wi_id IS NOT INITIAL.
*          WRITE :/ 'Workitem: ', lv_wi_id, ' - ', lv_wi_text.
*          WRITE :/ .
*        ENDIF.
*
*        PERFORM get_approver USING p_funk.
*
*        """"""""""""""""""
*        "RePro BW Dring. Änd.: 5000000584
*        "Sollte die Berechtigungsprüfung fehlgeschlagen sein, wird eine entsprechende
*        "Fehlermeldung ausgegeben.
*      ELSEIF ld_subrc = 50.
*        DATA(ld_mes2) = |Keine Berechtigungen für Beleg { p_doc }.|.
*        MESSAGE ld_mes2 TYPE 'S' DISPLAY LIKE 'E'.
*        "Wenn der gewählte Workflow weder BANF, BANP, BEST oder BESP ist,
*        "dann wird eine Fehlermeldung ausgegeben, dass der gewählte Workflow
*        "für die Transaktion deaktiviert wurde.
*      ELSEIF ld_subrc = 60.
*        MESSAGE 'Der ausgewählte Worklfow ist bei dieser Transaktion deaktiviert.' TYPE 'S' DISPLAY LIKE 'E'.
*        "Anonsten existiert entweder der Beleg nicht oder die Belegnummer ist nicht im Nummernkreis
*        "des entsprechenden Belegtyps
*      ELSE.
*        DATA(ld_mes1) = |Die Belegnummer gehört nicht zum Typ { p_wf }.|.
*        MESSAGE ld_mes1 TYPE 'S' DISPLAY LIKE 'E'.
*      ENDIF.
*      """""""""""""""""""""
    WHEN '2'. " Mit Funktion und Attribut

      CLEAR lt_attr.
      APPEND VALUE #( attrib = p_attr1 value = p_value1 ) TO lt_attr.
      APPEND VALUE #( attrib = p_attr2 value = p_value2 ) TO lt_attr.
      APPEND VALUE #( attrib = p_attr3 value = p_value3 ) TO lt_attr.
      APPEND VALUE #( attrib = p_attr4 value = p_value4 ) TO lt_attr.
      APPEND VALUE #( attrib = p_attr5 value = p_value5 ) TO lt_attr.
      APPEND VALUE #( attrib = p_attr6 value = p_value6 ) TO lt_attr.
      APPEND VALUE #( attrib = p_attr7 value = p_value7 ) TO lt_attr.

      DELETE lt_attr WHERE attrib IS INITIAL.

      DATA(lt_plans_) = lo_wf->get_approver( iv_wf_id = p_wf
                                             iv_funk  = p_funk
                                             iv_log   = abap_true
                                             it_attr  = lt_attr ). " Attribute und Werte

      PERFORM write.

    WHEN '3'. " Workitem zu Beleg

*      CHECK p_id IS NOT INITIAL.
*
*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          input  = p_id
*        IMPORTING
*          output = p_id.
*      """""""""""""" RePro BW Dring. Änd.: 5000000584
*      "Wenn der Report über die Transaktion ZOM_WF_CHECKUSER geöffnet wird,
*      "dann werden die Kontierungsmerkmale der Belegnummer mit dem Berechtigungsobjekt
*      "Z_FICA_TRG überprüft.
*      "Dabei sind nur Belege vom Type BEST, BESP, BANF und BANP zulässig.
*      IF sy-tcode = gc_tcode_opek.
*        CLEAR ld_subrc.
*        PERFORM check_belnr CHANGING ld_subrc.
*      ENDIF.
*      "Wenn der Report über die Transaktion ZOM_WF_TEST aufgerufen wird oder
*      "die Berechtigungsprüfung auf die Kontierungsmerkmale erfolgreich war
*      "und die Belegnummer zum gewählten Workflow gehört,
*      "dann wird die Genehmigerfindung regulär ausgegeben
*      IF ld_subrc = 0 OR sy-tcode = gc_tcode_all.
*        """"""""""""""""
*        SELECT a~wi_id, b~wi_text FROM sww_wi2obj AS a INNER JOIN swwwihead AS b ON a~wi_id = b~wi_id
*          WHERE a~instid = @p_id
*            AND b~wi_stat = 'READY'
*            AND b~wi_type = 'W'
*          INTO TABLE @DATA(lt_wi).
*
*        LOOP AT lt_wi ASSIGNING FIELD-SYMBOL(<ls_wi>).
*          WRITE :/ 'Workitem: ', <ls_wi>-wi_id, ' - ', <ls_wi>-wi_text.
*          WRITE :/ .
*        ENDLOOP.
*        """""""""""
*        """"""""""""RePro BW Dring. Änd.: 5000000584
*        "Sollte die Berechtigungsprüfung fehlgeschlagen sein, wird eine entsprechende
*        "Fehlermeldung ausgegeben.
*      ELSEIF ld_subrc = 50.
*        ld_mes2 = |Keine Berechtigungen für Beleg { p_doc }.|.
*        MESSAGE ld_mes2 TYPE 'S' DISPLAY LIKE 'E'.
*        "Wenn der gewählte Workflow weder BANF, BANP, BEST oder BESP ist,
*        "dann wird eine Fehlermeldung ausgegeben, dass der gewählte Workflow
*        "für die Transaktion deaktiviert wurde.
*      ELSEIF ld_subrc = 60.
*        MESSAGE 'Der ausgewählte Worklfow ist bei diesem Report deaktiviert.' TYPE 'S' DISPLAY LIKE 'E'.
*        "Anonsten existiert entweder der Beleg nicht oder die Belegnummer ist nicht im Nummernkreis
*        "des entsprechenden Belegtyps
*      ELSE.
*        ld_mes1 = |Die Belegnummer gehört nicht zum Typ { p_wf }.|.
*        MESSAGE ld_mes1 TYPE 'S' DISPLAY LIKE 'E'.
*
*      ENDIF.
*      """"""""""""
    WHEN '4'. " Genehmigerfindung für Workitem

*      CHECK p_wi IS NOT INITIAL.
*
*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*        EXPORTING
*          input  = p_wi
*        IMPORTING
*          output = p_wi.
*
*      " Ermittle Workitem-Text
*      SELECT SINGLE wi_text FROM swwwihead INTO @lv_wi_text WHERE wi_id = @p_wi AND wi_stat = 'READY' AND wi_type = 'W'.
*      CHECK sy-subrc IS INITIAL.
*
*      " Ermittle Funktionstext
*      DATA(lv_f) = lo_util->get_funktion_by_wi( iv_wi = p_wi ).
*      SELECT SINGLE descr FROM zom_wf_funktion INTO @DATA(lv_funk_txt) WHERE funktion = @lv_f.
*
*      " Ermittle Belegnummer
*      SELECT SINGLE a~instid FROM sww_wi2obj AS a INNER JOIN swwwihead AS b ON a~wi_id = b~wi_id
*      WHERE a~wi_id = @p_wi
*        AND b~wi_stat = 'READY'
*        AND b~wi_type = 'W'
*      INTO @DATA(lv_id).
*
*      WRITE :/ |Workitem: | && p_wi && | - | && lv_funk_txt && | | && p_wf && | | && lv_id.
*      WRITE :/.
*
*      zcl_om_wf_funktion_srv=>gv_log = abap_true.
*      CALL FUNCTION 'SWL_WI_ADM_REDO_RULE'
*        EXPORTING
*          wi_id                 = p_wi
*          authorization_checked = abap_true
*        EXCEPTIONS
*          enqueue_failed        = 1
*          read_failed           = 2
*          OTHERS                = 3.
*      IF sy-subrc IS NOT INITIAL.
*        WRITE :/ 'Fehler bei Bearbeiterregel durchführen für Workitem: ' && p_id.
*      ENDIF.
*
*      zcl_om_wf_funktion_srv=>gv_log = abap_false.

    WHEN '5' OR '6'. "Genehmigerfindung für RE-FX "Genehmigerfindung für FI-Änderungen und Storno
*
*      PERFORM output_refx_storno USING lv_storno
*                                       lv_active_tab.

  ENDCASE.

END-OF-SELECTION.
*
FORM write.

  LOOP AT lt_plans_ ASSIGNING FIELD-SYMBOL(<ls_plans>).
    SELECT SINGLE stext FROM hrp1000 INTO @DATA(lv_stext) WHERE otype = 'S' AND objid = @<ls_plans> AND begda <= @sy-datum AND endda >= @sy-datum. "#EC CI_SEL_NESTED
  ENDLOOP.

  IF lt_plans_ IS INITIAL.

    WRITE :/ '-----------------------------------------------------'.
    WRITE :/ 'Keine Genehmiger gefunden, also OM-Support ermitteln:'.

    lt_plans_ = lo_wf->get_approver( iv_wf_id = p_wf
                                     iv_funk  = /thkr/cl_wf_funktion_srv=>gc_wf_funk_omsp    " OM-Support
                                     iv_log   = abap_true
                                     it_attr  = lt_attr                                 ). " Attribute und Werte

    IF lt_plans IS INITIAL AND ( p_funk <> 'PRSP' AND p_funk <> 'OMSP').

      WRITE :/ '-----------------------------------------------------'.
      WRITE :/ 'Keine OM-Support gefunden, also WF-Support Level 3 ermitteln:'.
      WRITE :/ '-----------------------------------------------------'.

      READ TABLE lt_attr WITH KEY attrib = 'ZWFLEVEL' ASSIGNING FIELD-SYMBOL(<fs_attrib>).
      IF sy-subrc = 0.
        <fs_attrib>-value = '3'.
      ELSE.
        APPEND INITIAL LINE TO lt_attr ASSIGNING <fs_attrib>.
        <fs_attrib>-attrib = 'ZWFLEVEL'.
        <fs_attrib>-value = '3'.
      ENDIF.

      lt_plans = lo_wf->get_approver( iv_wf_id = p_wf
                                  iv_funk  = /thkr/cl_wf_funktion_srv=>gc_wf_funk_PRSP    " WF-Support - Level 2
                                  iv_log   = abap_true
                                  it_attr  = lt_attr                                 ). " Attribute und Werte

    ENDIF.

  ENDIF.

ENDFORM.


*FORM get_approver USING iv_step TYPE z_om_dte_funktion.
*
*  DATA(lo_util) = NEW zcl_om_wf_util( ).
*  DATA lv_nonbuge TYPE rlwrt.
*
*  CONSTANTS: lc_wf_id   TYPE string VALUE 'WFTYP',
*             lc_wf_funk TYPE string VALUE 'FUNKTION'.
*
*  IF p_wf = 'BANF' OR p_wf = 'BANP'.
*    SELECT SINGLE * FROM eban INTO @DATA(ls_eban) WHERE banfn = @p_doc AND loekz = @abap_false.
*    SELECT SINGLE * FROM ebkn INTO @DATA(ls_ebkn) WHERE banfn = @p_doc AND loekz = @abap_false.
*
*    IF ls_eban-knttp IS INITIAL.
*      MOVE-CORRESPONDING ls_eban TO ls_ebkn.
*      ls_ebkn-gsber = lo_util->get_zpgsbr_by_werks( iv_werks = ls_eban-werks ).
*      ls_ebkn-fipos = ls_eban-fipos.
*      ls_ebkn-fistl = ls_eban-fistl.
*    ENDIF.
*
*    IF ls_eban-kostl IS INITIAL AND ls_ebkn-kostl IS INITIAL.
*      " Ermittlung Kostenstelle
*      ls_ebkn-kostl = lo_util->get_banf_kostl( is_eban = ls_eban is_ebkn = ls_ebkn ).
*    ENDIF.
*
*    LOOP AT CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( p_data = ls_eban ) )->get_components( ) ASSIGNING FIELD-SYMBOL(<ls_comp>).
*      ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE ls_eban TO FIELD-SYMBOL(<lv_value>).
*      CHECK <ls_comp>-name <> 'LIMIT' AND <lv_value> IS NOT INITIAL.
*      APPEND VALUE #( element = <ls_comp>-name value = CONV string( <lv_value> ) ) TO lt_container.
*    ENDLOOP.
*
*    LOOP AT CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( p_data = ls_ebkn ) )->get_components( ) ASSIGNING <ls_comp>.
*      ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE ls_ebkn TO <lv_value>.
*      CHECK <lv_value> IS NOT INITIAL.
*      APPEND VALUE #( element = <ls_comp>-name value = CONV string( <lv_value> ) ) TO lt_container.
*    ENDLOOP.
*
*  ENDIF.
*
*  IF p_wf = 'BEST' OR p_wf = 'BESP'.
*    SELECT SINGLE * FROM ekko INTO @DATA(ls_ekko) WHERE ebeln = @p_doc AND loekz = @abap_false.
*    SELECT SINGLE * FROM ekpo INTO @DATA(ls_ekpo) WHERE ebeln = @p_doc AND loekz = @abap_false.
*    SELECT SINGLE * FROM ekkn INTO @DATA(ls_ekkn) WHERE ebeln = @p_doc AND loekz = @abap_false.
*
*    IF ls_ekpo-knttp IS INITIAL.
*      MOVE-CORRESPONDING ls_ekpo TO ls_ekkn.
*      ls_ekkn-gsber = lo_util->get_zpgsbr_by_werks( iv_werks = ls_ekpo-werks ).
*      ls_ekkn-fipos = ls_ekpo-fipos.
*      ls_ekkn-fistl = ls_ekpo-fistl.
*    ENDIF.
*
*    IF ls_ekpo-kostl IS INITIAL AND ls_ekkn-kostl IS INITIAL.
*      " Ermitteln der Kostenstelle
*      ls_ekkn-kostl = lo_util->get_best_kostl( is_ekpo = ls_ekpo is_ekkn = ls_ekkn ).
*    ENDIF.
*
*    LOOP AT CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( p_data = ls_ekko ) )->get_ddic_field_list( p_including_substructres = abap_true ) ASSIGNING FIELD-SYMBOL(<ls_field>).
*      ASSIGN COMPONENT <ls_field>-fieldname OF STRUCTURE ls_ekko TO <lv_value>.
*      CHECK <ls_field>-fieldname <> 'LIMIT' AND <lv_value> IS NOT INITIAL.
*** Ersetzen des Betrags durch Effektivwert
**      CASE <ls_field>-fieldname.
**        WHEN  'EFFWR'.
**          APPEND VALUE #( element = 'NETWR' value = CONV string( <lv_value> ) ) TO lt_container.
**          APPEND VALUE #( element = 'BRTWR' value = CONV string( <lv_value> ) ) TO lt_container.
**
**        WHEN 'NETWR'.
**          CONTINUE.
**        WHEN 'BRTWR'.
**          CONTINUE.
**        WHEN OTHERS.
**      ENDCASE.
*
*      APPEND VALUE #( element = <ls_field>-fieldname value = CONV string( <lv_value> ) ) TO lt_container.
*    ENDLOOP.
*
*    LOOP AT CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( p_data = ls_ekpo ) )->get_ddic_field_list( p_including_substructres = abap_true ) ASSIGNING <ls_field>.
*      ASSIGN COMPONENT <ls_field>-fieldname OF STRUCTURE ls_ekpo TO <lv_value>.
*      CHECK <ls_field>-fieldname <> 'LIMIT' AND <lv_value> IS NOT INITIAL.
*      APPEND VALUE #( element = <ls_field>-fieldname value = CONV string( <lv_value> ) ) TO lt_container.
*    ENDLOOP.
*
*    LOOP AT CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( p_data = ls_ekkn ) )->get_ddic_field_list( p_including_substructres = abap_true ) ASSIGNING <ls_field>.
*      ASSIGN COMPONENT <ls_field>-fieldname OF STRUCTURE ls_ekkn TO <lv_value>.
*      CHECK <ls_field>-fieldname <> 'LIMIT' AND <lv_value> IS NOT INITIAL.
*      APPEND VALUE #( element = <ls_field>-fieldname value = CONV string( <lv_value> ) ) TO lt_container.
*    ENDLOOP.
*
*
*  ENDIF.
*
*  IF iv_step IS NOT INITIAL.
*    CLEAR lt_step.
*    APPEND iv_step TO lt_step.
*  ELSE.
*    SELECT DISTINCT funktion FROM zom_wf_funk_c INTO TABLE lt_step WHERE workflow = p_wf.
*    SORT lt_step BY table_line.
*  ENDIF.
*
*  READ TABLE lt_step WITH KEY funktion = 'BUGE' TRANSPORTING NO FIELDS.
*  if sy-subrc = 0.
*    CALL METHOD lo_util->get_nonbuge_from_opek( EXPORTING iv_banfn = p_doc
*                                                IMPORTING ev_nonbuge = lv_nonbuge ).
*    DATA(lv_nonbuge_text) = CONV string( lv_nonbuge ).
*    IF lv_nonbuge IS NOT INITIAL.
*      CONCATENATE 'Achtung: Freigabegrenze für Budgetgenehmigung liegt bei ' lv_nonbuge_text '€.' INTO DATA(lv_nonbuge_str) RESPECTING BLANKS.
*      WRITE :/ lv_nonbuge_str.
*      WRITE:/.
*    ENDIF.
*  endif.
*
*  WRITE :/ 'Ergebnis der Genehmigerfindung:'.
*
*  zcl_om_wf_funktion_srv=>gv_log = abap_true.                " Protokollierung ein
*  zcl_om_wf_funktion_srv=>gv_log_all = abap_true.            " Ausgabe alle User an Planstelle
*  LOOP AT lt_step ASSIGNING FIELD-SYMBOL(<lv_step>).
*
*    DATA(lt_cont) = lt_container.
*    CLEAR lt_plans.
*
*    APPEND VALUE #( element = lc_wf_id value = p_wf ) TO lt_cont.
*    APPEND VALUE #( element = lc_wf_funk value = <lv_step> ) TO lt_cont.
*
*    WRITE :/ |Schritt: | && CONV string( <lv_step> ).
*    WRITE :/ '----------------------------------'.
*
*    CALL FUNCTION 'Z_WF_REGEL_BESCHAFFUNG_01'
*      TABLES
*        actor_tab          = lt_plans
*        ac_container       = lt_cont
*      EXCEPTIONS
*        nobody_found       = 1
*        document_not_found = 2
*        not_found          = 3
*        OTHERS             = 4.
*    IF sy-subrc IS INITIAL.
*
*      WRITE :/.
*      WRITE :/.
*
*    ENDIF.
*
*    IF lt_plans IS INITIAL.
*      WRITE :/ 'Kein Genehmiger gefunden.'.
*    ENDIF.
*
*  ENDLOOP.
*
*  zcl_om_wf_funktion_srv=>gv_log = abap_false.
*  zcl_om_wf_funktion_srv=>gv_log_all = abap_false.
*
*ENDFORM.

FORM output_refx_storno USING iv_storno
                              iv_tab.

*  DATA: lv_select TYPE string.
*
*  CASE iv_tab.
*
*    WHEN '5'.
*
*      SELECT intreno, bukrs, recnnr, objnr, imkey FROM vicncn
*        INTO TABLE @DATA(lt_vicncn)
*        WHERE recnnr EQ @p_contr AND bukrs EQ @p_bukrs.
*
*    WHEN '6'.
*
*      CASE iv_storno.
*        WHEN 'MM'.
*          CONCATENATE 'gjahr EQ @p_' iv_storno 'gja AND belnr EQ @p_' iv_storno 'bel' INTO lv_select.
*        WHEN 'FI'.
*          CONCATENATE 'gjahr EQ @p_' iv_storno 'gja AND belnr EQ @p_' iv_storno 'bel AND bukrs EQ @p_' iv_storno 'buk' INTO lv_select.
*        WHEN 'FO'.
*          CONCATENATE 'gjahr EQ @p_' iv_storno 'gja AND belnr EQ @p_' iv_storno 'bel AND bukrs EQ @p_' iv_storno 'buk' INTO lv_select.
*        WHEN 'SD'.
*          CONCATENATE 'belnr EQ @p_' iv_storno 'bel' INTO lv_select.
*        WHEN OTHERS.
*          RETURN.
*      ENDCASE.
*
*    WHEN OTHERS.
*      RETURN.
*  ENDCASE.
*
*  IF iv_tab EQ '6'.
*
*    SELECT bukrs, belnr, gjahr, modul, lfdnr
*    FROM zfi_storno
*    INTO TABLE @lt_zfi
*    WHERE (lv_select).
*
*    IF lt_zfi IS INITIAL.
*
*      SELECT bukrs, belnr, gjahr, lfdnr
*        FROM zfi_fb02
*        INTO CORRESPONDING FIELDS OF TABLE @lt_zfi
*        WHERE (lv_select).
*
*    ENDIF.
*
*  ENDIF.
*
*  IF lt_zfi IS NOT INITIAL.
*
*    LOOP AT lt_zfi ASSIGNING FIELD-SYMBOL(<lf_zfi>).
*
*      APPEND VALUE #( sign = 'I' option = 'CP' low = '*' && <lf_zfi>-belnr && '*') TO lt_selopt.
*
*    ENDLOOP.
*
*  ELSEIF lt_vicncn IS NOT INITIAL.
*
*    LOOP AT lt_vicncn ASSIGNING FIELD-SYMBOL(<lf_vic>).
*
*      APPEND VALUE #( sign = 'I' option = 'CP' low = '*' && <lf_vic>-recnnr && '*') TO lt_selopt.
*
*    ENDLOOP.
*
*  ELSE.
*
*    RETURN.
*
*  ENDIF.
*
*  SELECT wi_id, top_wi_id, wi_rh_task, crea_tmp, instid, typeid, wi_reltype
*    FROM sww_wi2obj
*    INTO TABLE @DATA(lt_wi2)
*    WHERE instid IN @lt_selopt
*    ORDER BY crea_tmp ASCENDING.
*
*  IF sy-subrc EQ 0.
*
*    LOOP AT lt_wi2 ASSIGNING FIELD-SYMBOL(<lf_wi2>).
*
*      SELECT SINGLE wi_text, wi_stat, wi_cd, wi_ct
*        FROM swwwihead
*        INTO @DATA(ls_head)
*        WHERE wi_id EQ @<lf_wi2>-wi_id.
*
*      APPEND ls_head TO lt_head.
*
*    ENDLOOP.
*
*    IF sy-subrc EQ 0.
*
*      LOOP AT lt_head ASSIGNING FIELD-SYMBOL(<lf_head>).
*
*        WRITE: /, <lf_head>-wi_stat.
*        WRITE: <lf_head>-wi_text.
*        WRITE: / '----------------------------------'.
*
*      ENDLOOP.
*
*    ENDIF.
*
*  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_belnr
*&---------------------------------------------------------------------*
*& Die Routine wird nur in der Transaktion "ZOM_WF_CHECKUSER" verwendet
*& Die Routine check_belnr dient als Sammelroutine für die Prüfung der
*& Belegnummer auf ihre Existenz, Richtigkeit und die Berechtigungen des
*& ausführenden Users.
*&
*&---------------------------------------------------------------------*
*& <--  ev_subrc  Der Paramter ev_subrc dient zur Übergabe des Prüfergebnis.
*&                50 bedeutet. dass der User keine Berechtigungen besitzt.
*&                60 bedeutet, dass der ausgewählte Workflow nicht über
*&                die Transaktion verwendet werden kann.
*&                Alle anderen Werte > 0 bedeuten, dass der Beleg entweder
*&                nicht dem gewhälten Workflow entspricht oder der Beleg
*&                nicht existiert.
*&---------------------------------------------------------------------*
FORM check_belnr CHANGING ev_subrc TYPE syst_subrc .
  DATA: ld_bukrs TYPE bukrs.
  DATA: ld_fikrs TYPE fikrs.
  DATA: ld_subrc TYPE syst_subrc.
  "Workflow ist nicht über Transaktion ZOM_WF_CHECKUSER auswertbar
  IF p_wf NE 'BANF' AND p_wf NE 'BANP' AND p_wf NE 'BEST' AND p_wf NE 'BANP'.
    ev_subrc = 60.
    RETURN.
  ENDIF.
  "Ruft die Routune zur Überprüfung der Belegnummer auf den entsprechenden Nummernkreis auf
  PERFORM check_number_interval USING ld_subrc.
  IF ld_subrc <> 0.
    ev_subrc = ld_subrc.
    RETURN.
  ENDIF.
  "Abhängig vom Workflow werden die Belegdaten aus anderen Tabellen gelesen, weshalb hier zwischen
  "den Workflowarten unterschieden wird.
  CASE p_wf.
      "Der gewählte Workflow ist vom Typ BANF oder BANP
    WHEN 'BANF' OR 'BANP'.

      CLEAR ld_subrc.
      PERFORM check_permission_for_banf CHANGING ld_subrc.
      IF ld_subrc <> 0.
        ev_subrc = ld_subrc.
        RETURN.
      ENDIF.
      "Der gewählte Workflow ist vom Typ BEST oder BESP
    WHEN 'BEST' OR 'BESP'.

      CLEAR ld_subrc.
      PERFORM check_permission_for_best CHANGING ld_subrc.
      IF ld_subrc <> 0.
        ev_subrc = ld_subrc.
        RETURN.
      ENDIF.
      ""Der gewählte Workflow ist nicht über die Transaktion auswertbar
    WHEN OTHERS.
      ev_subrc = 60.
      RETURN.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_number_interval
*&---------------------------------------------------------------------*
*& Die Routine wird nur in der Transaktion "ZOM_WF_CHECKUSER" verwendet
*& Die Routine check_number_interval prüft, ob die eingegebene Belegnummer
*& dem Nummernkreis des eingegebenen Workflows angehört.
*&
*&---------------------------------------------------------------------*
*& <--  ev_subrc  Der Paramter ev_subrc dient zur Übergabe des Prüfergebnis.
*&                Der Wert ist 1, sollte die Belegnummer nicht zum Nummernkreis gehören
*&                Alle anderen Werte weisen auf einen Fehler während der Prüfung hin.
*&                Dies könnte zum Beispiel ein fehlender Nummernkreis sein.
*&---------------------------------------------------------------------*
FORM check_number_interval CHANGING ev_subrc TYPE syst_subrc.

  DATA: ld_range_nr TYPE inri-nrrangenr.
  DATA: ld_nrkreis TYPE inri-object.
  DATA: ld_return TYPE inri-returncode.
  DATA: ld_id TYPE char10.
  "Abhängig vom gewählten Workflow wird der Nummernkreis definiert.
  CASE p_wf.
    WHEN 'BANF' OR 'BANP'.
      ld_nrkreis = 'BANF'.
      ld_range_nr = '01'.
    WHEN 'BEST' OR 'BESP'.
      ld_nrkreis = 'EINKBELEG'.
      ld_range_nr = '45'.
  ENDCASE.
  "Abhängig vom Reiter wird die Variable mit der entsprechenden Belegnummer gefüllt
  CASE mytab-dynnr.
    WHEN '100'.
      ld_id = p_doc.
    WHEN '300'.
      ld_id = p_id.
  ENDCASE.
  "Der Funktionsbaustein übernimmt die Prüfung der Belegnummer gegen den Nummernkreis
  CALL FUNCTION 'NUMBER_CHECK_INTERN'
    EXPORTING
      nr_range_nr             = ld_range_nr
      number                  = ld_id
      object                  = ld_nrkreis
    IMPORTING
      returncode              = ld_return
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      OTHERS                  = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
    ev_subrc =  sy-subrc.
  ENDIF.
  "Sollte die Belegnummer nicht zum Nummernkreis passen ( Return = X ),
  "wird ev_subrc auf 1 gesetzt und an die aufrufende Routine übergeben.
  IF ld_return = 'X'.
    ev_subrc = 1.
    RETURN.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_permission_for_banf
*&---------------------------------------------------------------------*
*& Die Routine wird nur in der Transaktion "ZOM_WF_CHECKUSER" verwendet
*& Die Routine check_permission_for_banf prüft die Berechtigungen des Anweders
*& auf das Berechtigungsobjekt Z_FICA_TRG. Dabei sind die Felder FIKRS,
*& FISTL, FIPEX und AUTHACT relevant. Die entsprechenden Daten stammen
*& aus den Kontierungsmerkalen des Belegs aus der Tabelle EBAN.
*&
*&---------------------------------------------------------------------*
*& <--  ev_subrc  Der Paramter ev_subrc dient zur Übergabe des Prüfergebnis.
*&                50 bedeutet. dass der User keine oder ungenügende Berechtigungen besitzt.
*&                Alle anderen Werte > 0 bedeuten, dass der Beleg nicht existiert oder
*&                der Datensatz fehlerhaft ist.
*&---------------------------------------------------------------------*
FORM check_permission_for_banf CHANGING ev_subrc TYPE syst_subrc.
*  DATA: ld_bukrs TYPE bukrs.
*  DATA: ld_fikrs TYPE fikrs.
*  DATA: ld_id TYPE char10.
*  DATA: ld_fipos_d type fipos.
*  DATA: ld_fistl_d type fistl.
*  "Abhängig vom Reiter wird die entsprechende Selektionvariable befüllt.
*  CASE mytab-dynnr.
*    WHEN '100'.
*      ld_id = p_doc.
*    WHEN '300'.
*      ld_id = p_id.
*  ENDCASE.
*  "Die Belegdaten werden aus den Tabellen EBAN und EBKN gelesen.
*  SELECT SINGLE * FROM eban INTO @DATA(ls_eban_2) WHERE banfn = @ld_id AND loekz = @abap_false.
*    SELECT SINGLE * FROM ebkn INTO @DATA(ls_ebkn_2) WHERE banfn = @ld_id AND loekz = @abap_false.
*  "Wenn keine Daten selektiert werden, existiert keine gültige Belegnummer, ein Fehler wird
*  "an die aufrufende Routine zurückgegeben.
*  IF ls_eban_2 is INITIAL and ls_ebkn_2 is INITIAL.
*    ev_subrc = 1.
*    RETURN.
*  ELSE.
*
*    IF ls_eban_2-knttp IS INITIAL.
**      MOVE-CORRESPONDING ls_eban TO ls_ebkn.
**      ls_ebkn-gsber = lo_util->get_zpgsbr_by_werks( iv_werks = ls_eban-werks ).
*      ld_fipos_d = ls_eban_2-fipos.
*      ld_fistl_d = ls_eban_2-fistl.
*      ELSE.
*        ld_fistl_d = ls_ebkn_2-fistl.
*        ld_fipos_d = ls_ebkn_2-fipos.
*    ENDIF.
*
*    "Die Tabelle EBAN enthält den Buchungskreis nicht als Feld, weswegen der Buchungskreis über
*    " die Methode get_bukrs_by_werks der Klasse ZCL_OM_WF_UTIL mit dem Parameter WERKS ermittelt wird
*    CALL METHOD lo_util->get_bukrs_by_werks
*      EXPORTING
*        iv_werks = ls_eban_2-werks
*      RECEIVING
*        rv_bukrs = ld_bukrs.
*    "Anschließend wird über einen Funktionsbaustein der Finanzkreis des Buchungskreis bestimmt.
*    CALL FUNCTION 'FMFK_GET_FIKRS_FROM_BUKRS'
*      EXPORTING
*        i_bukrs            = ld_bukrs
*      IMPORTING
*        e_fikrs            = ld_fikrs
*      EXCEPTIONS
*        no_fikrs_for_bukrs = 1
*        OTHERS             = 2.
*    "Anschließend werden die Berechtigungsgruppen zu den Kontierungsdaten ausgelesen.
*    SELECT SINGLE augrp FROM fmfctr INTO @DATA(ld_fistl)
*          WHERE fictr EQ @ld_fistl_d
*          AND fikrs EQ @ld_fikrs
*          AND datbis GE @sy-datum. "INS REPRO-SOT 2000002103_INT4_020_01
*
*    SELECT SINGLE augrp FROM fmci INTO @DATA(ld_fipex)
*          WHERE fipex EQ @ld_fipos_d
*          AND fikrs EQ  @ld_fikrs.
*    "Berechtigungsprüfung gegen Z_FICA_TRG
*    AUTHORITY-CHECK OBJECT 'Z_FICA_TRG'
*    ID 'FM_AUTHACT' FIELD '11'
*    ID 'FM_FIKRS' FIELD ld_fikrs
*    ID 'FM_AUTHGRF' DUMMY
*    ID 'FM_AUTHGRC' FIELD ld_fistl
*    ID 'FM_AUTHGRP' FIELD ld_fipex
*    ID 'FM_AUTHGRM'  DUMMY
*    ID 'FM_GRP_FAR' DUMMY.
*    "Berechtigungsprüfung fehlgeschlagen
*    IF sy-subrc <> 0.
*      ev_subrc = 50.
*      RETURN.
*    ENDIF.
*  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_permission_for_best
*&---------------------------------------------------------------------*
*& Die Routine wird nur in der Transaktion "ZOM_WF_CHECKUSER" verwendet
*& Die Routine check_permission_for_best prüft die Berechtigungen des Anweders
*& auf das Berechtigungsobjekt Z_FICA_TRG. Dabei sind die Felder FIKRS,
*& FISTL, FIPEX und AUTHACT relevant. Die entsprechenden Daten stammen
*& aus den Kontierungsmerkalen des Belegs aus der Tabelle EKPO.
*&
*&---------------------------------------------------------------------*
*& <--  ev_subrc  Der Paramter ev_subrc dient zur Übergabe des Prüfergebnis.
*&                50 bedeutet. dass der User keine oder ungenügende Berechtigungen besitzt.
*&                Alle anderen Werte > 0 bedeuten, dass der Beleg nicht existiert oder
*&                der Datensatz fehlerhaft ist.
*&---------------------------------------------------------------------*
FORM check_permission_for_best CHANGING ev_subrc TYPE syst_subrc.

*  DATA: ld_bukrs TYPE bukrs.
*  DATA: ld_fikrs TYPE fikrs.
*  DATA: ld_id TYPE char10.
*  DATA: ld_fipos_d type fipos.
*  DATA: ld_fistl_d type fistl.
*  "Abhängig vom Reiter wird die entsprechende Selektionvariable befüllt.
*  CASE mytab-dynnr.
*    WHEN '100'.
*      ld_id = p_doc.
*    WHEN '300'.
*      ld_id = p_id.
*  ENDCASE.
*  "Die Belegdaten werden aus den Tabellen EKPO, EKKO und EKKN gelesen.
*  SELECT SINGLE * FROM ekpo INTO @DATA(ls_ekpo_2) WHERE ebeln = @ld_id AND loekz = @abap_false.
*  SELECT SINGLE * FROM ekko INTO @DATA(ls_ekko_2) WHERE ebeln = @ld_id AND loekz = @abap_false.
*  SELECT SINGLE * FROM ekkn INTO @DATA(ls_ekkn_2) WHERE ebeln = @ld_id AND loekz = @abap_false.
*  "Wenn keine Daten selektiert werden, existiert keine gültige Belegnummer, ein Fehler wird
*  "an die aufrufende Routine zurückgegeben.
*  IF ls_ekpo_2 is INITIAL and ls_ekko_2 is INITIAL and ls_ekkn_2 is INITIAL.
*    ev_subrc = 1.
*    RETURN.
*  ELSE.
*
*    IF ls_ekpo_2-knttp IS INITIAL.
**      MOVE-CORRESPONDING ls_ekpo TO ls_ekkn.
**      ls_ekkn_2-gsber = lo_util->get_zpgsbr_by_werks( iv_werks = ls_ekpo-werks ).
*      ld_fipos_d = ls_ekpo_2-fipos.
*      ld_fistl_d = ls_ekpo_2-fistl.
*      ELSE.
*      ld_fipos_d = ls_ekkn_2-fipos.
*      ld_fistl_d = ls_ekkn_2-fistl.
*    ENDIF.
*    if ls_ekpo_2-bukrs is INITIAL.
*    CALL METHOD lo_util->get_bukrs_by_werks
*    EXPORTING
*      iv_werks = ls_ekpo_2-werks
*      RECEIVING
*      rv_bukrs = ld_bukrs.
*
*    ELSE.
*      ld_bukrs = ls_ekpo_2-bukrs .
*      ENDIf.
*
*
*   "Anschließend wird über einen Funktionsbaustein der Finanzkreis des Buchungskreis bestimmt.
*    CALL FUNCTION 'FMFK_GET_FIKRS_FROM_BUKRS'
*      EXPORTING
*        i_bukrs            = ld_bukrs
*      IMPORTING
*        e_fikrs            = ld_fikrs
*      EXCEPTIONS
*        no_fikrs_for_bukrs = 1
*        OTHERS             = 2.
*    "Anschließend werden die Berechtigungsgruppen zu den Kontierungsdaten ausgelesen.
*    SELECT SINGLE augrp FROM fmfctr INTO @DATA(ld_fistl)
*          WHERE fictr EQ @ld_fistl_d
*          AND fikrs EQ @ld_fikrs
*          AND datbis GE @sy-datum. "INS REPRO-SOT 2000002103_INT4_020_01
*
*    SELECT SINGLE augrp FROM fmci INTO @DATA(ld_fipex)
*          WHERE fipex EQ @ld_fipos_d
*          AND fikrs EQ  @ld_fikrs.
*    "Berechtigungsprüfung gegen Z_FICA_TRG
*    AUTHORITY-CHECK OBJECT 'Z_FICA_TRG'
*    ID 'FM_AUTHACT' FIELD '11'
*    ID 'FM_FIKRS' FIELD ld_fikrs
*    ID 'FM_AUTHGRF' DUMMY
*    ID 'FM_AUTHGRC' FIELD ld_fistl
*    ID 'FM_AUTHGRP' FIELD ld_fipex
*    ID 'FM_AUTHGRM'  DUMMY
*    ID 'FM_GRP_FAR' DUMMY.
*    "Berechtigungsprüfung fehlgeschlagen
*    IF sy-subrc <> 0.
*      ev_subrc = 50.
*      RETURN.
*    ENDIF.
*
*  ENDIF.

ENDFORM.
