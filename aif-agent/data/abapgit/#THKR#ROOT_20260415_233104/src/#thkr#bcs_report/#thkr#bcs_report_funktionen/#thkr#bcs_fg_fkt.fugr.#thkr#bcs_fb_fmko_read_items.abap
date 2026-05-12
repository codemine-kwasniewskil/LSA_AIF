FUNCTION /thkr/bcs_fb_fmko_read_items.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(REPID) TYPE  SY-REPID
*"     REFERENCE(REF_STRUCT) TYPE  DD03L-TABNAME
*"     REFERENCE(CFIELD) TYPE  FMCOBJC-CFIELD
*"     REFERENCE(FONDS) TYPE  FMAA-FONDS OPTIONAL
*"     REFERENCE(FAREA) TYPE  FMAA-FAREA OPTIONAL
*"     REFERENCE(FIPEX) TYPE  FPOS-FIPEX OPTIONAL
*"     REFERENCE(FICTR) TYPE  FCTR-FICTR OPTIONAL
*"     REFERENCE(GJAHR) TYPE  BPBYX-GJAHR
*"     REFERENCE(GNJHR) TYPE  BPBYX-GNJHR OPTIONAL
*"     REFERENCE(MEASURE) TYPE  FMAA-MEASURE OPTIONAL
*"  TABLES
*"      T_R_FIPEX STRUCTURE  RANGE_C24 OPTIONAL
*"      T_R_FICTR STRUCTURE  RANGE_C16 OPTIONAL
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------

  DATA: l_t_texpr        TYPE rsds_texpr,
        l_t_segments     TYPE rsds_trange,
        l_f_segments     LIKE LINE OF l_t_segments,


        l_t_segments_tmp TYPE rsds_trange,
        l_f_segments_tmp LIKE LINE OF l_t_segments,

        lt_frange_t_tmp  TYPE rsds_frange_t,
        ls_frange_t_tmp  LIKE LINE OF lt_frange_t_tmp,

        l_f_fields       LIKE LINE OF l_f_segments-frange_t,
        l_f_selopt       LIKE LINE OF l_f_fields-selopt_t,
        l_t_selopt       LIKE l_f_fields-selopt_t,

        l_f_selopt_tmp   LIKE LINE OF l_f_fields-selopt_t,
        l_t_selopt_tmp   LIKE l_f_fields-selopt_t,


        l_t_seltab       LIKE rsparams OCCURS 10 WITH HEADER LINE,
        l_t_tcfield      TYPE tcfield,
        l_t_nametab      LIKE dfies OCCURS 1 WITH HEADER LINE,
        l_tabletype      TYPE tabname,
        l_datasource     TYPE bukf_datasource,
        l_ref_table      TYPE REF TO data,
        l_ref_struct     TYPE REF TO data,
        l_test(12),
        l_valuename(50),
        l_keyfigure_check type char17,
        l_keyfigure      TYPE  bukf_keyfig,
        l_tablename      LIKE l_f_segments-tablename.


  DATA  l_bukf           TYPE  /thkr/kf_kfdsrc. "  zcbb_bukf_kfdsrc.  " Kennzahlen - Relation Kennzahl/Datenquellen

  DATA  l_check.


  FIELD-SYMBOLS: <ft> TYPE STANDARD TABLE, <f>, <fs>.

  DATA: ls_zcbbfmkf_repterm TYPE /thkr/kf_repterm. " zcbbfmkf_repterm. " Kennzahlenterme fürs Reporting wg. neue Budgettabellen


  TYPES rsds.
  DATA: g_t_trange        TYPE rsds_trange.
  DATA: l_f_dyn_range     TYPE rsds_range.
  DATA: l_f_dyn_frange    TYPE rsds_frange.
  DATA: l_t_trange        LIKE LINE OF g_t_trange.
  DATA: l_t_frange_t      LIKE LINE OF l_t_trange-frange_t.
  DATA: l_s_selopt_t      LIKE LINE OF l_t_frange_t-selopt_t.
  DATA: restricted(1).

* DS20210913
  DATA: l_t_seltab_beljournal      LIKE rsparams OCCURS 10 WITH HEADER LINE.
  DATA: ls_l_t_seltab_beljournal   TYPE rsparams.

* DS20210913
  DATA: l_t_seltab_budgetlines     LIKE rsparams OCCURS 10 WITH HEADER LINE.
  DATA: ls_l_t_seltab_budgetlines  TYPE rsparams.

  DATA: lv_rrcty_value    TYPE rrcty. " Satzart

*--------------------------------------------------------------------*





*--------------------------------------------------------------------*
* "/Selektionskriterien zu dem Report verwenden
*--------------------------------------------------------------------*
  CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
    EXPORTING
      curr_report     = repid
    TABLES
      selection_table = l_t_seltab.

*--------------------------------------------------------------------*
* "/ Kennzahl setzen
*--------------------------------------------------------------------*
l_keyfigure =  l_keyfigure_check = cfield.


*--------------------------------------------------------------------*
* "/ Aufloesung der Kennzahlen
*--------------------------------------------------------------------*
  CALL FUNCTION '/THKR/BCS_GET_KEYFIGURE_INFO'
    EXPORTING
      i_keyfigure      = l_keyfigure_check
    IMPORTING
      e_tabletype      = l_tabletype
      e_datasource     = l_datasource
    TABLES
      t_nametab        = l_t_nametab
    EXCEPTIONS
      not_found        = 1
      multiple_sources = 2.


* "/ Falls die Kennzahl nicht vorhanden ist
* "/ --> keine Einzelposten lesen
  IF sy-subrc <> 0.
*   Für das Feld ist keine Kennzahl gepflegt, wählen Sie ein anderes Feld.
    MESSAGE ID 'FMKOM1' TYPE 'E' NUMBER 570.  "/Kennzahl nicht gepflegt  -> Fehlerbehandlung
  ENDIF.


*--------------------------------------------------------------------*
* "/ Liefert Werte der dynamischen Selektionen (Selektionsbild)
*--------------------------------------------------------------------*
  CALL FUNCTION 'RS_REFRESH_FROM_DYNAMICAL_SEL'
    EXPORTING
      curr_report        = repid
      mode_write_or_move = 'M'
    IMPORTING
      p_trange           = g_t_trange
    EXCEPTIONS
      not_found          = 1
      wrong_type         = 2
      OTHERS             = 3.


*--------------------------------------------------------------------*
* "/ Aufschluesselung der Kennzahlenauspraegung
*--------------------------------------------------------------------*
  READ TABLE l_t_nametab INDEX 1.

  CREATE DATA l_ref_table TYPE (l_tabletype).
  ASSIGN l_ref_table->* TO <ft>.

  l_test = 'FMKF_S_'.
  l_test+7(5) = l_keyfigure.

  CREATE DATA l_ref_struct TYPE (l_t_nametab-tabname).
  ASSIGN l_ref_struct->* TO <fs>.


