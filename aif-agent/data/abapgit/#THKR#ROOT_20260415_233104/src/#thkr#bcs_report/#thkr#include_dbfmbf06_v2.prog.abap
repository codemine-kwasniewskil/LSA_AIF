*&---------------------------------------------------------------------*
*& Include          /THKR/INCLUDE_DBFMBF06_V2
*&---------------------------------------------------------------------*

* DS20210930
DATA: lv_p_per_fr  TYPE fm_periode.  " Periode von
DATA: lv_p_per_to  TYPE fm_periode.  " Periode bis


*&---------------------------------------------------------------------*
*&      Form  READ_TRANS_DATA
*&---------------------------------------------------------------------*
FORM read_trans_data
              TABLES g_t_fmto STRUCTURE g_t_fmto
                     g_t_fmoi STRUCTURE g_t_fmoi
                     g_t_fmfi STRUCTURE g_t_fmfi
                     g_t_fmco STRUCTURE g_t_fmco
                     g_t_conval STRUCTURE g_t_conval.

  FREE:  g_t_fmto,
         g_t_fmoi,
         g_t_fmfi,
         g_t_fmfi_parked,
         g_t_fmco,
         g_t_conval.
  CLEAR: g_t_fmto,
         g_t_fmoi,
         g_t_fmfi,
         g_t_fmfi_parked,
         g_t_fmco,
         g_t_conval.

*  "/ Check if trans data are selected
  CHECK NOT g_flg_fmto   IS INITIAL OR
        NOT g_flg_fmoi   IS INITIAL OR
        NOT g_flg_fmfi   IS INITIAL OR
        NOT g_flg_fmbkpf IS INITIAL OR
        NOT g_flg_fmco   IS INITIAL OR
        NOT g_flg_conval IS INITIAL.

*  "/ Text Bewegungsdaten werden eingelesen
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = TEXT-203
    EXCEPTIONS
      OTHERS = 1.

* Note 1238247
*  "/ Summensaetze
  IF NOT g_flg_conval IS INITIAL.
    PERFORM read_fmit   TABLES g_t_fmto
                        USING 'CONVAL'.
    g_t_conval[] = g_t_fmto[].
    CLEAR g_t_fmto.
    REFRESH g_t_fmto. " DS
  ENDIF.

  IF NOT g_flg_fmto IS INITIAL.
    PERFORM read_fmit   TABLES g_t_fmto
                        USING 'FMTOX'.
  ENDIF.

*  "/ Obligo und Mittelumbuchungen
  IF NOT g_flg_fmoi IS INITIAL.
    PERFORM read_fmioi TABLES g_t_fmoi.
  ENDIF.

*  "/ FI-Buchungen
  IF NOT g_flg_fmfi IS INITIAL.
    PERFORM read_fmifiit TABLES g_t_fmfi.
  ENDIF.
  IF NOT g_flg_fmbkpf IS INITIAL.
    PERFORM read_bkpf TABLES g_t_fmfi
                             g_t_fmfi_parked
                             g_t_fmbkpf.
  ENDIF.

*  "/ CO-Buchungen
  IF NOT g_flg_fmco IS INITIAL.
    PERFORM read_fmia TABLES g_t_fmco.
  ENDIF.

ENDFORM.                               " READ_TRANS_DATA

*&---------------------------------------------------------------------*
*&      Form  READ_FMIT
*&---------------------------------------------------------------------*
FORM read_fmit TABLES c_t_fmto      STRUCTURE g_t_fmto
               USING  u_f_struct    TYPE tabname.

  FIELD-SYMBOLS: <l_f_fmit>  TYPE fmit,
                 <l_f_fmtox> TYPE fmtox.

  DATA: l_f_fmto          LIKE g_t_fmto OCCURS 1 WITH HEADER LINE,
        l_t_fmit          LIKE fmit OCCURS 50,
        l_t_arch_fmit     TYPE STANDARD TABLE OF fmit,
        l_f_clauses       TYPE rsds_where,
        l_t_trange        TYPE rsds_range,
        l_sav_act_fkwaehr LIKE fmit-tsl01,
        l_sav_act_trwaehr LIKE fmit-tsl01,
        l_sav_perio7      LIKE ifmeisa-perio.
  DATA: l_f_per           LIKE fmtox-perio.

*  "/ Ranges fuer Gjahr und Perio aufbauen
  RANGES: l_r_gjahr  FOR fmtox-gjahr,
          l_r_perio7 FOR fmoix-perio7.

  PERFORM fill_time_ranges TABLES l_r_gjahr
                                  l_r_perio7
                            USING p_fyr_fr
                                  p_fyr_to
                                  p_per_fr
                                  p_per_to.

  IF p_usedb = 'X'.
*  "/ Auf Freie Abgrenzungen positionieren
    READ TABLE g_t_dyn_sel-clauses
          WITH KEY tablename = u_f_struct
          INTO l_f_clauses.

*  "/ Read with ranges
    PERFORM read_fmit_by_selopt TABLES l_t_fmit
                                       g_r_fictr
                                       g_r_fonds
                                       g_r_budper
                                       g_r_fipex
                                       g_r_farea
                                       g_r_measure
                                       g_r_grant
                                       l_r_gjahr
                                       l_f_clauses-where_tab
                                USING  fkrs-fikrs.
  ENDIF.

  IF p_usear = 'X'.
*  "/ Auf Freie Abgrenzungen positionieren
    READ TABLE g_t_dyn_sel-trange
          WITH KEY tablename = u_f_struct
          INTO l_t_trange.

    PERFORM read_fmit_from_archive TABLES l_t_arch_fmit
                                          g_r_fictr
                                          g_r_fonds
                                          g_r_budper
                                          g_r_fipex
                                          g_r_farea
                                          g_r_measure
                                          g_r_grant
                                          l_r_gjahr
                                          l_t_trange-frange_t
                                          so_files[]
                                   USING  fkrs-fikrs
                                          p_useas.

    APPEND LINES OF l_t_arch_fmit TO l_t_fmit.
    FREE l_t_arch_fmit.
  ENDIF.

* "/ Period dependend Totals
  IF p_pertot IS INITIAL.
    LOOP AT l_t_fmit ASSIGNING <l_f_fmit>.
*     "/ Uebernahme der periodenunabhaengigen Felder
      PERFORM move_fmit_to_fmto TABLES g_t_fmto
                                USING <l_f_fmit>.
*   "/ Alle Perioden durchlaufen
      DO VARYING l_sav_act_fkwaehr
            FROM <l_f_fmit>-hslvt NEXT <l_f_fmit>-hsl01
         VARYING l_sav_act_trwaehr
            FROM <l_f_fmit>-tslvt NEXT <l_f_fmit>-tsl01.
        IF l_sav_act_fkwaehr NE 0
        OR l_sav_act_trwaehr NE 0.
*         "/ Ermitteln Periode
          g_t_fmto-perio = <l_f_fmit>-rpmax - 17 + sy-index.
*         "/ CF_FLAG und Periode setzen
*          PERFORM SET_CF_FLAG_ACTUALS USING <L_F_FMIT>-RBTART
*                                   CHANGING G_T_FMTO-CF_FLAG
*                                            G_T_FMTO-PERIO.
*         "/ Nur angegebene Perioden selektieren
          l_sav_perio7(4)   = g_t_fmto-gjahr.
          l_sav_perio7+4(3) = g_t_fmto-perio.
          IF l_sav_perio7 IN l_r_perio7.
            PERFORM fill_amount_fmto
                         TABLES g_t_fmto
                          USING <l_f_fmit>-rldnr
                                l_sav_act_fkwaehr
                                l_sav_act_trwaehr.
            APPEND g_t_fmto.
          ENDIF.
        ENDIF.
        CHECK sy-index = 17.
*      "/ Verlassen der Schleife
        EXIT.
      ENDDO.
    ENDLOOP.

* "/ Fill further FMTOX fields
    LOOP AT g_t_fmto ASSIGNING <l_f_fmtox>.
      PERFORM fill_further_fmto_fields
                       CHANGING <l_f_fmtox>.
    ENDLOOP.
* "/ Period independend Totals
* "/ German local authorities
  ELSE.
    LOOP AT l_t_fmit ASSIGNING <l_f_fmit>.
*     "/ Uebernahme der periodenunabhaengigen Felder
      PERFORM move_fmit_to_fmto TABLES g_t_fmto
                                USING <l_f_fmit>.
*   "/ Alle Perioden durchlaufen
      DO VARYING l_sav_act_fkwaehr
            FROM <l_f_fmit>-hslvt NEXT <l_f_fmit>-hsl01
         VARYING l_sav_act_trwaehr
            FROM <l_f_fmit>-tslvt NEXT <l_f_fmit>-tsl01.
        IF l_sav_act_fkwaehr NE 0
        OR l_sav_act_trwaehr NE 0.
*            "/ set CF_FLAG
          l_f_per = <l_f_fmit>-rpmax - 17 + sy-index.
*         "/ CF_FLAG und Periode setzen
*          PERFORM SET_CF_FLAG_ACTUALS USING <L_F_FMIT>-RBTART
*                                   CHANGING G_T_FMTO-CF_FLAG
*                                            L_F_PER.
*         "/ Nur angegebene Perioden selektieren
          l_sav_perio7(4)   = g_t_fmto-gjahr.
          l_sav_perio7+4(3) = l_f_per.
          IF l_sav_perio7 IN l_r_perio7.
            CLEAR l_f_fmto.
            PERFORM fill_amount_fmto
                         TABLES l_f_fmto
                          USING <l_f_fmit>-rldnr
                                l_sav_act_fkwaehr
                                l_sav_act_trwaehr.
            g_t_fmto-fkbtrc = g_t_fmto-fkbtrc + l_f_fmto-fkbtrc.
            g_t_fmto-trbtrc = g_t_fmto-trbtrc + l_f_fmto-trbtrc.
            g_t_fmto-fkbtrw = g_t_fmto-fkbtrw + l_f_fmto-fkbtrw.
            g_t_fmto-trbtrw = g_t_fmto-trbtrw + l_f_fmto-trbtrw.
            g_t_fmto-fkbtrp = g_t_fmto-fkbtrp + l_f_fmto-fkbtrp.
            g_t_fmto-trbtrp = g_t_fmto-trbtrp + l_f_fmto-trbtrp.
          ENDIF.
        ENDIF.
        CHECK sy-index = 17.
*      "/ Verlassen der Schleife
        EXIT.
      ENDDO.
* "/ Ermitteln Periode
      g_t_fmto-perio = '000'.
      PERFORM fill_further_fmto_fields
                       CHANGING g_t_fmto.
      APPEND g_t_fmto.
    ENDLOOP.
  ENDIF.

*  "/ Sortieren fuer Zugriff via BINARY SEARCH
  CHECK NOT g_t_fmto[] IS INITIAL.
  SORT g_t_fmto BY
       gjahr grant_nbr measure farea fonds fictr fipex.
ENDFORM.                                                    " READ_FMIT

*&---------------------------------------------------------------------*
*&      Form  READ_FMIOI
*&---------------------------------------------------------------------*
FORM read_fmioi TABLES c_t_fmoi       STRUCTURE g_t_fmoi.

  FIELD-SYMBOLS: <l_f_fmioi> TYPE fmioi.

*  ranges: l_r_fipex for  fpos-fipex.
  DATA: l_t_fmioi         LIKE fmioi OCCURS 50,
        l_f_clauses       TYPE rsds_where,
        l_flg_skip_record.

*  "/ Felder fuer jahresuebergreifende Periodenabgrenzung
  DATA: l_sav_jahrper(7)      TYPE n,
        l_sav_jahrper_from(7) TYPE n,
        l_sav_jahrper_to(7)   TYPE n.
  l_sav_jahrper_from(4)   = p_fyr_fr.
  l_sav_jahrper_from+4(3) = p_per_fr.
  l_sav_jahrper_to(4)     = p_fyr_to.
  l_sav_jahrper_to+4(3)   = p_per_to.

  RANGES: l_r_perio  FOR fmoix-perio,
          l_r_perio7 FOR fmoix-perio7.

*  "/ Feldliste fuer FMIOI aufbereiten
  PERFORM field_list_actuals USING 'FMOIX'
                          CHANGING g_t_fields.

*  "/ Auf Freie Abgrenzungen positionieren
  READ TABLE g_t_dyn_sel-clauses
        WITH KEY tablename = 'FMOIX'
        INTO l_f_clauses.

* "/ Read with ranges
  PERFORM read_fmioi_by_selopt TABLES l_t_fmioi
                                      g_r_fictr
                                      g_r_fonds
                                      g_r_budper
                                      g_r_fipex
                                      g_r_farea
                                      g_r_measure
                                      g_r_grant
                                      l_f_clauses-where_tab
                               USING  fkrs-fikrs.

  LOOP AT l_t_fmioi ASSIGNING <l_f_fmioi>.
*     "/ jahresuebergreifende Periodenabgrenzung pruefen
    IF  NOT p_fyr_fr IS INITIAL
    AND NOT p_fyr_to IS INITIAL.
      l_sav_jahrper(4)   = <l_f_fmioi>-gjahr.
      IF <l_f_fmioi>-perio = '000'.
        l_sav_jahrper+4(3) = <l_f_fmioi>-perio.
        l_sav_jahrper+4(3) = '001'.
      ELSE.
        l_sav_jahrper+4(3) = <l_f_fmioi>-perio.
      ENDIF.
      CHECK l_sav_jahrper BETWEEN l_sav_jahrper_from
                              AND l_sav_jahrper_to.
    ENDIF.

*   "/ Abbausaetze mit Betrag Null nicht anzeigen
    IF <l_f_fmioi>-btart = fmfi_con_btart_reduction
    OR <l_f_fmioi>-btart = fmfi_con_btart_sucessr_adjust.
      CHECK <l_f_fmioi>-fkbtr NE 0
      OR    <l_f_fmioi>-trbtr NE 0.
    ENDIF.

*   "/ Uebernahme in die G_T_FMOI
    CLEAR g_t_fmoi.
    MOVE-CORRESPONDING <l_f_fmioi> TO g_t_fmoi.
    MOVE <l_f_fmioi>-fistl         TO g_t_fmoi-fictr.

*   "/ Clear of deactive dimensions
    PERFORM clear_deactive_dimensions
              CHANGING g_t_fmoi-fonds
                       g_t_fmoi-budget_pd
                       g_t_fmoi-farea
                       g_t_fmoi-measure
                       g_t_fmoi-grant_nbr.

*   "/ Check dynamic selection of perio and perio7
    PERFORM determine_dyn_sel_perio TABLES l_r_perio
                                           l_r_perio7
                                     USING 'FMOIX'.
*    PERFORM SET_CF_FLAG_ACTUALS USING G_T_FMOI-BTART
*                             CHANGING G_T_FMOI-CF_FLAG
*                                      G_T_FMOI-PERIO.
    g_t_fmoi-perio7(4)   = g_t_fmoi-gjahr.
    g_t_fmoi-perio7+4(3) = g_t_fmoi-perio.
    CHECK g_t_fmoi-perio7 IN l_r_perio7.
    CHECK g_t_fmoi-perio  IN l_r_perio.

*     "/ CO-Objekt aus OBJNRZ ermitteln
    PERFORM determine_co_object
                          USING <l_f_fmioi>-objnrz
                       CHANGING g_t_fmoi-kokrs
                                g_t_fmoi-kostl
                                g_t_fmoi-ktext
                                g_t_fmoi-aufnr
                                g_t_fmoi-atext
                                g_t_fmoi-posid
                                g_t_fmoi-post1
                                g_t_fmoi-prctr
                                g_t_fmoi-nplnr
                                g_t_fmoi-vornr.

*   "/ Profit center direct from table FMIOI
    IF NOT <l_f_fmioi>-prctr IS INITIAL.
      g_t_fmoi-prctr = <l_f_fmioi>-prctr.
    ENDIF.

*     "/ Freie Abgrenzung zu CO-Objekt pruefen
    PERFORM check_dynamic_selection_objnrz
                    USING 'FMOIX'
                          g_t_fmoi-kostl
                          g_t_fmoi-aufnr
                          g_t_fmoi-posid
                          g_t_fmoi-prctr
                 CHANGING l_flg_skip_record.
    CHECK l_flg_skip_record IS INITIAL.

*     "/ Abhaengige Felder fuellen
    g_t_fmoi-fwaer = fkrs-waers.
    PERFORM fill_amount_fmoi TABLES g_t_fmoi
                              USING <l_f_fmioi>.
    PERFORM text_get_from_domain USING 'FM_BTART'
                                       g_t_fmoi-btart
                              CHANGING g_t_fmoi-btext.
    PERFORM text_get_from_domain USING 'FM_STATS'
                                       g_t_fmoi-stats
                              CHANGING g_t_fmoi-statt.
    CALL FUNCTION 'FM_TEXT_GET_FROM_WRTTP'
      EXPORTING
        i_wrttp = g_t_fmoi-wrttp
      IMPORTING
        e_text  = g_t_fmoi-wtext.

*     "/ Text zum Profit-Center ermitteln
    IF NOT g_t_fmoi-prctr IS INITIAL.
      CALL FUNCTION 'KE_PROFIT_CENTER_KTEXT_GET'
        EXPORTING
          datum                   = sy-datlo
          prctr                   = g_t_fmoi-prctr
          kokrs                   = g_t_fmoi-kokrs
        IMPORTING
          ktext                   = g_t_fmoi-prctrt
        EXCEPTIONS
          not_found               = 1
          missing_coarea_or_ccode = 2
          OTHERS                  = 3.
    ENDIF.

*   "/ Fill further fields
    PERFORM fill_further_fmoi_fields CHANGING g_t_fmoi.

    COLLECT g_t_fmoi.
  ENDLOOP.

*  "/ Sortieren fuer Zugriff via BINARY SEARCH
  CHECK NOT g_t_fmoi[] IS INITIAL.
  SORT g_t_fmoi BY
       grant_nbr measure farea fonds fictr fipex refbn rfpos.

ENDFORM.                               " READ_FMIOI

*&---------------------------------------------------------------------*
*&      Form  READ_FMIFIIT
*&---------------------------------------------------------------------*
FORM read_fmifiit TABLES c_t_fmfi      STRUCTURE g_t_fmfi.

  FIELD-SYMBOLS: <l_f_fmifi> TYPE v_fmifi.

  DATA: l_t_fmifi             LIKE v_fmifi OCCURS 50,
        l_t_arch_fmifi        TYPE STANDARD TABLE OF v_fmifi,
        l_f_clauses           TYPE rsds_where,
        l_t_trange            TYPE rsds_range,
        l_f_segment           LIKE LINE OF dyn_sel-trange,
        l_flg_without_dyn_sel,
        l_flg_skip_record.

*  "/ Felder fuer jahresuebergreifende Periodenabgrenzung
  DATA: l_sav_jahrper(7)      TYPE n,
        l_sav_jahrper_from(7) TYPE n,
        l_sav_jahrper_to(7)   TYPE n.
  l_sav_jahrper_from(4)   = p_fyr_fr.
  l_sav_jahrper_from+4(3) = p_per_fr.
  l_sav_jahrper_to(4)     = p_fyr_to.
  l_sav_jahrper_to+4(3)   = p_per_to.

  RANGES: l_r_perio  FOR fmfix-perio,
          l_r_perio7 FOR fmfix-perio7.

  IF p_usedb = 'X'.
    PERFORM field_list_actuals USING 'FMFIX'
                               CHANGING g_t_fields.

*  "/ Auf Freie Abgrenzungen positionieren
    READ TABLE g_t_dyn_sel-clauses
          WITH KEY tablename = 'FMFIX'
          INTO l_f_clauses.

*  "/ If dynamic selection are too large
    DESCRIBE TABLE l_f_clauses-where_tab LINES sy-tfill.
    IF sy-tfill > 50.
      l_flg_without_dyn_sel = 'X'.
      READ TABLE g_t_dyn_sel-trange
            WITH KEY tablename = 'FMFIX'
            INTO l_f_segment.
*    "/ Select without dynamic selections
      FREE  l_f_clauses-where_tab.
    ENDIF.

* "/ Read with ranges
    PERFORM read_fmifiit_by_selopt TABLES l_t_fmifi
                                          g_r_fictr
                                          g_r_fonds
                                          g_r_budper
                                          g_r_fipex
                                          g_r_farea
                                          g_r_measure
                                          g_r_grant
                                          l_f_clauses-where_tab
                                   USING  fkrs-fikrs.
  ENDIF.

  IF p_usear = 'X'.
*  "/ Auf Freie Abgrenzungen positionieren
    READ TABLE g_t_dyn_sel-trange
          WITH KEY tablename = 'FMFIX'
          INTO l_t_trange.

    PERFORM read_fmifiit_from_archive TABLES l_t_arch_fmifi
                                             g_r_fictr
                                             g_r_fonds
                                             g_r_budper
                                             g_r_fipex
                                             g_r_farea
                                             g_r_measure
                                             g_r_grant
                                             l_t_trange-frange_t
                                             so_files[]
                                       USING fkrs-fikrs
                                             p_useas.

    APPEND LINES OF l_t_arch_fmifi TO l_t_fmifi.
    FREE l_t_arch_fmifi.
  ENDIF.

  LOOP AT l_t_fmifi ASSIGNING <l_f_fmifi>.
*     "/ If the select has been done without dynamic selection
    IF l_flg_without_dyn_sel = 'X' OR p_usedb = 'X'.
      PERFORM check_dynamic_selection_fmfix
         USING
            l_f_segment
           <l_f_fmifi>
         CHANGING
           l_flg_skip_record.
*       "/ Skip record
      CHECK l_flg_skip_record IS INITIAL.
    ENDIF.
*     "/ jahresuebergreifende Periodenabgrenzung pruefen
    IF  NOT p_fyr_fr IS INITIAL
    AND NOT p_fyr_to IS INITIAL.
      l_sav_jahrper(4)   = <l_f_fmifi>-gjahr.
      IF <l_f_fmifi>-perio = '000'.
        l_sav_jahrper+4(3) = '001'.
      ELSE.
        l_sav_jahrper+4(3) = <l_f_fmifi>-perio.
      ENDIF.
      CHECK l_sav_jahrper BETWEEN l_sav_jahrper_from
                              AND l_sav_jahrper_to.
    ENDIF.

    CHECK <l_f_fmifi>-fkbtr NE 0
    OR    <l_f_fmifi>-trbtr NE 0.

*     "/ Uebernahme in die G_T_FMFI
    CLEAR g_t_fmfi.
    MOVE-CORRESPONDING <l_f_fmifi> TO g_t_fmfi.
    MOVE <l_f_fmifi>-fistl         TO g_t_fmfi-fictr.

