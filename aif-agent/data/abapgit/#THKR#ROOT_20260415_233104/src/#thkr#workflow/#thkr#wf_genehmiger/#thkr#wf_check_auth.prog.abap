*&---------------------------------------------------------------------*
*& Include          /THKR/WF_CHECK_AUTH
*&---------------------------------------------------------------------*
 IF  reiter_nummer-activetab EQ 'T_ZWEI'.
  IF p_obj2 IS NOT INITIAL.
      lv_ber_otype = p_obj2.
      lt_ber_objid = s_objid2[].
    ENDIF.

    IF lv_ber_otype IS INITIAL.
      MESSAGE 'Bitte geben Sie O, S oder P für Reiter 1 und O oder S für Reiter 2 und 3 ein.'  TYPE 'E'  ##NO_TEXT.
    ENDIF.

    IF lt_ber_objid IS INITIAL.
      MESSAGE 'Bitte fügen Sie mindestens eine Objekt-ID ein.' TYPE 'E' ##NO_TEXT.
    ENDIF.

    IF lv_ber_otype = 'P'.
      SELECT DISTINCT pernr
              FROM pa0001
              INTO TABLE @lt_sel_p_s_o
              WHERE pernr IN @lt_ber_objid AND begda LE @sy-datum  AND endda GE @sy-datum.

    ELSEIF lv_ber_otype = 'O' OR lv_ber_otype = 'S'.
      SELECT DISTINCT objid
              FROM hrp1000
              WHERE objid IN @lt_ber_objid AND otype = @lv_ber_otype AND plvar = '01'
              AND begda LE @sy-datum  AND endda GE @sy-datum
              INTO TABLE @lt_sel_p_s_o.
    ELSE.
      MESSAGE 'Bitte geben Sie O, S oder P für Reiter 1 und O oder S für Reiter 2 ein.'  TYPE 'E'  ##NO_TEXT.
    ENDIF.

    IF lt_sel_p_s_o IS INITIAL.
      MESSAGE 'Selektierte Werte nicht vorhanden (HRP1000/PA0001).' TYPE 'E' ##NO_TEXT.
    ENDIF.

    LOOP AT lt_sel_p_s_o ASSIGNING FIELD-SYMBOL(<fs_selectber>).
      CALL FUNCTION 'RH_STRU_AUTHORITY_CHECK'
        EXPORTING
*         FCODE                    = 'DISP'
          plvar                    = '01'
          otype                    = lv_ber_otype
          objid                    = <fs_selectber>
*         WITH_BASE_AC             = 'X'
        EXCEPTIONS
          no_stru_authority        = 1
          no_stru_authority_hyper  = 2
          no_stru_authority_at_all = 3
          no_base_authority        = 4
          OTHERS                   = 5.

      IF sy-subrc <> 0.
        MESSAGE 'Sie haben keine Berechtigung. Strukturelle Berechtigungsprüfung laut T77UA und T77PR fehlgeschlagen.' TYPE 'E' ##NO_TEXT.
      ENDIF.
    ENDLOOP.

