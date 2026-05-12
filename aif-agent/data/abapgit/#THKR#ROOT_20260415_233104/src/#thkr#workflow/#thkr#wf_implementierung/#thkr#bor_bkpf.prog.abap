*****           Implementation of object type /THKR/BKPF           *****
INCLUDE <object>.
BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
  BEGIN OF KEY,
      COMPANYCODE LIKE BKPF-BUKRS,
      DOCUMENTNO LIKE BKPF-BELNR,
      FISCALYEAR LIKE BKPF-GJAHR,
  END OF KEY.
END_DATA OBJECT. " Do not change.. DATA is generated

******************** DATENDEKLARATIONEN ***************************
CONSTANTS: gc_x  TYPE c LENGTH 1 VALUE 'X',
           gc_i  TYPE c LENGTH 1 VALUE 'I',
           gc_eq TYPE c LENGTH 2 VALUE 'EQ'.


********************************* FORMS ***************************
FORM change_status USING uv_status TYPE /thkr/dte_fi_wf_status
                          uv_uname TYPE syuname
                          uv_process TYPE c.

  DATA ls_fb02 TYPE /thkr/fb02c.
  DATA lt_fb02 TYPE TABLE OF /thkr/fb02c.
  FIELD-SYMBOLS  <fs_fb02> TYPE /thkr/fb02c.

  DATA ls_storno TYPE /THKR/STORNOC.
  DATA lt_storno TYPE TABLE OF /THKR/STORNOC.
  FIELD-SYMBOLS  <fs_storno> TYPE /THKR/STORNOC.

  CASE uv_process .
    WHEN 'C'.

      " vorhandene Belege prüfen
      SELECT * INTO TABLE @lt_fb02 FROM /thkr/fb02c
                                   WHERE bukrs = @object-key-companycode
                                     AND belnr = @object-key-documentno
                                     AND gjahr = @object-key-fiscalyear
                                     AND ( status NE 40 AND
                                           status NE 70 AND
                                           status NE 80 ).
      IF sy-subrc = 0.

        " Sortierung nach der laufenden Nummer
        SORT lt_fb02 BY lfdnr DESCENDING buzei ASCENDING.

        " Lesen und ändern des/der aktuellen Satzes/Sätze
        LOOP AT lt_fb02 ASSIGNING <fs_fb02>.
          AT FIRST.
            " Relevante lfd. Nummer
            DATA(lv_lfdnr) = <fs_fb02>-lfdnr.
          ENDAT.

          IF lv_lfdnr <> <fs_fb02>-lfdnr.
            " Löschen der überflüssingen Sätze
            DELETE lt_fb02.
          ELSE.
            " Init Felder
            CLEAR: <fs_fb02>-usnam_wf, <fs_fb02>-cpudt_wf, <fs_fb02>-cputm_wf.
            " Übergabe der neuen Werte
            <fs_fb02>-status =  uv_status.
            <fs_fb02>-usnam_wf = uv_uname.
            <fs_fb02>-cpudt_wf = sy-datum.
            <fs_fb02>-cputm_wf = sy-uzeit.
          ENDIF.
        ENDLOOP.

        " Zurückschreiben der Änderung
        MODIFY /thkr/fb02c FROM TABLE lt_fb02 .

      ENDIF.

    WHEN 'S'.
      "!!!STORNO!!!
      " vorhandene Belege prüfen
      SELECT * INTO TABLE @lt_storno FROM /THKR/stornoc
                                     WHERE bukrs = @object-key-companycode
                                       AND modul = 'FI'
                                       AND belnr = @object-key-documentno
                                       AND gjahr = @object-key-fiscalyear
                                       AND ( status NE 40 AND
                                             status NE 70 AND
                                             status NE 80 ).
      IF sy-subrc = 0.

        " Sortierung nach der laufenden Nummer
        SORT lt_storno BY lfdnr DESCENDING.
        " Lesen und ändern des aktuellen Satzes
        DATA(lv_changed) = abap_false.
        LOOP AT lt_storno ASSIGNING <fs_storno>.
          IF lv_changed IS INITIAL.
            " Init Felder
            CLEAR: <fs_storno>-usnam_wf, <fs_storno>-cpudt_wf, <fs_storno>-cputm_wf.
            " Setzen der neuen Werte
<fs_storno>-status =  uv_status.
<fs_storno>-usnam_wf = uv_uname.
<fs_storno>-cpudt_wf = sy-datum.
<fs_storno>-cputm_wf = sy-uzeit.
            " Änderung nur am aktuellen Satz
            lv_changed = abap_true.
          ELSE.
            " Lösche Eintrag, braucht nicht zurückgeschrieben werden da keine Änderung
            DELETE lt_storno.
          ENDIF.
        ENDLOOP.

        " Zurückschreiben der Änderung
        MODIFY /THKR/stornoc FROM TABLE lt_storno.

      ENDIF.
*
  ENDCASE.

ENDFORM.

begin_method zchangestatus changing container.
DATA:
  lv_status  TYPE /thkr/fb02c-status,
  lv_user    TYPE wfsyst-agent,
  lv_process TYPE c LENGTH 1.

DATA lv_uname TYPE syuname.

swc_get_element container 'V_STATUS' lv_status.
swc_get_element container 'V_USER' lv_user.
swc_get_element container 'V_PROCESS' lv_process.

* Evtl Umsetzen erforderlich
IF lv_user(2) = 'US'.
  lv_uname = lv_user+2(12).
