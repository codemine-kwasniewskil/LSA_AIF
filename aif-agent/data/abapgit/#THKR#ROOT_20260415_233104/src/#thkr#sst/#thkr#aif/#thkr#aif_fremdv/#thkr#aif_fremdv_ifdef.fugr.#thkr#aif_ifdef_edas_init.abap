FUNCTION /thkr/aif_ifdef_edas_init .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(CONTEXT) TYPE  STRING OPTIONAL
*"     REFERENCE(FINF) TYPE  /AIF/T_FINF
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) OPTIONAL
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_AIF_BIC OPTIONAL
*"  EXCEPTIONS
*"      CANCEL
*"----------------------------------------------------------------------
  DATA: lo_struc TYPE REF TO cl_abap_structdescr.
  DATA: lo_tab TYPE REF TO cl_abap_tabledescr.
  DATA: lt_tab_kassz TYPE SORTED TABLE OF string WITH UNIQUE KEY table_line.


  lo_tab ?= cl_abap_tabledescr=>describe_by_data( p_data = raw_struct-line ).
  lo_struc ?= cl_abap_structdescr=>describe_by_name( p_name = lo_tab->get_table_line_type( )->absolute_name+6 ).
  DATA(lt_comp) = lo_struc->components.

  LOOP AT raw_struct-line ASSIGNING FIELD-SYMBOL(<ls_line>).

    IF <ls_line>-01_btyp = 'SZU' OR <ls_line>-01_btyp = 'SAB'.
      READ TABLE raw_struct-line WITH KEY 01_btyp = 'SST' 32_kassz = <ls_line>-41_urkass TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        "Es gibt eine Sollstellung in Datenlieferung. Keine weitere Bearbeitung notwendig.
        CONTINUE.
      ELSE.
        SELECT SINGLE belnr
          FROM bkpf
          WHERE xblnr = @<ls_line>-41_urkass
          INTO @DATA(lv_belnr).
        IF sy-subrc = 0.
          "Es gibt eine Anordnung mit dem Kassenzeichen auf dem System.
          "Behalte SZU bei.
          CONTINUE.
        ELSE.
          "Es gibt noch keine Anordnung.
          "Lese für die erste SZU / SAB aus EDAS-Tabelle den Datensatz und tausche SST gegen den ersten SZU / SAB Datensatz aus
          "alle anderen SZU mit gleichen Kassenzeichen können dann von der neuen Sollstellung gebucht werden.

          "Prüfe, ob für das Kassenzeichen bereits eine Sollstellung aus eine SZU-Satz gebaut wurde
          READ TABLE lt_tab_kassz WITH KEY table_line = <ls_line>-41_urkass TRANSPORTING NO FIELDS BINARY SEARCH.
          IF sy-subrc = 0.
            "für das Kassenzeichen wurde bereits eine SZU / SAB durch eine SSt ausgetauscht.
            "Behalte die weiteren SZU / SAB Datensätze bei.
            CONTINUE.
          ELSE.
            "Erster Datensatz für das Kassenzeichen.
            "Lese aus Datenbanktabelle
            SELECT SINGLE *
             FROM /thkr/t_edas_0
             WHERE kassz = @<ls_line>-41_urkass
              INTO @DATA(ls_edas_0).
            IF sy-subrc = 0.
              "SST mit Betrag 0 gefunden.
              "Austauschen.
              "Abfrage, welche Felder aus SST in SZU übergehen
              SELECT *
                FROM /thkr/t_edas_owr
              INTO TABLE @DATA(lt_field_overwrite).
              LOOP AT lt_comp ASSIGNING FIELD-SYMBOL(<ls_comp>).
                TRY.
                    IF lt_field_overwrite[ fieldname = <ls_comp>-name ]-ovwrt = abap_true.
                      ASSIGN COMPONENT <ls_comp>-name OF STRUCTURE <ls_line> TO FIELD-SYMBOL(<ls_curr_val>).
                      ASSIGN COMPONENT <ls_comp>-name+3 OF STRUCTURE ls_edas_0 TO FIELD-SYMBOL(<ls_tab_val>).
                      IF <ls_tab_val> IS ASSIGNED AND <ls_curr_val> IS ASSIGNED.
                        <ls_curr_val> = <ls_tab_val>.
                      ENDIF.
                    else.
                      "Feld gefunden, soll aber nicht übernommen werden.
                      CONTINUE.
                    ENDIF.
                  CATCH cx_sy_itab_line_not_found.
                    "Kein Feld in Übernahme Tabelle gefunden.
                    "Nicht übernehmen
                    CONTINUE.
                ENDTRY.
              ENDLOOP.
              "Lesen für Tabellenindex
              READ TABLE lt_tab_kassz WITH KEY table_line = <ls_line>-32_kassz TRANSPORTING NO FIELDS BINARY SEARCH.
              INSERT <ls_line>-32_kassz INTO lt_tab_kassz INDEX sy-tabix.
            ELSE.
              "Kein Datensatz gefunden.
              "Behalte SZU / SAB Datensatz und lasse ihn später auf Fehler laufen
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