*-------------------------------------------*
* Tabelle mit Kennzahlen holen
*-------------------------------------------*
  CALL FUNCTION '/THKR/BCS_GET_KEYFIGURE_TERMS' " 'FMRKF_GET_KEYFIGURE_TERMS'
    EXPORTING
      i_keyfigure  = l_keyfigure
      i_datasource = l_datasource
    IMPORTING
      e_t_terms    = <ft>.


  SORT l_t_nametab BY fieldname.


*-------------------------------------------*
* Felder der Kennzahl abloopen
*-------------------------------------------*
  LOOP AT l_t_nametab WHERE fieldname NE 'SIGN'. "/ Vorzeichen (SIGN) kann nicht ausgewertet werden

    restricted = 'X'.

    CLEAR l_t_selopt[].
    LOOP AT <ft> INTO <fs>. " Es muss jede Rechenregel bearbeitet werden, das Vorzeichen muss beachtet werden

      MOVE-CORRESPONDING <fs> TO ls_zcbbfmkf_repterm.

      l_valuename = l_t_nametab-fieldname.

*     Alles behandeln, was kein Geschäftsjahr ist
      IF  l_valuename <> 'GJAHR' AND l_valuename <> 'GNJHR'
        AND l_valuename <> 'RYEAR' AND l_valuename <> 'CEFFYEAR_9'.
*       restrictions from Dynamic Selections in G_T_TRANGE
*       and from Key Figures in <ft> will be joined into l_t_selopt

*    restrictions from Key Figures
        ASSIGN COMPONENT l_valuename OF STRUCTURE <fs> TO <f>.

        IF <f> <> '*'.

          IF ls_zcbbfmkf_repterm-sign = '+'.
            l_f_selopt-sign   = 'I'.
            l_f_selopt-option = 'EQ'.
            l_f_selopt-low    = <f>.
            APPEND l_f_selopt TO l_t_selopt.
            APPEND l_f_selopt TO l_f_fields-selopt_t.

            restricted = 'X'.
          ENDIF. " IF ls_zcbbfmkf_repterm-sign = '+'.

          IF ls_zcbbfmkf_repterm-sign = '-'.
            l_f_selopt-sign   = 'E'.
            l_f_selopt-option = 'EQ'.
            l_f_selopt-low    = <f>.
            APPEND l_f_selopt TO l_t_selopt.
            APPEND l_f_selopt TO l_f_fields-selopt_t.

            restricted = 'X'.
          ENDIF. " IF ls_zcbbfmkf_repterm-sign = '+'.

        ELSE.

          IF l_t_selopt IS INITIAL.
            CLEAR restricted.
          ENDIF. " IF l_t_selopt IS INITIAL.

        ENDIF.

*    restrictions from Dynamic Selections
        LOOP AT g_t_trange INTO l_t_trange.
          LOOP AT l_t_trange-frange_t INTO l_t_frange_t.
            IF l_t_frange_t-fieldname = l_valuename.
*             this field is restricted in Dynamic Selection and this restriction
*             will be added to l_t_selopt
              LOOP AT l_t_frange_t-selopt_t INTO l_s_selopt_t.
                l_f_selopt = l_s_selopt_t.
                APPEND l_f_selopt TO l_t_selopt.
                APPEND l_f_selopt TO l_f_fields-selopt_t.
              ENDLOOP.
              restricted = 'X'.
            ENDIF.
          ENDLOOP. " LOOP AT l_t_trange-frange_t INTO l_t_frange_t.
        ENDLOOP. "  LOOP AT g_t_trange INTO l_t_trange.



* weitere Felder für Jahre ergänzen
      ELSEIF l_valuename = 'GJAHR' OR  l_valuename = 'GNJHR'
            OR l_valuename = 'RYEAR' OR l_valuename = 'CEFFYEAR_9'.


        ASSIGN COMPONENT l_valuename OF STRUCTURE <fs> TO <f>.
        IF <f> IS INITIAL OR <f> = '*'.
          IF l_valuename = 'GNJHR'.       " Jahr der Kassenwirksamkeit

            IF l_datasource = '0002'.
              SELECT SINGLE * FROM /thkr/kf_kfdsrc INTO l_bukf  "zcbb_bukf_kfdsrc  Kennzahlen - Relation Kennzahl/Datenquellen
                                WHERE applic = 'ZB'
                                AND keyfig = l_keyfigure
                                AND datasource = l_datasource.
              IF l_bukf-fieldgroup = '0002'.
                l_check = 'X'.
              ENDIF.
            ENDIF.

            IF NOT l_check IS INITIAL OR l_datasource <> '0002'.
              IF NOT gnjhr IS INITIAL.
                l_f_selopt-sign     = 'I'.
                l_f_selopt-option   = 'EQ'.
                l_f_selopt-low(4)   = gnjhr.
                APPEND l_f_selopt TO l_f_fields-selopt_t.
              ELSE.
                l_f_selopt-sign     = 'I'.
                l_f_selopt-option   = 'GE'.
                l_f_selopt-low(4)   = gjahr.
                APPEND l_f_selopt TO l_f_fields-selopt_t.
              ENDIF.
            ENDIF.

          ELSE.
            CLEAR l_f_fields-selopt_t[].
            CONTINUE.
          ENDIF.
        ENDIF. " IF <f> IS INITIAL OR <f> = '*'.

        IF l_valuename = 'GJAHR'.
          l_f_selopt-sign       = 'I'.
          l_f_selopt-option     = 'EQ'.
          l_f_selopt-low(4)     = <f> + gjahr.
          IF NOT l_f_selopt-low IS INITIAL.
            APPEND l_f_selopt TO l_f_fields-selopt_t.
          ENDIF.
        ENDIF. " IF l_valuename = 'GJAHR'.

        IF l_valuename = 'GNJHR' AND <f>  CS '+'. " = '0'.
          l_f_selopt-sign       = 'I'.
          l_f_selopt-option     = 'EQ'.
          l_f_selopt-low(4)     = <f> + gjahr.
          IF NOT l_f_selopt-low IS INITIAL.
            APPEND l_f_selopt TO l_f_fields-selopt_t.
          ENDIF.


*       note 1285668: some customers deactivate the check on fiscal year
*       change in OF29, as the result the GNJHR can be lower/higher than the GJAHR
*       (not standard) this is reflected in customer modified key figure
*       change (GNJHR '*' instead '0')
        ELSEIF l_valuename = 'GNJHR' AND <f> = '*'.
          IF l_datasource     = '0002'.
            l_f_selopt-sign   = 'I'.
            l_f_selopt-option = 'NE'.
            CLEAR l_f_selopt-low.
            APPEND l_f_selopt TO l_f_fields-selopt_t.
          ENDIF.
        ENDIF.



        IF l_valuename = 'CEFFYEAR_9' AND <f> CS '+'.
          l_f_selopt-sign       = 'I'.
          l_f_selopt-option     = 'EQ'.
          l_f_selopt-low(4)     = <f> + gjahr.
          IF NOT l_f_selopt-low IS INITIAL.
            APPEND l_f_selopt TO l_f_fields-selopt_t.
          ENDIF.
        ENDIF.

      ENDIF.
    ENDLOOP. " LOOP AT <ft> INTO <fs>.

    l_f_fields-fieldname = l_valuename.






