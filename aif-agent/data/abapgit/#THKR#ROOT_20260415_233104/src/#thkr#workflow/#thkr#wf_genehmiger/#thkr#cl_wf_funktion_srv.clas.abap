class /THKR/CL_WF_FUNKTION_SRV definition
  public
  final
  create public .

public section.

  constants GC_WF_FUNK_OMSP type /THKR/DTE_WF_ATTR_COND value 'OMSP' ##NO_TEXT.
  class-data GV_LOG type ABAP_BOOL .
  class-data GV_LOG_ALL type ABAP_BOOL .
  data GV_SUPPORT type ABAP_BOOL .
  constants GC_WF_FUNK_PRSP type /THKR/DTE_WF_ATTR_COND value 'PRSP' ##NO_TEXT.

  class-methods CHECK_TESTORG
    importing
      !IT_ATTR_OM type HRTB_PT1222
    returning
      value(RV_RELEVANT) type XFLAG .
  methods GET_SUPPORT
    importing
      !IV_WF_ID type /THKR/DTE_WF_WFTYP
      !IV_FUNK type /THKR/DTE_WF_FUNKTION default 'PRSP'
      !IV_WITH_HOLDER_ONLY type ABAP_BOOL default ABAP_TRUE
      !IV_BUKRS type BUKRS optional
      !IV_GSBER type GSBER optional
      !IT_CONTAINER type SWCONTTAB optional
    returning
      value(RT_PLANS) type /THKR/T_WF_PLANS .
  class-methods GET_USER
    importing
      value(IT_PLANS) type /THKR/T_WF_PLANS
    returning
      value(RT_APPROVERLIST) type MMPUR_T_WFAGENT .
  class-methods CLASS_CONSTRUCTOR .
  methods GET_APPROVER
    importing
      !IV_WF_ID type /THKR/DTE_WF_WFTYP
      !IV_FUNK type /THKR/DTE_WF_FUNKTION
      !IV_WITH_HOLDER_ONLY type ABAP_BOOL default ABAP_TRUE
      !IV_CHECK_RELEVANT type ABAP_BOOL optional
      !IV_LOG type ABAP_BOOL optional
      !IT_ATTR type HRTB_ATTVALUE optional
    returning
      value(RT_PLANS) type /THKR/T_WF_PLANS .
  methods _GET_APPROVER
    importing
      !IV_WF_ID type /THKR/DTE_WF_WFTYP
      !IV_FUNK type /THKR/DTE_WF_FUNKTION
      !IV_WITH_HOLDER_ONLY type ABAP_BOOL default ABAP_TRUE
      !IT_ATTR type HRTB_ATTVALUE
    returning
      value(RT_PLANS) type /THKR/T_WF_PLANS_PRIO .
protected section.

  constants GC_ATTR_COND_KANN type /THKR/DTE_WF_ATTR_COND value 'KANN' ##NO_TEXT.
  constants GC_ATTR_COND_MUSS type /THKR/DTE_WF_ATTR_COND value 'MUSS' ##NO_TEXT.
  data GT_ATTR type /THKR/T_WF_ATTR .
  data GT_PLANS type /THKR/T_WF_PLANS_PRIO .
  class-data GV_CHECK_RELEVANT type ABAP_BOOL .
  data GV_VALUE type STRING .
  class-data GO_CLASSDESCR type ref to CL_ABAP_CLASSDESCR .
  class-data GT_WF_CONTROL type /THKR/T_WF_CONTROL .
  class-data GS_PARAM type /THKR/T_WF_PARAM .

  methods _ZBTRG_BEST
    importing
      !IS_ATTR_I type OMATTVALUE
      !IS_ATTR_OM type PT1222
      !IV_PLANS type PLANS
      !IT_ATTR_OM type HRTB_PT1222
    returning
      value(RV_VALID) type ABAP_BOOL .
  methods _ZEKGRP
    importing
      !IS_ATTR_I type OMATTVALUE
      !IS_ATTR_OM type PT1222
      !IV_PLANS type PLANS
      !IT_ATTR_OM type HRTB_PT1222
    returning
      value(RV_VALID) type ABAP_BOOL .
  methods _ZFIPOS
    importing
      !IS_ATTR_I type OMATTVALUE
      !IS_ATTR_OM type PT1222
      !IV_PLANS type PLANS
      !IT_ATTR_OM type HRTB_PT1222
    returning
      value(RV_VALID) type ABAP_BOOL .
  methods _ZFISTL
    importing
      !IS_ATTR_I type OMATTVALUE
      !IS_ATTR_OM type PT1222
      !IV_PLANS type PLANS
      !IT_ATTR_OM type HRTB_PT1222
    returning
      value(RV_VALID) type ABAP_BOOL .
  methods _ZFKBER
    importing
      !IS_ATTR_I type OMATTVALUE
      !IS_ATTR_OM type PT1222
      !IV_PLANS type PLANS
      !IT_ATTR_OM type HRTB_PT1222
    returning
      value(RV_VALID) type ABAP_BOOL .
  methods _ZFONDS
    importing
      !IS_ATTR_I type OMATTVALUE
      !IS_ATTR_OM type PT1222
      !IV_PLANS type PLANS
      !IT_ATTR_OM type HRTB_PT1222
    returning
      value(RV_VALID) type ABAP_BOOL .
  methods _ZKOSTL
    importing
      !IS_ATTR_I type OMATTVALUE
      !IS_ATTR_OM type PT1222
      !IV_PLANS type PLANS
      !IT_ATTR_OM type HRTB_PT1222
    returning
      value(RV_VALID) type ABAP_BOOL .
private section.

  methods _LOG
    importing
      !IV_ATTR type ANY
      !IV_VALUE type ANY
      !IT_PLANS type /THKR/T_WF_PLANS optional .