ELSE.
  lv_uname = lv_user.
ENDIF.


PERFORM change_status USING lv_status
                            lv_uname
                            lv_process.
end_method.

begin_method zgetbasicdata changing container.

DATA: ls_sdata  TYPE /thkr/s_wf_stornodaten,
      lv_betrag TYPE rlwrt,
      lv_gsber  TYPE bseg-gsber,
      lv_fistl  TYPE bseg-fistl,
      lv_fipos  TYPE bseg-fipos,
      lv_budat  TYPE syst-datum.
DATA lt_bseg TYPE TABLE OF bseg.
DATA lt_cdata TYPE /thkr/t_wf_changedaten.
DATA: lv_status type /THKR/DTE_FI_WF_STATUS.

FIELD-SYMBOLS <fs_bseg> TYPE bseg.

SELECT belnr, gsber, koart, kostl, aufnr, prctr, fipos, projk, dmbtr, fistl FROM bseg "#EC CI_NOORDER
       INTO CORRESPONDING FIELDS OF TABLE @lt_bseg
       WHERE belnr  = @object-key-documentno
       AND   bukrs  = @object-key-companycode
       AND   gjahr  = @object-key-fiscalyear.

IF sy-subrc EQ 0.
  LOOP AT lt_bseg ASSIGNING <fs_bseg>.
*    lv_betrag = lv_betrag + <fs_bseg>-dmbtr .
    IF   <fs_bseg>-koart = 'K' OR  <fs_bseg>-koart = 'D'  .
      lv_betrag = lv_betrag + <fs_bseg>-dmbtr .
    ELSE.
      " Geschätsbereich
      IF lv_gsber IS INITIAL.
        lv_gsber  = <fs_bseg>-gsber.
      ENDIF.
      IF lv_fistl IS INITIAL.
        lv_fistl  = <fs_bseg>-fistl.
*        IF lv_fistl IS INITIAL AND <fs_bseg>-aufnr IS NOT INITIAL.
*          " Ermitteln Kostenstelle aus dem Auftrag
*          SELECT SINGLE kostl, kostv INTO @DATA(ls_kostl)
*                 FROM aufk WHERE aufnr EQ @<fs_bseg>-aufnr. "#EC CI_GENBUFF
*          IF sy-subrc EQ 0.
*            " Übername Kostenstelle aus Auftrag
*            IF ls_kostl-kostl IS NOT INITIAL.
*              lv_kostl = ls_kostl-kostl.
*            ELSE.
*              lv_kostl = ls_kostl-kostv.
*            ENDIF.
*          ENDIF.
*        ENDIF.
        " Selektion über Profitcenter auch bei Fehler aus Auftrag
*        IF lv_kostl IS INITIAL AND <fs_bseg>-prctr IS NOT INITIAL.
*          " Ermitteln Kostenstelle zum Profitcenter
*          SELECT SINGLE kostl INTO @DATA(lv_kostl_p) FROM csks WHERE datbi >= @sy-datum "#EC CI_NOORDER "#EC CI_GENBUFF
*                                                                 AND prctr = @<fs_bseg>-prctr.
*          IF sy-subrc = 0.
*            " Übernahme Kostenstelle aus Profitcenter
*            lv_kostl = lv_kostl_p.
*          ENDIF.
*        ENDIF.
        " Selektion über PSP Element auch bei Fehler aus Profitcenter
*        IF lv_kostl IS INITIAL AND <fs_bseg>-projk IS NOT INITIAL.
*          " Ermitteln der Profitcenternummer aus dem PSP Element
*          SELECT SINGLE prctr INTO @DATA(lv_prctr) FROM prps WHERE pspnr = @<fs_bseg>-projk.
*          IF sy-subrc = 0.
*            " Ermitteln Kostenstelle zum Profitcenter
*            SELECT SINGLE kostl INTO @lv_kostl_p FROM csks WHERE datbi >= @sy-datum "#EC CI_NOORDER  "#EC CI_GENBUFF
*                                                             AND prctr = @lv_prctr.
*            IF sy-subrc = 0.
*              " Übernahme Kostenstelle aus Profitcenter
*              lv_kostl = lv_kostl_p.
*            ENDIF.
*          ENDIF.
*        ENDIF.
      ENDIF.
    ENDIF.
    " Finanzposition
    IF lv_fipos IS INITIAL.
      IF <fs_bseg>-fistl IS NOT INITIAL.
        lv_fipos  = <fs_bseg>-fipos.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDIF.
"!!!STORNO!!!
" Ermittlung der Stornodaten für die Beschreibung
CLEAR ls_sdata.
SELECT lfdnr, stgrd, budat, monat, cpudt, STATUS INTO TABLE @DATA(lt_sdata)
              FROM /thkr/stornoc
              WHERE bukrs = @object-key-companycode
                AND modul = 'FI'
                AND belnr = @object-key-documentno
                AND gjahr = @object-key-fiscalyear.
IF sy-subrc = 0.
  " Ermitteln des aktuellen Satzes
  SORT lt_sdata BY lfdnr DESCENDING.
  READ TABLE lt_sdata ASSIGNING FIELD-SYMBOL(<ls_sdata>) INDEX 1.
  IF sy-subrc = 0.
    MOVE-CORRESPONDING <ls_sdata> TO ls_sdata.
    lv_status = <ls_sdata>-status.
  ENDIF.
