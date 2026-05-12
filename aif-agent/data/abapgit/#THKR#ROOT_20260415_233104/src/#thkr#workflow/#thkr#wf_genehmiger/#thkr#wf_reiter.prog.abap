*&---------------------------------------------------------------------*
*& Include          /THKR/WF_REITER
*&---------------------------------------------------------------------*

************************************************************************
*          Reiter 2, "Einzelabfrage                                    *
************************************************************************
    IF p_par3 = 'X'.

************************************************************************
*        Eigabe-Bereich eingrenzen,  NUR S und O                       *
************************************************************************
      IF p_obj2 IS INITIAL OR ( p_obj2 NE 'O' AND p_obj2 NE 'S' ).
        MESSAGE 'Bitte geben Sie O oder S ein.'  TYPE 'E' ##NO_TEXT.
      ENDIF.

************************************************************************
*       Einzelabfrage ID holen + Gültigkeit prüfen                     *
************************************************************************
      IF s_objid2 IS NOT INITIAL.

        SELECT DISTINCT objid
        FROM hrp1000
        INTO @ls_selectopt2
        WHERE objid IN @s_objid2 AND otype = @p_obj2 AND plvar = '01'
        AND begda <=  @sy-datum  AND endda >= @sy-datum.
          APPEND ls_selectopt2 TO lt_selectopt2.
        ENDSELECT.

        lv_nummer = 1.

************************************************************************
*       Für IDs Attribute lesen             " Hauptloop Einzelabfrage  *
************************************************************************
        CLEAR lt_pr_zpgsbr_werks.

        IF lt_selectopt2 IS NOT INITIAL.
          LOOP AT lt_selectopt2 ASSIGNING FIELD-SYMBOL(<fs_sel_opt2>).

            CALL FUNCTION 'RH_OM_ATTRIBUTES_READ'
              EXPORTING
                plvar            = '01'
                otype            = p_obj2
                objid            = <fs_sel_opt2>
                scenario         = 'SSP'
                seldate          = sy-datum
              TABLES
                attrib           = lt_attrib2
                attrib_ext       = lt_attrib_ext2
              EXCEPTIONS
                no_active_plvar  = 1
                no_attributes    = 2
                no_values        = 3
                object_not_found = 4
                OTHERS           = 5.

            CASE sy-subrc.
              WHEN '0'.

                LOOP AT lt_attrib_ext2 ASSIGNING FIELD-SYMBOL(<fs_lt_attrib_ext2>).
                  ls_struc_attr-nummer     =  lv_nummer .
                  ls_struc_attr-objekttyp  =  p_obj2.
                  ls_struc_attr-objektid   =  <fs_sel_opt2>.
                  ls_struc_attr-attrib     =  <fs_lt_attrib_ext2>-attrib.
                  ls_struc_attr-low        =  <fs_lt_attrib_ext2>-low.
                  ls_struc_attr-high       =  <fs_lt_attrib_ext2>-high.
                  ls_struc_attr-excluded   =  <fs_lt_attrib_ext2>-excluded.
                  ls_struc_attr-defaultval =  <fs_lt_attrib_ext2>-defaultval.
                  ls_struc_attr-inherited  =  <fs_lt_attrib_ext2>-inherited.
                  ls_struc_attr-inherit    =  <fs_lt_attrib_ext2>-inherit.
                  ls_struc_attr-inh_otype  =  <fs_lt_attrib_ext2>-inh_otype.
                  ls_struc_attr-inh_objid  =  <fs_lt_attrib_ext2>-inh_objid.

                  " Text
                  SELECT SINGLE atext INTO @DATA(lv_atext) FROM t77omattrt WHERE attrib = @<fs_lt_attrib_ext2>-attrib AND langu = 'D' . "#EC CI_NOORDER
                  ls_struc_attr-atext = lv_atext.
                  CLEAR lv_atext.

                  IF ls_struc_attr-objekttyp = 'S'.
                    ls_struc_attr-zfunk_no_exist = 'X'.
                  ELSE.
                    ls_struc_attr-zfunk_no_exist = ''.
                  ENDIF.

                  APPEND ls_struc_attr TO lt_struc_attr_gesamt_erw.
                ENDLOOP.
                CLEAR ls_struc_attr.

************************************************************************
*                      Protokoll-Tabelle                               *
************************************************************************
                "  APPEND LINES OF lt_struc_attr_gesamt_erw TO lt_struc_attr_erw_end_pr.

************************************************************************
*                      Feld Condition (muss/kann).                     *
************************************************************************
                LOOP AT lt_struc_attr_gesamt_erw ASSIGNING FIELD-SYMBOL(<fs_abc>) WHERE attrib = 'ZFUNK' AND objekttyp = 'S'.
                  IF <fs_abc>-attrib = 'ZFUNK' AND <fs_abc>-objekttyp = 'S' AND <fs_abc>-nummer = lv_nummer .

                    DATA(lv_wert) = <fs_abc>-low.

                    SELECT * FROM /THKR/WF_CONTROL INTO TABLE @DATA(lt_data) WHERE funktion = @lv_wert.

                    LOOP AT lt_struc_attr_gesamt_erw ASSIGNING FIELD-SYMBOL(<fs_a>).
                      <fs_a>-zfunk_no_exist = ''.
                      LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_b>).
                        IF <fs_a>-attrib = <fs_b>-attribut.
                          <fs_a>-condition = <fs_b>-cond.
                          <fs_a>-vorhanden = 'X'.
                          <fs_a>-status = k_icon_green.

                          SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @<fs_b>-attribut AND langu = 'D' . "#EC CI_NOORDER
                          <fs_a>-atext =  lv_attr_txt.
                          CLEAR lv_attr_txt.

                          IF <fs_a>-text IS NOT INITIAL.
                            CONCATENATE <fs_a>-text <fs_b>-funktion INTO DATA(text) SEPARATED BY space.
                            IF strlen( text ) < 180.
                              <fs_a>-text = text.
                            ENDIF.                      "#EC CI_NOORDER
                          ELSE.
                            <fs_a>-text = |ZFUNK: { <fs_b>-funktion }|.
                          ENDIF.

                          EXIT.                         "#EC CI_NOORDER
                        ENDIF.
                      ENDLOOP.
                    ENDLOOP.
                  ENDIF.
                ENDLOOP. " lt_struc_attr_gesamt_erw

                CLEAR lt_data.

************************************************************************
*  existierende Atribute für ZOM_WF_FUNK auslesen                      *
************************************************************************
                SELECT attrib, low, condition
                       FROM @lt_struc_attr_gesamt_erw AS attr  ##ITAB_KEY_IN_SELECT
                       WHERE ( condition IS NOT INITIAL OR attrib = 'ZFUNK' ) AND nummer = @lv_nummer
                INTO TABLE @DATA(lt_result).


                IF lt_result IS NOT INITIAL.

************************************************************************
*  alle notwendige Attribute FUNK holen aus zom_wf_funk_c              *
************************************************************************
                  LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_attr_c>) WHERE attrib = 'ZFUNK'.
                    SELECT attribut AS attrib , cond AS condition , funktion
                    FROM /THKR/WF_CONTROL
                    WHERE funktion = @<fs_attr_c>-low
                    INTO TABLE @DATA(lt_result_zom_tpm).
                    APPEND LINES OF lt_result_zom_tpm TO lt_result_zom.
                    CLEAR lt_result_zom_tpm.
                  ENDLOOP.

                  SORT lt_result_zom.
                  DELETE ADJACENT DUPLICATES FROM lt_result_zom.

************************************************************************
*  Ptüfen bestehende/fehlende Attr.   Falls fehlen, einfügen           *
************************************************************************
                  CLEAR lt_result_zom_tmp.
                  LOOP AT lt_result_zom  ASSIGNING FIELD-SYMBOL(<fs_t>).
                    IF <fs_t>-attrib NE ''.

                      " Sonderlogik BRTWR
                      IF <fs_t>-attrib EQ 'BRTWR'.
                        READ TABLE lt_struc_attr_gesamt_erw
                          WITH KEY attrib = 'ZFRGVGB' nummer = lv_nummer objekttyp = 'S'
                          INTO DATA(lv_zfrgvgb).
                        IF sy-subrc IS INITIAL AND lv_zfrgvgb-low IS NOT INITIAL.

                          READ TABLE lt_struc_attr_gesamt_erw
                        WITH KEY attrib = 'ZFRGVGS' nummer = lv_nummer objekttyp = 'S'
                        INTO DATA(lv_zfrgvgs).
                          IF sy-subrc IS INITIAL AND lv_zfrgvgs-low IS NOT INITIAL.
                            CONTINUE.
                          ENDIF.
                        ENDIF.
                      ENDIF.


                      IF NOT line_exists( lt_struc_attr_gesamt_erw[ attrib = <fs_t>-attrib nummer = lv_nummer objekttyp = 'S'  ] ).  " condition = <fs_t>-condition  !!!

                        CLEAR ls_result_zom_tmp.
                        ls_result_zom_tmp-attrib    = <fs_t>-attrib.
                        ls_result_zom_tmp-condition = <fs_t>-condition.
                        ls_result_zom_tmp-funktion  = <fs_t>-funktion.
                        APPEND ls_result_zom_tmp TO lt_result_zom_tmp.

                      ENDIF.
                    ENDIF.
                  ENDLOOP.

                  SORT lt_result_zom_tmp.

                  " fehlende Attribute
                  LOOP AT lt_result_zom_tmp ASSIGNING FIELD-SYMBOL(<fs_result_zom_tmp>) GROUP BY <fs_result_zom_tmp>-attrib.
                    CLEAR: lv_muss, lv_kann.

                    DATA(lt_res_tmp) = VALUE struc_attr_tmp( FOR <p_tb> IN GROUP <fs_result_zom_tmp> ( <p_tb> ) ).

                    LOOP AT lt_res_tmp ASSIGNING FIELD-SYMBOL(<fs_res>).

                      IF <fs_res>-condition = 'MUSS'.
                        CONCATENATE lv_muss <fs_res>-funktion INTO lv_muss SEPARATED BY space.
                      ELSE.
                        CONCATENATE lv_kann <fs_res>-funktion INTO lv_kann SEPARATED BY space.
                      ENDIF.

                    ENDLOOP.

                    READ TABLE lt_res_tmp INTO DATA(lv_attr_tmp) INDEX 1.

                    IF sy-subrc = 0.
                      ls_struc_attr_gesamt_erw-nummer = lv_nummer.
                      ls_struc_attr_gesamt_erw-objekttyp = p_obj2.
                      ls_struc_attr_gesamt_erw-objektid  = <fs_sel_opt2>.
                      ls_struc_attr_gesamt_erw-attrib = lv_attr_tmp-attrib.
                      ls_struc_attr_gesamt_erw-vorhanden = ''.
                      SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @lv_attr_tmp-attrib AND langu = 'D' . "#EC CI_NOORDER
                      ls_struc_attr_gesamt_erw-atext = lv_attr_txt.
                      CLEAR lv_attr_txt.

                      IF lv_muss IS NOT INITIAL.
                        SHIFT lv_muss  LEFT BY 1 PLACES.
                        ls_struc_attr_gesamt_erw-condition = 'MUSS'.
                        ls_struc_attr_gesamt_erw-status = k_icon_red.
                        ls_struc_attr_gesamt_erw-text = |Attribut für { lv_muss } nicht vorhanden.| ##NO_TEXT.

                        APPEND ls_struc_attr_gesamt_erw TO lt_struc_attr_gesamt_erw.
                      ENDIF.

                      IF lv_kann IS NOT INITIAL.
                        SHIFT lv_kann  LEFT BY 1 PLACES.
                        ls_struc_attr_gesamt_erw-condition = 'KANN'.
                        ls_struc_attr_gesamt_erw-status = k_icon_yellow.
                        ls_struc_attr_gesamt_erw-text = |Attribut für { lv_kann } nicht vorhanden.| ##NO_TEXT.
                        APPEND ls_struc_attr_gesamt_erw TO lt_struc_attr_gesamt_erw.
                      ENDIF.

                      CLEAR ls_struc_attr_gesamt_erw.

                    ENDIF.
                  ENDLOOP.


                ELSE.  " ZFUNK nicht existiert.
                  IF p_obj2 = 'S'.
                    SELECT SINGLE plsty   " ob virtuell ?
                             FROM hrp9808
                             WHERE plvar = '01' AND otype = @p_obj2 AND objid = @<fs_sel_opt2> AND begda <= @sy-datum AND endda >= @sy-datum
                    INTO @DATA(l_v).                    "#EC CI_NOORDER

                    IF sy-subrc = 0 AND l_v = 'V'.

                      " Alle Rollen lesen
                      SELECT otype, objid, subty, sobid
                                            FROM hrp1001
                                            WHERE objid = @<fs_sel_opt2> AND otype = 'S' AND sclas = 'AG' AND begda <= @sy-datum AND endda >= @sy-datum AND plvar = '01'
                      INTO TABLE @DATA(lt_r_et).

                      IF lt_r_et IS NOT INITIAL AND sy-subrc = 0.

                        " obligatorische Funktionen holen
                        LOOP AT lt_r_et ASSIGNING FIELD-SYMBOL(<fs_lt_r_et>).

                          DATA(lv_rll_t) = <fs_lt_r_et>-sobid+0(2).
                          DATA(lv_rll_n)  = <fs_lt_r_et>-sobid+2(2).

                          SELECT SINGLE funktion FROM @lt_tab_result AS rff
                              WHERE typ_rolle = @lv_rll_t AND rolle_nr = @lv_rll_n
                          INTO @DATA(lt_tmp_f_e) ##ITAB_KEY_IN_SELECT ##ITAB_DB_SELECT.

                          IF sy-subrc = 0 AND lt_tmp_f_e IS NOT INITIAL.
                            APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2>  attrib = 'ZFUNK'
                            vorhanden = '' status =  k_icon_red text = 'Attribut ZFUNK ist nicht vorhanden.' ) TO lt_struc_attr_gesamt_erw.
                            CLEAR ls_struc_attr_gesamt_erw.
                            CONTINUE.
                          ENDIF.

                        ENDLOOP.

                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.

                CLEAR lt_result.

************************************************************************
*          entsprechend den Funktionen die richtigen Rollen            *
************************************************************************
                IF  p_obj2 = 'S'.

                  SELECT *
                         FROM @lt_struc_attr_gesamt_erw AS tab
                         WHERE nummer = @lv_nummer AND attrib = 'ZFUNK' AND low IS NOT INITIAL
                  INTO TABLE @DATA(result_table) ##db_feature_mode[itabs_in_from_clause] ##ITAB_KEY_IN_SELECT.

                  IF result_table IS NOT INITIAL.

                    LOOP AT result_table ASSIGNING FIELD-SYMBOL(<fs_erw_sttruc>).
                      SELECT * FROM @lt_tab_result AS res
                      WHERE funktion = @<fs_erw_sttruc>-low
                      INTO TABLE @DATA(lt_tmp_rolle) ##ITAB_KEY_IN_SELECT ##ITAB_DB_SELECT.
                      APPEND LINES OF lt_tmp_rolle TO lt_rolle_name_table.
                      CLEAR lt_tmp_rolle.
                    ENDLOOP.

                    SORT lt_rolle_name_table BY typ_rolle rolle_nr funktion.
                    DELETE ADJACENT DUPLICATES FROM lt_rolle_name_table COMPARING typ_rolle rolle_nr funktion.

                    IF lt_rolle_name_table IS NOT INITIAL.

                      LOOP AT result_table ASSIGNING FIELD-SYMBOL(<fs_tpm_no_exist>).
                        IF NOT line_exists( lt_rolle_name_table[ funktion = <fs_tpm_no_exist>-low ] ).

                          APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2>  attrib = ''
                                 condition = '' status =  k_icon_yellow text = |AG nicht definiert: { <fs_tpm_no_exist>-low }. | ) TO lt_struc_attr_gesamt_erw.
                          CLEAR ls_struc_attr_gesamt_erw.

                        ENDIF.
                      ENDLOOP.

                      LOOP AT lt_rolle_name_table ASSIGNING FIELD-SYMBOL(<fs_rl>).
                        CONCATENATE <fs_rl>-typ_rolle  <fs_rl>-rolle_nr '%' INTO DATA(lv_rolle_name).

                        SELECT SINGLE otype, objid, subty, sobid
                          FROM hrp1001
                          WHERE objid = @<fs_sel_opt2> AND sclas = 'AG' AND sobid LIKE @lv_rolle_name AND begda <= @sy-datum AND endda >= @sy-datum AND plvar = '01'
                        INTO @DATA(lv_rolle_exist).

                        IF sy-subrc = 0.

                          CLEAR arg_text.
                          SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.

                          APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2> attrib = 'ZFUNK'
                                 condition = '' agr_text = arg_text status = k_icon_green text = |AG: { <fs_rl>-typ_rolle }{ <fs_rl>-rolle_nr } für { <fs_rl>-funktion }.| ) TO lt_struc_attr_gesamt_erw.
                          CLEAR ls_struc_attr_gesamt_erw.

****************************************************************************************************************
                          " Wenn Rolle existiert, Rolleninhalt aus agr1252 mit MUSS/KANN Attributen vergleichen*
