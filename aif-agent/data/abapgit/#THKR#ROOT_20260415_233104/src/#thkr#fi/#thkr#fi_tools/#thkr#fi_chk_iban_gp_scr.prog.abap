*&---------------------------------------------------------------------*
*& Include          /THKR/FI_CHK_IBAN_GP_SCR                           *
*&---------------------------------------------------------------------*
*& Beschreibung:                                                       *
*&                                                                     *
*& Screen-Include Startbildschrim des Programms                        *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Autor:       Frank Brähler (Orexes GmbH)                            *
*& Anlage:      21.01.2026                                             *
*&                                                                     *
*& Änderer:     Frank Brähler                                          *
*& l.Datum:     03.02.2026                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
************************************************************************
* Startabfrage                                                         *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE a1_titel.
  SELECTION-SCREEN SKIP.

  SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-f01.
    SELECT-OPTIONS so_blart FOR bkpf-blart NO INTERVALS.
    PARAMETERS: p_gjahr TYPE gjahr,
                p_cpudt TYPE cpudt.
    SELECTION-SCREEN SKIP.

    PARAMETERS: p_sst TYPE /thkr/dte_bu_sst OBLIGATORY MATCHCODE OBJECT /thkr/aif_sst.
    SELECTION-SCREEN SKIP.
  SELECTION-SCREEN END OF BLOCK bl1.

  SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-f03.
    SELECTION-SCREEN SKIP.
    PARAMETERS: p_sitab TYPE xchar AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN SKIP.
  SELECTION-SCREEN END OF BLOCK bl3.


  SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-f02.
    SELECTION-SCREEN SKIP.
    PARAMETERS: p_vari TYPE slis_vari.
    SELECTION-SCREEN SKIP.
  SELECTION-SCREEN END OF BLOCK bl2.

SELECTION-SCREEN END OF BLOCK a1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f_alv_variant_f4 CHANGING p_vari.

*&---------------------------------------------------------------------*
*&      Form  ALV_VARIANT_F4
*&---------------------------------------------------------------------*
*       Layout variant search help
*----------------------------------------------------------------------*
FORM f_alv_variant_f4 CHANGING p_vari.

  DATA: lwa_variant TYPE disvariant.

  lwa_variant-report   = sy-repid.
  lwa_variant-username = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant    = lwa_variant
      i_save        = 'A'
    IMPORTING
      es_variant    = lwa_variant
    EXCEPTIONS
      not_found     = 1
      program_error = 2
      OTHERS        = 3.
  IF sy-subrc = 0.
    p_vari = lwa_variant-variant.
  ENDIF.
ENDFORM.                               " ALV_VARIANT_F4
