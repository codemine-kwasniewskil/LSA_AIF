*&---------------------------------------------------------------------*
* Gereon Koks  4.2.2026  T-Systems
*&---------------------------------------------------------------------*
* BUT000 korrigieren
*&---------------------------------------------------------------------*
*& Report /THKR/AIF_BUT000
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/aif_but000.
*&---------------------------------------------------------------------*
TABLES: but000.
*&---------------------------------------------------------------------*
DATA: l_but000  TYPE but000,
      lv_string TYPE string,
      lv_hash   TYPE xstring,
      lv_int    TYPE i.
*&---------------------------------------------------------------------*
SELECT-OPTIONS: p_bpext FOR but000-bpext.
SELECT-OPTIONS: p_sst   FOR but000-/thkr/sst.
PARAMETERS:     ak_hash AS CHECKBOX.
PARAMETERS:     ak_0001 AS CHECKBOX.
PARAMETERS:     ak_test AS CHECKBOX DEFAULT 'X'.
*&---------------------------------------------------------------------*
SELECT * FROM but000 INTO l_but000
  WHERE bpext     IN p_bpext
    AND /thkr/sst IN p_sst.

  lv_string = l_but000-bu_sort1.
*&---------------------------------------------------------------------*
  IF ak_hash = 'X'.
    TRY.
        cl_abap_message_digest=>calculate_hash_for_char(
          EXPORTING
            if_data          = lv_string
          IMPORTING
            ef_hashx         = lv_hash
        ).

        l_but000-bpext = 'CPD_' && lv_hash.

      CATCH cx_abap_message_digest.
    ENDTRY.
  ENDIF.
*&---------------------------------------------------------------------*
  IF ak_0001 = 'X'.
    l_but000-bpext = '0000000001'.
  ENDIF.
*&---------------------------------------------------------------------*
  IF ak_test IS INITIAL.
    MODIFY but000 FROM l_but000.
  ENDIF.

  ADD 1 TO lv_int.

  WRITE: /1 lv_int,
            l_but000-partner,
            l_but000-type,
            l_but000-bpkind,
            l_but000-bu_group,
            'BU_SORT1:', l_but000-bu_sort1,
            l_but000-bu_sort2,
            l_but000-name_org1,
            'BPEXT:', l_but000-bpext.
ENDSELECT.
*&---------------------------------------------------------------------*
