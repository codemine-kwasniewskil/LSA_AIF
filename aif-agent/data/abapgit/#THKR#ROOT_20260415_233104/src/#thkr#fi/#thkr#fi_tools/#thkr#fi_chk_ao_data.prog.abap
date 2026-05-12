*&---------------------------------------------------------------------*
*& Report /THKR/FI_CHK_AO_DATA
*&---------------------------------------------------------------------*
*& Beschreibung:                                                       *
*&                                                                     *
*& Prüfreport für den Schnittstellenimport von Auszahlungsanordnungen  *
*& Der Report soll Abweichungen zwischen der bereitgestellten Import   *
*& Datei und den im SAP verbuchten Auszahlungsanordnungen              *
*& identifizieren                                                      *
*&---------------------------------------------------------------------*
*& Autor:       Joemar Lang (OREXES GmbH)                              *
*& Anlage:      03.02.2026                                             *
*& Transaktion: /THKR/ZCHK_AO_DATA                                     *
*&---------------------------------------------------------------------*
REPORT /THKR/FI_CHK_AO_DATA.
  TYPES:
  BEGIN OF lty_data,
    iban TYPE bu_iban,
    gjahr TYPE gjahr,
    cpudt	TYPE cpudt,
    wrbtr	TYPE wrbtr,
    wrbtr2 TYPE wrbtr,
    diff TYPE abap_bool,
  END OF lty_data.
*----------------------------------------------------------------------*
* Datendeklaration                                                     *
*----------------------------------------------------------------------*
DATA: go_reproc TYPE REF TO /thkr/cl_aif_reproc.
DATA: gs_xmlparse TYPE /aif/xmlparse_data.
DATA: lx_exc TYPE REF TO cx_root.
DATA: ls_data TYPE lty_data.
DATA: lt_data TYPE TABLE OF lty_data.
DATA: lv_idx_tab TYPE /aif/msg_tbl.
DATA: lt_msg_tab TYPE TABLE OF guid_32.
DATA: lv_guid TYPE guid_32.
DATA: lt_data2 TYPE TABLE OF /thkr/db_iban_s.
DATA: lo_alv TYPE REF TO cl_salv_table.
DATA: lo_columns TYPE REF TO cl_salv_columns.
DATA: lo_column TYPE REF TO cl_salv_column.

FIELD-SYMBOLS: <lf_field> TYPE clike,
               <lf_data> TYPE lty_data.
*----------------------------------------------------------------------*
* Selektionsbild                                                       *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.
  PARAMETERS: p_ns  TYPE /aif/ns OBLIGATORY.
  PARAMETERS: p_ifname TYPE /aif/ifname OBLIGATORY.
  PARAMETERS: p_ifvers TYPE /aif/ifversion OBLIGATORY.
  SELECT-OPTIONS: so_msg FOR lv_guid NO INTERVALS.
  PARAMETERS: p_cpudt  TYPE cpudt OBLIGATORY.
  PARAMETERS: p_sst    TYPE /thkr/dte_bu_sst OBLIGATORY MATCHCODE OBJECT /thkr/aif_sst.
SELECTION-SCREEN END OF BLOCK b01.
************************************************************************
* Initialisierung des Programms                                        *
************************************************************************
INITIALIZATION.
************************************************************************
* Initialisierung Selektions-Title                                     *
************************************************************************
  p_ns = 'FREMDV'.
  p_ifname = 'I_0031_001'.
  p_ifvers = '00001'.
  p_cpudt  = sy-datum - 1.
*----------------------------------------------------------------------*
* Start der Programmverarbeitung                                       *
*----------------------------------------------------------------------*
START-OF-SELECTION.
TRY.
*----------------------------------------------------------------------*
* Start der Programmverarbeitung                                       *
*----------------------------------------------------------------------*
  SELECT SINGLE msg_tbl
  FROM /aif/t_inf_tbl
  WHERE ns = @p_ns
  AND ifname = @p_ifname
  AND ifver = @p_ifvers
  INTO @lv_idx_tab.
  IF sy-subrc = 0.