* note 1231531
* if no line in KF is '*' or restriction is specified in Dynamic Selection,
* restriction will be passed to ldb FMF
    IF restricted = 'X'.
      SORT l_f_fields-selopt_t.
      DELETE ADJACENT DUPLICATES FROM l_f_fields-selopt_t COMPARING ALL FIELDS.

*   DS20210914 - Wenn die gleiche Einschränkung
*        einmal mit I EQ 'WERT'     -> inkludieren
*        einmal mit E EQ 'WERT'     -> exkludieren
*   enthalten ist, dann muss der inkludierte Wert gewinnen und der exkludierte Wert gelöscht werden
      REFRESH l_t_selopt_tmp.

      l_t_selopt_tmp[] =  l_f_fields-selopt_t[].

      LOOP AT l_t_selopt_tmp INTO l_f_selopt_tmp WHERE sign = 'I'.

        DELETE l_f_fields-selopt_t WHERE sign   = 'E'
                                     AND option = l_f_selopt_tmp-option
                                     AND low    = l_f_selopt_tmp-low.

      ENDLOOP.

      APPEND l_f_fields TO l_f_segments-frange_t.


*     Sonderbehandlung für Satzart im Zusammehang mit der Datenquelle AVCT,
*     weil unterschiedliche Absprünge in der Einzelsicht notwendig
      IF l_f_fields-fieldname = 'RRCTY' AND l_datasource = '0003'.
        LOOP AT l_t_selopt_tmp INTO l_f_selopt_tmp WHERE sign = 'I'.
          CLEAR: lv_rrcty_value.
          IF l_f_selopt_tmp-low = '1'. " Budget
            lv_rrcty_value =   l_f_selopt_tmp-low.
          ENDIF.

          IF l_f_selopt_tmp-low = '0'. " IST
            lv_rrcty_value =   l_f_selopt_tmp-low.
          ENDIF.


        ENDLOOP.

      ENDIF. "  IF l_f_fields-fieldname = 'RRCTY'.


    ENDIF.
* end of note 1231531




*-------------------------------------------*
*   Behandlung wichtiger Felder für den Aufruf des Belegjournals - Hauptselektion!
*   sie kommt hier nicht über die freien Abgrenzungen sondern über die Kennzahl
*-------------------------------------------*
    IF l_f_fields-fieldname = 'WRTTP' AND l_f_fields-selopt_t IS NOT INITIAL.
      LOOP AT l_f_fields-selopt_t INTO l_f_selopt.

        l_t_seltab-selname  = 'S_WRTTP'.
        l_t_seltab-kind     = 'S'.
        l_t_seltab-sign     = l_f_selopt-sign.
        l_t_seltab-option   = l_f_selopt-option.
        l_t_seltab-low      = l_f_selopt-low.
        l_t_seltab-high     = l_f_selopt-high.
        APPEND l_t_seltab.

      ENDLOOP. " LOOP AT l_f_fields-selopt_t INTO l_f_selopt.
    ENDIF. " IF l_f_fields-fieldname = 'WRTTP' AND l_f_fields-selopt_t IS NOT INITIAL.
*-------------------------------------------*


    REFRESH l_f_fields-selopt_t.

  ENDLOOP. "  LOOP AT l_t_nametab WHERE fieldname NE 'SIGN'.


*-------
* Freie Abgrenzungen
*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsprogramm, Fonds
  IF l_t_nametab-tabname(6) = '/THKR/'.
    CASE l_t_nametab-tabname+11(5).

      WHEN 'FMTOX'.
        SELECT SINGLE * FROM /thkr/kf_kfdsrc INTO l_bukf   " zcbb_bukf_kfdsrc - Kennzahlen - Relation Kennzahl/Datenquellen
                        WHERE applic   = 'ZB'
                        AND keyfig     = l_keyfigure
                        AND datasource = l_datasource.

        l_f_segments-tablename = 'FMCOX'.
        APPEND l_f_segments TO l_t_segments.

        l_f_segments-tablename = 'FMOIX'.
        APPEND l_f_segments TO l_t_segments.

        l_f_segments-tablename = 'FMFIX'.


      WHEN 'FMFIX'.
        l_f_segments-tablename = 'FMCOX'.
        APPEND l_f_segments TO l_t_segments.

        l_f_segments-tablename = 'FMOIX'.
        APPEND l_f_segments TO l_t_segments.

        l_f_segments-tablename = 'FMFIX'.


      WHEN 'BPJA'.
        l_f_segments-tablename = 'BPBYX'.

      WHEN 'KF_S_'.
        IF l_t_nametab-tabname = '/THKR/SBCS_KF_S_FMBDT_BCS'. " 'ZSBB_FMKF_S_FMBDT_BCS' - Kennzahlen - Struktur für die Datenbanktabelle FMBDT
          l_f_segments-tablename = 'BUDT'.
        ENDIF.

        IF l_t_nametab-tabname = '/THKR/SBCS_KF_S_FMAVCT_BCS' ." 'ZSBB_FMKF_S_FMAVCT_BCS' - Kennzahlen - Struktur für die Datenbanktabelle FMAVCT
          l_f_segments-tablename = 'AVCT'.
        ENDIF.

    ENDCASE.
*----------

  ELSE.

    CASE l_t_nametab-tabname+7(5).

      WHEN 'FMTOX'.
        SELECT SINGLE * FROM /thkr/kf_kfdsrc INTO l_bukf   " zcbb_bukf_kfdsrc - Kennzahlen - Relation Kennzahl/Datenquellen
                        WHERE applic   = 'ZB'
                        AND keyfig     = l_keyfigure
                        AND datasource = l_datasource.

        l_f_segments-tablename = 'FMCOX'.
        APPEND l_f_segments TO l_t_segments.

        l_f_segments-tablename = 'FMOIX'.
        APPEND l_f_segments TO l_t_segments.

        l_f_segments-tablename = 'FMFIX'.


      WHEN 'FMFIX'.
        l_f_segments-tablename = 'FMCOX'.
        APPEND l_f_segments TO l_t_segments.

        l_f_segments-tablename = 'FMOIX'.
        APPEND l_f_segments TO l_t_segments.

        l_f_segments-tablename = 'FMFIX'.


      WHEN 'BPJA'.
        l_f_segments-tablename = 'BPBYX'.

      WHEN 'KF_S_'.
        IF l_t_nametab-tabname = '/THKR/SBCS_KF_S_FMBDT_BCS'. " 'ZSBB_FMKF_S_FMBDT_BCS' - Kennzahlen - Struktur für die Datenbanktabelle FMBDT
          l_f_segments-tablename = 'BUDT'.
        ENDIF.

        IF l_t_nametab-tabname = '/THKR/SBCS_KF_S_FMAVCT_BCS' ." 'ZSBB_FMKF_S_FMAVCT_BCS' - Kennzahlen - Struktur für die Datenbanktabelle FMAVCT
          l_f_segments-tablename = 'AVCT'.
        ENDIF.

    ENDCASE.

  ENDIF.