****************************************************************************************************************

                          SELECT  otype, objid, subty, sobid
                              FROM hrp1001
                              WHERE objid = @<fs_sel_opt2> AND sclas = 'AG' AND sobid LIKE @lv_rolle_name AND begda <= @sy-datum AND endda >= @sy-datum AND plvar = '01'
                          INTO TABLE @DATA(lt_rolle_tb).

                          SELECT * FROM @lt_struc_attr_gesamt_erw AS lt
                                     WHERE nummer = @lv_nummer AND attrib IS NOT INITIAL  AND  status NE @k_icon_red AND status NE @k_icon_yellow
                          INTO TABLE @DATA(lt_dat_tab) ##ITAB_KEY_IN_SELECT.

                          LOOP AT lt_rolle_tb ASSIGNING FIELD-SYMBOL(<fs_lt_rolle_tb>).

                            SELECT child_agr FROM agr_agrs WHERE agr_name = @<fs_lt_rolle_tb>-sobid
                            INTO TABLE @DATA(agrs_tmp).

                            IF agrs_tmp IS NOT INITIAL AND lt_dat_tab IS NOT INITIAL AND lt_t77omattot IS NOT INITIAL.
                              CLEAR: lt_agr1252, lt_field_values, lt_field_values_end, lt_field_values_tmp.

                              LOOP AT agrs_tmp ASSIGNING FIELD-SYMBOL(<fs_agrs>).
                                SELECT * FROM agr_1252
                                WHERE agr_name = @<fs_agrs>-child_agr AND low NE '*' AND low NE ''
                                INTO TABLE @lt_agr1252_tmp.
                                APPEND LINES OF lt_agr1252_tmp TO lt_agr1252.
                                CLEAR lt_agr1252_tmp.

                                " berechtigungswerte zur rolle ermitteln
                                CALL FUNCTION 'PRGN_1251_READ_FIELD_VALUES'
                                  EXPORTING
                                    activity_group = <fs_agrs>-child_agr
                                  TABLES
                                    field_values   = lt_field_values
                                  EXCEPTIONS
                                    OTHERS         = 0.

                                " als "gelöscht" markierte Einträge entfernen
                                DELETE lt_field_values
                                       WHERE NOT deleted IS INITIAL. "#EC CI_STDSEQ

                                MOVE-CORRESPONDING lt_field_values TO lt_field_values_tmp.
                                CLEAR lt_field_values.

                                LOOP AT lt_field_values_tmp ASSIGNING FIELD-SYMBOL(<fs_end>) WHERE agr_name IS INITIAL.
                                  <fs_end>-agr_name = <fs_agrs>-child_agr.
                                ENDLOOP.

                                APPEND LINES OF lt_field_values_tmp TO lt_field_values_end.
                                CLEAR lt_field_values_tmp.

                              ENDLOOP.

                              " UR12C nur wichtige Rollenwerte prüfen gegen Attribute
                              DATA(lt_rl_wrt) = VALUE ty_ur12c( FOR i IN lt_tab_result
                                                                      WHERE ( typ_rolle = <fs_rl>-typ_rolle AND
                                                                              rolle_nr  = <fs_rl>-rolle_nr )
                                                                      ( i ) ).

                              SORT lt_rl_wrt BY funktion.
                              DELETE ADJACENT DUPLICATES FROM lt_rl_wrt COMPARING funktion.

                              CLEAR lt_r1_wrt_attr.
                              LOOP AT lt_rl_wrt ASSIGNING FIELD-SYMBOL(<fs_r1_wrt>).
                                SELECT attribut AS attrib, cond AS condition, funktion
                                     FROM /THKR/WF_CONTROL APPENDING TABLE @lt_r1_wrt_attr
                                WHERE funktion = @<fs_r1_wrt>-funktion.
                              ENDLOOP.

                              SORT lt_r1_wrt_attr BY attrib.
                              DELETE ADJACENT DUPLICATES FROM lt_r1_wrt_attr COMPARING attrib.

                            ENDIF.


                            CLEAR attr_rng.
                            IF lt_agr1252 IS NOT INITIAL.

                              DELETE lt_agr1252 WHERE low CS '$' OR
                                                      low CS '''' OR
                                                      low EQ 'DUMMY'.

                              SORT lt_agr1252 BY agr_name varbl.

                              LOOP AT lt_agr1252 ASSIGNING FIELD-SYMBOL(<fs_lt_agr1252>) WHERE low NE '*' GROUP BY <fs_lt_agr1252>-varbl.

                                SELECT *
                                  FROM @lt_tab_result_13c AS t_13c
                                  WHERE typ_orgebene = @<fs_lt_agr1252>-varbl
                                INTO TABLE @DATA(lt_org_13c) ##db_feature_mode[itabs_in_from_clause] ##ITAB_KEY_IN_SELECT.

                                CLEAR attr_rng.
                                LOOP AT lt_org_13c ASSIGNING FIELD-SYMBOL(<fs_org_13c>).

                                  READ TABLE lt_t77omattot WITH KEY attrib = <fs_org_13c>-attrib TRANSPORTING NO FIELDS.

                                  IF sy-subrc = 0.

                                    " UR12C nur wichtige Rollenwerte prüfen gegen Attribute
                                    IF NOT line_exists( lt_r1_wrt_attr[ attrib = <fs_org_13c>-attrib  ] ).
                                      DELETE lt_org_13c.
                                      CONTINUE.
                                    ENDIF.
                                    ""

                                    IF NOT line_exists( lt_dat_tab[ attrib = <fs_org_13c>-attrib  ] ).

                                      ls_struc_attr_gesamt_erw-nummer = lv_nummer.
                                      ls_struc_attr_gesamt_erw-objekttyp = p_obj2.
                                      ls_struc_attr_gesamt_erw-objektid = <fs_sel_opt2>.
                                      ls_struc_attr_gesamt_erw-attrib = <fs_org_13c>-attrib.
                                      ls_struc_attr_gesamt_erw-atext = <fs_org_13c>-text.

                                      CLEAR arg_text.
                                      SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.

                                      ls_struc_attr_gesamt_erw-agr_text = arg_text.
*                                     ls_struc_attr_gesamt_erw-condition = 'MUSS'.
                                      ls_struc_attr_gesamt_erw-low  =  <fs_lt_agr1252>-low.
                                      ls_struc_attr_gesamt_erw-high  = <fs_lt_agr1252>-high.
                                      ls_struc_attr_gesamt_erw-status =  k_icon_red.
                                      ls_struc_attr_gesamt_erw-text  = |Attr. aus { <fs_lt_agr1252>-agr_name } fehlt. Sammelrolle: { <fs_rl>-typ_rolle }{ <fs_rl>-rolle_nr }.| ##NO_TEXT .
                                      IF NOT line_exists( lt_struc_attr_gesamt_erw[ table_line = ls_struc_attr_gesamt_erw ] ).
                                        APPEND ls_struc_attr_gesamt_erw TO lt_struc_attr_gesamt_erw.
                                      ENDIF.
                                      CLEAR ls_struc_attr_gesamt_erw.

                                    ELSE.

                                      DATA(lt_partn_tb_1252) = VALUE lt_agr_1252( FOR <partn_tb_2> IN GROUP <fs_lt_agr1252> ( <partn_tb_2> ) ).

                                      LOOP AT lt_partn_tb_1252 ASSIGNING FIELD-SYMBOL(<lt_partn_tb_1252>).

                                        IF <lt_partn_tb_1252>-high IS INITIAL.
                                          IF <lt_partn_tb_1252>-low CS '*'.
                                            option = 'CP'.
                                          ELSE.
                                            option = 'EQ'.
                                          ENDIF.
                                        ELSE.
                                          option = 'BT'.

                                          IF <lt_partn_tb_1252>-high CS 'Z'.
                                            REPLACE ALL OCCURRENCES OF 'Z' IN <fs_lt_agr1252>-high WITH '9'.
                                          ENDIF.
                                        ENDIF.

                                        APPEND LINES OF VALUE rseloption( ( sign   = 'I'
                                                                            option = option
                                                                            low    = <lt_partn_tb_1252>-low
                                                                            high   = <lt_partn_tb_1252>-high ) ) TO attr_rng.


                                        IF <lt_partn_tb_1252>-high IS NOT INITIAL.
                                          IF <lt_partn_tb_1252>-low CS '*'.
                                            APPEND LINES OF VALUE rseloption( ( sign   = 'I'
                                                                                option = 'CP'
                                                                                low    = <lt_partn_tb_1252>-low
                                                                                high   = '' ) ) TO attr_rng.
                                          ENDIF.

                                          IF <lt_partn_tb_1252>-high CS '*'.
                                            APPEND LINES OF VALUE rseloption( ( sign   = 'I'
                                                                                option = 'CP'
                                                                                low    = <lt_partn_tb_1252>-high
                                                                                high   = '' ) ) TO attr_rng.
                                          ENDIF.
                                        ENDIF.

                                      ENDLOOP.
                                      "CLEAR lt_partn_tb_1252.

                                    ENDIF.

                                  ENDIF.
                                ENDLOOP.

                                SORT attr_rng.
                                DELETE ADJACENT DUPLICATES FROM attr_rng.

                                " Vergleich
                                LOOP AT lt_org_13c ASSIGNING FIELD-SYMBOL(<fs_vgl>).

                                  SELECT objekttyp, objektid, attrib , low, high FROM @lt_dat_tab AS itab_dat
                                   WHERE attrib = @<fs_vgl>-attrib AND nummer = @lv_nummer
                                  INTO TABLE @DATA(lv_treff_diff).

                                  LOOP AT lv_treff_diff ASSIGNING FIELD-SYMBOL(<lv_treff_diff>).

                                    IF <lv_treff_diff>-low CS '000000000' AND
                                       <lv_treff_diff>-high CS 'ZZZZZZZZZ'.
                                      CONTINUE.
                                    ENDIF.

                                    IF <lv_treff_diff>-high IS INITIAL.

                                      IF <lv_treff_diff>-low NOT IN attr_rng.

                                        LOOP AT lt_partn_tb_1252 ASSIGNING FIELD-SYMBOL(<fs_ber_cell>).

                                          ls_struc_attr_gesamt_erw-nummer = lv_nummer.
                                          ls_struc_attr_gesamt_erw-objekttyp = p_obj2.
                                          ls_struc_attr_gesamt_erw-objektid = <fs_sel_opt2>.
                                          ls_struc_attr_gesamt_erw-attrib = <fs_vgl>-attrib.
                                          ls_struc_attr_gesamt_erw-atext = <fs_vgl>-text.
                                          CLEAR arg_text.
                                          SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.
                                          ls_struc_attr_gesamt_erw-agr_text = arg_text.
*                                         ls_struc_attr_gesamt_erw-condition = <fs_lt_agr>.
                                          ls_struc_attr_gesamt_erw-low  =  <fs_ber_cell>-low.
                                          ls_struc_attr_gesamt_erw-high  = <fs_ber_cell>-high.
                                          ls_struc_attr_gesamt_erw-status =  k_icon_red.
                                          ls_struc_attr_gesamt_erw-text  =
                                          |Wert-Differenz { <fs_ber_cell>-agr_name }. Sammelrolle: { <fs_rl>-typ_rolle }{ <fs_rl>-rolle_nr } [ vgl. { <fs_vgl>-attrib }: { <lv_treff_diff>-low } ].| ##NO_TEXT.
                                          IF NOT line_exists( lt_struc_attr_gesamt_erw[ table_line = ls_struc_attr_gesamt_erw ] ).
                                            APPEND ls_struc_attr_gesamt_erw TO lt_struc_attr_gesamt_erw.
                                          ENDIF.
                                          CLEAR ls_struc_attr_gesamt_erw.

                                        ENDLOOP.


                                      ENDIF.
                                    ELSE.
                                      IF <lv_treff_diff>-low NOT IN attr_rng OR <lv_treff_diff>-high NOT IN attr_rng.

                                        LOOP AT lt_partn_tb_1252 ASSIGNING FIELD-SYMBOL(<fs_ber_cell2>).

                                          ls_struc_attr_gesamt_erw-nummer = lv_nummer.
                                          ls_struc_attr_gesamt_erw-objekttyp = p_obj2.
                                          ls_struc_attr_gesamt_erw-objektid = <fs_sel_opt2>.
                                          ls_struc_attr_gesamt_erw-attrib = <fs_vgl>-attrib.
                                          ls_struc_attr_gesamt_erw-atext = <fs_vgl>-text.
                                          CLEAR arg_text.
                                          SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.
                                          ls_struc_attr_gesamt_erw-agr_text = arg_text.
*                                         ls_struc_attr_gesamt_erw-condition = <fs_lt_agr>.
                                          ls_struc_attr_gesamt_erw-low  =  <fs_ber_cell2>-low.
                                          ls_struc_attr_gesamt_erw-high  = <fs_ber_cell2>-high.
                                          ls_struc_attr_gesamt_erw-status =  k_icon_red.
                                          ls_struc_attr_gesamt_erw-text  =
                          |Wert-Differenz { <fs_ber_cell2>-agr_name }. Sammelrolle: { <fs_rl>-typ_rolle }{ <fs_rl>-rolle_nr } [ vgl. { <fs_vgl>-attrib }: { <lv_treff_diff>-low }-{ <lv_treff_diff>-high } ].| ##NO_TEXT.
                                          IF NOT line_exists( lt_struc_attr_gesamt_erw[ table_line = ls_struc_attr_gesamt_erw ] ).
                                            APPEND ls_struc_attr_gesamt_erw TO lt_struc_attr_gesamt_erw.
                                          ENDIF.
                                          CLEAR ls_struc_attr_gesamt_erw.

                                        ENDLOOP.

                                      ENDIF.
                                    ENDIF.
                                  ENDLOOP.
                                ENDLOOP.
                                CLEAR lt_partn_tb_1252.

                              ENDLOOP.

                            ENDIF.

                            CLEAR lt_partn_tb_1252.
                            CLEAR attr_rng.
                            DELETE lt_field_values_end WHERE low EQ '*' OR
                                                             low EQ 'DUMMY' OR
                                                             low CS '$' OR
                                                             low CS '''' OR
                                                             low IS INITIAL.

                            SORT lt_field_values_end BY object field low high.
                            DELETE ADJACENT DUPLICATES FROM lt_field_values_end COMPARING object field low high.

                            IF lt_field_values_end IS NOT INITIAL.
                              LOOP AT lt_field_values_end  ASSIGNING FIELD-SYMBOL(<fs_values_1251>) GROUP BY <fs_values_1251>-field.

                                READ TABLE lt_tab_result_02xxl WITH KEY typ_rolle = <fs_values_1251>-agr_name+0(2)
                                                                        rolle_nr = <fs_values_1251>-agr_name+2(2)
                                                                        objekt = <fs_values_1251>-object
                                                                        feld =  <fs_values_1251>-field
                                                                        ASSIGNING FIELD-SYMBOL(<fs_02xxl>).

                                CHECK sy-subrc = 0 AND <fs_02xxl>-typ_berecht IS NOT INITIAL.

                                IF <fs_02xxl>-typ_berecht = 'FISTL' OR <fs_02xxl>-typ_berecht = 'FIPEX'.
                                  IF <fs_values_1251>-low EQ '9999' OR <fs_values_1251>-low EQ 'TECH*'.
                                    CONTINUE.
                                  ENDIF.
                                ENDIF.

                                " sonder-Verarbeitung
                                /THKR/CL_CHECK_KOMPL=>ber_obj_special_procedure(
                                  EXPORTING
                                    iv_object = <fs_values_1251>-object
                                    iv_field  = <fs_values_1251>-field
                                  CHANGING
                                    iv_low    = <fs_values_1251>-low
                                    iv_high   = <fs_values_1251>-high
                                ).

                                SELECT *
                                 FROM @lt_tab_result_13c AS t_13c_b
                                 WHERE typ_berecht = @<fs_02xxl>-typ_berecht
                                INTO TABLE @DATA(lt_org_13c_ber) ##db_feature_mode[itabs_in_from_clause] ##ITAB_KEY_IN_SELECT.

                                CLEAR attr_rng.
                                LOOP AT lt_org_13c_ber ASSIGNING FIELD-SYMBOL(<fs_ber_13c>).
                                  READ TABLE lt_t77omattot WITH KEY attrib = <fs_ber_13c>-attrib TRANSPORTING NO FIELDS.

                                  IF sy-subrc = 0.

                                    " UR12C nur wichtige Rollenwerte prüfen gegen Attribute
                                    IF NOT line_exists( lt_r1_wrt_attr[ attrib = <fs_ber_13c>-attrib  ] ).
                                      DELETE lt_org_13c_ber.
                                      CONTINUE.
                                    ENDIF.

                                    ""

                                    IF NOT line_exists( lt_dat_tab[ attrib = <fs_ber_13c>-attrib  ] ).

                                      ls_struc_attr_gesamt_erw-nummer = lv_nummer.
                                      ls_struc_attr_gesamt_erw-objekttyp = p_obj2.
                                      ls_struc_attr_gesamt_erw-objektid = <fs_sel_opt2>.
                                      ls_struc_attr_gesamt_erw-attrib = <fs_ber_13c>-attrib.
                                      ls_struc_attr_gesamt_erw-atext = <fs_ber_13c>-text.
                                      CLEAR arg_text.
                                      SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.
                                      ls_struc_attr_gesamt_erw-agr_text = arg_text.
*                                     ls_struc_attr_gesamt_erw-condition = 'MUSS'.
                                      ls_struc_attr_gesamt_erw-low  =  <fs_values_1251>-low.
                                      ls_struc_attr_gesamt_erw-high  = <fs_values_1251>-high.
                                      ls_struc_attr_gesamt_erw-status =  k_icon_red.
                                      ls_struc_attr_gesamt_erw-text  = |Attr. aus { <fs_values_1251>-agr_name } fehlt. Sammelrolle: { <fs_rl>-typ_rolle }{ <fs_rl>-rolle_nr }. Objekt: { <fs_values_1251>-object }.| ##NO_TEXT .

                                      IF NOT line_exists( lt_struc_attr_gesamt_erw[ table_line = ls_struc_attr_gesamt_erw ] ).
                                        APPEND ls_struc_attr_gesamt_erw TO lt_struc_attr_gesamt_erw.
                                      ENDIF.
                                      CLEAR ls_struc_attr_gesamt_erw.

                                    ELSE.


                                      DATA(lt_partn_tb) = VALUE lt_agr_1251( FOR <partn_tb> IN GROUP <fs_values_1251> ( <partn_tb> ) ).


                                      LOOP AT lt_partn_tb ASSIGNING FIELD-SYMBOL(<lt_partn_tb>).

                                        IF <fs_02xxl>-typ_berecht = 'FISTL' OR <fs_02xxl>-typ_berecht = 'FIPEX'.
                                          IF <lt_partn_tb>-low EQ '9999' OR <lt_partn_tb>-low EQ 'TECH*'.
                                            DELETE lt_partn_tb.
                                            CONTINUE.
                                          ENDIF.
                                        ENDIF.

                                        " sonder-Verarbeitung
                                        /THKR/CL_CHECK_KOMPL=>ber_obj_special_procedure(
                                          EXPORTING
                                            iv_object = <lt_partn_tb>-object
                                            iv_field  = <lt_partn_tb>-field
                                          CHANGING
                                            iv_low    = <lt_partn_tb>-low
                                            iv_high   = <lt_partn_tb>-high
                                        ).

                                        IF <lt_partn_tb>-high IS INITIAL.
                                          IF <lt_partn_tb>-low CS '*'.
                                            option = 'CP'.
                                          ELSE.
                                            option = 'EQ'.
                                          ENDIF.
                                        ELSE.
                                          option = 'BT'.

                                          IF <lt_partn_tb>-high CS 'Z'.
                                            REPLACE ALL OCCURRENCES OF 'Z' IN <lt_partn_tb>-high WITH '9'.
                                          ENDIF.
                                        ENDIF.

                                        APPEND LINES OF VALUE rseloption( ( sign   = 'I'
                                                                            option = option
                                                                            low    = <lt_partn_tb>-low
                                                                            high   = <lt_partn_tb>-high ) ) TO attr_rng.

                                        IF <lt_partn_tb>-high IS NOT INITIAL.
                                          IF <lt_partn_tb>-low CS '*'.
                                            APPEND LINES OF VALUE rseloption( ( sign   = 'I'
                                                                                option = 'CP'
                                                                                low    = <lt_partn_tb>-low
                                                                                high   = '' ) ) TO attr_rng.
                                          ENDIF.

                                          IF <lt_partn_tb>-high CS '*'.
                                            APPEND LINES OF VALUE rseloption( ( sign   = 'I'
                                                                                option = 'CP'
                                                                                low    = <lt_partn_tb>-high
                                                                                high   = '' ) ) TO attr_rng.
                                          ENDIF.
                                        ENDIF.

                                      ENDLOOP.
                                      "CLEAR lt_partn_tb.

                                    ENDIF.

                                  ENDIF.
                                ENDLOOP.

                                SORT attr_rng.
                                DELETE ADJACENT DUPLICATES FROM attr_rng.

                                " Vergleich
                                LOOP AT lt_org_13c_ber ASSIGNING FIELD-SYMBOL(<fs_vgl_ber>).

                                  SELECT objekttyp, objektid, attrib , low, high FROM @lt_dat_tab AS itab_dat
                                   WHERE attrib = @<fs_vgl_ber>-attrib AND nummer = @lv_nummer
                                  INTO TABLE @DATA(lv_treff_difff).

                                  LOOP AT lv_treff_difff ASSIGNING FIELD-SYMBOL(<lv_treff_difff>).

                                    IF <lv_treff_difff>-low  CS '000000000' AND
                                       <lv_treff_difff>-high CS 'ZZZZZZZZZ'.
                                      CONTINUE.
                                    ENDIF.

                                    IF <lv_treff_difff>-attrib EQ 'ZTITEL' OR
                                       <lv_treff_difff>-attrib EQ 'ZTITEL_AO'.
                                      <lv_treff_difff>-low = <lv_treff_difff>-low+0(9).
                                      <lv_treff_difff>-high = <lv_treff_difff>-high+0(9).
                                    ENDIF.

                                    IF <lv_treff_difff>-high IS INITIAL.
                                      IF <lv_treff_difff>-low NOT IN attr_rng.

                                        LOOP AT lt_partn_tb ASSIGNING FIELD-SYMBOL(<fs_ber_cell3>).
                                          ls_struc_attr_gesamt_erw-nummer = lv_nummer.
                                          ls_struc_attr_gesamt_erw-objekttyp = p_obj2.
                                          ls_struc_attr_gesamt_erw-objektid = <fs_sel_opt2>.
                                          ls_struc_attr_gesamt_erw-attrib = <fs_vgl_ber>-attrib.
                                          ls_struc_attr_gesamt_erw-atext = <fs_vgl_ber>-text.
                                          CLEAR arg_text.
                                          SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.
                                          ls_struc_attr_gesamt_erw-agr_text = arg_text.
*                                         ls_struc_attr_gesamt_erw-condition = <fs_lt_agr>.
                                          ls_struc_attr_gesamt_erw-low  =  <fs_ber_cell3>-low.
                                          ls_struc_attr_gesamt_erw-high  = <fs_ber_cell3>-high.
                                          ls_struc_attr_gesamt_erw-status =  k_icon_red.
                                          ls_struc_attr_gesamt_erw-text  =
 |Wert-Differenz { <fs_ber_cell3>-agr_name }. Sammelrolle: { <fs_rl>-typ_rolle }{ <fs_rl>-rolle_nr }. Objekt: { <fs_values_1251>-object } [ vgl. { <fs_vgl_ber>-attrib }: { <lv_treff_difff>-low } ].| ##NO_TEXT.

                                          IF NOT line_exists( lt_struc_attr_gesamt_erw[ table_line = ls_struc_attr_gesamt_erw ] ).
                                            APPEND ls_struc_attr_gesamt_erw TO lt_struc_attr_gesamt_erw.
                                          ENDIF.
                                          CLEAR ls_struc_attr_gesamt_erw.
                                        ENDLOOP.

                                      ENDIF.
                                    ELSE.
                                      IF <lv_treff_difff>-low NOT IN attr_rng OR <lv_treff_difff>-high NOT IN attr_rng.

                                        LOOP AT lt_partn_tb ASSIGNING FIELD-SYMBOL(<fs_ber_cell4>).

                                          ls_struc_attr_gesamt_erw-nummer = lv_nummer.
                                          ls_struc_attr_gesamt_erw-objekttyp = p_obj2.
                                          ls_struc_attr_gesamt_erw-objektid = <fs_sel_opt2>.
                                          ls_struc_attr_gesamt_erw-attrib = <fs_vgl_ber>-attrib.
                                          ls_struc_attr_gesamt_erw-atext = <fs_vgl_ber>-text.
                                          CLEAR arg_text.
                                          SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.
                                          ls_struc_attr_gesamt_erw-agr_text = arg_text.
*                                         ls_struc_attr_gesamt_erw-condition = <fs_lt_agr>.
                                          ls_struc_attr_gesamt_erw-low  =  <fs_ber_cell4>-low.
                                          ls_struc_attr_gesamt_erw-high  = <fs_ber_cell4>-high.
                                          ls_struc_attr_gesamt_erw-status =  k_icon_red.
                                          ls_struc_attr_gesamt_erw-text  =
|Wert-Differenz { <fs_ber_cell4>-agr_name }. Sammelrolle: { <fs_rl>-typ_rolle }{ <fs_rl>-rolle_nr }. Objekt: { <fs_values_1251>-object } [ vgl. { <fs_vgl_ber>-attrib }: { <lv_treff_difff>-low }-{ <lv_treff_difff>-high } ].| ##NO_TEXT.

                                          IF NOT line_exists( lt_struc_attr_gesamt_erw[ table_line = ls_struc_attr_gesamt_erw ] ).
                                            APPEND ls_struc_attr_gesamt_erw TO lt_struc_attr_gesamt_erw.
                                          ENDIF.
                                          CLEAR ls_struc_attr_gesamt_erw.

                                        ENDLOOP.


                                      ENDIF.
                                    ENDIF.
                                  ENDLOOP.
                                ENDLOOP.
                                CLEAR lt_partn_tb.
                              ENDLOOP.
                            ENDIF.
                            CLEAR lt_partn_tb_1252.
                          ENDLOOP.
                          CLEAR: lt_rolle_tb, attr_rng.