ENDCLASS.



CLASS /THKR/CL_WF_FUNKTION_SRV IMPLEMENTATION.


  method CHECK_TESTORG.

     " Verhalten der Methode
    " ---------------------------------------------------------
    " Param	  Orgstruktur 1	  Orgstruktur 2	  relevant ist
    "   X	        X	                           	Org1
    "   X	                       	X	            Org2
    "   X                                       keine
    "   X         X               X           Org1 und Org2
    "                                         Org1 und Org2
    "             X               X           Org1 und Org2
    "  	          X	                         	Org1 und Org2
    "                             X           Org1 und Org2
    " ---------------------------------------------------------

    CONSTANTS: lc_obj TYPE swc_elem VALUE 'ZORGRELEV'.

    IF /thkr/cl_wf_funktion_srv=>gs_param IS INITIAL.
      " Lesen Parametertabelle ob Parameter enthalten
      SELECT SINGLE object, counter, value_von, value_bis FROM /thkr/t_wf_param
                    INTO CORRESPONDING FIELDS OF @/thkr/cl_wf_funktion_srv=>gs_param
                    WHERE object EQ @lc_obj.
      IF sy-subrc <> 0.
        " Aufbau Puffer
        /thkr/cl_wf_funktion_srv=>gs_param-object = lc_obj.
      ENDIF.
    ENDIF.

    " Abfrage ob Prüfung relevant
    IF /thkr/cl_wf_funktion_srv=>gs_param-value_von IS INITIAL.
      rv_relevant = abap_true.
      RETURN.
    ENDIF.

    "Lesen Attributtabelle aus dem OM
    READ TABLE it_attr_om ASSIGNING FIELD-SYMBOL(<ls_attr>) WITH KEY attrib = lc_obj.
    IF sy-subrc = 0 AND <ls_attr>-low IS INITIAL.
      " Testorg soll nicht genutzt werden und Planstelle ist in Testorg
      rv_relevant = abap_false.
    ELSEIF sy-subrc = 0 AND <ls_attr>-low IS NOT INITIAL.
      " Testorg wird genutzt und Planstelle ist in Testorg
      rv_relevant = abap_true.
    ELSEIF sy-subrc <> 0.
      " Testorg und Planstelle nicht relevant
      rv_relevant = abap_false.
    ENDIF.
  endmethod.


  method CLASS_CONSTRUCTOR.

    "Ermittle Workflow-Funktions-Customizing
    SELECT * FROM /thkr/wf_control into CORRESPONDING FIELDS OF TABLE gt_wf_control.
      if sy-subrc is not INITIAL.
        clear gt_wf_control.
        ENDIF.
      "Ermittle Klassen-Type-Instanz
      go_classdescr = CAST cl_abap_classdescr( cl_abap_typedescr=>describe_by_name( '/THKR/CL_WF_FUNKTION_SRV' ) ).

  endmethod.


  method GET_APPROVER.

    DATA: lt_plans  TYPE /thkr/t_wf_plans_prio,
          lt_selopt TYPE rseloption,
          lv_call   TYPE i.

    gv_check_relevant = iv_check_relevant.

    IF iv_log IS SUPPLIED.
      gv_log = iv_log.
    ENDIF.

    DO. " Mehrfacher Aufruf der Genehmigerfindung gemäß Customizing

      ADD 1 TO lv_call. " Aufruf Nummer X

*      " HOTFIX!!!!
      IF lv_call > 1.
        EXIT.
      ENDIF.

      DATA(lt_attr) = it_attr.
*      CLEAR lt_selopt. APPEND VALUE #( sign = 'I' option = 'CP' low = '*' && lv_call && '*') TO lt_selopt.

      IF gv_support IS NOT INITIAL.
        " Für den Support ist nur ein Durchlauf nötig
        IF lv_call > 1.
          EXIT.
        ENDIF.
      ELSE.
        " Ermittle Attribute für Nummer X
        SELECT * FROM /thkr/wf_control INTO TABLE @DATA(lt_funk)
          WHERE