* DS20230308 - Anpassung Haushaltsprogramm, Fonds
*--------------------------------------------------------------------*



  APPEND l_f_segments TO l_t_segments.

  REFRESH: l_f_segments-frange_t,
           l_f_fields-selopt_t.

  l_tablename = l_f_segments-tablename.


*-------------------------------------------*
***  PERFORM change_seltab TABLES l_t_seltab.
* aufgelöstes Perform, es ist nur die
* delete-Anweisung enthalten
*-------------------------------------------*
  DELETE l_t_seltab WHERE selname = 'S_VO_BY'
                       OR selname = 'S_SV_BY'
                       OR selname = 'S_WR_BY'
                       OR selname = 'S_GJ_BY'
                       OR selname = 'S_GN_BY'
                       OR selname = 'S_WR_TO'
                       OR selname = 'S_BA_TO'
                       OR selname = 'S_VO_TO'
                       OR selname = 'S_GN_TO'
                       OR selname = 'S_WR_FI'
                       OR selname = 'S_BA_FI'
                       OR selname = 'S_VO_FI'
                       OR selname = 'S_BE_FI'
                       OR selname = 'S_PE_FI'
                       OR selname = 'S_GJ_FI'
                       OR selname = 'S_GN_FI'.
*-------------------------------------------*



* Layout bei Übergabe an EP-Report löschen
  IF NOT ( sy-cprog = 'RFFMKBHA' OR  sy-cprog = 'RFFMKBHE' ) .
    DELETE l_t_seltab WHERE selname = 'P_DISVAR'.
  ENDIF.

* DS20210929
***  READ TABLE l_t_seltab WITH KEY selname = 'S_POTYP'.
***  IF sy-subrc = 0.
***    l_f_selopt-sign       = 'I'.
***    l_f_selopt-option     = 'EQ'.
***    l_f_selopt-low(4)     = l_t_seltab-low.
***    l_f_selopt-high(4)    = l_t_seltab-high.
***    APPEND l_f_selopt TO l_f_fields-selopt_t.
***
***    IF l_t_seltab-low = '2'.
***      l_f_selopt-sign     = 'I'.
***      l_f_selopt-option   = 'EQ'.
***      l_f_selopt-low(4)   = '5'.
***      l_f_selopt-high(4)  = l_t_seltab-high.
***      APPEND l_f_selopt TO l_f_fields-selopt_t.
***    ENDIF.
***
***    l_f_fields-fieldname = 'POTYP'.
***    APPEND l_f_fields TO l_f_segments-frange_t.
***    REFRESH l_f_fields-selopt_t.
***    l_f_segments-tablename = 'FMAA'.
***    APPEND l_f_segments TO l_t_segments.
***    REFRESH: l_f_segments-frange_t,
***             l_f_fields-selopt_t.
***  ENDIF. "  LOOP AT l_t_nametab WHERE fieldname NE 'SIGN'.


*--------------------------------------------------------------------*
* Entfernung freier Selektionen, da sonst überbestimmt und zu viele Werte zurück kommen

  LOOP AT l_t_segments INTO l_f_segments.

    LOOP AT l_f_segments-frange_t INTO l_f_fields.

      IF     l_f_fields-fieldname = 'FIKRS'
          OR l_f_fields-fieldname = 'GRANT'
          OR l_f_fields-fieldname = 'FONDS'

          OR l_f_fields-fieldname = 'KDATE'

          OR l_f_fields-fieldname = 'MAXSEL'

          OR l_f_fields-fieldname = 'FYR_FR'
          OR l_f_fields-fieldname = 'PER_FR'

          OR l_f_fields-fieldname = 'FYR_TO'
          OR l_f_fields-fieldname = 'PER_TO'

*         OR L_F_FIELDS-FIELDNAME = 'POTYP'
          OR l_f_fields-fieldname = 'FIPEX'
          OR l_f_fields-fieldname = 'FICTR'


          OR l_f_fields-fieldname = 'CF_FLAG'
          OR l_f_fields-fieldname = 'GJAHR'
*         OR l_f_fields-fieldname = 'GNJHR'
          OR l_f_fields-fieldname = 'RVERS'
          OR l_f_fields-fieldname = 'STATS'
          OR l_f_fields-fieldname = 'WRTTP'.

        DELETE l_f_segments-frange_t.

      ENDIF.

    ENDLOOP.

    MODIFY l_t_segments FROM l_f_segments.

  ENDLOOP.

*--------------------------------------------------------------------*


  LOOP AT g_t_trange INTO l_f_dyn_range.
    IF sy-subrc = 0 AND l_f_dyn_range-tablename = 'FMTOX'.
      LOOP AT l_f_dyn_range-frange_t INTO l_f_fields.
        IF l_f_fields-fieldname = 'BTART'
        OR l_f_fields-fieldname = 'BUKRS'
        OR l_f_fields-fieldname = 'HKONT'
        OR l_f_fields-fieldname = 'USERDIM'.

          APPEND l_f_fields TO l_f_segments-frange_t.
          REFRESH l_f_fields-selopt_t.

          l_f_segments-tablename = 'FMCOX'.
          APPEND l_f_segments TO l_t_segments.

          l_f_segments-tablename = 'FMOIX'.
          APPEND l_f_segments TO l_t_segments.

          l_f_segments-tablename = 'FMFIX'.
          APPEND l_f_segments TO l_t_segments.

          REFRESH: l_f_segments-frange_t,
                   l_f_fields-selopt_t.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.



*--------------------------------------------------------------------*
* Sonderbehandlung aufgrund der Kennzahl
*--------------------------------------------------------------------*
  IF l_tablename = 'AVCT'.
    IF  lv_rrcty_value = '0'.  " Istwerte -> Belegjournal

*      Bei Kennzahlen auf Basis von Istwerten aus AVCT muss das Statistikkennzeichen leer sein!
*      l_f_segments-tablename = 'FMFIX'. einfügen
      CLEAR: l_f_segments.
      l_f_segments-tablename = 'FMFIX'.

      CLEAR: l_t_frange_t.
      l_t_frange_t-fieldname = 'STATS'.

      CLEAR: l_s_selopt_t.
      l_f_selopt-sign   = 'I'.
      l_f_selopt-option = 'EQ'.
      l_f_selopt-low    = ' '.

      APPEND l_f_selopt   TO l_t_frange_t-selopt_t.

      APPEND l_t_frange_t TO l_f_segments-frange_t.

      APPEND l_f_segments TO l_t_segments.

    ENDIF. " IF  lv_rrcty_value = '0'.  " Istwerte -> Belegjournal
  ENDIF. "   IF l_tablename = 'AVCT'.