********************************************************************************************************
                        ELSE.
******************************************************************************************************************************************
* 18.01.2022 14:29:28  REPRO-KOE: mindestens eine passende FR vorhanden ist -> Warnmeldung. Wenn gar keine passende FR  – Fehlermeldung. *
******************************************************************************************************************************************

                          UNASSIGN <fs_w_e>.
                          LOOP AT lt_rolle_name_table ASSIGNING FIELD-SYMBOL(<fs_w>) WHERE funktion = <fs_rl>-funktion.
                            CONCATENATE <fs_w>-typ_rolle  <fs_w>-rolle_nr '%' INTO DATA(lv_r_w).

                            SELECT SINGLE otype, objid, subty, sobid
                            FROM hrp1001
                            WHERE objid = @<fs_sel_opt2> AND otype = 'S' AND sclas = 'AG' AND sobid LIKE @lv_r_w AND begda <= @sy-datum AND endda >= @sy-datum AND plvar = '01'
                            INTO @DATA(lv_rolle_w).

                            IF sy-subrc = 0.
                              ASSIGN k_icon_green TO <fs_w_e>.
                              EXIT.
                            ENDIF.


                            CLEAR lv_exist.

                            LOOP AT lt_tab_result_11xxl ASSIGNING FIELD-SYMBOL(<fs_11xxl_data>).

                              CALL FUNCTION 'Z_NSI_AGR_RFC_EXIST_ON_PLANS'
                                DESTINATION <fs_11xxl_data>-rfcdest
                                EXPORTING
                                  typ_rolle = <fs_w>-typ_rolle
                                  rolle_nr  = <fs_w>-rolle_nr
                                  plans     = <fs_sel_opt2>
                                IMPORTING
                                  rv_exist  = lv_exist.

                              IF lv_exist = 'X'.
                                ASSIGN k_icon_green TO <fs_w_e>.
                                EXIT.
                              ENDIF.
                            ENDLOOP.

                            IF lv_exist = 'X'.
                              EXIT.
                            ENDIF.
                          ENDLOOP.

                          IF <fs_w_e> IS NOT ASSIGNED.
                            ASSIGN k_icon_red TO <fs_w_e>.
                          ENDIF.

******************************************************************************************************************************************
                          IF <fs_w_e> IS ASSIGNED.

                            CLEAR arg_text.
                            SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name AND spras = 'D' AND line = '00000' AND text NE '' INTO  @arg_text.

                            CLEAR lv_exist.

                            LOOP AT lt_tab_result_11xxl ASSIGNING FIELD-SYMBOL(<fs_11xxl_data2>).

                              CALL FUNCTION 'Z_NSI_AGR_RFC_EXIST_ON_PLANS'
                                DESTINATION <fs_11xxl_data2>-rfcdest
                                EXPORTING
                                  typ_rolle = <fs_rl>-typ_rolle
                                  rolle_nr  = <fs_rl>-rolle_nr
                                  plans     = <fs_sel_opt2>
                                IMPORTING
                                  rv_exist  = lv_exist.

                              IF lv_exist = 'X'.
                                DATA(lv_rfc_system) = <fs_11xxl_data2>-rfcdest.
                                EXIT.
                              ENDIF.
                            ENDLOOP.

                            IF sy-subrc IS NOT INITIAL.
                              APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2> attrib = ''
                               condition = '' agr_text = arg_text status = <fs_w_e> text = |Keine AG: { <fs_rl>-typ_rolle }{ <fs_rl>-rolle_nr } für { <fs_rl>-funktion }.| ) TO lt_struc_attr_gesamt_erw.
                              CLEAR ls_struc_attr_gesamt_erw.
                            ENDIF.

                            IF lv_exist = 'X'.
                              CONCATENATE 'Fehlende Rolle' <fs_rl>-typ_rolle <fs_rl>-rolle_nr 'für' <fs_rl>-funktion 'im System' lv_rfc_system 'entdeckt.' INTO lv_rfc_agr SEPARATED BY space.
                              APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2> attrib = ''
                                    condition = '' agr_text = arg_text status = k_icon_green  text = lv_rfc_agr ) TO lt_struc_attr_gesamt_erw.
                              CLEAR ls_struc_attr_gesamt_erw.
                            ELSE.
                              APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2> attrib = ''
                                 condition = '' agr_text = arg_text status = <fs_w_e> text = |Keine AG: { <fs_rl>-typ_rolle }{ <fs_rl>-rolle_nr } für { <fs_rl>-funktion }.| ) TO lt_struc_attr_gesamt_erw.
                              CLEAR ls_struc_attr_gesamt_erw.
                            ENDIF.

                          ENDIF.
                        ENDIF.

                      ENDLOOP.
                    ELSE.

                      LOOP AT result_table ASSIGNING FIELD-SYMBOL(<fs_keine_rl>).
                        APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2> attrib = ''
                               condition = '' status = k_icon_yellow text = |Rolle nicht definiert: { <fs_keine_rl>-low }.| ) TO lt_struc_attr_gesamt_erw.
                        CLEAR ls_struc_attr_gesamt_erw.
                      ENDLOOP.
                    ENDIF.
                  ENDIF.
                ENDIF.

                CLEAR result_table.
************************************************************************
*                von F.Rollen zu ZFunk                                 *
************************************************************************
                IF  p_obj2 = 'S'.

                  /THKR/CL_CHECK_KOMPL=>check_zfunk_to_agr(
                     EXPORTING
                       iv_objid    = <fs_sel_opt2>
                       it_ur12c    = lt_tab_result
                       it_11xxl    = lt_tab_result_11xxl
                       iv_nummer   = lv_nummer
                       it_attr_erw = lt_struc_attr_gesamt_erw
                       iv_dest     = lv_dest
                     RECEIVING
                       rt_values   =  rt_values
                       ) .

                  LOOP AT rt_values ASSIGNING <fs_rt_values>.
                    CLEAR arg_text.

                    IF <fs_rt_values>-rolle IS NOT INITIAL.
                      CONCATENATE <fs_rt_values>-rolle '%' INTO <fs_rt_values>-rolle.
                      SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @<fs_rt_values>-rolle AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.
                    ENDIF.

                    APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2> attrib = ''
                           condition = '' agr_text = arg_text status = k_icon_red text = <fs_rt_values>-text ) TO lt_struc_attr_gesamt_erw.
                    CLEAR ls_struc_attr_gesamt_erw.
                  ENDLOOP.

                  CLEAR rt_values.
                ENDIF.



************************************************************************
*                PR-EBENE Attribute ZOM_CHECK_CUST_A                   *
************************************************************************
                IF  p_obj2 = 'O'.

                  SELECT * FROM /THKR/OM_C_CUS_A
                  INTO TABLE lt_check_cust_a_o
                  WHERE otype = 'O'.

                  SELECT SINGLE objid
                  FROM hrp9809
                  WHERE otype = @p_obj2 AND objid = @<fs_sel_opt2> AND orgty = 'PR' AND begda <= @sy-datum AND endda >= @sy-datum AND plvar = '01'
                  INTO @DATA(ls_hr_ebene).

                  IF sy-subrc = 0.
                    IF lt_check_cust_a_o IS NOT INITIAL.
                      LOOP AT lt_check_cust_a_o ASSIGNING FIELD-SYMBOL(<fs_lt_check_cust_a_o>).

                        IF <fs_lt_check_cust_a_o>-attrib = 'BUKRS' OR <fs_lt_check_cust_a_o>-attrib = 'EKORG'.
                          <fs_lt_check_cust_a_o>-status = k_icon_yellow.
                        ENDIF.

                        IF NOT line_exists( lt_struc_attr_gesamt_erw[ nummer = lv_nummer  objekttyp = p_obj2 objektid = <fs_sel_opt2> attrib = <fs_lt_check_cust_a_o>-attrib ] ).

                          APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2> attrib = <fs_lt_check_cust_a_o>-attrib
                                 condition = '' status = <fs_lt_check_cust_a_o>-status text = <fs_lt_check_cust_a_o>-text ) TO lt_struc_attr_gesamt_erw.
                          CLEAR ls_struc_attr_gesamt_erw.

                        ELSE.

                          APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2> attrib = <fs_lt_check_cust_a_o>-attrib
                                 condition = '' status = k_icon_green text = |Oblig. Attribut { <fs_lt_check_cust_a_o>-attrib } auf PR-Ebene vorhanden.| ) TO lt_struc_attr_gesamt_erw.
                          CLEAR ls_struc_attr_gesamt_erw.

************************************************************************
*                 HR_Ebene - Vererbung                                 *
************************************************************************

                          READ TABLE lt_struc_attr_gesamt_erw WITH KEY objekttyp = p_obj2 objektid = <fs_sel_opt2> nummer = lv_nummer attrib = <fs_lt_check_cust_a_o>-attrib
                          ASSIGNING FIELD-SYMBOL(<fs_hr>).

                          IF sy-subrc = 0.
                            IF  <fs_hr>-objektid = <fs_hr>-inh_objid.

                              APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2> attrib = <fs_lt_check_cust_a_o>-attrib
                                     condition = '' status = k_icon_green text = |Attribut { <fs_lt_check_cust_a_o>-attrib } auf PR-Ebene nicht geerbt.| ) TO lt_struc_attr_gesamt_erw.
                              CLEAR ls_struc_attr_gesamt_erw.

*--------------------------------------------------------------------*
*     06.07.2021 08:08:43   WERKS, Geschäftsbereich eindeutig        *
*--------------------------------------------------------------------*

                              IF <fs_lt_check_cust_a_o>-attrib = 'WERKS' OR <fs_lt_check_cust_a_o>-attrib = 'ZPGSBR'.
                                ls_pr_zpgsbr_werks-nummer  = lv_nummer.
                                ls_pr_zpgsbr_werks-objekttyp = <fs_hr>-objekttyp.
                                ls_pr_zpgsbr_werks-objektid  = <fs_hr>-objektid.
                                ls_pr_zpgsbr_werks-attrib  = <fs_hr>-attrib.
                                ls_pr_zpgsbr_werks-low  =   <fs_hr>-low.
                                ls_pr_zpgsbr_werks-high = <fs_hr>-high.

                                APPEND ls_pr_zpgsbr_werks TO lt_pr_zpgsbr_werks.
                                CLEAR ls_pr_zpgsbr_werks.
                              ENDIF.
*--------------------------------------------------------------------*
*     06.07.2021 08:08:43   WERKS, Geschäftsbereich eindeutig        *
*--------------------------------------------------------------------*
                            ELSE.

                              APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2> attrib = <fs_lt_check_cust_a_o>-attrib
                  condition = '' status = <fs_lt_check_cust_a_o>-status text = |Attribut { <fs_lt_check_cust_a_o>-attrib } auf PR-Ebene geerbt { <fs_hr>-inh_objid }.| ) TO lt_struc_attr_gesamt_erw.
                              CLEAR ls_struc_attr_gesamt_erw.

                            ENDIF.
                            UNASSIGN <fs_hr>.
                          ENDIF.

                        ENDIF.
                      ENDLOOP.
                    ENDIF.
                  ELSE.
************************************************************************
*      keine PR-Ebene, prüfen ob Kind-Element von PR-ID                *
************************************************************************
                    CALL FUNCTION 'RH_STRUC_GET'
                      EXPORTING
                        act_otype      = p_obj2
                        act_objid      = <fs_sel_opt2>
                        act_wegid      = 'O-O'
                        act_plvar      = '01'
                      TABLES
                        result_tab     = lt_result_tab_pr
                        result_objec   = lt_result_objec_rp
                        result_struc   = lt_result_struc_pr
                      EXCEPTIONS
                        no_plvar_found = 1
                        no_entry_found = 2
                        OTHERS         = 3.

                    IF sy-subrc = 0.
                      IF lt_result_objec_rp IS NOT INITIAL.
                        LOOP AT lt_result_objec_rp ASSIGNING FIELD-SYMBOL(<fs_lt_result_objec_rp>).
                          SELECT SINGLE objid FROM hrp9809 WHERE objid = @<fs_lt_result_objec_rp>-objid AND orgty = 'PR' AND begda <= @sy-datum AND endda >= @sy-datum
                          INTO @DATA(ls_hr_check).
                          IF sy-subrc = 0.

                            IF lt_check_cust_a_o IS NOT INITIAL.
                              LOOP AT lt_check_cust_a_o ASSIGNING FIELD-SYMBOL(<fs_lt_check_cust_a_o_kind>).

                                DATA(lv_status) = k_icon_red.

                                IF <fs_lt_check_cust_a_o_kind>-attrib EQ 'EKORG' OR <fs_lt_check_cust_a_o_kind>-attrib EQ 'BUKRS'.
                                  lv_status = k_icon_yellow.
                                ENDIF.

                                IF NOT line_exists( lt_struc_attr_gesamt_erw[ nummer = lv_nummer  objekttyp = p_obj2  objektid = <fs_sel_opt2>  attrib = <fs_lt_check_cust_a_o_kind>-attrib ] ).

                                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2> attrib = <fs_lt_check_cust_a_o_kind>-attrib
                  condition = '' status = lv_status  text = |Oblig. Attribut { <fs_lt_check_cust_a_o_kind>-attrib } fehlt! PR-ID { <fs_lt_result_objec_rp>-objid }.| ) TO lt_struc_attr_gesamt_erw.
                                  CLEAR ls_struc_attr_gesamt_erw.
                                ELSE.
*--------------------------------------------------------------------*
*     06.07.2021 08:08:43   WERKS, Geschäftsbereich eindeutig        *
*--------------------------------------------------------------------*

                                  IF <fs_lt_check_cust_a_o_kind>-attrib = 'WERKS' OR <fs_lt_check_cust_a_o_kind>-attrib = 'ZPGSBR'.

                                    READ TABLE lt_struc_attr_gesamt_erw WITH KEY objekttyp = p_obj2 objektid = <fs_sel_opt2> nummer = lv_nummer attrib = <fs_lt_check_cust_a_o_kind>-attrib
                                     ASSIGNING FIELD-SYMBOL(<fs_hr_child>).
                                    IF  <fs_hr_child>-objektid = <fs_hr_child>-inh_objid.
                                      ls_pr_zpgsbr_werks-nummer  = lv_nummer.
                                      ls_pr_zpgsbr_werks-objekttyp = <fs_hr_child>-objekttyp.
                                      ls_pr_zpgsbr_werks-objektid  = <fs_hr_child>-objektid.
                                      ls_pr_zpgsbr_werks-attrib  = <fs_hr_child>-attrib.
                                      ls_pr_zpgsbr_werks-low  =  <fs_hr_child>-low.
                                      ls_pr_zpgsbr_werks-high =  <fs_hr_child>-high.
                                      APPEND ls_pr_zpgsbr_werks TO lt_pr_zpgsbr_werks.
                                      CLEAR ls_pr_zpgsbr_werks.
                                    ENDIF.
                                  ENDIF.
                                ENDIF.

                              ENDLOOP.
                            ENDIF.
                          ENDIF.
                        ENDLOOP.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.

************************************************************************
*                Zusatz-Attribute Vergabestelle                        *
************************************************************************
*                IF  p_obj2 = 'S'.
*                  SELECT SINGLE low FROM @lt_struc_attr_gesamt_erw AS tb_struc
*                  WHERE nummer = @lv_nummer AND attrib = 'ZFUNK' AND low = 'VGST'   ##ITAB_KEY_IN_SELECT
*                  INTO @DATA(lv_vgst). " ##ITAB_KEY_IN_SELECT
*
*                  IF sy-subrc = 0.
*                    SELECT SINGLE low
*                    FROM @lt_struc_attr_gesamt_erw AS burks
*                    WHERE nummer = @lv_nummer AND objekttyp = 'S' AND attrib = 'BUKRS' AND low NE ''   ##ITAB_KEY_IN_SELECT
*                    INTO @DATA(lv_bukrs). " ##ITAB_KEY_IN_SELECT
*
*                    IF sy-subrc NE 0.
*                      SELECT SINGLE low
*                      FROM @lt_struc_attr_gesamt_erw AS werks
*                      WHERE nummer = @lv_nummer AND objekttyp = 'S' AND attrib = 'WERKS' AND low NE ''   ##ITAB_KEY_IN_SELECT
*                      INTO @DATA(lv_werks). " ##ITAB_KEY_IN_SELECT
*
**Buchungskreis aus Werk ermitteln
*                      IF sy-subrc = 0.
*
*                        CREATE OBJECT lo_util.
*
*                        CALL METHOD lo_util->get_bukrs_by_werks
*                          EXPORTING
*                            iv_werks = CONV #( lv_werks )
*                          RECEIVING
*                            rv_bukrs = lv_bukrs.
*
*                        CALL METHOD lo_util->get_zfrgvgb_by_bukrs
*                          EXPORTING
*                            iv_werks   = CONV #( lv_werks )
*                            iv_bukrs   = CONV #( lv_bukrs )
*                          RECEIVING
*                            rv_zfrgvgb = lv_btrg.
*
*                        SELECT SINGLE low
*                        FROM @lt_struc_attr_gesamt_erw AS betrwert
*                        WHERE nummer = @lv_nummer AND objekttyp = 'S'  ##ITAB_KEY_IN_SELECT
*                        AND  attrib = 'ZFRGVGB' AND low NE ''
*                        INTO @DATA(lv_betr_wert).
*
*                        IF sy-subrc NE 0.
*
*                          ls_struc_attr_gesamt_erw-nummer = lv_nummer.
*                          ls_struc_attr_gesamt_erw-objekttyp = p_obj2.
*                          ls_struc_attr_gesamt_erw-objektid = <fs_sel_opt2>.
*                          ls_struc_attr_gesamt_erw-attrib =  'ZFRGVGB'.
*
*                          SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @ls_struc_attr_gesamt_erw-attrib AND langu = 'D' . "#EC CI_NOORDER
*                          ls_struc_attr_gesamt_erw-atext = lv_attr_txt.
*                          CLEAR lv_attr_txt.
*
*                          ls_struc_attr_gesamt_erw-low = lv_btrg.
*                          ls_struc_attr_gesamt_erw-condition = ''.
*                          ls_struc_attr_gesamt_erw-status =  k_icon_green.
*                          ls_struc_attr_gesamt_erw-text  = |Betragsgrenze ZFRGVGB ist { lv_btrg }.|  ##NO_TEXT.
*                          APPEND ls_struc_attr_gesamt_erw TO lt_struc_attr_gesamt_erw.
*                          CLEAR ls_struc_attr_gesamt_erw.
*                        ENDIF.
*                      ELSE.
*
*                        SELECT SINGLE low
*                        FROM @lt_struc_attr_gesamt_erw AS betrwert2
*                        WHERE nummer = @lv_nummer AND objekttyp = 'S'  ##ITAB_KEY_IN_SELECT
*                        AND  attrib = 'ZFRGVGB' AND low NE ''
*                        INTO @DATA(lv_betr_wert2).
*
*                        IF sy-subrc NE 0.
*
*                          APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2> attrib = 'BUKRS'
*                                 condition = '' status = k_icon_red text = |WERKS und BUKRS fehlen. Betragsgrenze (ZFRGVGB) nicht ableitbar.| ) TO lt_struc_attr_gesamt_erw.
*                          CLEAR ls_struc_attr_gesamt_erw.
*                        ENDIF.
*
*                      ENDIF.
*                    ELSE.
*
** Die Betragsgrenze zu Bukrs holen
*
*                      SELECT SINGLE low
*                      FROM @lt_struc_attr_gesamt_erw AS betrwert3
*                      WHERE nummer = @lv_nummer AND objekttyp = 'S'  ##ITAB_KEY_IN_SELECT
*                      AND  attrib = 'ZFRGVGB' AND low NE ''
*                      INTO @DATA(lv_betr_wert3).
*
*                      IF sy-subrc NE 0.
*
*                        CREATE OBJECT lo_util.
*                        CALL METHOD lo_util->get_zfrgvgb_by_bukrs
*                          EXPORTING
*                            iv_werks   = CONV #( lv_werks )
*                            iv_bukrs   = CONV #( lv_bukrs )
*                          RECEIVING
*                            rv_zfrgvgb = lv_btrg.
*
*                        ls_struc_attr_gesamt_erw-nummer = lv_nummer.
*                        ls_struc_attr_gesamt_erw-objekttyp = p_obj2.
*                        ls_struc_attr_gesamt_erw-objektid = <fs_sel_opt2>.
*                        ls_struc_attr_gesamt_erw-attrib =  'ZFRGVGB'.
*
*                        SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @ls_struc_attr_gesamt_erw-attrib AND langu = 'D' . "#EC CI_NOORDER
*                        ls_struc_attr_gesamt_erw-atext = lv_attr_txt.
*                        CLEAR lv_attr_txt.
*
*                        ls_struc_attr_gesamt_erw-low = lv_btrg.
*                        ls_struc_attr_gesamt_erw-condition = ''.
*                        ls_struc_attr_gesamt_erw-status =  k_icon_green.
*                        ls_struc_attr_gesamt_erw-text  = |Betragsgrenze ZFRGVGB ist { lv_btrg } .| ##NO_TEXT.
*                        APPEND ls_struc_attr_gesamt_erw TO lt_struc_attr_gesamt_erw.
*                        CLEAR ls_struc_attr_gesamt_erw.
*                      ENDIF.
*
*                    ENDIF.
*                  ENDIF.
*                ENDIF.

