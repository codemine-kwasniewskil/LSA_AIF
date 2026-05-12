"Name: \PR:RFEBBU00\FO:FBRA_POSTING\SE:BEGIN\EI
ENHANCEMENT 0 Z_FI_FBRA_RFEBBU00_S1.
* es werden getrennt Einträge, die zum Ausgleich gehören "SELFD = AUGBL"
* darf nicht verwendet werden, deswegen jetzt mit
* SELFD = BELNR  und  SELVON = XXXXXXXXXXJJJJA
*-------------------------------------------------------------------
  types: begin of t_bel_orig,
          selfd type FELDN_F05A,
          selvon type SEL01_F05A_C25,
*           bukrs TYPE BUKRS,
*           belnr TYPE BELNR_D,
*           gjahr TYPE gjahr,
*          buzei TYPE BUZEI,
*          koart type koart.
*  alle ausgeglichenen Belege
      belege type ZFI_F_BELPOS_T,
*  alle Zahlungsbelege aus den "anderen" Bukrs
       zbelege type ZFI_F_ZBELEG_T.
  types: end of t_bel_orig.

  DATA:   BEGIN OF XFEBCL1 OCCURS 1.
            INCLUDE STRUCTURE FEBCL.
  DATA:   END OF XFEBCL1.
*
  DATA:   BEGIN OF XFEBCL2 OCCURS 14.
            INCLUDE STRUCTURE FEBCL.
  DATA:   END OF XFEBCL2.
  DATA:   gv_lines TYPE INTEGER.
  DATA:   gs_ikofi TYPE IKOFI.

  DATA:   gv_bukrs TYPE FEBKO-BUKRS,
          gv_belnr TYPE BELNR_D,
          gv_gjahr TYPE BKPF-gjahr,
          gv_buzei TYPE BSEG-BUZEI,
          gv_AUGBL TYPE BSEG-AUGBL.

  data:   gv_belnr_orig TYPE BELNR_D,
          gv_gjahr_orig type gjahr.

 data:  lt_bel_orig_fb type ZFI_F_BELPOS_T,
        lt_zbel_fb type ZFI_F_ZBELEG_T,
        ls_bel_orig type t_bel_orig,
        lt_bel_orig type standard table of t_bel_orig.

field-symbols: <fs_bel_orig> type t_bel_orig,
               <fs_bel_orig_fb> type ZFI_F_BELPOS.




  LOOP AT xfebcl ASSIGNING <fs_xfebcl> WHERE selfd = 'BELNR' AND selvon NE '*'.
    if <fs_xfebcl>-SELVON+14(1) ne 'A'.
*    clear: gv_bukrs, gv_buzei, gv_augbl.
    gv_belnr = <fs_xfebcl>-SELVON.
    gv_gjahr = <fs_xfebcl>-SELVON+10(4).

*-------------------------------------------------------------------
* Für die Umsetzung der StornoBelegnummer in FEBEP wg. buchungskreis
* übergreifender Buchung wird
* wie in Standardteil- wird das Gjahr aus Last Clearing document
* bestimmt
*------------------------------------------------------------------
       SELECT * FROM bkpf
        WHERE bukrs = febko-bukrs
        AND   belnr = gv_belnr
        ORDER BY PRIMARY KEY.   "last clearing document
      ENDSELECT.
*-------------------------------------------------------------------
*   bei der Rückläuferbuchung muss der Storno Beleg von dem 7000
*   Beleg ermittelt werden, deswegen müssen wird den merken
*   der Storno Beleg wird am Ende in die FEBEP eingetragen
*   MERKEN - findet nur einmalig statt
*-------------------------------------------------------------------
      if gv_belnr_orig is initial.
      if ikofi-eigr2 = '2' and
         ikofi-attr2 = '9' and
          ikofi-STGRD is not initial.
         gv_belnr_orig = bkpf-belnr.
         gv_gjahr_orig = bkpf-gjahr.
      endif.
      endif.
