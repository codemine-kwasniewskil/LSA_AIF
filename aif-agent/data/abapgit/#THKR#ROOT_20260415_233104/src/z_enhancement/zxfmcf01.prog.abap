*&---------------------------------------------------------------------*
*& Include          ZXFMCF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_KASSENZEICHEN
*&---------------------------------------------------------------------*
*& Kassenzeichen für Allgemeine Annahme-Anordnungen ermitteln(Header)
*& Nur für Belegart 'EE'
*&---------------------------------------------------------------------*
*&      <-- T_KBLD
*&---------------------------------------------------------------------*
FORM set_kassenzeichen  TABLES  p_t_kbld STRUCTURE kbld CHANGING p_kblk TYPE kblk .

*
*  DATA: lv_subrc TYPE sy-subrc,
*        lv_gjahr TYPE gjahr.
*  DATA: lv_kaz type /THKR/D_KASSENZEICHEN,
*        lv_rc  type NRRETURN.

*
*  CHECK p_kblk-blart = 'AN'.
*break zhm000000091.
**
*  READ TABLE p_t_kbld ASSIGNING FIELD-SYMBOL(<ls_kbld>) INDEX 1.
*  CHECK <ls_kbld> IS ASSIGNED.
*  lv_gjahr = p_kblk-budat(4).
*  IF p_kblk-xblnr IS INITIAL.
*      CALL METHOD /thkr/cl_kassenzeichen=>create
*        EXPORTING
*          i_fonds = <ls_kbld>-geber
*          i_gsber = <ls_kbld>-gsber
*          i_nrnr  = '00'
*         IMPORTING
*           e_kaz   = lv_kaz
*           e_rc    = lv_rc
*          .
*      p_kblk-xblnr = lv_kaz.

*    CALL FUNCTION 'Z_PSM_CREATE_KASSENZEICHEN'
*      EXPORTING
*        im_fistl         = <ls_kbld>-fistl
*        im_gjahr         = lv_gjahr  "<ls_kbld>-rgjahr  "woher das jahr nehmen!!!!!
*        im_nrnr          = '00'
*      IMPORTING
*        ex_kassenzeichen = p_kblk-xblnr
*        ex_rc            = lv_subrc
*      EXCEPTIONS
*        wrong_dienst     = 1
*        wrong_checkno    = 2
*        wrong_number     = 3
*        wrong_gjahr      = 4
*        OTHERS           = 5.
*    IF sy-subrc <> 0.
*      MESSAGE e104(z_tpbr).
*      " Fehler Kassenzeichen ermitteln.
*      " Fehlermeldung prüfen, ob sie hier ausgegeben werden
*
*    ENDIF.

*  ELSE.
** Pflichtfelder bei PARK
*    IF ( SY-UCOMM = 'PARK' ).
*      CALL FUNCTION 'Z_PSM_CHECK_KASSENZEICHEN'
*        EXPORTING
*          im_kassenzeichen = <ls_kbld>-xblnr
*          im_fistl         = <ls_kbld>-fistl
*          im_gjahr         = <ls_kbld>-rgjahr
**         IM_NEW           = ' '
*        IMPORTING
*          ex_kassenzeichen = p_kblk-xblnr
*          ex_rc            = lv_subrc
*        EXCEPTIONS
*          wrong_length     = 1
*          wrong_dienst     = 2
*          wrong_checkno    = 3
*          wrong_number     = 4
*          OTHERS           = 5.
*      IF sy-subrc <> 0.
*        " Fehlermeldung prüfen, ob sie hier ausgegeben werden
*        MESSAGE e104(z_tpbr).
** Fehler Kassenzeichen ermitteln.
*      ENDIF.
*    ENDIF.
*  endif.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_KASSENZEICHEN_POS
*&---------------------------------------------------------------------*
*& Kassenzeichen für Allgemeine Annahme-Anordnungen ermitteln(POS)
*& Nur für Belegart 'EE'
*&---------------------------------------------------------------------*
*&      --> F_KBLD
*&---------------------------------------------------------------------*
*& 2025-04-02 js - Übernahme eines bestehenden Kassenzeichens