*          aufruf IN @lt_selopt
*          AND
           workflow = @iv_wf_id
          AND funktion = @iv_funk.
        IF sy-subrc IS NOT INITIAL.
          EXIT. " kein weiterer Aufruf
        ELSE.
          " Wende nur Attribute an, die für diesen Durchlauf relevant sind
          LOOP AT lt_attr ASSIGNING FIELD-SYMBOL(<ls_attr>).
            IF NOT line_exists( lt_funk[ attribut = <ls_attr>-attrib ] ).
              DELETE TABLE lt_attr FROM <ls_attr>.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.

      " Ermittle Genehmiger mit relevanten Attributen
      DATA(lt_plans_tmp) = me->_get_approver( iv_wf_id            = iv_wf_id
                                              iv_funk             = iv_funk
                                              iv_with_holder_only = iv_with_holder_only     " Nur besetzte Planstellen relevant?
                                              it_attr             = lt_attr             ).

      " Speichere Planstellen des ersten Aufrufs
      IF lv_call = 1.
        lt_plans = lt_plans_tmp.
        CONTINUE.
      ENDIF.

      " Lösche alle Planstellen, die nicht auch in diesem Aufruf ermittelt wurden
      LOOP AT lt_plans ASSIGNING FIELD-SYMBOL(<ls_plans>).

        READ TABLE lt_plans_tmp ASSIGNING FIELD-SYMBOL(<ls_plans_tmp>) WITH KEY plans = <ls_plans>-plans.
        IF sy-subrc IS INITIAL.
          <ls_plans>-prio = <ls_plans>-prio && <ls_plans_tmp>-prio.
        ELSE.
          DELETE TABLE lt_plans FROM <ls_plans>. " Lösche Planstelle
        ENDIF.
      ENDLOOP.

    ENDDO.

    CHECK lt_plans IS NOT INITIAL.
    SORT lt_plans ASCENDING BY prio.
    DELETE lt_plans WHERE prio <> lt_plans[ 1 ]-prio. " spezifische Treffer haben Vorrang

    MOVE lt_plans TO rt_plans.

  endmethod.


  method GET_SUPPORT.

    CONSTANTS: lc_suppl TYPE om_attrib VALUE 'ZWFLEVEL',
               lc_gsber TYPE om_attrib VALUE 'ZPGSBR',
               lc_bukrs TYPE om_attrib VALUE 'BUKRS'.

    TYPES: BEGIN OF ty_s_funk,
             attribut  TYPE om_attrib,
             ref_tab   TYPE z_om_dte_ref_tab,
             ref_field TYPE z_om_dte_ref_field,
           END OF ty_s_funk.

    DATA: lt_funk TYPE STANDARD TABLE OF ty_s_funk,
          lt_attr TYPE hrtb_attvalue.


    " Ermittle notwendige Attribute für Workflow und Funktion
    LOOP AT gt_wf_control ASSIGNING FIELD-SYMBOL(<ls_func_c>) WHERE workflow = iv_wf_id AND funktion = iv_funk.
      " Aufbau der Attribut Tabelle
      APPEND INITIAL LINE TO lt_funk ASSIGNING FIELD-SYMBOL(<ls_funk>).
      <ls_funk>-attribut = <ls_func_c>-attribut.
    ENDLOOP.
    CHECK lt_funk IS NOT INITIAL.

    " Aufbau der Attribute für Bearbeiterfíndung
    LOOP AT lt_funk ASSIGNING <ls_funk>.

      APPEND INITIAL LINE TO lt_attr ASSIGNING FIELD-SYMBOL(<ls_attr>).
      <ls_attr>-attrib = <ls_funk>-attribut.

        CASE <ls_funk>-attribut.
          WHEN lc_suppl.       "ZWFLEVEL
            " Value wird später gesetzt bei Supportlevel
            CONTINUE.
          WHEN lc_gsber.      "ZPGSBR
            <ls_attr>-value = iv_gsber.
          WHEN lc_bukrs.       "BUKRS
            <ls_attr>-value = iv_bukrs.
        ENDCASE.



    ENDLOOP.

    " Bearbeiter für Support
    DO.
      READ TABLE lt_attr ASSIGNING <ls_attr> WITH KEY attrib = lc_suppl.
      IF sy-subrc <> 0.
        " Hinzufügen des Supportlevels
        APPEND INITIAL LINE TO lt_attr ASSIGNING <ls_attr>.
        <ls_attr>-attrib = lc_suppl.
      ENDIF.
      CASE sy-index.
        WHEN 1.
          <ls_attr>-value = 1.
        WHEN 2.
          <ls_attr>-value = 2.
          " Löschen Attribute
          DELETE lt_attr WHERE ( attrib <> lc_bukrs AND attrib <> lc_suppl ).
        WHEN 3.
          <ls_attr>-value = 3.
          " Nur Level bleibt
          DELETE lt_attr WHERE attrib <> lc_suppl.
      ENDCASE.

      " Ermittle Genehmiger
      DATA(lt_plans) = get_approver( iv_wf_id            = iv_wf_id               " Workflow (BANF, BEST...)
                                     iv_funk             = iv_funk                " Support WF (PRSP)
                                     iv_with_holder_only = iv_with_holder_only    " Nur besetzte Planstellen?
                                     it_attr             = lt_attr             ). " Attribute und Werte

      IF lt_plans IS NOT INITIAL OR sy-index = 3.
        EXIT.
      ENDIF.

    ENDDO.

    " Übergabe an die Schnittstelle
    rt_plans[] = lt_plans.

  endmethod.


  method GET_USER.

     DATA: lt_holder TYPE TABLE OF tree_objec.

    CONSTANTS: lc_wf_admin TYPE sy-uname VALUE 'ZHM000000038'.

    " Ermittle User zu Planstellen
    LOOP AT it_plans ASSIGNING FIELD-SYMBOL(<ls_plans>).

      CLEAR lt_holder.
      CALL FUNCTION 'RH_OM_GET_HOLDER_OF_POSITION'
        EXPORTING
          otype           = 'S'
          objid           = <ls_plans>
        TABLES
          disp_tab        = lt_holder
        EXCEPTIONS
          no_active_plvar = 1
          OTHERS          = 2.
      IF sy-subrc IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      DELETE lt_holder WHERE begda > sy-datum OR endda < sy-datum.

      LOOP AT lt_holder ASSIGNING FIELD-SYMBOL(<ls_holder>). "#EC CI_NESTED

        CASE <ls_holder>-otype.

          WHEN 'US'.
            APPEND <ls_holder>-realo TO rt_approverlist.

          WHEN 'P'.
            SELECT SINGLE usrid FROM pa0105 INTO @DATA(lv_user)
              WHERE pernr = @<ls_holder>-objid
                AND subty = '0001'
                AND begda <= @sy-datum
                AND endda >= @sy-datum.              "#EC CI_SEL_NESTED
            IF sy-subrc IS INITIAL.
              APPEND lv_user TO rt_approverlist.
            ENDIF.

          WHEN 'BP'.
            SELECT SINGLE b~sobid FROM hrp1001 AS a INNER JOIN hrp1001 AS b ON a~objid = b~objid AND
                                                                               b~rsign = 'B' AND
                                                                               b~relat = '209' AND b~sclas = 'P' AND
                                                                               b~istat = '1' AND
                                                                               b~begda <= @sy-datum AND b~endda >= @sy-datum
              INTO @DATA(lv_person)
              WHERE a~sobid = @<ls_holder>-objid
                AND a~sclas = 'BP' AND a~relat = '207' AND a~rsign = 'B'
                AND a~otype = 'CP'
                AND a~begda <= @sy-datum AND a~endda >= @sy-datum.
            IF sy-subrc IS INITIAL.
              SELECT SINGLE usrid FROM pa0105 INTO lv_user
                WHERE pernr = lv_person
                  AND subty = '0001'
                  AND begda <= sy-datum
                  AND endda >= sy-datum.             "#EC CI_SEL_NESTED
              IF sy-subrc IS INITIAL.

              ENDIF.

            ENDIF.

        ENDCASE.

      ENDLOOP.

    ENDLOOP.

    " Setze technischen Workflow-Admin wenn kein User ermittelt werden konnte
    IF rt_approverlist IS INITIAL.
      APPEND lc_wf_admin TO rt_approverlist.
      RETURN.
    ENDIF.

    SORT rt_approverlist.
    DELETE ADJACENT DUPLICATES FROM rt_approverlist.

  endmethod.


  method _GET_APPROVER.

    DATA: lt_attr_om    TYPE hrtb_pt1222,
          lt_plans_copy TYPE /thkr/t_wf_plans_prio,
          lt_selopt     TYPE rseloption,
          lt_plans_log  TYPE TABLE OF plans.

    DATA: lo_data TYPE REF TO data.

    FIELD-SYMBOLS: <lv_value> TYPE any.

    CLEAR rt_plans.

    " Prüfe essentielle Importingparameter
    CHECK iv_wf_id IS NOT INITIAL AND iv_funk IS NOT INITIAL.

    DATA(lt_funk) = gt_wf_control.
    SORT lt_funk BY workflow funktion prio ASCENDING cond DESCENDING.

    " Lösche nicht benötigte Einträge
    DELETE lt_funk WHERE workflow <> iv_wf_id OR funktion <> iv_funk.

    " Spezielle Logik für Supportermittlung
    IF gv_support IS NOT INITIAL.
      LOOP AT lt_funk ASSIGNING FIELD-SYMBOL(<ls_funk>).
        " Prüfung ob Attribut für den Durchlauf benötigt wird
        READ TABLE it_attr TRANSPORTING NO FIELDS WITH KEY attrib = <ls_funk>-attribut.
        IF sy-subrc <> 0.
          " Eintrag wird nicht benötigt
          DELETE lt_funk.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF iv_with_holder_only = abap_true.

      " Ermittle besetzte Planstellen mit der importierten Funktion
      SELECT DISTINCT a~objid FROM hrv1222a AS a INNER JOIN hrp1001 AS b ON b~otype  = 'S'      AND
                                                                            b~objid  = a~objid  AND
                                                                            b~plvar  = a~plvar  AND
                                                                            b~rsign  = 'A'      AND
                                                                            b~relat  = '008'    AND
                                                                            b~begda <= sy-datum AND
                                                                            b~endda >= sy-datum
        INTO TABLE rt_plans
        WHERE a~plvar  = '01'
          AND a~otype  = 'S'
          AND a~begda <= sy-datum
          AND a~endda >= sy-datum
          AND a~attrib = 'ZFUNK'
          AND a~low    = iv_funk
          AND ( b~sclas = 'P' OR b~sclas = 'US' ).                 " Nur Personen oder User
    ELSE.

      " Ermittle ALLE Planstellen mit der importierten Funktion
      SELECT DISTINCT objid FROM hrv1222a
           INTO TABLE rt_plans
           WHERE plvar  = '01'
             AND otype  = 'S'
             AND begda <= sy-datum
             AND endda >= sy-datum
             AND attrib = 'ZFUNK'
             AND low    = iv_funk.

    ENDIF.
    IF sy-subrc IS NOT INITIAL.
      RETURN.
    ENDIF.

    " Ermittle Datentypen der importierten Attribute
    IF it_attr IS NOT INITIAL.
      SELECT attrib refstruct reffield FROM t77omattr INTO CORRESPONDING FIELDS OF TABLE gt_attr
        FOR ALL ENTRIES IN it_attr WHERE attrib = it_attr-attrib.
    ENDIF.

    " Prüfe, ob weitere Funktions-Attributs-Prüfungen gefordert sind
    CHECK lt_funk IS NOT INITIAL.

    DATA(lt_attr) = it_attr.

    MOVE-CORRESPONDING rt_plans TO gt_plans.
    LOOP AT lt_funk ASSIGNING <ls_funk>. " Loop über alle Attribute der Funktion sortiert nach Prio und Kondition/Art

      " Lese importierten Attributwert
      READ TABLE lt_attr ASSIGNING FIELD-SYMBOL(<ls_attr_i>) WITH KEY attrib = <ls_funk>-attribut.
      IF sy-subrc IS NOT INITIAL.
        IF <ls_funk>-cond = gc_attr_cond_muss.
          CLEAR rt_plans.
          RETURN. " MUSS-Parameter wurde nicht versorgt - Suche beenden und keinen Genehmiger zurückgeben
        ELSE.
          CONTINUE. " KANN bzw. ENTWEDER/ODER Parameter wurde nicht versorgt - überspringen und Suche fortsetzen
        ENDIF.
      ENDIF.

      CLEAR: gv_value. "gt_plans_value. " Hilfsvariablen löschen

      " Konvertiere Wert des Attributs
      CLEAR lo_data.
      UNASSIGN: <lv_value>.
      READ TABLE gt_attr ASSIGNING FIELD-SYMBOL(<ls_attr_def>) WITH KEY attrib = <ls_attr_i>-attrib.
      IF sy-subrc IS INITIAL.
        TRY.
            DATA(lv_type) = <ls_attr_def>-refstruct && '-' && <ls_attr_def>-reffield.
            CREATE DATA lo_data TYPE (lv_type).
            ASSIGN lo_data->* TO <lv_value>.
            IF lo_data IS BOUND AND <lv_value> IS ASSIGNED.
              <lv_value> = <ls_attr_i>-value.
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = <lv_value>
                IMPORTING
                  output = <lv_value>.
              <ls_attr_i>-value = <lv_value>.
            ENDIF.
          CATCH cx_root.
        ENDTRY.
      ENDIF.

      " Kopiere aktuell verbleibende Planstellen vor nächster Ausdünnung
      lt_plans_copy = gt_plans.

      " Führe Attributsprüfung für alle Planstellen durch
      LOOP AT gt_plans ASSIGNING FIELD-SYMBOL(<ls_pos>). "#EC CI_SEL_NESTED

        DATA(lv_index) = sy-tabix.

        " Ermittle alle Attribute der Planstelle
        CLEAR lt_attr_om.
        CALL FUNCTION 'RH_OM_ATTRIBUTES_READ'
          EXPORTING
            otype            = 'S'
            objid            = <ls_pos>-plans
            scenario         = 'SSP'
