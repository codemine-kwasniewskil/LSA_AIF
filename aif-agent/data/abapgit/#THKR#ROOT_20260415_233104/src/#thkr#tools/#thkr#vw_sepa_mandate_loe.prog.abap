*&---------------------------------------------------------------------*
*& Report /THKR/VW_SEPA_MANDATE_LOE                                    *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Beschreibung:                                                       *
*& Vorbereiten und Durchführung löschen von SEPA-Mandate.              *
*& 1. SEPA-Mandate selektieren                                         *
*& 2. SEPA-Mandate prüfen und kennzeichen                              *
*& 3. SEPA-Mandate löschen                                             *
*&                                                                     *
*& Autor:        Frank Brähler (Orexes GmbH)                           *
*& Datum:        12.01.2026                                            *
*&                                                                     *
*& l. Änderung: 14.01.2026                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT /thkr/vw_sepa_mandate_loe.

************************************************************************
* Struktur-Typen                                                       *
************************************************************************
DATA: gs_sepa         TYPE sepa_mandate,
      gs_loe_sepa_m   TYPE /thkr/s_sepa_mandate_loe,
      gs_fieldcat     TYPE slis_fieldcat_alv,
      gs_layo         TYPE slis_layout_alv,
      gs_sepa_mandate TYPE sepa_mandate.

************************************************************************
* Tabellentypen                                                        *
************************************************************************
DATA: gt_loe_sepa_m TYPE /thkr/t_sepa_mandate_loe,
      gt_sepa       TYPE TABLE OF sepa_mandate,
      gt_fieldcat   TYPE slis_t_fieldcat_alv.

************************************************************************
* Feldsymbole                                                          *
************************************************************************
FIELD-SYMBOLS: <gfs_sepa> TYPE sepa_mandate.

************************************************************************
* Selection-Screen                                                     *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE a1_titel.
  SELECTION-SCREEN SKIP.

  SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-f01.
    PARAMETERS: p_dele  TYPE char1 AS CHECKBOX.
  SELECTION-SCREEN END OF BLOCK bl1.

  SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF BLOCK a1.

************************************************************************
* Start-Of-Selektion                                                   *
************************************************************************
START-OF-SELECTION.
  SELECT * FROM /THKR/loe_sepa_m WHERE kzcheck IS NOT INITIAL
             INTO TABLE @gt_loe_sepa_m.

  IF NOT p_dele IS INITIAL.
    LOOP AT gt_loe_sepa_m INTO gs_loe_sepa_m.
      IF NOT gs_loe_sepa_m-kzcheck IS INITIAL.
        SELECT SINGLE * FROM sepa_mandate INTO @gs_sepa_mandate
                                WHERE mguid = @gs_loe_sepa_m-mguid.
        IF 0 EQ sy-subrc.
          UPDATE /thkr/loe_sepa_m SET lonam   = @sy-uname,
                                      lodat   = @sy-datum,
                                      lotim   = @sy-uzeit
                             WHERE mguid = @gs_loe_sepa_m-mguid.
          IF 0 EQ sy-subrc.
            DELETE FROM sepa_mandate WHERE mguid EQ gs_loe_sepa_m-mguid.
            IF 0 NE sy-subrc.
              ROLLBACK WORK.
              MESSAGE 'Fehler beim DELETE! - Löachen nicht möglich' TYPE 'E'.
            ENDIF.
          ELSE.
            ROLLBACK WORK.
            MESSAGE 'Fehler beim Update! - Löachen nicht möglich' TYPE 'E'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
    SELECT * FROM /THKR/loe_sepa_m WHERE kzcheck IS NOT INITIAL
           INTO TABLE @gt_loe_sepa_m.
  ENDIF.

  PERFORM get_fieldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat        = gt_fieldcat  "  SLIS_T_FIELDCAT_ALV OPTIONAL
*     i_structure_name   = '/THKR/LOE_SEPA_M'
      i_callback_program = sy-repid
    TABLES
      t_outtab           = gt_loe_sepa_m
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.


END-OF-SELECTION.

************************************************************************
* Initialisierung des Programms                                        *
************************************************************************
INITIALIZATION.
************************************************************************
* Initialisierung Selektions-Title                                     *
************************************************************************
  a1_titel = TEXT-t01.


