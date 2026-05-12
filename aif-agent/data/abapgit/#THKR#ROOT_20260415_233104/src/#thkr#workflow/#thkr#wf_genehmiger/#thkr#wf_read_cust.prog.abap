*&---------------------------------------------------------------------*
*& Include          /THKR/WF_READ_CUST
*&---------------------------------------------------------------------*

  lt_fields = VALUE #( ( fieldname = 'TYP_ROLLE' )
                       ( fieldname = 'ROLLE_NR' )
                       ( fieldname = 'FUNKTION' )
                       ( fieldname = 'WORKFLOW' ) ).

  Select * From ZNSI_AGR_UR12C INTO TABLE lt_tab_result.

  IF lt_tab_result IS INITIAL.
    MESSAGE |ZNSI_AGR_UR12C ist initial.| TYPE 'E' ##NO_TEXT.
  ENDIF.

  SELECT * FROM ZNSI_AGR_UR13C INTo TABLE lt_tab_result_13c.

  IF lt_tab_result_13c IS INITIAL.
    MESSAGE |ZNSI_AGR_UR13C ist initial.| TYPE 'E' ##NO_TEXT.
  ENDIF.

SELECT * FROM ZNSI_AGR_02XXL INTO TABLE lt_tab_result_02xxl.

  IF lt_tab_result_02xxl IS INITIAL.
    MESSAGE |ZNSI_AGR_02XXL ist initial.| TYPE 'E' ##NO_TEXT.
  ENDIF.

  SELECT * FROM ZNSI_AGR_05XXL INTO TABLE lt_tab_result_05xxl
    where variante = 'HKR'.

  DELETE lt_tab_result_05xxl WHERE typ_orgebene IS INITIAL AND
                                   typ_berecht IS INITIAL.

  IF lt_tab_result_05xxl IS INITIAL.
    MESSAGE |ZNSI_AGR_05XXL ist initial.| TYPE 'E' ##NO_TEXT.
  ENDIF.

SELECT * FROM ZNSI_AGR_06XXL INTO TABLE lt_tab_result_06xxl_2.

Loop at lt_tab_result_06xxl_2 into ls_tab_result_06xxl_2.

  MOVE-CORRESPONDING ls_tab_result_06xxl_2 to ls_tab_result_06xxl.
  Append ls_tab_result_06xxl to lt_tab_result_06xxl.

  ENDLOOP.


  IF lt_tab_result_06xxl IS INITIAL.
    MESSAGE |ZNSI_AGR_06XXL ist initial.| TYPE 'E' ##NO_TEXT.
  ENDIF.

  SELECT * FROM ZNSI_AGR_11XXL into TABLE lt_tab_result_11xxl.

  IF lt_tab_result_11xxl IS INITIAL.
    MESSAGE |ZNSI_AGR_11XXL ist initial.| TYPE 'E' ##NO_TEXT.
  ELSE.

    DELETE lt_tab_result_11xxl WHERE orgma NE 'X'.

    LOOP AT lt_tab_result_11xxl ASSIGNING FIELD-SYMBOL(<rfc_activ>).

      SELECT SINGLE rfcdest FROM rfcdes WHERE rfcdest EQ @<rfc_activ>-rfcdest INTO @DATA(lv_rfcdest).
      IF sy-subrc IS NOT INITIAL.
        DELETE lt_tab_result_11xxl.
        CONTINUE.
      ENDIF.
    ENDLOOP.

  ENDIF.

  " SSP-Attrubute lesen
  SELECT * FROM t77omattot WHERE scenario = 'SSP'
    INTO TABLE @lt_t77omattot.

  IF lt_t77omattot IS INITIAL.
    MESSAGE |Tabelle t77omattot ist leer.| TYPE 'E' ##NO_TEXT.
  ENDIF.