*           BUFFER_REFRESH   = ' '
          TABLES
            attrib           = lt_attr_om
          EXCEPTIONS
            no_active_plvar  = 1
            no_attributes    = 2
            no_values        = 3
            object_not_found = 4
            OTHERS           = 5.
        IF sy-subrc IS NOT INITIAL OR lt_attr_om IS INITIAL. " Keine OM-Daten aufgrund Berechtigungsfehler o.ä.
          DELETE gt_plans INDEX lv_index. " Planstelle aussortieren
          CONTINUE.
        ENDIF.

        DELETE lt_attr_om WHERE excluded = abap_true.

        " Prüfung ob Genehmiger von Testorg abgeleitet werden sollen
        DATA(lv_relevant) = check_testorg( it_attr_om = lt_attr_om ).
        IF lv_relevant IS INITIAL.
          " Planstelle nicht relevant
          DELETE gt_plans.
          CONTINUE.
        ENDIF.

        " Lese alle ermittelten Attributwerte aus OM für das Attribut
        DATA(lv_valid) = abap_false.
        LOOP AT lt_attr_om ASSIGNING FIELD-SYMBOL(<ls_attr_om>) WHERE attrib = <ls_funk>-attribut. "#EC CI_SEL_NESTED

          IF <ls_attr_om>-low = '*'.
            lv_valid = abap_true.