*   "/ Clear of deactive dimensions
    PERFORM clear_deactive_dimensions
              CHANGING g_t_fmfi-fonds
                       g_t_fmfi-budget_pd
                       g_t_fmfi-farea
                       g_t_fmfi-measure
                       g_t_fmfi-grant_nbr.

*   "/ Check dynamic selection of perio and perio7
    PERFORM determine_dyn_sel_perio TABLES l_r_perio
                                           l_r_perio7
                                     USING 'FMFIX'.
*    PERFORM SET_CF_FLAG_ACTUALS USING G_T_FMFI-BTART
*                             CHANGING G_T_FMFI-CF_FLAG
*                                      G_T_FMFI-PERIO.
    g_t_fmfi-perio7(4)   = g_t_fmfi-gjahr.
    g_t_fmfi-perio7+4(3) = g_t_fmfi-perio.
    CHECK g_t_fmfi-perio7 IN l_r_perio7.
    CHECK g_t_fmfi-perio  IN l_r_perio.

*     "/ CO-Objekt aus OBJNRZ ermitteln
    PERFORM determine_co_object USING <l_f_fmifi>-objnrz
                             CHANGING g_t_fmfi-kokrs
                                      g_t_fmfi-kostl
                                      g_t_fmfi-ktext
                                      g_t_fmfi-aufnr
                                      g_t_fmfi-atext
                                      g_t_fmfi-posid
                                      g_t_fmfi-post1
                                      g_t_fmfi-prctr
                                      g_t_fmfi-nplnr
                                      g_t_fmfi-vornr.

*   "/ Profit center direct from table FMIFIIT
    IF NOT <l_f_fmifi>-prctr IS INITIAL.
      g_t_fmfi-prctr = <l_f_fmifi>-prctr.
    ENDIF.

*     "/ Freie Abgrenzung zu CO-Objekt pruefen
    PERFORM check_dynamic_selection_objnrz
                    USING 'FMFIX'
                          g_t_fmfi-kostl
                          g_t_fmfi-aufnr
                          g_t_fmfi-posid
                          g_t_fmfi-prctr
                 CHANGING l_flg_skip_record.
    CHECK l_flg_skip_record IS INITIAL.

    CASE <l_f_fmifi>-rldnr.
      WHEN fmfi_con_ldnr_commitment.
        g_t_fmfi-fkbtrc = <l_f_fmifi>-fkbtr.
        g_t_fmfi-trbtrc = <l_f_fmifi>-trbtr.
        CLEAR: g_t_fmfi-fkbtrp, g_t_fmfi-trbtrp.
      WHEN fmfi_con_ldnr_payment.
        g_t_fmfi-fkbtrp = <l_f_fmifi>-fkbtr.
        g_t_fmfi-trbtrp = <l_f_fmifi>-trbtr.
        CLEAR: g_t_fmfi-fkbtrc, g_t_fmfi-trbtrc.
    ENDCASE.

    PERFORM text_get_from_domain USING 'FM_BTART'
                                       g_t_fmfi-btart
                              CHANGING g_t_fmfi-btext.
    PERFORM text_get_from_domain USING 'FM_STATS'
                                       g_t_fmfi-stats
                              CHANGING g_t_fmfi-statt.
    CALL FUNCTION 'FM_TEXT_GET_FROM_WRTTP'
      EXPORTING
        i_wrttp = g_t_fmfi-wrttp
      IMPORTING
        e_text  = g_t_fmfi-wtext.

*     "/ Text zum CO-Vorgang
    IF NOT g_t_fmfi-vrgng IS INITIAL.
      SELECT SINGLE * FROM tj01t
                     WHERE vrgng = g_t_fmfi-vrgng
                       AND spras = sy-langu.
      IF sy-subrc = 0.
        g_t_fmfi-vtext = tj01t-txt.
      ENDIF.
    ENDIF.

*     "/ Text zum Profit-Center ermitteln
    IF NOT g_t_fmfi-prctr IS INITIAL.
      CALL FUNCTION 'KE_PROFIT_CENTER_KTEXT_GET'
        EXPORTING
          datum                   = sy-datlo
          prctr                   = g_t_fmfi-prctr
          kokrs                   = g_t_fmfi-kokrs
        IMPORTING
          ktext                   = g_t_fmfi-prctrt
        EXCEPTIONS
          not_found               = 1
          missing_coarea_or_ccode = 2
          OTHERS                  = 3.
    ENDIF.

    g_t_fmfi-fwaer = fkrs-waers.
*   "/ Fill other fields
    PERFORM fill_further_fmfi_fields CHANGING g_t_fmfi.

*   "/ Parked documents into table G_T_FMFI_PARKED
*   "/ for documents headers
    IF g_t_fmfi-wrttp = '60' AND
       NOT g_flg_fmbkpf IS INITIAL.
      CLEAR g_t_fmfi_parked.
      MOVE g_t_fmfi TO g_t_fmfi_parked.
      COLLECT g_t_fmfi_parked.
    ELSE.
*     "/ Others documents
      COLLECT g_t_fmfi.
    ENDIF.
  ENDLOOP.

*  "/ Sortieren fuer Zugriff via BINARY SEARCH
  IF NOT g_t_fmfi[] IS INITIAL.
    SORT g_t_fmfi BY
       grant_nbr measure farea fonds budget_pd fictr fipex fmbelnr fmbuzei.
  ENDIF.
  IF NOT g_t_fmfi_parked[] IS INITIAL.
    SORT g_t_fmfi_parked BY
       grant_nbr measure farea fonds budget_pd fictr fipex fmbelnr fmbuzei.
  ENDIF.
ENDFORM.                               " READ_FMIFIIT

*&---------------------------------------------------------------------*
*&      Form  READ_FMIA
*&---------------------------------------------------------------------*
FORM read_fmia TABLES c_t_fmco      STRUCTURE g_t_fmco.

  FIELD-SYMBOLS: <l_f_fmia> TYPE fmia.

  DATA: l_t_fmia          LIKE fmia OCCURS 50,
        l_f_clauses       TYPE rsds_where,
        l_flg_skip_record.

*  "/ Felder fuer jahresuebergreifende Periodenabgrenzung
  DATA: l_sav_jahrper(7)      TYPE n,
        l_sav_jahrper_from(7) TYPE n,
        l_sav_jahrper_to(7)   TYPE n.
  l_sav_jahrper_from(4)   = p_fyr_fr.
  l_sav_jahrper_from+4(3) = p_per_fr.
  l_sav_jahrper_to(4)     = p_fyr_to.
  l_sav_jahrper_to+4(3)   = p_per_to.

  RANGES: l_r_perio  FOR fmcox-perio,
          l_r_perio7 FOR fmcox-perio7.

*  "/ CO-Buchungen einlesen
  PERFORM field_list_fmia.

*  "/ Auf Freie Abgrenzungen positionieren
  READ TABLE g_t_dyn_sel-clauses
        WITH KEY tablename = 'FMCOX'
        INTO l_f_clauses.

* "/ Read with ranges
  PERFORM read_fmia_by_selopt TABLES l_t_fmia
                                     g_r_fictr
                                     g_r_fonds
                                     g_r_budper
                                     g_r_fipex
                                     g_r_farea
                                     g_r_measure
                                     g_r_grant
                                     l_f_clauses-where_tab
                              USING  fkrs-fikrs.

  LOOP AT l_t_fmia ASSIGNING <l_f_fmia>.
*     "/ jahresuebergreifende Periodenabgrenzung pruefen
    IF  NOT p_fyr_fr IS INITIAL
    AND NOT p_fyr_to IS INITIAL.
      l_sav_jahrper(4)   = <l_f_fmia>-ryear.
      IF <l_f_fmia>-poper = '000'.
        l_sav_jahrper+4(3) = '001'.
      ELSE.
        l_sav_jahrper+4(3) = <l_f_fmia>-poper.
      ENDIF.
      CHECK l_sav_jahrper BETWEEN l_sav_jahrper_from
                              AND l_sav_jahrper_to.
    ENDIF.

    CHECK <l_f_fmia>-hsl NE 0
    OR    <l_f_fmia>-tsl NE 0.

*     "/ Uebernahme in die G_T_FMCO
    CLEAR g_t_fmco.
    MOVE-CORRESPONDING <l_f_fmia> TO g_t_fmco.
    g_t_fmco-fwaer    = fkrs-waers.
    g_t_fmco-fictr    = <l_f_fmia>-rfistl.
    g_t_fmco-fipex    = <l_f_fmia>-rfipex.

*   "/ Clear of deactive dimensions
    IF g_flg_fund_active = 'X'.
      g_t_fmco-fonds    = <l_f_fmia>-rfonds.
    ENDIF.
    IF g_flg_budper_active IS INITIAL.
      CLEAR g_t_fmco-budget_pd.
    ENDIF.
    IF g_flg_farea_active = 'X'.
      g_t_fmco-farea    = <l_f_fmia>-rfarea.
    ENDIF.
    IF g_flg_measure_active = 'X'.
      g_t_fmco-measure  = <l_f_fmia>-rmeasure.
    ENDIF.
    IF g_flg_grant_active IS INITIAL.
      CLEAR g_t_fmco-grant_nbr.
    ENDIF.

    g_t_fmco-gjahr   = <l_f_fmia>-ryear.
    g_t_fmco-gnjhr   = <l_f_fmia>-rgnjhr.
    g_t_fmco-perio   = <l_f_fmia>-poper.
    g_t_fmco-twaer   = <l_f_fmia>-rtcur.
    g_t_fmco-refbn   = <l_f_fmia>-refdocnr.
    g_t_fmco-rfpos   = <l_f_fmia>-refdocln.
    g_t_fmco-fmbelnr = <l_f_fmia>-docnr.
    g_t_fmco-fmbuzei = <l_f_fmia>-docln.
    g_t_fmco-bukrs   = <l_f_fmia>-rbukrs.
    g_t_fmco-wrttp   = <l_f_fmia>-rwrttp.
    g_t_fmco-btart   = <l_f_fmia>-rbtart.
    g_t_fmco-hkont   = <l_f_fmia>-rhkont.
    g_t_fmco-stats   = <l_f_fmia>-rstats.
    g_t_fmco-vrgng   = <l_f_fmia>-rvrgng.
    g_t_fmco-cflev   = <l_f_fmia>-rcflev.
    g_t_fmco-zhldt   = <l_f_fmia>-budat.
    g_t_fmco-userdim = <l_f_fmia>-ruserdim.
    IF NOT g_flg_paybud_for_co IS INITIAL.
      g_t_fmco-fkbtrp = <l_f_fmia>-hsl.
      g_t_fmco-trbtrp = <l_f_fmia>-tsl.
    ENDIF.
    IF NOT g_flg_combud_for_co IS INITIAL.
      g_t_fmco-fkbtrc = <l_f_fmia>-hsl.
      g_t_fmco-trbtrc = <l_f_fmia>-tsl.
    ENDIF.

*   "/ Check dynamic selection of perio and perio7
    PERFORM determine_dyn_sel_perio TABLES l_r_perio
                                           l_r_perio7
                                     USING 'FMCOX'.
    g_t_fmco-perio7(4)   = g_t_fmco-gjahr.
    g_t_fmco-perio7+4(3) = g_t_fmco-perio.
    CHECK g_t_fmco-perio7 IN l_r_perio7.
    CHECK g_t_fmco-perio  IN l_r_perio.

*     "/ CO-Objekt aus OBJNRZ ermitteln
    PERFORM determine_co_object USING <l_f_fmia>-robjnrz
                             CHANGING g_t_fmco-kokrs
                                      g_t_fmco-kostl
                                      g_t_fmco-ktext
                                      g_t_fmco-aufnr
                                      g_t_fmco-atext
                                      g_t_fmco-posid
                                      g_t_fmco-post1
                                      g_t_fmco-prctr
                                      g_t_fmco-nplnr
                                      g_t_fmco-vornr.

*     "/ Freie Abgrenzung zu CO-Objekt pruefen
    PERFORM check_dynamic_selection_objnrz
                    USING 'FMCOX'
                          g_t_fmco-kostl
                          g_t_fmco-aufnr
                          g_t_fmco-posid
                          g_t_fmco-prctr
                 CHANGING l_flg_skip_record.
    CHECK l_flg_skip_record IS INITIAL.

*     "/ Weitere abhaengige Felder ermitteln
    g_t_fmco-kokrs = <l_f_fmia>-kokrs.
    PERFORM text_get_from_domain USING 'FM_BTART'
                                       g_t_fmco-btart
                              CHANGING g_t_fmco-btext.
    PERFORM text_get_from_domain USING 'FM_STATS'
                                       g_t_fmco-stats
                              CHANGING g_t_fmco-statt.
    CALL FUNCTION 'FM_TEXT_GET_FROM_WRTTP'
      EXPORTING
        i_wrttp = g_t_fmco-wrttp
      IMPORTING
        e_text  = g_t_fmco-wtext.

    IF NOT g_t_fmco-vrgng IS INITIAL.
      SELECT SINGLE * FROM tj01t
                     WHERE vrgng = g_t_fmco-vrgng
                       AND spras = sy-langu.
      IF sy-subrc = 0.
        g_t_fmco-vtext = tj01t-txt.
      ENDIF.
    ENDIF.

*     "/ Text zum Profit-Center ermitteln
    IF NOT g_t_fmco-prctr IS INITIAL.
      CALL FUNCTION 'KE_PROFIT_CENTER_KTEXT_GET'
        EXPORTING
          datum                   = sy-datlo
          prctr                   = g_t_fmco-prctr
          kokrs                   = g_t_fmco-kokrs
        IMPORTING
          ktext                   = g_t_fmco-prctrt
        EXCEPTIONS
          not_found               = 1
          missing_coarea_or_ccode = 2
          OTHERS                  = 3.
    ENDIF.

*   "/ Fill further fileds
    PERFORM fill_further_fmco_fields CHANGING g_t_fmco.

    APPEND g_t_fmco.
  ENDLOOP.

*  "/ Sortieren fuer Zugriff via BINARY SEARCH
  CHECK NOT g_t_fmco[] IS INITIAL.
  SORT g_t_fmco BY
         grant_nbr measure farea fonds budget_pd fictr fipex refbn rfpos.
ENDFORM.                                                    " READ_FMIA

*&---------------------------------------------------------------------*
*&      Form  READ_FONDS_MASTER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_U_T_trippels  text
*      <--P_U_T_FMAA  text
*----------------------------------------------------------------------*
FORM read_fonds_master_data TABLES   u_r_fonds      STRUCTURE range_c10
                                     u_t_fmfincode  STRUCTURE fmfincode
                            USING    u_f_struct     TYPE tabname
                                     u_t_fundbpd    TYPE t_fundbpd.

  DATA: l_f_clauses        TYPE rsds_where,
        l_f_ranges         TYPE rsds_range,
        l_flg_large_ranges,
        l_r_fundbpd_sel    TYPE RANGE OF bp_geber,
        l_r_fundbpd_sel_c  TYPE RANGE OF bp_geber,
        l_s_fundbpd_sel    LIKE LINE OF l_r_fundbpd_sel.

  FIELD-SYMBOLS:
      <fundbpd>             TYPE s_fundbpd.

  CHECK u_t_fmfincode[] IS INITIAL.

*  "/ Feldliste anpassen
  PERFORM field_list_ffnd USING    u_f_struct.

  CHECK g_flg_ffnd = 'X'.

* If budget period is active and dynamic selection by FINUSE is made for an FMAA_xx;
* restrict Funds read to only that that participate in Fund/BP relations
* that meet the selection criteria for FMFUNDBPD-FINUSE:
  IF g_flg_fundbpd_sel = con_on AND u_f_struct <> 'FFND'.
    LOOP AT u_t_fundbpd ASSIGNING <fundbpd>.
      CLEAR l_s_fundbpd_sel.
      l_s_fundbpd_sel-sign = 'I'.
      l_s_fundbpd_sel-option = 'EQ'.
      l_s_fundbpd_sel-low = <fundbpd>-fincode.
      COLLECT l_s_fundbpd_sel INTO l_r_fundbpd_sel.
    ENDLOOP.
    PERFORM convert_ranges TABLES l_r_fundbpd_sel
                                  l_r_fundbpd_sel_c
                         CHANGING l_flg_large_ranges.
  ENDIF.

*  "/ Message: Fonds werden eingelesen
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = TEXT-200
    EXCEPTIONS
      OTHERS = 1.

*  "/ Free selections for FMAA
  PERFORM set_free_selection_fmaa USING    u_f_struct
                                          'FMFINCODE'
                                  CHANGING l_f_clauses
                                           l_f_ranges.
* "/ Delete large ranges
  PERFORM convert_ranges TABLES u_r_fonds
                                g_r_fonds_c
                       CHANGING l_flg_large_ranges.
*  "/ Fonds einlesen
  SELECT (g_t_fields-fields)                           "#EC CI_DYNWHERE
          FROM fmfincode
          INTO CORRESPONDING FIELDS OF TABLE u_t_fmfincode
         WHERE fikrs    =  fkrs-fikrs
           AND fincode  IN u_r_fonds
           AND fincode  IN l_r_fundbpd_sel
           AND (l_f_clauses-where_tab).

  IF NOT u_t_fmfincode[] IS INITIAL.
*   "/ Check all ranges
    IF NOT g_r_fonds_c[] IS INITIAL.
      DELETE u_t_fmfincode WHERE NOT fincode IN g_r_fonds_c.
    ENDIF.
    IF NOT l_r_fundbpd_sel_c[] IS INITIAL.
      DELETE u_t_fmfincode WHERE NOT fincode IN l_r_fundbpd_sel_c.
    ENDIF.
    SORT u_t_fmfincode BY fincode.
  ENDIF.

* "/ Restore large ranges
  PERFORM restore_range TABLES u_r_fonds
                               g_r_fonds_c.

ENDFORM.                               " READ_FONDS_MASTER_DATA
*&---------------------------------------------------------------------*
*&      Form  CHECK_NEEDED_TEXTS_FFND
*&---------------------------------------------------------------------*
FORM check_needed_texts_ffnd
               TABLES u_t_fields     STRUCTURE rsfs_struc
                      u_t_sav_fields STRUCTURE g_t_sav_fields
               USING  u_f_struct     TYPE      tabname
             CHANGING c_flg_fmfint   LIKE fmdy-xfeld
                      c_flg_fmfuset  LIKE fmdy-xfeld
                      c_flg_typet    LIKE fmdy-xfeld
                      c_flg_kna1     LIKE fmdy-xfeld
                      c_flg_substr_desc LIKE fmdy-xfeld.

* "/ No funds master data
  IF g_flg_fmaa_co IS INITIAL AND
     g_flg_fmaa_bo IS INITIAL AND
     g_flg_fmaa_po IS INITIAL AND
     g_flg_ffnd IS INITIAL.
*     G_FLG_FMAAREL IS INITIAL.
    CLEAR c_flg_fmfint.
    CLEAR c_flg_fmfuset.
    CLEAR c_flg_typet.
    CLEAR c_flg_kna1.
    CLEAR c_flg_substr_desc.
    EXIT.
  ENDIF.

*  "/ Alle Texte, falls keine eingeschraenkte Feldliste
  IF u_t_fields[] IS INITIAL.
    c_flg_fmfint  = 'X'.
    c_flg_fmfuset = 'X'.
    c_flg_typet   = 'X'.
    c_flg_kna1    = 'X'.
    c_flg_substr_desc = 'X'.
    EXIT.
  ENDIF.

*  "/ Fonds Texte
  LOOP AT u_t_sav_fields WHERE segmentname = u_f_struct
                           AND ( fieldname = 'FNAME' OR
                                 fieldname = 'FDSCR' ).
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    c_flg_fmfint = 'X'.
  ENDIF.

*  "/ Finanzierungszweck-Texte
  LOOP AT u_t_sav_fields WHERE segmentname = u_f_struct
                           AND ( fieldname = 'UNAME' OR
                                 fieldname = 'UDSCR' ).
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    c_flg_fmfuset = 'X'.
  ENDIF.

*  "/ Fondstyp-Texte
  LOOP AT u_t_sav_fields WHERE segmentname = u_f_struct
                           AND fieldname   = 'FUND_TYPET'.
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    c_flg_typet = 'X'.
  ENDIF.

*  "/ Debitoren-Texte
  LOOP AT u_t_sav_fields WHERE segmentname = u_f_struct
                           AND fieldname   = 'NAME1_FONDS'.
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    c_flg_kna1 = 'X'.
  ENDIF.

* "/ Substring description
  LOOP AT u_t_sav_fields WHERE segmentname = u_f_struct
                           AND ( fieldname = 'FDSUB1T_SH' OR
                                 fieldname = 'FDSUB1T_LO' OR
                                 fieldname = 'FDSUB2T_SH' OR
                                 fieldname = 'FDSUB2T_LO' ).
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    c_flg_substr_desc = 'X'.
  ENDIF.
ENDFORM.                               " CHECK_NEEDED_TEXTS_FFND
*&---------------------------------------------------------------------*
*&      Form  READ_FICTR_MASTER_DATA
*&---------------------------------------------------------------------*
FORM read_fictr_master_data TABLES   u_r_fictr  STRUCTURE range_c16
                                     u_t_fmfctr STRUCTURE fmfctr
                            USING    u_f_struct TYPE      tabname.

  DATA: l_f_clauses        TYPE rsds_where,
        l_f_ranges         TYPE rsds_range,
        l_flg_large_ranges.

  CHECK u_t_fmfctr[] IS INITIAL.

*  "/ Feldliste anpassen
  PERFORM field_list_fctr USING u_f_struct.

  CHECK g_flg_fctr = 'X'.

*  "/ Message: Finanzstellen werden eingelesen
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = TEXT-201
    EXCEPTIONS
      OTHERS = 1.

*  "/ Free selections for FMAA, FMAAREL, FMSNREL
  PERFORM set_free_selection_fmaa USING    u_f_struct
                                          'FMFCTR'
                                  CHANGING l_f_clauses
                                           l_f_ranges.

* "/ Delete large ranges
  PERFORM convert_ranges TABLES u_r_fictr
                                g_r_fictr_c
                       CHANGING l_flg_large_ranges.

* "/ Read fund center master data records from database
  PERFORM read_fund_center_db TABLES u_r_fictr
                              l_f_clauses-where_tab
                              u_t_fmfctr
                       USING  g_f_kdate_from
                              g_f_kdate_to.

  IF NOT u_t_fmfctr[] IS INITIAL.
