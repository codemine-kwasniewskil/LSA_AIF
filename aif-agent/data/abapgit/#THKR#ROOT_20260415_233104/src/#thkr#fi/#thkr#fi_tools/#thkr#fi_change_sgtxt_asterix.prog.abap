*&---------------------------------------------------------------------*
*& Report /THKR/CHANGE_ARCHIV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/fi_change_sgtxt_asterix.

DATA param TYPE acdoca.

* Selektionsbild
SELECTION-SCREEN BEGIN OF BLOCK d1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS s_bukrs FOR param-rbukrs.
  SELECT-OPTIONS s_gjahr FOR param-gjahr.
  SELECT-OPTIONS s_blnr FOR param-belnr.
SELECTION-SCREEN END OF BLOCK d1.

SELECTION-SCREEN BEGIN OF BLOCK d2 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS s_user FOR param-usnam.
SELECTION-SCREEN END OF BLOCK d2.

SELECTION-SCREEN BEGIN OF BLOCK d3 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_set TYPE flag DEFAULT abap_true.
  PARAMETERS: p_test TYPE flag DEFAULT abap_true.
  SELECTION-SCREEN COMMENT /1(79) TEXT-002.
  SELECTION-SCREEN COMMENT /1(79) TEXT-003.
SELECTION-SCREEN END OF BLOCK d3.

START-OF-SELECTION.
  SELECT FROM bseg AS i INNER JOIN bkpf AS k
      ON i~bukrs = k~bukrs
     AND i~gjahr = k~gjahr
     AND i~belnr = k~belnr
    FIELDS i~bukrs,
           i~gjahr,
           i~belnr,
           i~buzei,
           i~sgtxt AS old_itemtxt,
           i~sgtxt AS new_itemtxt,
           ' '     AS processed
    WHERE i~bukrs IN @s_bukrs
      AND i~gjahr IN @s_gjahr
      AND i~belnr IN @s_blnr
      AND i~sgtxt IS NOT INITIAL
      AND k~usnam IN @s_user
    GROUP BY i~bukrs,
             i~gjahr,
             i~belnr,
             i~buzei,
             i~sgtxt
        INTO TABLE @DATA(result).

  LOOP AT result ASSIGNING FIELD-SYMBOL(<line>).
    IF p_set = abap_true.
      IF <line>-old_itemtxt(1) <> '*'.
        <line>-new_itemtxt = |*{ <line>-old_itemtxt }|.
      ENDIF.
    ELSE.
      IF <line>-old_itemtxt(1) = '*'.
        <line>-new_itemtxt = shift_left( val = <line>-old_itemtxt places = 1 ).
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF p_test = abap_false.
    "** process on db with chunk size = 10000!
    LOOP AT result ASSIGNING <line>.
      "** Skip unchanged entries:
      IF <line>-new_itemtxt = <line>-old_itemtxt.
        <line>-processed = '-'.
        CONTINUE.
      ENDIF.
      "** Processing...
      UPDATE bseg SET sgtxt = <line>-new_itemtxt WHERE bukrs = <line>-bukrs AND gjahr = <line>-gjahr AND belnr = <line>-belnr and buzei = <line>-buzei.
      IF sy-subrc = 0.
        <line>-processed = abap_true.
      ENDIF.
      IF sy-tabix > 1 AND sy-tabix MOD 5000 = 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDLOOP.
    COMMIT WORK AND WAIT.
  ENDIF.

  "** Prepare output
  cl_salv_table=>factory( IMPORTING r_salv_table = DATA(salv) CHANGING t_table = result ).
  LOOP AT salv->get_columns( )->get( ) ASSIGNING FIELD-SYMBOL(<col>).
    <col>-r_column->set_short_text( CONV #( to_mixed( <col>-columnname ) ) ).
    <col>-r_column->set_medium_text( CONV #( to_mixed( <col>-columnname ) ) ).
    <col>-r_column->set_long_text( CONV #( to_mixed( <col>-columnname ) ) ).
  ENDLOOP.
  DATA(testmodus) = COND #( WHEN p_test = abap_true THEN '*TESTMODUS*' ELSE '' ).
  salv->get_display_settings( )->set_list_header( |{ testmodus } Umsetzung von { lines( result ) } Einträgen | ).
  salv->get_functions( )->set_all( abap_true ).
  salv->get_columns( )->set_optimize( abap_true ).
  salv->display(  ).
*ENDIF.
