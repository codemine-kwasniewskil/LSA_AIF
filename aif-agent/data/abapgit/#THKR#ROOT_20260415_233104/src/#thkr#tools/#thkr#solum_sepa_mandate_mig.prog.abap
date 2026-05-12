*&---------------------------------------------------------------------*
*& Report /THKR/SOLUM_SEPA_MANDATE_MIG                                 *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Beschreibung:                                                       *
*& Mandatsreferenz für SOLUMWEB-Mandate mit dem -Benutzer MIG in der   *
*& Mandatsreferenz mit dem SUFIX _MIG kennzeichnen                     *
*&                                                                     *
*& Autor:        Frank Brähler (Orexes GmbH)                           *
*& Datum:        05.02.2026                                            *
*&                                                                     *
*& l. Änderung:  18.02.2026                                            *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT /thkr/solum_sepa_mandate_mig.

************************************************************************
* Globale Variablen                                                    *
************************************************************************
DATA: gv_mndid        TYPE sepa_mndid,
      gv_origin_mndid TYPE sepa_mndid_origin.

************************************************************************
* Struktur-Typen                                                       *
************************************************************************
DATA: gs_sepa       TYPE sepa_mandate,
      gt_sepa       TYPE TABLE OF sepa_mandate,
      gs_loe_sepa_m TYPE /thkr/s_sepa_mandate_loe,
      gt_loe_sepa_m TYPE /thkr/t_sepa_mandate_loe,
      gs_fieldcat   TYPE slis_fieldcat_alv,
      gs_layo       TYPE slis_layout_alv.

************************************************************************
* Selection-Screen                                                     *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE a1_titel.
  SELECTION-SCREEN SKIP.

  SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-f01.
    PARAMETERS: p_mndid TYPE sepa_mndid OBLIGATORY DEFAULT '%SOLUMWEB%',
                p_ernam TYPE sepa_ernam OBLIGATORY DEFAULT '9999-MIG',
                p_sufix TYPE char4      DEFAULT '_MIG'.
  SELECTION-SCREEN END OF BLOCK bl1.

  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-f02.
    PARAMETERS: p_test TYPE xchar AS CHECKBOX DEFAULT 'X',
                p_chks TYPE xchar AS CHECKBOX.
  SELECTION-SCREEN END OF BLOCK bl2.
  SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF BLOCK a1.

************************************************************************
* Start-Of-Selektion                                                   *
************************************************************************
START-OF-SELECTION.

  SELECT * FROM sepa_mandate INTO gs_sepa
                WHERE mndid LIKE p_mndid
                AND   ernam EQ p_ernam.
    CLEAR gs_loe_sepa_m.
    MOVE-CORRESPONDING gs_sepa TO gs_loe_sepa_m.
    MOVE: sy-uname TO gs_loe_sepa_m-cpnam,
          sy-datum TO gs_loe_sepa_m-cpdat,
          sy-uzeit TO gs_loe_sepa_m-cptim.

    IF NOT gs_sepa-mndid CS p_sufix.
      IF p_chks IS INITIAL.
        APPEND gs_loe_sepa_m TO gt_loe_sepa_m.
      ENDIF.
    ELSE.
      IF NOT p_chks IS INITIAL.
        APPEND gs_loe_sepa_m TO gt_loe_sepa_m.
      ENDIF.
    ENDIF.
  ENDSELECT.

  IF NOT gt_loe_sepa_m[] IS INITIAL.
    LOOP AT gt_loe_sepa_m INTO gs_loe_sepa_m.
      SELECT SINGLE * FROM sepa_mandate INTO gs_sepa
                      WHERE mguid EQ gs_loe_sepa_m-mguid.
      IF 0 EQ sy-subrc.
        IF p_chks IS INITIAL.
          CONCATENATE gs_sepa-mndid p_sufix        INTO gv_mndid.
        ELSE.
          gv_mndid = gs_sepa-mndid.
        ENDIF.
        CONCATENATE gs_sepa-origin_mndid p_sufix INTO gv_origin_mndid.
        WRITE: /05 gs_loe_sepa_m-mndid,
               ' | ',
               gv_mndid,
               ' | ',
               gv_origin_mndid,
               ' | ',
               p_test.
        IF p_test IS INITIAL.
          IF p_chks IS INITIAL.
            UPDATE sepa_mandate SET mndid        = gv_mndid
                                    origin_mndid = gv_origin_mndid
                         WHERE mguid = gs_loe_sepa_m-mguid.
          ELSE.
            IF NOT gs_sepa-origin_mndid CS p_sufix.
              UPDATE sepa_mandate SET origin_mndid = gv_origin_mndid
                           WHERE mguid = gs_loe_sepa_m-mguid.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