*   "/ Check all ranges
    IF NOT g_r_fictr_c[] IS INITIAL.
      DELETE u_t_fmfctr WHERE NOT fictr IN g_r_fictr_c.
    ENDIF.
    SORT u_t_fmfctr BY fictr.
  ENDIF.

* "/ Restore large ranges
  PERFORM restore_range TABLES u_r_fictr
                               g_r_fictr_c.

ENDFORM.                               " READ_FICTR_MASTER_DATA

*&---------------------------------------------------------------------*
*&      Form  CHECK_NEEDED_TEXTS_FCTR
*&---------------------------------------------------------------------*
FORM check_needed_texts_fctr
               TABLES   u_t_fields     STRUCTURE rsfs_struc
                        u_t_sav_fields STRUCTURE g_t_sav_fields
               USING    u_f_struct     TYPE      tabname
               CHANGING c_flg_fmfctrt
                        c_flg_fmhisv
                        c_flg_substr_desc.

* "/ No fictr master data
  IF g_flg_fmaa_po IS INITIAL AND
     g_flg_fctr IS INITIAL.
*     G_FLG_FMAAREL IS INITIAL.
    CLEAR c_flg_fmfctrt.
    CLEAR c_flg_fmhisv.
    CLEAR c_flg_substr_desc.
    EXIT.
  ENDIF.

*  "/ Alle Texte, falls keine eingeschraenkte Feldliste
  IF u_t_fields[] IS INITIAL.
    c_flg_fmfctrt = 'X'.
    c_flg_fmhisv  = 'X'.
    c_flg_substr_desc = 'X'.
    EXIT.
  ENDIF.

*  "/ FICTR Texte
  LOOP AT u_t_sav_fields WHERE segmentname = u_f_struct
                           AND ( fieldname = 'CNAME' OR
                                 fieldname = 'CDSCR' ).
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    c_flg_fmfctrt = 'X'.
  ENDIF.

*  "/ FICTR Hierarchy
  LOOP AT u_t_sav_fields WHERE segmentname = u_f_struct
                           AND ( fieldname = 'CLEVL' OR
                                 fieldname = 'FICTR_UP' OR
                                 fieldname = 'HIVARNT' ).
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    c_flg_fmhisv = 'X'.
  ENDIF.

* "/ Substring description
  LOOP AT u_t_sav_fields WHERE segmentname = u_f_struct
                           AND ( fieldname = 'FCSUB1T_SH' OR
                                 fieldname = 'FCSUB1T_LO' OR
                                 fieldname = 'FCSUB2T_SH' OR
                                 fieldname = 'FCSUB2T_LO' OR
                                 fieldname = 'FCSUB3T_SH' OR
                                 fieldname = 'FCSUB3T_LO' ).
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    c_flg_substr_desc = 'X'.
  ENDIF.

ENDFORM.                               " CHECK_NEEDED_TEXTS_FCTR
*&---------------------------------------------------------------------*
*&      Form  READ_FIPEX_MASTER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_fipex_master_data TABLES   u_r_fipex STRUCTURE range_c24
                                     u_t_fmci STRUCTURE fmci
                            USING    u_f_struct     TYPE tabname.

  DATA: l_f_clauses        TYPE rsds_where,
        l_f_ranges         TYPE rsds_range,
        l_flg_large_ranges.

  CHECK u_t_fmci[] IS INITIAL.

*  "/ Feldliste anpassen
  PERFORM field_list_fpos USING u_f_struct.

  CHECK g_flg_fpos = 'X'.

*  "/ Message: Finanzpositionen werden eingelesen
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = TEXT-202
    EXCEPTIONS
      OTHERS = 1.

*  "/ Free selections for FMAA, FMAAREL, FMSNREL
  PERFORM set_free_selection_fmaa USING    u_f_struct
                                          'FMCI'
                                  CHANGING l_f_clauses
                                           l_f_ranges.

* "/ Delete large ranges
  PERFORM convert_ranges TABLES u_r_fipex
                                g_r_fipex_c
                       CHANGING l_flg_large_ranges.

* "/ Read commitemnt items from database
  PERFORM read_cmmt_item_db TABLES u_r_fipex
                                   g_r_gjahr_md
                                   l_f_clauses-where_tab
                                   u_t_fmci
                            USING  l_f_ranges.

  IF NOT u_t_fmci[] IS INITIAL.
*   "/ Check all ranges
    IF NOT g_r_fipex_c[] IS INITIAL.
      DELETE u_t_fmci WHERE NOT fipex IN g_r_fipex_c.
    ENDIF.
    SORT u_t_fmci BY fipex.
  ENDIF.

* "/ Restore large ranges
  PERFORM restore_range TABLES u_r_fipex
                               g_r_fipex_c.

ENDFORM.                               " READ_FIPEX_MASTER_DATA

*&---------------------------------------------------------------------*
*&      Form  CHECK_NEEDED_TEXTS_FIPEX
*&---------------------------------------------------------------------*
FORM check_needed_texts_fipex
                     TABLES u_t_fields     STRUCTURE rsfs_struc
                            u_t_sav_fields STRUCTURE g_t_sav_fields
                     USING  u_f_struct     TYPE      tabname
                   CHANGING c_flg_fmcit
                            c_flg_hier
                            c_flg_fmzubsp
                            c_flg_subsr_desc.

* "/ No fipex master data
  IF g_flg_fmaa_po IS INITIAL AND
     g_flg_fpos IS INITIAL.
*     G_FLG_FMAAREL IS INITIAL.
    CLEAR c_flg_fmcit.
    CLEAR c_flg_hier.
    CLEAR c_flg_fmzubsp.
    CLEAR c_flg_subsr_desc.
    EXIT.
  ENDIF.

*  "/ Alle Texte, falls keine eingeschraenkte Feldliste
  IF u_t_fields[] IS INITIAL.
    c_flg_fmcit   = 'X'.
    c_flg_hier    = 'X'.
    IF NOT g_flg_komm IS INITIAL.
      c_flg_fmzubsp = 'X'.
    ENDIF.
    EXIT.
  ENDIF.

*  "/ FIPEX Texte
  LOOP AT u_t_sav_fields WHERE segmentname = u_f_struct
                           AND ( fieldname = 'PNAME' OR
                                 fieldname = 'TEXT1' OR
                                 fieldname = 'TEXT2' OR
                                 fieldname = 'TEXT3' ).
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    c_flg_fmcit   = 'X'.
  ENDIF.

*  "/ FIPEX Hierarchy
  LOOP AT u_t_sav_fields WHERE segmentname = u_f_struct
                           AND ( fieldname = 'PLEVL' OR
                                 fieldname = 'FIPUP' OR
                                 fieldname = 'HIE_ID' ).
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    c_flg_hier = 'X'.
  ENDIF.

* "/ Substring description
  LOOP AT u_t_sav_fields WHERE segmentname = u_f_struct
                           AND ( fieldname = 'CISUB1T_SH' OR
                                 fieldname = 'CISUB1T_LO' OR
                                 fieldname = 'CISUB2T_SH' OR
                                 fieldname = 'CISUB2T_LO' OR
                                 fieldname = 'CISUB3T_SH' OR
                                 fieldname = 'CISUB3T_LO' ).
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    c_flg_subsr_desc = 'X'.
  ENDIF.

  CHECK NOT g_flg_komm IS INITIAL.
*  "/ FICTR Hierarchy
  LOOP AT u_t_sav_fields WHERE segmentname = u_f_struct
                           AND ( fieldname = 'EFICTR'  OR
                                 fieldname = 'EFIPEX1' OR
                                 fieldname = 'EFIPEX2' OR
                                 fieldname = 'EFIPEX3' OR
                                 fieldname = 'EFIPEX4' OR
                                 fieldname = 'EFIPEX5' ).
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    c_flg_fmzubsp = 'X'.
  ENDIF.

ENDFORM.                               " CHECK_NEEDED_TEXTS_FIPEX

*&---------------------------------------------------------------------*
*&      Form  READ_FONDS_TEXTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_R_FONDS  text
*      -->P_U_T_FMFINCODE  text
*      -->P_U_T_FMAA  text
*----------------------------------------------------------------------*
FORM read_fonds_texts TABLES   c_r_fonds      STRUCTURE range_c10
                               u_t_fmfincode  STRUCTURE fmfincode
                               u_t_ffnd       STRUCTURE ffnd
                      USING    u_f_struct     TYPE      tabname
                      CHANGING c_flg_fmfuset  TYPE      flag.

  FIELD-SYMBOLS: <u_f_fmfincode> TYPE fmfincode.

  DATA: l_t_fmfint  LIKE fmfint OCCURS 10 WITH HEADER LINE,
        l_t_fmfuset LIKE fmfuset OCCURS 10 WITH HEADER LINE,
        l_t_typet   LIKE fmfundtypet OCCURS 50 WITH HEADER LINE,
        l_t_kna1    LIKE kna1 OCCURS 10 WITH HEADER LINE.
  DATA: l_flg_fmfint,
        l_flg_typet,
        l_flg_kna1,
        l_flg_substr_desc,
        l_flg_selections.
  DATA: l_f_clauses TYPE rsds_where,
        l_f_ranges  TYPE rsds_range.

* if Fund=SPACE, add empty record to node's table
  IF g_flg_fund_active IS INITIAL
  OR g_flg_fund_space = 'X'.
    CLEAR u_t_ffnd.
    COLLECT u_t_ffnd.
  ENDIF.

  CHECK NOT u_t_fmfincode[] IS INITIAL.

*  "/ Ermitteln, ob Texte gebraucht werden
  CLEAR c_flg_fmfuset.
  PERFORM check_needed_texts_ffnd
                       TABLES   g_t_fields-fields
                                g_t_sav_fields
                       USING    u_f_struct
                       CHANGING l_flg_fmfint
                                c_flg_fmfuset
                                l_flg_typet
                                l_flg_kna1
                                l_flg_substr_desc.

*  "/ Message: Fondstexten werden eingelesen
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = TEXT-210
    EXCEPTIONS
      OTHERS = 1.

*  "/ Fonds-Texte einlesen
  IF l_flg_fmfint = 'X'.
    SELECT spras fikrs fincode bezeich  beschr FROM fmfint
           INTO CORRESPONDING FIELDS OF TABLE l_t_fmfint
              FOR ALL ENTRIES IN u_t_fmfincode
           WHERE spras   = sy-langu
             AND fikrs   = fkrs-fikrs
             AND fincode = u_t_fmfincode-fincode.
*            order by primary key.
  ENDIF.

*     "/ Text zum Finanzierungszweck lesen
  IF c_flg_fmfuset = 'X'.
    SELECT spras fikrs finuse bezeich  beschr FROM fmfuset
           INTO CORRESPONDING FIELDS OF TABLE l_t_fmfuset
              FOR ALL ENTRIES IN u_t_fmfincode
                      WHERE spras  = sy-langu
                        AND fikrs  = fkrs-fikrs
                        AND finuse = u_t_fmfincode-finuse.
  ENDIF.

* "/ Text zum Fondstyp lesen
  IF l_flg_typet = 'X'.
    SELECT fm_area fund_type fund_typet
             FROM fmfundtypet
             INTO CORRESPONDING FIELDS OF TABLE l_t_typet
             FOR ALL ENTRIES IN u_t_fmfincode
            WHERE fm_area   = fkrs-fikrs
              AND fund_type = u_t_fmfincode-type
              AND langu     = sy-langu.
  ENDIF.

*     "/ Text zum Debitor lesen
  IF l_flg_kna1 = 'X'.
    SELECT kunnr name1  FROM kna1
           INTO CORRESPONDING FIELDS OF TABLE l_t_kna1
              FOR ALL ENTRIES IN u_t_fmfincode
                      WHERE kunnr = u_t_fmfincode-sponsor.
  ENDIF.

*  "/ Free selections for FMFINCODE
  PERFORM set_free_selection_fmaa USING    u_f_struct
                                          'FMFINCODE'
                                  CHANGING l_f_clauses
                                           l_f_ranges.

  IF NOT c_r_fonds[] IS INITIAL OR
  NOT l_f_clauses-where_tab[] IS INITIAL.
*   Flag -> remember that nonempty sel.criteria existed
    l_flg_selections = 'X'.
  ENDIF.

* Init and recreate c_r_fonds again
  FREE c_r_fonds.

* Adjust ranges with Fund=SPACE (only if nonemtpy sel.criteria before,
* otherwise the range table must remain empty)
  IF g_flg_fund_space = 'X'
  AND NOT l_flg_selections IS INITIAL.
    set_range_equal c_r_fonds space.
  ENDIF.

  LOOP AT u_t_fmfincode ASSIGNING <u_f_fmfincode>.
    IF NOT l_flg_selections IS INITIAL.
*     Use this value as future selection criterium
      set_range_equal c_r_fonds <u_f_fmfincode>-fincode.
    ENDIF.

    CLEAR u_t_ffnd.
    MOVE-CORRESPONDING <u_f_fmfincode> TO u_t_ffnd.

*  "/ Fonds-Texte einlesen
    IF l_flg_fmfint = 'X'.
      READ TABLE l_t_fmfint
            WITH KEY spras   = sy-langu
                     fikrs   = fkrs-fikrs
                     fincode = <u_f_fmfincode>-fincode.
*           binary search.
      IF sy-subrc = 0.
        MOVE l_t_fmfint-bezeich TO u_t_ffnd-fname.
        MOVE l_t_fmfint-beschr  TO u_t_ffnd-fdscr.
      ENDIF.
    ENDIF.
*     "/ Text zum Finanzierungszweck lesen
    IF c_flg_fmfuset = 'X'.
      READ TABLE l_t_fmfuset
            WITH KEY fikrs  = fkrs-fikrs
                     finuse = <u_f_fmfincode>-finuse.
      IF sy-subrc = 0.
        MOVE l_t_fmfuset-bezeich TO u_t_ffnd-uname.
        MOVE l_t_fmfuset-beschr  TO u_t_ffnd-udscr.
      ENDIF.
    ENDIF.

*   "/ Text zum Fondstyp lesen
    IF l_flg_typet = 'X'.
      READ TABLE l_t_typet
            WITH KEY fm_area   = fkrs-fikrs
                     fund_type = <u_f_fmfincode>-type.
      IF sy-subrc = 0.
        MOVE l_t_typet-fund_typet TO u_t_ffnd-fund_typet.
      ENDIF.
    ENDIF.

*     "/ Text zum Debitor lesen
    IF l_flg_kna1 = 'X'.
      READ TABLE l_t_kna1
            WITH KEY kunnr = <u_f_fmfincode>-sponsor.
      IF sy-subrc = 0.
        MOVE l_t_kna1-name1 TO u_t_ffnd-name1.
      ENDIF.
    ENDIF.

*   "/ Substring description
    IF l_flg_substr_desc = 'X'.
      CALL FUNCTION 'FM_SUBSTRING_GET_DESCRIPTION'
        EXPORTING
          i_masdatid = '3'
          i_strid    = <u_f_fmfincode>-str_id
          i_sub1     = <u_f_fmfincode>-fdsub1
          i_sub2     = <u_f_fmfincode>-fdsub2
        IMPORTING
          e_desc1_sh = u_t_ffnd-fdsub1t_sh
          e_desc1_lo = u_t_ffnd-fdsub1t_lo
          e_desc2_sh = u_t_ffnd-fdsub2t_sh
          e_desc2_lo = u_t_ffnd-fdsub2t_lo.
    ENDIF.

    COLLECT u_t_ffnd.
  ENDLOOP.
ENDFORM.                               " READ_FONDS_TEXTS
*&---------------------------------------------------------------------*
*&      Form  READ_FICTR_TEXTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_R_FISTL  text
*      -->P_U_T_FMFCTR  text
*      -->P_U_T_FMAA  text
*----------------------------------------------------------------------*
FORM read_fictr_texts TABLES c_r_fictr  STRUCTURE range_c16
                             u_t_fmfctr STRUCTURE fmfctr
                             u_t_fctr   STRUCTURE fctr
                      USING  u_f_struct TYPE      tabname.

  FIELD-SYMBOLS: <u_f_fmfctr> TYPE fmfctr.

  DATA: l_t_fmfctrt   LIKE fmfctrt OCCURS 10 WITH HEADER LINE,
        l_t_fmhisv    LIKE fmhisv  OCCURS 10 WITH HEADER LINE,
        l_sav_hivarnt LIKE fm01h-hivarnt.

  DATA: l_flg_fmfctrt,
        l_flg_fmhisv,
        l_flg_substr_desc,
        l_flg_selections.

  DATA: l_f_clauses TYPE rsds_where,
        l_f_ranges  TYPE rsds_range.

  CHECK NOT u_t_fmfctr[] IS INITIAL.

*  "/ Ermitteln, ob Texte gebraucht werden
  PERFORM check_needed_texts_fctr TABLES   g_t_fields-fields
                                           g_t_sav_fields
                                  USING    u_f_struct
                                  CHANGING l_flg_fmfctrt
                                           l_flg_fmhisv
                                           l_flg_substr_desc.

*  "/ Message: Finanzstellentexten werden eingelesen
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = TEXT-211
    EXCEPTIONS
      OTHERS = 1.

  IF l_flg_fmfctrt = 'X'.
*     "/ Texttabelle lesen
    SELECT * FROM fmfctrt
             INTO CORRESPONDING FIELDS OF TABLE l_t_fmfctrt
              FOR ALL ENTRIES IN u_t_fmfctr
            WHERE spras  = sy-langu
              AND fikrs  = fkrs-fikrs
              AND fictr  = u_t_fmfctr-fictr
              AND datbis >= p_kdate
              AND datab  <= p_kdate.
    SORT l_t_fmfctrt BY spras fikrs fictr.
  ENDIF.
  IF l_flg_fmhisv = 'X'.
*   "/ Hierarchie-Variante ermitteln
    IF p_cvarnt IS INITIAL.
      SELECT SINGLE hivarnt FROM fm01h
                    INTO  l_sav_hivarnt
                    WHERE fikrs = fkrs-fikrs
                      AND gjahr = g_fipex_gjahr.
    ELSE.
      l_sav_hivarnt = p_cvarnt.
    ENDIF.

    IF    sy-subrc = 0.

*   "/ Uebergeordnete Finanzstelle einlesen
      SELECT fikrs fistl parent_st hivarnt hilevel
             INTO CORRESPONDING FIELDS
               OF TABLE l_t_fmhisv
             FROM fmhisv
              FOR ALL ENTRIES IN u_t_fmfctr
            WHERE fikrs   = fkrs-fikrs
              AND hivarnt = l_sav_hivarnt
              AND fistl   = u_t_fmfctr-fictr.
      SORT l_t_fmhisv BY fistl.
    ENDIF.
  ENDIF.

*  "/ Free selections for FMFCTR
  PERFORM set_free_selection_fmaa USING    u_f_struct
                                          'FMFCTR'
                                  CHANGING l_f_clauses
                                           l_f_ranges.

  IF NOT c_r_fictr[] IS INITIAL OR
  NOT l_f_clauses-where_tab[] IS INITIAL.
*   Flag -> remember that nonempty sel.criteria existed
    l_flg_selections = 'X'.
  ENDIF.

* Init and recreate c_r_fictr again
  FREE c_r_fictr.

  LOOP AT u_t_fmfctr ASSIGNING <u_f_fmfctr>.
    IF NOT l_flg_selections IS INITIAL.
*     Use this value as future selection criterium
      set_range_equal c_r_fictr <u_f_fmfctr>-fictr.
    ENDIF.

    CLEAR u_t_fctr.
    MOVE-CORRESPONDING <u_f_fmfctr> TO u_t_fctr.

    IF l_flg_fmfctrt = 'X'.
*     "/ Texte lesen
      READ TABLE l_t_fmfctrt
            WITH KEY spras   = sy-langu
                     fikrs   = fkrs-fikrs
                     fictr   = <u_f_fmfctr>-fictr
            BINARY SEARCH.
      IF sy-subrc = 0.
        MOVE l_t_fmfctrt-bezeich TO u_t_fctr-cname.
        MOVE l_t_fmfctrt-beschr  TO u_t_fctr-cdscr.
      ENDIF.
    ENDIF.
    IF l_flg_fmhisv = 'X'.
*   "/ Hierarchie-Variante ermitteln
      READ TABLE l_t_fmhisv
        WITH KEY fikrs   = fkrs-fikrs
                 hivarnt = l_sav_hivarnt
                 fistl   = <u_f_fmfctr>-fictr
          BINARY SEARCH.
      IF sy-subrc = 0.
        MOVE l_t_fmhisv-hilevel   TO u_t_fctr-clevl.
        MOVE l_t_fmhisv-hivarnt   TO u_t_fctr-hivarnt.
        MOVE l_t_fmhisv-parent_st TO u_t_fctr-fictr_up.
      ENDIF.
    ENDIF.
*   "/ Substring description
    IF l_flg_substr_desc = 'X'.
      CALL FUNCTION 'FM_SUBSTRING_GET_DESCRIPTION'
        EXPORTING
          i_masdatid = '2'
          i_strid    = <u_f_fmfctr>-str_id
          i_sub1     = <u_f_fmfctr>-fcsub1
          i_sub2     = <u_f_fmfctr>-fcsub2
          i_sub3     = <u_f_fmfctr>-fcsub3
        IMPORTING
          e_desc1_sh = u_t_fctr-fcsub1t_sh
          e_desc1_lo = u_t_fctr-fcsub1t_lo
          e_desc2_sh = u_t_fctr-fcsub2t_sh
          e_desc2_lo = u_t_fctr-fcsub2t_lo
          e_desc3_sh = u_t_fctr-fcsub3t_sh
          e_desc3_lo = u_t_fctr-fcsub3t_lo.
    ENDIF.

    APPEND u_t_fctr.
  ENDLOOP.
ENDFORM.                               " READ_FICTR_TEXTS
*&---------------------------------------------------------------------*
*&      Form  READ_FIPEX_TEXTS
*&---------------------------------------------------------------------*
FORM read_fipex_texts TABLES c_r_fipex STRUCTURE range_c24
                             u_t_fmci STRUCTURE fmci
                             u_t_fpos  STRUCTURE fpos
                      USING  u_f_struct     TYPE      tabname.

  FIELD-SYMBOLS: <u_f_fmci> TYPE fmci.

  DATA: l_t_fmcit    LIKE fmcit    OCCURS 10 WITH HEADER LINE,
        l_t_fmbu     LIKE fmbu     OCCURS 10 WITH HEADER LINE,
        l_t_fmzubsp  LIKE fmzubsp  OCCURS 10 WITH HEADER LINE,
        l_sav_sfictr LIKE fmzubsp-sfictr.
  DATA: l_flg_fmcit,
        l_flg_hier,
        l_flg_fmzubsp,
        l_flg_substr_desc,
        l_flg_selections.
  DATA: l_f_clauses TYPE rsds_where,
        l_f_ranges  TYPE rsds_range.

  CHECK NOT u_t_fmci[] IS INITIAL.