ENDIF.
*
*" Ermittlung der Änderungsdaten für die Beschreibung
FREE lt_cdata.
*" Nur wenn Stornodaten leer sind
IF ls_sdata IS INITIAL.
  " Ermittlung und Aufbereitung Änderungen
  CALL FUNCTION '/THKR/WF_GET_CHANGES'
    EXPORTING
      iv_bukrs   = object-key-companycode
      iv_belnr   = object-key-documentno
      iv_gjahr   = object-key-fiscalyear
    IMPORTING
      et_changes = lt_cdata.
ENDIF.


swc_set_element container 'V_BETRAG' lv_betrag.
swc_set_element container 'V_GSBER' lv_gsber.
swc_set_element container 'V_FISTL' lv_fistl.
swc_set_element container 'V_FIPOS' lv_fipos.
swc_set_element container 'S_SDATA' ls_sdata.
swc_set_table   container 'T_CDATA' lt_cdata.
swc_set_element container 'V_STATUS' lv_status.

end_method.

begin_method zbelegchange_bg changing container.
DATA:
  lv_xsubrc TYPE syst-subrc.

* BelegDaten zusammenstellen
* Änderungen einpflegen

DATA lt_kopf TYPE TABLE OF /thkr/fb02c.
DATA lt_bseg TYPE bseg_t.
DATA ls_bseg TYPE bseg.
DATA ls_bkpf TYPE bkpf.
DATA lt_bkpf TYPE TABLE OF bkpf.
DATA lt_accchg TYPE TABLE OF accchg.
DATA ls_accchg TYPE accchg.
DATA lv_kopf TYPE xflag.
DATA lv_pos  TYPE xflag.
DATA ls_return TYPE bapiret2.
DATA: lt_fb02_text TYPE STANDARD TABLE OF /thkr/fb02c_text.



DATA: ls_bkpf_old TYPE bkpf,
      lt_bseg_old TYPE STANDARD TABLE OF fbseg,
      lt_bseg_new TYPE STANDARD TABLE OF fbseg,
      lv_objectid TYPE cdobjectv,
      lv_kopf_upd TYPE cdchngind,
      lv_pos_upd  TYPE cdchngind.

FIELD-SYMBOLS: <fs_kopf> TYPE /thkr/fb02c,
               <fs_bseg> TYPE bseg.

* vorhandene genehmigte  Belege prüfen
SELECT * FROM /thkr/fb02c                     "#EC CI_ALL_FIELDS_NEEDED
INTO TABLE @lt_kopf
WHERE bukrs = @object-key-companycode
AND   belnr =  @object-key-documentno
AND   gjahr = @object-key-fiscalyear
AND   status EQ '50'.                     "Genehmigt





SELECT SINGLE * FROM bkpf INTO @ls_bkpf       "#EC CI_ALL_FIELDS_NEEDED
WHERE belnr  = @object-key-documentno
AND   bukrs  = @object-key-companycode
AND   gjahr  = @object-key-fiscalyear.


LOOP AT lt_kopf ASSIGNING <fs_kopf>.

  SELECT * FROM /thkr/fb02c_text
  INTO TABLE @lt_fb02_text
WHERE bukrs = @object-key-companycode
AND   belnr =  @object-key-documentno
AND   gjahr = @object-key-fiscalyear
    AND lfdnr = @<fs_kopf>-lfdnr.

  IF ls_bkpf-bktxt NE <fs_kopf>-bktxt.
    ls_accchg-fdname = 'BKPF-BKTXT'.
    ls_accchg-oldval = ls_bkpf-bktxt. ls_accchg-newval = <fs_kopf>-bktxt.
    APPEND ls_accchg TO lt_accchg.
    lv_kopf = gc_x.
    " Änderungsbelegtrigger
    lv_kopf_upd = 'U'.
  ENDIF.

  IF ls_bkpf-xblnr NE <fs_kopf>-xblnr.
    ls_accchg-fdname = 'BKPF-XBLNR'.
    ls_accchg-oldval = ls_bkpf-xblnr. ls_accchg-newval = <fs_kopf>-xblnr.
    APPEND ls_accchg TO lt_accchg.
    lv_kopf = gc_x.
    " Änderungsbelegtrigger
    lv_kopf_upd = 'U'.
  ENDIF.

  " Sichern des alten Standes für Änderungsbelege
  ls_bkpf_old = ls_bkpf.

  ls_bkpf-bktxt = <fs_kopf>-bktxt.
  ls_bkpf-xblnr = <fs_kopf>-xblnr.
  APPEND ls_bkpf TO lt_bkpf.

  CALL FUNCTION 'READ_BSEG'
    EXPORTING
      xbelnr         = object-key-documentno
      xbukrs         = object-key-companycode
      xbuzei         = <fs_kopf>-buzei
      xgjahr         = object-key-fiscalyear
      no_auth_check  = 'X'
    IMPORTING
*     XBSEC          =
*     XBSED          =
      xbseg          = ls_bseg
*     XBSEGA         =
    EXCEPTIONS
      key_incomplete = 1
      not_authorized = 2
      not_found      = 3
      OTHERS         = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  ls_bseg-zlspr = <fs_kopf>-zlspr.
  ls_bseg-mansp = <fs_kopf>-mansp.
  ls_bseg-manst = <fs_kopf>-manst.