*--------------------------------------------------------------------*




  CALL FUNCTION 'FREE_SELECTIONS_RANGE_2_EX'
    EXPORTING
      field_ranges = l_t_segments
    IMPORTING
      expressions  = l_t_texpr.


************************************************************************
* "/ Umwandlung der mitgegebenen Parameter in SUBMIT Parameter


*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsstellen, Fonds
  IF NOT measure IS INITIAL.
    DELETE l_t_seltab WHERE selname = 'S_MEAS' AND
                             kind = 'S'.
    l_t_seltab-selname    = 'S_MEAS'.
    l_t_seltab-kind       = 'S'.
    l_t_seltab-sign       = 'I'.
    l_t_seltab-option     = 'EQ'.
    l_t_seltab-low        = measure.
    APPEND l_t_seltab.

  ELSE.
    DELETE l_t_seltab WHERE selname = 'S_MEAS' AND
                             kind = 'S'.
    l_t_seltab-selname    = 'S_MEAS'.
    l_t_seltab-kind       = 'S'.
    l_t_seltab-sign       = 'I'.
    l_t_seltab-option     = 'EQ'.
    l_t_seltab-low        = measure.
    APPEND l_t_seltab.

  ENDIF.


  IF NOT fonds IS INITIAL.
    DELETE l_t_seltab WHERE selname = 'S_FONDS' AND
                             kind = 'S'.
    l_t_seltab-selname    = 'S_FONDS'.
    l_t_seltab-kind       = 'S'.
    l_t_seltab-sign       = 'I'.
    l_t_seltab-option     = 'EQ'.
    l_t_seltab-low        = fonds.
    APPEND l_t_seltab.

  ELSE.
    DELETE l_t_seltab WHERE selname = 'S_FONDS' AND
                           kind = 'S'.
    l_t_seltab-selname    = 'S_FONDS'.
    l_t_seltab-kind       = 'S'.
    l_t_seltab-sign       = 'E'.
    l_t_seltab-option     = 'EQ'.
    l_t_seltab-low        = fonds.
    APPEND l_t_seltab.

  ENDIF.
*--------------------------------------------------------------------*


  IF NOT t_r_fipex[] IS INITIAL.
    DELETE l_t_seltab WHERE selname = 'S_FIPEX' AND
                                 kind = 'S'.
    LOOP AT t_r_fipex.
      l_t_seltab-selname    = 'S_FIPEX'.
      l_t_seltab-kind       = 'S'.
      l_t_seltab-sign       = t_r_fipex-sign.
      l_t_seltab-option     = t_r_fipex-option.
      l_t_seltab-low        = t_r_fipex-low.
      APPEND l_t_seltab.
    ENDLOOP.
  ELSEIF NOT fipex IS INITIAL.
    DELETE l_t_seltab WHERE selname = 'S_FIPEX' AND
                             kind = 'S'.
    l_t_seltab-selname    = 'S_FIPEX'.
    l_t_seltab-kind       = 'S'.
    l_t_seltab-sign       = 'I'.
    l_t_seltab-option     = 'EQ'.
    l_t_seltab-low        = fipex.
    APPEND l_t_seltab.
  ENDIF.

  IF NOT t_r_fictr[] IS INITIAL.
    DELETE l_t_seltab WHERE selname = 'S_FICTR' AND
                               kind = 'S'.
    LOOP AT t_r_fictr.
      l_t_seltab-selname  = 'S_FICTR'.
      l_t_seltab-kind     = 'S'.
      l_t_seltab-sign     = t_r_fictr-sign.
      l_t_seltab-option   = t_r_fictr-option.
      l_t_seltab-low      = t_r_fictr-low.
      l_t_seltab-high     = t_r_fictr-high.
      APPEND l_t_seltab.
    ENDLOOP.
  ELSEIF NOT fictr IS INITIAL.
    DELETE l_t_seltab WHERE selname = 'S_FICTR' AND
                            kind = 'S'.
    l_t_seltab-selname    = 'S_FICTR'.
    l_t_seltab-kind       = 'S'.
    l_t_seltab-sign       = 'I'.
    l_t_seltab-option     = 'EQ'.
    l_t_seltab-low  = fictr.
    APPEND l_t_seltab.
  ENDIF.


  IF farea IS INITIAL.
    READ TABLE l_t_seltab WITH KEY selname = 'S_FAREA'.
    l_t_seltab-selname  = 'S_FAREA'.
    l_t_seltab-kind     = 'S'.
    l_t_seltab-sign     = 'I'.
    l_t_seltab-option   = 'EQ'.
    l_t_seltab-low      = ' '.
    MODIFY l_t_seltab
    TRANSPORTING kind sign option low WHERE selname = 'S_FAREA'.
  ENDIF.

  READ TABLE l_t_seltab WITH KEY selname = 'P_PER_FR'.
  IF sy-subrc = 0.
    IF  l_t_seltab-low IS INITIAL.
      l_t_seltab-low    = '000'.
      MODIFY l_t_seltab.
    ENDIF.
  ELSE.
    l_t_seltab-selname  = 'P_PER_FR'.
    l_t_seltab-kind     = 'P'.
    l_t_seltab-sign     = 'I'.
    l_t_seltab-option   = 'EQ'.
    l_t_seltab-low      = '000'.
    MODIFY l_t_seltab.
  ENDIF.


  READ TABLE l_t_seltab WITH KEY selname = 'P_PER_TO'.
  IF sy-subrc = 0.
    IF  l_t_seltab-low IS INITIAL.
      l_t_seltab-low    = '016'.
      MODIFY l_t_seltab.
    ENDIF.
  ELSE.
    l_t_seltab-selname  = 'P_PER_TO'.
    l_t_seltab-kind     = 'P'.
    l_t_seltab-sign     = 'I'.
    l_t_seltab-option   = 'EQ'.
    l_t_seltab-low      = '016'.
    MODIFY l_t_seltab.
  ENDIF.


*Begin of note 857716
  DELETE l_t_seltab WHERE selname = 'P_STAMM' AND
                                  kind = 'P'.
  l_t_seltab-selname    = 'P_STAMM'.
  l_t_seltab-kind       = 'P'.
  l_t_seltab-low        = 'X'.
  APPEND l_t_seltab.
