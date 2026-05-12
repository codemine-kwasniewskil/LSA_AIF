*&---------------------------------------------------------------------*
*& Include          /THKR/FI_IST_REPORT_C01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      CLASS DEFINITION
*&---------------------------------------------------------------------*
CLASS lcl_appl DEFINITION.
*    -----//-----
  PUBLIC SECTION.
    CLASS-METHODS:
      main,
      display,
      screen_check,
      f4_path.

*    -----//-----
  PROTECTED SECTION.
    CONSTANTS:
      mc_default_langu  TYPE sylangu VALUE 'D'.
    CLASS-DATA:
      mt_alv       TYPE tt_alv_data,
      mt_alv_vein  TYPE tt_alv_vein,
      ms_alv_vein  TYPE ty_alv_vein,
      mt_vein_pos  TYPE tt_vein_pos,
      ms_vein_pos  TYPE ty_vein_pos,
      mt_alv_hvwng TYPE tt_alv_hvwng_data,
      mt_alv_vhvw  TYPE tt_alv_vein_hvw,
      mo_table     TYPE REF TO cl_salv_table.

*    -----//-----
  PRIVATE SECTION.
    CLASS-METHODS:
      get_data,
      get_vein_data,
      get_havwng_data,
      get_vein_header IMPORTING iv_name        TYPE abap_compname
                                iv_appl        TYPE /thkr/de_appl
                      RETURNING VALUE(rv_name) TYPE abap_compname,
      file_save,
      save_persokh,
      save_havweb,
      save_vein,
      save_havwng,
      create_file CHANGING ct_text_data TYPE truxs_t_text_data,
      convert_table_to_csv IMPORTING it_table     TYPE STANDARD TABLE
                                     iv_separator TYPE char1 DEFAULT ';'
                           EXPORTING et_csv       TYPE truxs_t_text_data
                           RAISING   cx_root.
ENDCLASS.