************************************************************************
*                Zusatz-Attribute Buge                                 *
************************************************************************
*                IF  p_obj2 = 'S'.
*                  CLEAR rt_values_erw.
*                  /THKR/CL_CHECK_KOMPL=>check_zbtrg_ao_buge(
*                    EXPORTING
*                      iv_objid    =  <fs_sel_opt2>
*                      iv_nummer   =  lv_nummer
*                      it_attr_erw =  lt_struc_attr_gesamt_erw
*                    RECEIVING rt_values = rt_values_erw  ).
*
*                  LOOP AT rt_values_erw ASSIGNING FIELD-SYMBOL(<fs_v>).
*                    APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2>
*                                                                 attrib = <fs_v>-attrib low = <fs_v>-low high = <fs_v>-high
*                                                                 condition = '' status = k_icon_red text = <fs_v>-text )
*                                                                 TO lt_struc_attr_gesamt_erw.
*                    CLEAR ls_struc_attr_gesamt_erw.
*                  ENDLOOP.
*
*                ENDIF.

************************************************************************
*                Zusatz-Attribute WAGE                                 *
************************************************************************
*                IF  p_obj2 = 'S'.
*                  SELECT SINGLE low
*                  FROM @lt_struc_attr_gesamt_erw AS tb_struc_wage
*                  WHERE nummer = @lv_nummer AND attrib = 'ZFUNK' AND low = 'WAGE'   ##ITAB_KEY_IN_SELECT
*                  INTO @DATA(lv_wage). " ##ITAB_KEY_IN_SELECT
*                  IF sy-subrc = 0.
*                    SELECT SINGLE low
*                    FROM @lt_struc_attr_gesamt_erw AS b_dstl
*                    WHERE nummer = @lv_nummer AND objekttyp = 'S'  ##ITAB_KEY_IN_SELECT
*                    AND  attrib = 'ZWGRP_DSTL' AND low NE ''
*                    INTO @DATA(lv_betr_dstl).
*
*                    IF sy-subrc NE 0.
*                      SELECT low
*                      FROM @lt_struc_attr_gesamt_erw AS werk
*              WHERE nummer = @lv_nummer AND objekttyp = 'S' AND attrib = 'WERKS' AND low NE '' AND ( status NE @k_icon_red AND status NE @k_icon_yellow )  ##ITAB_KEY_IN_SELECT
*              INTO TABLE @DATA(lt_werk). " ##ITAB_KEY_IN_SELECT
*
*                      IF sy-subrc = 0.
*
*                        SORT lt_werk BY low.
*                        DELETE ADJACENT DUPLICATES FROM lt_werk COMPARING low.
*
*                        LOOP AT lt_werk  ASSIGNING FIELD-SYMBOL(<fs_werk>).
*                          DATA(lt_range_wage) = zcl_om_wf_util=>get_zwgrp_dstl_by_werks( CONV #( <fs_werk>-low ) ).
*
*                          IF sy-tabix >= 1 AND 'xxxxxxxxx' NOT IN lt_range_wage .
*
*                            LOOP AT lt_range_wage ASSIGNING FIELD-SYMBOL(<fs_lt_range_wage>).
*
*                              ls_struc_attr_gesamt_erw-nummer = lv_nummer.
*                              ls_struc_attr_gesamt_erw-objekttyp = p_obj2.
*                              ls_struc_attr_gesamt_erw-objektid = <fs_sel_opt2>.
*                              ls_struc_attr_gesamt_erw-attrib =  'ZWGRP_DSTL'.
*                              ls_struc_attr_gesamt_erw-low  = <fs_lt_range_wage>-low.
*                              ls_struc_attr_gesamt_erw-high = <fs_lt_range_wage>-high.
*                              ls_struc_attr_gesamt_erw-condition = ''.
*
*                              SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @ls_struc_attr_gesamt_erw-attrib AND langu = 'D' . "#EC CI_NOORDER
*                              ls_struc_attr_gesamt_erw-atext = lv_attr_txt.
*                              CLEAR lv_attr_txt.
*
*                              ls_struc_attr_gesamt_erw-status =  k_icon_yellow.
*                              ls_struc_attr_gesamt_erw-text  = |ZWGRP_DSTL ist abgeleitet.| ##NO_TEXT.
*                              APPEND ls_struc_attr_gesamt_erw TO lt_struc_attr_gesamt_erw.
*                              CLEAR ls_struc_attr_gesamt_erw.
*
*                            ENDLOOP.
*                          ENDIF.
*                        ENDLOOP.
*
*                        SELECT SINGLE low
*                          FROM @lt_struc_attr_gesamt_erw AS b_dstl
*                          WHERE nummer = @lv_nummer AND objekttyp = 'S'  ##ITAB_KEY_IN_SELECT
*                          AND  attrib = 'ZWGRP_DSTL' AND ( low NE '' OR text NE '' )
*                        INTO @DATA(lv_betr_dstl_exist).
*                        IF sy-subrc NE 0.
*
*                          APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2> attrib = 'ZWGRP_DSTL'
*                                 condition = '' status = k_icon_red text = |ZWGRP_DSTL ist nicht ableitbar.| ) TO lt_struc_attr_gesamt_erw.
*                          CLEAR ls_struc_attr_gesamt_erw.
*                        ENDIF.
*
*                      ELSE.
*
*                        APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = p_obj2 objektid = <fs_sel_opt2> attrib = 'WERKS'
*                               condition = '' status = k_icon_red text = |WERKS fehlt, ZWGRP_DSTL nicht ableitbar.| ) TO lt_struc_attr_gesamt_erw.
*                        CLEAR ls_struc_attr_gesamt_erw.
*                      ENDIF.
*                    ENDIF.
**************************************************************************
***                ZWGRPFB -->  ZWGRP_DSTL                               *
**************************************************************************
*                    SELECT attrib, low, high
*                    FROM @lt_struc_attr_gesamt_erw AS b_dstl
*                    WHERE nummer = @lv_nummer AND objekttyp = 'S'  ##ITAB_KEY_IN_SELECT
*                    AND  attrib = 'ZWGRP_DSTL' AND ( low NE '' OR status = @k_icon_yellow )
*                    INTO TABLE @DATA(lt_zwgrp_dstl).
*
*                    IF sy-subrc = 0.
*
*                      SORT lt_zwgrp_dstl BY attrib low high.
*                      DELETE ADJACENT DUPLICATES FROM lt_zwgrp_dstl COMPARING attrib low high.
*
*                      SELECT attrib, low, high
*                      FROM @lt_struc_attr_gesamt_erw AS b_dst22
*                      WHERE nummer = @lv_nummer AND objekttyp = 'S'  ##ITAB_KEY_IN_SELECT
*                      AND  attrib = 'ZWGRPFB' AND ( low NE '' OR status = @k_icon_green )
*                      INTO TABLE @DATA(lt_zwgrpfb).
*
*                      IF sy-subrc = 0.
*
*                        CLEAR lt_range.
*                        LOOP AT lt_zwgrp_dstl ASSIGNING FIELD-SYMBOL(<fs_lt_zwgrp_dstl>).
*                          IF <fs_lt_zwgrp_dstl>-high IS NOT INITIAL.
*                            lt_range = VALUE #( BASE lt_range ( sign = 'I' option = 'BT' low = <fs_lt_zwgrp_dstl>-low high = <fs_lt_zwgrp_dstl>-high ) ).
*                          ELSE.
*                            lt_range = VALUE #( BASE lt_range ( sign = 'I' option = 'EQ' low = <fs_lt_zwgrp_dstl>-low  ) ).
*                          ENDIF.
*                        ENDLOOP.
*
*                        SORT lt_zwgrpfb BY attrib low high.
*                        DELETE ADJACENT DUPLICATES FROM lt_zwgrpfb COMPARING attrib low high.
*
*                        LOOP AT lt_zwgrpfb ASSIGNING FIELD-SYMBOL(<fs_lt_zwgrpfb>).
*
*                          IF <fs_lt_zwgrpfb>-high IS INITIAL.
*
*                            IF  <fs_lt_zwgrpfb>-low NOT IN lt_range.
*                              ls_struc_attr_gesamt_erw-nummer = lv_nummer.
*                              ls_struc_attr_gesamt_erw-objekttyp = p_obj2.
*                              ls_struc_attr_gesamt_erw-objektid = <fs_sel_opt2>.
*                              ls_struc_attr_gesamt_erw-attrib = <fs_lt_zwgrpfb>-attrib.
*                              ls_struc_attr_gesamt_erw-low = <fs_lt_zwgrpfb>-low.
*                              " ls_struc_attr_gesamt_erw-condition = 'MUSS'.
*
*                              SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @ls_struc_attr_gesamt_erw-attrib AND langu = 'D' . "#EC CI_NOORDER
*                              ls_struc_attr_gesamt_erw-atext = lv_attr_txt.
*                              CLEAR lv_attr_txt.
*
*                              ls_struc_attr_gesamt_erw-status =  k_icon_red.
*                              ls_struc_attr_gesamt_erw-text  = |ZWGRPFB ist nicht in ZWGRP_DSTL enthalten.| ##NO_TEXT .
*                              APPEND ls_struc_attr_gesamt_erw TO lt_struc_attr_gesamt_erw.
*                              CLEAR ls_struc_attr_gesamt_erw.
*                            ENDIF.
*
*                          ELSE.
*
*                            IF <fs_lt_zwgrpfb>-low NOT IN lt_range OR <fs_lt_zwgrpfb>-high NOT IN lt_range.
*                              ls_struc_attr_gesamt_erw-nummer = lv_nummer.
*                              ls_struc_attr_gesamt_erw-objekttyp = p_obj2.
*                              ls_struc_attr_gesamt_erw-objektid = <fs_sel_opt2>.
*                              ls_struc_attr_gesamt_erw-attrib = <fs_lt_zwgrpfb>-attrib.
*                              ls_struc_attr_gesamt_erw-low = <fs_lt_zwgrpfb>-low.
*                              ls_struc_attr_gesamt_erw-high = <fs_lt_zwgrpfb>-high.
*                              " ls_struc_attr_gesamt_erw-condition = 'MUSS'.
*
*                              SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @ls_struc_attr_gesamt_erw-attrib AND langu = 'D' . "#EC CI_NOORDER
*                              ls_struc_attr_gesamt_erw-atext = lv_attr_txt.
*                              CLEAR lv_attr_txt.
*
*                              ls_struc_attr_gesamt_erw-status =  k_icon_red.
*                              ls_struc_attr_gesamt_erw-text  = |ZWGRPFB ist nicht in ZWGRP_DSTL enthalten.| ##NO_TEXT .
*                              APPEND ls_struc_attr_gesamt_erw TO lt_struc_attr_gesamt_erw.
*                              CLEAR ls_struc_attr_gesamt_erw.
*                            ENDIF.
*                          ENDIF.
*                        ENDLOOP.
*                      ENDIF.
*                    ENDIF.
*                  ENDIF.
*                ENDIF.


                CLEAR: lt_rolle_name_table, lt_tmp_rolle, lv_rolle_exist, lt_dat_tab,
                       lt_result_objec_rp, lt_result_struc_pr, lt_agr1252_tmp,
                       agrs_tmp, lt_agr1252, lt_rolle_tb, lt_result_tab_pr.


                " Nur fehlerhafte Datensätze anzeigen
                IF p_par5 = 'X'.
                  DELETE lt_struc_attr_gesamt_erw WHERE NOT status EQ k_icon_yellow AND
                                                        NOT status EQ k_icon_red.

                ENDIF.

************************************************************************
*                einzelne Ids zusammenfassen                           *
************************************************************************
                CLEAR: ls_struc_attr, lt_result_zom.
                APPEND LINES OF lt_struc_attr_gesamt_erw TO lt_struc_attr_gesamt_erw_end .
                CLEAR: lt_struc_attr_gesamt_erw, ls_struc_attr_gesamt_erw.
                lv_nummer = lv_nummer + 1.

            ENDCASE.
          ENDLOOP.
        ELSE.
          MESSAGE 'Selektierte Werte in HRP1000 nicht vorhanden.' TYPE 'E' ##NO_TEXT.
        ENDIF.
      ELSE.
        MESSAGE 'Bitte fügen Sie mindestens eine Objekt-ID ein.' TYPE 'E' ##NO_TEXT.
      ENDIF.
      " WRITE 'OK'.

*--------------------------------------------------------------------*
*     06.07.2021 08:08:43   WERKS, Geschäftsbereich eindeutig        *
*--------------------------------------------------------------------*
      IF lt_pr_zpgsbr_werks IS NOT INITIAL.

        LOOP AT lt_pr_zpgsbr_werks ASSIGNING FIELD-SYMBOL(<fs_attrib_wert>) WHERE attrib = 'WERKS'.

          LOOP AT lt_pr_zpgsbr_werks ASSIGNING FIELD-SYMBOL(<fs_attrib_wert_eind>) WHERE attrib = 'WERKS'.
            IF <fs_attrib_wert>-low  = <fs_attrib_wert_eind>-low AND <fs_attrib_wert>-objektid NE <fs_attrib_wert_eind>-objektid.
              ls_struc_attr_gesamt_erw-nummer = <fs_attrib_wert>-nummer.
              ls_struc_attr_gesamt_erw-objekttyp = <fs_attrib_wert>-objekttyp.
              ls_struc_attr_gesamt_erw-objektid = <fs_attrib_wert>-objektid .
              ls_struc_attr_gesamt_erw-attrib = <fs_attrib_wert>-attrib.

              SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @ls_struc_attr_gesamt_erw-attrib AND langu = 'D' . "#EC CI_NOORDER
              ls_struc_attr_gesamt_erw-atext = lv_attr_txt.
              CLEAR lv_attr_txt.

              ls_struc_attr_gesamt_erw-low =  <fs_attrib_wert>-low.
              ls_struc_attr_gesamt_erw-high =  <fs_attrib_wert>-high.
              ls_struc_attr_gesamt_erw-status =  k_icon_red.
              ls_struc_attr_gesamt_erw-text  = | Attr. { <fs_attrib_wert>-attrib } ist nicht eindeutig: { <fs_attrib_wert_eind>-objektid }| .

              DATA(lv_line_index) = line_index( lt_struc_attr_gesamt_erw_end[ nummer = <fs_attrib_wert>-nummer objekttyp = <fs_attrib_wert>-objekttyp
              objektid = <fs_attrib_wert>-objektid attrib = <fs_attrib_wert>-attrib low = <fs_attrib_wert>-low ] ).
              IF lv_line_index > 0.
                INSERT ls_struc_attr_gesamt_erw INTO lt_struc_attr_gesamt_erw_end INDEX lv_line_index.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDLOOP.

        LOOP AT lt_pr_zpgsbr_werks ASSIGNING FIELD-SYMBOL(<fs_attrib_wert2>) WHERE attrib = 'ZPGSBR'.

          LOOP AT lt_pr_zpgsbr_werks ASSIGNING FIELD-SYMBOL(<fs_attrib_wert_eind2>) WHERE attrib = 'ZPGSBR'.
            IF <fs_attrib_wert2>-low  = <fs_attrib_wert_eind2>-low AND <fs_attrib_wert2>-objektid NE <fs_attrib_wert_eind2>-objektid.
              ls_struc_attr_gesamt_erw-nummer = <fs_attrib_wert2>-nummer.
              ls_struc_attr_gesamt_erw-objekttyp = <fs_attrib_wert2>-objekttyp.
              ls_struc_attr_gesamt_erw-objektid = <fs_attrib_wert2>-objektid .
              ls_struc_attr_gesamt_erw-attrib = <fs_attrib_wert2>-attrib.

              SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @ls_struc_attr_gesamt_erw-attrib AND langu = 'D' . "#EC CI_NOORDER
              ls_struc_attr_gesamt_erw-atext = lv_attr_txt.
              CLEAR lv_attr_txt.

              ls_struc_attr_gesamt_erw-low =  <fs_attrib_wert2>-low.
              ls_struc_attr_gesamt_erw-high =  <fs_attrib_wert2>-high.
              ls_struc_attr_gesamt_erw-status =  k_icon_red.
              ls_struc_attr_gesamt_erw-text  = | Attr. { <fs_attrib_wert2>-attrib } ist nicht eindeutig: { <fs_attrib_wert_eind2>-objektid }| .

              DATA(lv_line_index2) = line_index( lt_struc_attr_gesamt_erw_end[ nummer = <fs_attrib_wert2>-nummer objekttyp = <fs_attrib_wert2>-objekttyp
              objektid = <fs_attrib_wert2>-objektid attrib = <fs_attrib_wert2>-attrib low = <fs_attrib_wert2>-low ] ).
              IF lv_line_index2 > 0.
                INSERT ls_struc_attr_gesamt_erw INTO lt_struc_attr_gesamt_erw_end INDEX lv_line_index2.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
        CLEAR lt_pr_zpgsbr_werks.
      ENDIF.


************************************************************************
*         Reiter 2, TopDown                                            *
************************************************************************
    ELSEIF p_par4 = 'X'.

************************************************************************
*   Falls Typ nicht befüllt oder nicht 'O' oder 'S'  -> Fehlermeldung  *
************************************************************************
      IF p_obj2 IS INITIAL OR ( p_obj2 NE 'O' AND p_obj2 NE 'S' ).
        MESSAGE 'Bitte geben Sie O oder S ein.' TYPE 'E' ##NO_TEXT.
      ENDIF.

************************************************************************
*   mit Hilfe Obj.Id aktuell Objekte aus hrp1000 holen                 *
************************************************************************
      IF s_objid2 IS NOT INITIAL.

        SELECT SINGLE objid                             "#EC CI_NOORDER
          FROM hrp1000
          INTO @ls_selectopt3
          WHERE objid = @s_objid2-low  AND otype = @p_obj2 AND plvar = '01'
        AND begda <= @sy-datum  AND endda >= @sy-datum. "#EC CI_NOORDER

        lv_nummer = 1.
************************************************************************
*         TopDown-Ids (Struktur) lesen                                 *
************************************************************************
        IF ls_selectopt3 IS NOT INITIAL.
          CALL FUNCTION 'RH_STRUC_GET' "
            EXPORTING
              act_otype      = p_obj2
              act_objid      = ls_selectopt3
              act_wegid      = 'O-O-S-P'
              act_plvar      = '01'
            IMPORTING
              act_plvar      = ld_act_plvar2              " Plan Version
            TABLES
              result_objec   = lt_result_objec2           " objec
            EXCEPTIONS
              no_plvar_found = 1                          " No active plan version exists
              no_entry_found = 2.                         " No agent found

          IF sy-subrc = 0.
************************************************************************
*        Attribute pro Id auslesen                                     *
************************************************************************

            LOOP AT lt_result_objec2  ASSIGNING FIELD-SYMBOL(<fs_objec2>).

              CALL FUNCTION 'RH_OM_ATTRIBUTES_READ'
                EXPORTING
                  plvar            = '01'
                  otype            = <fs_objec2>-otype
                  objid            = <fs_objec2>-objid
                  scenario         = 'SSP'
                  seldate          = sy-datum
                TABLES
                  attrib           = lt_attrib3
                  attrib_ext       = lt_attrib_ext3
                EXCEPTIONS
                  no_active_plvar  = 1
                  no_attributes    = 2
                  no_values        = 3
                  object_not_found = 4
                  OTHERS           = 5.

************************************************************************
* Attribute pro Id erweitern (+ nummer, type, id, zfunk_no_exist )     *
************************************************************************
              CASE sy-subrc.
                WHEN '0'.
                  LOOP AT lt_attrib_ext3 ASSIGNING FIELD-SYMBOL(<fs_lt_attrib_ext3>).
                    ls_struc_attr2-nummer     = lv_nummer .
                    ls_struc_attr2-objekttyp  = <fs_objec2>-otype.
                    ls_struc_attr2-objektid   = <fs_objec2>-objid.
                    ls_struc_attr2-attrib     = <fs_lt_attrib_ext3>-attrib.
                    ls_struc_attr2-low        = <fs_lt_attrib_ext3>-low.
                    ls_struc_attr2-high       = <fs_lt_attrib_ext3>-high.
                    ls_struc_attr2-excluded   = <fs_lt_attrib_ext3>-excluded.
                    ls_struc_attr2-defaultval = <fs_lt_attrib_ext3>-defaultval.
                    ls_struc_attr2-inherited  = <fs_lt_attrib_ext3>-inherited.
                    ls_struc_attr2-inherit    = <fs_lt_attrib_ext3>-inherit.
                    ls_struc_attr2-inh_otype  = <fs_lt_attrib_ext3>-inh_otype.
                    ls_struc_attr2-inh_objid  = <fs_lt_attrib_ext3>-inh_objid.

                    IF ls_struc_attr-objekttyp = 'S'.
                      ls_struc_attr-zfunk_no_exist = 'X'.
                    ELSE.
                      ls_struc_attr-zfunk_no_exist = ''.
                    ENDIF.

                    " Text
                    SELECT SINGLE atext INTO @DATA(lv_atext2) FROM t77omattrt WHERE attrib = @<fs_lt_attrib_ext3>-attrib AND langu = 'D' . "#EC CI_NOORDER
                    ls_struc_attr2-atext = lv_atext2.
                    CLEAR lv_atext2.

                    APPEND ls_struc_attr2 TO lt_struc_attr_gesamt_erw2.
                    CLEAR ls_struc_attr2.
                  ENDLOOP.

************************************************************************
*                      Protokoll-Tabelle 2                             *
************************************************************************
                  " APPEND LINES OF lt_struc_attr_gesamt_erw2 TO lt_struc_attr_erw_end2_pr.