*  "/ Ermitteln, ob Texte gebraucht werden
  PERFORM check_needed_texts_fipex TABLES g_t_fields-fields
                                          g_t_sav_fields
                                   USING  u_f_struct
                                 CHANGING l_flg_fmcit
                                          l_flg_hier
                                          l_flg_fmzubsp
                                          l_flg_substr_desc.

*  "/ Message: Finanzpositionentexten werden eingelesen
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = TEXT-212
    EXCEPTIONS
      OTHERS = 1.

  IF l_flg_fmcit = 'X'.
*   "/ Texttabelle lesen
    SELECT * FROM fmcit
            INTO CORRESPONDING FIELDS OF TABLE l_t_fmcit
             FOR ALL ENTRIES IN u_t_fmci
           WHERE spras = sy-langu
             AND fikrs = fkrs-fikrs
             AND gjahr = g_fipex_gjahr
             AND fipex = u_t_fmci-fipex
             ORDER BY PRIMARY KEY.
  ENDIF.

  IF l_flg_hier = 'X'.
*   "/ Read hierarchy of commitment items
    PERFORM determine_fipex_hierarchy
               TABLES c_r_fipex
                      l_t_fmbu
                      g_t_fipex_index.
  ENDIF.

  IF l_flg_fmzubsp  =  'X'     AND
     NOT g_flg_komm IS INITIAL AND
     fkrs-no_hierarchy IS INITIAL.
*  "/ Haushaltsfinanzstelle ermitteln
    CALL FUNCTION 'FM_HH_FICTR_DETERMINE'
      EXPORTING
        ip_fikrs    = fkrs-fikrs
        ip_gjahr    = g_fipex_gjahr
      IMPORTING
        op_hh_fictr = l_sav_sfictr.

*  "/ Saldenfinanzstelle und Saldenfinanzpositionen ermitteln
    SELECT fikrs varnt gjahr sfipex sfictr sfonds
           efictr efipex1 efipex2 efipex3 efipex4 efipex5
             INTO CORRESPONDING FIELDS
               OF TABLE l_t_fmzubsp
             FROM fmzubsp
              FOR ALL ENTRIES IN u_t_fmci
            WHERE fikrs  = fkrs-fikrs
              AND varnt  = p_varnt
              AND gjahr  = g_fipex_gjahr
              AND sfipex = u_t_fmci-fipex
              AND sfictr = l_sav_sfictr
              AND sfonds = space.
    SORT l_t_fmzubsp BY fikrs varnt gjahr sfonds sfictr sfipex.
  ENDIF.

*  "/ Free selections for FMCI
  PERFORM set_free_selection_fmaa USING    u_f_struct
                                          'FMCI'
                                  CHANGING l_f_clauses
                                           l_f_ranges.

  IF NOT c_r_fipex[] IS INITIAL OR
  NOT l_f_clauses-where_tab[] IS INITIAL.
*   Flag -> remember that nonempty sel.criteria existed
    l_flg_selections = 'X'.
  ENDIF.

* Init and recreate c_r_fipex again
  FREE c_r_fipex.

  LOOP AT u_t_fmci ASSIGNING <u_f_fmci>.
    IF NOT l_flg_selections IS INITIAL.
*     Use this value as future selection criterium
      set_range_equal c_r_fipex <u_f_fmci>-fipex.
    ENDIF.

    CLEAR u_t_fpos.
    MOVE-CORRESPONDING <u_f_fmci> TO u_t_fpos.

    IF l_flg_fmcit = 'X'.
*     "/ Texte lesen
      READ TABLE l_t_fmcit
           WITH KEY spras = sy-langu
                    fikrs = fkrs-fikrs
                    gjahr = g_fipex_gjahr
                    fipex = <u_f_fmci>-fipex
           BINARY SEARCH.
      IF sy-subrc = 0.
        MOVE l_t_fmcit-bezei TO u_t_fpos-pname.
        MOVE l_t_fmcit-text1 TO u_t_fpos-text1.
        MOVE l_t_fmcit-text2 TO u_t_fpos-text2.
        MOVE l_t_fmcit-text3 TO u_t_fpos-text3.
      ENDIF.
    ENDIF.

    IF l_flg_hier = 'X'.
*     "/ Read hierarchy of commitment items
*     "/ PLEVL und HIE_ID
      READ TABLE l_t_fmbu WITH KEY fipex = <u_f_fmci>-fipex.
      IF sy-subrc = 0.
        u_t_fpos-plevl = l_t_fmbu-pos_level.
      ENDIF.
      READ TABLE g_t_fipex_index WITH KEY posit = <u_f_fmci>-posit.
      IF sy-subrc = 0.
        u_t_fpos-hie_id = g_t_fipex_index-hie_id.
      ENDIF.
    ENDIF.

*   "/ Substring description
    IF l_flg_substr_desc = 'X'.
      CALL FUNCTION 'FM_SUBSTRING_GET_DESCRIPTION'
        EXPORTING
          i_masdatid = '1'
          i_strid    = <u_f_fmci>-str_id
          i_sub1     = <u_f_fmci>-cisub1
          i_sub2     = <u_f_fmci>-cisub2
          i_sub3     = <u_f_fmci>-cisub3
          i_sub4     = <u_f_fmci>-cisub4
          i_sub5     = <u_f_fmci>-cisub5
        IMPORTING
          e_desc1_sh = u_t_fpos-cisub1t_sh
          e_desc1_lo = u_t_fpos-cisub1t_lo
          e_desc2_sh = u_t_fpos-cisub2t_sh
          e_desc2_lo = u_t_fpos-cisub2t_lo
          e_desc3_sh = u_t_fpos-cisub3t_sh
          e_desc3_lo = u_t_fpos-cisub3t_lo
          e_desc4_sh = u_t_fpos-cisub4t_sh
          e_desc4_lo = u_t_fpos-cisub4t_lo
          e_desc5_sh = u_t_fpos-cisub5t_sh
          e_desc5_lo = u_t_fpos-cisub5t_lo.
    ENDIF.

    IF l_flg_fmzubsp = 'X'.
*   "/ Saldenfinanzpositionen ermitteln
      READ TABLE l_t_fmzubsp
          WITH KEY fikrs  = fkrs-fikrs
                   varnt  = p_varnt
                   gjahr  = g_fipex_gjahr
                   sfonds = space
                   sfictr = l_sav_sfictr
                   sfipex = <u_f_fmci>-fipex
          BINARY SEARCH.
      IF sy-subrc = 0.
        MOVE l_t_fmzubsp-efictr  TO u_t_fpos-efictr.
        MOVE l_t_fmzubsp-efipex1 TO u_t_fpos-efipex1.
        MOVE l_t_fmzubsp-efipex2 TO u_t_fpos-efipex2.
        MOVE l_t_fmzubsp-efipex3 TO u_t_fpos-efipex3.
        MOVE l_t_fmzubsp-efipex4 TO u_t_fpos-efipex4.
        MOVE l_t_fmzubsp-efipex5 TO u_t_fpos-efipex5.
      ENDIF.
    ENDIF.

    APPEND u_t_fpos.
  ENDLOOP.

* "/ no fipos selected -> SPACE to ranges
  DESCRIBE TABLE u_t_fpos LINES sy-tfill.
  IF sy-tfill = 0.
    set_range_equal c_r_fipex space.
  ENDIF.

ENDFORM.                               " READ_FIPEX_TEXTS

*&---------------------------------------------------------------------*
*&      Form  DETERMINE_FIPEX_HIERARCHY
*&---------------------------------------------------------------------*
FORM determine_fipex_hierarchy
               TABLES u_r_fipex  STRUCTURE range_c24
                      c_t_fmbu   STRUCTURE fmbu
                      c_t_index  STRUCTURE g_t_fipex_index.

  FIELD-SYMBOLS: <l_f_fmbu> TYPE fmbu.

  DATA: l_sav_balbud,
        l_sav_hierarchy.

  IF NOT g_flg_komm IS INITIAL.
    IF fkrs-no_hierarchy IS INITIAL.
*     "/ Saldenfinanzpositionen auch noch einlesen
      l_sav_balbud = 'A'.
    ELSE.
*        "/ Hierarchie nicht einebnen
      l_sav_hierarchy = 'X'.
    ENDIF.
  ENDIF.

*  "/ Einstellungen zum Hierarchieaufbau
  CALL FUNCTION 'FM4C_READ_HIERARCHY_SET'
    EXPORTING
      i_range_sel          = 'X'
      i_range_with_subtree = p_fposdn
      i_carrier_hierarchy  = ' '
      i_balbud_carrier     = l_sav_balbud
      i_post_carrier       = ' '
      i_del_non_carrier    = ' '
      i_del_statistics     = ' '
      i_sort               = '1'
      i_use_centres        = ' '
      i_with_hierarchy     = l_sav_hierarchy.

*  "/ Finanzpositionen-Hierarchie aufbauen
  CALL FUNCTION 'FM4C_READ_HIERARCHY'
    EXPORTING
      i_fikrs = fkrs-fikrs
      i_varnt = p_varnt
      i_gjahr = g_fipex_gjahr
    TABLES
      t_fipex = u_r_fipex.

*  "/ Aufgebaute Tabellen importieren
  CALL FUNCTION 'FM4C_GET_INTERNAL_DATA'
    TABLES
      t_fmbu = c_t_fmbu.

*  "/ HIE-ID in Zwischentabelle uebernehmen
  FREE g_t_fipex_index.
  LOOP AT c_t_fmbu ASSIGNING <l_f_fmbu>
                       WHERE display = 'X'.
    c_t_index-posit  = <l_f_fmbu>-posit.
    c_t_index-hie_id = sy-tabix.
    APPEND c_t_index.
  ENDLOOP.

ENDFORM.                    " DETERMINE_FIPEX_HIERARCHY

*&---------------------------------------------------------------------*
*&      Form  READ_CMMT_ITEM_DB
*&---------------------------------------------------------------------*
*       Read commitment items from datatabse
*----------------------------------------------------------------------*
FORM read_cmmt_item_db TABLES u_r_fipex    STRUCTURE range_c24
                              u_r_gjahr_md STRUCTURE range_n4
                              u_where_tab  TYPE rsds_where_tab
                              c_t_fmci     STRUCTURE fmci
                       USING  u_f_segment  TYPE rsds_range.

  FIELD-SYMBOLS: <l_f_fmci> TYPE fmci.
  DATA: l_t_fmci LIKE fmci OCCURS 100.
  DATA: l_flg_without_dyn_sel,
        l_flg_skip_record.
  DATA: l_f_segment  TYPE  rsds_range,
        l_f_frange_t TYPE  rsds_frange_t.
  DATA: BEGIN OF l_t_fpos OCCURS 50,
          gjahr      LIKE fmci-gjahr,
          parent_fip LIKE fmhici-parent_fip.
          INCLUDE STRUCTURE fpos.
        DATA: END OF l_t_fpos.

*  "/ If dynamic selection are too large
  DESCRIBE TABLE u_where_tab LINES sy-tfill.
  IF sy-tfill > 100.
    l_flg_without_dyn_sel = 'X'.
*    read table G_T_DYN_SEL-TRANGE
*         with key TABLENAME = 'FMCI'
*         into L_F_SEGMENT.
    FREE  u_where_tab.
  ENDIF.

  IF p_varnt NE '000'.
*     "/ The alternative Variant of commitment items with JOIN
    SELECT (g_t_fields-fields)                         "#EC CI_DYNWHERE
          INTO CORRESPONDING FIELDS OF TABLE l_t_fpos
          FROM fmci INNER JOIN fmhici
            ON fmci~fipex = fmhici~fipex AND
               fmci~fikrs = fmhici~fikrs AND
               fmci~gjahr = fmhici~gjahr
         WHERE fmhici~fipex IN u_r_fipex
           AND fmhici~gjahr IN u_r_gjahr_md
           AND fmhici~fikrs =  fkrs-fikrs
           AND fmhici~varnt =  p_varnt
           AND (u_where_tab).
*     "/ Copy commitment items of year G_FIPEX_GJAHR
    LOOP AT l_t_fpos WHERE gjahr = g_fipex_gjahr.
      MOVE-CORRESPONDING l_t_fpos TO c_t_fmci.
      MOVE l_t_fpos-parent_fip    TO c_t_fmci-fipup.
*       "/ If the select has been done without dynamic selection
      IF l_flg_without_dyn_sel = 'X'.
        PERFORM check_dynamic_selection_fmci
           TABLES    u_f_segment-frange_t
           USING     c_t_fmci
           CHANGING  l_flg_skip_record.
*           "/ Skip record
        CHECK l_flg_skip_record IS INITIAL.
      ENDIF.
      APPEND c_t_fmci.
    ENDLOOP.
*     "/ Copy commitment items that are not valid in the year
*     "/ G_FIPEX_GJAHR
    LOOP AT l_t_fpos WHERE gjahr <> g_fipex_gjahr.
      READ TABLE c_t_fmci WITH KEY fikrs = fkrs-fikrs
                                   fipex = l_t_fpos-fipex.
      CHECK sy-subrc <> 0.
      MOVE-CORRESPONDING l_t_fpos TO c_t_fmci.
      MOVE l_t_fpos-parent_fip    TO c_t_fmci-fipup.
*       "/ If the select has been done without dynamic selection
      IF l_flg_without_dyn_sel = 'X'.
        PERFORM check_dynamic_selection_fmci
           TABLES    u_f_segment-frange_t
           USING     c_t_fmci
           CHANGING  l_flg_skip_record.
*         "/ Skip record
        CHECK l_flg_skip_record IS INITIAL.
      ENDIF.
      APPEND c_t_fmci.
    ENDLOOP.

  ELSE.
*     "/ Finanzpositionen zu den Deckungsringen einlesen
    SELECT (g_t_fields-fields) FROM fmci               "#EC CI_DYNWHERE
           INTO CORRESPONDING FIELDS OF TABLE l_t_fmci
          WHERE fikrs =  fkrs-fikrs
            AND fipex IN u_r_fipex
            AND gjahr IN u_r_gjahr_md
            AND stvar =  'X'
            AND (u_where_tab).

*     "/ Copy commitment items of year G_FIPEX_GJAHR
    LOOP AT l_t_fmci ASSIGNING <l_f_fmci>
        WHERE gjahr = g_fipex_gjahr.
*       "/ If the select has been done without dynamic selection
      IF l_flg_without_dyn_sel = 'X'.
        PERFORM check_dynamic_selection_fmci
           TABLES     u_f_segment-frange_t
           USING     <l_f_fmci>
           CHANGING  l_flg_skip_record.
*         "/ Skip record
        CHECK l_flg_skip_record IS INITIAL.
      ENDIF.
      APPEND  <l_f_fmci> TO c_t_fmci.
    ENDLOOP.
*     "/ Copy commitment items that are not valid in the year
*     "/ G_FIPEX_GJAHR
    LOOP AT l_t_fmci ASSIGNING <l_f_fmci>
        WHERE gjahr <> g_fipex_gjahr.
      READ TABLE c_t_fmci WITH KEY fikrs = fkrs-fikrs
                                   fipex = <l_f_fmci>-fipex.
      CHECK sy-subrc <> 0.
*       "/ If the select has been done without dynamic selection
      IF l_flg_without_dyn_sel = 'X'.
        PERFORM check_dynamic_selection_fmci
           TABLES     u_f_segment-frange_t
           USING     <l_f_fmci>
           CHANGING  l_flg_skip_record.
*         "/ Skip record
        CHECK l_flg_skip_record IS INITIAL.
      ENDIF.
      APPEND  <l_f_fmci> TO c_t_fmci.
    ENDLOOP.
  ENDIF.

ENDFORM.                               " READ_CMMT_ITEM_DB

*&---------------------------------------------------------------------*
*&      Form  READ_FUND_CENTER_DB
*&---------------------------------------------------------------------*
*       Read fund centers from datatabse
*----------------------------------------------------------------------*
FORM read_fund_center_db TABLES u_r_fictr    STRUCTURE range_c16
                                u_where_tab  TYPE rsds_where_tab
                                c_t_fmfctr   STRUCTURE fmfctr
                         USING  u_kdate_from LIKE p_kdate
                                u_kdate_to   LIKE p_kdate.

  FIELD-SYMBOLS: <l_f_fmfctr> TYPE fmfctr.
  DATA: l_t_fmfctr LIKE fmfctr OCCURS 100.

*        "/ Finanzstellen mit Selektionskriterien einlesen
  SELECT (g_t_fields-fields) FROM fmfctr               "#EC CI_DYNWHERE
           INTO CORRESPONDING FIELDS OF TABLE l_t_fmfctr
          WHERE fikrs  = fkrs-fikrs
            AND fictr  IN u_r_fictr
            AND datbis >= u_kdate_from
            AND datab  <= u_kdate_to
            AND (u_where_tab).

*     "/ Copy fund centers that are valid for the P_KDATE
  LOOP AT l_t_fmfctr ASSIGNING <l_f_fmfctr>
          WHERE datbis >= p_kdate
            AND datab  <= p_kdate.
    APPEND  <l_f_fmfctr> TO c_t_fmfctr.
  ENDLOOP.
*     "/ Copy fund centers that are not valid for the
*     "/ key date P_KDATE, but that are valid in the
*     "/ time ranges for transactional data
  LOOP AT l_t_fmfctr ASSIGNING <l_f_fmfctr>
          WHERE NOT datbis >= p_kdate
                 OR
                NOT datab  <= p_kdate.
    READ TABLE c_t_fmfctr WITH KEY fikrs = fkrs-fikrs
                                   fictr = <l_f_fmfctr>-fictr.
    CHECK sy-subrc <> 0.
    APPEND  <l_f_fmfctr> TO c_t_fmfctr.
  ENDLOOP.

ENDFORM.                               " READ_FUND_CENTER_DB

*&---------------------------------------------------------------------*
*&      Form  READ_FUNDED_PROGRAM_DB
*&---------------------------------------------------------------------*
*       Read funded program from datatabse
*----------------------------------------------------------------------*
FORM read_funded_program_db TABLES u_r_measure    STRUCTURE range_c24
                                   u_where_tab    TYPE rsds_where_tab
                                   c_t_fmas       STRUCTURE fmas
                         USING  u_kdate_from LIKE p_kdate
                                u_kdate_to   LIKE p_kdate.

  FIELD-SYMBOLS: <l_f_fmas> TYPE fmas.
  DATA: l_t_fmas LIKE fmas OCCURS 100.

*     "/ Read measure with sel-crit.
* n2278978 if Commitment Items are not Year-Dependent,
* all checks on MD would be performed on TODAY
* now real validity check is performed on transactional data
  SELECT measure valid_from valid_to authgrp FROM fmmeasure
         INTO CORRESPONDING FIELDS OF TABLE l_t_fmas
         WHERE  fmarea  =  fkrs-fikrs
          AND   measure IN u_r_measure
*          AND   VALID_TO   >= U_KDATE_FROM
*          AND   valid_from <= u_kdate_to
          AND (u_where_tab).

**     "/ Copy funded programs that are valid for the P_KDATE
*  LOOP AT L_T_FMAS ASSIGNING <L_F_FMAS>
*          WHERE VALID_TO    >= P_KDATE
*            AND VALID_FROM  <= P_KDATE.
*    APPEND  <L_F_FMAS> TO C_T_FMAS.
*  ENDLOOP.
**     "/ Copy funded programs that are not valid for the
**     "/ key date P_KDATE, but that are valid in the
**     "/ time ranges for transactional data
*  LOOP AT L_T_FMAS ASSIGNING <L_F_FMAS>
*          WHERE NOT VALID_TO    >= P_KDATE
*                 OR
*                NOT VALID_FROM  <= P_KDATE.
*    READ TABLE c_t_fmas WITH KEY measure = <l_f_fmas>-measure.
*    CHECK SY-SUBRC <> 0.
*    APPEND  <L_F_FMAS> TO C_T_FMAS.
*  ENDLOOP.

  c_t_fmas[] = l_t_fmas[].

ENDFORM.                               " READ_FUNDED_PROGRAM_DB

*&---------------------------------------------------------------------*
*&      Form  READ_GRANT_DB
*&---------------------------------------------------------------------*
*       Read grant from datatabse
*----------------------------------------------------------------------*
FORM read_grant_db TABLES u_r_grant    STRUCTURE range_c20
                          u_where_tab  TYPE rsds_where_tab
                          c_t_fgmg     STRUCTURE fgmg
                   USING  u_kdate_from LIKE      p_kdate
                          u_kdate_to   LIKE      p_kdate.

  FIELD-SYMBOLS: <l_f_fgmg> TYPE fgmg.
  DATA: l_t_fgmg LIKE fgmg OCCURS 100.
  DATA: l_f_init_date LIKE gmgr-valid_from.

*     "/ Read grant with sel-crit.
* n2278978 if Commitment Items are not Year-Dependent,
* all checks on MD would be performed on TODAY
* now real validity check is performed on transactional data
  SELECT (g_t_fields-fields)                          "#EC CI_SGLSELECT
         FROM gmgr
         INTO CORRESPONDING FIELDS OF TABLE l_t_fgmg
         WHERE  grant_nbr  IN u_r_grant
*          AND ( VALID_TO   >= U_KDATE_FROM OR
*                VALID_FROM = L_F_INIT_DATE )
*          AND ( VALID_FROM <= U_KDATE_TO   OR
*                valid_to   = l_f_init_date )
          AND (u_where_tab).

**     "/ Copy grants that are valid for the P_KDATE
*  LOOP AT L_T_FGMG ASSIGNING <L_F_FGMG>
*          WHERE VALID_TO    >= P_KDATE
*            AND VALID_FROM  <= P_KDATE.
*    APPEND  <L_F_FGMG> TO C_T_FGMG.
*  ENDLOOP.
**     "/ Copy grants that are not valid for the
**     "/ key date P_KDATE, but that are valid in the
**     "/ time ranges for transactional data
*  LOOP AT L_T_FGMG ASSIGNING <L_F_FGMG>
*          WHERE NOT VALID_TO    >= P_KDATE
*                 OR
*                NOT VALID_FROM  <= P_KDATE.
*    READ TABLE C_T_FGMG WITH KEY GRANT_NBR = <L_F_FGMG>-GRANT_NBR.
*    CHECK SY-SUBRC <> 0.
*    APPEND  <L_F_FGMG> TO C_T_FGMG.
*  ENDLOOP.

  c_t_fgmg[] = l_t_fgmg[].

ENDFORM.                               " READ_GRANT_DB

