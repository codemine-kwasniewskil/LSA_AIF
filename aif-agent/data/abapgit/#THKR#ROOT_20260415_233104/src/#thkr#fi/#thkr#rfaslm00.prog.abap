**********************************************************************
*                                                                    *
*       Zusammenfassende Meldung in Papierform                       *
*                                                                    *
**********************************************************************
*           REPARATUREN                                              *
* YHR-01:   Adressend der CPD-Kunden wurden nicht angezeigt          *
* YHR-02:   Druckersteuerung für den ALV                             *
* YHR-03:   Umsetllung auf ALV                                       *
**********************************************************************


REPORT rfaslm00
  LINE-SIZE 132
  NO STANDARD PAGE HEADING
  MESSAGE-ID fr.

*---------------------------------------------------------------------*
*       Datendeklarationsteil                                         *
*       (Segments, Tables, Data, Field-Groups, Selektionsparameter)   *
*---------------------------------------------------------------------*
INCLUDE /thkr/rfaslidd.

DATA: hlp_line TYPE nummr,                                  "775681
      hlp_lsub TYPE nummr.                                  "775681
DATA: ld_fm_name   TYPE rs38l_fnam,                         "1123764
      ld_form_name TYPE fpname,                             "1123764
      lv_cx_fp_api TYPE REF TO cx_fp_api.                   "1123764


*---------------------------------------------------------------------*
*       Weitere Selektionsparameter                                   *
*---------------------------------------------------------------------*
PARAMETERS:
  par_down TYPE aslmdownpayment.  "select down payments     "1595286

SELECTION-SCREEN SKIP 1.                                    "PDF

PARAMETERS:                                                 "2252566
  par_list TYPE xfeld RADIOBUTTON GROUP f1. "Nur Liste      "2252566

PARAMETERS pdf_form TYPE pdf_form RADIOBUTTON GROUP f1      "PDF
           DEFAULT 'X'.                                     "2252566
*PARAMETERS  par_pdf TYPE fpwbformname_aslm                 "1124020
*   DEFAULT 'F_ASL_DE' VALUE CHECK.                 "PDF    "1124020
PARAMETERS  par_pdf TYPE fpwbformname_aslm                  "1124020
            MATCHCODE OBJECT hfpform_aslm                   "1124020
            DEFAULT 'F_ASL_DE'.                             "1124020
PARAMETERS scr_form TYPE scr_form RADIOBUTTON GROUP f1.     "PDF

PARAMETERS:                                                 "YHR-02
  par_form LIKE rsscf-tdform       "Formularname             "YHR-02
  DEFAULT 'F_ASL_DE',                                       "YHR-02
  par_lpp  TYPE aslmlpp,                                    "775681
  par_addr LIKE rfpdo-aslmaddr.    "Anschriftsdaten hinzulesen
SELECTION-SCREEN SKIP 1.                                    "PDF

SELECTION-SCREEN:                                           "YHR-02
BEGIN OF LINE.                                            "YHR-02
PARAMETERS:                                                 "YHR-02
  pri_form     TYPE fpm_parcon     NO-DISPLAY.              "YHR-02
PARAMETERS:                                                 "766359
  prp_form TYPE pri_params     NO-DISPLAY,                  "766359
  arp_form TYPE arc_params     NO-DISPLAY.                  "766359
SELECTION-SCREEN:
COMMENT 1(30) TEXT-028,
PUSHBUTTON 33(35) p1button USER-COMMAND pri1 MODIF ID py1."YHR-02
SELECTION-SCREEN:                                           "YHR-02
END OF LINE.                                              "YHR-02
PARAMETERS:                                                 "775681
  par_corr     TYPE aslmcorr.                               "775681
PARAMETERS:
* par_prim     LIKE tsp01-rqdest,  "Druckername für die Meldung  "YHR-02
* par_form     LIKE rsscf-tdform       "Formularname             "YHR-02
*              DEFAULT 'F_ASL_DE',                               "YHR-02
  par_lohn LIKE rfpdo-aslmlohn     "Lohnveredelung kumulieren
               DEFAULT 'X',
  par_drei LIKE rfpdo1-aslmdrei,   "Dreiecksgeschäft kumulieren
  par_skip LIKE rfpdo2-aslmskip.   "Ausgabe je Steuernummer
end_of_block 2.

CLEAR: gd_pdf_form, gd_scr_form.                            "PDF
gd_pdf_form = pdf_form.                                     "PDF
gd_scr_form = scr_form.                                     "PDF

INCLUDE /thkr/rfaslalv.

*---------------------------------------------------------------------*
*       Prüfung der Eingabedaten                                      *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON par_form.
  IF par_form EQ space AND scr_form = 'X'.                    "PDF
    SET CURSOR FIELD 'PAR_FORM'.
    MESSAGE e702.
  ENDIF.
  IF scr_form = 'X'.                                          "PDF
    CALL FUNCTION 'FORM_CHECK'
      EXPORTING
        i_pzfor = par_form.
  ENDIF.                                                      "PDF


AT SELECTION-SCREEN ON par_pdf.                               "PDF
  IF par_pdf EQ space AND pdf_form = 'X'.                     "PDF
    SET CURSOR FIELD 'PAR_PDF'.                               "PDF
    MESSAGE e702.                                             "PDF
  ENDIF.                                                      "PDF


AT SELECTION-SCREEN ON BLOCK 2.                             "1123764
  IF par_pdf NE space AND pdf_form = 'X'.                   "1123764
    ld_form_name = par_pdf.                                 "1123764
    TRY.                                                    "1123764
        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'             "1123764
          EXPORTING                                         "1123764
            i_name     = ld_form_name                       "1123764
          IMPORTING                                         "1123764
            e_funcname = ld_fm_name.                        "1123764
      CATCH cx_fp_api INTO lv_cx_fp_api.                    "1123764
        MESSAGE lv_cx_fp_api TYPE 'E'.                      "1123764
    ENDTRY.                                                 "1123764
  ENDIF.                                                    "1123764