************************************************************************
*                   Feld Condition (muss/kann).                        *
************************************************************************
                  LOOP AT lt_struc_attr_gesamt_erw2 ASSIGNING FIELD-SYMBOL(<fs_abc2>) WHERE attrib = 'ZFUNK' AND objekttyp = 'S'.
                    IF <fs_abc2>-attrib = 'ZFUNK' AND <fs_abc2>-objekttyp = 'S' AND <fs_abc2>-nummer = lv_nummer . "#EC CI_NOORDER

                      DATA(lv_wert2) = <fs_abc2>-low.

                      SELECT * FROM /THKR/WF_CONTROL INTO TABLE @DATA(lt_data2) WHERE funktion = @lv_wert2.

                      LOOP AT lt_struc_attr_gesamt_erw2 ASSIGNING FIELD-SYMBOL(<fs_a2>).
                        <fs_a2>-zfunk_no_exist = ''.
                        LOOP AT lt_data2 ASSIGNING FIELD-SYMBOL(<fs_b2>).
                          IF <fs_a2>-attrib = <fs_b2>-attribut.
                            <fs_a2>-condition = <fs_b2>-cond.
                            <fs_a2>-vorhanden = 'X'.
                            <fs_a2>-status = k_icon_green.

                            SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @<fs_b2>-attribut AND langu = 'D' . "#EC CI_NOORDER
                            <fs_a2>-atext = lv_attr_txt.
                            CLEAR lv_attr_txt.

                            IF <fs_a2>-text IS NOT INITIAL.
                              CONCATENATE <fs_a2>-text <fs_b2>-funktion INTO DATA(text2) SEPARATED BY space.
                              IF strlen( text2 ) < 180.
                                <fs_a2>-text = text2.
                              ENDIF.                    "#EC CI_NOORDER
                            ELSE.
                              <fs_a2>-text = |ZFUNK: { <fs_b2>-funktion } |.
                            ENDIF.

                            EXIT.                       "#EC CI_NOORDER
                          ENDIF.
                        ENDLOOP.
                      ENDLOOP.
                    ENDIF.
                  ENDLOOP.

                  CLEAR lt_data2.

************************************************************************
*  existierende Atribute für ZOM_WF_FUNK auslesen                      *
************************************************************************
                  SELECT attrib, low, condition
                         FROM @lt_struc_attr_gesamt_erw2 AS attr  ##ITAB_KEY_IN_SELECT
                         WHERE ( condition IS NOT INITIAL OR attrib = 'ZFUNK' ) AND nummer = @lv_nummer
                  INTO TABLE @DATA(lt_result2).

                  IF lt_result2 IS NOT INITIAL.

************************************************************************
*  alle notwendige Attribute FUNK holen aus zom_wf_funk_c              *
************************************************************************
                    LOOP AT lt_result2 ASSIGNING FIELD-SYMBOL(<fs_attr_c2>) WHERE attrib = 'ZFUNK'.
                      SELECT attribut AS attrib , cond AS condition , funktion
                      FROM /THKR/WF_CONTROL
                      WHERE funktion = @<fs_attr_c2>-low
                      INTO TABLE @DATA(lt_result_zom_tpm2).
                      APPEND LINES OF lt_result_zom_tpm2 TO lt_result_zom2.
                      CLEAR lt_result_zom_tpm2.
                    ENDLOOP.

                    SORT lt_result_zom2.
                    DELETE ADJACENT DUPLICATES FROM lt_result_zom2.
************************************************************************
*  Ptüfen bestehende/fehlende Attr.                                    *
************************************************************************
                    CLEAR lt_result_zom_tmp2s.
                    LOOP AT lt_result_zom2  ASSIGNING FIELD-SYMBOL(<fs_t2>).

                      IF <fs_t2>-attrib NE ''.

                        " Sonderlogik BRTWR
                        IF <fs_t2>-attrib EQ 'BRTWR'.
                          READ TABLE lt_struc_attr_gesamt_erw2
                            WITH KEY attrib = 'ZFRGVGB' nummer = lv_nummer objekttyp = 'S'
                            INTO DATA(lv_zfrgvgb2).
                          IF sy-subrc IS INITIAL AND lv_zfrgvgb2-low IS NOT INITIAL.

                            READ TABLE lt_struc_attr_gesamt_erw2
                          WITH KEY attrib = 'ZFRGVGS' nummer = lv_nummer objekttyp = 'S'
                          INTO DATA(lv_zfrgvgs2).
                            IF sy-subrc IS INITIAL AND lv_zfrgvgs2-low IS NOT INITIAL.
                              CONTINUE.
                            ENDIF.
                          ENDIF.
                        ENDIF.


                        IF NOT line_exists(
                    lt_struc_attr_gesamt_erw2[ attrib = <fs_t2>-attrib  nummer = lv_nummer objekttyp = 'S'  ] ).  " condition = <fs_t2>-condition

                          CLEAR ls_result_zom_tmp.
                          ls_result_zom_tmp-attrib    = <fs_t2>-attrib.
                          ls_result_zom_tmp-condition = <fs_t2>-condition.
                          ls_result_zom_tmp-funktion  = <fs_t2>-funktion.
                          APPEND ls_result_zom_tmp TO lt_result_zom_tmp2s.

                        ENDIF.
                      ENDIF.
                    ENDLOOP.

                    SORT lt_result_zom_tmp2s.
                    " fehlende Attribute
                    LOOP AT lt_result_zom_tmp2s ASSIGNING FIELD-SYMBOL(<fs_result_zom_tmp2>) GROUP BY <fs_result_zom_tmp2>-attrib.
                      CLEAR: lv_muss, lv_kann.

                      DATA(lt_res_tmp2) = VALUE struc_attr_tmp( FOR <p_tb2> IN GROUP <fs_result_zom_tmp2> ( <p_tb2> ) ).

                      LOOP AT lt_res_tmp2 ASSIGNING FIELD-SYMBOL(<fs_res2>).

                        IF <fs_res2>-condition = 'MUSS'.
                          CONCATENATE lv_muss <fs_res2>-funktion INTO lv_muss SEPARATED BY space.
                        ELSE.
                          CONCATENATE lv_kann <fs_res2>-funktion INTO lv_kann SEPARATED BY space.
                        ENDIF.

                      ENDLOOP.

                      READ TABLE lt_res_tmp2 INTO DATA(lv_attr_tmp2) INDEX 1.

                      IF sy-subrc = 0.
                        ls_struc_attr_gesamt_erw2-nummer = lv_nummer.
                        ls_struc_attr_gesamt_erw2-objekttyp = <fs_objec2>-otype..
                        ls_struc_attr_gesamt_erw2-objektid  = <fs_objec2>-objid.
                        ls_struc_attr_gesamt_erw2-attrib = lv_attr_tmp2-attrib.
                        ls_struc_attr_gesamt_erw2-vorhanden = ''.
                        SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @lv_attr_tmp2-attrib AND langu = 'D' . "#EC CI_NOORDER
                        ls_struc_attr_gesamt_erw2-atext = lv_attr_txt.
                        CLEAR lv_attr_txt.

                        IF lv_muss IS NOT INITIAL.
                          SHIFT lv_muss  LEFT BY 1 PLACES.
                          ls_struc_attr_gesamt_erw2-condition = 'MUSS'.
                          ls_struc_attr_gesamt_erw2-status = k_icon_red.
                          ls_struc_attr_gesamt_erw2-text = |Attribut für { lv_muss } nicht vorhanden.| ##NO_TEXT.

                          APPEND ls_struc_attr_gesamt_erw2 TO lt_struc_attr_gesamt_erw2.
                        ENDIF.

                        IF lv_kann IS NOT INITIAL.
                          SHIFT lv_kann  LEFT BY 1 PLACES.
                          ls_struc_attr_gesamt_erw2-condition = 'KANN'.
                          ls_struc_attr_gesamt_erw2-status = k_icon_yellow.
                          ls_struc_attr_gesamt_erw2-text = |Attribut für { lv_kann } nicht vorhanden.| ##NO_TEXT.
                          APPEND ls_struc_attr_gesamt_erw2 TO lt_struc_attr_gesamt_erw2.
                        ENDIF.

                        CLEAR ls_struc_attr_gesamt_erw2.
                      ENDIF.
                    ENDLOOP.

                  ELSE.  " ZFUNK nicht existiert.

                    IF <fs_objec2>-otype = 'S'.
                      SELECT SINGLE plsty   " ob virtuell ?
                             FROM hrp9808
                 WHERE plvar = '01' AND otype = @<fs_objec2>-otype AND objid = @<fs_objec2>-objid AND begda <= @sy-datum AND endda >= @sy-datum
          INTO @DATA(l_v2).                             "#EC CI_NOORDER

                      IF sy-subrc = 0 AND l_v2 = 'V'.

                        " Alle Rollen lesen
                        SELECT otype, objid, subty, sobid
                                              FROM hrp1001
             WHERE objid = @<fs_objec2>-objid AND otype = 'S' AND sclas = 'AG' AND begda <= @sy-datum AND endda >= @sy-datum AND plvar = '01'
INTO TABLE @DATA(lt_r_et2).

                        IF lt_r_et2 IS NOT INITIAL AND sy-subrc = 0.

                          " obligatorische Funktionen holen
                          LOOP AT lt_r_et2 ASSIGNING FIELD-SYMBOL(<fs_lt_r_et2>).

                            DATA(lv_rll_t2)  = <fs_lt_r_et2>-sobid+0(2).
                            DATA(lv_rll_n2)  = <fs_lt_r_et2>-sobid+2(2).

                            SELECT SINGLE funktion FROM @lt_tab_result AS rff2
                                WHERE typ_rolle = @lv_rll_t2 AND rolle_nr = @lv_rll_n2
                            INTO @DATA(lt_tmp_f_e2) ##ITAB_KEY_IN_SELECT ##ITAB_DB_SELECT.

                            IF sy-subrc = 0 AND lt_tmp_f_e IS NOT INITIAL.
                              APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid attrib = 'ZFUNK'
                              condition = '' status = k_icon_red text = 'Attribut ZFUNK ist nicht vorhanden.' ) TO lt_struc_attr_gesamt_erw2.
                              CLEAR ls_struc_attr_gesamt_erw2.
                              CONTINUE.
                            ENDIF.
                          ENDLOOP.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  ENDIF.

                  CLEAR lt_result2.
************************************************************************
*          entsprechend den Funktionen die richtigen Rollen            *
************************************************************************
                  IF  <fs_objec2>-otype = 'S'.

                    SELECT *
                           FROM @lt_struc_attr_gesamt_erw2 AS tab2f
                           WHERE nummer = @lv_nummer AND attrib = 'ZFUNK' AND low IS NOT INITIAL
                    INTO TABLE @DATA(result_table2) ##db_feature_mode[itabs_in_from_clause] ##ITAB_KEY_IN_SELECT.

                    IF result_table2 IS NOT INITIAL.

                      LOOP AT result_table2 ASSIGNING FIELD-SYMBOL(<fs_erw_sttruc2>).
                        SELECT * FROM @lt_tab_result AS res2 WHERE funktion = @<fs_erw_sttruc2>-low
                        INTO TABLE @DATA(lt_tmp_rolle2) ##ITAB_KEY_IN_SELECT ##ITAB_DB_SELECT.
                        APPEND LINES OF lt_tmp_rolle2 TO lt_rolle_name_table2.
                        CLEAR lt_tmp_rolle2.
                      ENDLOOP.

                      SORT lt_rolle_name_table2 BY typ_rolle rolle_nr funktion.
                      DELETE ADJACENT DUPLICATES FROM lt_rolle_name_table2 COMPARING typ_rolle rolle_nr funktion.

                      IF lt_rolle_name_table2 IS NOT INITIAL.

                        LOOP AT result_table2 ASSIGNING FIELD-SYMBOL(<fs_tpm_no_exist2>).
                          IF NOT line_exists( lt_rolle_name_table2[ funktion = <fs_tpm_no_exist2>-low ] ).

                            APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid attrib = ''
                                   condition = '' status = k_icon_yellow text = |AG nicht definiert: { <fs_tpm_no_exist2>-low }.| ) TO lt_struc_attr_gesamt_erw2.
                            CLEAR ls_struc_attr_gesamt_erw2.
                          ENDIF.
                        ENDLOOP.


                        LOOP AT lt_rolle_name_table2 ASSIGNING FIELD-SYMBOL(<fs_r2>).
                          CONCATENATE <fs_r2>-typ_rolle  <fs_r2>-rolle_nr '%' INTO DATA(lv_rolle_name2).

                          SELECT SINGLE otype, objid, subty, sobid FROM hrp1001
                            WHERE objid = @<fs_objec2>-objid AND sclas = 'AG' AND sobid LIKE @lv_rolle_name2
                            AND begda <= @sy-datum AND endda >= @sy-datum
                          INTO @DATA(lv_rolle_exist2).

                          IF sy-subrc = 0.

                            CLEAR arg_text.
                            SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name2 AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.

                            APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid attrib = 'ZFUNK'
condition = '' agr_text = arg_text status = k_icon_green text = |AG: { <fs_r2>-typ_rolle }{ <fs_r2>-rolle_nr } für { <fs_r2>-funktion }.| ) TO lt_struc_attr_gesamt_erw2.
                            CLEAR ls_struc_attr_gesamt_erw2.

