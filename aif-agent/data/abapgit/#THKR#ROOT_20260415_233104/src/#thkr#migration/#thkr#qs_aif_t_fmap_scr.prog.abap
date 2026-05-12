*&---------------------------------------------------------------------*
*& Include          /THKR/QS_AIF_T_FMAP_SCR
*&---------------------------------------------------------------------*
*&                                                                     *
*& Autor:    Frank Brähler (Orexes GmbH) (ZHM000000307)                *
*& Erstellt am: 05.05.2025                                             *
*&                                                                     *
*& l. Änderer : Frank Brähler (ZHM000000307)                           *
*& l. Datum   : 15.05.2025                                             *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& TOP - Inlcude für /THKR/QS_AIF_T_FMAP                               *
*&                                                                     *
*& Definitionen Startbildschirm                                        *
*&                                                                     *
*&---------------------------------------------------------------------*
*& Änderungshistorie:                                                  *
*& Datum    Änderer      Beschreibung                                  *
*& -------- ------------ --------------------------------------------- *
*& 20250505 ZHM000000307 Anlage des Reports                            *
*&                                                                     *
*&---------------------------------------------------------------------*

************************************************************************
* Selektonsbildschirm festlegen                                        *
************************************************************************
  SELECTION-SCREEN BEGIN OF BLOCK sm001 WITH FRAME TITLE TEXT-f01.
    SELECTION-SCREEN SKIP.
    PARAMETERS: pa_ns TYPE /aif/ns OBLIGATORY DEFAULT 'FREMDV'.
    SELECT-OPTIONS so_field FOR gs_t_fmap-fieldname.
    SELECTION-SCREEN SKIP.
    SELECTION-SCREEN BEGIN OF BLOCK sm002 WITH FRAME TITLE TEXT-f02.
      SELECTION-SCREEN BEGIN OF LINE.
        SELECTION-SCREEN COMMENT (28) lc_coll FOR FIELD pa_coll.
        PARAMETERS: pa_coll TYPE xflag AS CHECKBOX DEFAULT 'X'.
      SELECTION-SCREEN END OF LINE.
    SELECTION-SCREEN END OF BLOCK sm002.
  SELECTION-SCREEN END OF BLOCK sm001.