*---------------------------------------------------------------------*
*       F4-Hilfe fuer Formulare                                       *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_form.
  DATA: hp_form_name LIKE thead-tdform.
  CALL FUNCTION 'DISPLAY_FORM_TREE_F4'
    EXPORTING
      p_tree_name = 'FI-10'
    IMPORTING
      p_form_name = hp_form_name
    EXCEPTIONS
      OTHERS      = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  IF sy-subrc EQ 0 AND hp_form_name NE space.
    par_form = hp_form_name.
  ENDIF.


AT SELECTION-SCREEN OUTPUT.                                 "YHR-02

  gv_in_cloud = cl_cos_utilities=>is_s4h_cloud( ).

* make RLDNR invisible
  PERFORM make_rldnr_invisible.                             "871301

* ----- Begin Note 2252566 -----                            "2252566
* modify screen and input parameters for tax auditor
* turn off all output related parameters
  IF NOT gd_tax_auditor IS INITIAL.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'PAR_LIST'
          OR 'PAR_EPOS'.
          screen-input = '0'.
          MODIFY SCREEN.
        WHEN 'PDF_FORM'
          OR 'PAR_PDF'
          OR 'SCR_FORM'
          OR 'PAR_FORM'
          OR 'PAR_LPP'
          OR 'PAR_ADDR'
          OR 'P1BUTTON'
          OR 'PAR_CORR'
          OR 'PAR_LOHN'
          OR 'PAR_DREI'
          OR 'PAR_SKIP'.
          screen-input = '0'.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
    par_list = 'X'.          "only list output
    par_epos = 'X'.          "line item list
    CLEAR:
      pdf_form,
      par_pdf,
      scr_form,
      par_form,
      par_lpp,
      par_addr,
      par_corr,
      par_lohn,
      par_drei,
      par_skip.
  ENDIF.
* ----- End Note 2252566 -----                              "2252566

  check_wia_and_modify_screen flg_xwia.                     "1104195
  LOOP AT SCREEN INTO DATA(ls_screen).
    IF ls_screen-group1 = 'TXA'.
      IF flg_txa_active = abap_true.
        ls_screen-input = '1'.
        ls_screen-invisible = '0'.
      ELSE.
        ls_screen-input = '0'.
        ls_screen-invisible = '1'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN FROM ls_screen.
  ENDLOOP.

  PERFORM modify_screen_for_alt_rep_curr.                   "3299454

* begin of insertion "766359
* This program once used functions which directly retrieve
* structure ITCPO by which print parameters are passed to the
* SAPscript functions. Now the generic function
* GET_PRINT_PARAMETERS is used to also retrieve archive parameters.
* Old print parameters still stored in field pri_form are transfered
* to the new parameter set in order to preserve information
* the user has saved in variants.
  FIELD-SYMBOLS <p> TYPE any.
  IF pri_form-container NE space
     AND prp_form-armod EQ space.
    ASSIGN pri_form-container TO <p> CASTING TYPE itcpo.
    MOVE-CORRESPONDING <p> TO itcpo.
    CLEAR gs_prparams.
    hlp_copies = itcpo-tdcopies.

    CALL FUNCTION 'GET_PRINT_PARAMETERS'
      EXPORTING
        archive_mode           = '1'
        authority              = itcpo-tdautority
        copies                 = hlp_copies
        department             = itcpo-tddivision
        destination            = itcpo-tddest
        expiration             = itcpo-tdlifetime
        immediately            = itcpo-tdimmed
        no_dialog              = 'X'
        receiver               = itcpo-tdreceiver
        sap_cover_page         = itcpo-tdcover
        mode                   = 'PARAMS'
      IMPORTING
        out_parameters         = gs_prparams
        valid                  = gs_valid
      EXCEPTIONS
        archive_info_not_found = 1
        invalid_print_params   = 2
        invalid_archive_params = 3
        OTHERS                 = 4.

    prp_form = gs_prparams.
  ENDIF.
* end of insertion "766359

* Reading in old report variants can overwrite the already    "2613615
* initialized auth_ldr, because the parameter existed in the  "2613615
* LDB before it was implemented here.                         "2613615
  auth_ldr = 'X'.                                           "2613615


  CALL FUNCTION 'SET_ARROW_ICON'                            "YHR-02
    EXPORTING                                            "YHR-02
*     i_parameter  = pri_form                 "YHR-02 "766359
      i_parameter  = prp_form                         "766359
      i_icon_text  = TEXT-029                         "YHR-02
    IMPORTING                                            "YHR-02
      e_arrow_icon = p1button.                        "YHR-02

  report_id = 'RFASLM00'.                                   "983616

  ASSIGN gv_report_id TO <fs_repid>.

*---------------------------------------------------------------------*
*       Datenselektionsteil / Einzelposten- und Fehlerliste           *
*---------------------------------------------------------------------*
  INCLUDE rfasli00.

***********************************************************************
*                                                                     *
*       Unterprogramme                                                *
*                                                                     *
*---------------------------------------------------------------------*
*                                                                     *
*       AT-SELECTION-SCREEN nicht verwendet                           *
*       TOP-OF-PAGE         nicht verwendet                           *
*       START-OF-SELECTION  nicht verwendet                           *
*       END-OF-SELECTION    Ausgabe selektierter Daten                *
*---------------------------------------------------------------------*
*       FILL_ASL            Tabelle mit ASL füllen                    *
*       START_ASL           Start der ASL-Meldung                     *
*       WRITE_ASL           Zeile der ASL-Meldung schreiben           *
*       END_ASL             Ende der ASL-Meldung                      *
*                                                                     *
***********************************************************************