*  IF ls_bseg-koart = 'K'.
  ls_bseg-bvtyp = <fs_kopf>-bvtyp.                    " Partnerbank
*  ENDIF.

  IF <fs_kopf>-zlsch_k IS NOT INITIAL .
    ls_bseg-zlsch = <fs_kopf>-zlsch_k.
  ENDIF.
  IF <fs_kopf>-zlsch_d IS NOT INITIAL .
    ls_bseg-zlsch = <fs_kopf>-zlsch_d.
  ENDIF.

  ls_bseg-zterm = <fs_kopf>-zterm.
  ls_bseg-zfbdt = <fs_kopf>-zfbdt.
  ls_bseg-zbd1t = <fs_kopf>-zbd1t.
  ls_bseg-zbd2t = <fs_kopf>-zbd2t.
  ls_bseg-zbd3t = <fs_kopf>-zbd3t.
  ls_bseg-zbd1p = <fs_kopf>-zbd1p.
  ls_bseg-zbd2p = <fs_kopf>-zbd2p.

  IF ls_bseg-koart = 'D'.

    ls_bseg-madat = <fs_kopf>-madat.
    ls_bseg-mschl = <fs_kopf>-mschl.
    ls_bseg-maber = <fs_kopf>-maber.
    ls_bseg-hbkid = <fs_kopf>-hbkid.


  ENDIF.

  IF ls_bseg-zlsch IS NOT INITIAL AND <fs_kopf>-zlsch_d IS INITIAL AND <fs_kopf>-zlsch_k IS INITIAL.
    CLEAR ls_bseg-zlsch.
  ENDIF.

  SELECT * FROM bseg INTO TABLE lt_bseg       "#EC CI_ALL_FIELDS_NEEDED
  WHERE    belnr  = object-key-documentno               "#EC CI_NOORDER
  AND      bukrs  = object-key-companycode
  AND      gjahr  = object-key-fiscalyear.

  READ TABLE  lt_bseg WITH KEY buzei = <fs_kopf>-buzei ASSIGNING <fs_bseg> .
  IF sy-subrc EQ 0.

    " Sichern des unveränderten Satzes
    APPEND INITIAL LINE TO lt_bseg_old ASSIGNING FIELD-SYMBOL(<ls_bseg_old>).
    MOVE-CORRESPONDING <fs_bseg> TO <ls_bseg_old>.

*   Aufbereiten  Änderungsdaten
    IF <fs_bseg>-zlspr NE <fs_kopf>-zlspr.
      CONCATENATE <fs_kopf>-buzei 'BSEG-ZLSPR' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-zlspr. ls_accchg-newval = <fs_kopf>-zlspr.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.
    IF <fs_bseg>-zlsch NE ls_bseg-zlsch.
      CONCATENATE <fs_kopf>-buzei 'BSEG-ZLSCH' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-zlsch. ls_accchg-newval = ls_bseg-zlsch.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.
    IF <fs_bseg>-mansp NE <fs_kopf>-mansp.
      CONCATENATE <fs_kopf>-buzei 'BSEG-MANSP' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-mansp. ls_accchg-newval = <fs_kopf>-mansp.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.
    IF <fs_bseg>-manst NE <fs_kopf>-manst.
      CONCATENATE <fs_kopf>-buzei 'BSEG-MANST' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-manst. ls_accchg-newval = <fs_kopf>-manst.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.
    IF <fs_bseg>-bvtyp NE <fs_kopf>-bvtyp.            " Partnerbank
      CONCATENATE <fs_kopf>-buzei 'BSEG-BVTYP' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-bvtyp. ls_accchg-newval = <fs_kopf>-bvtyp.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.

    "Zahlungsschlüssel
    IF <fs_bseg>-zterm NE <fs_kopf>-zterm.
      CONCATENATE <fs_kopf>-buzei 'BSEG-ZTERM' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-zterm. ls_accchg-newval = <fs_kopf>-zterm.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.
    "Basisdatum
    IF <fs_bseg>-zfbdt NE <fs_kopf>-zfbdt.
      CONCATENATE <fs_kopf>-buzei 'BSEG-ZFBDT' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-zfbdt. ls_accchg-newval = <fs_kopf>-zfbdt.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.
    "Tag 1
    IF <fs_bseg>-zbd1t NE <fs_kopf>-zbd1t.
      CONCATENATE <fs_kopf>-buzei 'BSEG-ZBD1T' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-zbd1t. ls_accchg-newval = <fs_kopf>-zbd1t.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.
    "Prozent 1
    IF <fs_bseg>-zbd1p NE <fs_kopf>-zbd1p.
      CONCATENATE <fs_kopf>-buzei 'BSEG-ZBD1P' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-zbd1p. ls_accchg-newval = <fs_kopf>-zbd1p.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.
    "Tag 2
    IF <fs_bseg>-zbd2t NE <fs_kopf>-zbd2t.
      CONCATENATE <fs_kopf>-buzei 'BSEG-ZBD2T' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-zbd2t. ls_accchg-newval = <fs_kopf>-zbd2t.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.
    "Prozent 2
    IF <fs_bseg>-zbd2p NE <fs_kopf>-zbd2p.
      CONCATENATE <fs_kopf>-buzei 'BSEG-ZBD2P' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-zbd2p. ls_accchg-newval = <fs_kopf>-zbd2p.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.
    "Frist
    IF <fs_bseg>-zbd3t NE <fs_kopf>-zbd3t.
      CONCATENATE <fs_kopf>-buzei 'BSEG-ZBD3T' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-zbd3t. ls_accchg-newval = <fs_kopf>-zbd3t.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.
    "Mahndatum
    IF <fs_bseg>-madat NE <fs_kopf>-madat.
      CONCATENATE <fs_kopf>-buzei 'BSEG-MADAT' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-madat. ls_accchg-newval = <fs_kopf>-madat.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.
    "Mahnschlüssel
    IF <fs_bseg>-mschl NE <fs_kopf>-mschl.
      CONCATENATE <fs_kopf>-buzei 'BSEG-MSCHL' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-mschl. ls_accchg-newval = <fs_kopf>-mschl.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.
    "Mahnbereich
    IF <fs_bseg>-maber NE <fs_kopf>-maber.
      CONCATENATE <fs_kopf>-buzei 'BSEG-MABER' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-maber. ls_accchg-newval = <fs_kopf>-maber.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.
    "Hausbank
    IF <fs_bseg>-hbkid NE <fs_kopf>-hbkid.
      CONCATENATE <fs_kopf>-buzei 'BSEG-HBKID' INTO ls_accchg-fdname.
      ls_accchg-oldval = <fs_bseg>-hbkid. ls_accchg-newval = <fs_kopf>-hbkid.
      APPEND ls_accchg TO lt_accchg.
      lv_pos = gc_x.
    ENDIF.
    "
    READ TABLE lt_fb02_text WITH KEY buzei = <fs_kopf>-buzei ASSIGNING FIELD-SYMBOL(<fs_text>).
    IF sy-subrc = 0.

      IF <fs_bseg>-sgtxt NE <fs_text>-sgtxt.
        CONCATENATE <fs_kopf>-buzei 'BSEG-SGTXT' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-sgtxt. ls_accchg-newval = <fs_text>-sgtxt.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
        ls_bseg-sgtxt = <fs_text>-sgtxt.
      ENDIF.

      IF <fs_bseg>-zuonr NE <fs_text>-zuonr.
        CONCATENATE <fs_kopf>-buzei 'BSEG-ZUONR' INTO ls_accchg-fdname.
        ls_accchg-oldval = <fs_bseg>-zuonr. ls_accchg-newval = <fs_text>-zuonr.
        APPEND ls_accchg TO lt_accchg.
        lv_pos = gc_x.
        ls_bseg-zuonr = <fs_text>-zuonr.
      ENDIF.

    ENDIF.