*&---------------------------------------------------------------------*
*&      CLASS IMPLEMENTATION
*&---------------------------------------------------------------------*
CLASS lcl_appl IMPLEMENTATION.
  METHOD main.
    " get data by selection criterias
    CASE abap_true.
      WHEN p_pers OR p_havw.
        get_data( ).
      WHEN p_vein.
        get_vein_data( ).
      WHEN p_havwng.
        get_havwng_data( ).
    ENDCASE.

    " save data to CSV-file
    IF p_save = abap_true.
      file_save( ).
    ENDIF.
  ENDMETHOD.


  METHOD get_data.
    DATA: lt_fmifiit TYPE STANDARD TABLE OF fmifiit,
          lt_fmci    TYPE SORTED TABLE OF ty_fmci_data WITH NON-UNIQUE KEY fikrs gjahr fipex,
          lt_temp    LIKE mt_alv,
          ls_alv     LIKE LINE OF mt_alv,
          lv_period  TYPE char6.


    " data selection
    SELECT fmifiit~fmbelnr fmifiit~fikrs fmbuzei btart rldnr gjahr stunr perio trbtr twaer fonds fipex psobt
      INTO CORRESPONDING FIELDS OF TABLE lt_fmifiit
          FROM fmifiit INNER JOIN fmifihd ON fmifiit~fmbelnr = fmifihd~fmbelnr AND fmifiit~fikrs = fmifihd~fikrs
          WHERE fonds IN so_fonds
            AND gjahr = p_gjahr
            AND loekz = space
            AND wrttp = '57'.

    IF lt_fmifiit IS NOT INITIAL.
      SELECT fmci~fikrs fmci~gjahr fmci~fipex hsart zz_fkz text1 text2 text3
        FROM fmci INNER JOIN fmcit ON fmci~fikrs = fmcit~fikrs
        AND  fmci~gjahr = fmcit~gjahr
        AND  fmci~fipex = fmcit~fipex
        AND  spras      = mc_default_langu
        INTO CORRESPONDING FIELDS OF TABLE lt_fmci
          FOR ALL ENTRIES IN lt_fmifiit
          WHERE fmci~fikrs = lt_fmifiit-fikrs
            AND fmci~gjahr = lt_fmifiit-gjahr
            AND fmci~fipex = lt_fmifiit-fipex.
    ENDIF.

    " internal table preparation
    LOOP AT lt_fmifiit ASSIGNING FIELD-SYMBOL(<fs_fmifiit>).
      APPEND INITIAL LINE TO lt_temp ASSIGNING FIELD-SYMBOL(<fs_temp>).
      MOVE-CORRESPONDING <fs_fmifiit> TO <fs_temp>.
      " removing key fields that are no longer needed and may interfere with summarization
      FREE: <fs_temp>-fmbelnr, <fs_temp>-stunr, <fs_temp>-fmbuzei, <fs_temp>-btart, <fs_temp>-rldnr.

      <fs_temp>-kapitel = <fs_fmifiit>-fipex(4).
      <fs_temp>-titel   = <fs_fmifiit>-fipex+4(5).

      " month determination
      IF p_monat IS NOT INITIAL.
        IF <fs_fmifiit>-perio IS NOT INITIAL.
          <fs_temp>-monat = |{ <fs_fmifiit>-gjahr }{ <fs_fmifiit>-perio+1(2) }|.
        ELSEIF <fs_fmifiit>-psobt IS NOT INITIAL.
          <fs_temp>-monat = <fs_fmifiit>-psobt(6).
        ENDIF.
      ENDIF.

      " FMCI addition
      READ TABLE lt_fmci ASSIGNING FIELD-SYMBOL(<ls_fmci>) WITH TABLE KEY fikrs = <fs_fmifiit>-fikrs gjahr = <fs_fmifiit>-gjahr fipex = <fs_fmifiit>-fipex.
      IF sy-subrc = 0.
        <fs_temp>-zz_fkz = <ls_fmci>-zz_fkz.
        <fs_temp>-hsart = <ls_fmci>-hsart.
        IF <ls_fmci>-hsart = 'C'.
          <fs_temp>-unplan = abap_true.
        ENDIF.
        <fs_temp>-text1 = <ls_fmci>-text1.
        <fs_temp>-text2 = <ls_fmci>-text2.
        <fs_temp>-text3 = <ls_fmci>-text3.
      ENDIF.
    ENDLOOP.

    " filter by month
    IF p_monat IS NOT INITIAL.
      lv_period = |{ p_gjahr }{ p_monat }|.
      DELETE lt_temp WHERE monat <> lv_period.
    ENDIF.

    " Kapitel und Titel ggf. entfernen
    " Wenn im Selektionsbild angegeben.
    IF p_kapitl IS NOT INITIAL.
      DELETE lt_temp WHERE kapitel <> p_kapitl.
    ENDIF.

    IF p_titel IS NOT INITIAL.
      DELETE lt_temp WHERE titel = p_titel.
    ENDIF.

    " summarize the amount based on the period and financial position to the result table
    SORT lt_temp BY fonds kapitel titel monat.
    LOOP AT lt_temp ASSIGNING <fs_temp>.
      MOVE-CORRESPONDING <fs_temp> TO ls_alv.
      COLLECT ls_alv INTO mt_alv.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_vein_data.
    DATA: lt_kblp     TYPE STANDARD TABLE OF kblp,
          lt_kblk     TYPE SORTED TABLE OF kblk WITH NON-UNIQUE KEY belnr,
          lv_begin    TYPE datum,
          lv_end      TYPE datum,
          ls_vein_pos TYPE ty_vein_pos.

    FIELD-SYMBOLS: <mf_pos> TYPE ty_vein_pos.

    BREAK-POINT ID /thkr/fi_ist_r_vein_data.

    SELECT belnr blpos erdat erldat wtges fipos fdatk
      INTO CORRESPONDING FIELDS OF TABLE lt_kblp
      FROM kblp
      WHERE vrgng = 'KCOM'
        AND fipex IN so_fipex
        AND stats <> 'X'.

    IF lt_kblp IS NOT INITIAL.
      SELECT belnr waers
        INTO CORRESPONDING FIELDS OF TABLE lt_kblk
        FROM kblk
        FOR ALL ENTRIES IN lt_kblp
        WHERE belnr = lt_kblp-belnr.
    ENDIF.

    LOOP AT lt_kblp ASSIGNING FIELD-SYMBOL(<ls_kblp>).
      APPEND INITIAL LINE TO mt_alv_vein ASSIGNING FIELD-SYMBOL(<ls_alv>).
      MOVE-CORRESPONDING <ls_kblp> TO <ls_alv>.

      READ TABLE lt_kblk ASSIGNING FIELD-SYMBOL(<ls_kblk>) WITH TABLE KEY belnr = <ls_kblp>-belnr.
      IF sy-subrc = 0.
        <ls_alv>-waers = <ls_kblk>-waers.
      ENDIF.
    ENDLOOP.

    " filter by year
    IF p_gjahr IS NOT INITIAL.
      lv_begin = |{ p_gjahr }0101|.
      lv_end = |{ p_gjahr }1231|.
      DELETE mt_alv_vein WHERE erdat < lv_begin OR erdat > lv_end.
    ENDIF.