***************************************************************************************
* Wenn Rolle existiert, Rolleninhalt aus agr1252 mit MUSS/KANN Attributen vergleichen *
***************************************************************************************
                            SELECT  otype, objid, subty, sobid FROM hrp1001
   WHERE objid = @<fs_objec2>-objid AND sclas = 'AG' AND sobid LIKE @lv_rolle_name2 AND begda <= @sy-datum AND endda >= @sy-datum
   INTO TABLE @DATA(lt_rolle_tb2).

                            SELECT * FROM @lt_struc_attr_gesamt_erw2 AS lt2
                     WHERE nummer = @lv_nummer AND attrib IS NOT INITIAL AND status NE @k_icon_red AND status NE @k_icon_yellow
                     INTO TABLE @DATA(lt_dat_tab2) ##ITAB_KEY_IN_SELECT.


                            LOOP AT lt_rolle_tb2 ASSIGNING FIELD-SYMBOL(<fs_lt_rolle_tb2>).

                              SELECT child_agr FROM agr_agrs
                              WHERE agr_name = @<fs_lt_rolle_tb2>-sobid "LIKE @lv_rolle_name2
                              INTO TABLE @DATA(agrs_tmp2).

                              IF agrs_tmp2 IS NOT INITIAL AND lt_dat_tab2 IS NOT INITIAL AND lt_t77omattot IS NOT INITIAL..
                                CLEAR: lt_agr12522, lt_field_values, lt_field_values_end, lt_field_values_tmp.

                                LOOP AT agrs_tmp2 ASSIGNING FIELD-SYMBOL(<fs_agrs2>).
                                  SELECT * FROM agr_1252
                                  WHERE agr_name = @<fs_agrs2>-child_agr AND low NE '*' AND low NE ''
                                  INTO TABLE @lt_agr1252_tmp2.
                                  APPEND LINES OF lt_agr1252_tmp2 TO lt_agr12522.
                                  CLEAR lt_agr1252_tmp2.


                                  " Berechtigungswerte zur rolle ermitteln
                                  CALL FUNCTION 'PRGN_1251_READ_FIELD_VALUES'
                                    EXPORTING
                                      activity_group = <fs_agrs2>-child_agr
                                    TABLES
                                      field_values   = lt_field_values
                                    EXCEPTIONS
                                      OTHERS         = 0.

                                  " als "gelöscht" markierte Einträge entfernen
                                  DELETE lt_field_values
                                         WHERE NOT deleted IS INITIAL. "#EC CI_STDSEQ

                                  MOVE-CORRESPONDING lt_field_values TO lt_field_values_tmp.
                                  CLEAR lt_field_values.

                                  LOOP AT lt_field_values_tmp ASSIGNING FIELD-SYMBOL(<fs_end_2>) WHERE agr_name IS INITIAL.
                                    <fs_end_2>-agr_name = <fs_agrs2>-child_agr.
                                  ENDLOOP.

                                  APPEND LINES OF lt_field_values_tmp TO lt_field_values_end.
                                  CLEAR lt_field_values_tmp.
                                ENDLOOP.

                                " UR12C nur wichtige Rollenwerte prüfen gegen Attribute
                                DATA(lt_rl_wrt2) = VALUE ty_ur12c( FOR i IN lt_tab_result
                                                                        WHERE ( typ_rolle = <fs_r2>-typ_rolle AND
                                                                                rolle_nr  = <fs_r2>-rolle_nr )
                                                                        ( i ) ).

                                SORT lt_rl_wrt2 BY funktion.
                                DELETE ADJACENT DUPLICATES FROM lt_rl_wrt2 COMPARING funktion.

                                CLEAR lt_r1_wrt_attr.
                                LOOP AT lt_rl_wrt2 ASSIGNING FIELD-SYMBOL(<fs_r1_wrt2>).
                                  SELECT attribut AS attrib, cond AS condition, funktion
                                       FROM /THKR/WF_CONTROL APPENDING TABLE @lt_r1_wrt_attr
                                  WHERE funktion = @<fs_r1_wrt2>-funktion.
                                ENDLOOP.

                                SORT lt_r1_wrt_attr BY attrib.
                                DELETE ADJACENT DUPLICATES FROM lt_r1_wrt_attr COMPARING attrib.

                              ENDIF.

                              CLEAR attr_rng.
                              IF lt_agr12522 IS NOT INITIAL.

                                DELETE lt_agr12522 WHERE low CS '$' OR
                                                         low CS '''' OR
                                                         low EQ 'DUMMY'.

                                SORT lt_agr12522 BY agr_name varbl.

                                LOOP AT lt_agr12522 ASSIGNING FIELD-SYMBOL(<fs_lt_agr12522>) WHERE low NE '*' GROUP BY <fs_lt_agr12522>-varbl.

                                  SELECT *
                                  FROM @lt_tab_result_13c AS t_13c2
                                  WHERE typ_orgebene = @<fs_lt_agr12522>-varbl
                           INTO TABLE @DATA(lt_org_13c_2) ##db_feature_mode[itabs_in_from_clause] ##ITAB_KEY_IN_SELECT.

                                  CLEAR attr_rng.
                                  LOOP AT lt_org_13c_2 ASSIGNING FIELD-SYMBOL(<fs_org_13c_2>).

                                    READ TABLE lt_t77omattot WITH KEY attrib = <fs_org_13c_2>-attrib TRANSPORTING NO FIELDS.

                                    IF sy-subrc = 0.

                                      " UR12C nur wichtige Rollenwerte prüfen gegen Attribute
                                      IF NOT line_exists( lt_r1_wrt_attr[ attrib = <fs_org_13c_2>-attrib  ] ).
                                        DELETE lt_org_13c_2.
                                        CONTINUE.
                                      ENDIF.
                                      ""

                                      IF NOT line_exists( lt_dat_tab2[ attrib = <fs_org_13c_2>-attrib  ] ).
                                        ls_struc_attr_gesamt_erw2-nummer = lv_nummer.
                                        ls_struc_attr_gesamt_erw2-objekttyp = <fs_objec2>-otype..
                                        ls_struc_attr_gesamt_erw2-objektid = <fs_objec2>-objid.
                                        ls_struc_attr_gesamt_erw2-attrib = <fs_org_13c_2>-attrib.

                                        ls_struc_attr_gesamt_erw2-atext = <fs_org_13c_2>-text.

                                        CLEAR arg_text.
                                        SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name2 AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.

                                        ls_struc_attr_gesamt_erw2-agr_text = arg_text.
*                                       ls_struc_attr_gesamt_erw2-condition = 'MUSS'.
                                        ls_struc_attr_gesamt_erw2-low  =  <fs_lt_agr12522>-low.
                                        ls_struc_attr_gesamt_erw2-high  = <fs_lt_agr12522>-high.
                                        ls_struc_attr_gesamt_erw2-status =  k_icon_red.
                                        ls_struc_attr_gesamt_erw2-text  = |Attr. aus { <fs_lt_agr12522>-agr_name } fehlt. Sammelrolle: { <fs_r2>-typ_rolle }{ <fs_r2>-rolle_nr }.| ##NO_TEXT.
                                        IF NOT line_exists( lt_struc_attr_gesamt_erw2[ table_line = ls_struc_attr_gesamt_erw2 ] ).
                                          APPEND ls_struc_attr_gesamt_erw2 TO lt_struc_attr_gesamt_erw2.
                                        ENDIF.
                                        CLEAR ls_struc_attr_gesamt_erw2.

                                      ELSE.

                                        DATA(lt_partn_tb_12522) = VALUE lt_agr_1252( FOR <partn_tb_2> IN GROUP <fs_lt_agr12522> ( <partn_tb_2> ) ).

                                        LOOP AT lt_partn_tb_12522 ASSIGNING FIELD-SYMBOL(<lt_partn_tb_12522>).

                                          IF <lt_partn_tb_12522>-high IS INITIAL.

                                            IF <lt_partn_tb_12522>-low CS '*'.
                                              option = 'CP'.
                                            ELSE.
                                              option = 'EQ'.
                                            ENDIF.

                                          ELSE.
                                            option = 'BT'.

                                            IF <lt_partn_tb_12522>-high CS 'Z'.
                                              REPLACE ALL OCCURRENCES OF 'Z' IN <lt_partn_tb_12522>-high WITH '9'.
                                            ENDIF.
                                          ENDIF.

                                          APPEND LINES OF VALUE rseloption( ( sign   = 'I'
                                                                              option = option
                                                                              low    = <lt_partn_tb_12522>-low
                                                                 high   = <lt_partn_tb_12522>-high ) ) TO attr_rng.


                                          IF <lt_partn_tb_12522>-high IS NOT INITIAL.
                                            IF <lt_partn_tb_12522>-low CS '*'.
                                              APPEND LINES OF VALUE rseloption( ( sign   = 'I'
                                                                                  option = 'CP'
                                                                                  low    = <lt_partn_tb_12522>-low
                                                                                  high   = '' ) ) TO attr_rng.
                                            ENDIF.

                                            IF <lt_partn_tb_12522>-high CS '*'.
                                              APPEND LINES OF VALUE rseloption( ( sign   = 'I'
                                                                                  option = 'CP'
                                                                                  low    = <lt_partn_tb_12522>-high
                                                                                  high   = '' ) ) TO attr_rng.
                                            ENDIF.
                                          ENDIF.

                                        ENDLOOP.
                                        " CLEAR lt_partn_tb_12522.
                                      ENDIF.
                                    ENDIF.
                                  ENDLOOP.

                                  SORT attr_rng.
                                  DELETE ADJACENT DUPLICATES FROM attr_rng.

                                  " Vergleich
                                  LOOP AT lt_org_13c_2 ASSIGNING FIELD-SYMBOL(<fs_vgl2>).

                                    SELECT objekttyp, objektid, attrib , low, high FROM @lt_dat_tab2 AS itab_dat2
                                     WHERE attrib = @<fs_vgl2>-attrib AND nummer = @lv_nummer
                                    INTO TABLE @DATA(lv_treff_diff2).

                                    LOOP AT lv_treff_diff2 ASSIGNING FIELD-SYMBOL(<fs_treff_diff2>).

                                      IF <fs_treff_diff2>-low  CS '000000000' AND
                                         <fs_treff_diff2>-high CS 'ZZZZZZZZZ'.
                                        CONTINUE.
                                      ENDIF.

                                      IF <fs_treff_diff2>-high IS INITIAL.
                                        IF <fs_treff_diff2>-low NOT IN attr_rng.

                                          LOOP AT lt_partn_tb_12522 ASSIGNING FIELD-SYMBOL(<fs_ber_cell5>).

                                            ls_struc_attr_gesamt_erw2-nummer = lv_nummer.
                                            ls_struc_attr_gesamt_erw2-objekttyp = <fs_objec2>-otype.
                                            ls_struc_attr_gesamt_erw2-objektid =  <fs_objec2>-objid.
                                            ls_struc_attr_gesamt_erw2-attrib = <fs_vgl2>-attrib.
                                            ls_struc_attr_gesamt_erw2-atext = <fs_vgl2>-text.

                                            CLEAR arg_text.
                                            SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name2 AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.

                                            ls_struc_attr_gesamt_erw2-agr_text = arg_text.
*                                           ls_struc_attr_gesamt_erw-condition = <fs_lt_agr>.
                                            ls_struc_attr_gesamt_erw2-low  =  <fs_ber_cell5>-low.
                                            ls_struc_attr_gesamt_erw2-high  = <fs_ber_cell5>-high.
                                            ls_struc_attr_gesamt_erw2-status =  k_icon_red.
                                            ls_struc_attr_gesamt_erw2-text  = |Wert-Differenz { <fs_ber_cell5>-agr_name }. Sammelrolle: { <fs_r2>-typ_rolle }{ <fs_r2>-rolle_nr } [ vgl. { <fs_vgl2>-attrib }: { <fs_treff_diff2>-low } ].| ##NO_TEXT .
                                            IF NOT line_exists( lt_struc_attr_gesamt_erw2[ table_line = ls_struc_attr_gesamt_erw2 ] ).
                                              APPEND ls_struc_attr_gesamt_erw2 TO lt_struc_attr_gesamt_erw2.
                                            ENDIF.
                                            CLEAR ls_struc_attr_gesamt_erw2.
                                          ENDLOOP.

                                        ENDIF.
                                      ELSE.
                                        IF <fs_treff_diff2>-low NOT IN attr_rng OR <fs_treff_diff2>-high NOT IN attr_rng.

                                          LOOP AT lt_partn_tb_12522 ASSIGNING FIELD-SYMBOL(<fs_ber_cell6>).

                                            ls_struc_attr_gesamt_erw2-nummer = lv_nummer.
                                            ls_struc_attr_gesamt_erw2-objekttyp = <fs_objec2>-otype.
                                            ls_struc_attr_gesamt_erw2-objektid =  <fs_objec2>-objid.
                                            ls_struc_attr_gesamt_erw2-attrib = <fs_vgl2>-attrib.
                                            ls_struc_attr_gesamt_erw2-atext = <fs_vgl2>-text.

                                            CLEAR arg_text.
                                            SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name2 AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.

                                            ls_struc_attr_gesamt_erw2-agr_text = arg_text.
*                                           ls_struc_attr_gesamt_erw-condition = <fs_lt_agr>.
                                            ls_struc_attr_gesamt_erw2-low  =  <fs_ber_cell6>-low.
                                            ls_struc_attr_gesamt_erw2-high  = <fs_ber_cell6>-high.
                                            ls_struc_attr_gesamt_erw2-status =  k_icon_red.
                                            ls_struc_attr_gesamt_erw2-text  =
|Wert-Differenz { <fs_ber_cell6>-agr_name }. Sammelrolle: { <fs_r2>-typ_rolle }{ <fs_r2>-rolle_nr } [ vgl. { <fs_vgl2>-attrib }: { <fs_treff_diff2>-low }-{ <fs_treff_diff2>-high } ].| ##NO_TEXT .
                                            IF NOT line_exists( lt_struc_attr_gesamt_erw2[ table_line = ls_struc_attr_gesamt_erw2 ] ).
                                              APPEND ls_struc_attr_gesamt_erw2 TO lt_struc_attr_gesamt_erw2.
                                            ENDIF.
                                            CLEAR ls_struc_attr_gesamt_erw2.

                                          ENDLOOP.
                                        ENDIF.
                                      ENDIF.
                                    ENDLOOP.
                                  ENDLOOP.
                                  CLEAR lt_partn_tb_12522.
                                ENDLOOP.
                              ENDIF.

                              CLEAR lt_partn_tb_12522.
                              CLEAR attr_rng.
                              DELETE lt_field_values_end WHERE low EQ '*' OR
                                                               low EQ 'DUMMY' OR
                                                               low CS '$' OR
                                                               low CS '''' OR
                                                               low IS INITIAL.

                              SORT lt_field_values_end BY object field low high.
                              DELETE ADJACENT DUPLICATES FROM lt_field_values_end COMPARING object field low high.


                              IF lt_field_values_end IS NOT INITIAL.
                                LOOP AT lt_field_values_end  ASSIGNING FIELD-SYMBOL(<fs_values_12512>) GROUP BY <fs_values_12512>-field.

                                  READ TABLE lt_tab_result_02xxl WITH KEY typ_rolle = <fs_values_12512>-agr_name+0(2)
                                                                   rolle_nr = <fs_values_12512>-agr_name+2(2)
                                                                   objekt = <fs_values_12512>-object
                                                                   feld =  <fs_values_12512>-field
                                                                   ASSIGNING FIELD-SYMBOL(<fs_02xxl_2>).

                                  CHECK sy-subrc = 0 AND <fs_02xxl_2>-typ_berecht IS NOT INITIAL.


                                  IF <fs_02xxl_2>-typ_berecht = 'FISTL' OR <fs_02xxl_2>-typ_berecht = 'FIPEX'.
                                    IF <fs_values_12512>-low EQ '9999' OR <fs_values_12512>-low EQ 'TECH*'.
                                      CONTINUE.
                                    ENDIF.
                                  ENDIF.

                                  " sonder-Verarbeitung
                                  /THKR/CL_CHECK_KOMPL=>ber_obj_special_procedure(
                                    EXPORTING
                                      iv_object = <fs_values_12512>-object
                                      iv_field  = <fs_values_12512>-field
                                    CHANGING
                                      iv_low    = <fs_values_12512>-low
                                      iv_high   = <fs_values_12512>-high
                                  ).

                                  SELECT *
                                    FROM @lt_tab_result_13c AS t_13c_b2
                                    WHERE typ_berecht = @<fs_02xxl_2>-typ_berecht
              INTO TABLE @DATA(lt_org_13c_ber2) ##db_feature_mode[itabs_in_from_clause] ##ITAB_KEY_IN_SELECT.

                                  CLEAR attr_rng.
                                  LOOP AT lt_org_13c_ber2 ASSIGNING FIELD-SYMBOL(<fs_ber_13c_2>).
                                    READ TABLE lt_t77omattot WITH KEY attrib = <fs_ber_13c_2>-attrib TRANSPORTING NO FIELDS.

                                    IF sy-subrc = 0.

                                      " UR12C nur wichtige Rollenwerte prüfen gegen Attribute
                                      IF NOT line_exists( lt_r1_wrt_attr[ attrib = <fs_ber_13c_2>-attrib  ] ).
                                        DELETE lt_org_13c_ber2.
                                        CONTINUE.
                                      ENDIF.

                                      ""

                                      IF NOT line_exists( lt_dat_tab2[ attrib = <fs_ber_13c_2>-attrib  ] ).

                                        ls_struc_attr_gesamt_erw2-nummer = lv_nummer.
                                        ls_struc_attr_gesamt_erw2-objekttyp = <fs_objec2>-otype.
                                        ls_struc_attr_gesamt_erw2-objektid = <fs_objec2>-objid.
                                        ls_struc_attr_gesamt_erw2-attrib = <fs_ber_13c_2>-attrib.
                                        ls_struc_attr_gesamt_erw2-atext = <fs_ber_13c_2>-text.

                                        CLEAR arg_text.
                                        SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name2 AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.
                                        ls_struc_attr_gesamt_erw2-agr_text = arg_text.
*                                       ls_struc_attr_gesamt_erw-condition = 'MUSS'.
                                        ls_struc_attr_gesamt_erw2-low  =  <fs_values_12512>-low.
                                        ls_struc_attr_gesamt_erw2-high  = <fs_values_12512>-high.
                                        ls_struc_attr_gesamt_erw2-status =  k_icon_red.
                                        ls_struc_attr_gesamt_erw2-text  = |Attr. aus { <fs_values_12512>-agr_name } fehlt. Sammelrolle: { <fs_r2>-typ_rolle }{ <fs_r2>-rolle_nr }. Objekt: { <fs_values_12512>-object }.| ##NO_TEXT .
                                        IF NOT line_exists( lt_struc_attr_gesamt_erw2[ table_line = ls_struc_attr_gesamt_erw2 ] ).
                                          APPEND ls_struc_attr_gesamt_erw2 TO lt_struc_attr_gesamt_erw2.
                                        ENDIF.
                                        CLEAR ls_struc_attr_gesamt_erw2.

                                      ELSE.

                                        DATA(lt_partn_tb2) = VALUE lt_agr_1251( FOR <partn_tb2> IN GROUP <fs_values_12512> ( <partn_tb2> ) ).

                                        LOOP AT lt_partn_tb2 ASSIGNING FIELD-SYMBOL(<lt_partn_tb2>).

                                          IF <fs_02xxl_2>-typ_berecht = 'FISTL' OR <fs_02xxl_2>-typ_berecht = 'FIPEX'.
                                            IF <lt_partn_tb2>-low EQ '9999' OR <lt_partn_tb2>-low EQ 'TECH*'.
                                              DELETE lt_partn_tb2.
                                              CONTINUE.
                                            ENDIF.
                                          ENDIF.

                                          " sonder-Verarbeitung
                                          /THKR/CL_CHECK_KOMPL=>ber_obj_special_procedure(
                                            EXPORTING
                                              iv_object = <lt_partn_tb2>-object
                                              iv_field  = <lt_partn_tb2>-field
                                            CHANGING
                                              iv_low    = <lt_partn_tb2>-low
                                              iv_high   = <lt_partn_tb2>-high
                                          ).

                                          IF <lt_partn_tb2>-high IS INITIAL.
                                            IF <lt_partn_tb2>-low CS '*'.
                                              option = 'CP'.
                                            ELSE.
                                              option = 'EQ'.
                                            ENDIF.
                                          ELSE.
                                            option = 'BT'.

                                            IF <lt_partn_tb2>-high CS 'Z'.
                                              REPLACE ALL OCCURRENCES OF 'Z' IN <lt_partn_tb2>-high WITH '9'.
                                            ENDIF.
                                          ENDIF.

                                          APPEND LINES OF VALUE rseloption( ( sign   = 'I'
                                                                              option = option
                                                                              low    = <lt_partn_tb2>-low
                                                            high   = <lt_partn_tb2>-high ) ) TO attr_rng.

                                          IF <lt_partn_tb2>-high IS NOT INITIAL.
                                            IF <lt_partn_tb2>-low CS '*'.
                                              APPEND LINES OF VALUE rseloption( ( sign   = 'I'
                                                                                  option = 'CP'
                                                                              low    = <lt_partn_tb2>-low
                                                                             high   = '' ) ) TO attr_rng.
                                            ENDIF.

                                            IF <lt_partn_tb2>-high CS '*'.
                                              APPEND LINES OF VALUE rseloption( ( sign   = 'I'
                                                                                  option = 'CP'
                                                                             low    = <lt_partn_tb2>-high
                                                                             high   = '' ) ) TO attr_rng.
                                            ENDIF.
                                          ENDIF.

                                        ENDLOOP.
                                        "CLEAR lt_partn_tb2.

                                      ENDIF.
                                    ENDIF.
                                  ENDLOOP.

                                  SORT attr_rng.
                                  DELETE ADJACENT DUPLICATES FROM attr_rng.

                                  " Vergleich
                                  LOOP AT lt_org_13c_ber2 ASSIGNING FIELD-SYMBOL(<fs_vgl_ber2>).

                                    SELECT objekttyp, objektid, attrib , low, high FROM @lt_dat_tab2 AS itab_dat2
                                     WHERE attrib = @<fs_vgl_ber2>-attrib AND nummer = @lv_nummer
                                    INTO TABLE @DATA(lv_treff_difff2).

                                    LOOP AT lv_treff_difff2 ASSIGNING FIELD-SYMBOL(<fs_treff_difff2>).

                                      IF <fs_treff_difff2>-low  CS '000000000' AND
                                         <fs_treff_difff2>-high CS 'ZZZZZZZZZ'.
                                        CONTINUE.
                                      ENDIF.

                                      IF <fs_treff_difff2>-attrib EQ 'ZTITEL' OR
                                       <fs_treff_difff2>-attrib EQ 'ZTITEL_AO'.
                                        <fs_treff_difff2>-low = <fs_treff_difff2>-low+0(9).
                                        <fs_treff_difff2>-high = <fs_treff_difff2>-high+0(9).
                                      ENDIF.

                                      IF <fs_treff_difff2>-high IS INITIAL.
                                        IF <fs_treff_difff2>-low NOT IN attr_rng.

                                          LOOP AT lt_partn_tb2 ASSIGNING FIELD-SYMBOL(<fs_ber_cell7>).

                                            ls_struc_attr_gesamt_erw2-nummer = lv_nummer.
                                            ls_struc_attr_gesamt_erw2-objekttyp = <fs_objec2>-otype. .
                                            ls_struc_attr_gesamt_erw2-objektid =  <fs_objec2>-objid.
                                            ls_struc_attr_gesamt_erw2-attrib = <fs_vgl_ber2>-attrib.
                                            ls_struc_attr_gesamt_erw2-atext = <fs_vgl_ber2>-text.

                                            CLEAR arg_text.
                                            SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name2 AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.

                                            ls_struc_attr_gesamt_erw2-agr_text = arg_text.
*                                         ls_struc_attr_gesamt_erw-condition = <fs_lt_agr>.
                                            ls_struc_attr_gesamt_erw2-low  =  <fs_ber_cell7>-low.
                                            ls_struc_attr_gesamt_erw2-high  = <fs_ber_cell7>-high.
                                            ls_struc_attr_gesamt_erw2-status =  k_icon_red.
                                            ls_struc_attr_gesamt_erw2-text  =
|Wert-Differenz { <fs_ber_cell7>-agr_name }. Sammelrolle: { <fs_r2>-typ_rolle }{ <fs_r2>-rolle_nr }. Objekt: { <fs_values_12512>-object } [ vgl. { <fs_vgl_ber2>-attrib }: { <fs_treff_difff2>-low } ] .| ##NO_TEXT .

                                            IF NOT line_exists( lt_struc_attr_gesamt_erw2[ table_line = ls_struc_attr_gesamt_erw2 ] ).
                                              APPEND ls_struc_attr_gesamt_erw2 TO lt_struc_attr_gesamt_erw2.
                                            ENDIF.
                                            CLEAR ls_struc_attr_gesamt_erw2.
                                          ENDLOOP.
                                        ENDIF.
                                      ELSE.
                                        IF <fs_treff_difff2>-low NOT IN attr_rng OR <fs_treff_difff2>-high NOT IN attr_rng.

                                          LOOP AT lt_partn_tb2 ASSIGNING FIELD-SYMBOL(<fs_ber_cell8>).

                                            ls_struc_attr_gesamt_erw2-nummer = lv_nummer.
                                            ls_struc_attr_gesamt_erw2-objekttyp = <fs_objec2>-otype. .
                                            ls_struc_attr_gesamt_erw2-objektid =  <fs_objec2>-objid.
                                            ls_struc_attr_gesamt_erw2-attrib = <fs_vgl_ber2>-attrib.
                                            ls_struc_attr_gesamt_erw2-atext = <fs_vgl_ber2>-text.

                                            CLEAR arg_text.
                                            SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name2 AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.

                                            ls_struc_attr_gesamt_erw2-agr_text = arg_text.
*                                           ls_struc_attr_gesamt_erw-condition = <fs_lt_agr>.
                                            ls_struc_attr_gesamt_erw2-low  =  <fs_ber_cell8>-low.
                                            ls_struc_attr_gesamt_erw2-high  = <fs_ber_cell8>-high.
                                            ls_struc_attr_gesamt_erw2-status =  k_icon_red.
                                            ls_struc_attr_gesamt_erw2-text  =
|Wert-Differenz { <fs_ber_cell8>-agr_name }. Sammelrolle: { <fs_r2>-typ_rolle }{ <fs_r2>-rolle_nr }. Objekt: { <fs_values_12512>-object }  [ vgl. { <fs_vgl_ber2>-attrib }: { <fs_treff_difff2>-low }-{ <fs_treff_difff2>-high } ].| ##NO_TEXT .

                                            IF NOT line_exists( lt_struc_attr_gesamt_erw2[ table_line = ls_struc_attr_gesamt_erw2 ] ).
                                              APPEND ls_struc_attr_gesamt_erw2 TO lt_struc_attr_gesamt_erw2.
                                            ENDIF.
                                            CLEAR ls_struc_attr_gesamt_erw2.
                                          ENDLOOP.

                                        ENDIF.
                                      ENDIF.
                                    ENDLOOP.
                                  ENDLOOP.
                                  CLEAR lt_partn_tb2.
                                ENDLOOP.
                              ENDIF.
                              CLEAR lt_partn_tb2.
                            ENDLOOP.
                            CLEAR: lt_rolle_tb2, attr_rng.

**************************************************************************************
                          ELSE.
******************************************************************************************************************************************
* 18.01.2022 14:29:28  REPRO-KOE: mindestens eine passende FR vorhanden ist -> Ampel grün/(früher Warnmeldung). Wenn gar keine passende FR  – Fehlermeldung. *
******************************************************************************************************************************************
                            UNASSIGN <fs_w_e2>.
                            LOOP AT lt_rolle_name_table2 ASSIGNING FIELD-SYMBOL(<fs_w2>) WHERE funktion = <fs_r2>-funktion.
                              CONCATENATE <fs_w2>-typ_rolle  <fs_w2>-rolle_nr '%' INTO DATA(lv_r_w2).

                              SELECT SINGLE otype, objid, subty, sobid
                              FROM hrp1001
WHERE objid = @<fs_objec2>-objid AND sclas = 'AG' AND sobid LIKE @lv_r_w2 AND begda <= @sy-datum AND endda >= @sy-datum AND plvar = '01'
INTO @DATA(lv_rolle_w2).

                              IF sy-subrc = 0.
                                ASSIGN k_icon_green TO <fs_w_e2>.
                                EXIT.
                              ENDIF.


                              CLEAR lv_exist.

                              LOOP AT lt_tab_result_11xxl ASSIGNING FIELD-SYMBOL(<fs_11xxl_data_3>).

                                CALL FUNCTION 'Z_NSI_AGR_RFC_EXIST_ON_PLANS'
                                  DESTINATION <fs_11xxl_data_3>-rfcdest
                                  EXPORTING
                                    typ_rolle = <fs_w2>-typ_rolle
                                    rolle_nr  = <fs_w2>-rolle_nr
                                    plans     = <fs_objec2>-objid
                                  IMPORTING
                                    rv_exist  = lv_exist.

                                IF lv_exist = 'X'.
                                  ASSIGN k_icon_green TO <fs_w_e2>.
                                  EXIT.
                                ENDIF.
                              ENDLOOP.

                              IF lv_exist = 'X'.
                                EXIT.
                              ENDIF.
                            ENDLOOP.