*---------------------------------------------------------------------*
*       FORM END-OF-SELECTION                                         *
*---------------------------------------------------------------------*
*       Erstellen der Liste aus den extrahierten Daten                *
*---------------------------------------------------------------------*
*       Keine USING-Parameter                                         *
*---------------------------------------------------------------------*
FORM end-of-selection.

  CHECK gd_pdf_form = 'X' OR                                "2252566
        gd_scr_form = 'X'.                                  "2252566

  CLEAR:
    hlp_stceg,
    hlp_subtr.

*  IF par_drei EQ space.                                    "1384895
  SORT BY
    hlp_umkrs
    bseg-stceg
    bseg-xegdr
    hlp_ind
    bkpf-gjahr
    bkpf-belnr
    bseg-buzei.
*  ELSE.                                                    "1384895
*    SORT BY                                                "1384895
*      hlp_umkrs                                            "1384895
*      bseg-stceg                                           "1384895
*      hlp_ind                                              "1384895
*      bseg-xegdr                                           "1384895
*      bkpf-gjahr                                           "1384895
*      bkpf-belnr                                           "1384895
*      bseg-buzei.                                          "1384895
*  ENDIF.                                                   "1384895

  LOOP.

    AT NEW hlp_umkrs.
      REFRESH tab.
      CLEAR tab.
      PERFORM read_t001 USING bkpf-bukrs.
      IF flg_umkrs EQ 'X'.
        PERFORM read_t007f USING hlp_umkrs.
      ENDIF.
    ENDAT.

*    AT NEW bseg-stceg.                                     "1384895
*      hlp_xegdr = '0'.                                     "1384895
*    ENDAT.                                                 "1384895

    PERFORM fill_asl_line.                                  "1384895

*    AT END OF hlp_ind.                                     "1384895
*      IF par_lohn EQ space.                                "1384895
*        PERFORM fill_asl_line.                             "1384895
*      ENDIF.                                               "1384895
*    ENDAT.                                                 "1384895

*    AT END OF bseg-xegdr.                                  "1384895
*      IF par_lohn NE space AND par_drei EQ space.          "1384895
*        PERFORM fill_asl_line.                             "1384895
*      ENDIF.                                               "1384895
*      IF bseg-xegdr NE '0'.                                "1384895
*        hlp_xegdr = bseg-xegdr.                            "1384895
*      ENDIF.                                               "1384895
*    ENDAT.                                                 "1384895

*    AT END OF bseg-stceg.                                  "1384895
*      IF par_lohn NE space AND par_drei NE space.          "1384895
*        bseg-xegdr = hlp_xegdr                             "1384895.
*        PERFORM fill_asl_line.                             "1384895
*      ENDIF.                                               "1384895
*    ENDAT.                                                 "1384895


    AT END OF hlp_umkrs.

      IF gv_in_cloud = abap_false.

        PERFORM condense_asl_line.                          "1384895
        PERFORM start_asl.
        SORT tab.
        LOOP AT tab.
          PERFORM write_asl.
        ENDLOOP.
        PERFORM end_asl.

      ENDIF.

    ENDAT.

  ENDLOOP.

ENDFORM.                    "end-of-selection



*---------------------------------------------------------------------*
*       FORM FILL_ASL_LINE                                            *
*---------------------------------------------------------------------*
*       Füllen einer Zeile der Zusammenfassenden Meldung              *
*---------------------------------------------------------------------*
*       Keine USING-Parameter                                         *
*---------------------------------------------------------------------*
FORM fill_asl_line.

* ----- Begin delete 1384895 -----                          "1384895
*  IF par_skip   NE space      AND     "belgischer Indikator ASLM-BEIND
*     tab-bukrs  EQ hlp_umkrs  AND     "ist T, wenn XEGDR = 1. Daher in
*     tab-stceg  EQ bseg-stceg AND     "diesem Fall HLP_IND ignorieren
*     tab-ind    EQ '0'        AND     "und Werte kumulieren
*     hlp_ind    EQ '1'        AND
*     tab-xegdr  EQ '1'        AND
*     bseg-xegdr EQ '1'.
*    hlp_ind = '0'.
*    tab-lfdnr = tab-lfdnr - 1.
*  ENDIF.
* ----- End delete 1384895 -----                            "1384895
  tab-bukrs = hlp_umkrs.
  tab-stceg = bseg-stceg.
  tab-ind   = hlp_ind.
  tab-xegdr = bseg-xegdr.
*  tab-lfdnr = tab-lfdnr + 1.                               "1384895
*  tab-dmshb = sum(hlp_dmshb).                              "1384895
  tab-lfdnr = 0.                                            "1384895
  tab-dmshb = hlp_dmshb.                                    "1384895
  tab-koart = hlp_koart.
  tab-ktnra = hlp_ktnra.
*  tab-belnr = bkpf-belnr.                         "YHR-01  "1384895
*  tab-gjahr = bkpf-gjahr.                         "YHR-01  "1384895
  tab-name1 = hlp_name1.                                    "530539
  tab-stras = hlp_stras.                                    "530539
  tab-ort01 = hlp_ort01.                                    "530539
  tab-pstlz = hlp_pstlz.                                    "530539

  tab-xegcos = hlp_xegcos.                                  "3302554 - EE Call-off stock

  COLLECT tab.

ENDFORM.                    "fill_asl_line