*   Übergabe Werte
    <fs_bseg> = ls_bseg.

    IF lv_pos IS NOT INITIAL.
      " Sichern des veränderten Satzes
      APPEND INITIAL LINE TO lt_bseg_new ASSIGNING FIELD-SYMBOL(<ls_bseg_new>).
      MOVE-CORRESPONDING <fs_bseg> TO <ls_bseg_new>.
      " Änderungsbelegtrigger
      lv_pos_upd = 'U'.
    ENDIF.


    LOOP AT lt_fb02_text ASSIGNING <fs_text> WHERE buzei <> <fs_kopf>-buzei.
      CLEAR lv_pos.

      READ TABLE  lt_bseg WITH KEY buzei = <fs_text>-buzei ASSIGNING FIELD-SYMBOL(<fs_bseg_text>) .
      IF sy-subrc = 0.
        APPEND INITIAL LINE TO lt_bseg_old ASSIGNING <ls_bseg_old>.
        MOVE-CORRESPONDING <fs_bseg_text> TO <ls_bseg_old>.

        IF <fs_bseg_text>-sgtxt NE <fs_text>-sgtxt.
          CONCATENATE <fs_text>-buzei 'BSEG-SGTXT' INTO ls_accchg-fdname.
          ls_accchg-oldval = <fs_bseg_text>-sgtxt. ls_accchg-newval = <fs_text>-sgtxt.
          APPEND ls_accchg TO lt_accchg.
          lv_pos = gc_x.
          <fs_bseg_text>-sgtxt = <fs_text>-sgtxt.
        ENDIF.

        IF <fs_bseg_text>-zuonr NE <fs_text>-zuonr.
          CONCATENATE <fs_text>-buzei 'BSEG-ZUONR' INTO ls_accchg-fdname.
          ls_accchg-oldval = <fs_bseg_text>-zuonr. ls_accchg-newval = <fs_text>-zuonr.
          APPEND ls_accchg TO lt_accchg.
          lv_pos = gc_x.
          <fs_bseg_text>-zuonr = <fs_text>-zuonr.
        ENDIF.

      ENDIF.

      IF lv_pos IS NOT INITIAL.
        " Sichern des veränderten Satzes
        APPEND INITIAL LINE TO lt_bseg_new ASSIGNING <ls_bseg_new>.
        MOVE-CORRESPONDING <fs_bseg_text> TO <ls_bseg_new>.
        " Änderungsbelegtrigger
        lv_pos_upd = 'U'.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDLOOP.

LOOP AT lt_bseg_old ASSIGNING FIELD-SYMBOL(<fs_bseg_old>).
  READ TABLE lt_bseg_new WITH KEY buzei = <fs_bseg_old>-buzei TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.
    APPEND <fs_bseg_old> TO lt_bseg_new.
  ENDIF.
ENDLOOP.

SORT lt_bseg_old BY buzei.
SORT lt_bseg_new BY buzei.


SORT lt_bseg BY buzei.