******************************************************************************************************************************************
                            IF <fs_w_e2> IS NOT ASSIGNED.
                              ASSIGN k_icon_red TO <fs_w_e2>.
                            ENDIF.

                            IF <fs_w_e2> IS ASSIGNED.

                              CLEAR arg_text.
                              SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @lv_rolle_name2 AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.

                              CLEAR lv_exist.

                              LOOP AT lt_tab_result_11xxl ASSIGNING FIELD-SYMBOL(<fs_11xxl_data_4>).


                                CALL FUNCTION 'Z_NSI_AGR_RFC_EXIST_ON_PLANS'
                                  DESTINATION <fs_11xxl_data_4>-rfcdest
                                  EXPORTING
                                    typ_rolle = <fs_r2>-typ_rolle
                                    rolle_nr  = <fs_r2>-rolle_nr
                                    plans     = <fs_objec2>-objid
                                  IMPORTING
                                    rv_exist  = lv_exist.

                                IF lv_exist = 'X'.
                                  DATA(lv_rfc_system_2) = <fs_11xxl_data_4>-rfcdest.
                                  EXIT.
                                ENDIF.
                              ENDLOOP.

                              IF sy-subrc IS NOT INITIAL.
                                APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid attrib = ''
condition = '' agr_text = arg_text status = <fs_w_e2> text = |Keine AG: { <fs_r2>-typ_rolle }{ <fs_r2>-rolle_nr } für { <fs_r2>-funktion }.| ) TO lt_struc_attr_gesamt_erw2.
                                CLEAR ls_struc_attr_gesamt_erw2.
                              ENDIF.

                              IF lv_exist = 'X'.
                                CONCATENATE 'Fehlende Rolle' <fs_r2>-typ_rolle <fs_r2>-rolle_nr 'für' <fs_r2>-funktion 'im System' lv_rfc_system_2 'entdeckt.' INTO lv_rfc_agr SEPARATED BY space.
                                APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid  attrib = ''
                                      condition = '' agr_text = arg_text status = k_icon_green text = lv_rfc_agr ) TO lt_struc_attr_gesamt_erw2.
                                CLEAR ls_struc_attr_gesamt_erw.
                              ELSE.
                                APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid attrib = ''
condition = '' agr_text = arg_text status = <fs_w_e2> text = |Keine AG: { <fs_r2>-typ_rolle }{ <fs_r2>-rolle_nr } für { <fs_r2>-funktion }.| ) TO lt_struc_attr_gesamt_erw2.
                                CLEAR ls_struc_attr_gesamt_erw2.
                              ENDIF.


                            ENDIF.
                          ENDIF.

                        ENDLOOP. " lt_rolle_name_table ASSIGNING FIELD-SYMBOL(<fs_rl>)
                      ELSE.

                        LOOP AT result_table2 ASSIGNING FIELD-SYMBOL(<fs_keine_r2>).
                          APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid attrib = ''
                                 condition = '' status = k_icon_yellow text = |Rolle nicht definiert: { <fs_keine_r2>-low }.| ) TO lt_struc_attr_gesamt_erw2.
                          CLEAR ls_struc_attr_gesamt_erw2.
                        ENDLOOP.

                      ENDIF. " lt_rolle_name_table IS NOT INITIAL
                    ENDIF.   " result_table IS NOT INITIAL
                  ENDIF.

                  CLEAR result_table2.
************************************************************************
*                von F.Rollen zu ZFunk                    Test         *
************************************************************************
                  IF  <fs_objec2>-otype = 'S'.
                    /THKR/CL_CHECK_KOMPL=>check_zfunk_to_agr(
                       EXPORTING
                         iv_objid    = <fs_objec2>-objid
                         it_ur12c    = lt_tab_result
                         it_11xxl    = lt_tab_result_11xxl
                         iv_nummer   = lv_nummer
                         it_attr_erw = lt_struc_attr_gesamt_erw2
                         iv_dest     = lv_dest
                       RECEIVING
                         rt_values   =  rt_values
                         ) .

                    LOOP AT rt_values ASSIGNING <fs_rt_values>.
                      CLEAR arg_text.

                      IF <fs_rt_values>-rolle IS NOT INITIAL.
                        CONCATENATE <fs_rt_values>-rolle '%' INTO <fs_rt_values>-rolle.
                        SELECT SINGLE text FROM agr_texts WHERE agr_name LIKE @<fs_rt_values>-rolle AND spras = 'D' AND line = '00000' AND text NE '' INTO @arg_text.
                      ENDIF.

                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid attrib = ''
                             condition = '' agr_text = arg_text status = k_icon_red text = <fs_rt_values>-text ) TO lt_struc_attr_gesamt_erw2.
                      CLEAR ls_struc_attr_gesamt_erw2.
                    ENDLOOP.

                    CLEAR rt_values.
                  ENDIF.

************************************************************************
*                PR-EBENE Attribute ZOM_CHECK_CUST_A                   *
************************************************************************
                  IF  <fs_objec2>-otype = 'O'.
                    CLEAR lt_check_cust_a_o.

                    SELECT * FROM /THKR/OM_C_CUS_A
                    INTO TABLE lt_check_cust_a_o
                    WHERE otype = 'O'.

                    SELECT SINGLE objid
                    FROM hrp9809
WHERE otype = @<fs_objec2>-otype AND objid = @<fs_objec2>-objid AND orgty = 'PR' AND begda <= @sy-datum AND endda >= @sy-datum
INTO @DATA(ls_hr_ebene2).

                    IF sy-subrc = 0.

                      IF lt_check_cust_a_o IS NOT INITIAL.

                        LOOP AT lt_check_cust_a_o ASSIGNING FIELD-SYMBOL(<fs_lt_check_cust_a_o2>).

                          IF <fs_lt_check_cust_a_o2>-attrib = 'BUKRS' OR <fs_lt_check_cust_a_o2>-attrib = 'EKORG'.
                            <fs_lt_check_cust_a_o2>-status = k_icon_yellow.
                          ENDIF.

                          IF NOT line_exists( lt_struc_attr_gesamt_erw2[ nummer = lv_nummer  objekttyp = <fs_objec2>-otype  objektid = <fs_objec2>-objid  attrib = <fs_lt_check_cust_a_o2>-attrib ] ).

                            APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid attrib = <fs_lt_check_cust_a_o2>-attrib
                            condition = '' status = <fs_lt_check_cust_a_o2>-status text = <fs_lt_check_cust_a_o2>-text ) TO lt_struc_attr_gesamt_erw2.
                            CLEAR ls_struc_attr_gesamt_erw2.

                          ELSE.

                            APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid attrib = <fs_lt_check_cust_a_o2>-attrib
                            condition = '' status = k_icon_green text = |Oblig. Attribut { <fs_lt_check_cust_a_o2>-attrib } auf PR-Ebene vorhanden.| ) TO lt_struc_attr_gesamt_erw2.
                            CLEAR ls_struc_attr_gesamt_erw2.

************************************************************************
*                 HR_Ebene - Vererbung                         *
************************************************************************

                            READ TABLE lt_struc_attr_gesamt_erw2  WITH KEY objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid nummer = lv_nummer attrib = <fs_lt_check_cust_a_o2>-attrib
                            ASSIGNING FIELD-SYMBOL(<fs_hr2>).

                            IF sy-subrc = 0.
                              IF  <fs_hr2>-objektid = <fs_hr2>-inh_objid.

                                APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid attrib = <fs_lt_check_cust_a_o2>-attrib
                                       condition = '' status = k_icon_green text = |Attribut { <fs_lt_check_cust_a_o2>-attrib } auf PR-Ebene nicht geerbt.| ) TO lt_struc_attr_gesamt_erw2.

                                CLEAR ls_struc_attr_gesamt_erw2.
*--------------------------------------------------------------------*
*     06.07.2021 08:08:43   WERKS, Geschäftsbereich eindeutig        *
*--------------------------------------------------------------------*
                                IF <fs_lt_check_cust_a_o2>-attrib = 'WERKS' OR <fs_lt_check_cust_a_o2>-attrib = 'ZPGSBR'.
                                  ls_pr_zpgsbr_werks2-nummer  = lv_nummer.
                                  ls_pr_zpgsbr_werks2-objekttyp = <fs_hr2>-objekttyp.
                                  ls_pr_zpgsbr_werks2-objektid  = <fs_hr2>-objektid.
                                  ls_pr_zpgsbr_werks2-attrib  = <fs_hr2>-attrib.
                                  ls_pr_zpgsbr_werks2-low  =   <fs_hr2>-low.
                                  ls_pr_zpgsbr_werks2-high = <fs_hr2>-high.

                                  APPEND ls_pr_zpgsbr_werks2 TO lt_pr_zpgsbr_werks2.
                                  CLEAR ls_pr_zpgsbr_werks2.
                                ENDIF.

                              ELSE.

                                APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid attrib = <fs_lt_check_cust_a_o2>-attrib
           condition = '' status = <fs_lt_check_cust_a_o2>-status text = |Attribut { <fs_lt_check_cust_a_o2>-attrib } auf PR-Ebene geerbt { <fs_hr2>-inh_objid }.| ) TO lt_struc_attr_gesamt_erw2.
                                CLEAR ls_struc_attr_gesamt_erw2.
                              ENDIF.

                              UNASSIGN <fs_hr2>.
                            ENDIF.
                          ENDIF.
                        ENDLOOP.
                      ENDIF.

                    ELSE.

************************************************************************
*      keine PR-Ebene, prüfen ob Kind-Element von PR-ID                *
************************************************************************
                      CALL FUNCTION 'RH_STRUC_GET'
                        EXPORTING
                          act_otype      = <fs_objec2>-otype
                          act_objid      = <fs_objec2>-objid
                          act_wegid      = 'O-O'
                          act_plvar      = '01'
                        TABLES
                          result_tab     = lt_result_tab_pr2
                          result_objec   = lt_result_objec_rp2
                          result_struc   = lt_result_struc_pr2
                        EXCEPTIONS
                          no_plvar_found = 1
                          no_entry_found = 2
                          OTHERS         = 3.

                      IF sy-subrc = 0.
                        IF lt_result_objec_rp2 IS NOT INITIAL.
                          LOOP AT lt_result_objec_rp2 ASSIGNING FIELD-SYMBOL(<fs_lt_result_objec_rp2>).
                            SELECT SINGLE objid FROM hrp9809 WHERE objid = @<fs_lt_result_objec_rp2>-objid AND orgty = 'PR' AND begda <= @sy-datum AND endda >= @sy-datum
                            INTO @DATA(ls_hr_check2).
                            IF sy-subrc = 0.

                              IF lt_check_cust_a_o IS NOT INITIAL.
                                LOOP AT lt_check_cust_a_o ASSIGNING FIELD-SYMBOL(<fs_lt_check_cust_a_o_kind2>).

                                  DATA(lv_status2) = k_icon_red.

                                  IF <fs_lt_check_cust_a_o_kind2>-attrib EQ 'EKORG' OR <fs_lt_check_cust_a_o_kind2>-attrib EQ 'BUKRS'.
                                    lv_status2 = k_icon_yellow.
                                  ENDIF.

                                  IF NOT line_exists( lt_struc_attr_gesamt_erw2[ nummer = lv_nummer  objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid  attrib = <fs_lt_check_cust_a_o_kind2>-attrib ] ).

                                    APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid attrib = <fs_lt_check_cust_a_o_kind2>-attrib
                       condition = '' status = lv_status2 text = |Oblig. Attribut { <fs_lt_check_cust_a_o_kind2>-attrib } fehlt! PR-ID { <fs_lt_result_objec_rp2>-objid }.| ) TO lt_struc_attr_gesamt_erw2.
                                    CLEAR ls_struc_attr_gesamt_erw2.

                                  ELSE.
*--------------------------------------------------------------------*
*     06.07.2021 08:08:43   WERKS, Geschäftsbereich eindeutig        *
*--------------------------------------------------------------------*
                                    IF <fs_lt_check_cust_a_o_kind2>-attrib = 'WERKS' OR <fs_lt_check_cust_a_o_kind2>-attrib = 'ZPGSBR'.

                                      READ TABLE lt_struc_attr_gesamt_erw2 WITH KEY objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid nummer = lv_nummer attrib = <fs_lt_check_cust_a_o_kind2>-attrib
                                       ASSIGNING FIELD-SYMBOL(<fs_hr_child2>).
                                      IF  <fs_hr_child2>-objektid = <fs_hr_child2>-inh_objid.
                                        ls_pr_zpgsbr_werks2-nummer  = lv_nummer.
                                        ls_pr_zpgsbr_werks2-objekttyp = <fs_hr_child2>-objekttyp.
                                        ls_pr_zpgsbr_werks2-objektid  = <fs_hr_child2>-objektid.
                                        ls_pr_zpgsbr_werks2-attrib  = <fs_hr_child2>-attrib.
                                        ls_pr_zpgsbr_werks2-low  =  <fs_hr_child2>-low.
                                        ls_pr_zpgsbr_werks2-high =  <fs_hr_child2>-high.
                                        APPEND ls_pr_zpgsbr_werks2 TO lt_pr_zpgsbr_werks2.
                                        CLEAR ls_pr_zpgsbr_werks2.
                                      ENDIF.
                                    ENDIF.
                                  ENDIF.

                                ENDLOOP.
                              ENDIF.
                            ENDIF.
                          ENDLOOP.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  ENDIF.

************************************************************************
*                Zusatz-Attribute Vergabestelle                        *
************************************************************************
*
*                  IF  <fs_objec2>-otype = 'S'.
*                    SELECT SINGLE low
*                    FROM @lt_struc_attr_gesamt_erw2 AS tb_struc2
* WHERE nummer = @lv_nummer AND attrib = 'ZFUNK' AND low = 'VGST'   ##ITAB_KEY_IN_SELECT
* INTO @DATA(lv_vgst2). " ##ITAB_KEY_IN_SELECT
*
*                    IF sy-subrc = 0.
*                      SELECT SINGLE low
*                      FROM @lt_struc_attr_gesamt_erw2 AS burks2
*WHERE nummer = @lv_nummer AND objekttyp = 'S'  AND attrib = 'BUKRS' AND low NE ''   ##ITAB_KEY_IN_SELECT
*INTO @DATA(lv_bukrs2). " ##ITAB_KEY_IN_SELECT
*
*                      IF sy-subrc NE 0.
*                        SELECT SINGLE low
*                        FROM @lt_struc_attr_gesamt_erw2 AS werks2
*WHERE nummer = @lv_nummer AND objekttyp = 'S' AND attrib = 'WERKS' AND low NE ''   ##ITAB_KEY_IN_SELECT
*INTO @DATA(lv_werks2). " ##ITAB_KEY_IN_SELECT
*
**Buchungskreis aus Werk ermitteln
*
*                        IF sy-subrc = 0.
*
*                          CREATE OBJECT lo_util.
*
*                          CALL METHOD lo_util->get_bukrs_by_werks
*                            EXPORTING
*                              iv_werks = CONV #( lv_werks2 )
*                            RECEIVING
*                              rv_bukrs = lv_bukrs2.
*
*                          CALL METHOD lo_util->get_zfrgvgb_by_bukrs
*                            EXPORTING
*                              iv_werks   = CONV #( lv_werks )
*                              iv_bukrs   = CONV #( lv_bukrs2 )
*                            RECEIVING
*                              rv_zfrgvgb = lv_btrg2.
*
*
*                          SELECT SINGLE low
*                          FROM @lt_struc_attr_gesamt_erw2 AS betrwert4
*              WHERE nummer = @lv_nummer AND objekttyp = 'S'  ##ITAB_KEY_IN_SELECT
*              AND  attrib = 'ZFRGVGB' AND low NE ''
*              INTO @DATA(lv_betr_wert4).
*
*                          IF sy-subrc NE 0.
*                            ls_struc_attr_gesamt_erw2-nummer = lv_nummer.
*                            ls_struc_attr_gesamt_erw2-objekttyp = <fs_objec2>-otype.
*                            ls_struc_attr_gesamt_erw2-objektid =  <fs_objec2>-objid.
*                            ls_struc_attr_gesamt_erw2-attrib =  'ZFRGVGB'.
*
*                            SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @ls_struc_attr_gesamt_erw2-attrib AND langu = 'D' . "#EC CI_NOORDER
*                            ls_struc_attr_gesamt_erw2-atext = lv_attr_txt.
*                            CLEAR lv_attr_txt.
*
*                            ls_struc_attr_gesamt_erw2-low = lv_btrg2.
*                            ls_struc_attr_gesamt_erw2-condition = ''.
*                            ls_struc_attr_gesamt_erw2-status =  k_icon_green.
*                            ls_struc_attr_gesamt_erw2-text  = |Betragsgrenze ZFRGVGB ist { lv_btrg2 }.| ##NO_TEXT .
*                            APPEND ls_struc_attr_gesamt_erw2 TO lt_struc_attr_gesamt_erw2.
*                            CLEAR ls_struc_attr_gesamt_erw2.
*                          ENDIF.
*                        ELSE.
*
*                          SELECT SINGLE low
*                          FROM @lt_struc_attr_gesamt_erw2 AS betrwert5
*          WHERE nummer = @lv_nummer AND objekttyp = 'S'  ##ITAB_KEY_IN_SELECT
*          AND  attrib = 'ZFRGVGB' AND low NE ''
*          INTO @DATA(lv_betr_wert5).
*
*                          IF sy-subrc NE 0.
*
*                            APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid attrib = 'BUKRS'
*                           condition = '' status = k_icon_red text = |WERKS und BUKRS fehlen. Betragsgrenze (ZFRGVGB) nicht ableitbar.| ) TO lt_struc_attr_gesamt_erw2.
*                            CLEAR ls_struc_attr_gesamt_erw2.
*                          ENDIF.
*
*                        ENDIF.
*                      ELSE.
** Die Betragsgrenze zu Bukrs holen
*
*                        SELECT SINGLE low
*                        FROM @lt_struc_attr_gesamt_erw2 AS betrwert6
*        WHERE nummer = @lv_nummer AND objekttyp = 'S'  ##ITAB_KEY_IN_SELECT
*        AND  attrib = 'ZFRGVGB' AND low NE ''
*        INTO @DATA(lv_betr_wert6).
*
*                        IF sy-subrc NE 0.
*                          CREATE OBJECT lo_util.
*                          CALL METHOD lo_util->get_zfrgvgb_by_bukrs
*                            EXPORTING
*                              iv_werks   = CONV #( lv_werks )
*                              iv_bukrs   = CONV #( lv_bukrs2 )
*                            RECEIVING
*                              rv_zfrgvgb = lv_btrg2.
*
*                          ls_struc_attr_gesamt_erw2-nummer = lv_nummer.
*                          ls_struc_attr_gesamt_erw2-objekttyp = <fs_objec2>-otype.
*                          ls_struc_attr_gesamt_erw2-objektid =  <fs_objec2>-objid.
*                          ls_struc_attr_gesamt_erw2-attrib =  'ZFRGVGB'.
*
*                          SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @ls_struc_attr_gesamt_erw2-attrib AND langu = 'D' . "#EC CI_NOORDER
*                          ls_struc_attr_gesamt_erw2-atext = lv_attr_txt.
*                          CLEAR lv_attr_txt.
*
*                          ls_struc_attr_gesamt_erw2-low = lv_btrg2.
*                          ls_struc_attr_gesamt_erw2-condition = ''.
*                          ls_struc_attr_gesamt_erw2-status =  k_icon_green.
*                          ls_struc_attr_gesamt_erw2-text  = |Betragsgrenze ZFRGVGB ist { lv_btrg2 }. | ##NO_TEXT.
*                          APPEND ls_struc_attr_gesamt_erw2 TO lt_struc_attr_gesamt_erw2.
*                          CLEAR ls_struc_attr_gesamt_erw2.
*                        ENDIF.
*                      ENDIF.
*                    ENDIF.
*                  ENDIF.


************************************************************************
*                Zusatz-Attribute Buge                                 *
************************************************************************
*                  IF  <fs_objec2>-otype = 'S'.
*                    CLEAR rt_values_erw.
*                    /THKR/CL_CHECK_KOMPL=>check_zbtrg_ao_buge(
*                      EXPORTING
*                        iv_objid    =  <fs_objec2>-objid
*                        iv_nummer   =  lv_nummer
*                        it_attr_erw =  lt_struc_attr_gesamt_erw2
*                      RECEIVING rt_values = rt_values_erw  ).
*
*                    LOOP AT rt_values_erw ASSIGNING FIELD-SYMBOL(<fs_v2>).
*                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype
*                                                                   objektid = <fs_objec2>-objid attrib = <fs_v2>-attrib
*                                                                   low = <fs_v2>-low high = <fs_v2>-high condition = ''
*                                                                   status = k_icon_red text = <fs_v2>-text )
*                                                                   TO lt_struc_attr_gesamt_erw2.
*                      CLEAR ls_struc_attr_gesamt_erw2.
*                    ENDLOOP.
*                    CLEAR rt_values.
*                  ENDIF.