*---------------------------------------------------------------------*
*       FORM START_ASL                                                *
*---------------------------------------------------------------------*
*       Start der Zusammenfassenden Meldung                           *
*---------------------------------------------------------------------*
*       Keine USING-Parameter                                         *
*---------------------------------------------------------------------*
FORM start_asl.

  DATA: ls_arparams LIKE arc_params,  "archive parameters    "766359
        ls_prparams LIKE pri_params.  "print parameters      "766359

  aslm-pertyp      = gd_pertyp.                             "870277
  IF gd_pertyp EQ '1'.              "monthly                  "870277
    aslm-monat       = par_mona.                            "870277
    aslm-quart       = 0.                                   "870277
    aslm-ajahr       = par_jamo.                            "870277
  ELSE.                             "quarterly or annnual     "870277
    aslm-monat       = 0.                                   "870277
    aslm-quart       = par_quar.                            "870277
    aslm-ajahr       = par_jahr.                            "870277
  ENDIF.                                                    "870277

  PERFORM read_t001z USING t001-bukrs 'SAPA01'.
  aslm-zulv1       = t001z-paval.
  PERFORM read_t001z USING t001-bukrs 'SAPA02'.
  aslm-zulv2       = t001z-paval.
  PERFORM read_t001z USING t001-bukrs 'SAPA03'.
  aslm-zulv3       = t001z-paval.
  PERFORM euro_curr USING t001-waers CHANGING aslm-peuro.    "euro

  hlp_line = 0.                                             "775681
  hlp_lsub = 0.                                             "775681
  aslm-corde = space.                                       "775681
  IF par_corr EQ 'X'.                                       "775681
    aslm-corde = '1'.                  "corrected report     "775681
  ENDIF.                                                    "775681

  DATA: outpars   LIKE pri_params,
        valid     TYPE c,
        jobname   LIKE tbtcjob-jobname,
        jobcount  LIKE tbtcjob-jobcount,
        stepcount LIKE tbtcjob-stepcount.                   "549974

  DATA: steplist LIKE tbtcstep OCCURS 10 WITH HEADER LINE.  "549974


  CALL FUNCTION 'GET_JOB_RUNTIME_INFO'
    IMPORTING
      jobcount        = jobcount
      jobname         = jobname
      stepcount       = stepcount                           "549974
    EXCEPTIONS
      no_runtime_info = 1.

  CALL FUNCTION 'BP_JOB_READ'
    EXPORTING
      job_read_jobcount     = jobcount
      job_read_jobname      = jobname
      job_read_opcode       = 20
    TABLES
      job_read_steplist     = steplist                      "549974
    EXCEPTIONS
      invalid_opcode        = 1
      job_doesnt_exist      = 2
      job_doesnt_have_steps = 3.

*----------------------------------------------------------------------*
* copy print parameters and archive parameters from PARAMETER          *
*----------------------------------------------------------------------*
  CLEAR ls_arparams.                                        "766359
  CLEAR ls_prparams.                                        "766359
  IF arp_form-sap_object NE space.                          "766359
    ls_arparams = arp_form.                                 "766359
  ENDIF.                                                    "766359
  CLEAR itcpo.                                              "766359
  CLEAR gs_idxparams.                                       "766359

  itcpo-tdreceiver = steplist-prrec.                        "549974
  itcpo-tddivision = steplist-prabt.                        "549974
  itcpo-tdautority = steplist-prber.                        "549974

* begin of deletion "766359
* if print_par ne space.                        "549974   "622072
*   itcpo = print_par.              "Druckparameter vom Sel. Bild
*  itcpo-tdsuffix1  = itcpo-tddest.     "Name des Druckers"YHR-02"549974
* end of deletion "766359
  IF prp_form-armod NE space.                               "766359
* copy general print parameters to itcpo                    "766359
    ls_prparams = prp_form.                                 "766359
    itcpo-tdpageslct = space.                               "766359
    itcpo-tdcopies   = ls_prparams-prcop.                   "766359
    itcpo-tddest     = ls_prparams-pdest.                   "766359
    itcpo-tdnoprev   = 'X'.                                 "766359
    itcpo-tdnewid    = 'X'.                                 "766359
    itcpo-tdimmed    = ls_prparams-primm.                   "766359
    itcpo-tddelete   = ls_prparams-prrel.                   "766359
    itcpo-tdlifetime = ls_prparams-pexpi.                   "766359
    itcpo-tdcover    = ls_prparams-prsap.                   "766359
    itcpo-tdreceiver = ls_prparams-prrec.                   "766359
    itcpo-tddivision = ls_prparams-prabt.                   "766359
    itcpo-tdautority = ls_prparams-prber.                   "766359
    itcpo-tdarmod    = ls_prparams-armod.                   "766359
    itcpo-tdsuffix1  = itcpo-tddest.                        "766359
  ELSE.                                                     "549974
    itcpo-tdpageslct = space.       "Druckseiten Auswahl           "YHR-02
    itcpo-tdnewid    = 'X'.         "neues Spool-Dataset erstellen "YHR-02
    itcpo-tdcopies   = 1.           "Anzahl Kopien                 "YHR-02
*  itcpo-tdpreview  = space.       "Druckbildanzeige           "YHR-02
    itcpo-tdimmed    = space.       "sofort drucken      "YHR-02"549974
    itcpo-tddelete   = space.       "Freigabe nach Druck  "YHR-02"549974
  ENDIF.                                                    "549974
  itcpo-tddataset  = 'LIST2S'.         "Dataset-Name
* itcpo-tdsuffix1  = par_prim.    "Name des Druckers   "YHR-02"549974
  itcpo-tdsuffix2  = 'ASL'.            "Kurzbezeichnung
  itcpo-tdtitle    = sy-title.         "Text-Beschreibung
  IF ls_prparams-prtxt = space.                             "983616
    itcpo-tdcovtitle = TEXT-051.       "Beschreibung der Ausgabedatei
  ELSE.                                                     "983616
    itcpo-tdcovtitle = ls_prparams-prtxt.                   "983616
  ENDIF.                                                    "983616

*----------------------------------------------------------------------*
* Ausgabe von "Formular" und der eingegebenen Beschreibung durch den   *
* Benutzer im Archiv                                                   *
*----------------------------------------------------------------------*
  gs_idxparams-function   = 'DARA'.                         "766359
  gs_idxparams-mandant    = sy-mandt.                       "766359
  gs_idxparams-sap_object = ls_arparams-sap_object.         "766359
  gs_idxparams-ar_object  = ls_arparams-ar_object.          "766359
  gs_idxparams-reserve(6) = 'COMMIT'.                       "766359

  IF gd_scr_form = 'X'.                                         "PDF
    CALL FUNCTION 'OPEN_FORM'
      EXPORTING
        archive_index  = gs_idxparams                        "766359
        archive_params = ls_arparams                         "766359
        form           = par_form
        device         = 'PRINTER'
        language       = sy-langu
        options        = itcpo