*-------------------------------------------------------------------

***    DATA: ls_BSAS TYPE BSAS.
***    SELECT * FROM BSAS INTO ls_BSAS WHERE BELNR = gv_belnr
***                                      AND BUKRS = febko-bukrs
***                                      AND GJAHR = gv_gjahr.
***      gv_AUGBL = ls_BSAS-AUGBL.
***    ENDSELECT.
***
****-------------------------------------------------------------------
**** --> ab hier ist gv_belnr die Belegnummer der ursprünglichen Forderung
****    die am Ende eine Zahlsperre bekommen soll
****-------------------------------------------------------------------
***    CALL FUNCTION 'ZFI_FEB_GET_KREDIT_LINE'
***      EXPORTING
***        i_bukrs         = febko-bukrs
***        i_belnr         = gv_belnr
***        i_gjahr         = gv_gjahr
***      IMPORTING
***        E_BUKRS         = gv_bukrs
***        E_BELNR         = gv_belnr
***        E_GJAHR         = gv_gjahr
***        E_BUZEI         = gv_buzei
***      EXCEPTIONS
***        NOT_FOUND       = 1
***        OTHERS          = 2
***          .
***    IF sy-subrc <> 0.
****     Implement suitable error handling here
***    ENDIF.


call function '/THKR/FEB_GET_KREDIT_LINE'
  exporting
    i_bukrs           = febko-bukrs
    i_belnr           = gv_belnr
    i_gjahr           = gv_gjahr
*   IMPORTING
*        E_BUKRS         = gv_bukrs
***        E_BELNR         = gv_belnr
***        E_GJAHR         = gv_gjahr
  changing
    ct_bel_orig       = lt_bel_orig_fb
    ct_zbeleg         = lt_zbel_fb
 EXCEPTIONS
   NOT_FOUND         = 1
   OTHERS            = 2
          .
if sy-subrc <> 0.
* Implement suitable error handling here
endif.
      ls_bel_orig-selfd = <fs_xfebcl>-selfd.
      ls_bel_orig-selvon = <fs_xfebcl>-selvon.
      ls_bel_orig-belege =  lt_bel_orig_fb.
       ls_bel_orig-zbelege =  lt_zbel_fb.
      append ls_bel_orig to lt_bel_orig.
*      loop at lt_bel_orig_fb assigning <fs_bel_orig_fb>.
*        ls_bel_orig-belnr = <fs_bel_orig_fb>-belnr.
*        ls_bel_orig-bukrs = <fs_bel_orig_fb>-bukrs.
*        ls_bel_orig-gjahr = <fs_bel_orig_fb>-gjahr.
*        ls_bel_orig-buzei = <fs_bel_orig_fb>-buzei.
*        ls_bel_orig-koart = <fs_bel_orig_fb>-koart.
*         append ls_bel_orig to lt_bel_orig.
*      endloop.
    endif. "Repro-Roc
  ENDLOOP.

* REPRO-ROC20210208-neu
*****  LOOP AT xfebcl WHERE ( selfd = 'AUGBL' )
*****                     AND selvon NE '*'.
*****    APPEND xfebcl TO xfebcl2.
*****  ENDLOOP.
*****
*****  gs_ikofi = ikofi.
*****  DESCRIBE TABLE xfebcl2 LINES gv_lines.
*****  IF gv_lines > 0.
*****
*****    DELETE xfebcl WHERE ( selfd = 'AUGBL' )
*****                      AND selvon NE '*'.
*****
*****    LOOP AT xfebcl WHERE ( selfd = 'BELNR' )
*****                       AND selvon NE '*'.
*****      APPEND xfebcl TO xfebcl1.
*****    ENDLOOP.
*****    DELETE xfebcl WHERE ( selfd = 'BELNR' )
*****                      AND selvon NE '*'.
*****
*****    LOOP AT xfebcl2.
*****      APPEND xfebcl2 TO xfebcl.
*****      DELETE xfebcl2.
*****      EXIT.
*****    ENDLOOP.
*------------------------------------------------------*
* REPRO-ROC20210223
* Es können max. 2 Belege ausgeglichen sein.
* Rechnung mit dem Rückläufer
* der Ausgleich auf dem Zwischenkonto
*------------------------------------------------------*
* nehmen die zusätzlichen Ausgleiche in eine extra Tabelle
*------------------------------------------------------*
   gs_ikofi = ikofi.
   LOOP AT xfebcl   WHERE ( selfd = 'BELNR' )
                     AND selvon NE '*'.
    if xfebcl-SELVON+14(1) = 'A'.
    APPEND xfebcl TO xfebcl2.
    delete xfebcl . "REPRO-ROC20210223
    endif.
  ENDLOOP.

    DESCRIBE TABLE xfebcl2 LINES gv_lines.