* End of note 857716


  l_t_seltab-selname    = 'P_KENN'.
  l_t_seltab-kind       = 'P'.
  l_t_seltab-sign       = 'I'.
  l_t_seltab-option     = 'EQ'.
  l_t_seltab-low        = cfield.
  APPEND l_t_seltab.


  l_t_seltab-selname  = 'P_ZERO'.
  l_t_seltab-kind     = 'P'.
  l_t_seltab-sign     = 'I'. l_t_seltab-option = 'EQ'.
  IF repid EQ 'RFFMKBHE' OR repid EQ 'RFFMKBHA' OR repid EQ 'RFFMKBHH'.
    l_t_seltab-low  = 'X'.
  ELSE.
    l_t_seltab-low  = cfield.
  ENDIF.
  APPEND l_t_seltab.


*Hinweis 1007174 - Flag Obere/untere kontierungen nicht notwendig,
*da bereits bei erstem Lauf über die LDB alle Fipos ermittelt und
*in SELTAB enthalten
  DELETE l_t_seltab WHERE selname = 'P_FMAADN'
                      AND kind    = 'P'.

  l_t_seltab-selname  = 'P_FMAADN'.
  l_t_seltab-kind     = 'P'.
  l_t_seltab-low      = ' '.
  APPEND l_t_seltab.

  DELETE l_t_seltab WHERE selname = 'P_FMAAUP'
                      AND kind    = 'P'.
  l_t_seltab-selname  = 'P_FMAAUP'.
  l_t_seltab-kind     = 'P'.
  l_t_seltab-low      = ' '.
  APPEND l_t_seltab.


* Hinweis 1021366
* Kommunenflag an und Fond aktiv; eigentlich nicht unterstützt aber
* hier wenigstens Fonds leer machen, wenn von RFFMKBHE oder RFFMKBHA
* aufgerufen
  IF repid EQ 'RFFMKBHE' OR repid EQ 'RFFMKBHA'.

    DELETE l_t_seltab WHERE selname = 'S_FONDS'.
    l_t_seltab-selname  = 'S_FONDS'.
    l_t_seltab-kind     = 'S'.
    l_t_seltab-low      = ' '.
    APPEND l_t_seltab.

  ELSEIF repid EQ 'RFFMKBHH'.

    DELETE l_t_seltab WHERE selname = 'S_FONDS'
                      AND   kind    = 'S'.

    l_t_seltab-selname = 'S_FONDS'.
    l_t_seltab-kind    = 'S'.
    l_t_seltab-sign    = 'I'.
    l_t_seltab-option  = 'EQ'.
    l_t_seltab-low     = fonds.
    APPEND l_t_seltab.
  ENDIF.


* Hinweis 1123432
* Finanzpositionengruppe löschen wenn Finanzposition gefüllt ist
  READ TABLE l_t_seltab WITH KEY selname = 'S_FIPEX'.
  IF sy-subrc = 0.
    IF  l_t_seltab-low IS NOT INITIAL.
      DELETE l_t_seltab WHERE selname = 'P_CI_GRP'.
    ENDIF.
  ENDIF.

* Hinweis 1147355
* Finanzstellenengruppe löschen wenn Finanzstelle gefüllt ist
  READ TABLE l_t_seltab WITH KEY selname = 'S_FICTR'.
  IF sy-subrc = 0.
    IF  l_t_seltab-low IS NOT INITIAL.
      DELETE l_t_seltab WHERE selname = 'P_FC_GRP'.
    ENDIF.
  ENDIF.



*--------------------------------------------------------------------*
* Sonderbehandlung aufgrund der Kennzahl
*--------------------------------------------------------------------*
  IF l_tablename = 'AVCT'.
    IF  lv_rrcty_value = '0'.  " Istwerte -> Belegjournal
      l_tablename = 'AVCT_0'.
    ENDIF.

    IF  lv_rrcty_value = '1'.  " Budgetwerte -> Erfassungsbelege
      l_tablename = 'AVCT_1'.
    ENDIF.
  ENDIF. "   IF l_tablename = 'AVCT'.
*--------------------------------------------------------------------*



************************************************************************
* "/ Aufruf der Einzelpostenreports
*--------------------------------------------------------------------*
  CASE l_tablename.

*** Alte Welt
***    Belegjournal rufen
***    WHEN 'FMFIX'.
***      SUBMIT rffmepg2x WITH SELECTION-TABLE l_t_seltab
***             WITH FREE SELECTIONS l_t_texpr
***             AND RETURN.


*    Belegjournal rufen
    WHEN 'FMFIX'  OR 'AVCT_0'.

* Selektionsbedingungen anpassen
      LOOP AT  l_t_seltab INTO ls_l_t_seltab_beljournal.

        IF    ls_l_t_seltab_beljournal-selname = 'S_FIKRS' " Finanzkreis
           OR ls_l_t_seltab_beljournal-selname = 'S_GRANT' "

*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsstellen, Fonds
***           OR ls_l_t_seltab_beljournal-selname = 'S_FONDS' "
*--------------------------------------------------------------------*

      " HHM Kontierung
           OR ls_l_t_seltab_beljournal-selname = 'S_FIPEX' " Finanzposition
           OR ls_l_t_seltab_beljournal-selname = 'P_KDATE' " Stichtag

           OR ls_l_t_seltab_beljournal-selname = 'S_FICTR' " Finanzstelle

        " Optimierung Datenbankzugriff
           OR ls_l_t_seltab_beljournal-selname = 'P_MAXSEL' " max. Trefferanzahl

        " Obligo / IST Jahresangaben
           OR ls_l_t_seltab_beljournal-selname = 'P_FYR_FR' " Geschäftsjahr von
           OR ls_l_t_seltab_beljournal-selname = 'P_PER_FR' " Periode von

           OR ls_l_t_seltab_beljournal-selname = 'P_FYR_TO' " Geschäftsjahr bis
           OR ls_l_t_seltab_beljournal-selname = 'P_PER_TO' " Periode bis


           OR ls_l_t_seltab_beljournal-selname = 'P_POTYP'  " Finanzpositionstyp
           OR ls_l_t_seltab_beljournal-selname = 'S_WRTTP'. " Werttyp

          IF ls_l_t_seltab_beljournal-low IS NOT INITIAL.
            IF  ls_l_t_seltab_beljournal-sign IS INITIAL.
              ls_l_t_seltab_beljournal-sign = 'I'.
            ENDIF.

            IF  ls_l_t_seltab_beljournal-option IS INITIAL.
              ls_l_t_seltab_beljournal-option = 'EQ'.
            ENDIF.

            APPEND ls_l_t_seltab_beljournal TO  l_t_seltab_beljournal.
          ENDIF. "  IF ls_l_t_seltab_beljournal-low IS NOT INITIAL.

        ENDIF. " IF ls_l_t_seltab_beljournal-selname = 'S_FIKRS' ....