************************************************************************
*   Korrete Darstellung der FIPOS / FIPEX ermitteln. Wird durch den    *
*   Konvertierungsbaustein - OUTPUT der Domäne durchgeführt.           *
*   Das Ergebnis wird in eine FIPEX wegen der CHAR-Länge geschrieben   *
************************************************************************
    LOOP AT mt_alv_vein INTO ms_alv_vein.
      CLEAR ms_vein_pos.          "Eigener Struktur-Typ wegen der FIPEX
      MOVE-CORRESPONDING ms_alv_vein TO ms_vein_pos.
      CALL FUNCTION 'CONVERSION_EXIT_FMCIS_OUTPUT'
        EXPORTING
          input  = ms_vein_pos-fipos
        IMPORTING
          output = ms_vein_pos-fipex.
************************************************************************
*     Aus der FIPEX die Punkte entfernen. Wird wegen der Sortierung    *
*     benötigt.                                                        *
************************************************************************
      REPLACE ALL OCCURRENCES OF '.' IN ms_vein_pos-fipex WITH ' '.
      CONDENSE ms_vein_pos-fipex.
      APPEND ms_vein_pos TO mt_vein_pos.    "Datensatz merken
    ENDLOOP.

************************************************************************
*   Sortierung nach dem Fälligkeitsdatum unmd der Finanzposition       *
************************************************************************
    SORT mt_vein_pos BY fdatk fipex.

************************************************************************
*   Die Finanzposition auf die ersten 9 Stellen reduzieren             +
************************************************************************
    LOOP AT mt_vein_pos ASSIGNING <mf_pos>.
      <mf_pos>-fipex = <mf_pos>-fipex+0(9).
    ENDLOOP.

    CLEAR mt_alv_vein[].  "Alte Ausgabetabelle leeren

************************************************************************
*   Summierung manuel pro Fälligkeitstag und Finanuzposition           *
************************************************************************
    LOOP AT mt_vein_pos INTO ms_vein_pos.
      AT NEW fdatk.       "Fälligkeitsdatum Start
        CLEAR ms_alv_vein.
        MOVE  ms_vein_pos-fdatk TO ls_vein_pos-fdatk.
      ENDAT.

      MOVE: ms_vein_pos-fipos  TO ls_vein_pos-fipos,
            ms_vein_pos-belnr  TO ls_vein_pos-belnr,
            ms_vein_pos-blpos  TO ls_vein_pos-blpos,
            ms_vein_pos-erdat  TO ls_vein_pos-erdat,
            ms_vein_pos-erldat TO ls_vein_pos-erldat.
      AT NEW fipex.   "Finanzposition nach Convertierung
        CLEAR ms_alv_vein.
        MOVE: ls_vein_pos-fipos  TO ms_alv_vein-fipos,
              ls_vein_pos-belnr  TO ms_alv_vein-belnr,
              ls_vein_pos-blpos  TO ms_alv_vein-blpos,
              ls_vein_pos-erdat  TO ms_alv_vein-erdat,
              ls_vein_pos-erldat TO ms_alv_vein-erldat.
      ENDAT.

      ADD  ms_vein_pos-wtges TO ms_alv_vein-wtges.
      MOVE ms_vein_pos-waers TO ms_alv_vein-waers.