*&---------------------------------------------------------------------*
*&      Form  READ_FMAVCT_DATA
*&---------------------------------------------------------------------*
FORM read_fmavct_data TABLES   u_r_fonds   STRUCTURE range_c10
                               u_r_budper  STRUCTURE range_c10
                               u_r_fictr   STRUCTURE range_c16
                               u_r_fipex   STRUCTURE range_c24
                               u_r_farea   STRUCTURE range_c16
                               u_r_meas    STRUCTURE range_c24
                               u_r_grant   STRUCTURE range_c20
                               u_r_userdim STRUCTURE range_c10
                               c_t_avct    STRUCTURE g_t_avct
                     USING     u_versn.

  FIELD-SYMBOLS: <l_f_fmavct> TYPE fmavct,
                 <l_f_avct>   TYPE avct.
  RANGES: l_r_gjahr      FOR  avct-ryear,
          l_r_perio7     FOR  avct-perio7.
  DATA: l_t_fmavct    LIKE fmavct OCCURS 100,
        l_f_clauses   TYPE rsds_where,
        l_sav_perio7  LIKE avct-perio7,
        l_sav_tamount LIKE avct-tamount,
        l_sav_hamount LIKE avct-hamount,
        l_sav_kamount LIKE avct-kamount.


*--------------------------------------------------------------------*
* DS20210930 - Ersetzung des dyn. Aufrufs der Perioden durch Festwerte
*              wie im alten Haushaltsbericht
*--------------------------------------------------------------------*
  lv_p_per_fr = '000'.
  lv_p_per_to = '999'.

  PERFORM fill_time_ranges TABLES l_r_gjahr          " DS20210930
                                  l_r_perio7
                            USING p_fyr_fr
                                  p_fyr_to

                                  lv_p_per_fr
                                  lv_p_per_to.

***  PERFORM fill_time_ranges TABLES l_r_gjahr
***                                  l_r_perio7
***                            USING p_fyr_fr
***                                  p_fyr_to
***                                  p_per_fr
***                                  p_per_to.
*--------------------------------------------------------------------*


* "/ Auf Freie Abgrenzungen positionieren
  READ TABLE g_t_dyn_sel-clauses
        WITH KEY tablename = 'AVCT'
        INTO l_f_clauses.

* "/ Read with ranges
  PERFORM read_fmavct_by_selopt TABLES l_t_fmavct
                                       u_r_fictr
                                       u_r_fonds
                                       u_r_budper
                                       u_r_fipex
                                       u_r_farea
                                       u_r_meas
                                       u_r_grant
                                       u_r_userdim
                                       l_r_gjahr
                                       l_f_clauses-where_tab
                                USING  fkrs-fikrs
                                       u_versn.

  LOOP AT l_t_fmavct ASSIGNING <l_f_fmavct>.
*   "/ Take over general fields
*    PERFORM MOVE_FMAVCT_TO_AVCT TABLES C_T_AVCT
*                                USING <L_F_FMAVCT>.

    CLEAR c_t_avct.                                       " DS20210512
    MOVE-CORRESPONDING <l_f_fmavct> TO c_t_avct.          " DS20210512

* "/ Calculation over all periods
    WHILE sy-index <= 17
       VARY l_sav_tamount
          FROM <l_f_fmavct>-tslvt NEXT <l_f_fmavct>-tsl01
       VARY l_sav_hamount
          FROM <l_f_fmavct>-hslvt NEXT <l_f_fmavct>-hsl01
       VARY l_sav_kamount
          FROM <l_f_fmavct>-kslvt NEXT <l_f_fmavct>-ksl01.
      IF l_sav_tamount NE 0
      OR l_sav_hamount NE 0
      OR l_sav_kamount NE 0.
*       "/ Determine period
        c_t_avct-perio = <l_f_fmavct>-rpmax - 17 + sy-index.
*       "/ Only selected periods
        l_sav_perio7(4)   = <l_f_fmavct>-ryear.
        l_sav_perio7+4(3) = c_t_avct-perio.
        IF l_sav_perio7 IN l_r_perio7.
          c_t_avct-perio7  = l_sav_perio7.
          c_t_avct-tamount = l_sav_tamount.
          c_t_avct-hamount = l_sav_hamount.
          c_t_avct-kamount = l_sav_kamount.

          c_t_avct-fwaer = fkrs-waers.
          c_t_avct-twaer = <l_f_fmavct>-rtcur.
*          c_t_avct-kwaer =

          APPEND c_t_avct.
        ENDIF.
      ENDIF.
    ENDWHILE.
  ENDLOOP.

* "/ Fill further AVCT fields
  LOOP AT c_t_avct ASSIGNING <l_f_avct>.
*    PERFORM FILL_FURTHER_AVCT_FIELDS
*                     CHANGING <L_F_AVCT>.
  ENDLOOP.

*  "/ Sortieren fuer Zugriff via BINARY SEARCH
  CHECK NOT c_t_avct[] IS INITIAL.

  SORT c_t_avct BY
       rgrant_nbr rmeasure rfuncarea rfund budget_pd_9 rfundsctr rcmmtitem.

ENDFORM.                               " READ_FMAVCT_DATA


*&---------------------------------------------------------------------*
*&      Form  READ_FMBDT_DATA
*&---------------------------------------------------------------------*
FORM read_fmbdt_data TABLES    u_r_fonds   STRUCTURE range_c10
                               u_r_budper  STRUCTURE range_c10
                               u_r_fictr   STRUCTURE range_c16
                               u_r_fipex   STRUCTURE range_c24
                               u_r_farea   STRUCTURE range_c16
                               u_r_meas    STRUCTURE range_c24
                               u_r_grant   STRUCTURE range_c20
                               u_r_userdim STRUCTURE range_c10
                               c_t_budt    STRUCTURE g_t_budt
                     USING     u_versn.

  FIELD-SYMBOLS: <l_f_fmbdt> TYPE fmbdt,
                 <l_f_budt>  TYPE budt.
  RANGES: l_r_gjahr      FOR  budt-ryear,
          l_r_perio7     FOR  budt-perio7.
  DATA: l_t_fmbdt     LIKE fmbdt OCCURS 100,
        l_f_clauses   TYPE rsds_where,
        l_sav_perio7  LIKE budt-perio7,
        l_sav_tamount LIKE budt-tamount,
        l_sav_hamount LIKE budt-hamount,
        l_sav_kamount LIKE budt-kamount.
  DATA: l_f_processt  TYPE  buprocesst,
        l_budtype_txt TYPE  text20.



*--------------------------------------------------------------------*
* DS20210930 - Ersetzung des dyn. Aufrufs der Perioden durch Festwerte
*              wie im alten Haushaltsbericht
*--------------------------------------------------------------------*
  lv_p_per_fr = '000'.
  lv_p_per_to = '999'.

  PERFORM fill_time_ranges TABLES l_r_gjahr        " DS20210930
                                  l_r_perio7
                            USING p_fyr_fr
                                  p_fyr_to

                                  lv_p_per_fr
                                  lv_p_per_to.

***  PERFORM fill_time_ranges TABLES l_r_gjahr
***                                  l_r_perio7
***                            USING p_fyr_fr
***                                  p_fyr_to
***                                  p_per_fr
***                                  p_per_to.
*--------------------------------------------------------------------*


* "/ Auf Freie Abgrenzungen positionieren
  READ TABLE g_t_dyn_sel-clauses
        WITH KEY tablename = 'BUDT'
        INTO l_f_clauses.

* "/ Read with ranges
  PERFORM read_fmbdt_by_selopt TABLES  l_t_fmbdt
                                       u_r_fictr
                                       u_r_fonds
                                       u_r_budper
                                       u_r_fipex
                                       u_r_farea
                                       u_r_meas
                                       u_r_grant
                                       u_r_userdim
                                       l_r_gjahr
                                       l_f_clauses-where_tab
                                USING  fkrs-fikrs
                                       u_versn.

  LOOP AT l_t_fmbdt ASSIGNING <l_f_fmbdt>.
*   "/ Take over general fields
*    PERFORM MOVE_FMBDT_TO_BUDT TABLES C_T_BUDT
*                                USING <L_F_FMBDT>.
    CLEAR c_t_budt.
    MOVE-CORRESPONDING <l_f_fmbdt> TO c_t_budt.

*   Read texts
    PERFORM text_get_from_domain USING 'BUKU_WFSTATE'
                                        c_t_budt-wfstate_9
                               CHANGING c_t_budt-wfstate_txt.

    CALL FUNCTION 'BUKU_CHECK_VALTYPE'
      EXPORTING
        i_valtype      = c_t_budt-valtype_9
        i_flg_text     = 'X'
      IMPORTING
        e_valtype_text = c_t_budt-valtype_txt
      EXCEPTIONS
        not_found      = 1
        OTHERS         = 2.

    CALL FUNCTION 'BUKU_CHECK_PROCESS'
      EXPORTING
        i_process    = c_t_budt-process_9
        i_flg_text   = 'X'
      IMPORTING
        e_f_processt = l_f_processt
      EXCEPTIONS
        not_found    = 1
        OTHERS       = 2.

    IF sy-subrc = 0.
      c_t_budt-process_txt = l_f_processt-text15.
    ENDIF.

    CALL FUNCTION 'FMCU_CHECK_BUDTYPE'
      EXPORTING
        i_fm_area       = c_t_budt-rfikrs
        i_valtype       = c_t_budt-valtype_9
        i_budtype       = c_t_budt-budtype_9
      IMPORTING
        e_budtype_txt20 = l_budtype_txt
      EXCEPTIONS
        OTHERS          = 2.

    IF sy-subrc = 0.
      c_t_budt-budtype_txt = l_budtype_txt.
    ENDIF.

* "/ Calculation over all periods
    WHILE sy-index <= 17
       VARY l_sav_tamount
          FROM <l_f_fmbdt>-tslvt NEXT <l_f_fmbdt>-tsl01
       VARY l_sav_hamount
          FROM <l_f_fmbdt>-hslvt NEXT <l_f_fmbdt>-hsl01
       VARY l_sav_kamount
          FROM <l_f_fmbdt>-kslvt NEXT <l_f_fmbdt>-ksl01.
      IF l_sav_tamount NE 0
      OR l_sav_hamount NE 0
      OR l_sav_kamount NE 0.
*       "/ Determine period
        c_t_budt-perio = <l_f_fmbdt>-rpmax - 17 + sy-index.
*       "/ Only selected periods
        l_sav_perio7(4)   = <l_f_fmbdt>-ryear.
        l_sav_perio7+4(3) = c_t_budt-perio.
        IF l_sav_perio7 IN l_r_perio7.
          c_t_budt-perio7  = l_sav_perio7.
          c_t_budt-tamount = l_sav_tamount * -1.
          c_t_budt-hamount = l_sav_hamount * -1.
          c_t_budt-kamount = l_sav_kamount * -1.

          c_t_budt-fwaer = fkrs-waers.
          c_t_budt-twaer = <l_f_fmbdt>-rtcur.
*         C_T_BUDT-KWAER =

          APPEND c_t_budt.

        ENDIF.
      ENDIF.
    ENDWHILE.

    PERFORM collect_bobjects
      USING <l_f_fmbdt>-rgrant_nbr
            <l_f_fmbdt>-rfund
            <l_f_fmbdt>-budget_pd_9
            <l_f_fmbdt>-rfundsctr
            <l_f_fmbdt>-rcmmtitem
            <l_f_fmbdt>-rfuncarea
            <l_f_fmbdt>-rmeasure.

  ENDLOOP.

* "/ Fill further BUDT fields
*  LOOP AT C_T_BUDT ASSIGNING <L_F_BUDT>.
*    PERFORM FILL_FURTHER_BUDT_FIELDS
*                     CHANGING <L_F_BUDT>.
*  ENDLOOP.

*  "/ Sortieren fuer Zugriff via BINARY SEARCH
  CHECK NOT c_t_budt[] IS INITIAL.

  SORT c_t_budt BY
       rgrant_nbr rmeasure rfuncarea rfund budget_pd_9 rfundsctr rcmmtitem.

ENDFORM.                               " READ_FMBUDT_DATA

*&---------------------------------------------------------------------*
*&      Form  READ_FMBDP_DATA
*&---------------------------------------------------------------------*
FORM read_fmbdp_data TABLES    u_r_fonds   STRUCTURE range_c10
                               u_r_budper  STRUCTURE range_c10
                               u_r_fictr   STRUCTURE range_c16
                               u_r_fipex   STRUCTURE range_c24
                               u_r_farea   STRUCTURE range_c16
                               u_r_meas    STRUCTURE range_c24
                               u_r_grant   STRUCTURE range_c20
                               u_r_userdim STRUCTURE range_c10
                               c_t_budp    STRUCTURE g_t_budp
                     USING     u_versn.

  FIELD-SYMBOLS: <l_f_fmbdp> TYPE fmbdp,
                 <l_f_budp>  TYPE budp.
  RANGES: l_r_gjahr      FOR  budp-ryear,
          l_r_perio7     FOR  budp-perio7.
  DATA: l_t_fmbdp     LIKE fmbdp OCCURS 100,
        l_f_clauses   TYPE rsds_where,
        l_sav_perio7  LIKE budp-perio7,
        l_sav_tamount LIKE budp-tamount,
        l_sav_hamount LIKE budp-hamount,
        l_sav_kamount LIKE budp-kamount.
  DATA: l_f_processt  TYPE  buprocesst,
        l_budtype_txt TYPE  text20.


*--------------------------------------------------------------------*
* DS20210930 - Ersetzung des dyn. Aufrufs der Perioden durch Festwerte
*              wie im alten Haushaltsbericht
*--------------------------------------------------------------------*
  lv_p_per_fr = '000'.
  lv_p_per_to = '999'.

  PERFORM fill_time_ranges TABLES l_r_gjahr          " DS20210930
                                  l_r_perio7
                            USING p_fyr_fr
                                  p_fyr_to

                                  lv_p_per_fr
                                  lv_p_per_to.

***  PERFORM fill_time_ranges TABLES l_r_gjahr
***                                  l_r_perio7
***                            USING p_fyr_fr
***                                  p_fyr_to
***                                  p_per_fr
***                                  p_per_to.
*--------------------------------------------------------------------*


* "/ Auf Freie Abgrenzungen positionieren
  READ TABLE g_t_dyn_sel-clauses
        WITH KEY tablename = 'BUDP'
        INTO l_f_clauses.

* "/ Read with ranges
  PERFORM read_fmbdp_by_selopt TABLES  l_t_fmbdp
                                       u_r_fictr
                                       u_r_fonds
                                       u_r_budper
                                       u_r_fipex
                                       u_r_farea
                                       u_r_meas
                                       u_r_grant
                                       u_r_userdim
                                       l_r_gjahr
                                       l_f_clauses-where_tab
                                USING  fkrs-fikrs
                                       u_versn.

  LOOP AT l_t_fmbdp ASSIGNING <l_f_fmbdp>.
*   "/ Take over general fields
*    PERFORM MOVE_FMBDP_TO_BUDP TABLES C_T_BUDP
*                                USING <L_F_FMBDP>.
    CLEAR c_t_budp.
    MOVE-CORRESPONDING <l_f_fmbdp> TO c_t_budp.

*   Read texts
    PERFORM text_get_from_domain USING 'BUKU_WFSTATE'
                                        c_t_budp-wfstate_9
                               CHANGING c_t_budp-wfstate_txt.

    CALL FUNCTION 'BUKU_CHECK_VALTYPE'
      EXPORTING
        i_valtype      = c_t_budp-valtype_9
        i_flg_text     = 'X'
      IMPORTING
        e_valtype_text = c_t_budp-valtype_txt
      EXCEPTIONS
        not_found      = 1
        OTHERS         = 2.

    CALL FUNCTION 'BUKU_CHECK_PROCESS'
      EXPORTING
        i_process    = c_t_budp-process_9
        i_flg_text   = 'X'
      IMPORTING
        e_f_processt = l_f_processt
      EXCEPTIONS
        not_found    = 1
        OTHERS       = 2.

    IF sy-subrc = 0.
      c_t_budp-process_txt = l_f_processt-text15.
    ENDIF.

    CALL FUNCTION 'FMCU_CHECK_BUDTYPE'
      EXPORTING
        i_fm_area       = c_t_budp-rfikrs
        i_valtype       = c_t_budp-valtype_9
        i_budtype       = c_t_budp-budtype_9
      IMPORTING
        e_budtype_txt20 = l_budtype_txt
      EXCEPTIONS
        OTHERS          = 2.

    IF sy-subrc = 0.
      c_t_budp-budtype_txt = l_budtype_txt.
    ENDIF.

* "/ Calculation over all periods
    WHILE sy-index <= 17
       VARY l_sav_tamount
          FROM <l_f_fmbdp>-tslvt NEXT <l_f_fmbdp>-tsl01
       VARY l_sav_hamount
          FROM <l_f_fmbdp>-hslvt NEXT <l_f_fmbdp>-hsl01
       VARY l_sav_kamount
          FROM <l_f_fmbdp>-kslvt NEXT <l_f_fmbdp>-ksl01.
      IF l_sav_tamount NE 0
      OR l_sav_hamount NE 0
      OR l_sav_kamount NE 0.
*       "/ Determine period
        c_t_budp-perio = <l_f_fmbdp>-rpmax - 17 + sy-index.
*       "/ Only selected periods
        l_sav_perio7(4)   = <l_f_fmbdp>-ryear.
        l_sav_perio7+4(3) = c_t_budp-perio.
        IF l_sav_perio7 IN l_r_perio7.
          c_t_budp-perio7  = l_sav_perio7.
          c_t_budp-tamount = l_sav_tamount * -1.
          c_t_budp-hamount = l_sav_hamount * -1.
          c_t_budp-kamount = l_sav_kamount * -1.
          APPEND c_t_budp.
        ENDIF.
      ENDIF.
    ENDWHILE.

    PERFORM collect_bobjects
      USING <l_f_fmbdp>-rgrant_nbr
            <l_f_fmbdp>-rfund
            <l_f_fmbdp>-budget_pd_9
            <l_f_fmbdp>-rfundsctr
            <l_f_fmbdp>-rcmmtitem
            <l_f_fmbdp>-rfuncarea
            <l_f_fmbdp>-rmeasure.

  ENDLOOP.

* "/ Fill further BUDT fields
*  LOOP AT C_T_BUDP ASSIGNING <L_F_BUDP>.
*    PERFORM FILL_FURTHER_BUDT_FIELDS
*                     CHANGING <L_F_BUDT>.
*  ENDLOOP.

*  "/ Sortieren fuer Zugriff via BINARY SEARCH
  CHECK NOT c_t_budp[] IS INITIAL.

  SORT c_t_budp BY
       rgrant_nbr rmeasure rfuncarea rfund budget_pd_9 rfundsctr rcmmtitem.

ENDFORM.                               " READ_FMBUDP_DATA

*&---------------------------------------------------------------------*
*&      Form  READ_VFMED_DATA
*&---------------------------------------------------------------------*
FORM read_vfmed_data TABLES    u_r_fonds   STRUCTURE range_c10
                               u_r_budper  STRUCTURE range_c10
                               u_r_fictr   STRUCTURE range_c16
                               u_r_fipex   STRUCTURE range_c24
                               u_r_farea   STRUCTURE range_c16
                               u_r_meas    STRUCTURE range_c24
                               u_r_grant   STRUCTURE range_c20
                               u_r_userdim STRUCTURE range_c10
                               c_t_buhl    STRUCTURE g_t_buhl
                     USING     u_versn.

  FIELD-SYMBOLS: <l_f_vfmed> TYPE v_fmed,
                 <l_f_buhl>  TYPE buhl.
  RANGES: l_r_gjahr      FOR  buhl-fiscyear,
          l_r_perio7     FOR  buhl-perio7.
  DATA: l_t_vfmed     LIKE v_fmed OCCURS 100,
        l_f_clauses   TYPE rsds_where,
        l_sav_perio7  LIKE buhl-perio7,
        l_sav_tamount LIKE buhl-tamount,
        l_sav_hamount LIKE buhl-hamount.
* Document type
  DATA: l_t_doctypet TYPE fmed_t_doctypet,
        l_f_doctypet TYPE fmeddoctypet.
  DATA: l_f_process_uit TYPE  buprocess_uit,
        l_budtype_txt   TYPE  text20.


*--------------------------------------------------------------------*
* DS20210930 - Ersetzung des dyn. Aufrufs der Perioden durch Festwerte
*              wie im alten Haushaltsbericht
*--------------------------------------------------------------------*
  lv_p_per_fr = '000'.
  lv_p_per_to = '999'.

  PERFORM fill_time_ranges TABLES l_r_gjahr          " DS20210930
                                  l_r_perio7
                            USING p_fyr_fr
                                  p_fyr_to

                                  lv_p_per_fr
                                  lv_p_per_to.

***  PERFORM fill_time_ranges TABLES l_r_gjahr
***                                  l_r_perio7
***                            USING p_fyr_fr
***                                  p_fyr_to
***                                  p_per_fr
***                                  p_per_to.
*--------------------------------------------------------------------*


* "/ Auf Freie Abgrenzungen positionieren
  READ TABLE g_t_dyn_sel-clauses
        WITH KEY tablename = 'BUHL'
        INTO l_f_clauses.

* "/ Read with ranges
  PERFORM read_vfmed_by_selopt TABLES  l_t_vfmed
                                       u_r_fictr
                                       u_r_fonds
                                       u_r_budper
                                       u_r_fipex
                                       u_r_farea
                                       u_r_meas
                                       u_r_grant
                                       u_r_userdim
                                       l_r_gjahr
                                       l_f_clauses-where_tab
                                USING  fkrs-fikrs
                                       u_versn.


  CHECK NOT l_t_vfmed[] IS INITIAL.

  CALL FUNCTION 'FMCU_GET_DOCTYPES'
    EXPORTING
      i_flg_with_text = 'X'
    IMPORTING
      e_t_doctypet    = l_t_doctypet
    EXCEPTIONS
      no_doctype      = 1
      OTHERS          = 2.

  SORT l_t_doctypet BY doctype.

  LOOP AT l_t_vfmed ASSIGNING <l_f_vfmed>.
