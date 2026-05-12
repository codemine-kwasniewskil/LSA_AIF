*&---------------------------------------------------------------------*
*& Report /THKR/FI_CHK_AO_DATA
*&---------------------------------------------------------------------*
*& Beschreibung:                                                       *
*&                                                                     *
*& Prüfreport: Inkorrekt hinterlegte Geschäftpartner-Namen             *
*&---------------------------------------------------------------------*
*& Autor:       Joemar Lang (OREXES GmbH)                              *
*& Anlage:      03.02.2026                                             *
*& Transaktion: /THKR/ZCHK_GP_NAME                                     *
*&---------------------------------------------------------------------*
REPORT /THKR/FI_CHK_GP_NAME.
  TYPES:
  BEGIN OF lty_data,
    partner TYPE but000-partner,
    type TYPE but000-type,
    snd_id TYPE sepa_mandate-snd_id,
    name_org1 TYPE but000-name_org1,
    name_last TYPE but000-name_last,
    name_grp1 TYPE but000-name_grp1,
  END OF lty_data,

  BEGIN OF lty_outtab,
    zeile TYPE i,
    partner TYPE but000-partner,
    type TYPE but000-type,
    name_diff1 TYPE i,
    name_diff2 TYPE i,
    name_diff3 TYPE i,
    name_diff4 TYPE i,
    max_len1 TYPE i,
    max_len2 TYPE i,
    max_len3 TYPE i,
    max_len4 TYPE i,
  END OF lty_outtab.

DATA: lv_zeile TYPE i VALUE 0.
DATA: ls_outtab TYPE lty_outtab.
DATA: lt_outtab TYPE TABLE OF lty_outtab.
DATA: lv_butname TYPE c LENGTH 40.
DATA: lt_data TYPE TABLE OF lty_data.
DATA: lo_alv TYPE REF TO cl_salv_table.
DATA: lo_columns TYPE REF TO cl_salv_columns.
DATA: lo_column TYPE REF TO cl_salv_column.
DATA: lo_aggregations TYPE REF TO cl_salv_aggregations.
DATA: lx_exc TYPE REF TO cx_root.
FIELD-SYMBOLS: <ls_data> TYPE lty_data.

*----------------------------------------------------------------------*
* Start der Programmverarbeitung                                       *
*----------------------------------------------------------------------*
START-OF-SELECTION.
TRY.
*----------------------------------------------------------------------*
* Geschäftspartner-Namen ermitteln                                     *
*----------------------------------------------------------------------*
  SELECT DISTINCT partner, type, name_org1, name_last, name_grp1
  FROM but000
  INTO CORRESPONDING FIELDS OF TABLE @lt_data.
  IF sy-subrc IS INITIAL.
*----------------------------------------------------------------------*
* ID für den SEPA Mandate ergänzen                                     *
*----------------------------------------------------------------------*
    LOOP AT lt_data ASSIGNING <ls_data>.
      <ls_data>-snd_id = <ls_data>-partner.
    ENDLOOP.
*----------------------------------------------------------------------*
* Namen in den SEPA Mandaten ermitteln                                 *
*----------------------------------------------------------------------*
    SELECT snd_id, snd_name1
    FROM sepa_mandate
    FOR ALL ENTRIES IN @lt_data
    WHERE snd_id = @lt_data-snd_id
    INTO TABLE @DATA(lt_sepa_data).
*----------------------------------------------------------------------*
* Namen in den Migrations-Daten ermitteln                              *
*----------------------------------------------------------------------*
    SELECT a~satz_id, a~partner, b~mandatgebername, c~namezeile1
    FROM /thkr/mig_ao_sap
    AS a
    INNER JOIN /thkr/migdao AS b ON b~satz_id = a~satz_id
    INNER JOIN /thkr/migdzp AS c ON c~satz_id = a~satz_id
    FOR ALL ENTRIES IN @lt_data
    WHERE a~partner = @lt_data-partner
    INTO TABLE @DATA(lt_import_data).
*----------------------------------------------------------------------*
* Namen überprüfen                                                     *
*----------------------------------------------------------------------*
    LOOP AT lt_data ASSIGNING <ls_data>.
      lv_zeile = lv_zeile + 1.
      CLEAR: lv_butname, ls_outtab.
      ls_outtab-zeile = lv_zeile.
      ls_outtab-partner = <ls_data>-partner.
      CASE <ls_data>-type.
      WHEN '1'.
        lv_butname = <ls_data>-name_last.
      WHEN '2'.
        lv_butname = <ls_data>-name_org1.
      WHEN '3'.
        lv_butname = <ls_data>-name_grp1.
      ENDCASE.
      ls_outtab-type = <ls_data>-type.
*----------------------------------------------------------------------*
* GP-Namen überprüfen auf max. Länge                                   *
*----------------------------------------------------------------------*
     IF strlen( lv_butname ) EQ 40.
       ls_outtab-max_len1 = 1.
     ENDIF.
*----------------------------------------------------------------------*
* Namen überprüfen (gegen SEPA Mandate)                                *
*----------------------------------------------------------------------*
      LOOP AT lt_sepa_data
      ASSIGNING FIELD-SYMBOL(<ls_sepa_data>)
      WHERE snd_id = <ls_data>-snd_id.
        IF lv_butname <> <ls_sepa_data>-snd_name1.
          ls_outtab-name_diff1 = 1.
        ENDIF.