************************************************************************
*     Wenn sich die Finanzposition ändern, d.h. auch bei Fälligkeits-  *
*     datum, wird ein Summendatzensatz geschrieben.                    *
************************************************************************
      AT END OF fipex.
        IF p_gjahr IS NOT INITIAL.
          SELECT SINGLE text1 text2 text3 FROM fmcit
                 INTO ( ms_alv_vein-text1, ms_alv_vein-text2, ms_alv_vein-text3 )
                 WHERE spras EQ sy-langu
                 AND   gjahr EQ p_gjahr
                 AND   fipex EQ ms_vein_pos-fipex.
        ELSE.
          SELECT SINGLE text1 text2 text3 FROM fmcit
                 INTO ( ms_alv_vein-text1, ms_alv_vein-text2, ms_alv_vein-text3 )
                 WHERE spras EQ sy-langu
                 AND   fipex EQ ms_vein_pos-fipex.
        ENDIF.
        MOVE ls_vein_pos-fdatk TO ms_alv_vein-fdatk.
        APPEND ms_alv_vein TO mt_alv_vein.
      ENDAT.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_havwng_data.
    DATA: lt_tline TYPE TABLE OF tline.
    SELECT fmit~fikrs,
           fmit~ryear,
           substring( fmit~rfipex,1 ,9  ) AS rfipex,
           fmci~zz_fkz,
           fmci~zz_apl,
           rwrttp,
           SUM( CAST( hsl01 + hsl02 + hsl03 + hsl04 + hsl05 + hsl06 + hsl07 + hsl08 +
                      hsl09 + hsl10 + hsl11 + hsl12 + hsl13 + hsl14 + hsl15 + hsl16  AS DEC( 23, 2 ) ) ) AS sum
      FROM fmit
        LEFT JOIN fmci ON fmci~fikrs = fmit~fikrs  AND
                          fmci~gjahr = fmit~ryear  AND
                          fmci~fipex = fmit~rfipex
      WHERE rfonds  IN @so_fonds
         AND rfipex IN @so_fipex
         AND ryear  = @p_gjahr
         AND rldnr  = '9A'
         AND rrcty  = '0'
         AND rvers  = '000'
         AND rtcur  = 'EUR'
         AND rpmax  = '016'
         AND ( rwrttp = '57' OR rwrttp = '61' )
         AND ( fmci~hsart <> '3' AND fmci~hsart <> '4' )
         AND fmit~rstats = ''
      GROUP BY
           fmit~fikrs,
           fmit~ryear,
           substring( fmit~rfipex,1 ,9  ),
           rwrttp,
           fmci~zz_fkz,
           fmci~zz_apl
      INTO TABLE @DATA(lt_fmit).

    LOOP AT lt_fmit INTO DATA(ls_fmit).
      CHECK ls_fmit-rwrttp = '57' OR p_anzah IS NOT INITIAL.
      APPEND INITIAL LINE TO mt_alv_hvwng ASSIGNING FIELD-SYMBOL(<fs_alv_hvwng>).

      <fs_alv_hvwng>-fikrs    = ls_fmit-fikrs.
      <fs_alv_hvwng>-gjahr    = ls_fmit-ryear.
      <fs_alv_hvwng>-zz_fkz   = ls_fmit-zz_fkz.
      <fs_alv_hvwng>-betrag   = abs( ls_fmit-sum ). "+ ls_fmit-sum2.
      <fs_alv_hvwng>-flagapl  = COND #( WHEN  ls_fmit-zz_apl IS NOT INITIAL THEN '1'
                                        ELSE '0' ).

      CALL FUNCTION 'CONVERSION_EXIT_FIPOS_OUTPUT'
        EXPORTING
          input  = ls_fmit-rfipex
        IMPORTING
          output = <fs_alv_hvwng>-fipex.

      CLEAR lt_tline.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id              = 'FP01'
          language        = sy-langu
          name            = CONV tdobname( ls_fmit-fikrs && ls_fmit-ryear && ls_fmit-rfipex )
          object          = 'FMMD'
        TABLES
          lines           = lt_tline
        EXCEPTIONS
          id              = 1
          language        = 2
          name            = 3
          not_found       = 4
          object          = 5
          reference_check = 6
          wrong_access    = 7
          OTHERS          = 8.
      IF sy-subrc = 0.
        LOOP AT lt_tline INTO DATA(ls_tline).
          <fs_alv_hvwng>-bezeichnung = <fs_alv_hvwng>-bezeichnung && ls_tline-tdline.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_vein_header.
    DATA: ls_ve_map TYPE /thkr/s_ve_header.

    SELECT SINGLE * FROM /thkr/db_ve_map INTO ls_ve_map
           WHERE feldname EQ iv_name
           AND   appl     EQ iv_appl
           AND   langu    EQ sy-langu.
    IF 0 EQ sy-subrc.
      MOVE ls_ve_map-mapname+0(ls_ve_map-ausglaenge) TO rv_name.
    ENDIF.
*    CASE iv_name.
*      WHEN 'GJAHR'.
*        MOVE TEXT-vh1 TO rv_name.
*      WHEN 'FIPEX'.
*        MOVE TEXT-vh2 TO rv_name.
*      WHEN 'BEZEICHNUNG'.
*        MOVE TEXT-vh3 TO rv_name.
*      WHEN 'ZZ_FKZ'.
*        MOVE TEXT-vh4 TO rv_name.
*      WHEN 'BETRAG'.
*        MOVE TEXT-vh5 TO rv_name.
*      WHEN 'FLAGAPL'.
*        MOVE TEXT-vh6 TO rv_name.
*      WHEN OTHERS.
*        MOVE iv_name TO rv_name.
*    ENDCASE.
  ENDMETHOD.


  METHOD file_save.
    CHECK p_save IS NOT INITIAL.
    CASE abap_true.
      WHEN p_pers.
        save_persokh( ).
      WHEN p_havw.
        save_havweb( ).
      WHEN p_vein.
        save_vein( ).
      WHEN p_havwng.
        save_havwng( ).
    ENDCASE.
  ENDMETHOD.


  METHOD save_persokh.
    DATA: "lt_pers_data     TYPE tt_persokh_data,
      "lt_pers_data  TYPE tt_csv_persokh_data,
      lt_pers_data  TYPE tt_havweb_data,
      lt_csv_output TYPE truxs_t_text_data,
      ls_header     LIKE LINE OF lt_csv_output,
      lr_t_data     TYPE REF TO cl_abap_tabledescr,
      lr_s_data     TYPE REF TO cl_abap_structdescr.

    LOOP AT mt_alv ASSIGNING FIELD-SYMBOL(<ls_alv>).
      APPEND INITIAL LINE TO lt_pers_data ASSIGNING FIELD-SYMBOL(<ls_pers>).
      MOVE-CORRESPONDING <ls_alv> TO <ls_pers>.
      <ls_pers>-bezeichnung = |{ <ls_alv>-text1 }{ <ls_alv>-text2 }{ <ls_alv>-text3 }|.
      <ls_pers>-finpos = |{ <ls_alv>-kapitel }.{ <ls_alv>-titel }|.

