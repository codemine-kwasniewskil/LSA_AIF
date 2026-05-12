************************************************************************
*                        Land Sachen-Anhalt                            *
************************************************************************
*  SAP-Release :                               EA-PS-Release:          *
*  Objektname  : /thkr/sst_wm                                          *
*  Objekttyp   : Ausführbares Programm                                 *
*  Autor       : Falko Schröter                   User-ID: ZHM000000059*
*  Auftraggeber:                                  User-ID:             *
*  Erstelldatum: 23.01.2026              Transportauftrag:             *
*  Beschreibung: Ermitteln der SST-Daten für ELVISWeb (wertmarken)     *
*                                                                      *
************************************************************************
*                          Änderungen                                  *
************************************************************************
*  Änd.-Nr.    :  INC08751430                  Änd.-Datum:  26.02.2026 *
*  Nr. OP-Liste:                         Transportauftrag:             *
*  Bearbeiter  :  F.Schröter                     User-ID: ZHM000000059 *
*  Auftraggeber:                                 User-ID:              *
*  Beschreibung:  Möglichst den vollständigen Verwendungszweck an das  *
*                 FVV übergeben. Jedoch maximal 90 Zeichen, da laut    *
*                 Datensatzbeschreibung (dataport) nicht mehr vorge-   *
*                 sehen sind                                           *
*                                                                      *
************************************************************************
REPORT /thkr/sst_wm LINE-SIZE 200.

TABLES: /thkr/cu_sst_wm, /thkr/ld_sst_wm.

DATA: gt_daten     TYPE TABLE OF /thkr/s_sst_wm,
      gs_daten     TYPE /thkr/s_sst_wm,
      gt_nachricht TYPE TABLE OF zfi_bn_nachricht,
      gs_nachricht TYPE zfi_bn_nachricht,
      gt_cu_sst_wm TYPE TABLE OF /thkr/cu_sst_wm,
      gs_cu_sst_wm TYPE /thkr/cu_sst_wm,
      gt_uebergabe TYPE TABLE OF /thkr/fi_sst_wm,
      gs_uebergabe TYPE /thkr/fi_sst_wm,
      gs_ld_sst_wm TYPE /thkr/ld_sst_wm,
      gv_datum     TYPE sy-datum.

DATA: lv_lotkz      TYPE pso_lotkz,
      lv_vwezw(300) type c,
      lt_febre      type table of febre,
      ls_febre      type febre.

*---------------------------------------------------------------------*
* Selektionsbild
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: so_kassz FOR /thkr/cu_sst_wm-kassenzeichen.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(35) gv_text.
    PARAMETERS: p_erfdat TYPE sy-datum.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_wdhlg TYPE flag AS CHECKBOX.
  SELECT-OPTIONS: so_wdhlg FOR /thkr/ld_sst_wm-laufdatum.
  PARAMETERS: p_aif TYPE flag AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-003.
  PARAMETERS: p_disp TYPE flag AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-004.
  PARAMETERS: p_q_ns   TYPE /aif/ns DEFAULT 'FREMDV',
              p_q_name TYPE /aif/pers_rtcfgr_name.
SELECTION-SCREEN END OF BLOCK b4.

*---------------------------------------------------------------------*
* Vorbelegung der SELECT-OPTIONS
*---------------------------------------------------------------------*
INITIALIZATION.

  DATA: ls_range LIKE so_kassz,
        lv_xblnr TYPE xblnr.

  IF so_kassz[] IS INITIAL.

    ls_range-sign   = 'I'.      " Include
    ls_range-option = 'EQ'.     " Gleich

    SELECT kassenzeichen FROM /thkr/cu_sst_wm INTO lv_xblnr.

      ls_range-low    = lv_xblnr.
      APPEND ls_range TO so_kassz.

    ENDSELECT.

  ENDIF.