*----------------------------------------------------------------------*
* SEPA-Namen überprüfen auf max. Länge                                 *
*----------------------------------------------------------------------*
        IF strlen( <ls_sepa_data>-snd_name1 ) EQ 40.
          ls_outtab-max_len2 = 1.
        ENDIF.
      ENDLOOP.
*----------------------------------------------------------------------*
* Namen überprüfen (gegen Import + Import intern)                      *
*----------------------------------------------------------------------*
      LOOP AT lt_import_data
      ASSIGNING FIELD-SYMBOL(<ls_import_data>)
      WHERE partner = <ls_data>-partner.
        IF lv_butname <> <ls_import_data>-mandatgebername.
          ls_outtab-name_diff2 = 1.
        ENDIF.
        IF lv_butname <> <ls_import_data>-namezeile1.
          ls_outtab-name_diff3 = 1.
        ENDIF.
        IF <ls_import_data>-mandatgebername <> <ls_import_data>-namezeile1.
          ls_outtab-name_diff4 = 1.
        ENDIF.
*----------------------------------------------------------------------*
* Import-Namen überprüfen auf max. Länge                               *
*----------------------------------------------------------------------*
        IF strlen( <ls_import_data>-mandatgebername ) GT 40.
          ls_outtab-max_len3 = 1.
        ENDIF.
*----------------------------------------------------------------------*
* Import-Namen überprüfen auf max. Länge                               *
*----------------------------------------------------------------------*
        IF strlen( <ls_import_data>-namezeile1 ) GT 40.
          ls_outtab-max_len4 = 1.
        ENDIF.
      ENDLOOP.
      APPEND ls_outtab TO lt_outtab.
    ENDLOOP.
*----------------------------------------------------------------------*
* SALV erzeugen                                                        *
*----------------------------------------------------------------------*
   cl_salv_table=>factory(
     IMPORTING
       r_salv_table = lo_alv
     CHANGING
       t_table      = lt_outtab
   ).
*----------------------------------------------------------------------*
* Spaltenbezeichnung ergänzen                                          *
*----------------------------------------------------------------------*
   lo_aggregations = lo_alv->get_aggregations( ).
   lo_columns = lo_alv->get_columns( ).
   lo_column = lo_columns->get_column( 'ZEILE' ).
   lo_column->set_long_text('Zeile').
   lo_column = lo_columns->get_column( 'NAME_DIFF1' ).
   lo_column->set_long_text('Diff: GP-SEPA').
   lo_aggregations->add_aggregation( columnname = 'NAME_DIFF1' aggregation = if_salv_c_aggregation=>total ).
   lo_column = lo_columns->get_column( 'NAME_DIFF2' ).
   lo_column->set_long_text('Diff: GP-AO-Import').
   lo_aggregations->add_aggregation( columnname = 'NAME_DIFF2' aggregation = if_salv_c_aggregation=>total ).
   lo_column = lo_columns->get_column( 'NAME_DIFF3' ).
   lo_column->set_long_text('Diff: GP-ZP-Import').
   lo_aggregations->add_aggregation( columnname = 'NAME_DIFF3' aggregation = if_salv_c_aggregation=>total ).
   lo_column = lo_columns->get_column( 'NAME_DIFF4' ).
   lo_column->set_long_text('Diff: AO-ZP-Import').
   lo_aggregations->add_aggregation( columnname = 'NAME_DIFF4' aggregation = if_salv_c_aggregation=>total ).
   lo_column = lo_columns->get_column( 'MAX_LEN1' ).
   lo_column->set_long_text('Max. Länge: GP-Name').
   lo_aggregations->add_aggregation( columnname = 'MAX_LEN1' aggregation = if_salv_c_aggregation=>total ).
   lo_column = lo_columns->get_column( 'MAX_LEN2' ).
   lo_column->set_long_text('Max. Länge: SEPA-Name').
   lo_aggregations->add_aggregation( columnname = 'MAX_LEN2' aggregation = if_salv_c_aggregation=>total ).
   lo_column = lo_columns->get_column( 'MAX_LEN3' ).
   lo_column->set_long_text('Max. Länge: AO-Import-Name').
   lo_aggregations->add_aggregation( columnname = 'MAX_LEN3' aggregation = if_salv_c_aggregation=>total ).
   lo_column = lo_columns->get_column( 'MAX_LEN4' ).
   lo_column->set_long_text('Max. Länge: ZP-Import-Name').
   lo_aggregations->add_aggregation( columnname = 'MAX_LEN4' aggregation = if_salv_c_aggregation=>total ).
   lo_aggregations->set_aggregation_before_items( abap_true ).
*----------------------------------------------------------------------*
* SALV Einstellungen                                                   *
*----------------------------------------------------------------------*
   " Standard-Funktionen (Sortieren, Filtern, Excel-Export etc.) aktivieren
   lo_alv->get_functions( )->set_all( abap_true ).
   " Spaltentitel optimieren (automatische Breite)
   lo_alv->get_columns( )->set_optimize( abap_true ).
   " Titel der Liste setzen
   lo_alv->get_display_settings( )->set_list_header( 'Prüfung: Geschäftspartner-Namen' ).
   lo_alv->get_display_settings( )->set_striped_pattern( abap_true ).
   " 3. Anzeige
   lo_alv->display( ).
  ENDIF.
  CATCH cx_salv_existing INTO lx_exc.
  CATCH cx_salv_data_error INTO lx_exc.
  CATCH cx_salv_msg INTO lx_exc.
  CATCH cx_salv_not_found INTO lx_exc.
ENDTRY.
