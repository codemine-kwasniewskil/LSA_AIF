*&---------------------------------------------------------------------*
*& Report /THKR/CHANGE_ARCHIV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/change_archiv.


"" EPL des Einzahlers
* Selektionsbild
SELECTION-SCREEN BEGIN OF BLOCK d1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_from TYPE saearchivi OBLIGATORY DEFAULT 'P1',
              p_to   TYPE saearchivi OBLIGATORY DEFAULT 'E1'.
SELECTION-SCREEN END OF BLOCK d1.

SELECTION-SCREEN BEGIN OF BLOCK d2 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_test TYPE flag DEFAULT abap_true.
  SELECTION-SCREEN COMMENT /1(79) TEXT-002.
SELECTION-SCREEN END OF BLOCK d2.

START-OF-SELECTION.

  SELECT FROM toaom
    FIELDS sap_object,
            ar_object,
            ar_status,
            archiv_id AS von,
            @p_to AS ziel
    WHERE archiv_id = @p_from
    INTO TABLE @DATA(archives).
  IF sy-subrc = 0.
    IF p_test = abap_false.
      UPDATE toaom SET archiv_id = @p_to WHERE archiv_id = @p_from.
      IF sy-subrc EQ 0.
        COMMIT WORK.
      ELSE.
        MESSAGE |Fehler bei der Tabellenänderung subrc = { sy-subrc }| TYPE 'E' DISPLAY LIKE 'I'.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.
    "** Prepare output
    cl_salv_table=>factory( IMPORTING r_salv_table = DATA(salv) CHANGING t_table = archives ).

    LOOP AT salv->get_columns( )->get( ) ASSIGNING FIELD-SYMBOL(<col>).
      <col>-r_column->set_short_text( CONV #( to_mixed( <col>-columnname ) ) ).
      <col>-r_column->set_medium_text( CONV #( to_mixed( <col>-columnname ) ) ).
      <col>-r_column->set_long_text( CONV #( to_mixed( <col>-columnname ) ) ).
    ENDLOOP.
    DATA(testmodus) = COND #( WHEN p_test = abap_true THEN '*TESTMODUS*' ELSE '' ).
    salv->get_display_settings( )->set_list_header( |{ testmodus } Umsetzung von { p_from } nach { p_to } | ).
    salv->get_functions( )->set_all( abap_true ).
    salv->get_columns( )->set_optimize( abap_true ).
    salv->display(  ).

  ENDIF.