* letztes Laufdatum lesen
  SELECT SINGLE * FROM /thkr/ld_sst_wm INTO gs_ld_sst_wm
    WHERE satzart = '01'.
  IF sy-subrc <> 0.
    p_erfdat = sy-datum.
  ELSE.
    gv_datum = gs_ld_sst_wm-laufdatum .
    p_erfdat = gs_ld_sst_wm-laufdatum + 1.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  CONCATENATE gv_datum+6(2) '.' gv_datum+4(2) '.' gv_datum(4)
         INTO gv_text.
  CONCATENATE 'ab Datum (letzter Lauf' gv_text ')'
         INTO gv_text SEPARATED BY space.

AT SELECTION-SCREEN.
  IF NOT p_wdhlg IS INITIAL AND so_wdhlg-low IS INITIAL.
    MESSAGE 'Bitte bei Wiederholung ein Datum (Zeitraum) eingeben!' TYPE 'E'.
  ENDIF.


*---------------------------------------------------------------------*
* Hauptlogik
*---------------------------------------------------------------------*
START-OF-SELECTION.

* lesen der Customizingeinstellungen (für welche Kassenzeichen die SST-Daten ermittelt werden sollen)
  SELECT *  FROM /thkr/cu_sst_wm INTO TABLE gt_cu_sst_wm.

* Ermitteln der Daten aus der Tabelle zfi_bn_nachricht (Nachrichten auf Basis der ELKO-Verarbeitung)
  IF  p_wdhlg IS INITIAL.
    SELECT erfdat budat kunnr bukrs belnr gjahr xblnr wrbtr kukey esnum  FROM zfi_bn_nachricht
      INTO CORRESPONDING FIELDS OF TABLE gt_nachricht
      WHERE xblnr IN so_kassz AND
            erfdat >= p_erfdat AND erfdat <= sy-datum.
  ELSE.
    IF so_wdhlg-high IS INITIAL.
      SELECT erfdat budat kunnr bukrs belnr gjahr xblnr wrbtr kukey esnum  FROM zfi_bn_nachricht
        INTO CORRESPONDING FIELDS OF TABLE gt_nachricht
        WHERE xblnr IN so_kassz AND
              erfdat = so_wdhlg-low.
    ELSE.
      SELECT erfdat budat kunnr bukrs belnr gjahr xblnr wrbtr kukey esnum  FROM zfi_bn_nachricht
        INTO CORRESPONDING FIELDS OF TABLE gt_nachricht
        WHERE xblnr IN so_kassz AND
              erfdat >= so_wdhlg-low AND erfdat <= so_wdhlg-high.
    ENDIF.
  ENDIF.


  IF sy-subrc <> 0.
    WRITE: / 'Zu diesen Selektionskriterien sind keine Daten vorhanden.'.
    EXIT.
  ENDIF.

* Schnittstellendatensatz zusammenbauen, je Kassenzeichen
  LOOP AT so_kassz.

    CLEAR: gt_daten, gs_daten.

    LOOP AT gt_nachricht INTO gs_nachricht
      WHERE xblnr = so_kassz-low.

      gs_daten-01_belnr     = gs_nachricht-belnr+2(8).
      gs_daten-03_xblnr     = gs_nachricht-xblnr.
      gs_daten-05_zp_nummer = gs_nachricht-kunnr.
      gs_daten-11_erfdat    = gs_nachricht-erfdat.
      gs_daten-10_budat     = gs_nachricht-budat.
      gs_daten-13_kukey     = gs_nachricht-kukey.
      gs_daten-09_betrag    = |{ trunc( gs_nachricht-wrbtr ) }|.

      gs_daten-04_zlweg        = '4'.
      gs_daten-06_lfd_nr_zp    = '001'.
      gs_daten-07_konstante    = '1'.
      gs_daten-14_aktenzeichen = 'Wertmarke'.

*     Nachlesen von Daten aus weiteren Tabellen
      SELECT SINGLE piban partn sgtxt FROM febep
        INTO ( gs_daten-08_iban, gs_daten-12_name, gs_daten-15_vzweck )
        WHERE kukey = gs_nachricht-kukey AND
              esnum = gs_nachricht-esnum.

      SELECT SINGLE lotkz FROM bkpf INTO lv_lotkz
        WHERE bukrs = gs_nachricht-bukrs AND
              belnr = gs_nachricht-belnr AND
              gjahr = gs_nachricht-gjahr.

      gs_daten-02_lotkz = lv_lotkz+2(8).