SELECT * FROM bkdf INTO TABLE @DATA(lt_bkdf)  "#EC CI_ALL_FIELDS_NEEDED
WHERE    belnr  = @object-key-documentno                "#EC CI_NOORDER
AND      bukrs  = @object-key-companycode
AND      gjahr  = @object-key-fiscalyear.

SELECT * FROM bsec INTO TABLE @DATA(lt_bsec)  "#EC CI_ALL_FIELDS_NEEDED
WHERE    belnr  = @object-key-documentno                "#EC CI_NOORDER
AND      bukrs  = @object-key-companycode
AND      gjahr  = @object-key-fiscalyear.

SELECT * FROM bsed INTO TABLE @DATA(lt_bsed)  "#EC CI_ALL_FIELDS_NEEDED
WHERE    belnr  = @object-key-documentno                "#EC CI_NOORDER
AND      bukrs  = @object-key-companycode
AND      gjahr  = @object-key-fiscalyear.

SELECT * FROM bset INTO TABLE @DATA(lt_bset)  "#EC CI_ALL_FIELDS_NEEDED
WHERE    belnr  = @object-key-documentno                "#EC CI_NOORDER
AND      bukrs  = @object-key-companycode
AND      gjahr  = @object-key-fiscalyear.

*** CD 5*841 AVVISO Übertragung ***
" Sichern der alten Werte für Übergabe an Fuba
" BKPF und BSEG sind schon gesichert
DATA(lt_bsed_old) = lt_bsed.
*******

CALL FUNCTION 'CHANGE_DOCUMENT'
  TABLES
    t_bkdf = lt_bkdf
    t_bkpf = lt_bkpf
    t_bsec = lt_bsec
    t_bsed = lt_bsed
    t_bseg = lt_bseg
    t_bset = lt_bset
*   T_BSEG_ADD       =
  .

IF sy-subrc <> 0.
  lv_xsubrc = 4.
ELSE.

*** CD 5*841 AVVISO Übertragung ausführen, wenn Beleg relevant***

  CALL FUNCTION 'Z_FI_ALE_CHANGE_DOCUMENT'
    EXPORTING
      i_bkpf_old       = ls_bkpf_old             " ursprünglicher FI-Belegkopf
      i_bkpf_new       = ls_bkpf                 " geänderter FI-Belegkopf
    TABLES
      t_bseg_old       = lt_bseg_old             " ursprüngliche FI-Belegzeilen
      t_bseg_new       = lt_bseg                 " geänderte FI-Belegzeilen
      t_bsed_old       = lt_bsed_old             " Belegsegment Wechselfelder
      t_bsed_new       = lt_bsed                 " Belegsegment Wechselfelder
    EXCEPTIONS
      no_fi_ale_change = 1                       " Keine Änderungsdaten für FI ALE versendet
      OTHERS           = 2.
  IF sy-subrc <> 0.
    " AVVISO IDOC nicht angestossen
    MESSAGE w180(z_tpbr).
  ENDIF.

  COMMIT WORK.
******
  "WICHTIG555"
*  " Zusatzfelder Kopf
*  CLEAR lv_kopf.
*  IF <fs_kopf>-zz_haftvor IS NOT INITIAL.
*    ls_bkpf-zz_haftvor = <fs_kopf>-zz_haftvor.
*    lv_kopf = abap_true.
*  ENDIF.
*  IF <fs_kopf>-zz_014 IS NOT INITIAL.
*    ls_bkpf-zz_014 = <fs_kopf>-zz_014.
*    lv_kopf = abap_true.
*  ENDIF.
*  IF ls_bkpf-zz_k1 <> <fs_kopf>-zz_k1.
*    ls_bkpf-zz_k1 = <fs_kopf>-zz_k1.
*    lv_kopf = abap_true.
*  ENDIF.
*  IF ls_bkpf-zz_k2 <> <fs_kopf>-zz_k2.
*    ls_bkpf-zz_k2 = <fs_kopf>-zz_k2.
*    lv_kopf = abap_true.
*  ENDIF.
*  IF ls_bkpf-zz_k3 <> <fs_kopf>-zz_k3.
*    ls_bkpf-zz_k3 = <fs_kopf>-zz_k3.
*    lv_kopf = abap_true.
*  ENDIF.

  IF lv_kopf IS NOT INITIAL.
    UPDATE bkpf FROM ls_bkpf.
    " Prüfe Änderungsbelegtrigger
    IF lv_kopf_upd IS INITIAL.
      lv_kopf_upd = 'U'.
    ENDIF.
  ENDIF.

  " Erzeugen Objektid
  lv_objectid(3)    = sy-mandt.
  lv_objectid+3(4)  = object-key-companycode.
  lv_objectid+7(10) = object-key-documentno .
  lv_objectid+17(4) = object-key-fiscalyear.

  " Schreiben Änderungsbelege
  CALL FUNCTION 'BELEG_WRITE_DOCUMENT'
    EXPORTING
      objectid = lv_objectid
      tcode    = 'FB02'
      utime    = sy-uzeit
      udate    = sy-datum
      username = sy-uname
      n_bkpf   = ls_bkpf
      o_bkpf   = ls_bkpf_old
      upd_bkpf = lv_kopf_upd
      upd_bseg = lv_pos_upd
    TABLES
      xbseg    = lt_bseg_new
      ybseg    = lt_bseg_old.

ENDIF.