*            IF <ls_funk>-specific_first = abap_true.   "ED
*              <ls_pos>-prio = <ls_pos>-prio && '*'.
*            ENDIF.
            EXIT.
          ENDIF.

          " Prüfe, ob es eine spezielle Untermethode zur Behandlung gibt
          DATA(lv_method) = '_' && <ls_funk>-attribut.
          IF line_exists( go_classdescr->methods[ name = lv_method ] ).

            " Rufe Untermethode zum Vergleich der Werte auf
            CALL METHOD (lv_method)
              EXPORTING
                is_attr_i  = <ls_attr_i>  " Aktuelles importiertes Attribut und Wert
                is_attr_om = <ls_attr_om> " Aktuelles OM-Attribut und Wert
                iv_plans   = <ls_pos>-plans     " Aktuelle Planstelle
                it_attr_om = lt_attr_om   " Alle Attribute und Werte der Planstelle
              RECEIVING
                rv_valid   = lv_valid.

          ELSE.

            " Lösche Planstelle aus Ergebnisliste, wenn Werte abweichen
            CLEAR lt_selopt.
*            APPEND VALUE #( sign = 'I' option = 'CP' low = <ls_attr_om>-low ) TO lt_selopt.                          " Werte mit * berücksichtigen
            APPEND VALUE #( sign = 'I' option = 'BT' low = <ls_attr_om>-low high = <ls_attr_om>-high ) TO lt_selopt. " Ranges berücksichtigen
            IF <ls_attr_i>-value = <ls_attr_om>-low OR <ls_attr_i>-value IN lt_selopt.
              lv_valid = abap_true.

            ELSE.

              APPEND VALUE #( sign = 'I' option = 'CP' low = <ls_attr_om>-low ) TO lt_selopt.                          " Werte mit * berücksichtigen
              IF <ls_attr_i>-value = <ls_attr_om>-low OR <ls_attr_i>-value IN lt_selopt.
                lv_valid = abap_true.