************************************************************************
* Berechtigung:  Bukrs und Personalbereich und Personalteilbereich     *
************************************************************************
    IF lv_ber_otype = 'P'.

      CLEAR: lt_ber_om_gesamt, lt_objid_ber, lt_ber_om.
      LOOP AT lt_sel_p_s_o ASSIGNING FIELD-SYMBOL(<fs_ber_om_p>).

        SELECT pernr, bukrs, werks, btrtl
               FROM pa0001 INTO TABLE @DATA(lt_ber_om_tmp)
               WHERE pernr = @<fs_ber_om_p> AND begda LE @sy-datum AND endda GE @sy-datum.

        IF sy-subrc = 0.
          LOOP AT lt_ber_om_tmp ASSIGNING FIELD-SYMBOL(<fs_ber_tmp>).
            ls_ber_om-otype = lv_ber_otype.
            ls_ber_om-objid = <fs_ber_tmp>-pernr.
            ls_ber_om-bukrs = <fs_ber_tmp>-bukrs.
            ls_ber_om-persa = <fs_ber_tmp>-werks.
            ls_ber_om-btrtl = <fs_ber_tmp>-btrtl.
            APPEND ls_ber_om  TO lt_ber_om.
            CLEAR ls_ber_om.
          ENDLOOP.

          APPEND LINES OF lt_ber_om TO lt_ber_om_gesamt.
          CLEAR lt_ber_om.
        ENDIF.
      ENDLOOP.


    ELSEIF lv_ber_otype = 'O' OR lv_ber_otype = 'S' .


      IF lv_ber_otype = 'O'.
        lv_wegid = 'O-O'.
      ELSE.
        lv_wegid = 'S-O'.
      ENDIF.

      CLEAR: lt_ber_om_gesamt, lt_objid_ber, lt_ber_om, lv_distl_ok, lt_hrp1008_g.
      LOOP AT lt_sel_p_s_o ASSIGNING FIELD-SYMBOL(<fs_ber_om>).

        CALL FUNCTION 'RH_PM_GET_IT1008'
          EXPORTING
            p_plvar = '01'
            p_otype = lv_ber_otype
            p_objid = <fs_ber_om>
            p_begda = sy-datum
            p_endda = sy-datum
            p_istat = '1'
          TABLES
            pt_1008 = lt_hrp1008.

        DELETE lt_hrp1008 WHERE bukrs IS INITIAL AND
                                persa IS INITIAL AND
                                btrtl IS INITIAL.

        IF lt_hrp1008 IS INITIAL.
          lv_distl_ok = ''.
        ELSE.
          lv_distl_ok = 'X'.
          APPEND LINES OF lt_hrp1008 TO lt_hrp1008_g.
          CONTINUE.
        ENDIF.
        CLEAR lt_hrp1008.

        " nichts gefunden, weiter im OM nach oben gehen
        IF lv_distl_ok = ''.

          CALL FUNCTION 'RH_STRUC_GET'
            EXPORTING
              act_otype      = lv_ber_otype
              act_objid      = <fs_ber_om>
              act_wegid      = lv_wegid
              act_plvar      = '01'
            TABLES
              result_tab     = result_tab_ac
            EXCEPTIONS
              no_plvar_found = 1
              no_entry_found = 2
              OTHERS         = 3.

          IF sy-subrc = 0.

            LOOP AT result_tab_ac ASSIGNING FIELD-SYMBOL(<fs_objid_ber>) WHERE otype = 'O'.

              lv_objid = CONV #( <fs_objid_ber>-objid ).

              CALL FUNCTION 'RH_PM_GET_IT1008'
                EXPORTING
                  p_plvar = '01'
                  p_otype = <fs_objid_ber>-otype
                  p_objid = lv_objid
                  p_begda = sy-datum
                  p_endda = sy-datum
                  p_istat = '1'
                TABLES
                  pt_1008 = lt_hrp1008.

              DELETE lt_hrp1008 WHERE bukrs IS INITIAL AND
                                      persa IS INITIAL AND
                                      btrtl IS INITIAL.


              IF lt_hrp1008 IS INITIAL.
                lv_distl_ok = ''.
              ELSE.
                lv_distl_ok = 'X'.
                APPEND LINES OF lt_hrp1008 TO lt_hrp1008_g.
                EXIT.
              ENDIF.
            ENDLOOP.

            CLEAR lt_hrp1008.


            IF lv_distl_ok = '' AND lv_ber_otype = 'S'.

              LOOP AT result_tab_ac ASSIGNING FIELD-SYMBOL(<fs_objid_ber2>) WHERE otype = 'O'.

                lv_objid = CONV #( <fs_objid_ber2>-objid ).

                CALL FUNCTION 'RH_STRUC_GET'
                  EXPORTING
                    act_otype      = 'O'
                    act_objid      = lv_objid
                    act_wegid      = 'O-O'
                    act_plvar      = '01'
                  TABLES
                    result_tab     = result_tab_ac2
                  EXCEPTIONS
                    no_plvar_found = 1
                    no_entry_found = 2
                    OTHERS         = 3.

                LOOP AT result_tab_ac2 ASSIGNING FIELD-SYMBOL(<fs_ber_s>) WHERE otype = 'O'.
                  lv_objid = CONV #( <fs_ber_s>-objid ).

                  CALL FUNCTION 'RH_PM_GET_IT1008'
                    EXPORTING
                      p_plvar = '01'
                      p_otype = 'O'
                      p_objid = lv_objid
                      p_begda = sy-datum
                      p_endda = sy-datum
                      p_istat = '1'
                    TABLES
                      pt_1008 = lt_hrp1008.

                  DELETE lt_hrp1008 WHERE bukrs IS INITIAL AND
                                          persa IS INITIAL AND
                                          btrtl IS INITIAL.

                  IF lt_hrp1008 IS INITIAL.
                    lv_distl_ok = ''.
                  ELSE.
                    lv_distl_ok = 'X'.
                    APPEND LINES OF lt_hrp1008 TO lt_hrp1008_g.
                    EXIT.
                  ENDIF.
                ENDLOOP.

              ENDLOOP.

            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

    ELSE.
      MESSAGE 'Bitte geben Sie O oder S ein.'  TYPE 'E'  ##NO_TEXT.
    ENDIF.

    SORT lt_hrp1008_g.
    DELETE ADJACENT DUPLICATES FROM lt_hrp1008_g COMPARING bukrs persa btrtl.