************************************************************************
*                Zusatz-Attribute WAGE                                 *
************************************************************************
*                  IF  <fs_objec2>-otype = 'S'.
*                    SELECT SINGLE low
*                    FROM @lt_struc_attr_gesamt_erw2 AS tb_struc_wage2
*WHERE nummer = @lv_nummer AND attrib = 'ZFUNK' AND low = 'WAGE'   ##ITAB_KEY_IN_SELECT
*INTO @DATA(lv_wage2). " ##ITAB_KEY_IN_SELECT
*
*                    IF sy-subrc = 0.
*                      SELECT SINGLE low
*                      FROM @lt_struc_attr_gesamt_erw2 AS b_dst2
*  WHERE nummer = @lv_nummer AND objekttyp = 'S'  ##ITAB_KEY_IN_SELECT
*  AND  attrib = 'ZWGRP_DSTL' AND low NE ''
*  INTO @DATA(lv_betr_dstl2).
*
*                      IF sy-subrc NE 0.
*                        SELECT low
*                        FROM @lt_struc_attr_gesamt_erw2 AS werk2
*WHERE nummer = @lv_nummer AND objekttyp = 'S' AND attrib = 'WERKS' AND low NE '' AND ( status NE @k_icon_red AND status NE @k_icon_yellow )    ##ITAB_KEY_IN_SELECT
*INTO TABLE @DATA(lt_werk2). " ##ITAB_KEY_IN_SELECT
*
*                        IF sy-subrc = 0.
*
*                          SORT lt_werk2 BY low.
*                          DELETE ADJACENT DUPLICATES FROM lt_werk2 COMPARING low.
*
*                          LOOP AT lt_werk2  ASSIGNING FIELD-SYMBOL(<fs_werk2>).
*                            DATA(lt_range_wage2) = zcl_om_wf_util=>get_zwgrp_dstl_by_werks( CONV #( <fs_werk2>-low ) ).
*
*                            IF sy-tabix >= 1 AND 'xxxxxxxxx' NOT IN lt_range_wage2 .
*
*                              LOOP AT lt_range_wage2 ASSIGNING FIELD-SYMBOL(<fs_lt_range_wage2>).
*
*                                ls_struc_attr_gesamt_erw2-nummer = lv_nummer.
*                                ls_struc_attr_gesamt_erw2-objekttyp = <fs_objec2>-otype.
*                                ls_struc_attr_gesamt_erw2-objektid =  <fs_objec2>-objid.
*                                ls_struc_attr_gesamt_erw2-attrib =  'ZWGRP_DSTL'.
*                                ls_struc_attr_gesamt_erw2-low  = <fs_lt_range_wage2>-low.
*                                ls_struc_attr_gesamt_erw2-high = <fs_lt_range_wage2>-high.
*                                ls_struc_attr_gesamt_erw2-condition = ''.
*
*                                SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @ls_struc_attr_gesamt_erw2-attrib AND langu = 'D' . "#EC CI_NOORDER
*                                ls_struc_attr_gesamt_erw2-atext = lv_attr_txt.
*                                CLEAR lv_attr_txt.
*
*                                ls_struc_attr_gesamt_erw2-status =  k_icon_yellow.
*                                ls_struc_attr_gesamt_erw2-text  = |ZWGRP_DSTL ist abgeleitet.| ##NO_TEXT.
*                                APPEND ls_struc_attr_gesamt_erw2 TO lt_struc_attr_gesamt_erw2.
*                                CLEAR ls_struc_attr_gesamt_erw2.
*
*                              ENDLOOP.
*                            ENDIF.
*                          ENDLOOP.
*
*                          SELECT SINGLE low
*                     FROM @lt_struc_attr_gesamt_erw2 AS b_dstl2
*WHERE nummer = @lv_nummer AND objekttyp = 'S'  ##ITAB_KEY_IN_SELECT
*AND  attrib = 'ZWGRP_DSTL' AND ( low NE '' OR text NE '' )
*INTO @DATA(lv_betr_dstl_exist2).
*
*                          IF sy-subrc NE 0.
*                            APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid attrib = 'ZWGRP_DSTL'
*                                   condition = '' status = k_icon_red text = |ZWGRP_DSTL ist nicht ableitbar.| ) TO lt_struc_attr_gesamt_erw2.
*                            CLEAR ls_struc_attr_gesamt_erw2.
*                          ENDIF.
*                        ELSE.
*                          APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = lv_nummer objekttyp = <fs_objec2>-otype objektid = <fs_objec2>-objid attrib = 'WERKS'
*                                 condition = '' status = k_icon_red text = |WERKS fehlt, ZWGRP_DSTL nicht ableitbar.| ) TO lt_struc_attr_gesamt_erw2.
*                          CLEAR ls_struc_attr_gesamt_erw2.
*                        ENDIF.
*                      ENDIF.
**************************************************************************
***                ZWGRPFB -->  ZWGRP_DSTL                               *
**************************************************************************
*                      SELECT attrib, low, high
*                   FROM @lt_struc_attr_gesamt_erw2 AS b_dstl2
*WHERE nummer = @lv_nummer AND objekttyp = 'S'  ##ITAB_KEY_IN_SELECT
*AND  attrib = 'ZWGRP_DSTL' AND ( low NE '' OR status = @k_icon_yellow )
*INTO TABLE @DATA(lt_zwgrp_dstl2).
*
*
*                      IF sy-subrc = 0.
*
*                        SORT lt_zwgrp_dstl2 BY attrib low high.
*                        DELETE ADJACENT DUPLICATES FROM lt_zwgrp_dstl2 COMPARING attrib low high.
*
*                        SELECT attrib, low, high
*                FROM @lt_struc_attr_gesamt_erw2 AS b_dst222
*WHERE nummer = @lv_nummer AND objekttyp = 'S'  ##ITAB_KEY_IN_SELECT
*AND  attrib = 'ZWGRPFB' AND ( low NE '' OR status = @k_icon_green )
*INTO TABLE @DATA(lt_zwgrpfb2).
*
*                        IF sy-subrc = 0.
*
*                          CLEAR lt_range.
*                          LOOP AT lt_zwgrp_dstl2 ASSIGNING FIELD-SYMBOL(<fs_lt_zwgrp_dstl2>).
*                            IF <fs_lt_zwgrp_dstl2>-high IS NOT INITIAL.
*                              lt_range = VALUE #( BASE lt_range ( sign = 'I' option = 'BT' low = <fs_lt_zwgrp_dstl2>-low high = <fs_lt_zwgrp_dstl2>-high ) ).
*                            ELSE.
*                              lt_range = VALUE #( BASE lt_range ( sign = 'I' option = 'EQ' low = <fs_lt_zwgrp_dstl2>-low  ) ).
*                            ENDIF.
*                          ENDLOOP.
*
*                          SORT lt_zwgrpfb2 BY attrib low high.
*                          DELETE ADJACENT DUPLICATES FROM lt_zwgrpfb2 COMPARING attrib low high.
*
*                          LOOP AT lt_zwgrpfb2 ASSIGNING FIELD-SYMBOL(<fs_lt_zwgrpfb2>).
*
*                            IF <fs_lt_zwgrpfb2>-high IS INITIAL.
*
*                              IF  <fs_lt_zwgrpfb2>-low NOT IN lt_range.
*                                ls_struc_attr_gesamt_erw2-nummer = lv_nummer.
*                                ls_struc_attr_gesamt_erw2-objekttyp = <fs_objec2>-otype.
*                                ls_struc_attr_gesamt_erw2-objektid =  <fs_objec2>-objid.
*                                ls_struc_attr_gesamt_erw2-attrib = <fs_lt_zwgrpfb2>-attrib.
*                                ls_struc_attr_gesamt_erw2-low = <fs_lt_zwgrpfb2>-low.
*                                " ls_struc_attr_gesamt_erw-condition = 'MUSS'.
*
*                                SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @ls_struc_attr_gesamt_erw2-attrib AND langu = 'D' . "#EC CI_NOORDER
*                                ls_struc_attr_gesamt_erw2-atext = lv_attr_txt.
*                                CLEAR lv_attr_txt.
*
*                                ls_struc_attr_gesamt_erw2-status =  k_icon_red.
*                                ls_struc_attr_gesamt_erw2-text  = |ZWGRPFB ist nicht in ZWGRP_DSTL enthalten.| ##NO_TEXT .
*                                APPEND ls_struc_attr_gesamt_erw2 TO lt_struc_attr_gesamt_erw2.
*                                CLEAR ls_struc_attr_gesamt_erw2.
*                              ENDIF.
*
*                            ELSE.
*
*                              IF <fs_lt_zwgrpfb2>-low NOT IN lt_range OR <fs_lt_zwgrpfb2>-high NOT IN lt_range.
*                                ls_struc_attr_gesamt_erw2-nummer = lv_nummer.
*                                ls_struc_attr_gesamt_erw2-objekttyp = <fs_objec2>-otype.
*                                ls_struc_attr_gesamt_erw2-objektid =  <fs_objec2>-objid.
*                                ls_struc_attr_gesamt_erw2-attrib = <fs_lt_zwgrpfb2>-attrib.
*                                ls_struc_attr_gesamt_erw2-low = <fs_lt_zwgrpfb2>-low.
*                                ls_struc_attr_gesamt_erw2-high = <fs_lt_zwgrpfb2>-high.
*                                " ls_struc_attr_gesamt_erw-condition = 'MUSS'.
*
*                                SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @ls_struc_attr_gesamt_erw2-attrib AND langu = 'D' . "#EC CI_NOORDER
*                                ls_struc_attr_gesamt_erw2-atext = lv_attr_txt.
*                                CLEAR lv_attr_txt.
*
*                                ls_struc_attr_gesamt_erw2-status =  k_icon_red.
*                                ls_struc_attr_gesamt_erw2-text  = |ZWGRPFB ist nicht in ZWGRP_DSTL enthalten.| ##NO_TEXT .
*                                APPEND ls_struc_attr_gesamt_erw2 TO lt_struc_attr_gesamt_erw2.
*                                CLEAR ls_struc_attr_gesamt_erw2.
*                              ENDIF.
*                            ENDIF.
*                          ENDLOOP.
*                        ENDIF.
*                      ENDIF.
*                    ENDIF.
*                  ENDIF.


                  CLEAR: lt_rolle_name_table2, lt_tmp_rolle2, lv_rolle_exist2, lt_dat_tab2,
                     lv_treff_diff2, lt_agr1252_tmp2, agrs_tmp2, lt_agr12522, lt_rolle_tb2.
                  CLEAR: ls_struc_attr2, lt_result_zom2.

                  " Nur fehlerhafte Datensätze anzeigen
                  IF p_par5 = 'X'.
                    DELETE lt_struc_attr_gesamt_erw2 WHERE NOT status EQ k_icon_yellow AND
                                                           NOT status EQ k_icon_red.

                  ENDIF.


                  APPEND LINES OF lt_struc_attr_gesamt_erw2 TO lt_struc_attr_gesamt_erw_end2.
                  CLEAR: lt_struc_attr_gesamt_erw2, ls_struc_attr_gesamt_erw2.
                  lv_nummer = lv_nummer + 1.

              ENDCASE.
            ENDLOOP.
          ELSE.
            MESSAGE 'Zu dem Objekt existieren keine TopDown-Elemente.' TYPE 'E' ##NO_TEXT.
          ENDIF. " sy-subrc = 0.
        ELSE.
          MESSAGE 'ID ist in HRP1000 nicht vorhanden.' TYPE 'E' ##NO_TEXT.
        ENDIF. " IF ls_selectopt3 IS NOT INITIAL.
      ELSE.
        MESSAGE 'Bitte fügen Sie mindestens eine Objekt-ID ein.' TYPE 'E' ##NO_TEXT.
      ENDIF.
    ENDIF. "TopDown

    " WRITE 'ok'.

*--------------------------------------------------------------------*
*     06.07.2021 08:08:43   WERKS, Geschäftsbereich eindeutig        *
*--------------------------------------------------------------------*

    IF lt_pr_zpgsbr_werks2 IS NOT INITIAL.

      LOOP AT lt_pr_zpgsbr_werks2 ASSIGNING FIELD-SYMBOL(<fs_attrib_wert3>) WHERE attrib = 'WERKS'.

        LOOP AT lt_pr_zpgsbr_werks2 ASSIGNING FIELD-SYMBOL(<fs_attrib_wert_eind3>) WHERE attrib = 'WERKS'.
          IF <fs_attrib_wert3>-low  = <fs_attrib_wert_eind3>-low AND <fs_attrib_wert3>-objektid NE <fs_attrib_wert_eind3>-objektid.
            ls_struc_attr_gesamt_erw2-nummer = <fs_attrib_wert3>-nummer.
            ls_struc_attr_gesamt_erw2-objekttyp = <fs_attrib_wert3>-objekttyp.
            ls_struc_attr_gesamt_erw2-objektid = <fs_attrib_wert3>-objektid .
            ls_struc_attr_gesamt_erw2-attrib = <fs_attrib_wert3>-attrib.

            SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @ls_struc_attr_gesamt_erw2-attrib AND langu = 'D' . "#EC CI_NOORDER
            ls_struc_attr_gesamt_erw2-atext = lv_attr_txt.
            CLEAR lv_attr_txt.

            ls_struc_attr_gesamt_erw2-low =  <fs_attrib_wert3>-low.
            ls_struc_attr_gesamt_erw2-high =  <fs_attrib_wert3>-high.
            ls_struc_attr_gesamt_erw2-status =  k_icon_red.
            ls_struc_attr_gesamt_erw2-text  = | Attr. { <fs_attrib_wert3>-attrib } ist nicht eindeutig: { <fs_attrib_wert_eind3>-objektid }| .

            DATA(lv_line_index3) = line_index( lt_struc_attr_gesamt_erw_end2[ nummer = <fs_attrib_wert3>-nummer objekttyp = <fs_attrib_wert3>-objekttyp
            objektid = <fs_attrib_wert3>-objektid attrib = <fs_attrib_wert3>-attrib low = <fs_attrib_wert3>-low ] ).
            IF lv_line_index3 > 0.
              INSERT ls_struc_attr_gesamt_erw2 INTO lt_struc_attr_gesamt_erw_end2 INDEX lv_line_index3.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      LOOP AT lt_pr_zpgsbr_werks2 ASSIGNING FIELD-SYMBOL(<fs_attrib_wert4>) WHERE attrib = 'ZPGSBR'.

        LOOP AT lt_pr_zpgsbr_werks2 ASSIGNING FIELD-SYMBOL(<fs_attrib_wert_eind4>) WHERE attrib = 'ZPGSBR'.
          IF <fs_attrib_wert4>-low  = <fs_attrib_wert_eind4>-low AND <fs_attrib_wert4>-objektid NE <fs_attrib_wert_eind4>-objektid.
            ls_struc_attr_gesamt_erw2-nummer = <fs_attrib_wert4>-nummer.
            ls_struc_attr_gesamt_erw2-objekttyp = <fs_attrib_wert4>-objekttyp.
            ls_struc_attr_gesamt_erw2-objektid = <fs_attrib_wert4>-objektid .
            ls_struc_attr_gesamt_erw2-attrib = <fs_attrib_wert4>-attrib.

            SELECT SINGLE atext INTO @lv_attr_txt FROM t77omattrt WHERE attrib = @ls_struc_attr_gesamt_erw2-attrib AND langu = 'D' . "#EC CI_NOORDER
            ls_struc_attr_gesamt_erw2-atext = lv_attr_txt.
            CLEAR lv_attr_txt.

            ls_struc_attr_gesamt_erw2-low =  <fs_attrib_wert4>-low.
            ls_struc_attr_gesamt_erw2-high =  <fs_attrib_wert4>-high.
            ls_struc_attr_gesamt_erw2-status =  k_icon_red.
            ls_struc_attr_gesamt_erw2-text  = | Attr. { <fs_attrib_wert4>-attrib } ist nicht eindeutig: { <fs_attrib_wert_eind4>-objektid }| .

            DATA(lv_line_index4) = line_index( lt_struc_attr_gesamt_erw_end2[ nummer = <fs_attrib_wert4>-nummer objekttyp = <fs_attrib_wert4>-objekttyp
            objektid = <fs_attrib_wert4>-objektid attrib = <fs_attrib_wert4>-attrib low = <fs_attrib_wert4>-low ] ).
            IF lv_line_index4 > 0.
              INSERT ls_struc_attr_gesamt_erw2 INTO lt_struc_attr_gesamt_erw_end2 INDEX lv_line_index4.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      CLEAR lt_pr_zpgsbr_werks2.
    ENDIF.

************************************************************************
*         Ausgabe-Vorbereiten,                                         *
************************************************************************
    "geerbte Attribute ausblenden

*    IF p_par5 = 'X'.
*      CLEAR lt_struc_attr_gesamt_erw_end_f.
*
*      IF lt_struc_attr_gesamt_erw_end IS NOT INITIAL.
*        lt_struc_attr_gesamt_erw_end_f  = VALUE #(  FOR l IN lt_struc_attr_gesamt_erw_end  WHERE ( inherit = '' ) ( l ) ).
*        ASSIGN lt_struc_attr_gesamt_erw_end_f TO <fs_tabelle>.
*      ELSEIF lt_struc_attr_gesamt_erw_end2 IS NOT INITIAL.
*        lt_struc_attr_gesamt_erw_end_f  = VALUE #( FOR l IN lt_struc_attr_gesamt_erw_end2  WHERE ( inherit = '' ) ( l ) ).
*        ASSIGN lt_struc_attr_gesamt_erw_end_f TO <fs_tabelle>.
*      ENDIF.
*
*    ELSE.
    IF lt_struc_attr_gesamt_erw_end IS NOT INITIAL.
      ASSIGN lt_struc_attr_gesamt_erw_end TO <fs_tabelle>.
    ELSEIF lt_struc_attr_gesamt_erw_end2 IS NOT INITIAL.
      ASSIGN lt_struc_attr_gesamt_erw_end2 TO <fs_tabelle>.
    ENDIF.
*    ENDIF.


    IF <fs_tabelle> IS ASSIGNED.
      TRY.
          cl_salv_table=>factory(
*          EXPORTING
*              r_container = cl_gui_container=>default_screen
            IMPORTING
              r_salv_table = lref_table2
            CHANGING
              t_table      =  <fs_tabelle> ).

*************************************************************************
**         Container aufbauen, um eigene Buttons hinzuzufügen           *
*************************************************************************
*          lref_table2->get_functions( )->add_function( name = |{ lcl_events=>co_btn_xl_export2 }|
*                                                       icon = |{ icon_export }|
*                                                      text = 'Zusatzdaten'              ##NO_TEXT
*                                                      tooltip = 'Zusatzdaten aufrufen.' ##NO_TEXT
*                              position = if_salv_c_function_position=>right_of_salv_functions ).
*
*************************************************************************
**    Handler für Button (Protokoll)  -> siehe lok. Klasse lcl_events   *
*************************************************************************
*          SET HANDLER lcl_events=>on_toolbar_click2 FOR lref_table2->get_event( ).
************************************************************************
*          Sortier-Buttons, Excel-Ausgabe, uns                         *
************************************************************************
          gr_funct_extra = lref_table2->get_functions( ).
          gr_funct_extra->set_all(
              value = if_salv_c_bool_sap=>true
          ).
************************************************************************
*          Struktur-Spaltenbezeichner ändern  (Status/Vorhanden)       *
************************************************************************
          o_col2 = lref_table2->get_columns( )->get_column( 'STATUS' ).
          o_col2->set_medium_text( 'Status' ) ##NO_TEXT.
          o_col2->set_short_text( 'S' ) ##NO_TEXT.

          o_col2 = lref_table2->get_columns( )->get_column( 'INHERIT' ).
          o_col2->set_long_text( 'Attribut geerbt' ) ##NO_TEXT.
          o_col2->set_medium_text( 'geerbt' ) ##NO_TEXT.
          o_col2->set_short_text( 'geerbt' ) ##NO_TEXT.

          o_col2 = lref_table2->get_columns( )->get_column( 'NUMMER' ).
          o_col2->set_medium_text( 'Nummer' ) ##NO_TEXT.
          o_col2->set_short_text( 'Nr' ) ##NO_TEXT.

          o_col2 = lref_table2->get_columns( )->get_column( 'CONDITION' ).
          o_col2->set_medium_text( 'Condition' ) ##NO_TEXT.
          o_col2->set_short_text( 'Cond' ) ##NO_TEXT.

          o_col2 = lref_table2->get_columns( )->get_column( 'VORHANDEN' ).
          o_col2->set_medium_text( 'vorhanden' ) ##NO_TEXT.
          o_col2->set_short_text( 'v' ) ##NO_TEXT.

************************************************************************
*          Spalten ausblenden                                          *
************************************************************************


          TRY.
* Spalte über Namen suchen
              DATA(o_spalte) = CAST cl_salv_column_list( lref_table2->get_columns( )->get_column( 'ZFUNK_NO_EXIST' ) ).
* Spalte ausblenden
              o_spalte->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              o_spalte = CAST cl_salv_column_list( lref_table2->get_columns( )->get_column( 'DEFAULTVAL' ) ).
              o_spalte->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              o_spalte = CAST cl_salv_column_list( lref_table2->get_columns( )->get_column( 'INHERITED' ) ).
              o_spalte->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              o_spalte = CAST cl_salv_column_list( lref_table2->get_columns( )->get_column( 'INH_LEVEL' ) ).
              o_spalte->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              o_spalte = CAST cl_salv_column_list( lref_table2->get_columns( )->get_column( 'EXCLUDED' ) ).
              o_spalte->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.
************************************************************************
*         Überschrift, Spalten-Breite optimieren                       *
************************************************************************
          lref_table2->get_columns( )->set_optimize( abap_true ).
          lref_table2->get_columns( )->set_column_position( columnname = 'ATEXT' position = 5 ).

          display_settings2 = lref_table2->get_display_settings( ).
          display_settings2->set_list_header( 'Bestehende bzw. fehlende Attribute' ) ##NO_TEXT.
************************************************************************
*         Anzeigen                                                     *
************************************************************************
          lref_table2->display( ).
************************************************************************
*         Fehlermeldung, falls 'Anzeigen' nicht funktioniert           *
************************************************************************
        CATCH cx_salv_msg INTO  lref_message2.
          MESSAGE lref_message2 TYPE 'E'. ##NO_TEXT
      ENDTRY.
    ELSE.
      MESSAGE 'Selektierte Werte nicht gefunden.' TYPE 'E' ##NO_TEXT.
    ENDIF.