*      IF p_monat IS INITIAL.
*        <ls_pers>-monat = <ls_alv>-gjahr.
*      ENDIF.
*      CONDENSE <ls_pers>-trbtr NO-GAPS.
*      CALL FUNCTION 'CONVERSION_EXIT_ZSIGN_OUTPUT'
*        EXPORTING
*          input  = <ls_pers>-trbtr
*        IMPORTING
*          output = <ls_pers>-trbtr.
    ENDLOOP.

    CALL FUNCTION 'SAP_CONVERT_TO_CSV_FORMAT'
      EXPORTING
*       i_field_seperator    = ';'
        i_line_header        = abap_true
      TABLES
        i_tab_sap_data       = lt_pers_data
      CHANGING
        i_tab_converted_data = lt_csv_output
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    " add header
    lr_t_data ?= cl_abap_typedescr=>describe_by_data( lt_pers_data ).
    lr_s_data ?= lr_t_data->get_table_line_type( ).
    IF lines( lt_csv_output ) > 0.
      lt_csv_output[ 1 ] = 'Jahr;Haushaltsstelle;Titelbezeichnung;Funktionsziffer;Betrag;FlagAPL'.
    ENDIF.

*    LOOP AT lr_s_data->components ASSIGNING FIELD-SYMBOL(<ls_comp>).
*      IF <ls_comp>-name EQ TEXT-c05.
*        ls_header = |{ ls_header };{ TEXT-u01 }|.
*      ELSE.
*        ls_header = |{ ls_header };{ <ls_comp>-name }|.
*      ENDIF.
*    ENDLOOP.
    SHIFT ls_header BY 1 PLACES LEFT IN CHARACTER MODE.
    INSERT ls_header INTO lt_csv_output INDEX 1.

    create_file( CHANGING ct_text_data = lt_csv_output ).
  ENDMETHOD.


  METHOD save_havweb.
    DATA: lt_havw_data  TYPE tt_havweb_data,
          lt_csv_output TYPE truxs_t_text_data.

    LOOP AT mt_alv ASSIGNING FIELD-SYMBOL(<ls_alv>).
      APPEND INITIAL LINE TO lt_havw_data ASSIGNING FIELD-SYMBOL(<ls_havw>).
      MOVE-CORRESPONDING <ls_alv> TO <ls_havw>.
      <ls_havw>-finpos = |{ <ls_alv>-kapitel }.{ <ls_alv>-titel }|.
      <ls_havw>-bezeichnung = |{ <ls_alv>-text1 }{ <ls_alv>-text2 }{ <ls_alv>-text3 }|.
      IF <ls_alv>-unplan IS INITIAL.
        MOVE '0' TO <ls_havw>-unplan.
      ENDIF.
    ENDLOOP.
    convert_table_to_csv( EXPORTING it_table     = lt_havw_data
                                    iv_separator = ';'
                          IMPORTING et_csv       = lt_csv_output ).
    IF lines( lt_csv_output ) > 0.
      lt_csv_output[ 1 ] = 'Jahr;Haushaltsstelle;Titelbezeichnung;Funktionsziffer;Betrag;FlagAPL'.
    ENDIF.
    create_file( CHANGING ct_text_data = lt_csv_output ).
  ENDMETHOD.

  METHOD save_havwng.
    DATA: lt_csv_output  TYPE truxs_t_text_data.
    DATA: lt_havwng_data TYPE tt_havweb_ng_data.

    LOOP AT mt_alv_hvwng INTO DATA(ls_hvwng).
      APPEND CORRESPONDING #( ls_hvwng ) TO lt_havwng_data.
    ENDLOOP.
    convert_table_to_csv( EXPORTING it_table     = lt_havwng_data
                                    iv_separator = ';'
                          IMPORTING et_csv       = lt_csv_output ).