*INS INC08751430 Begin
      clear: lt_febre, lv_vwezw.
      select * from febre into table lt_febre
        WHERE kukey = gs_nachricht-kukey AND
              esnum = gs_nachricht-esnum.

      if sy-subrc = 0.
        sort lt_febre by rsnum.
        loop at lt_febre into ls_febre.
          if ls_febre-vwezw cs '+KREF+' or ls_febre-vwezw cs '+BREF+' or
             ls_febre-vwezw cs '+EREF+' or ls_febre-vwezw cs '+TXID+' or
             ls_febre-vwezw cs '+MREF+' or ls_febre-vwezw cs '+CRED+'.
*            Inhalt nicht verwenden
            else.
             if lv_vwezw is initial.
                lv_vwezw = ls_febre-vwezw.
               else.
                concatenate lv_vwezw ls_febre-vwezw into lv_vwezw separated by space.
             endif.
          endif.
        endloop.
        if not lv_vwezw is initial.
           gs_daten-15_vzweck = lv_vwezw(70).
        endif.
      endif.
*INS INC08751430 End

      APPEND gs_daten TO gt_daten.

    ENDLOOP.

    IF NOT gt_daten IS INITIAL.

      READ TABLE gt_cu_sst_wm WITH KEY kassenzeichen = so_kassz-low INTO gs_cu_sst_wm.

      gs_uebergabe-kassenzeichen = gs_cu_sst_wm-kassenzeichen.
      gs_uebergabe-beschreibung  = gs_cu_sst_wm-beschreibung.

      gs_uebergabe-ausgabe = gt_daten[].

      APPEND gs_uebergabe TO gt_uebergabe.

    ENDIF.

  ENDLOOP.

  IF NOT gt_uebergabe IS INITIAL.
    IF p_wdhlg IS INITIAL.
*      Datum des letzten Lauf wegschreiben
      gs_ld_sst_wm-satzart = '01'.
      gs_ld_sst_wm-laufdatum = Sy-datum.
      MODIFY /thkr/ld_sst_wm FROM gs_ld_sst_wm.
      COMMIT WORK.
    ENDIF.

*   Ausgabe der selektierten Wertmarken als Liste
    IF NOT p_disp IS INITIAL.
      LOOP AT gt_uebergabe INTO gs_uebergabe.
        WRITE: gs_uebergabe-kassenzeichen, gs_uebergabe-beschreibung.
        gt_daten[] = gs_uebergabe-ausgabe.
        LOOP AT gt_daten INTO gs_daten.
          WRITE: / gs_daten.
        ENDLOOP.
        WRITE: /.
      ENDLOOP.

    ENDIF.

    IF p_wdhlg IS INITIAL OR ( NOT p_wdhlg IS INITIAL AND NOT p_aif IS INITIAL ).
* Übergabe der Daten an das AIF zur Erstellung der SST-Dateien:
* aus /THKR/R_SEND_IST_RUECK
      TRY.
          /aif/cl_enabler_xml=>transfer_to_aif_mult( EXPORTING it_any_structure = gt_uebergabe
                                                               iv_queue_ns      = p_q_ns
                                                               iv_queue_name    = p_q_name
                                                               iv_use_buffer    = abap_true ).

        CATCH /aif/cx_inf_det_base.           " Generic Exception for AIF Enabler
        CATCH /aif/cx_enabler_base.           " Generic Exception for AIF Enabler
        CATCH /aif/cx_aif_engine_not_found.   " General exception class for AIF engines
        CATCH /aif/cx_error_handling_general. " AIF Error Handling Exception Class
        CATCH /aif/cx_aif_engine_base.        " Base Exception Class for AIF Engines
      ENDTRY.

    ENDIF.

  ELSE.
    WRITE: / 'Zu diesen Selektionskriterien sind keine Daten vorhanden.'.
    EXIT.

  ENDIF.