*   "/ Take over general fields
*    PERFORM MOVE_VFMED_TO_BUHL TABLES C_T_BUHL
*                                USING <L_F_VFMED>.
    CLEAR c_t_buhl.
    MOVE-CORRESPONDING <l_f_vfmed> TO c_t_buhl.

    CALL FUNCTION 'BUKU_CHECK_VALTYPE'
      EXPORTING
        i_valtype      = c_t_buhl-valtype
        i_flg_text     = 'X'
      IMPORTING
        e_valtype_text = c_t_buhl-valtype_txt
      EXCEPTIONS
        not_found      = 1
        OTHERS         = 2.

    CALL FUNCTION 'BUKU_CHECK_PROCESS_UI'
      EXPORTING
        i_process_ui    = c_t_buhl-process_ui
        i_flg_text      = 'X'
      IMPORTING
        e_f_process_uit = l_f_process_uit
      EXCEPTIONS
        not_found       = 1
        OTHERS          = 2.

    IF sy-subrc = 0.
      c_t_buhl-process_txt = l_f_process_uit-text15.
    ENDIF.

    CALL FUNCTION 'FMCU_CHECK_BUDTYPE'
      EXPORTING
        i_fm_area       = c_t_buhl-fm_area
        i_valtype       = c_t_buhl-valtype
        i_budtype       = c_t_buhl-budtype
      IMPORTING
        e_budtype_txt20 = l_budtype_txt
      EXCEPTIONS
        OTHERS          = 2.

    IF sy-subrc = 0.
      c_t_buhl-budtype_txt = l_budtype_txt.
    ENDIF.

    READ TABLE l_t_doctypet
      INTO l_f_doctypet
      WITH KEY doctype = c_t_buhl-doctype
      BINARY SEARCH.

    IF sy-subrc = 0.
      c_t_buhl-doctype_txt = l_f_doctypet-text.
    ENDIF.

    PERFORM text_get_from_domain USING 'BUED_DOCSTATE'
                                        c_t_buhl-docstate
                               CHANGING c_t_buhl-docstate_txt.

    PERFORM text_get_from_domain USING 'BP_RSTAT'
                                        c_t_buhl-revstate
                               CHANGING c_t_buhl-revstate_txt.

* "/ Calculation over all periods
    WHILE sy-index <= 16
       VARY l_sav_tamount
          FROM <l_f_vfmed>-tval01 NEXT <l_f_vfmed>-tval02
       VARY l_sav_hamount
          FROM <l_f_vfmed>-lval01 NEXT <l_f_vfmed>-lval02.
      IF l_sav_tamount NE 0
      OR l_sav_hamount NE 0.
*       "/ Determine period
        c_t_buhl-perio = <l_f_vfmed>-rpmax - 16 + sy-index.
*       "/ Only selected periods
        l_sav_perio7(4)   = <l_f_vfmed>-fiscyear.
        l_sav_perio7+4(3) = c_t_buhl-perio.
        IF l_sav_perio7 IN l_r_perio7.
          c_t_buhl-perio7  = l_sav_perio7.
          c_t_buhl-tamount = l_sav_tamount * -1.
          c_t_buhl-hamount = l_sav_hamount * -1.

          c_t_buhl-fwaer = fkrs-waers.
          c_t_buhl-twaer = <l_f_vfmed>-tcurr.

          APPEND c_t_buhl.
        ENDIF.
      ENDIF.
    ENDWHILE.

    PERFORM collect_bobjects
      USING <l_f_vfmed>-grant_nbr
            <l_f_vfmed>-fund
            <l_f_vfmed>-budget_pd
            <l_f_vfmed>-fundsctr
            <l_f_vfmed>-cmmtitem
            <l_f_vfmed>-funcarea
            <l_f_vfmed>-measure.

  ENDLOOP.

* "/ Fill further BUHL fields
*  LOOP AT C_T_BUHL ASSIGNING <L_F_BUHL>.
*    PERFORM FILL_FURTHER_BUHL_FIELDS
*                     CHANGING <L_F_BUHL>.
*  ENDLOOP.

*  "/ Sortieren fuer Zugriff via BINARY SEARCH
  CHECK NOT c_t_buhl[] IS INITIAL.

  SORT c_t_buhl BY
       grant_nbr measure funcarea fund budget_pd fundsctr cmmtitem.

ENDFORM.                               " READ_VFMED_DATA

*&---------------------------------------------------------------------*
*&      Form  READ_BUDGET_DATA
*&---------------------------------------------------------------------*
FORM read_budget_data TABLES   u_r_fonds   STRUCTURE range_c10
                               u_r_budper  STRUCTURE range_c10
                               u_r_fictr   STRUCTURE range_c16
                               u_r_fipex   STRUCTURE range_c24
                               u_r_farea   STRUCTURE range_c16
                               u_r_meas    STRUCTURE range_c24
                               u_r_grant   STRUCTURE range_c20
*                              U_R_USERDIM STRUCTURE RANGE_C10
                               c_t_avct    STRUCTURE g_t_avct
                               c_t_budt    STRUCTURE g_t_budt
                               c_t_budp    STRUCTURE g_t_budp
                               c_t_buhl    STRUCTURE g_t_buhl.

  DATA: u_r_userdim  TYPE RANGE OF fm_userdim.

*  "/ Check, if budget should be read
  CHECK: NOT g_flg_avct   IS INITIAL OR
         NOT g_flg_budt   IS INITIAL OR
         NOT g_flg_budp   IS INITIAL OR
         NOT g_flg_buhl   IS INITIAL OR
         NOT g_flg_conval IS INITIAL.

*  "/ Text "Bewegungsdaten werden eingelesen"
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = TEXT-205
    EXCEPTIONS
      OTHERS = 1.

  LOOP AT g_t_versions.

    IF NOT g_flg_avct IS INITIAL.
      PERFORM read_fmavct_data
        TABLES u_r_fonds
               u_r_budper
               u_r_fictr
               u_r_fipex
               u_r_farea
               u_r_meas
               u_r_grant
               u_r_userdim
               c_t_avct
        USING g_t_versions-versn.

    ENDIF.

    IF NOT g_flg_budt IS INITIAL.
      PERFORM read_fmbdt_data
        TABLES u_r_fonds
               u_r_budper
               u_r_fictr
               u_r_fipex
               u_r_farea
               u_r_meas
               u_r_grant
               u_r_userdim
               c_t_budt
        USING g_t_versions-versn.

    ENDIF.
    IF NOT g_flg_budp IS INITIAL.
      PERFORM read_fmbdp_data
        TABLES u_r_fonds
               u_r_budper
               u_r_fictr
               u_r_fipex
               u_r_farea
               u_r_meas
               u_r_grant
               u_r_userdim
               c_t_budp
        USING g_t_versions-versn.

    ENDIF.

    IF NOT g_flg_buhl IS INITIAL.
      PERFORM read_vfmed_data
        TABLES u_r_fonds
               u_r_budper
               u_r_fictr
               u_r_fipex
               u_r_farea
               u_r_meas
               u_r_grant
               u_r_userdim
               c_t_buhl
        USING g_t_versions-versn.

    ENDIF.

  ENDLOOP.
ENDFORM.                               " READ_BUDGET_DATA

*&---------------------------------------------------------------------*
*&      Form  SET_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM set_selection_screen.

* "/ Pushbutton for hidden parameters and selection crit.
  IF p_others IS INITIAL.
    set_pushbutton TEXT-100 icon_expand sscrfields-functxt_02.
  ELSE.
    set_pushbutton TEXT-100 icon_collapse sscrfields-functxt_02.
  ENDIF.

  LOOP AT SCREEN.
    CASE screen-group1.
*     "/ Do Selection parameters for report currency visible
      WHEN 'CCU' OR 'CDA' OR 'CTY'.
*       "/ Only for Budget and Commitment/Actuals
        CHECK g_flg_fmto IS INITIAL AND
              g_flg_fmoi IS INITIAL AND
              g_flg_fmfi IS INITIAL AND
              g_flg_fmco IS INITIAL.
        screen-active = 0.
        MODIFY SCREEN.
*     "/ Parameter P_MAXSEL only for line items
      WHEN 'OPL'.
*       "/ Only line items
        CHECK g_flg_fmoi IS INITIAL AND
              g_flg_fmfi IS INITIAL AND
              g_flg_fmco IS INITIAL.
        screen-active = 0.
        MODIFY SCREEN.
*      WHEN 'SUM'.
*       "/ Only for Commitment/Actuals totals and line items
*        CHECK G_FLG_FMTO IS INITIAL AND
*              G_FLG_FMOI IS INITIAL AND
*              G_FLG_FMFI IS INITIAL AND
*              G_FLG_FMCO IS INITIAL.
*        SCREEN-ACTIVE = 0.
*        MODIFY SCREEN.
      WHEN 'FIC'.
        CHECK g_flg_fund_active IS INITIAL.
*       "/ Without Fund
        screen-active = 0.
        MODIFY SCREEN.
      WHEN 'BPD'.
        CHECK g_flg_budper_active IS INITIAL.
*       "/ Without Budget period
        screen-active = 0.
        MODIFY SCREEN.
      WHEN 'FBE'.
        CHECK g_flg_farea_active IS INITIAL.
*       "/ Without Function
        screen-active = 0.
        MODIFY SCREEN.
      WHEN 'MAS'.
        CHECK g_flg_measure_active IS INITIAL.
*       "/ Without Measure
        screen-active = 0.
        MODIFY SCREEN.
      WHEN 'GMG'.
        CHECK g_flg_grant_active IS INITIAL.
*       "/ Without Grant
        screen-active = 0.
        MODIFY SCREEN.
      WHEN 'CGR'.
*        CHECK G_FLG_FMAAREL IS INITIAL.
*       "/ Without Cover group
        screen-active = 0.
        MODIFY SCREEN.
      WHEN 'FVJ'.
        CHECK g_flg_yearpos IS INITIAL.
*       "/ Only yearindependent commitment items
        screen-active = 0.
        MODIFY SCREEN.
      WHEN 'FSK'.
        CHECK g_flg_yearctr IS INITIAL.
*       "/ Only yearindependent fund centers
        screen-active = 0.
        MODIFY SCREEN.
      WHEN 'FSV'.
        IF g_flg_komm         IS INITIAL.
*       "/ Ausblenden:
*       "/ Hierarchy variant of fund centers for German local auth.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF  NOT g_flg_komm     IS INITIAL
        AND g_flg_no_hierarchy IS INITIAL.
*         "/ Ausblenden:
*         "/ Hierarchievariante der Finanzstellen
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
*      WHEN 'GJR' OR 'FYR' OR 'PER'.
*       Overall values - hide Fiscal Year input fields
*        CHECK P_RB_OVL IS INITIAL.
*        SCREEN-ACTIVE = 0.
*        MODIFY SCREEN.
    ENDCASE.
  ENDLOOP.

* "/ Second loop at screen for customer functions
  LOOP AT SCREEN.
*   "/ Call customer function
*   "/ using Business Transaction Events
*   "/ Process 00106131
    CLEAR g_flg_modify_screen.
    CALL FUNCTION 'OUTBOUND_CALL_00106131_P'
      EXPORTING
        u_screen_name        = screen-name
        u_screen_group1      = screen-group1
        u_screen_group2      = screen-group2
        u_screen_group3      = screen-group3
        u_screen_group4      = screen-group4
        u_others_sel_crit    = p_others
      CHANGING
        c_screen_required    = screen-required
        c_screen_input       = screen-input
        c_screen_output      = screen-output
        c_screen_intensified = screen-intensified
        c_screen_invisible   = screen-invisible
        c_screen_active      = screen-active
        c_screen_display_3d  = screen-display_3d
        c_screen_value_help  = screen-value_help
        c_screen_request     = screen-request
        c_flg_modify         = g_flg_modify_screen.

*   "/ IF G_FLG_MODIFY_SCREEN is not INITIAL than modify screen
    CHECK NOT g_flg_modify_screen IS INITIAL.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                               " SET_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  INITIALIZE_FMF_SEL_SCREEN
*&---------------------------------------------------------------------*
*       Initialize global variables for node FMF_SEL_SCREEN
*----------------------------------------------------------------------*
FORM initialize_fmf_sel_screen.

  REFRESH: g_t_fmfincode,
           g_t_fmfctr,
           g_t_fmci.

  REFRESH: g_t_ffnd,
           g_t_fbpd,
           g_t_fctr,
*           G_T_CVPL,
           g_t_fpos,
           g_t_fnct,
           g_t_fgmg.

  REFRESH: g_t_trippels,
           g_t_cobjects,
           g_t_pobjects,
           g_t_bobjects.

  REFRESH: g_r_fonds,
           g_r_budper,
           g_r_fictr,
*           G_R_OBJNR,
           g_r_fipex,
*           G_R_FIPOS_C,
*           G_R_POSIT,
*           G_R_POSIT_C,
           g_r_farea.
*           G_R_DECKRNG,

* Budget tables ......

  CLEAR: g_t_fmfincode,
         g_t_ffnd,
         g_t_fbpd,
         g_t_fmfctr,
         g_t_fctr,
         g_t_fmci,
*         G_T_CVPL,
         g_t_fpos,
         g_t_trippels,
         g_t_fnct,
*        G_T_FMGM,
         g_r_fonds,
         g_r_budper,
         g_r_fictr,
         g_r_fipex,
         g_r_farea.

*  IF NOT P_FMAHIE IS INITIAL OR
*     NOT P_FMAADN IS INITIAL OR
*     NOT P_FMAAUP IS INITIAL.
*    "/ If hierarchy then read at first master data
*    P_FMBUD = 'X'.
*    CLEAR P_BUDFM.
*  ENDIF.

ENDFORM.                               " INITIALIZE_FMF_SEL_SCREEN

*&---------------------------------------------------------------------*
*&      Form  READ_FMIT_BY_SELOPT
*&---------------------------------------------------------------------*
FORM read_fmit_by_selopt TABLES u_dest_table  STRUCTURE fmit
                                u_r_fictr     STRUCTURE range_c16
                                u_r_fonds     STRUCTURE range_c10
                                u_r_budper    STRUCTURE range_c10
                                u_r_fipex     STRUCTURE range_c22
                                u_r_farea     STRUCTURE range_c16
                                u_r_measure   STRUCTURE range_c24
                                u_r_grant     STRUCTURE range_c20
                                u_r_gjahr     STRUCTURE range_n4
                                u_t_where_tab TYPE rsds_where_tab
                         USING  u_f_fikrs     LIKE fkrs-fikrs.

  DATA: l_flg_large_ranges,
        lt_budper_where TYPE STANDARD TABLE OF abapsource.

* "/ If count of ranges > G_C_MAX_TRIPPELS than select all - performance
  PERFORM refresh_large_ranges TABLES u_r_fonds
                                      u_r_budper
                                      u_r_fictr
                                      u_r_fipex
                                      u_r_farea
                                      u_r_measure
                                      u_r_grant
                             CHANGING l_flg_large_ranges.

* For budget period, we have to adjust the select-options in case
* there are NULL values:
  CALL METHOD cl_fm_budper_utilities_appl=>budget_pd_selopt_to_where
    EXPORTING
      it_selopt         = u_r_budper[]
      i_selopt_name     = 'U_R_BUDPER'
      i_sql_column_name = 'BUDGET_PD'
    IMPORTING
      et_where_clause   = lt_budper_where.

* "/ Select from database
  SELECT * APPENDING TABLE u_dest_table
           FROM fmit
          WHERE fikrs  =  u_f_fikrs
            AND rfistl IN u_r_fictr
            AND rfonds IN u_r_fonds
            AND (lt_budper_where)
            AND rfipex IN u_r_fipex
            AND rfarea IN u_r_farea
            AND rmeasure  IN u_r_measure
            AND grant_nbr IN u_r_grant
            AND ryear  IN u_r_gjahr
            AND (u_t_where_tab).

  IF NOT u_dest_table[] IS INITIAL.
*   "/ Check all ranges
    IF NOT g_r_fonds_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT rfonds IN g_r_fonds_c.
    ENDIF.
    IF NOT g_r_budper_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT budget_pd IN g_r_budper_c.
    ENDIF.
    IF NOT g_r_fictr_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT rfistl IN g_r_fictr_c.
    ENDIF.
    IF NOT g_r_fipex_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT rfipex IN g_r_fipex_c.
    ENDIF.
    IF NOT g_r_farea_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT rfarea IN g_r_farea_c.
    ENDIF.
    IF NOT g_r_measure_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT rmeasure IN g_r_measure_c.
    ENDIF.
    IF NOT g_r_grant_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT grant_nbr IN g_r_grant_c.
    ENDIF.
  ENDIF.

* Macro REMOVE_BY_FUND_BP_COMBINATION will delete table entries where
* the combination of Fund/Budget Period does not match an entry
* in FMFUNDBPD database as selected by dyanmic selection for field FINUSE.
* - &1 = itab name, &2 = field name for Fund in itab,
*   &3 = field name for Budget Period in itab
  remove_by_fund_bp_combination u_dest_table rfonds budget_pd.

*   "/ Restore large ranges back
  PERFORM restore_ranges TABLES u_r_fonds
                                u_r_budper
                                u_r_fictr
                                u_r_fipex
                                u_r_farea
                                u_r_measure
                                u_r_grant.

ENDFORM.                               "READ_FMIT_BY_SELOPT

*&---------------------------------------------------------------------*
*&      Form  READ_FMIT_FROM_ARCHIVE
*&---------------------------------------------------------------------*
FORM read_fmit_from_archive
                            TABLES u_dest_table  STRUCTURE fmit
                                   u_r_fictr     STRUCTURE range_c16
                                   u_r_fonds     STRUCTURE range_c10
                                   u_r_budper    STRUCTURE range_c10
                                   u_r_fipex     STRUCTURE range_c22
                                   u_r_farea     STRUCTURE range_c16
                                   u_r_measure   STRUCTURE range_c24
                                   u_r_grant     STRUCTURE range_c20
                                   u_r_gjahr     STRUCTURE range_n4
                                   u_t_dyn_sel   TYPE rsds_frange_t
                                   u_t_files     TYPE as_t_rng_archiv
                             USING u_f_fikrs     LIKE fkrs-fikrs
                                   v_useas       LIKE p_useas.

  DATA: l_files       TYPE rng_archiv,
        lt_files      TYPE as_t_rng_archiv,
        lt_selections TYPE rsds_trange.

  IF v_useas IS INITIAL.
    LOOP AT u_t_files INTO l_files WHERE low CP 'FM_ACTSUM'.
      APPEND l_files TO lt_files.
    ENDLOOP.
    CHECK NOT lt_files IS INITIAL.
  ENDIF.

  PERFORM as_selections_create TABLES lt_selections
                                      u_r_fictr
                                      u_r_fonds
                                      u_r_budper
                                      u_r_fipex
                                      u_r_farea
                                      u_r_measure
                                      u_r_grant
                                      u_r_gjahr
                                      u_t_dyn_sel
                                USING u_f_fikrs
                                      'FM_ACTSUM'.


  CALL FUNCTION 'FM_FMIT_FROM_ARCHIVE_READ'
    EXPORTING
      i_selections       = lt_selections
      i_show_errors      = 'X'
      i_show_progess     = 'X'
    TABLES
      e_fmit             = u_dest_table
      i_arch_sel         = lt_files
    EXCEPTIONS
      no_infostruc_found = 1
      selections_error   = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Macro REMOVE_BY_FUND_BP_COMBINATION will delete table entries where
* the combination of Fund/Budget Period does not match an entry
* in FMFUNDBPD database as selected by dyanmic selection for field FINUSE.
* - &1 = itab name, &2 = field name for Fund in itab,
*   &3 = field name for Budget Period in itab
  remove_by_fund_bp_combination u_dest_table rfonds budget_pd.

ENDFORM.                               "READ_FMIT_FROM_ARCHIVE

*&---------------------------------------------------------------------*
*&      Form  READ_FMIOI_BY_SELOPT
*&---------------------------------------------------------------------*
FORM read_fmioi_by_selopt TABLES u_dest_table  STRUCTURE fmioi
                                 u_r_fictr     STRUCTURE range_c16
                                 u_r_fonds     STRUCTURE range_c10
                                 u_r_budper    STRUCTURE range_c10
                                 u_r_fipex     STRUCTURE range_c22
                                 u_r_farea     STRUCTURE range_c16
                                 u_r_measure   STRUCTURE range_c24
                                 u_r_grant     STRUCTURE range_c20
                                 u_t_where_tab TYPE rsds_where_tab
                          USING  u_f_fikrs     LIKE fkrs-fikrs.

  DATA: l_flg_large_ranges,
        l_f_max_sel_rows   TYPE tbmaxsel,
        lt_budper_where    TYPE STANDARD TABLE OF abapsource.

* "/ Check if more data should be selected
  IF NOT p_maxsel IS INITIAL.
    l_f_max_sel_rows = p_maxsel - fmsg_fmfbcs-cnt_selected_data.
    CHECK l_f_max_sel_rows > 0.
  ENDIF.

* "/ If count of ranges > G_C_MAX_TRIPPELS than select all - performance
  PERFORM refresh_large_ranges TABLES u_r_fonds
                                      u_r_budper
                                      u_r_fictr
                                      u_r_fipex
                                      u_r_farea
                                      u_r_measure
                                      u_r_grant
                             CHANGING l_flg_large_ranges.

* "/ Restriction only if the ranges hadn't been refreshed
  IF l_flg_large_ranges IS INITIAL AND NOT p_maxsel IS INITIAL.
    l_f_max_sel_rows = p_maxsel - fmsg_fmfbcs-cnt_selected_data.
  ELSE.
    CLEAR l_f_max_sel_rows.
  ENDIF.

* For budget period, we have to adjust the select-options in case
* there are NULL values:
  CALL METHOD cl_fm_budper_utilities_appl=>budget_pd_selopt_to_where
    EXPORTING
      it_selopt         = u_r_budper[]
      i_selopt_name     = 'U_R_BUDPER'
      i_sql_column_name = 'BUDGET_PD'
    IMPORTING
      et_where_clause   = lt_budper_where.

*   "/ Select from database
  SELECT (g_t_fields-fields)
    APPENDING CORRESPONDING FIELDS
      OF TABLE u_dest_table
    FROM fmioi
    UP TO l_f_max_sel_rows ROWS
   WHERE fikrs = u_f_fikrs
     AND fonds IN u_r_fonds
     AND (lt_budper_where)
     AND fistl IN u_r_fictr
     AND fipex IN u_r_fipex
     AND farea IN u_r_farea
     AND measure   IN u_r_measure
     AND grant_nbr IN u_r_grant
     AND (u_t_where_tab).

  IF NOT u_dest_table[] IS INITIAL.
*   "/ Check all ranges
    IF NOT g_r_fonds_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT fonds IN g_r_fonds_c.
    ENDIF.
    IF NOT g_r_budper_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT budget_pd IN g_r_budper_c.
    ENDIF.
    IF NOT g_r_fictr_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT fistl IN g_r_fictr_c.
    ENDIF.
    IF NOT g_r_fipex_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT fipex IN g_r_fipex_c.
    ENDIF.
    IF NOT g_r_farea_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT farea IN g_r_farea_c.
    ENDIF.
    IF NOT g_r_measure_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT measure IN g_r_measure_c.
    ENDIF.
    IF NOT g_r_grant_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT grant_nbr IN g_r_grant_c.
    ENDIF.
  ENDIF.

