*----------------------------------------------------------------------*
***INCLUDE Z_FI_LVM_BNKA_F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form LOCK_DATA
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM lock_data .

  CHECK p_test IS INITIAL.

  CHECK gv_lock IS INITIAL.

  CALL FUNCTION 'ENQUEUE_EFBNKA'
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2.
  CASE sy-subrc.
    WHEN 0.
      gv_lock = 'X'.
    WHEN 1.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    WHEN 2.
      MESSAGE e012.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form UNLOCK_DATA
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM unlock_data .

  CHECK gv_lock IS NOT INITIAL.
  CALL FUNCTION 'DEQUEUE_EFBNKA'.
  CLEAR gv_lock.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_DATA
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM update_data .

  DATA:
    lt_bnka_err TYPE TABLE OF bnka,
    lt_bnka_new TYPE TABLE OF bnka,

    l_objectid  TYPE cdobjectv, " cdhdr-objectid,
    l_bnka_new  TYPE bnka,
    l_bnka_old  TYPE bnka,
    l_bnka      TYPE bnka,
    l_updkz     TYPE c,
    l_len       TYPE i.

  FIELD-SYMBOLS: <object_id> TYPE any.
  PERFORM read_bnka.

  IF lines( gt_bnka ) = 0.
   message e013.
  ENDIF.


  LOOP AT gt_bnka ASSIGNING FIELD-SYMBOL(<bgrup>).

    CASE <bgrup>-bankl+3(1).
      WHEN '0'.
        <bgrup>-bgrup = '00'.
        APPEND <bgrup> TO gt_bnka_change.
      WHEN '1'.
        <bgrup>-bgrup = '01'.
        APPEND <bgrup> TO gt_bnka_change.
      WHEN '2'.
        <bgrup>-bgrup = '02'.
        APPEND <bgrup> TO gt_bnka_change.
      WHEN '4'.
        <bgrup>-bgrup = '04'.
        APPEND <bgrup> TO gt_bnka_change.
      WHEN '5'.
        <bgrup>-bgrup = '05'.
        APPEND <bgrup> TO gt_bnka_change.
      WHEN '6'.
        <bgrup>-bgrup = '06'.
        APPEND <bgrup> TO gt_bnka_change.
      WHEN '7'.
        <bgrup>-bgrup = '07'.
        APPEND <bgrup> TO gt_bnka_change.
      WHEN '8'.
        <bgrup>-bgrup = '08'.
        APPEND <bgrup> TO gt_bnka_change.
      WHEN '9'.
        <bgrup>-bgrup = '09'.
        APPEND <bgrup> TO gt_bnka_change.
      WHEN OTHERS.
        CONTINUE.
    ENDCASE.

    IF <bgrup>-bankl = '60050101'.
      <bgrup>-bgrup = '02'.
      READ TABLE gt_bnka_change INTO l_bnka WITH KEY banks = <bgrup>-banks
                                                     bankl = <bgrup>-bankl.
      IF sy-subrc  = 0.
        MODIFY gt_bnka_change FROM <bgrup> INDEX sy-tabix.
      ENDIF.
    ENDIF.
  ENDLOOP.
  IF p_test IS INITIAL.
    LOOP AT gt_bnka_change ASSIGNING <bgrup>.
      UPDATE bnka FROM <bgrup>.

      IF sy-subrc <> 0.

        APPEND <bgrup> TO lt_bnka_err.

      ELSEIF p_cdoc IS NOT INITIAL.

        SELECT SINGLE * FROM bnka INTO l_bnka_new  WHERE banks = <bgrup>-banks
                                                   AND   bankl = <bgrup>-bankl.
        IF sy-subrc = 0.
          APPEND l_bnka_new TO lt_bnka_new.
        ENDIF.

      ENDIF.

    ENDLOOP.
  ENDIF.
* Änderungsbelege erzeugen
  IF p_test IS INITIAL AND p_cdoc IS NOT INITIAL.

    LOOP AT lt_bnka_new ASSIGNING FIELD-SYMBOL(<bnka_new>).

      l_bnka_old = <bnka_new>.
      l_bnka_old-bgrup = ' '.
      l_updkz = 'U'.

      WRITE space TO l_bnka.
      TRANSLATE l_bnka-banks USING ' X'.
      TRANSLATE l_bnka-bankl USING ' X'.
      l_len = strlen( l_bnka ).
      l_bnka = <bnka_new>.
      ASSIGN l_bnka(l_len) TO <object_id>.
      l_objectid = <object_id>.


      CALL FUNCTION 'BANK_WRITE_DOCUMENT'
        EXPORTING
          objectid                = l_objectid
          tcode                   = sy-tcode
          utime                   = sy-uzeit
          udate                   = sy-datum
          username                = sy-uname
          object_change_indicator = l_updkz
          n_bnka                  = <bnka_new>
          o_bnka                  = l_bnka_old
          upd_bnka                = l_updkz.

    ENDLOOP.

  ENDIF.

  COMMIT WORK.

  IF p_test = 'X'.
    gt_result = gt_bnka_change.
  ELSE.
    gt_result = lt_bnka_new.
  ENDIF.
* erstmal nicht notwendig.
*  IF lines( lt_bnka_err ) > 0.
*    LOOP AT lt_bnka_err ASSIGNING FIELD-SYMBOL(<err>).
*      READ TABLE gt_result ASSIGNING FIELD-SYMBOL(<res>)
*                           WITH KEY banks = <err>-banks bankl = <err>-bankl.
*      IF sy-subrc = 0.
*        <res>-status = 'E'.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DATA
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM alv_data .
data: lv_list_header type lvc_title.
*Entscheidung welche Darstellung erfolgen soll, hier Vollscreen Dynpro
  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = go_table
                              CHANGING t_table = gt_result ).
    CATCH cx_salv_msg.
  ENDTRY.

* Symbolleiste wird eingeblendet
  go_functions = go_table->get_functions( ).
  go_functions->set_all( abap_true ).

  go_display = go_table->get_display_settings( ).
  go_display->set_striped_pattern( cl_salv_display_settings=>true ).
  IF p_test = 'X'.
    lv_list_header = text-002.
    go_display->set_list_header( lv_list_header ).
  ELSE.
     lv_list_header = text-001.
    go_display->set_list_header( lv_list_header ).
  ENDIF.

  TRY.
      go_columns = go_table->get_columns( ).
      go_column ?= go_columns->get_column( 'BANKS' ).
    CATCH cx_salv_not_found.
  ENDTRY.



* Sortierung
  go_sorts = go_table->get_sorts( ).
  "gr_sorts->add_sort( 'CITYTO' ).


** Filter
*  go_filter = go_table->get_filters( ).
*  go_filter->add_filter( columnname = 'CARRID' low = 'LH' ).


* Layout (Layoutänderungen abspeicherbar)
  go_layout = go_table->get_layout( ).
  key-report = sy-repid.
  go_layout->set_key( key ).
  go_layout->set_save_restriction( cl_salv_layout=>restrict_none ).


*******************
* Anzeige Tabelle *
*******************
  go_table->display( ).



ENDFORM.
*&---------------------------------------------------------------------*
*& Form READ_BNKA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM read_bnka.
  SELECT * FROM bnka INTO TABLE gt_bnka
           WHERE banks IN so_banks
           AND   bankl IN so_bankl
           AND   bgrup = space
           AND   loevm = space.

ENDFORM.
