*----------------------------------------------------------------------*
***INCLUDE Z_FI_LVM_BNKA_F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form LOCK_DATA
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM lock_data .

  CHECK p_test IS INITIAL.
  CHECK p_lock IS NOT INITIAL.
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

  DATA: lt_zfi_bnka TYPE TABLE OF zfi_bnka,
        lt_bnka_err TYPE TABLE OF zfi_bnka,
        lt_bnka_new TYPE TABLE OF bnka,
        l_objectid  TYPE cdobjectv, " cdhdr-objectid,
        l_bnka_new  TYPE bnka,
        l_bnka_old  TYPE bnka,
        l_bnka      TYPE bnka,
        l_updkz     TYPE c,
        l_len       TYPE i.

  FIELD-SYMBOLS: <object_id>.

* Tabelle mit Löschkennzeichen einlesen
  SELECT * FROM zfi_bnka INTO TABLE lt_zfi_bnka.

  IF lines( lt_zfi_bnka ) = 0.
    RETURN.
  ENDIF.

  IF p_test IS INITIAL.
    LOOP AT lt_zfi_bnka ASSIGNING FIELD-SYMBOL(<lkz>).

      UPDATE bnka SET loevm = 'X' WHERE banks = <lkz>-banks
                                  AND   bankl = <lkz>-bankl.
*                                  AND   loevm = ' '.
      IF sy-subrc <> 0.

        APPEND <lkz> TO lt_bnka_err.

      ELSEIF p_cdoc IS NOT INITIAL.

        SELECT SINGLE * FROM bnka INTO l_bnka_new  WHERE banks = <lkz>-banks
                                                   AND   bankl = <lkz>-bankl.
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
      l_bnka_old-loevm = ' '.
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

  gt_result = lt_zfi_bnka.
  IF lines( lt_bnka_err ) > 0.
    LOOP AT lt_bnka_err ASSIGNING FIELD-SYMBOL(<err>).
      READ TABLE gt_result ASSIGNING FIELD-SYMBOL(<res>)
                           WITH KEY banks = <err>-banks bankl = <err>-bankl.
      IF sy-subrc = 0.
        <res>-status = 'E'.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_DATA
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM alv_data .

  DATA: lo_salv     TYPE REF TO zcl_fi_bnka_salv,
        lt_data_ref TYPE REF TO data.

  CREATE OBJECT lo_salv.

  TRY.

      IF lines( gt_result ) > 0.

        GET REFERENCE OF gt_result INTO lt_data_ref.

        lo_salv->display(
        EXPORTING
          i_t_data_ref = lt_data_ref ).

*      ELSE.
*
*        l_salv->display( ).

      ENDIF.

    CATCH cx_salv_not_found.

  ENDTRY.

ENDFORM.