*       dialog         = 'X'            "YHR-02    +"549974      -"766359
        dialog         = ' '            "YHR-02    -"549974      +"766359
      EXCEPTIONS
        form           = 1.
    IF sy-subrc EQ 1.                    "Abbruch:
      MESSAGE a069(f0) WITH par_form.    "Formular ist nicht aktiv!
    ENDIF.

  ELSE.                                                              "PDF
    DATA sfpoutputparams TYPE sfpoutputparams.                     "PDF
    APPEND gs_idxparams TO gt_idxparams_adobe.                     "PDF

* get outputparameters
    PERFORM fill_outputparams_pdf USING itcpo
                                  CHANGING sfpoutputparams.        "PDF

    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = sfpoutputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.                                 "PDF
    IF sy-subrc <> 0.                                              "PDF
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.                                                         "PDF

  ENDIF.                                                           "PDF

  DESCRIBE TABLE tab LINES sy-tfill.   "britische Seitenzahl, Datum
  aslm-gbpag = ( sy-tfill + 14 ) DIV 15.
  aslm-gbnum = 0.
  READ TABLE br_budat INDEX 1.
  aslm-date1 = br_budat-low.
  aslm-date2 = br_budat-high.

  IF gd_vatdate_active = 'X'.                               "1023317
    IF     aslm-date1 IS INITIAL                            "1023317
       AND aslm-date2 IS INITIAL.                           "1023317
      READ TABLE br_vatdt INDEX 1.                          "1023317
      aslm-date1 = br_vatdt-low.                            "1023317
      aslm-date2 = br_vatdt-high.                           "1023317
    ENDIF.                                                  "1023317
  ENDIF.                                                    "1023317

*----------------------------------------------------------------------*
* Zusammensetzen des Objektschlüssels entweder aus Umsatzsteuerkreis,  *
* Quartalsjahr und Quartal oder aus Umsatzsteuerkreis, Anfangs-        *
* Datum und End-Datum der Selektion. Dieser Schlüssel kann auch als    *
* Suchbegriff bei der Archivsuche verwendet werden                     *
*----------------------------------------------------------------------*
  IF aslm-quart > 0.                                        "766359
    CONCATENATE hlp_umkrs aslm-ajahr  aslm-quart            "766359
    ls_arparams-info                                        "766359
    INTO gs_idxparams-object_id.                            "766359
  ELSEIF aslm-monat > 0.                                    "870277
    CONCATENATE hlp_umkrs aslm-ajahr  aslm-monat            "870277
    ls_arparams-info                                        "870277
    INTO gs_idxparams-object_id.                            "870277
  ELSE.                                                     "766359
    CONCATENATE hlp_umkrs aslm-date1 aslm-date2             "766359
    ls_arparams-info                                        "766359
    INTO gs_idxparams-object_id.                            "766359
  ENDIF.                                                    "766359

*----------------------------------------------------------------------*
* Füllen der Form mit den Werten der DARA-Zeile (SAPScript)            *
*----------------------------------------------------------------------*

  IF gd_scr_form = 'X'.                                     "PDF

* CALL FUNCTION 'START_FORM'.                                "766359
    CALL FUNCTION 'START_FORM'                              "766359
      EXPORTING                                             "766359
        archive_index = gs_idxparams.                       "766359

    aslm-totav = space.
    aslm-nocus = 0.
    CLEAR hlp_stceg.                                          "note 367288
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element  = '510'
        type     = 'TOP'
        function = 'APPEND'
      EXCEPTIONS
        window   = 1
        element  = 2.
  ELSE.                                                        "PDF
    gs_t001_adobe = t001.                                      "PDF
    gs_sadr_adobe = sadr.                                   "1242028
    CLEAR gt_aslm_adobe[].                                  "1646825
  ENDIF.                                                       "PDF

ENDFORM.                    "start_asl



*---------------------------------------------------------------------*
*       FORM WRITE_ASL                                                *
*---------------------------------------------------------------------*
*       Schreiben einer Zeile der Zusammenfassenden Meldung           *
*---------------------------------------------------------------------*
*       Keine USING-Parameter                                         *
*---------------------------------------------------------------------*
FORM write_asl.

  DATA:
    p_amount TYPE aflex14d2o19s.   "AFLE enablement original (7)type p,
  TABLES spell.

  IF gd_scr_form = 'X'.                                     "PDF