** The headline is wrong because the data element descrption is used, replace it here:
    IF lines( lt_csv_output ) > 0.
      lt_csv_output[ 1 ] = 'Jahr;Haushaltsstelle;Titelbezeichnung;Funktionsziffer;Betrag;FlagAPL'.
    ENDIF.
    create_file( CHANGING ct_text_data = lt_csv_output ).
  ENDMETHOD.

  METHOD save_vein.
    DATA: lt_vein_data  TYPE tt_alv_vaus,
          lt_csv_output TYPE truxs_t_text_data,
          ls_header     LIKE LINE OF lt_csv_output,
          lr_t_data     TYPE REF TO cl_abap_tabledescr,
          lr_s_data     TYPE REF TO cl_abap_structdescr,
          lt_col_vaus   TYPE tt_col_vaus,
          ls_col_vaus   TYPE ts_col_vaus.

    LOOP AT mt_alv_vein ASSIGNING FIELD-SYMBOL(<ls_col>).
      MOVE-CORRESPONDING <ls_col> TO ls_col_vaus.
      IF ls_col_vaus-erldat IS INITIAL.
        MOVE <ls_col>-erdat TO ls_col_vaus-erldat.
      ENDIF.

      ls_col_vaus-fipex = |{ <ls_col>-fipos(4) }.{ <ls_col>-fipos+4(5) }|.
      COLLECT ls_col_vaus INTO lt_col_vaus.
    ENDLOOP.

*    LOOP AT mt_alv_vein ASSIGNING FIELD-SYMBOL(<ls_alv>).
*      APPEND INITIAL LINE TO lt_vein_data ASSIGNING FIELD-SYMBOL(<ls_vein>).
*      MOVE-CORRESPONDING <ls_alv> TO <ls_vein>.
*      IF <ls_vein>-erldat IS INITIAL.
*        MOVE <ls_alv>-erdat TO <ls_vein>-erldat.
*      ENDIF.
*
*      <ls_vein>-fipex = |{ <ls_alv>-fipos(4) }.{ <ls_alv>-fipos+4(5) }|.
*      REPLACE ',' IN <ls_vein>-wtges WITH ''.
*      CONDENSE <ls_vein>-wtges NO-GAPS.
*    ENDLOOP.

    LOOP AT lt_col_vaus INTO ls_col_vaus.
      APPEND INITIAL LINE TO lt_vein_data ASSIGNING FIELD-SYMBOL(<ls_vein>).
      MOVE-CORRESPONDING ls_col_vaus TO <ls_vein>.
      REPLACE ',' IN <ls_vein>-wtges WITH ''.
      CONDENSE <ls_vein>-wtges NO-GAPS.
    ENDLOOP.

    CALL FUNCTION 'SAP_CONVERT_TO_CSV_FORMAT'
      EXPORTING
*       i_field_seperator    = ';'
        i_line_header        = abap_true
      TABLES
        i_tab_sap_data       = lt_vein_data
      CHANGING
        i_tab_converted_data = lt_csv_output
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    " add header
    lr_t_data ?= cl_abap_typedescr=>describe_by_data( lt_vein_data ).
    lr_s_data ?= lr_t_data->get_table_line_type( ).
    LOOP AT lr_s_data->components ASSIGNING FIELD-SYMBOL(<ls_comp>).