* Macro REMOVE_BY_FUND_BP_COMBINATION will delete table entries where
* the combination of Fund/Budget Period does not match an entry
* in FMFUNDBPD database as selected by dyanmic selection for field FINUSE.
* - &1 = itab name, &2 = field name for Fund in itab,
*   &3 = field name for Budget Period in itab
  remove_by_fund_bp_combination u_dest_table fonds budget_pd.

*   "/ Restrict selected data (if large ranges have been used)
*   "/ and set counter for selected data
  PERFORM set_counter TABLES u_dest_table
                      USING  l_flg_large_ranges.

*   "/ Restore large ranges back
  PERFORM restore_ranges TABLES u_r_fonds
                                u_r_budper
                                u_r_fictr
                                u_r_fipex
                                u_r_farea
                                u_r_measure
                                u_r_grant.

ENDFORM.                               "READ_FMIOI_BY_SELOPT

*&---------------------------------------------------------------------*
*&      Form  READ_FMIFIIT_BY_SELOPT
*&---------------------------------------------------------------------*
FORM read_fmifiit_by_selopt TABLES u_dest_table  STRUCTURE v_fmifi
                                   u_r_fictr     STRUCTURE range_c16
                                   u_r_fonds     STRUCTURE range_c10
                                   u_r_budper    STRUCTURE range_c10
                                   u_r_fipex     STRUCTURE range_c22
                                   u_r_farea     STRUCTURE range_c16
                                   u_r_measure   STRUCTURE range_c24
                                   u_r_grant     STRUCTURE range_c20
                                   u_t_where_tab TYPE rsds_where_tab
                            USING  u_f_fikrs     LIKE fkrs-fikrs.

  DATA: l_flg_large_ranges,
        l_f_max_sel_rows   TYPE tbmaxsel,
        lt_budper_where    TYPE STANDARD TABLE OF abapsource.

* "/ Check if more data should be selected
  IF NOT p_maxsel IS INITIAL.
    l_f_max_sel_rows = p_maxsel - fmsg_fmfbcs-cnt_selected_data.
    CHECK l_f_max_sel_rows > 0.
  ENDIF.

* "/ If count of ranges > G_C_MAX_TRIPPELS than select all - performance
  PERFORM refresh_large_ranges TABLES u_r_fonds
                                      u_r_budper
                                      u_r_fictr
                                      u_r_fipex
                                      u_r_farea
                                      u_r_measure
                                      u_r_grant
                             CHANGING l_flg_large_ranges.

* "/ Restriction only if the ranges hadn't been refreshed
  IF l_flg_large_ranges IS INITIAL AND NOT p_maxsel IS INITIAL.
    l_f_max_sel_rows = p_maxsel - fmsg_fmfbcs-cnt_selected_data.
  ELSE.
    CLEAR l_f_max_sel_rows.
  ENDIF.

* For budget period, we have to adjust the select-options in case
* there are NULL values:
  CALL METHOD cl_fm_budper_utilities_appl=>budget_pd_selopt_to_where
    EXPORTING
      it_selopt         = u_r_budper[]
      i_selopt_name     = 'U_R_BUDPER'
      i_sql_column_name = 'BUDGET_PD'
    IMPORTING
      et_where_clause   = lt_budper_where.

*   "/ Select from database
  SELECT (g_t_fields-fields)
    APPENDING CORRESPONDING FIELDS
     OF TABLE u_dest_table
    FROM v_fmifi
    UP TO l_f_max_sel_rows ROWS
   WHERE fikrs =  u_f_fikrs
     AND fistl IN  u_r_fictr
     AND fonds IN  u_r_fonds
     AND (lt_budper_where)
     AND fipex IN  u_r_fipex
     AND farea IN  u_r_farea
     AND measure   IN u_r_measure
     AND grant_nbr IN u_r_grant
     AND (u_t_where_tab).

  IF NOT u_dest_table[] IS INITIAL.
*   "/ Check all ranges
    IF NOT g_r_fonds_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT fonds IN g_r_fonds_c.
    ENDIF.
    IF NOT g_r_budper_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT budget_pd IN g_r_budper_c.
    ENDIF.
    IF NOT g_r_fictr_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT fistl IN g_r_fictr_c.
    ENDIF.
    IF NOT g_r_fipex_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT fipex IN g_r_fipex_c.
    ENDIF.
    IF NOT g_r_farea_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT farea IN g_r_farea_c.
    ENDIF.
    IF NOT g_r_measure_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT measure IN g_r_measure_c.
    ENDIF.
    IF NOT g_r_grant_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT grant_nbr IN g_r_grant_c.
    ENDIF.
  ENDIF.

* Macro REMOVE_BY_FUND_BP_COMBINATION will delete table entries where
* the combination of Fund/Budget Period does not match an entry
* in FMFUNDBPD database as selected by dyanmic selection for field FINUSE.
* - &1 = itab name, &2 = field name for Fund in itab,
*   &3 = field name for Budget Period in itab
  remove_by_fund_bp_combination u_dest_table fonds budget_pd.

*   "/ Restrict selected data (if large ranges have been used)
*   "/ and set counter for selected data
  PERFORM set_counter TABLES u_dest_table
                      USING  l_flg_large_ranges.

*   "/ Restore large ranges back
  PERFORM restore_ranges TABLES u_r_fonds
                                u_r_budper
                                u_r_fictr
                                u_r_fipex
                                u_r_farea
                                u_r_measure
                                u_r_grant.

ENDFORM.                               "READ_FMIFIIT_BY_SELOPT

*&---------------------------------------------------------------------*
*&      Form  READ_FMIFIIT_FROM_ARCHIVE
*&---------------------------------------------------------------------*
FORM read_fmifiit_from_archive
                            TABLES u_dest_table  STRUCTURE v_fmifi
                                   u_r_fictr     STRUCTURE range_c16
                                   u_r_fonds     STRUCTURE range_c10
                                   u_r_budper    STRUCTURE range_c10
                                   u_r_fipex     STRUCTURE range_c22
                                   u_r_farea     STRUCTURE range_c16
                                   u_r_measure   STRUCTURE range_c24
                                   u_r_grant     STRUCTURE range_c20
                                   u_t_dyn_sel   TYPE rsds_frange_t
                                   u_t_files     TYPE as_t_rng_archiv
                             USING u_f_fikrs     LIKE fkrs-fikrs
                                   v_useas       LIKE p_useas.

  DATA: l_files        TYPE rng_archiv,
        lt_files       TYPE as_t_rng_archiv,
        lt_selections  TYPE rsds_trange,
        lt_gjahr_dummy TYPE TABLE OF range_n4.

  IF v_useas IS INITIAL.
    LOOP AT u_t_files INTO l_files WHERE low CP 'FM_DOC_FI'.
      APPEND l_files TO lt_files.
    ENDLOOP.
    CHECK NOT lt_files IS INITIAL.
  ENDIF.

  PERFORM as_selections_create TABLES lt_selections
                                      u_r_fictr
                                      u_r_fonds
                                      u_r_budper
                                      u_r_fipex
                                      u_r_farea
                                      u_r_measure
                                      u_r_grant
                                      lt_gjahr_dummy
                                      u_t_dyn_sel
                                USING u_f_fikrs
                                      'FM_DOC_FI'.


  CALL FUNCTION 'FM_FMFIX_FROM_ARCHIVE_READ'
    EXPORTING
      i_selections       = lt_selections
      i_show_errors      = 'X'
      i_show_progess     = 'X'
    TABLES
      e_fmifi            = u_dest_table
      i_arch_sel         = lt_files
    EXCEPTIONS
      no_infostruc_found = 1
      selections_error   = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

* Macro REMOVE_BY_FUND_BP_COMBINATION will delete table entries where
* the combination of Fund/Budget Period does not match an entry
* in FMFUNDBPD database as selected by dyanmic selection for field FINUSE.
* - &1 = itab name, &2 = field name for Fund in itab,
*   &3 = field name for Budget Period in itab
  remove_by_fund_bp_combination u_dest_table fonds budget_pd.

ENDFORM.                               "READ_FMIFIIT_FROM_ARCHIVE

*&---------------------------------------------------------------------*
*&      Form  AS_SELECTIONS_CREATE
*&---------------------------------------------------------------------*
FORM as_selections_create TABLES c_t_selections TYPE rsds_trange
                                 u_r_fictr      STRUCTURE range_c16
                                 u_r_fonds      STRUCTURE range_c10
                                 u_r_budper     STRUCTURE range_c10
                                 u_r_fipex      STRUCTURE range_c22
                                 u_r_farea      STRUCTURE range_c16
                                 u_r_measure    STRUCTURE range_c24
                                 u_r_grant      STRUCTURE range_c20
                                 u_r_gjahr      STRUCTURE range_n4
                                 u_t_dyn_sel    TYPE rsds_frange_t
                           USING u_f_fikrs      LIKE fkrs-fikrs
                                 u_f_obcect     TYPE arch_obj-object.

  DATA: lw_selopt LIKE rsdsselopt,
        lt_selopt TYPE rsds_selopt_t,
        lw_frange TYPE rsds_frange,
        lt_frange TYPE rsds_frange_t,
        lw_trange TYPE rsds_range,
        lt_trange TYPE rsds_trange.
  STATICS: lt_dfies_fmifihd TYPE STANDARD TABLE OF dfies,
           lt_dfies_fmifiit TYPE STANDARD TABLE OF dfies,
           lt_dfies_fmit    TYPE STANDARD TABLE OF dfies.

  IF u_f_obcect = 'FM_DOC_FI'.
    IF NOT u_t_dyn_sel[] IS INITIAL AND lt_dfies_fmifihd[] IS INITIAL.
      CALL FUNCTION 'DDIF_NAMETAB_GET'
        EXPORTING
          tabname   = 'FMIFIHD'
        TABLES
          dfies_tab = lt_dfies_fmifihd[].

      CALL FUNCTION 'DDIF_NAMETAB_GET'
        EXPORTING
          tabname   = 'FMIFIIT'
        TABLES
          dfies_tab = lt_dfies_fmifiit[].
    ENDIF.
  ELSEIF u_f_obcect = 'FM_ACTSUM'.
    IF NOT u_t_dyn_sel[] IS INITIAL AND lt_dfies_fmit[] IS INITIAL.
      CALL FUNCTION 'DDIF_NAMETAB_GET'
        EXPORTING
          tabname   = 'FMIFIIT'
        TABLES
          dfies_tab = lt_dfies_fmifiit[].
    ENDIF.
  ENDIF.

  IF u_f_obcect = 'FM_DOC_FI'.
    lw_trange-tablename = 'FMIFIHD'.
  ELSEIF u_f_obcect = 'FM_ACTSUM'.
    lw_trange-tablename = 'FMIT'.
  ENDIF.
  lw_frange-fieldname = 'FIKRS'.
  lw_selopt-sign      = 'I'.
  lw_selopt-option    = 'EQ'.
  lw_selopt-low       = u_f_fikrs.
  APPEND lw_selopt TO lt_selopt.
  lw_frange-selopt_t  = lt_selopt[].
  APPEND lw_frange TO lt_frange.

* dynamic selections
  IF u_f_obcect = 'FM_DOC_FI'.
    LOOP AT u_t_dyn_sel INTO lw_frange.
      READ TABLE lt_dfies_fmifihd WITH KEY
          fieldname = lw_frange-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc IS INITIAL.
        APPEND lw_frange TO lt_frange.
      ENDIF.
    ENDLOOP.

    IF NOT lt_frange[] IS INITIAL .
      lw_trange-frange_t = lt_frange[].
      APPEND lw_trange TO lt_trange.
    ENDIF.

    FREE:lt_frange.
    lw_trange-tablename = 'FMIFIIT'.
  ENDIF.

  IF NOT u_r_fictr[] IS INITIAL.
    FREE: lt_selopt.
    IF u_f_obcect = 'FM_DOC_FI'.
      lw_frange-fieldname = 'FISTL'.
    ELSEIF u_f_obcect = 'FM_ACTSUM'.
      lw_frange-fieldname = 'RFISTL'.
    ENDIF.
    LOOP AT u_r_fictr.
      MOVE-CORRESPONDING u_r_fictr TO lw_selopt.
      APPEND lw_selopt TO lt_selopt.
    ENDLOOP.
    lw_frange-selopt_t = lt_selopt[].
    APPEND lw_frange TO lt_frange.
  ENDIF.

  IF NOT u_r_fonds[] IS INITIAL.
    FREE: lt_selopt.
    IF u_f_obcect = 'FM_DOC_FI'.
      lw_frange-fieldname = 'FONDS'.
    ELSEIF u_f_obcect = 'FM_ACTSUM'.
      lw_frange-fieldname = 'RFONDS'.
    ENDIF.
    LOOP AT u_r_fonds.
      MOVE-CORRESPONDING u_r_fonds TO lw_selopt.
      APPEND lw_selopt TO lt_selopt.
    ENDLOOP.
    lw_frange-selopt_t = lt_selopt[].
    APPEND lw_frange TO lt_frange.
  ENDIF.

  IF NOT u_r_budper[] IS INITIAL.
    FREE: lt_selopt.
    IF u_f_obcect = 'FM_DOC_FI'.
      lw_frange-fieldname = 'BUDGET_PD'.
    ELSEIF u_f_obcect = 'FM_ACTSUM'.
      lw_frange-fieldname = 'BUDGET_PD'.
    ENDIF.
    LOOP AT u_r_budper.
      MOVE-CORRESPONDING u_r_budper TO lw_selopt.
      APPEND lw_selopt TO lt_selopt.
    ENDLOOP.
    lw_frange-selopt_t = lt_selopt[].
    APPEND lw_frange TO lt_frange.
  ENDIF.

  IF NOT u_r_fipex[] IS INITIAL.
    FREE: lt_selopt.
    IF u_f_obcect = 'FM_DOC_FI'.
      lw_frange-fieldname = 'FIPEX'.
    ELSEIF u_f_obcect = 'FM_ACTSUM'.
      lw_frange-fieldname = 'RFIPEX'.
    ENDIF.
    LOOP AT u_r_fipex.
      MOVE-CORRESPONDING u_r_fipex TO lw_selopt.
      APPEND lw_selopt TO lt_selopt.
    ENDLOOP.
    lw_frange-selopt_t = lt_selopt[].
    APPEND lw_frange TO lt_frange.
  ENDIF.

  IF NOT u_r_farea[] IS INITIAL.
    FREE: lt_selopt.
    IF u_f_obcect = 'FM_DOC_FI'.
      lw_frange-fieldname = 'FAREA'.
    ELSEIF u_f_obcect = 'FM_ACTSUM'.
      lw_frange-fieldname = 'RFAREA'.
    ENDIF.
    LOOP AT u_r_farea.
      MOVE-CORRESPONDING u_r_farea TO lw_selopt.
      APPEND lw_selopt TO lt_selopt.
    ENDLOOP.
    lw_frange-selopt_t = lt_selopt[].
    APPEND lw_frange TO lt_frange.
  ENDIF.

  IF NOT u_r_measure[] IS INITIAL.
    FREE: lt_selopt.
    IF u_f_obcect = 'FM_DOC_FI'.
      lw_frange-fieldname = 'MEASURE'.
    ELSEIF u_f_obcect = 'FM_ACTSUM'.
      lw_frange-fieldname = 'RMEASURE'.
    ENDIF.
    LOOP AT u_r_measure.
      MOVE-CORRESPONDING u_r_measure TO lw_selopt.
      APPEND lw_selopt TO lt_selopt.
    ENDLOOP.
    lw_frange-selopt_t = lt_selopt[].
    APPEND lw_frange TO lt_frange.
  ENDIF.

  IF NOT u_r_grant[] IS INITIAL.
    FREE: lt_selopt.
    lw_frange-fieldname = 'GRANT_NBR'.
    LOOP AT u_r_grant.
      MOVE-CORRESPONDING u_r_grant TO lw_selopt.
      APPEND lw_selopt TO lt_selopt.
    ENDLOOP.
    lw_frange-selopt_t = lt_selopt[].
    APPEND lw_frange TO lt_frange.
  ENDIF.

  IF NOT u_r_gjahr[] IS INITIAL.
    FREE: lt_selopt.
    lw_frange-fieldname = 'RYEAR'.
    LOOP AT u_r_gjahr.
      MOVE-CORRESPONDING u_r_gjahr TO lw_selopt.
      APPEND lw_selopt TO lt_selopt.
    ENDLOOP.
    lw_frange-selopt_t = lt_selopt[].
    APPEND lw_frange TO lt_frange.
  ENDIF.

* dynamic selections
  LOOP AT u_t_dyn_sel INTO lw_frange.
    IF u_f_obcect = 'FM_DOC_FI'.
      READ TABLE lt_dfies_fmifiit WITH KEY
          fieldname = lw_frange-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc IS INITIAL.
        APPEND lw_frange TO lt_frange.
      ENDIF.
    ELSEIF u_f_obcect = 'FM_ACTSUM'.
      READ TABLE lt_dfies_fmit WITH KEY
          fieldname = lw_frange-fieldname TRANSPORTING NO FIELDS.
      IF sy-subrc IS INITIAL.
        APPEND lw_frange TO lt_frange.
      ENDIF.
    ENDIF.
  ENDLOOP.


  IF NOT lt_frange[] IS INITIAL.
    lw_trange-frange_t = lt_frange[].
    APPEND lw_trange TO lt_trange.
  ENDIF.

  APPEND LINES OF lt_trange TO c_t_selections.

ENDFORM.                               "AS_SELECTIONS_CREATE

*&---------------------------------------------------------------------*
*&      Form  READ_FMIA_BY_SELOPT
*&---------------------------------------------------------------------*
FORM read_fmia_by_selopt TABLES u_dest_table  STRUCTURE fmia
                                u_r_fictr     STRUCTURE range_c16
                                u_r_fonds     STRUCTURE range_c10
                                u_r_budper    STRUCTURE range_c10
                                u_r_fipex     STRUCTURE range_c22
                                u_r_farea     STRUCTURE range_c16
                                u_r_measure   STRUCTURE range_c24
                                u_r_grant     STRUCTURE range_c20
                                u_t_where_tab TYPE rsds_where_tab
                         USING  u_f_fikrs LIKE fkrs-fikrs.

  DATA: l_flg_large_ranges,
        l_f_max_sel_rows   TYPE tbmaxsel,
        lt_budper_where    TYPE STANDARD TABLE OF abapsource.

* "/ Check if more data should be selected
  IF NOT p_maxsel IS INITIAL.
    l_f_max_sel_rows = p_maxsel - fmsg_fmfbcs-cnt_selected_data.
    CHECK l_f_max_sel_rows > 0.
  ENDIF.

* "/ If count of ranges > G_C_MAX_TRIPPELS than select all - performance
  PERFORM refresh_large_ranges TABLES u_r_fonds
                                      u_r_budper
                                      u_r_fictr
                                      u_r_fipex
                                      u_r_farea
                                      u_r_measure
                                      u_r_grant
                             CHANGING l_flg_large_ranges.

* "/ Restriction only if the ranges hadn't been refreshed
  IF l_flg_large_ranges IS INITIAL AND NOT p_maxsel IS INITIAL.
    l_f_max_sel_rows = p_maxsel - fmsg_fmfbcs-cnt_selected_data.
  ELSE.
    CLEAR l_f_max_sel_rows.
  ENDIF.

* For budget period, we have to adjust the select-options in case
* there are NULL values:
  CALL METHOD cl_fm_budper_utilities_appl=>budget_pd_selopt_to_where
    EXPORTING
      it_selopt         = u_r_budper[]
      i_selopt_name     = 'U_R_BUDPER'
      i_sql_column_name = 'BUDGET_PD'
    IMPORTING
      et_where_clause   = lt_budper_where.

*   "/ Select from database
  SELECT (g_t_fields-fields)
     APPENDING CORRESPONDING FIELDS
       OF TABLE u_dest_table
     FROM fmia
     UP TO l_f_max_sel_rows ROWS
    WHERE fikrs  =  u_f_fikrs
      AND rfistl IN u_r_fictr
      AND rfonds IN u_r_fonds
      AND (lt_budper_where)
      AND rfipex IN u_r_fipex
      AND rfarea IN u_r_farea
      AND rmeasure  IN u_r_measure
      AND grant_nbr IN u_r_grant
      AND rldnr  =  fmfi_con_ldnr_controlling
      AND (u_t_where_tab).

  IF NOT u_dest_table[] IS INITIAL.
*   "/ Check all ranges
    IF NOT g_r_fonds_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT rfonds IN g_r_fonds_c.
    ENDIF.
    IF NOT g_r_budper_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT budget_pd IN g_r_budper_c.
    ENDIF.
    IF NOT g_r_fictr_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT rfistl IN g_r_fictr_c.
    ENDIF.
    IF NOT g_r_fipex_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT rfipex IN g_r_fipex_c.
    ENDIF.
    IF NOT g_r_farea_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT rfarea IN g_r_farea_c.
    ENDIF.
    IF NOT g_r_measure_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT rmeasure IN g_r_measure_c.
    ENDIF.
    IF NOT g_r_grant_c[] IS INITIAL.
      DELETE u_dest_table WHERE NOT grant_nbr IN g_r_grant_c.
    ENDIF.
  ENDIF.

* Macro REMOVE_BY_FUND_BP_COMBINATION will delete table entries where
* the combination of Fund/Budget Period does not match an entry
* in FMFUNDBPD database as selected by dyanmic selection for field FINUSE.
* - &1 = itab name, &2 = field name for Fund in itab,
*   &3 = field name for Budget Period in itab
  remove_by_fund_bp_combination u_dest_table rfonds budget_pd.

*   "/ Restrict selected data (if large ranges have been used)
*   "/ and set counter for selected data
  PERFORM set_counter TABLES u_dest_table
                      USING  l_flg_large_ranges.

*   "/ Restore large ranges back
  PERFORM restore_ranges TABLES u_r_fonds
                                u_r_budper
                                u_r_fictr
                                u_r_fipex
                                u_r_farea
                                u_r_measure
                                u_r_grant.

ENDFORM.                               "READ_FMIA_BY_SELOPT