* page break after par_lpp lines and restart line numbers   "775681
    IF par_lpp GT 0.                                        "775681
      ADD 1 TO hlp_line.                                    "775681
      IF hlp_line GT par_lpp.                               "775681
        hlp_line = 1.                                       "775681
        ADD par_lpp TO hlp_lsub.                            "775681
        CALL FUNCTION 'WRITE_FORM'                          "775681
          EXPORTING                                      "775681
            element = '520'                           "775681
          EXCEPTIONS                                     "775681
            window  = 1                               "775681
            element = 2.                              "775681
      ENDIF.                                                "775681
    ENDIF.                                                  "775681
  ENDIF.                                                    "PDF

  aslm-nummr   = tab-lfdnr+3(5)        "Laufende Nummer
                 - hlp_lsub            "Abzug durch PAR_LPP "775681
                 - hlp_subtr.          "Abzug durch Parameter PAR_SKIP

  ADD 1 TO aslm-gbnum.                 "britische Numerierung
  IF aslm-gbnum GT 15.
    aslm-gbnum = 1.
    aslm-gbcus = 15.
  ENDIF.

  aslm-dmshb   = tab-dmshb.            "Betrag mit Vorkommastellen
  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      language = space
      currency = t001-waers
      amount   = tab-dmshb
    IMPORTING
      in_words = spell.
  p_amount     = spell-number.         "Betrag ohne Vorkommastellen
  IF tab-dmshb LT 0.
    p_amount   = - p_amount.
  ENDIF.
  WRITE p_amount TO aslm-dmshv CURRENCY '0'.

  p_amount = ( tab-dmshb / 100 ) * 100."britischer Betrag
  WRITE p_amount TO aslm-gbshb CURRENCY t001-waers.
  IF tab-dmshb LT 0.
    WRITE '(' TO aslm-gbshb(1).
    WRITE ')' TO aslm-gbshb+20(1).
    CONDENSE aslm-gbshb NO-GAPS.
    WRITE aslm-gbshb TO aslm-gbshb
      USING EDIT MASK 'RR_____________________'.
  ENDIF.

  IF tab-ind EQ 1.                     "Lohnveredelungsindikator
    aslm-lvind = '1'.
  ELSE.
    aslm-lvind = space.
  ENDIF.
  IF tab-ind EQ 2.                     "Dienstleistung      "1384895
    aslm-xegsrv = '1'.                                      "1384895
  ELSE.                                                     "1384895
    aslm-xegsrv = space.                                    "1384895
  ENDIF.                                                    "1384895
  IF tab-xegdr EQ 1.                   "Dreiecksgeschäftsindikator
    aslm-dreie = '1'.
  ELSE.
    aslm-dreie = space.
  ENDIF.
  aslm-deind = space.          "indicator for DE            "1402105
  aslm-beind = space.          "indicator for BE            "1402105
  aslm-gbind = space.          "indicator for GB            "1402105
  IF tab-xegdr EQ 1.
*   aslm-deind = '1'.                             "1402105  "1425810
    aslm-deind = '2'.                  "deutscher Indikator "1425810
    aslm-beind = 'T'.                  "belgischer Indikator
    aslm-gbind = '2'.                  "britischer Indikator
  ELSEIF tab-ind EQ 1.
    aslm-beind = 'A'.
*    aslm-gbind = '1'.                                      "1402105
  ELSEIF tab-ind EQ 2.   "Services                          "1402105
*   aslm-deind = '2'.                             "1402105  "1425810
    aslm-deind = '1'.                                       "1425810
    aslm-beind = 'S'.                                       "1402105
    aslm-gbind = '3'.                                       "1402105
* ELSE.                                                     "1402105
*    aslm-beind = space.                                    "1402105
*    aslm-gbind = space.                                    "1402105
  ENDIF.

  aslm-stceg   = space.
  aslm-kunnr   = space.
  aslm-name1   = space.
  aslm-stras   = space.
  aslm-ort01   = space.
  aslm-pstlz   = space.

  "Lesen der Anschriftsdaten ggf.
  IF par_skip EQ space OR              "nur bei Wechsel der Steuernummer
   ( par_skip NE space AND hlp_stceg NE tab-stceg ).
    aslm-stceg = tab-stceg.
    aslm-kunnr = tab-ktnra.
    IF par_addr NE space OR pdf_form NE space.              "PDF
      aslm-name1 = tab-name1.                               "530539
      aslm-stras = tab-stras.                               "530539
      aslm-ort01 = tab-ort01.                               "530539
      aslm-pstlz = tab-pstlz.                               "530539
    ENDIF.
  ENDIF.

  aslm-xegcos     = tab-xegcos.                             "3302554 - EE Call-off stock

  IF hlp_stceg NE tab-stceg.           "Anzahl Kunden in der Liste
    hlp_stceg  = tab-stceg.
    ADD 1 TO aslm-nocus.
    IF aslm-nocus CN '0'.
      SHIFT aslm-nocus LEFT BY sy-fdpos PLACES.
    ENDIF.
  ELSEIF par_skip NE space.            "ggf. laufende Nummer nicht
    ADD 1 TO hlp_subtr.                "ausgeben bei gleicher Steuernr.
    SHIFT aslm-nummr BY 5 PLACES.
  ENDIF.

  IF gd_scr_form = 'X'.                                     "PDF
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element = '500'
      EXCEPTIONS
        window  = 1
        element = 2.
    IF sy-subrc NE 0.                    "Abbruch:
      MESSAGE a706 WITH par_form '500' 'MAIN'.
    ENDIF.                               "Element 500 (Fenster MAIN) fehlt
  ENDIF.                                                       "PDF

  aslm-gbcus = aslm-gbnum.             "britische Anzahl Kunden

  ADD aslm-dmshb TO aslm-total.        "Summe mit Nachkommastellen
  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      language = space
      currency = t001-waers
      amount   = aslm-total
    IMPORTING
      in_words = spell.
  p_amount     = spell-number.         "Summe ohne Nachkommastellen
  IF aslm-total LT 0.
    p_amount   = - p_amount.
  ENDIF.
  WRITE p_amount TO aslm-totav CURRENCY '0'.
  IF gd_pdf_form = 'X'.                          "PDF
    MOVE-CORRESPONDING aslm TO gs_aslm_adobe.    "PDF
    APPEND gs_aslm_adobe TO gt_aslm_adobe.       "PDF
  ENDIF.                                         "PDF

ENDFORM.                    "write_asl