*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsstellen, Fonds
        IF ls_l_t_seltab_beljournal-selname = 'S_FONDS' "
           OR ls_l_t_seltab_beljournal-selname = 'S_MEAS'.


          IF ls_l_t_seltab_beljournal-low IS NOT INITIAL.
            IF  ls_l_t_seltab_beljournal-sign IS INITIAL.
              ls_l_t_seltab_beljournal-sign = 'I'.
            ENDIF.

            IF  ls_l_t_seltab_beljournal-option IS INITIAL.
              ls_l_t_seltab_beljournal-option = 'EQ'.
            ENDIF.

            APPEND ls_l_t_seltab_beljournal TO  l_t_seltab_beljournal.

          ELSE.

            IF  ls_l_t_seltab_beljournal-sign = 'I'.
              ls_l_t_seltab_beljournal-sign = 'I'.

              IF  ls_l_t_seltab_beljournal-option IS INITIAL.
                ls_l_t_seltab_beljournal-option = 'EQ'.
              ENDIF.

              APPEND ls_l_t_seltab_beljournal TO  l_t_seltab_beljournal.
            ENDIF. " IF  ls_l_t_seltab_beljournal-sign = 'E'.

          ENDIF. "  IF ls_l_t_seltab_beljournal-low IS NOT INITIAL.


        ENDIF. " IF ls_l_t_seltab_beljournal-selname = 'S_FIKRS' ....
*--------------------------------------------------------------------*


      ENDLOOP. " LOOP AT  l_t_seltab INTO ls_l_t_seltab_beljournal.


*     Belegjournal rufen
      SUBMIT  rffmepgax
       WITH SELECTION-TABLE l_t_seltab_beljournal   " Selektionsbild versorgen
       WITH FREE SELECTIONS l_t_texpr               " Freie Abgrenzungen
       AND RETURN.





***      Alte Welt
***    WHEN 'BPBYX'.
***      SUBMIT rffmep1bx
***             WITH SELECTION-TABLE l_t_seltab
***             WITH FREE SELECTIONS l_t_texpr
***             AND RETURN.


    WHEN 'BUDT'   OR 'AVCT_1'.

      REFRESH: l_t_seltab_budgetlines.
*   Selektionsbedingungen anpassen
      LOOP AT  l_t_seltab INTO ls_l_t_seltab_budgetlines.


        IF  ls_l_t_seltab_budgetlines-selname = 'S_FIKRS'. " Finanzkreis
          ls_l_t_seltab_budgetlines-selname = 'P_FMAREA'.

          APPEND ls_l_t_seltab_budgetlines TO  l_t_seltab_budgetlines.
        ENDIF. "IF  ls_l_t_seltab_budgetlines-selname = 'S_FIKRS'. " Finanzkreis


        IF  ls_l_t_seltab_budgetlines-selname = 'S_FIPEX'. " Finanzposition
          ls_l_t_seltab_budgetlines-selname = 'S_CMMT'.

          APPEND ls_l_t_seltab_budgetlines TO  l_t_seltab_budgetlines.
        ENDIF. "IF  ls_l_t_seltab_budgetlines-selname = 'S_FIPEX'. " Finanzposition


        IF ls_l_t_seltab_budgetlines-selname = 'S_FICTR'. " Finanzstelle
          ls_l_t_seltab_budgetlines-selname = 'S_FCTR'.

          APPEND ls_l_t_seltab_budgetlines TO  l_t_seltab_budgetlines.
        ENDIF. " IF ls_l_t_seltab_budgetlines-selname = 'S_FICTR'. " Finanzstelle


        IF ls_l_t_seltab_budgetlines-selname = 'S_VERSN'. " Version
          ls_l_t_seltab_budgetlines-selname = 'S_VERS'.

          APPEND ls_l_t_seltab_budgetlines TO  l_t_seltab_budgetlines.
        ENDIF. " IF ls_l_t_seltab_budgetlines-selname = 'S_VERSN'. " Version


        IF ls_l_t_seltab_budgetlines-selname = 'P_GJAHR'. " Geschäftsjahr
          ls_l_t_seltab_budgetlines-kind    = 'S'.
          ls_l_t_seltab_budgetlines-selname = 'S_YEAR'.
          ls_l_t_seltab_budgetlines-sign    = 'I'.        "
          ls_l_t_seltab_budgetlines-option  = 'EQ'.       "

          APPEND ls_l_t_seltab_budgetlines TO  l_t_seltab_budgetlines.
        ENDIF. " IF ls_l_t_seltab_budgetlines-selname = 'P_GJAHR'. " Geschäftsjahr



        IF ls_l_t_seltab_budgetlines-selname = 'P_POTYP'. " Finanzpositionstyp
          ls_l_t_seltab_budgetlines-kind    = 'S'.
          ls_l_t_seltab_budgetlines-selname = 'S_POTYP'.
          ls_l_t_seltab_budgetlines-sign    = 'I'.        "
          ls_l_t_seltab_budgetlines-option  = 'EQ'.       "


          APPEND ls_l_t_seltab_budgetlines TO  l_t_seltab_budgetlines.
        ENDIF. " IF ls_l_t_seltab_budgetlines-selname = 'P_GJAHR'. " Finanzpositionstyp


*--------------------------------------------------------------------*
* DS20230308 - Anpassung Haushaltsprogramm, Fonds

        IF ls_l_t_seltab_budgetlines-selname = 'S_MEAS'. " Haushaltsprogramm
          ls_l_t_seltab_budgetlines-selname = 'S_MEAS'.

          APPEND ls_l_t_seltab_budgetlines TO  l_t_seltab_budgetlines.
        ENDIF. " IF ls_l_t_seltab_budgetlines-selname = 'S_VERSN'. " Version

        IF ls_l_t_seltab_budgetlines-selname = 'S_FONDS'. " Fonds
          ls_l_t_seltab_budgetlines-selname = 'S_FUND'.

          APPEND ls_l_t_seltab_budgetlines TO  l_t_seltab_budgetlines.
        ENDIF. " IF ls_l_t_seltab_budgetlines-selname = 'S_VERSN'. " Version

* DS20230308 - Anpassung Haushaltsprogramm, Fonds
*--------------------------------------------------------------------*

      ENDLOOP. " LOOP AT  l_t_seltab INTO l_t_seltab_budgetlines.


* Restliche Werte aus der freien Selektion bzw. den Kennzahlen belegen
      IF l_t_segments IS NOT INITIAL.

        LOOP AT l_t_segments INTO l_f_segments_tmp WHERE ( tablename = 'BUDT' OR tablename = 'AVCT' ).

          LOOP AT l_f_segments_tmp-frange_t INTO ls_frange_t_tmp.