*&---------------------------------------------------------------------*
*&      Form  READ_FMAVCT_BY_SELOPT
*&---------------------------------------------------------------------*
FORM read_fmavct_by_selopt TABLES c_dest_table  STRUCTURE fmavct
                                  u_r_fictr     STRUCTURE range_c16
                                  u_r_fonds     STRUCTURE range_c10
                                  u_r_budper    STRUCTURE range_c10
                                  u_r_fipex     STRUCTURE range_c24
                                  u_r_farea     STRUCTURE range_c16
                                  u_r_measure   STRUCTURE range_c24
                                  u_r_grant     STRUCTURE range_c20
                                  u_r_userdim   STRUCTURE range_c10
                                  u_r_gjahr     STRUCTURE range_n4
                                  u_t_where_tab TYPE rsds_where_tab
                           USING  u_f_fikrs     LIKE fkrs-fikrs
                                  u_versn.

  DATA: l_flg_large_ranges,
        l_dummy            LIKE sy-tabix,
        l_t_large_ranges   TYPE g_t_large_ranges WITH HEADER LINE,
        lt_budper_where    TYPE STANDARD TABLE OF abapsource.

* "/ If count of ranges > G_C_MAX_TRIPPELS than select all - performance
  PERFORM refresh_large_ranges TABLES u_r_fonds
                                      u_r_budper
                                      u_r_fictr
                                      u_r_fipex
                                      u_r_farea
                                      u_r_measure
                                      u_r_grant
*                                     U_R_USERDIM
                             CHANGING l_flg_large_ranges.

* For budget period, we have to adjust the select-options in case
* there are NULL values:
  CALL METHOD cl_fm_budper_utilities_appl=>budget_pd_selopt_to_where
    EXPORTING
      it_selopt         = u_r_budper[]
      i_selopt_name     = 'U_R_BUDPER'
      i_sql_column_name = 'BUDGET_PD_9'
    IMPORTING
      et_where_clause   = lt_budper_where.

* "/ Select from database
  SELECT * APPENDING TABLE c_dest_table
           FROM fmavct
          WHERE rfikrs  =  u_f_fikrs
            AND rfund      IN u_r_fonds
            AND (lt_budper_where)
            AND rfundsctr  IN u_r_fictr
            AND rcmmtitem  IN u_r_fipex
            AND rfuncarea  IN u_r_farea
            AND rgrant_nbr IN u_r_grant
            AND rmeasure   IN u_r_measure
            AND ryear      IN u_r_gjahr
            AND rvers      =  u_versn
            AND rldnr      IN s_budcat
            AND (u_t_where_tab).

  IF NOT c_dest_table[] IS INITIAL.
*   "/ Check all ranges
    IF NOT g_r_fonds_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rfund IN g_r_fonds_c.
    ENDIF.
    IF NOT g_r_budper_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT budget_pd_9 IN g_r_budper_c.
    ENDIF.
    IF NOT g_r_fictr_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rfundsctr IN g_r_fictr_c.
    ENDIF.
    IF NOT g_r_fipex_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rcmmtitem IN g_r_fipex_c.
    ENDIF.
    IF NOT g_r_farea_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rfuncarea IN g_r_farea_c.
    ENDIF.
    IF NOT g_r_measure_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rmeasure IN g_r_measure_c.
    ENDIF.
    IF NOT g_r_grant_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rgrant_nbr IN g_r_grant_c.
    ENDIF.
    IF NOT g_r_userdim_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT ruserdim IN g_r_userdim_c.
    ENDIF.
*   "/ If more than two dimensions have been selected by blocks
*   "/ than delete redundant entries
    LOOP AT l_t_large_ranges.
      CASE l_t_large_ranges-range.
        WHEN 'FONDS'.
          DELETE c_dest_table WHERE NOT rfund IN u_r_fonds.
        WHEN 'BUDGET_PD'.
          DELETE c_dest_table WHERE NOT budget_pd_9 IN u_r_budper.
        WHEN 'FICTR'.
          DELETE c_dest_table WHERE NOT rfundsctr IN u_r_fictr.
        WHEN 'FIPEX'.
          DELETE c_dest_table WHERE NOT rcmmtitem IN u_r_fipex.
        WHEN 'FAREA'.
          DELETE c_dest_table WHERE NOT rfuncarea IN u_r_farea.
        WHEN 'MEASURE'.
          DELETE c_dest_table WHERE NOT rmeasure IN u_r_measure.
        WHEN 'GRANT'.
          DELETE c_dest_table WHERE NOT rgrant_nbr IN u_r_grant.
        WHEN 'USERDIM'.
          DELETE c_dest_table WHERE NOT ruserdim IN u_r_userdim.
      ENDCASE.
    ENDLOOP.
  ENDIF.

* Macro REMOVE_BY_FUND_BP_COMBINATION will delete table entries where
* the combination of Fund/Budget Period does not match an entry
* in FMFUNDBPD database as selected by dyanmic selection for field FINUSE.
* - &1 = itab name, &2 = field name for Fund in itab,
*   &3 = field name for Budget Period in itab
  remove_by_fund_bp_combination c_dest_table rfund budget_pd_9.

*   "/ Restore large ranges back
  PERFORM restore_ranges TABLES u_r_fonds
                                u_r_budper
                                u_r_fictr
                                u_r_fipex
                                u_r_farea
                                u_r_measure
                                u_r_grant.

ENDFORM.                               "READ_FMAVCT_BY_SELOPT

*&---------------------------------------------------------------------*
*&      Form  READ_FMBDT_BY_SELOPT
*&---------------------------------------------------------------------*
FORM read_fmbdt_by_selopt TABLES  c_dest_table  STRUCTURE fmbdt
                                  u_r_fictr     STRUCTURE range_c16
                                  u_r_fonds     STRUCTURE range_c10
                                  u_r_budper    STRUCTURE range_c10
                                  u_r_fipex     STRUCTURE range_c24
                                  u_r_farea     STRUCTURE range_c16
                                  u_r_measure   STRUCTURE range_c24
                                  u_r_grant     STRUCTURE range_c20
                                  u_r_userdim   STRUCTURE range_c10
                                  u_r_gjahr     STRUCTURE range_n4
                                  u_t_where_tab TYPE rsds_where_tab
                           USING  u_f_fikrs     LIKE fkrs-fikrs
                                  u_versn.

  DATA: l_flg_large_ranges,
        l_dummy            LIKE sy-tabix,
        l_t_large_ranges   TYPE g_t_large_ranges WITH HEADER LINE,
        lt_budper_where    TYPE STANDARD TABLE OF abapsource.

* "/ If count of ranges > G_C_MAX_TRIPPELS than select all - performance
  PERFORM refresh_large_ranges TABLES u_r_fonds
                                      u_r_budper
                                      u_r_fictr
                                      u_r_fipex
                                      u_r_farea
                                      u_r_measure
                                      u_r_grant
*                                     U_R_USERDIM
                             CHANGING l_flg_large_ranges.

* For budget period, we have to adjust the select-options in case
* there are NULL values:
  CALL METHOD cl_fm_budper_utilities_appl=>budget_pd_selopt_to_where
    EXPORTING
      it_selopt         = u_r_budper[]
      i_selopt_name     = 'U_R_BUDPER'
      i_sql_column_name = 'BUDGET_PD_9'
    IMPORTING
      et_where_clause   = lt_budper_where.

* "/ Select from database
  SELECT * APPENDING TABLE c_dest_table
           FROM fmbdt
          WHERE rfikrs  =  u_f_fikrs
            AND rfund      IN u_r_fonds
            AND (lt_budper_where)
            AND rfundsctr  IN u_r_fictr
            AND rcmmtitem  IN u_r_fipex
            AND rfuncarea  IN u_r_farea
            AND rgrant_nbr IN u_r_grant
            AND rmeasure   IN u_r_measure
            AND ryear      IN u_r_gjahr
            AND rvers      =  u_versn
            AND valtype_9  IN s_valtyp
            AND process_9  IN s_proces
            AND budtype_9  IN s_budtyp
            AND rldnr      IN s_budcat
            AND (u_t_where_tab).

  IF NOT c_dest_table[] IS INITIAL.
*   "/ Check all ranges
    IF NOT g_r_fonds_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rfund IN g_r_fonds_c.
    ENDIF.
    IF NOT g_r_budper_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT budget_pd_9 IN g_r_budper_c.
    ENDIF.
    IF NOT g_r_fictr_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rfundsctr IN g_r_fictr_c.
    ENDIF.
    IF NOT g_r_fipex_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rcmmtitem IN g_r_fipex_c.
    ENDIF.
    IF NOT g_r_farea_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rfuncarea IN g_r_farea_c.
    ENDIF.
    IF NOT g_r_measure_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rmeasure IN g_r_measure_c.
    ENDIF.
    IF NOT g_r_grant_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rgrant_nbr IN g_r_grant_c.
    ENDIF.
    IF NOT g_r_userdim_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT ruserdim IN g_r_userdim_c.
    ENDIF.
*   "/ If more than two dimensions have been selected by blocks
*   "/ than delete redundant entries
    LOOP AT l_t_large_ranges.
      CASE l_t_large_ranges-range.
        WHEN 'FONDS'.
          DELETE c_dest_table WHERE NOT rfund IN u_r_fonds.
        WHEN 'BUDGET_PD'.
          DELETE c_dest_table WHERE NOT budget_pd_9 IN u_r_budper.
        WHEN 'FICTR'.
          DELETE c_dest_table WHERE NOT rfundsctr IN u_r_fictr.
        WHEN 'FIPEX'.
          DELETE c_dest_table WHERE NOT rcmmtitem IN u_r_fipex.
        WHEN 'FAREA'.
          DELETE c_dest_table WHERE NOT rfuncarea IN u_r_farea.
        WHEN 'MEASURE'.
          DELETE c_dest_table WHERE NOT rmeasure IN u_r_measure.
        WHEN 'GRANT'.
          DELETE c_dest_table WHERE NOT rgrant_nbr IN u_r_grant.
        WHEN 'USERDIM'.
          DELETE c_dest_table WHERE NOT ruserdim IN u_r_userdim.
      ENDCASE.
    ENDLOOP.
  ENDIF.

* Macro REMOVE_BY_FUND_BP_COMBINATION will delete table entries where
* the combination of Fund/Budget Period does not match an entry
* in FMFUNDBPD database as selected by dyanmic selection for field FINUSE.
* - &1 = itab name, &2 = field name for Fund in itab,
*   &3 = field name for Budget Period in itab
  remove_by_fund_bp_combination c_dest_table rfund budget_pd_9.

*   "/ Restore large ranges back
  PERFORM restore_ranges TABLES u_r_fonds
                                u_r_budper
                                u_r_fictr
                                u_r_fipex
                                u_r_farea
                                u_r_measure
                                u_r_grant.

ENDFORM.                               "READ_FMBDT_BY_SELOPT

*&---------------------------------------------------------------------*
*&      Form  READ_FMBDT_BY_SELOPT
*&---------------------------------------------------------------------*
FORM read_fmbdp_by_selopt TABLES  c_dest_table  STRUCTURE fmbdp
                                  u_r_fictr     STRUCTURE range_c16
                                  u_r_fonds     STRUCTURE range_c10
                                  u_r_budper    STRUCTURE range_c10
                                  u_r_fipex     STRUCTURE range_c24
                                  u_r_farea     STRUCTURE range_c16
                                  u_r_measure   STRUCTURE range_c24
                                  u_r_grant     STRUCTURE range_c20
                                  u_r_userdim   STRUCTURE range_c10
                                  u_r_gjahr     STRUCTURE range_n4
                                  u_t_where_tab TYPE rsds_where_tab
                           USING  u_f_fikrs     LIKE fkrs-fikrs
                                  u_versn.

  DATA: l_flg_large_ranges,
        l_dummy            LIKE sy-tabix,
        l_t_large_ranges   TYPE g_t_large_ranges WITH HEADER LINE,
        lt_budper_where    TYPE STANDARD TABLE OF abapsource.

* "/ If count of ranges > G_C_MAX_TRIPPELS than select all - performance
  PERFORM refresh_large_ranges TABLES u_r_fonds
                                      u_r_budper
                                      u_r_fictr
                                      u_r_fipex
                                      u_r_farea
                                      u_r_measure
                                      u_r_grant
*                                     U_R_USERDIM
                             CHANGING l_flg_large_ranges.

* For budget period, we have to adjust the select-options in case
* there are NULL values:
  CALL METHOD cl_fm_budper_utilities_appl=>budget_pd_selopt_to_where
    EXPORTING
      it_selopt         = u_r_budper[]
      i_selopt_name     = 'U_R_BUDPER'
      i_sql_column_name = 'BUDGET_PD_9'
    IMPORTING
      et_where_clause   = lt_budper_where.

* "/ Select from database
  SELECT * APPENDING TABLE c_dest_table
           FROM fmbdp
          WHERE rfikrs  =  u_f_fikrs
            AND rfund      IN u_r_fonds
            AND (lt_budper_where)
            AND rfundsctr  IN u_r_fictr
            AND rcmmtitem  IN u_r_fipex
            AND rfuncarea  IN u_r_farea
            AND rgrant_nbr IN u_r_grant
            AND rmeasure   IN u_r_measure
            AND ryear      IN u_r_gjahr
            AND rvers      =  u_versn
            AND valtype_9  IN s_valtyp
            AND process_9  IN s_proces
            AND budtype_9  IN s_budtyp
            AND rldnr      IN s_budcat
            AND (u_t_where_tab).

  IF NOT c_dest_table[] IS INITIAL.
*   "/ Check all ranges
    IF NOT g_r_fonds_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rfund IN g_r_fonds_c.
    ENDIF.
    IF NOT g_r_budper_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT budget_pd_9 IN g_r_budper_c.
    ENDIF.
    IF NOT g_r_fictr_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rfundsctr IN g_r_fictr_c.
    ENDIF.
    IF NOT g_r_fipex_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rcmmtitem IN g_r_fipex_c.
    ENDIF.
    IF NOT g_r_farea_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rfuncarea IN g_r_farea_c.
    ENDIF.
    IF NOT g_r_measure_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rmeasure IN g_r_measure_c.
    ENDIF.
    IF NOT g_r_grant_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT rgrant_nbr IN g_r_grant_c.
    ENDIF.
    IF NOT g_r_userdim_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT ruserdim IN g_r_userdim_c.
    ENDIF.
*   "/ If more than two dimensions have been selected by blocks
*   "/ than delete redundant entries
    LOOP AT l_t_large_ranges.
      CASE l_t_large_ranges-range.
        WHEN 'FONDS'.
          DELETE c_dest_table WHERE NOT rfund IN u_r_fonds.
        WHEN 'BUDGET_PD'.
          DELETE c_dest_table WHERE NOT budget_pd_9 IN u_r_budper.
        WHEN 'FICTR'.
          DELETE c_dest_table WHERE NOT rfundsctr IN u_r_fictr.
        WHEN 'FIPEX'.
          DELETE c_dest_table WHERE NOT rcmmtitem IN u_r_fipex.
        WHEN 'FAREA'.
          DELETE c_dest_table WHERE NOT rfuncarea IN u_r_farea.
        WHEN 'MEASURE'.
          DELETE c_dest_table WHERE NOT rmeasure IN u_r_measure.
        WHEN 'GRANT'.
          DELETE c_dest_table WHERE NOT rgrant_nbr IN u_r_grant.
        WHEN 'USERDIM'.
          DELETE c_dest_table WHERE NOT ruserdim IN u_r_userdim.
      ENDCASE.
    ENDLOOP.
  ENDIF.

* Macro REMOVE_BY_FUND_BP_COMBINATION will delete table entries where
* the combination of Fund/Budget Period does not match an entry
* in FMFUNDBPD database as selected by dyanmic selection for field FINUSE.
* - &1 = itab name, &2 = field name for Fund in itab,
*   &3 = field name for Budget Period in itab
  remove_by_fund_bp_combination c_dest_table rfund budget_pd_9.

*   "/ Restore large ranges back
  PERFORM restore_ranges TABLES u_r_fonds
                                u_r_budper
                                u_r_fictr
                                u_r_fipex
                                u_r_farea
                                u_r_measure
                                u_r_grant.

ENDFORM.                               "READ_FMBDP_BY_SELOPT

*&---------------------------------------------------------------------*
*&      Form  READ_VFMED_BY_SELOPT
*&---------------------------------------------------------------------*
FORM read_vfmed_by_selopt TABLES  c_dest_table  STRUCTURE v_fmed
                                  u_r_fictr     STRUCTURE range_c16
                                  u_r_fonds     STRUCTURE range_c10
                                  u_r_budper    STRUCTURE range_c10
                                  u_r_fipex     STRUCTURE range_c24
                                  u_r_farea     STRUCTURE range_c16
                                  u_r_measure   STRUCTURE range_c24
                                  u_r_grant     STRUCTURE range_c20
                                  u_r_userdim   STRUCTURE range_c10
                                  u_r_gjahr     STRUCTURE range_n4
                                  u_t_where_tab TYPE rsds_where_tab
                           USING  u_f_fikrs     LIKE fkrs-fikrs
                                  u_versn.

  DATA: l_flg_large_ranges,
        l_dummy            LIKE sy-tabix,
        l_t_large_ranges   TYPE g_t_large_ranges WITH HEADER LINE,
        lt_budper_where    TYPE STANDARD TABLE OF abapsource.

* "/ If count of ranges > G_C_MAX_TRIPPELS than select all - performance
  PERFORM refresh_large_ranges TABLES u_r_fonds
                                      u_r_budper
                                      u_r_fictr
                                      u_r_fipex
                                      u_r_farea
                                      u_r_measure
                                      u_r_grant
*                                     U_R_USERDIM
                             CHANGING l_flg_large_ranges.

* For budget period, we have to adjust the select-options in case
* there are NULL values:
  CALL METHOD cl_fm_budper_utilities_appl=>budget_pd_selopt_to_where
    EXPORTING
      it_selopt         = u_r_budper[]
      i_selopt_name     = 'U_R_BUDPER'
      i_sql_column_name = 'BUDGET_PD'
    IMPORTING
      et_where_clause   = lt_budper_where.

* "/ Select from database
  SELECT * APPENDING TABLE c_dest_table
           FROM v_fmed
          WHERE fm_area    =  u_f_fikrs
            AND fund       IN u_r_fonds
            AND (lt_budper_where)
            AND fundsctr   IN u_r_fictr
            AND cmmtitem   IN u_r_fipex
            AND funcarea   IN u_r_farea
            AND grant_nbr  IN u_r_grant
            AND measure    IN u_r_measure
            AND fiscyear   IN u_r_gjahr
            AND version    =  u_versn
            AND valtype    IN s_valtyp
            AND process    IN s_proces
            AND budtype    IN s_budtyp
            AND doctype    IN s_doctyp
            AND budcat     IN s_budcat
            AND (u_t_where_tab).

  IF NOT c_dest_table[] IS INITIAL.
*   "/ Check all ranges
    IF NOT g_r_fonds_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT fund IN g_r_fonds_c.
    ENDIF.
    IF NOT g_r_budper_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT budget_pd IN g_r_budper_c.
    ENDIF.
    IF NOT g_r_fictr_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT fundsctr IN g_r_fictr_c.
    ENDIF.
    IF NOT g_r_fipex_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT cmmtitem IN g_r_fipex_c.
    ENDIF.
    IF NOT g_r_farea_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT funcarea IN g_r_farea_c.
    ENDIF.
    IF NOT g_r_measure_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT measure IN g_r_measure_c.
    ENDIF.
    IF NOT g_r_grant_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT grant_nbr IN g_r_grant_c.
    ENDIF.
    IF NOT g_r_userdim_c[] IS INITIAL.
      DELETE c_dest_table WHERE NOT userdim IN g_r_userdim_c.
    ENDIF.
*   "/ If more than two dimensions have been selected by blocks
*   "/ than delete redundant entries
    LOOP AT l_t_large_ranges.
      CASE l_t_large_ranges-range.
        WHEN 'FONDS'.
          DELETE c_dest_table WHERE NOT fund IN u_r_fonds.
        WHEN 'BUDGET_PD'.
          DELETE c_dest_table WHERE NOT budget_pd IN u_r_budper.
        WHEN 'FICTR'.
          DELETE c_dest_table WHERE NOT fundsctr IN u_r_fictr.
        WHEN 'FIPEX'.
          DELETE c_dest_table WHERE NOT cmmtitem IN u_r_fipex.
        WHEN 'FAREA'.
          DELETE c_dest_table WHERE NOT funcarea IN u_r_farea.
        WHEN 'MEASURE'.
          DELETE c_dest_table WHERE NOT measure IN u_r_measure.
        WHEN 'GRANT'.
          DELETE c_dest_table WHERE NOT grant_nbr IN u_r_grant.
        WHEN 'USERDIM'.
          DELETE c_dest_table WHERE NOT userdim IN u_r_userdim.
      ENDCASE.
    ENDLOOP.
  ENDIF.

* Macro REMOVE_BY_FUND_BP_COMBINATION will delete table entries where
* the combination of Fund/Budget Period does not match an entry
* in FMFUNDBPD database as selected by dyanmic selection for field FINUSE.
* - &1 = itab name, &2 = field name for Fund in itab,
*   &3 = field name for Budget Period in itab
  remove_by_fund_bp_combination c_dest_table fund budget_pd.

*   "/ Restore large ranges back
  PERFORM restore_ranges TABLES u_r_fonds
                                u_r_budper
                                u_r_fictr
                                u_r_fipex
                                u_r_farea
                                u_r_measure
                                u_r_grant.

ENDFORM.                               "READ_VFMED_BY_SELOPT

*&---------------------------------------------------------------------*
*&      Form  COLLECT_BOBJECTS
*&---------------------------------------------------------------------*
FORM collect_bobjects
  USING u_grant_nbr TYPE gm_grant_nbr
        u_fund      TYPE bp_geber
        u_budget_pd TYPE fm_budget_period
        u_fundsctr  TYPE fistl
        u_cmmtitem  TYPE fm_fipex
        u_funcarea  TYPE fm_farea
        u_measure   TYPE fm_measure.

  DATA: l_f_bobject TYPE s_bobject.

  CLEAR l_f_bobject.

  l_f_bobject-address-grant_nbr = u_grant_nbr.
  l_f_bobject-address-fund      = u_fund.
  l_f_bobject-address-budget_pd = cl_fm_budper_utilities_appl=>set_value_switched( u_budget_pd ).
  l_f_bobject-address-fundsctr  = u_fundsctr.
  l_f_bobject-address-cmmtitem  = u_cmmtitem.
  l_f_bobject-address-funcarea  = u_funcarea.
  l_f_bobject-address-measure   = u_measure.

  COLLECT l_f_bobject INTO g_t_bobjects.

ENDFORM.                               " COLLECT_BOBJECTS