*---------------------------------------------------------------------*
*       FORM END_ASL                                                  *
*---------------------------------------------------------------------*
*       Ende der Zusammenfassenden Meldung                            *
*---------------------------------------------------------------------*
*       Keine USING-Parameter                                         *
*---------------------------------------------------------------------*
FORM end_asl.

  DATA BEGIN OF tab_windows OCCURS 10.
  INCLUDE STRUCTURE itcwe.
  DATA END OF tab_windows.

  IF gd_scr_form = 'X'.                                           "PDF
    CALL FUNCTION 'END_FORM'
      IMPORTING
        result = itcpp.

    CALL FUNCTION 'READ_FORM_ELEMENTS'
      TABLES
        elements = tab_windows.
    LOOP AT tab_windows.
      IF tab_windows-window(5) EQ 'TITLE'. EXIT. ENDIF.
    ENDLOOP.
    IF tab_windows-window(5) EQ 'TITLE'.
      aslm-nopag = itcpp-tdpages.
      IF aslm-nopag CN '0'.
        SHIFT aslm-nopag LEFT BY sy-fdpos PLACES.
      ENDIF.
      CALL FUNCTION 'START_FORM'
        EXPORTING
          startpage = 'FIRST'.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          window = 'TITLE1'
        EXCEPTIONS
          window = 1.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          window = 'TITLE2'
        EXCEPTIONS
          window = 1.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          window = 'TITLE3'
        EXCEPTIONS
          window = 1.
      CALL FUNCTION 'END_FORM'.
    ENDIF.
  ELSE.                                                           "PDF
    DATA fm_name TYPE rs38l_fnam.
    DATA fp_docparams TYPE sfpdocparams.
    DATA form_name TYPE fpname.

    form_name = par_pdf.                                          "PDF

    TRY.
        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
          EXPORTING
            i_name     = form_name
          IMPORTING
            e_funcname = fm_name.
      CATCH cx_fp_api.
    ENDTRY.

    fp_docparams-langu = sy-langu.
* country is a obligatory field for PDF forms.
* Not sure, which meaning the country has for PDF form processing
    IF sel_lstm-low NE space.                                       "PDF
      fp_docparams-country = sel_lstm-low.                        "PDF
    ELSE.                                                           "PDF
      fp_docparams-country = gs_t001_adobe-land1.                 "PDF
    ENDIF.                                                          "PDF

    fp_docparams-daratab = gt_idxparams_adobe.                    "PDF

    DATA lt_aslm_adobe TYPE aslm_adobe_t.                         "PDF
    DATA gs_aslm_adobe TYPE aslm.
    DATA ls_aslm_adobe TYPE aslm_adobe.                           "PDF

* Move gt_aslm_adobe into lt_aslm_adobe
    LOOP AT gt_aslm_adobe INTO gs_aslm_adobe.
      MOVE-CORRESPONDING gs_aslm_adobe TO ls_aslm_adobe. "PDF
      ls_aslm_adobe-stceg_country = gs_aslm_adobe-stceg(2).       "PDF
      ls_aslm_adobe-stceg_number = gs_aslm_adobe-stceg+2(18).     "PDF
      APPEND ls_aslm_adobe TO lt_aslm_adobe.                      "PDF
    ENDLOOP.                                                      "PDF

    CALL FUNCTION fm_name
      EXPORTING
        /1bcdwb/docparams = fp_docparams
        ls_t001           = gs_t001_adobe
        ls_sadr           = gs_sadr_adobe
        lt_aslm           = lt_aslm_adobe
        ls_aslm1          = ls_aslm_adobe                    "1486848
      EXCEPTIONS
        usage_error       = 1
        system_error      = 2
        internal_error    = 3
        OTHERS            = 4.                                    "PDF

  ENDIF.  "ADOBE

  IF gd_scr_form = 'X'.                                           "PDF

    CALL FUNCTION 'CLOSE_FORM'
      IMPORTING
        result = itcpp.
  ELSE.                                                           "PDF
    DATA sfpjoboutput TYPE sfpjoboutput.                          "PDF

    CALL FUNCTION 'FP_JOB_CLOSE'
      IMPORTING
        e_result       = sfpjoboutput                             "PDF
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    DATA ls_spoolids TYPE rspoid.                                 "PDF
    READ TABLE sfpjoboutput-spoolids INDEX 1 INTO ls_spoolids.    "PDF

    tab_output-bukrs = hlp_umkrs.
    tab_output-flag  = 2.
    tab_output-name  = 'LIST2S'.
    tab_output-spono = ls_spoolids.
    APPEND tab_output.

  ENDIF.                                                          "PDF

* output spool identification of Form                      "766359
  IF itcpp-tdarmod CA '13'.                                 "766359
    tab_output-bukrs = hlp_umkrs.
    tab_output-flag  = 2.
    tab_output-name  = 'LIST2S'.
    tab_output-spono = itcpp-tdspoolid.
    APPEND tab_output.
  ENDIF.                                                    "766359

* archive identification of Form                           "766359
  IF itcpp-tdarmod CA '23'.                                 "766359
    tab_output-bukrs  = hlp_umkrs.                          "766359
    tab_output-flag   = 6.                                  "766359
    tab_output-busobj = gs_idxparams-sap_object.            "766359
    tab_output-dokart = gs_idxparams-ar_object.             "766359
    tab_output-objid  = gs_idxparams-object_id.             "766359
    APPEND tab_output.                                      "766359
  ENDIF.                                                    "766359

ENDFORM.                    "end_asl

*---------------------------------------------------------------------*
*       FORM EURO_CURR                                                *
*---------------------------------------------------------------------*
* Überprüft ob die meldende Währung EURO ist.                         *
*---------------------------------------------------------------------*
FORM euro_curr USING waers LIKE t001-waers                   "euro
               CHANGING x_euro TYPE c.

  SELECT SINGLE * FROM tcurc WHERE waers = waers.
  IF sy-subrc NE 0.
    MESSAGE e883(b1) WITH waers.
  ELSE.
    IF tcurc-isocd = 'EUR'.
      x_euro = '1'.
    ELSE.
      CLEAR x_euro.
    ENDIF.
  ENDIF.
ENDFORM.                               "euro

* Begin of PDF
FORM fill_outputparams_pdf USING    p_itcpo TYPE itcpo
                   CHANGING p_outputparams TYPE sfpoutputparams.

  p_outputparams-device       = p_itcpo-tdprinter.
  p_outputparams-nodialog     = 'X'.
  p_outputparams-preview      = p_itcpo-tdpreview.