*           Budgetkategorie
            IF ls_frange_t_tmp-fieldname = 'RLDNR'. " -> S_BUDCAT

              LOOP AT ls_frange_t_tmp-selopt_t INTO l_f_selopt_tmp.

                IF l_f_segments_tmp-tablename <> 'AVCT'.
                  CLEAR: ls_l_t_seltab_budgetlines.
                  ls_l_t_seltab_budgetlines-selname = 'S_BUDCAT'.
                  ls_l_t_seltab_budgetlines-kind    = 'S'.
                  ls_l_t_seltab_budgetlines-sign    = l_f_selopt_tmp-sign.
                  ls_l_t_seltab_budgetlines-option  = l_f_selopt_tmp-option.
                  ls_l_t_seltab_budgetlines-low     = l_f_selopt_tmp-low.
                  ls_l_t_seltab_budgetlines-high    = l_f_selopt_tmp-high.
                  APPEND ls_l_t_seltab_budgetlines TO  l_t_seltab_budgetlines.


                ELSE.
                  CLEAR: ls_l_t_seltab_budgetlines.
                  ls_l_t_seltab_budgetlines-selname = 'S_BUDCAT'.
                  ls_l_t_seltab_budgetlines-kind    = 'S'.
                  ls_l_t_seltab_budgetlines-sign    = l_f_selopt_tmp-sign.
                  ls_l_t_seltab_budgetlines-option  = l_f_selopt_tmp-option.
                  ls_l_t_seltab_budgetlines-low     = COND #( WHEN l_f_selopt_tmp-low = '9H' THEN '9F'
                                                              WHEN l_f_selopt_tmp-low = '9I' THEN '9G' ).
*                 ls_l_t_seltab_budgetlines-high    = l_f_selopt_tmp-high.
                  APPEND ls_l_t_seltab_budgetlines TO  l_t_seltab_budgetlines.

                ENDIF. " IF tablename <> 'AVCT'.



                CLEAR: ls_l_t_seltab_budgetlines.
                ls_l_t_seltab_budgetlines-selname = 'S_RLDNR'.
                ls_l_t_seltab_budgetlines-kind    = 'S'.
                ls_l_t_seltab_budgetlines-sign    = l_f_selopt_tmp-sign.
                ls_l_t_seltab_budgetlines-option  = l_f_selopt_tmp-option.
                ls_l_t_seltab_budgetlines-low     = l_f_selopt_tmp-low.
                ls_l_t_seltab_budgetlines-high    = l_f_selopt_tmp-high.
                APPEND ls_l_t_seltab_budgetlines TO  l_t_seltab_budgetlines.

              ENDLOOP.
            ENDIF. " IF ls_frange_t_tmp-fieldname = 'RLDNR'. " -> S_BUDCAT



*           BCS Werttyp
            IF ls_frange_t_tmp-fieldname = 'VALTYPE_9'. " -> S_VALTYP
              LOOP AT ls_frange_t_tmp-selopt_t INTO l_f_selopt_tmp.

                CLEAR: ls_l_t_seltab_budgetlines.
                ls_l_t_seltab_budgetlines-selname = 'S_VALTYP'.
                ls_l_t_seltab_budgetlines-kind    = 'S'.
                ls_l_t_seltab_budgetlines-sign    = l_f_selopt_tmp-sign.
                ls_l_t_seltab_budgetlines-option  = l_f_selopt_tmp-option.
                ls_l_t_seltab_budgetlines-low     = l_f_selopt_tmp-low.
                ls_l_t_seltab_budgetlines-high    = l_f_selopt_tmp-high.
                APPEND ls_l_t_seltab_budgetlines TO  l_t_seltab_budgetlines.

              ENDLOOP.
            ENDIF. " IF ls_frange_t_tmp-fieldname = 'RLDNR'. " -> S_BUDCAT


*           Budgettype
            IF ls_frange_t_tmp-fieldname = 'BUDTYPE_9'. " -> S_BUDTYP
              LOOP AT ls_frange_t_tmp-selopt_t INTO l_f_selopt_tmp.

                CLEAR: ls_l_t_seltab_budgetlines.
                ls_l_t_seltab_budgetlines-selname = 'S_BUDTYP'.
                ls_l_t_seltab_budgetlines-kind    = 'S'.
                ls_l_t_seltab_budgetlines-sign    = l_f_selopt_tmp-sign.
                ls_l_t_seltab_budgetlines-option  = l_f_selopt_tmp-option.
                ls_l_t_seltab_budgetlines-low     = l_f_selopt_tmp-low.
                ls_l_t_seltab_budgetlines-high    = l_f_selopt_tmp-high.
                APPEND ls_l_t_seltab_budgetlines TO  l_t_seltab_budgetlines.

              ENDLOOP.
            ENDIF. " IF ls_frange_t_tmp-fieldname = 'BUDTYPE_9'. " -> S_BUDTYP



*           Satzart
            IF ls_frange_t_tmp-fieldname = 'RRCTY'. " -> S_RRCTY
              LOOP AT ls_frange_t_tmp-selopt_t INTO l_f_selopt_tmp.

                CLEAR: ls_l_t_seltab_budgetlines.
                ls_l_t_seltab_budgetlines-selname = 'S_RRCTY'.
                ls_l_t_seltab_budgetlines-kind    = 'S'.
                ls_l_t_seltab_budgetlines-sign    = l_f_selopt_tmp-sign.
                ls_l_t_seltab_budgetlines-option  = l_f_selopt_tmp-option.
                ls_l_t_seltab_budgetlines-low     = l_f_selopt_tmp-low.
                ls_l_t_seltab_budgetlines-high    = l_f_selopt_tmp-high.
                APPEND ls_l_t_seltab_budgetlines TO  l_t_seltab_budgetlines.

              ENDLOOP.
            ENDIF. " IF ls_frange_t_tmp-fieldname = 'RRCTY'. " -> S_RRCTY


*           Jahr der Kassenwirksamkeit
            IF ls_frange_t_tmp-fieldname = 'CEFFYEAR_9'. " -> S_CSHYR
              LOOP AT ls_frange_t_tmp-selopt_t INTO l_f_selopt_tmp.

                CLEAR: ls_l_t_seltab_budgetlines.
                ls_l_t_seltab_budgetlines-selname = 'S_CSHYR'.
                ls_l_t_seltab_budgetlines-kind    = 'S'.
                ls_l_t_seltab_budgetlines-sign    = l_f_selopt_tmp-sign.
                ls_l_t_seltab_budgetlines-option  = l_f_selopt_tmp-option.
                ls_l_t_seltab_budgetlines-low     = l_f_selopt_tmp-low.
*               ls_l_t_seltab_budgetlines-high    = l_f_selopt_tmp-high.
                APPEND ls_l_t_seltab_budgetlines TO  l_t_seltab_budgetlines.

              ENDLOOP.
            ENDIF. " IF ls_frange_t_tmp-fieldname = 'RRCTY'. " -> S_RRCTY


          ENDLOOP.


        ENDLOOP.

      ENDIF. "IF l_t_segments IS NOT INITIAL.



      SUBMIT rffmed_drilldown
             WITH SELECTION-TABLE l_t_seltab_budgetlines
             AND RETURN.
  ENDCASE.



ENDFUNCTION.