*      ls_header = |{ ls_header };{ <ls_comp>-name }|.
      ls_header = |{ ls_header };{ get_vein_header( iv_name = <ls_comp>-name iv_appl = 'VE' ) }|.
    ENDLOOP.
    SHIFT ls_header BY 1 PLACES LEFT IN CHARACTER MODE.
    INSERT ls_header INTO lt_csv_output INDEX 1.

    create_file( CHANGING ct_text_data = lt_csv_output ).
  ENDMETHOD.

  METHOD create_file.
    CASE abap_true.
      WHEN p_local.
        " saving to Local PC
        TRY.
            cl_gui_frontend_services=>gui_download( EXPORTING filename = CONV #( p_path )
                                                              filetype = 'ASC'
                                                              codepage = '4110'
                                                    CHANGING  data_tab = ct_text_data ).
          CATCH cx_root INTO DATA(e_text).
            MESSAGE e_text->get_text( ) TYPE 'I'.
        ENDTRY.
      WHEN p_appse.
        " saving to Application Server
        OPEN DATASET p_path FOR OUTPUT IN TEXT MODE ENCODING UTF-8.

        LOOP AT ct_text_data ASSIGNING FIELD-SYMBOL(<ls_text_data>).
          TRANSFER <ls_text_data> TO p_path.
        ENDLOOP.

        CLOSE DATASET p_path.
    ENDCASE.
  ENDMETHOD.

  METHOD convert_table_to_csv.
    DATA: lt_components TYPE abap_component_tab,
          lv_line       TYPE string,
          lt_dfies      TYPE TABLE OF dfies.

    FIELD-SYMBOLS: <fs_line>  TYPE any,
                   <fs_field> TYPE any.

    DATA(lr_t_data) = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data( it_table ) ).
    DATA(lr_s_data) = CAST cl_abap_structdescr( lr_t_data->get_table_line_type( ) ).
    lt_components = lr_s_data->get_components( ).

    DATA(lt_symbols) = lr_s_data->get_symbols( ).
    LOOP AT lt_symbols ASSIGNING FIELD-SYMBOL(<ls_comp>).
      DATA(lo_elem_descr) = CAST cl_abap_elemdescr( <ls_comp>-type ).
      lv_line = |{ lv_line }{ COND #( WHEN lv_line IS INITIAL THEN '' ELSE iv_separator ) }{ lo_elem_descr->get_ddic_field( )-scrtext_l }|.
    ENDLOOP.
    APPEND lv_line TO et_csv.

    LOOP AT it_table ASSIGNING <fs_line>.
      CLEAR lv_line.
      LOOP AT lt_components INTO DATA(ls_component).
        ASSIGN COMPONENT ls_component-name OF STRUCTURE <fs_line> TO <fs_field>.
        DATA(lv_value) = COND string(
          WHEN sy-subrc = 0 THEN
            COND string(
              WHEN CAST cl_abap_elemdescr( lr_s_data->get_component_type( ls_component-name ) )->type_kind CA 'IPF'
               AND <fs_field> < 0
              THEN |-{ abs( <fs_field> ) }|
              ELSE |{ <fs_field> }| )
          ELSE '' ).

        lv_value = replace( val = lv_value sub = '"' with = '""' occ = 0 ).
        IF lv_value CA iv_separator OR lv_value CA '"'.
          lv_value = |"{ lv_value }"|.
        ENDIF.

        lv_line = |{ lv_line }{ COND #( WHEN lv_line IS INITIAL THEN '' ELSE iv_separator ) }{ lv_value }|.
      ENDLOOP.
      APPEND lv_line TO et_csv.
    ENDLOOP.
  ENDMETHOD.


  METHOD f4_path.
    DATA: lv_location_flag TYPE dxfields-location,
          lv_action        TYPE i,
          lv_filename      TYPE string,
          lv_fullpath      TYPE string,
          lv_path          TYPE string.

    CASE abap_true.
      WHEN p_local.
        cl_gui_frontend_services=>file_save_dialog(
          EXPORTING
            default_extension = 'csv'
          CHANGING
            filename          = lv_filename
            path              = lv_path
            fullpath          = lv_fullpath
            user_action       = lv_action
          EXCEPTIONS
            OTHERS            = 99 ).
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ELSE.
          IF lv_action EQ cl_gui_frontend_services=>action_ok.
            p_path = lv_fullpath.
          ENDIF.
        ENDIF.

      WHEN p_appse.
*        lv_location_flag = 'A'.
*        CALL FUNCTION 'F4_DXFILENAME_TOPRECURSION'
*          EXPORTING
*            i_location_flag = lv_location_flag
*            i_server        = ''
*            i_path          = p_path
*            filemask        = ''
*          IMPORTING
*            o_location_flag = lv_location_flag
**           o_server        = ''
*            o_path          = p_path
**           ABEND_FLAG      =
*          EXCEPTIONS
*            rfc_error       = 1
*            error_with_gui  = 2
*            OTHERS          = 3.

        CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
*          EXPORTING
*            directory        = ' '
*            filemask         = ' '
          IMPORTING
            serverfile       = p_path
          EXCEPTIONS
            canceled_by_user = 1
            OTHERS           = 2.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
    ENDCASE.

  ENDMETHOD.


  METHOD screen_check.
    IF sy-ucomm = 'FLS'.
      FREE: p_path.
    ENDIF.

    IF sy-ucomm = 'TMS'.
      FREE: p_monat.
    ENDIF.

    IF p_save = abap_true AND p_path IS INITIAL.
      MESSAGE TEXT-e01 TYPE 'E'.
      EXIT.
    ENDIF.

    IF p_gjahr IS INITIAL AND p_vein IS INITIAL.
      MESSAGE TEXT-e02 TYPE 'E'.
      EXIT.
    ENDIF.
  ENDMETHOD.


  METHOD display.
    DATA: lo_functions  TYPE REF TO cl_salv_functions,
          lo_display    TYPE REF TO cl_salv_display_settings,
          lo_layout     TYPE REF TO cl_salv_layout,
          lo_columns    TYPE REF TO cl_salv_columns_table,
          lo_column     TYPE REF TO cl_salv_column_table,
          lo_events     TYPE REF TO cl_salv_events_table,
          lo_selections TYPE REF TO cl_salv_selections.
    DATA: key            TYPE salv_s_layout_key,
          lt_columns     TYPE salv_t_column_ref,
          ls_columns     TYPE salv_s_column_ref,
          lv_short_text  TYPE scrtext_s,
          lv_medium_text TYPE scrtext_m,
          lv_long_text   TYPE scrtext_l,
          lv_variant     TYPE slis_vari.

    TRY.
        CASE abap_true.
          WHEN p_pers OR p_havw.
            cl_salv_table=>factory( IMPORTING r_salv_table = mo_table
                                    CHANGING  t_table      = mt_alv ).
          WHEN p_havwng.
            cl_salv_table=>factory( IMPORTING r_salv_table = mo_table
                                    CHANGING  t_table      = mt_alv_hvwng ).
          WHEN p_vein.
            cl_salv_table=>factory( IMPORTING r_salv_table = mo_table
                                    CHANGING  t_table      = mt_alv_vein ).
        ENDCASE.

        lo_functions = mo_table->get_functions( ).
        lo_functions->set_all( abap_true ).

        lo_columns = mo_table->get_columns( ).
        lo_columns->set_optimize( abap_true ).

        REFRESH lt_columns.
        CLEAR ls_columns.
        lt_columns = lo_columns->get(  ).
        LOOP AT lt_columns INTO ls_columns.
          TRY.
              lo_column ?= lo_columns->get_column( ls_columns-columnname ).
              CASE ls_columns-columnname.
                WHEN 'KAPITEL'.
                  lv_short_text  = TEXT-c01.
                  lv_medium_text = TEXT-c01.
                  lv_long_text   = TEXT-c01.
                  lo_column->set_short_text( lv_short_text ).
                  lo_column->set_medium_text( lv_medium_text ).
                  lo_column->set_long_text( lv_long_text ).
                WHEN 'TITEL'.
                  lv_short_text  = TEXT-c02.
                  lv_medium_text = TEXT-c02.
                  lv_long_text   = TEXT-c02.
                  lo_column->set_short_text( lv_short_text ).
                  lo_column->set_medium_text( lv_medium_text ).
                  lo_column->set_long_text( lv_long_text ).
                WHEN 'MONAT'.
                  lv_short_text  = TEXT-c03.
                  lv_medium_text = TEXT-c03.
                  lv_long_text   = TEXT-c03.
                  lo_column->set_short_text( lv_short_text ).
                  lo_column->set_medium_text( lv_medium_text ).
                  lo_column->set_long_text( lv_long_text ).
                WHEN 'UNPLAN'.
                  lv_short_text  = TEXT-c04.
                  lv_medium_text = TEXT-c04.
                  lv_long_text   = TEXT-c04.
                  lo_column->set_short_text( lv_short_text ).
                  lo_column->set_medium_text( lv_medium_text ).
                  lo_column->set_long_text( lv_long_text ).
              ENDCASE.
            CATCH cx_salv_not_found.
              CONTINUE.
          ENDTRY.
        ENDLOOP.

        lo_selections = mo_table->get_selections( ).
        lo_selections->set_selection_mode( if_salv_c_selection_mode=>cell ).

        lo_display = mo_table->get_display_settings( ).
        lo_display->set_striped_pattern( cl_salv_display_settings=>true ).
        lo_display->set_list_header( TEXT-t01 ).

        lo_layout = mo_table->get_layout( ).
        key-report = sy-repid.
        lo_layout->set_key( key ).
        lo_layout->set_save_restriction( cl_salv_layout=>restrict_none ).
        lo_layout->set_default( cl_salv_layout=>true ).
        IF p_vein IS NOT INITIAL.
          SELECT SINGLE variant FROM ltdx INTO lv_variant
                       WHERE relid   EQ 'LT'
                       AND   report  EQ sy-repid
                       AND   variant EQ '/FB_TEST'.
          IF 0 EQ sy-subrc.
            lo_layout->set_initial_layout( lv_variant ).
          ENDIF.
        ENDIF.

        mo_table->display( ).
      CATCH cx_salv_msg INTO DATA(lo_salv_msg).
        DATA(lv_msg) = lo_salv_msg->get_text( ).
        MESSAGE lv_msg TYPE 'E'.
      CATCH cx_salv_not_found.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