swc_set_element container 'XSUBRC' lv_xsubrc.
end_method.

begin_method zstornofb08 changing container.
DATA:
  s_sdata    LIKE /thkr/s_wf_stornodaten,
  returnmess LIKE bapiret2 OCCURS 0,
  xsubrc     TYPE syst-subrc.

DATA: lt_bdcdata   TYPE STANDARD TABLE OF bdcdata WITH DEFAULT KEY,
      lt_bdcmess   TYPE STANDARD TABLE OF bdcmsgcoll,
      lt_return    TYPE STANDARD TABLE OF bapireturn1,
      ls_sdata     TYPE /thkr/s_wf_stornodaten,
      ls_opt       TYPE ctu_params,
      lv_budat_ext TYPE char10,
      lv_xsubrc    TYPE syst-subrc.


" Stornodaten vom Kontainer

swc_get_element container 'S_SDATA' ls_sdata.

" Aufbau der BDCDATEN
lt_bdcdata = VALUE #(
    ( program  = 'SAPMF05A' dynpro = '105' dynbegin = 'X' )
    ( fnam = 'RF05A-BELNS'  fval = object-key-documentno )
    ( fnam = 'BKPF-BUKRS'   fval = object-key-companycode )
    ( fnam = 'RF05A-GJAHS'  fval = object-key-fiscalyear )
    ( fnam = 'UF05A-STGRD'  fval = ls_sdata-stgrd ) ).
*    ( fnam = 'BSIS-MONAT'   fval = ls_sdata-monat ) ).
*        ( fnam = 'BDC_OKCODE'   fval = '=BU' ) ).

IF  ls_sdata-budat IS NOT INITIAL AND ls_sdata-budat <> '00010101'.

  WRITE ls_sdata-budat TO lv_budat_ext.
  APPEND VALUE #( fnam = 'BSIS-BUDAT'  fval = lv_budat_ext ) TO lt_bdcdata.

ENDIF.

" Aufbau der Optionen
ls_opt-dismode = 'A'.
ls_opt-updmode = 'S'.
ls_opt-nobinpt = space.
ls_opt-nobiend = space.

" Prüfung Berechtigung

CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
  EXPORTING
    tcode  = 'FB08'
  EXCEPTIONS
    ok     = 1
    not_ok = 2
    OTHERS = 3.
IF sy-subrc = 1.
  " Aufruf der Transaktion
  CALL TRANSACTION 'FB08' USING lt_bdcdata
                          OPTIONS FROM ls_opt
                          MESSAGES INTO lt_bdcmess.
  IF lt_bdcmess IS NOT INITIAL.
    LOOP AT lt_bdcmess ASSIGNING FIELD-SYMBOL(<ls_mess>) WHERE msgtyp NA 'IW'.
      APPEND INITIAL LINE TO lt_return ASSIGNING FIELD-SYMBOL(<ls_return>).
      <ls_return>-type = <ls_mess>-msgtyp.
      <ls_return>-id = <ls_mess>-msgid.
      <ls_return>-number = <ls_mess>-msgnr.
      <ls_return>-message_v1 = <ls_mess>-msgv1.
      <ls_return>-message_v2 = <ls_mess>-msgv2.
      <ls_return>-message_v3 = <ls_mess>-msgv3.
      <ls_return>-message_v4 = <ls_mess>-msgv4.
    ENDLOOP.

  ENDIF.

ELSE.

  " Keine Berechtigung
  APPEND INITIAL LINE TO lt_return ASSIGNING <ls_return>.
  <ls_return>-id = '00'.
  <ls_return>-number = '172'.
  <ls_return>-type = 'E'.
  <ls_return>-message_v1 = 'FB08'.
ENDIF.

" Prüfung ob Beleg wirklich storniert ist
lv_xsubrc = 0.
IF lt_return IS INITIAL.

  " Vor der Ermittlung muss ein Commit die DB aktuallisieren
  COMMIT WORK AND WAIT.
  " Lese Beleg zur Prüfung ob storniert
  SELECT SINGLE stblg, stjah INTO @DATA(ls_beleg) FROM bkpf
                             WHERE bukrs = @object-key-companycode
                               AND belnr = @object-key-documentno
                               AND gjahr = @object-key-fiscalyear.

  IF sy-subrc = 0 AND ls_beleg-stblg IS NOT INITIAL.
    " Prüfung Geschäftsjahr
    IF ls_beleg-stjah = object-key-fiscalyear.
      " Storno wurde durchgeführt
      FREE lt_return.
    ELSE.
      " Kein Storno durchgeführt
      lv_xsubrc = 4.
    ENDIF.
  ELSE.
    " Kein Storno durchgeführt
    lv_xsubrc = 4.
  ENDIF.
  IF lv_xsubrc = 4.
    APPEND INITIAL LINE TO lt_return ASSIGNING <ls_return>.
    <ls_return>-id = '00'.
    <ls_return>-number = '001'.
    <ls_return>-type = 'E'.
    <ls_return>-message_v1 = TEXT-e01. " Kein Storno durchgeführt
  ENDIF.
ENDIF.

swc_set_table container 'RETURNMESS' returnmess.
swc_set_element container 'XSUBRC' xsubrc.
end_method.

BEGIN_METHOD ZCHECKSTORNO CHANGING CONTAINER.
DATA: lt_error  TYPE TABLE OF payrq03,
      ls_error  TYPE payrq03,
      lv_xsubrc TYPE syst-subrc.