*    " Land
*    AUTHORITY-CHECK OBJECT 'ZOM_VERI'
*        ID 'ACTVT' FIELD '03'
*        ID 'BUKRS' DUMMY
*        ID 'PERSA' DUMMY
*        ID 'BTRTL' DUMMY
*        ID 'ZOM_HIERE' FIELD 'BW'.
*
*    IF sy-subrc IS NOT INITIAL.
*
*      LOOP AT lt_hrp1008_g ASSIGNING FIELD-SYMBOL(<fs_ber_zver_om>).
*
*        " RS
*        AUTHORITY-CHECK OBJECT 'ZOM_VERI'
*          ID 'ACTVT' FIELD '03'
*          ID 'BUKRS' FIELD <fs_ber_zver_om>-bukrs
*          ID 'PERSA' DUMMY
*          ID 'BTRTL' DUMMY
*          ID 'ZOM_HIERE' FIELD 'RS'.
*
*        CHECK sy-subrc IS NOT INITIAL.
*
*        " DS
*        AUTHORITY-CHECK OBJECT 'ZOM_VERI'
*          ID 'ACTVT' FIELD '03'
*          ID 'BUKRS' FIELD <fs_ber_zver_om>-bukrs
*          ID 'PERSA' FIELD <fs_ber_zver_om>-persa
*          ID 'BTRTL' FIELD <fs_ber_zver_om>-btrtl
*          ID 'ZOM_HIERE' FIELD 'DS'.
*
*        IF sy-subrc <> 0.
*          MESSAGE |Sie haben keine Berechtigung. ZOM_VERI (DS) [ BUKRS: { <fs_ber_zver_om>-bukrs }, PERSA: { <fs_ber_zver_om>-persa }, BTRTL: { <fs_ber_zver_om>-btrtl }].| TYPE 'E' ##NO_TEXT.
*        ENDIF.
*      ENDLOOP.
*
*      IF sy-subrc IS NOT INITIAL.
*        MESSAGE |Berechtigungsprüfung fehlgeschlagen. BUKRS, PERSA und BTRTL nicht in HRP1008 entlang der Organisationsstruktur gefunden.| TYPE 'E' ##NO_TEXT.
*      ENDIF.
*
*    ENDIF.

  ENDIF.