*&---------------------------------------------------------------------*
*& Form get_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_fieldcat .
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = '/THKR/LOE_SEPA_M'
    CHANGING
      ct_fieldcat      = gt_fieldcat.

  DELETE gt_fieldcat WHERE fieldname EQ 'MANDT' OR
                           fieldname EQ 'SIGN_CITY' OR
                           fieldname EQ 'SIGN_DATE' OR
                           fieldname EQ 'PAY_TYPE'  OR
                           fieldname EQ 'B2B'  OR
                           fieldname EQ 'REASON_CODE'  OR
                           fieldname EQ 'CHG_REASON'  OR
                           fieldname EQ 'ORIGIN'  OR
                           fieldname EQ 'GLOCK'  OR
                           fieldname EQ 'GLOCK_VAL_FROM'  OR
                           fieldname EQ 'GLOCK_VAL_TO'  OR
                           fieldname EQ 'ANWND'  OR
                           fieldname EQ 'ORI_ERNAM'  OR
                           fieldname EQ 'ORI_ERDAT'  OR
                           fieldname EQ 'ORI_ERTIM'  OR
                           fieldname EQ 'REF_TYPE'  OR
                           fieldname EQ 'REF_ID'  OR
                           fieldname EQ 'REF_DESC'  OR
                           fieldname EQ 'SND_TYPE'  OR
                           fieldname EQ 'SND_DIR_NAME'  OR
                           fieldname EQ 'SND_LANGUAGE'  OR
                           fieldname EQ 'SND_DIR_ID'  OR
                           fieldname EQ 'SND_DIR_ID'  OR
                           fieldname EQ 'SND_DEBTOR_ID'  OR
                           fieldname EQ 'REC_TYPE'  OR
                           fieldname EQ 'REC_STREET'  OR
                           fieldname EQ 'REC_HOUSENUM'  OR
                           fieldname EQ 'REC_POSTAL'  OR
                           fieldname EQ 'REC_DIR_NAME'  OR
                           fieldname EQ 'REC_DIR_ID'  OR
                           fieldname EQ 'FIRSTUSE_DATE'  OR
                           fieldname EQ 'FIRSTUSE_DOCTYPE'  OR
                           fieldname EQ 'FIRSTUSE_DOCID'  OR
                           fieldname EQ 'LASTUSE_DOCTYPE'  OR
                           fieldname EQ 'LASTUSE_DOCID'  OR
                           fieldname EQ 'FIRSTUSE_PAYRUN'  OR
                           fieldname EQ 'ORGF1'  OR
                           fieldname EQ 'ORGF2'  OR
                           fieldname EQ 'ORGF3'  OR
                           fieldname EQ 'ORGF4'  OR
                           fieldname EQ '/SAPF15/F15_BW'  OR
                           fieldname EQ '/SAPF15/F15_KZ'  OR
                           fieldname EQ '/SAPF15/GUID'  OR
                           fieldname EQ 'CONTRACT_ID'  OR
                           fieldname EQ 'CONTRACT_DESC'  OR
                           fieldname EQ 'BANK_CRDTR'  OR
                           fieldname EQ 'LAND1_DDMA'  OR
                           fieldname EQ 'PROC_DDMA'  OR
                           fieldname EQ 'BANKS_DDMA'  OR
                           fieldname EQ 'BANKL_DDMA'  OR
                           fieldname EQ 'BANKN_DDMA'  OR
                           fieldname EQ 'BKONT_DDMA'  OR
                           fieldname EQ 'BKREF_DDMA'  OR
                           fieldname EQ 'HBKID_DDMA'  OR
                           fieldname EQ 'HKTID_DDMA'  OR
                           fieldname EQ 'LAUFD'  OR
                           fieldname EQ 'LAUFI'  OR
                           fieldname EQ 'LIMIT_AMOUNT'  OR
                           fieldname EQ 'LIMIT_CURR'  OR
                           fieldname EQ 'LIMIT_NUMBER'  OR
                           fieldname EQ 'LIMIT_UNIT'  OR
                           fieldname EQ 'LIMIT_START_DATE'.
ENDFORM.