*                IF <ls_funk>-specific_first = abap_true.   "ED
*                  <ls_pos>-prio = <ls_pos>-prio && '*'.
*                ENDIF.
              ENDIF.

            ENDIF.

          ENDIF.

          " Prüfe keine weiteren Attributwerte sobald einer passt
          IF lv_valid = abap_true.
            EXIT.
          ENDIF.

        ENDLOOP.

        " Lösche Planstelle aus Ergebnisliste, wenn kein Attributwert passt
        IF lv_valid = abap_false.
            DELETE gt_plans INDEX lv_index.
        ENDIF.

      ENDLOOP.

      " Prüfe, ob alle Planstellen aussortiert wurden - nehme Aussortierung bei KANN-Attribut zurück
      IF gt_plans IS INITIAL AND <ls_funk>-cond = gc_attr_cond_kann.
        gt_plans = lt_plans_copy.
        MOVE gt_plans TO lt_plans_log.
        me->_log( iv_attr = <ls_attr_i>-attrib iv_value = <ls_attr_i>-value it_plans = lt_plans_log ). " Planstellen
        EXIT.                                    " Aus dem Loop aussteigen, da nachfolgende "Kanns" irrelevant **ED 06.08.2020
      ENDIF.

      " Verlasse LOOP wenn keine Planstellen mehr übrig sind und kein ENTWEDER/ODER läuft
      IF gt_plans IS INITIAL.
        MOVE gt_plans TO lt_plans_log.
        me->_log( iv_attr = <ls_attr_i>-attrib iv_value = <ls_attr_i>-value it_plans = lt_plans_log ). " Planstellen
        EXIT.
      ENDIF.

      MOVE gt_plans TO lt_plans_log.
      me->_log( iv_attr = <ls_attr_i>-attrib iv_value = <ls_attr_i>-value it_plans = lt_plans_log ). " Planstellen

    ENDLOOP.

    rt_plans = gt_plans.

  endmethod.


  method _LOG.

      DATA: lt_pos TYPE TABLE OF plans.

    CHECK gv_log = abap_true.

  IF sy-tcode = 'ZOM_WF_CHECKUSER' and iv_attr = 'BUKRS'.
    exit.
    ENDIF.

    WRITE :/ |Nach Anwendung von | && iv_attr && | mit Wert | && iv_value && | sind noch folgende Planstellen relevant:|.
    LOOP AT it_plans ASSIGNING FIELD-SYMBOL(<lv_pos>).
      SELECT SINGLE stext FROM hrp1000 INTO @DATA(lv_stext) WHERE otype = 'S' AND objid = @<lv_pos> AND begda <= @sy-datum AND endda >= @sy-datum. "#EC CI_SEL_NESTED
      CLEAR lt_pos. APPEND <lv_pos> TO lt_pos.
      DATA(lt_user) = /thkr/cl_wf_funktion_srv=>get_user( it_plans = lt_pos ).
      IF gv_log_all IS INITIAL.
        " Ausgabe des ersten gefundenen User pro Planstelle
        READ TABLE lt_user INTO DATA(lv_user) INDEX 1.
        SELECT SINGLE name_first && ' ' && name_last FROM usr21 INNER JOIN adrp ON usr21~persnumber = adrp~persnumber INTO @DATA(lv_username) WHERE usr21~bname = @lv_user.
        WRITE :/ 'Planstelle: ', <lv_pos>, ' - ', lv_stext, 'User:', lv_user, | - |, lv_username.
        CLEAR lv_user.
      ELSE.
        " Ausgabe aller User die unter der Planstelle hängen
        LOOP AT lt_user ASSIGNING FIELD-SYMBOL(<lv_user>).
          SELECT SINGLE name_first && ' ' && name_last FROM usr21 INNER JOIN adrp ON usr21~persnumber = adrp~persnumber INTO @lv_username WHERE usr21~bname = @<lv_user>.
          WRITE :/ 'Planstelle: ', <lv_pos>, ' - ', lv_stext, 'User:', <lv_user>, | - |, lv_username.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    IF it_plans IS INITIAL.
      WRITE :/ 'Keine'.
    ENDIF.

    WRITE :/.

  ENDMETHOD.


  method _ZBTRG_BEST.

        DATA: lt_selopt TYPE rseloption.

    DATA(lv_value_om) = CONV string( is_attr_om-low ).
    DATA(lv_high_om)  = CONV string( is_attr_om-high ).
    DATA(lv_value_i)  = CONV string( is_attr_i-value ).

    SHIFT lv_value_i LEFT DELETING LEADING '0'.

    SHIFT lv_value_om LEFT DELETING LEADING '0'.
    IF lv_value_om IS INITIAL.
      lv_value_om = CONV string( is_attr_om-low ).
    ENDIF.

    SHIFT lv_high_om LEFT DELETING LEADING '0'.
    IF lv_high_om  IS INITIAL.
      lv_high_om  = CONV string( is_attr_om-high ).
    ENDIF.
    IF lv_high_om  CO 'Z'.
      lv_high_om  = CONV string( is_attr_om-high ).
    ENDIF.


*  >>>> 08.11.2022 - ED
* Entferne auch die Punkte, denn die sind ggf. auch noch da
    REPLACE ALL OCCURRENCES OF `.` IN lv_value_i WITH ``.
    CONDENSE lv_value_i NO-GAPS.
    REPLACE ALL OCCURRENCES OF `.` IN lv_value_om WITH ``.
    CONDENSE lv_value_om NO-GAPS.
    REPLACE ALL OCCURRENCES OF `.` IN  lv_high_om WITH ``.
    CONDENSE lv_high_om NO-GAPS.

*  <<<< 08.11.2022 - ED


    " Prüfe Werte ohne führende Nullen
    APPEND VALUE #( sign = 'I' option = 'CP' low = lv_value_om ) TO lt_selopt.
    APPEND VALUE #( sign = 'I' option = 'BT' low = lv_value_om high = lv_high_om ) TO lt_selopt. " Ranges

    IF lv_value_i = lv_value_om OR lv_value_i IN lt_selopt.
      rv_valid = abap_true.
    ENDIF.

  endmethod.


  METHOD _zekgrp.

    DATA: lt_selopt TYPE rseloption.

    DATA(lv_value_om) = CONV string( is_attr_om-low ).
    DATA(lv_high_om)  = CONV string( is_attr_om-high ).
    DATA(lv_value_i)  = CONV string( is_attr_i-value ).

    SHIFT lv_value_i LEFT DELETING LEADING '0'.

    SHIFT lv_value_om LEFT DELETING LEADING '0'.
    IF lv_value_om IS INITIAL.
      lv_value_om = CONV string( is_attr_om-low ).
    ENDIF.

    SHIFT lv_high_om LEFT DELETING LEADING '0'.
    IF lv_high_om  IS INITIAL.
      lv_high_om  = CONV string( is_attr_om-high ).
    ENDIF.
    IF lv_high_om  CO 'Z'.
      lv_high_om  = CONV string( is_attr_om-high ).
    ENDIF.