*p_outputparams-GETPDF       =
*p_outputparams-GETPDL       =
*p_outputparams-CONNECTION   =

  p_outputparams-dest         = p_itcpo-tddest.
  p_outputparams-reqnew       = p_itcpo-tdnewid.
  p_outputparams-reqimm       = p_itcpo-tdimmed.
  p_outputparams-reqdel       = p_itcpo-tddelete.
  p_outputparams-reqfinal     = p_itcpo-tdfinal.
*p_outputparams-SPOOLID      =
  p_outputparams-senddate     = p_itcpo-tdsenddate.
  p_outputparams-sendtime     = p_itcpo-tdsendtime.
  p_outputparams-schedule     = p_itcpo-tdschedule.
  p_outputparams-copies       = p_itcpo-tdcopies.
  p_outputparams-dataset      = p_itcpo-tddataset.
  p_outputparams-suffix1      = p_itcpo-tdsuffix1.
  p_outputparams-suffix2      = p_itcpo-tdsuffix2.
  p_outputparams-covtitle     = p_itcpo-tdcovtitle.
  p_outputparams-cover        = p_itcpo-tdcover.
  p_outputparams-receiver     = p_itcpo-tdreceiver.
  p_outputparams-division     = p_itcpo-tddivision.
  p_outputparams-lifetime     = p_itcpo-tdlifetime.
*p_outputparams-AUTHORITY    =
  p_outputparams-rqposname    = p_itcpo-rqposname.
*p_outputparams-PDLTYPE      =
*p_outputparams-XDCNAME      =
*p_outputparams-NOPDF        =
*p_outputparams-SPONUMIV     =

  p_outputparams-arcmode      = p_itcpo-tdarmod.
  p_outputparams-noarmch      = p_itcpo-tdnoarmch.

  p_outputparams-title        = p_itcpo-tdtitle.
  p_outputparams-nopreview    = p_itcpo-tdnoprev.
  p_outputparams-noprint      = p_itcpo-tdnoprint.
*p_outputparams-NOARCHIVE    =
*p_outputparams-IMMEXIT      =
*p_outputparams-NOPRIBUTT    =

ENDFORM.                    " fill_outputparams
* End of PDF

INCLUDE make_rldnr_invisible.                               "871301

*&---------------------------------------------------------------------*
*&      Form  CONDENSE_ASL_LINE                             "1384895
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM condense_asl_line.                                     "1384895

  DATA: ls_tabc  LIKE LINE OF tab,
        lt_tabc  LIKE TABLE OF ls_tabc,
        ls_index TYPE i,
        ls_xegdr TYPE xegdr.

  LOOP AT tab.
    ls_tabc-bukrs = tab-bukrs.
    ls_tabc-stceg = tab-stceg.
    ls_tabc-ind   = tab-ind.
    ls_tabc-xegdr = tab-xegdr.
    ls_tabc-dmshb = tab-dmshb.
    ls_tabc-xegcos = tab-xegcos.                           "3302554 - EE Call-off stock

    IF par_skip NE space.
*   Belgischer Indikator ASLM-BEIND ist T, wenn XEGDR = 1.
*   Daher in diesem Fall HLP_IND ignorieren
*   und Werte kumulieren
      IF ls_tabc-xegdr EQ '1' AND
         ls_tabc-ind   EQ '1'.
        ls_tabc-ind = '0'.
      ENDIF.
    ENDIF.
    IF par_lohn NE space  AND
       ls_tabc-ind EQ '1'.
      ls_tabc-ind = '0'.
    ENDIF.
    IF par_drei NE space.
      ls_tabc-xegdr = '0'.
    ENDIF.
    COLLECT ls_tabc INTO lt_tabc.
  ENDLOOP.

  SORT lt_tabc
       BY bukrs
          stceg
          xegdr
          ind.
  SORT tab
       BY bukrs
          stceg
          xegdr
          ind.

  LOOP AT lt_tabc INTO ls_tabc.
    ls_tabc-lfdnr = sy-tabix.
    READ TABLE tab
         WITH KEY bukrs = ls_tabc-bukrs
                  stceg = ls_tabc-stceg.
    IF sy-subrc = 0.
      ls_index = sy-tabix.
      ls_tabc-koart = tab-koart.
      ls_tabc-ktnra = tab-ktnra.
      ls_tabc-name1 = tab-name1.
      ls_tabc-stras = tab-stras.
      ls_tabc-ort01 = tab-ort01.
      ls_tabc-pstlz = tab-pstlz.
      IF par_drei NE space
         AND ls_tabc-ind CA '01'.                           "1435932
        ls_xegdr = '0'.
        LOOP AT tab FROM ls_index.
          IF tab-bukrs NE ls_tabc-bukrs OR
             tab-stceg NE ls_tabc-stceg.
            EXIT.
          ENDIF.
          IF tab-xegdr EQ '1'.
            ls_xegdr = '1'.
          ENDIF.
        ENDLOOP.
        ls_tabc-xegdr = ls_xegdr.
      ENDIF.
    ENDIF.
    MODIFY lt_tabc FROM ls_tabc.
  ENDLOOP.

  tab[] = lt_tabc[].
  tab   = ls_tabc.

ENDFORM.                    " CONDENSE_ASL_LINE             "1384895
*&---------------------------------------------------------------------*
*&      Form  at-selection-screen                           "2252566
*&---------------------------------------------------------------------*
*     Selection screen processing called from Include RFASLI00
*----------------------------------------------------------------------*
FORM at-selection-screen.                                   "2252566

* Check if at least one form of output is active            "2252566
* (If 'only list output' then 'line item list'              "2252566
*  must still be selected manually.)                        "2252566
  IF par_list = 'X' AND                                     "2252566
     par_epos IS INITIAL.                                   "2252566
    SET CURSOR FIELD 'PAR_EPOS'.                            "2252566
    MESSAGE e177.                                           "2252566
  ENDIF.                                                    "2252566

ENDFORM.                    " at-selection-screen.          "2252566