FORM set_kassenzeichen_pos CHANGING   p_f_kbld TYPE kbld.

  DATA: lv_gjahr  TYPE gjahr,
        lv_subrc  TYPE sy-subrc,
        lv_string TYPE string.
  DATA: lv_kaz type /THKR/D_KASSENZEICHEN,
        lv_rc  type NRRETURN.
  FIELD-SYMBOLS: <lv_xblnr> TYPE xblnr.

  CHECK p_f_kbld-blart = 'AN'.
  IF p_f_kbld-xblnr IS INITIAL.
    lv_gjahr = p_f_kbld-budat(4).
      CALL METHOD /thkr/cl_kassenzeichen=>create
        EXPORTING
          i_fonds = p_f_kbld-geber
          i_gsber = p_f_kbld-gsber
          i_nrnr  = '00'
         IMPORTING
           e_kaz   = lv_kaz
           e_rc    = lv_rc
          .
      set parameter id '/THKR/KLSA841_KBLK' field lv_kaz.
      p_f_kbld-xblnr = lv_kaz.
    ELSE.         " 2025-04-02 js
      set parameter id '/THKR/KLSA841_KBLK' field p_f_kbld-xblnr.
    ENDIF.
*    CALL FUNCTION 'Z_PSM_CREATE_KASSENZEICHEN'
*      EXPORTING
*        im_fistl         = p_f_kbld-fistl
*        im_gjahr         = lv_gjahr  "  "woher das jahr nehmen!!!!!
*        im_nrnr          = '00'
*      IMPORTING
*        ex_kassenzeichen = p_f_kbld-xblnr
*        ex_rc            = lv_subrc
*      EXCEPTIONS
*        wrong_dienst     = 1
*        wrong_checkno    = 2
*        wrong_number     = 3
*        wrong_gjahr      = 4
*        OTHERS           = 5.
*    IF sy-subrc <> 0.
*      MESSAGE e104(z_tpbr).
*      " Fehler Kassenzeichen ermitteln.
*      " Fehlermeldung prüfen, ob sie hier ausgegeben werden
*    ELSE.
*      lv_string = '(SAPLFMFR)F_KBLK-XBLNR'.
*      ASSIGN (lv_string) TO <lv_xblnr>.
*      IF sy-subrc = 0.
*        <lv_xblnr> = p_f_kbld-xblnr.
*      ENDIF.
*
*    ENDIF.
*
*  ELSE.
*    IF ( SY-UCOMM = 'PARK' ).
*    CALL FUNCTION 'Z_PSM_CHECK_KASSENZEICHEN'
*      EXPORTING
*        im_kassenzeichen = p_f_kbld-xblnr
*        im_fistl         = p_f_kbld-fistl
*        im_gjahr         = lv_gjahr
**       IM_NEW           = ' '
*      IMPORTING
*        ex_kassenzeichen = p_f_kbld-xblnr
*        ex_rc            = lv_subrc
*      EXCEPTIONS
*        wrong_length     = 1
*        wrong_dienst     = 2
*        wrong_checkno    = 3
*        wrong_number     = 4
*        OTHERS           = 5.
**    IF sy-subrc <> 0.
**      " Fehlermeldung prüfen, ob sie hier ausgegeben werden
**      MESSAGE e104(z_tpbr).
*** Fehler Kassenzeichen ermitteln.
**    ENDIF.
**  ENDIF.
** 2021.0513 BTO Fehlermeldung differenzierter ausgeben
*    IF sy-subrc <> 0.
*      CASE sy-subrc .
*        WHEN 1.
*          MESSAGE e106(z_tpbr).
*        WHEN 2.
*          MESSAGE e107(z_tpbr).
*        WHEN 3.
*          MESSAGE e108(z_tpbr).
*        WHEN 4.
*          MESSAGE e109(z_tpbr).
*        WHEN 5.
*          MESSAGE e111(z_tpbr).
*        WHEN OTHERS.
*          MESSAGE e105(z_tpbr).
*      ENDCASE.
*    endif.
*  endif.
*endif.
ENDFORM.