*  >>>> 08.11.2022 - ED
* Entferne auch die Punkte, denn die sind ggf. auch noch da
    REPLACE ALL OCCURRENCES OF `.` IN lv_value_i WITH ``.
    CONDENSE lv_value_i NO-GAPS.
    REPLACE ALL OCCURRENCES OF `.` IN lv_value_om WITH ``.
    CONDENSE lv_value_om NO-GAPS.
    REPLACE ALL OCCURRENCES OF `.` IN  lv_high_om WITH ``.
    CONDENSE lv_high_om NO-GAPS.

*  <<<< 08.11.2022 - ED


    " Prüfe Werte ohne führende Nullen
    APPEND VALUE #( sign = 'I' option = 'CP' low = lv_value_om ) TO lt_selopt.
    APPEND VALUE #( sign = 'I' option = 'BT' low = lv_value_om high = lv_high_om ) TO lt_selopt. " Ranges

    IF lv_value_i = lv_value_om OR lv_value_i IN lt_selopt.
      rv_valid = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD _zfipos.

    DATA: lt_selopt TYPE rseloption.

    DATA(lv_value_om) = CONV string( is_attr_om-low ).
    DATA(lv_high_om)  = CONV string( is_attr_om-high ).
    DATA(lv_value_i)  = CONV string( is_attr_i-value ).

    SHIFT lv_value_i LEFT DELETING LEADING '0'.

    SHIFT lv_value_om LEFT DELETING LEADING '0'.
    IF lv_value_om IS INITIAL.
      lv_value_om = CONV string( is_attr_om-low ).
    ENDIF.

    SHIFT lv_high_om LEFT DELETING LEADING '0'.
    IF lv_high_om  IS INITIAL.
      lv_high_om  = CONV string( is_attr_om-high ).
    ENDIF.
    IF lv_high_om  CO 'Z'.
      lv_high_om  = CONV string( is_attr_om-high ).
    ENDIF.


*  >>>> 08.11.2022 - ED
* Entferne auch die Punkte, denn die sind ggf. auch noch da
    REPLACE ALL OCCURRENCES OF `.` IN lv_value_i WITH ``.
    CONDENSE lv_value_i NO-GAPS.
    REPLACE ALL OCCURRENCES OF `.` IN lv_value_om WITH ``.
    CONDENSE lv_value_om NO-GAPS.
    REPLACE ALL OCCURRENCES OF `.` IN  lv_high_om WITH ``.
    CONDENSE lv_high_om NO-GAPS.

*  <<<< 08.11.2022 - ED


    " Prüfe Werte ohne führende Nullen
    APPEND VALUE #( sign = 'I' option = 'CP' low = lv_value_om ) TO lt_selopt.
    APPEND VALUE #( sign = 'I' option = 'BT' low = lv_value_om high = lv_high_om ) TO lt_selopt. " Ranges

    IF lv_value_i = lv_value_om OR lv_value_i IN lt_selopt.
      rv_valid = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD _zfistl.

    DATA: lt_selopt TYPE rseloption.

    DATA(lv_value_om) = CONV string( is_attr_om-low ).
    DATA(lv_high_om)  = CONV string( is_attr_om-high ).
    DATA(lv_value_i)  = CONV string( is_attr_i-value ).

    SHIFT lv_value_i LEFT DELETING LEADING '0'.

    SHIFT lv_value_om LEFT DELETING LEADING '0'.
    IF lv_value_om IS INITIAL.
      lv_value_om = CONV string( is_attr_om-low ).
    ENDIF.

    SHIFT lv_high_om LEFT DELETING LEADING '0'.
    IF lv_high_om  IS INITIAL.
      lv_high_om  = CONV string( is_attr_om-high ).
    ENDIF.
    IF lv_high_om  CO 'Z'.
      lv_high_om  = CONV string( is_attr_om-high ).
    ENDIF.


**  >>>> 08.11.2022 - ED
** Entferne auch die Punkte, denn die sind ggf. auch noch da
    REPLACE ALL OCCURRENCES OF `.` IN lv_value_i WITH ``.
    CONDENSE lv_value_i NO-GAPS.
    REPLACE ALL OCCURRENCES OF `.` IN lv_value_om WITH ``.
    CONDENSE lv_value_om NO-GAPS.
    REPLACE ALL OCCURRENCES OF `.` IN  lv_high_om WITH ``.
    CONDENSE lv_high_om NO-GAPS.
*
**  <<<< 08.11.2022 - ED


    " Prüfe Werte ohne führende Nullen
    APPEND VALUE #( sign = 'I' option = 'CP' low = lv_value_om ) TO lt_selopt.
    APPEND VALUE #( sign = 'I' option = 'BT' low = lv_value_om high = lv_high_om ) TO lt_selopt. " Ranges

    IF lv_value_i = lv_value_om OR lv_value_i IN lt_selopt.
      rv_valid = abap_true.
    ENDIF.

  ENDMETHOD.


  method _ZFKBER.

        DATA: lt_selopt TYPE rseloption.

    DATA(lv_value_om) = CONV string( is_attr_om-low ).
    DATA(lv_high_om)  = CONV string( is_attr_om-high ).
    DATA(lv_value_i)  = CONV string( is_attr_i-value ).

    SHIFT lv_value_i LEFT DELETING LEADING '0'.

    SHIFT lv_value_om LEFT DELETING LEADING '0'.
    IF lv_value_om IS INITIAL.
      lv_value_om = CONV string( is_attr_om-low ).
    ENDIF.

    SHIFT lv_high_om LEFT DELETING LEADING '0'.
    IF lv_high_om  IS INITIAL.
      lv_high_om  = CONV string( is_attr_om-high ).
    ENDIF.
    IF lv_high_om  CO 'Z'.
      lv_high_om  = CONV string( is_attr_om-high ).
    ENDIF.