"Eintrag gefunden, allerdings keine Single-Index-Tabelle hinterlegt.
"Verwendung der Standard-Index-Tabelle
    IF lv_idx_tab IS INITIAL.
      lv_idx_tab = '/AIF/STD_IDX_TBL'.
    ENDIF.
  ELSE.
"keinen Eintrag gefunden
"Verwendung der Standard-Index Tabelle
    lv_idx_tab = '/AIF/STD_IDX_TBL'.
  ENDIF.

  SELECT DISTINCT msgguid
  FROM (lv_idx_tab)
  WHERE ns = @p_ns
  AND ifname = @p_ifname
  AND ifver = @p_ifvers
  AND msgguid IN @so_msg
  AND create_date = @p_cpudt
  INTO TABLE @lt_msg_tab.

  go_reproc = NEW /thkr/cl_aif_reproc( ).

  LOOP AT lt_msg_tab ASSIGNING FIELD-SYMBOL(<ls_msg>).
    go_reproc->set_aif_properties(
    iv_ns       = p_ns
    iv_ifname   = p_ifname
    iv_ifvers   = p_ifvers
    iv_msg_guid = CONV /aif/sxmssmguid( <ls_msg> )
    ).
    gs_xmlparse = go_reproc->get_aif_message( ).
    ASSIGN gs_xmlparse-xi_data->* TO FIELD-SYMBOL(<ls_data>).

    ASSIGN COMPONENT 'LINE' OF STRUCTURE <ls_data> TO FIELD-SYMBOL(<lt_table>).
    IF sy-subrc IS INITIAL.
    LOOP AT <lt_table> ASSIGNING FIELD-SYMBOL(<ls_line>).
      CLEAR ls_data.
      ASSIGN COMPONENT '65_IBAN' OF STRUCTURE <ls_line> TO <lf_field>.
      IF sy-subrc IS INITIAL.
        IF <lf_field> IS NOT INITIAL.
          ls_data-iban = <lf_field>.
        ENDIF.
      ENDIF.
      ASSIGN COMPONENT '04_HHJ' OF STRUCTURE <ls_line> TO <lf_field>.
      IF sy-subrc IS INITIAL.
        IF <lf_field> IS NOT INITIAL.
          ls_data-gjahr = <lf_field>.
        ENDIF.
      ENDIF.
      ASSIGN COMPONENT '15_BETR1' OF STRUCTURE <ls_line> TO <lf_field>.
      IF sy-subrc IS INITIAL.
        IF <lf_field> IS NOT INITIAL.
          ls_data-wrbtr = <lf_field>.
          ls_data-wrbtr = ls_data-wrbtr / 100.
        ENDIF.
      ENDIF.
      ls_data-cpudt = p_cpudt.
      IF ls_data-iban IS NOT INITIAL AND ls_data-wrbtr IS NOT INITIAL.
        READ TABLE lt_data WITH KEY iban = ls_data-iban ASSIGNING <lf_data>.
        IF sy-subrc IS INITIAL.
          <lf_data>-wrbtr = <lf_data>-wrbtr + ls_data-wrbtr.
        ELSE.
          APPEND ls_data TO lt_data.
        ENDIF.
      ENDIF.
    ENDLOOP.
    ENDIF.

    ASSIGN COMPONENT 'T_BRUECKE' OF STRUCTURE <ls_data> TO FIELD-SYMBOL(<lt_data2>).
    IF sy-subrc IS INITIAL.
      LOOP AT <lt_data2> ASSIGNING FIELD-SYMBOL(<ls_data2>).
        ASSIGN COMPONENT 'T_ZAHLUNGSDATEN' OF STRUCTURE <ls_data2> TO FIELD-SYMBOL(<lt_table2>).
        IF sy-subrc IS INITIAL.
          LOOP AT <lt_table2> ASSIGNING FIELD-SYMBOL(<ls_line2>).
            CLEAR ls_data.
            ASSIGN COMPONENT 'IBAN' OF STRUCTURE <ls_line2> TO <lf_field>.
            IF sy-subrc IS INITIAL.
              IF <lf_field> IS NOT INITIAL.
                ls_data-iban = <lf_field>.
              ENDIF.
            ENDIF.
            ASSIGN COMPONENT 'BEWILLIGUNGSDATUM' OF STRUCTURE <ls_line2> TO <lf_field>.
            IF sy-subrc IS INITIAL.
              IF <lf_field> IS NOT INITIAL.
                ls_data-gjahr = <lf_field>(4).
              ENDIF.
            ENDIF.
            ASSIGN COMPONENT 'AUSZAHLUNGSBETRAG' OF STRUCTURE <ls_line2> TO FIELD-SYMBOL(<lf_field2>).
            IF sy-subrc IS INITIAL.
              IF <lf_field2> IS NOT INITIAL.
                ls_data-wrbtr = CONV wrbtr( <lf_field2> ).
              ENDIF.
            ENDIF.
            ls_data-cpudt = p_cpudt.
            IF ls_data-iban IS NOT INITIAL AND ls_data-wrbtr IS NOT INITIAL.
              READ TABLE lt_data WITH KEY iban = ls_data-iban ASSIGNING <lf_data>.
              IF sy-subrc IS INITIAL.
                <lf_data>-wrbtr = <lf_data>-wrbtr + ls_data-wrbtr.
              ELSE.
                APPEND ls_data TO lt_data.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
    ENDIF.



  ENDLOOP.

  SELECT * FROM /thkr/db_iban_s
  INTO TABLE lt_data2
  WHERE cpudt = p_cpudt
  AND sst = p_sst.

  LOOP AT lt_data ASSIGNING <lf_data>.
    READ TABLE lt_data2 WITH KEY iban = <lf_data>-iban ASSIGNING FIELD-SYMBOL(<lf_data2>).
    IF sy-subrc IS INITIAL.
      <lf_data>-wrbtr2 = <lf_data2>-wrbtr.
    ENDIF.
    IF <lf_data>-wrbtr EQ <lf_data>-wrbtr2.
      <lf_data>-diff = abap_false.
    ELSE.
      <lf_data>-diff = abap_true.
    ENDIF.
  ENDLOOP.

   " SALV-Objekt erzeugen
   cl_salv_table=>factory(
     IMPORTING
       r_salv_table = lo_alv
     CHANGING
       t_table      = lt_data
   ).
