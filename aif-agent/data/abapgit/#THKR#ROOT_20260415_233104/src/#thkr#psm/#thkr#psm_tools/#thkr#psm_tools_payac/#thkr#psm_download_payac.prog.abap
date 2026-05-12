*&---------------------------------------------------------------------*
*& Report Z_PSM_DOWNLOAD_PAYAC
*&---------------------------------------------------------------------*
*& Download PAYAC
*&---------------------------------------------------------------------*
REPORT /thkr/psm_download_payac MESSAGE-ID /thkr/fi_init.


*** Includes

* Top
INCLUDE /thkr/psm_download_payac_top.

* Selektion
INCLUDE /thkr/psm_download_payac_sel.

* Forms
INCLUDE /thkr/psm_download_payac_f01.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_datnam.
* ---
  PERFORM f4_datnam
    CHANGING
      p_datnam.

* Prüfungen
AT SELECTION-SCREEN.
* ---
  PERFORM pruef_datnam
    USING
      p_datnam.
* ---
  PERFORM pruef_gjahr_neu
    USING
      p_f_jw
      p_gjahr
      p_gj_neu.

START-OF-SELECTION.

  PERFORM selektion
    USING
      p_fikrs
      p_gjahr
      p_druck
    CHANGING
      gv_dbcnt_alle.

*
  PERFORM selektion_zu_download
    USING
      p_f_jw
      p_gjahr
      p_gj_neu
      p_maxlin.

*
  IF ( p_test IS INITIAL ).
* ---
    PERFORM download
      USING
        p_datnam
      CHANGING
        gv_dl_subrc.
*
  ENDIF.

END-OF-SELECTION.

  WRITE: 'DB Total:', gv_dbcnt_alle COLOR COL_TOTAL INTENSIFIED OFF.
  ULINE.
  IF ( gv_dl_subrc = 0 ).
    WRITE: 'Done' COLOR COL_POSITIVE INTENSIFIED OFF.
  ELSE.
    WRITE: 'Fehlercode:', gv_dl_subrc COLOR COL_NEGATIVE INTENSIFIED OFF.
  ENDIF.
*
  ULINE.