**  >>>> 08.11.2022 - ED
** Entferne auch die Punkte, denn die sind ggf. auch noch da
*    REPLACE ALL OCCURRENCES OF REGEX `[[:punct:]]` IN lv_value_i WITH ``.
*    CONDENSE lv_value_i NO-GAPS.
*    REPLACE ALL OCCURRENCES OF REGEX `[[:punct:]]` IN lv_value_om WITH ``.
*    CONDENSE lv_value_om NO-GAPS.
*    REPLACE ALL OCCURRENCES OF REGEX `[[:punct:]]` IN  lv_high_om WITH ``.
*    CONDENSE lv_high_om NO-GAPS.
*
**  <<<< 08.11.2022 - ED


    " Prüfe Werte ohne führende Nullen
    APPEND VALUE #( sign = 'I' option = 'CP' low = lv_value_om ) TO lt_selopt.
    APPEND VALUE #( sign = 'I' option = 'BT' low = lv_value_om high = lv_high_om ) TO lt_selopt. " Ranges

    IF lv_value_i = lv_value_om OR lv_value_i IN lt_selopt.
      rv_valid = abap_true.
    ENDIF.

  endmethod.


  method _ZFONDS.

        DATA: lt_selopt TYPE rseloption.

    DATA(lv_value_om) = CONV string( is_attr_om-low ).
    DATA(lv_high_om)  = CONV string( is_attr_om-high ).
    DATA(lv_value_i)  = CONV string( is_attr_i-value ).

    SHIFT lv_value_i LEFT DELETING LEADING '0'.

    SHIFT lv_value_om LEFT DELETING LEADING '0'.
    IF lv_value_om IS INITIAL.
      lv_value_om = CONV string( is_attr_om-low ).
    ENDIF.

    SHIFT lv_high_om LEFT DELETING LEADING '0'.
    IF lv_high_om  IS INITIAL.
      lv_high_om  = CONV string( is_attr_om-high ).
    ENDIF.
    IF lv_high_om  CO 'Z'.
      lv_high_om  = CONV string( is_attr_om-high ).
    ENDIF.


**  >>>> 08.11.2022 - ED
** Entferne auch die Punkte, denn die sind ggf. auch noch da
*    REPLACE ALL OCCURRENCES OF REGEX `[[:punct:]]` IN lv_value_i WITH ``.
*    CONDENSE lv_value_i NO-GAPS.
*    REPLACE ALL OCCURRENCES OF REGEX `[[:punct:]]` IN lv_value_om WITH ``.
*    CONDENSE lv_value_om NO-GAPS.
*    REPLACE ALL OCCURRENCES OF REGEX `[[:punct:]]` IN  lv_high_om WITH ``.
*    CONDENSE lv_high_om NO-GAPS.
*
**  <<<< 08.11.2022 - ED


    " Prüfe Werte ohne führende Nullen
    APPEND VALUE #( sign = 'I' option = 'CP' low = lv_value_om ) TO lt_selopt.
    APPEND VALUE #( sign = 'I' option = 'BT' low = lv_value_om high = lv_high_om ) TO lt_selopt. " Ranges

    IF lv_value_i = lv_value_om OR lv_value_i IN lt_selopt.
      rv_valid = abap_true.
    ENDIF.

  endmethod.


  method _ZKOSTL.

        DATA: lt_selopt TYPE rseloption.

    DATA(lv_value_om) = CONV string( is_attr_om-low ).
    DATA(lv_high_om)  = CONV string( is_attr_om-high ).
    DATA(lv_value_i)  = CONV string( is_attr_i-value ).

    SHIFT lv_value_i LEFT DELETING LEADING '0'.

    SHIFT lv_value_om LEFT DELETING LEADING '0'.
    IF lv_value_om IS INITIAL.
      lv_value_om = CONV string( is_attr_om-low ).
    ENDIF.

    SHIFT lv_high_om LEFT DELETING LEADING '0'.
    IF lv_high_om  IS INITIAL.
      lv_high_om  = CONV string( is_attr_om-high ).
    ENDIF.
    IF lv_high_om  CO 'Z'.
      lv_high_om  = CONV string( is_attr_om-high ).
    ENDIF.


*  >>>> 08.11.2022 - ED
* Entferne auch die Punkte, denn die sind ggf. auch noch da
        REPLACE ALL OCCURRENCES OF `.` IN lv_value_i WITH ``.
    CONDENSE lv_value_i NO-GAPS.
    REPLACE ALL OCCURRENCES OF `.` IN lv_value_om WITH ``.
    CONDENSE lv_value_om NO-GAPS.
    REPLACE ALL OCCURRENCES OF `.` IN  lv_high_om WITH ``.
    CONDENSE lv_high_om NO-GAPS.

*  <<<< 08.11.2022 - ED


    " Prüfe Werte ohne führende Nullen
    APPEND VALUE #( sign = 'I' option = 'CP' low = lv_value_om ) TO lt_selopt.
    APPEND VALUE #( sign = 'I' option = 'BT' low = lv_value_om high = lv_high_om ) TO lt_selopt. " Ranges

    IF lv_value_i = lv_value_om OR lv_value_i IN lt_selopt.
      rv_valid = abap_true.
    ENDIF.

  endmethod.
ENDCLASS.