*    IF gv_lines > 0.
*------------------------------------------------------
* Löschen integriert siehe oben* REPRO-ROC20210223
*------------------------------------------------------
**   LOOP AT xfebcl   WHERE ( selfd = 'BELNR' )
**                     AND selvon NE '*'.
**    if xfebcl-SELVON+14(1) = 'A'.
**    delete xfebcl .
**    endif.
**  ENDLOOP.


**    LOOP AT xfebcl WHERE ( selfd = 'BELNR' )
**                       AND selvon NE '*'.
**      if xfebcl-SELVON+14(1) ne 'A'.
**      APPEND xfebcl TO xfebcl1.
**      DELETE xfebcl.
**      endif.
**    ENDLOOP.
**
***-------------------------------------------------------------------
*** 1 Satz bleibt in der Standardtabelle xfebcl
***-------------------------------------------------------------------
**    LOOP AT xfebcl2.
**      APPEND xfebcl2 TO xfebcl.
**      DELETE xfebcl2.
**      EXIT.
**    ENDLOOP.


*-------------------------------------------------------------------
* Zuerst alle "Ausgleichbelege" bearbeiten
* Es wird nur ein Eintrag erwartet
*-------------------------------------------------------------------

    LOOP AT xfebcl2 WHERE ( selfd = 'AUGBL'
                         OR selfd = 'BELNR' )
                        AND selvon NE '*'.                     "n1622292

      augbl = xfebcl2-selvon(10).   "AFLE leftadjusted confirmed
      belns = xfebcl2-selvon(10).   "AFLE leftadjusted confirmed

      SELECT * FROM bkpf                 "Depner, 270597
        WHERE bukrs = febko-bukrs        "Depner, 270597
        AND   belnr = belns     "Depner, 270597
        ORDER BY PRIMARY KEY.            "last clearing document
      ENDSELECT.                         "Depner, 270597
*
*      EXIT.
*    ENDLOOP.
*
      IF sy-subrc = 0 OR mode = 'A' OR mode = 'E'.              "n1321162
*************************************************************************
***    Begin of comment                           C5053248
*************************************************************************
**    perform fbra_posting_aufrufen.
*************************************************************************
****    End of comment                            C5053248
*************************************************************************
*************************************************************************
****    Begin of ALV Conversion                   C5053248
*************************************************************************
        PERFORM fbra_posting_aufrufen CHANGING xt_fb01.
        ikofi = gs_ikofi.
*************************************************************************
****    End of ALV Conversion                     C5053248
*************************************************************************
      ELSE.
        CLEAR vb_error.
        vb_error-anwnd = febko-anwnd.
        vb_error-absnd = febko-absnd.
        vb_error-azidt = febko-azidt.
        vb_error-ktonr = febko-ktonr.
        vb_error-aznum = febko-aznum.
        vb_error-esnum = febep-esnum.
        vb_error-buber = bereich.
        vb_error-zeile = TEXT-034.
        APPEND vb_error.
        statist-error = statist-error + 1.
      ENDIF.
    ENDLOOP.
*  ENDIF.
*
ENDENHANCEMENT.