" Init Rückgabewert
lv_xsubrc = 0.
" Lese Beleg zur Prüfung ob storniert
SELECT SINGLE stblg, stjah INTO @DATA(ls_beleg) FROM bkpf
                           WHERE bukrs = @object-key-companycode
                             AND belnr = @object-key-documentno
                             AND gjahr = @object-key-fiscalyear.
IF sy-subrc = 0 AND ls_beleg-stblg IS NOT INITIAL.
  " Prüfung Geschäftsjahr
  IF ls_beleg-stjah = object-key-fiscalyear.
    " Storno wurde durchgeführt
    FREE lt_error.
  ELSE.
    " Kein Storno durchgeführt
    ls_error = TEXT-e01.
    APPEND ls_error TO lt_error.
    lv_xsubrc = 4.
  ENDIF.
ELSE.
  " Kein Storno durchgeführt
  ls_error = TEXT-e01.
  APPEND ls_error TO lt_error.
  lv_xsubrc = 4.
ENDIF.

swc_set_table container 'T_MESSAGES' lt_error.
swc_set_element container 'XSUBRC' lv_xsubrc.

END_METHOD.

BEGIN_METHOD ZADDATTACHEMENTS CHANGING CONTAINER.
DATA:
      LV_XSUBRC TYPE SYST-SUBRC,
      LV_WIID TYPE SWWWIHEAD-WI_ID,
      lv_objkey type SWO_TYPEID.
      SWC_GET_ELEMENT CONTAINER 'V_WIID' LV_WIID.

Move object-key to lv_objkey.

  CALL FUNCTION '/THKR/WF_OBJ_RELAT_CREATE'
  EXPORTING
    iv_objkey                            = lv_objkey
    iv_objtype                           = 'BKPF'
    iv_wi_id                             = lv_wiid
 EXCEPTIONS
   RELATION_COULD_NOT_CREATE            = 1
   ERROR_READING_ATTACHEMENTS           = 2
   ERROR_READING_ATTACHEMENT_TYPE       = 3
   OTHERS                               = 4
          .
IF sy-subrc <> 0.
lv_xsubrc = 2.
ENDIF.

  SWC_SET_ELEMENT CONTAINER 'XSUBRC' LV_XSUBRC.
END_METHOD.

BEGIN_METHOD ZBELEG_STORNO_BG CHANGING CONTAINER.
DATA:
      XSUBRC TYPE SYST-SUBRC,
      V_BUDAT TYPE SYST-DATUM.
  SWC_GET_ELEMENT CONTAINER 'V_BUDAT' V_BUDAT.

  DATA lv_xsubrc TYPE syst-subrc.

RANGES: r_belnr FOR bkpf-belnr,
        r_bukrs FOR bkpf-bukrs,
        r_gjahr FOR bkpf-gjahr.


" Ermitteln relevanten Satz aus ZFI_STORNO
SELECT SINGLE stgrd, budat INTO @DATA(ls_storno) FROM /THKR/STORNOC "#EC CI_NOORDER
                                         WHERE belnr = @object-key-documentno
                                           AND bukrs = @object-key-companycode
                                           AND gjahr = @object-key-fiscalyear
                                           AND modul = 'FI'
                                           AND status = 50.

IF sy-subrc = 0.
  IF ls_storno-budat IS INITIAL.
    ls_storno-budat = sy-datum.
  ENDIF.


  " Aufbau Daten für Stornierung
  REFRESH: r_belnr, r_bukrs, r_gjahr.

  r_belnr-sign = gc_i.
  r_belnr-option = gc_eq.
  r_belnr-low = object-key-documentno.
  APPEND r_belnr.
  r_bukrs-sign = gc_i.
  r_bukrs-option = gc_eq.
  r_bukrs-low = object-key-companycode.
  APPEND r_bukrs.
  r_gjahr-sign = gc_i.
  r_gjahr-option = gc_eq.
  r_gjahr-low =  object-key-fiscalyear.
  APPEND r_gjahr.

  " Aufruf des Massenstornoprogramms für selektierte Belege
  SUBMIT sapf080 AND RETURN                              "#EC CI_SUBMIT
         WITH br_bukrs IN r_bukrs
         WITH br_gjahr IN r_gjahr
         WITH br_belnr IN r_belnr
         WITH testlauf EQ space
         WITH stogrd   EQ ls_storno-stgrd                   "AD131098
         WITH stodat   EQ ls_storno-budat
         WITH xlist    EQ space.

*  " Lesen der Headerdaten für übergabe der Kommentare
*  SELECT SINGLE * INTO @DATA(ls_bkpf) FROM bkpf WHERE belnr = @object-key-documentno "#EC CI_ALL_FIELDS_NEEDED
*                                                  AND bukrs = @object-key-companycode
*                                                  AND gjahr = @object-key-fiscalyear.
*  IF sy-subrc = 0.
*
*    " Übergabe der Kommentare
*    ls_bkpf-zz_k1 = ls_storno-zz_k1.
*    ls_bkpf-zz_k2 = ls_storno-zz_k2.
*    ls_bkpf-zz_k3 = ls_storno-zz_k3.
*
*    " Update der Kommentare auf der Datenbank
*    UPDATE bkpf FROM ls_bkpf.
*
*  ENDIF.

ENDIF.

swc_set_element container 'XSUBRC' lv_xsubrc.

END_METHOD.