*----------------------------------------------------------------------*
* Spaltenbezeichnung ergänzen                                          *
*----------------------------------------------------------------------*
   lo_columns = lo_alv->get_columns( ).
   lo_column = lo_columns->get_column( 'WRBTR' ).
   lo_column->set_short_text('AIF-Betrag').
   lo_column->set_medium_text('AIF-Betrag').
   lo_column->set_long_text('AIF-Betrag').
   lo_column = lo_columns->get_column( 'WRBTR2' ).
   lo_column->set_short_text('ZIBAN-Bet.').
   lo_column->set_medium_text('ZIBAN-Betrag').
   lo_column->set_long_text('ZIBAN-Betrag').
   lo_column = lo_columns->get_column( 'DIFF' ).
   lo_column->set_short_text('Fehler').
   lo_column->set_long_text('Fehler').
   " --- Optionale Einstellungen ---
   " Standard-Funktionen (Sortieren, Filtern, Excel-Export etc.) aktivieren
   lo_alv->get_functions( )->set_all( abap_true ).
   " Spaltentitel optimieren (automatische Breite)
   lo_alv->get_columns( )->set_optimize( abap_true ).
   " Titel der Liste setzen
   lo_alv->get_display_settings( )->set_list_header( 'Prüfbericht AIF - Ziel IBAN' ).
   lo_alv->get_display_settings( )->set_striped_pattern( abap_true ).
   " 3. Anzeige
   lo_alv->display( ).

  CATCH /aif/cx_aif_engine_not_found INTO lx_exc.
  CATCH /aif/cx_error_handling_general INTO lx_exc.
  CATCH cx_salv_msg INTO lx_exc.
  CATCH cx_salv_not_found INTO lx_exc.
ENDTRY.
