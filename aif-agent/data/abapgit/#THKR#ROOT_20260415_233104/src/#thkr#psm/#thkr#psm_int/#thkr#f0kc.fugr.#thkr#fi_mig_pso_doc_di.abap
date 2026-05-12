FUNCTION /thkr/fi_mig_pso_doc_di.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_NODATA) LIKE  BGR00-NODATA DEFAULT '/'
*"     VALUE(I_DEL_NODATA) LIKE  BOOLE-BOOLE DEFAULT 'X'
*"     VALUE(I_INTLOT) TYPE  C DEFAULT SPACE
*"     VALUE(I_NRKRS_LOT) LIKE  INRI-NRRANGENR DEFAULT SPACE
*"     VALUE(I_LOTKZ_ALLOC) LIKE  BOOLE-BOOLE DEFAULT 'X'
*"     VALUE(I_NO_FIELD_STATUS) LIKE  BOOLE-BOOLE DEFAULT SPACE
*"     VALUE(I_NO_ACC_DETERM) LIKE  BOOLE-BOOLE DEFAULT SPACE
*"     VALUE(I_INVERSE_POSTING) LIKE  BOOLE-BOOLE DEFAULT SPACE
*"     VALUE(I_CHECK) LIKE  BOOLE-BOOLE DEFAULT SPACE
*"     VALUE(I_DATE_CONVERT) LIKE  BOOLE-BOOLE DEFAULT SPACE
*"     VALUE(I_NO_CHECK) TYPE  BOOLE-BOOLE DEFAULT SPACE
*"     VALUE(I_NO_FI_NUMBER) TYPE  BOOLE-BOOLE DEFAULT SPACE
*"     VALUE(I_XPRFG) TYPE  XPRFG DEFAULT 'X'
*"     VALUE(I_DERIVE) TYPE  BOOLE-BOOLE DEFAULT SPACE
*"     VALUE(I_DUE_DATE_DEFERRAL) TYPE  BOOLE-BOOLE DEFAULT SPACE
*"     VALUE(I_MIG_DATA) TYPE  /THKR/S_MIG_PSO_DI_DATA OPTIONAL
*"  EXPORTING
*"     VALUE(E_BUKRS) LIKE  ACCIT-BUKRS
*"     VALUE(E_GJAHR) LIKE  ACCIT-GJAHR
*"     VALUE(E_BELNR) LIKE  ACCIT-BELNR
*"     VALUE(E_LOTKZ) LIKE  ACCIT-LOTKZ
*"  TABLES
*"      T_BBKPF STRUCTURE  BBKPF_FM
*"      T_BBSEG STRUCTURE  BBSEG_FM
*"      T_BBTAX STRUCTURE  BBTAX_FM OPTIONAL
*"      T_BWITH STRUCTURE  BWITH_DI OPTIONAL
*"      T_PSO50 STRUCTURE  PSO50 OPTIONAL
*"----------------------------------------------------------------------
**********************************************************************
* THKR Kopie des SAP Original Funktionsbausteins 'FI_PSO_DOC_DIRECT_INPUT'
* Alle geänderten Stellen sind mit "THKR" gekennzeichnet
* Notwendig ist dies, damit man auch Änderungen von AO vornehmen kann.
* und ggf. weiteren Funktionen die im Std. nicht unterstützt werden.

** I_DUE_DATE_DEFERRAL neuer Importparameter für Ratenstundung.
** Anpassen des Codings, da der Ursprüngliche Fnktionsbaustein nur ein Beleg pro AO
** innerhalb einer Verarbeitung zulässt.
**  Alle geänderten Stellen sind mit "THKR_DUE_DATE" gekennzeichnet
***********************************************************************
  STATICS: BEGIN OF l_t_belnr  OCCURS 0,
             belnr LIKE vbkpf-belnr,
           END   OF l_t_belnr.

**********************************************************************
** /THKR/ wenn man mehrere Belege insb. Stundungen erzeugt, dann darf hier nicht die Belegnummer vom letzten Aufruf drin stehen.
*  CLEAR l_t_belnr.
*  REFRESH l_t_belnr.
**********************************************************************


  DATA: l_t_vbkpf     LIKE vbkpf       OCCURS 0 WITH HEADER LINE,
        l_t_vbseg     LIKE vbseg       OCCURS 0 WITH HEADER LINE,
        l_t_vbsec     LIKE vbsec       OCCURS 0 WITH HEADER LINE,
        l_t_vbset     LIKE vbset       OCCURS 0 WITH HEADER LINE,
        l_t_vbkpf_old LIKE vbkpf       OCCURS 0 WITH HEADER LINE,
        l_t_vbseg_old LIKE vbseg       OCCURS 0 WITH HEADER LINE,
        l_t_vbsec_old LIKE vbsec       OCCURS 0 WITH HEADER LINE,
        l_t_vbset_old LIKE vbset       OCCURS 0 WITH HEADER LINE.

  DATA: l_t_item      LIKE pso02s      OCCURS 0 WITH HEADER LINE,
        l_t_item_old  LIKE pso02s      OCCURS 0 WITH HEADER LINE,
        l_t_pssec     TYPE fipso_bsec  OCCURS 0 WITH HEADER LINE,
        l_t_pssec_old TYPE fipso_bsec  OCCURS 0 WITH HEADER LINE,
        l_t_pso       LIKE pso02       OCCURS 0 WITH HEADER LINE,
        l_t_pso_old   LIKE pso02       OCCURS 0 WITH HEADER LINE,
        l_t_payac01   LIKE payac01     OCCURS 0 WITH HEADER LINE,
        l_t_pso50     LIKE pso50       OCCURS 0 WITH HEADER LINE.

  DATA: l_t_tiban   LIKE tiban OCCURS 0 WITH HEADER LINE. "note1710829

  DATA: l_tabkey(24).                                    "note1710829

  DATA: l_f_pso       LIKE pso02,
        l_f_pso_old   LIKE pso02,
        l_f_ppsec_old TYPE fipso_bsec,
        l_f_payac05   LIKE payac05,
        l_ktabline    LIKE sy-tabix,
        l_who_activ   LIKE pso43,
        l_activity    LIKE tact-actvt VALUE con_act_insert,
        l_okcode      LIKE sy-ucomm,
        l_tcode       LIKE bkpf-tcode,
        l_tax_mode    TYPE c,
        l_subrc       LIKE sy-subrc,
        l_lotkz       LIKE pso02-lotkz,
        l_buzei       LIKE pso02-buzei,
        l_psosum      LIKE fmdy-psosu,
        l_psosf       LIKE pso02-psosf,   "Steuerfinanzposition
        l_belnr       LIKE vbkpf-belnr,
        l_fipos       LIKE pso02-fipos,
        l_recurring   LIKE boole-boole,
        l_xpp         LIKE boole-boole,                   "PRELIMINARY?
        l_psoxwf      LIKE pso02-psoxwf,                   "Workflow
        l_flg_post    LIKE boole-boole,                    "Buchen?
        l_flg_inverse LIKE boole-boole,
        l_flg_save    LIKE boole-boole,           "Vorerfaßt speichern?
        l_flg_check   LIKE boole-boole VALUE 'X',          "dummy
* Gereon Koks  6.2.2026  TSI
        l_iban        TYPE iban.


  FIELD-SYMBOLS <fs_l_pso>  TYPE pso02.
  FIELD-SYMBOLS <fs_l_item> TYPE pso02s.

  DATA: c_subrc TYPE sy-subrc.

* Fuer Mittelreservierung:
  DATA: l_xrecov LIKE boole-boole VALUE space,        "Dummy-Felder
        l_xpayko LIKE payko OCCURS 0. "Dummy-Felder
* Mittelreservierung muss wissen, dass sie aus dem Direct-Input auf-
* gerufen wird - (fuer Abbau bei Buchung)
  DATA: l_flg_direct_input LIKE boole-boole VALUE 'X'.

* welche Customizingeinstellungen liegen vor?
  CALL FUNCTION 'FI_PSO_PSO43_READ'
    IMPORTING
      e_pso35 = l_who_activ
    EXCEPTIONS
      OTHERS  = 1.

* Nodata-Kennzeichen (vom Batch-Input) entfernen
  IF NOT i_del_nodata IS INITIAL.
    PERFORM bereinige_bbtabs
                TABLES   t_bbkpf
                         t_bbseg
                         t_bbtax
                         t_bwith
                USING    i_nodata.
  ENDIF.

  LOOP AT t_bbkpf.
*-----T_BBKPF darf eigentlich nur eine Zeile enthalten

* Buchungskreisdaten ermitteln:
    l_ktabline = sy-tabix.
    l_buzei = 1.

* Soll vorerfasst oder gebucht werden?
    IF t_bbkpf-tcode EQ 'FB01'.
      CLEAR l_xpp.
    ELSEIF t_bbkpf-tcode EQ 'FBV1'.
      l_xpp = char_x.
    ELSE.
      MESSAGE e244(fq) WITH t_bbkpf-tcode.
    ENDIF.

    IF t_bbkpf-psoty EQ space.
      MESSAGE e844(fq).
*       Nur Anordnungen buchen:
    ENDIF.

*-----Transaktionscode fuer Anordnung belegen
    CALL FUNCTION 'FI_PSO_TCODE_GET'
      EXPORTING
        i_psoty      = t_bbkpf-psoty
        i_activity   = l_activity
        i_xrecurring = l_recurring
      IMPORTING
        e_tcode      = l_tcode.

    MOVE: l_tcode TO t_bbkpf-tcode.

    IF t_bbkpf-blart EQ space.
      MESSAGE e721(fq) WITH TEXT-100.
*       Das Feld 'Belegart' muß gefüllt werden.
    ENDIF.

*     Pruefen ob Belegart und Anordnungstyp zusammenpassen
    CALL FUNCTION 'FI_PSO_DOC_TYPE_PSOTY_CHECK'
      EXPORTING
        i_psoty = t_bbkpf-psoty
        i_blart = t_bbkpf-blart.

    MOVE-CORRESPONDING t_bbkpf TO l_f_pso.
*   User data fill
    l_f_pso-cpudt = sy-datum.
    l_f_pso-cputm = sy-uzeit.
    l_f_pso-usnam = sy-uname.

*   nur vorerfassen:
    IF NOT l_xpp IS INITIAL.
      l_f_pso-bstat = 'V'.
    ENDIF.
    l_f_pso-buzei = l_buzei.
    PERFORM conv_datformat_pso
                USING       i_date_convert
                            char_k
                            char_x
                CHANGING    t_bbkpf
                            t_bbseg
                            t_bbtax
                            l_f_pso.

    CALL FUNCTION 'FI_PSO_COMPANY_CODE_READ'
      CHANGING
        c_f_pso = l_f_pso.

*-----read company code variant
    CALL FUNCTION 'FI_PSO_BUKFM_READ'
      EXPORTING
        i_bukrs     = l_f_pso-bukrs
      CHANGING
        c_f_payac05 = l_f_payac05.

* Jahr und Monat aus Datum bestimmen:
    CALL FUNCTION 'FI_PSO_PERIOD_CHECK'
      EXPORTING
        i_budat       = l_f_pso-budat
        i_bukrs       = l_f_pso-bukrs
        i_bldat       = l_f_pso-bldat
      CHANGING
        c_gjahr       = l_f_pso-gjahr
        c_monat       = l_f_pso-monat
      EXCEPTIONS
        error_message = 1.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid  TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL FUNCTION 'FI_PSO_FI_HEADER_FILL'
      EXPORTING
        i_t_pso   = l_f_pso
        i_xprfg   = i_xprfg
        i_okcode  = char_space
      TABLES
        c_t_vbkpf = l_t_vbkpf
        i_t_item  = l_t_item.

    PERFORM conv_currformat
                USING       char_k
                CHANGING    t_bbkpf
                            t_bbseg
                            t_bbtax.

*-----check no fipos!
    LOOP AT t_bbseg WHERE NOT fipos IS INITIAL.
      MESSAGE e507(fq) WITH ' ' sy-tabix.
*     Beleg &1 Satz &2: Feld 'FIPEX' statt 'FIPOS' muß gefüllt werden
    ENDLOOP.

*   fill L_T_PSO and L_T_ITEM depending on request category
*   and inverse posting flag
    IF t_bbkpf-psoty EQ char_03 OR t_bbkpf-psoty EQ char_09.
*         Verrechnungsanordnung
      PERFORM clearing_request_fill TABLES   t_bbseg
                                             t_bbtax
                                             l_t_pso
                                             l_t_item
                                             l_t_pssec
                                    USING    l_who_activ
                                             i_date_convert
                                             l_activity
                                             i_no_field_status
                                             i_no_acc_determ
                                    CHANGING t_bbkpf
                                             l_f_pso.

    ELSEIF i_inverse_posting IS INITIAL AND
         ( t_bbkpf-psoty EQ char_06 OR
           t_bbkpf-psoty EQ char_07 OR
           t_bbkpf-psoty EQ char_08   ).
*    deferral request, temporary waiver or remission (no inverse post.)
*    fill L_T_PSO and L_T_ITEM from reference document
      PERFORM r_d_c_fill TABLES   t_bbseg
                                  t_bbtax
                                  l_t_pso
                                  l_t_item
                                  l_t_pssec
                         USING    l_who_activ
                                  l_f_payac05
                                  i_date_convert
                                  l_activity
                                  i_no_field_status
                                  i_no_acc_determ
* Gereon Koks  6.2.2026  TSI
                                  l_xpp
                         CHANGING t_bbkpf
                                  l_f_pso
                                  l_flg_inverse
* Gereon Koks  6.2.2026  TSI
                                  l_iban.

    ELSE.
*         Normalfall
      PERFORM normal_case_fill TABLES   t_bbseg
                                        t_bbtax
                                        l_t_pso
                                        l_t_item
                                        l_t_pssec
                               USING    l_who_activ
                                        l_f_payac05
                                        i_date_convert
                                        l_activity
                                        i_no_field_status
                                        i_no_acc_determ
                                        i_xprfg
* Gereon Koks  6.2.2026  TSI
                                        l_xpp
                               CHANGING t_bbkpf
                                        l_f_pso
* Gereon Koks  6.2.2026  TSI
                                        l_iban.
    ENDIF.

* new development: COBl derive for FBV1 note 2833210
    IF i_derive IS NOT INITIAL.
      LOOP AT l_t_pso ASSIGNING <fs_l_pso>.
        CHECK l_xpp = 'X'.
        LOOP AT l_t_item ASSIGNING <fs_l_item> WHERE itabkey = <fs_l_pso>-itabkey.

          PERFORM cobl_data_structure IN PROGRAM saplf0ka USING '01'
                                                                space
                                                                'X'
                                                       CHANGING <fs_l_pso>
                                                                <fs_l_item>
                                                                c_subrc.
          CLEAR <fs_l_item>-fipos.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

* Prüfung auf doppelte Rechnung
    LOOP AT l_t_pso ASSIGNING <fs_l_pso> WHERE koart = char_k.
      PERFORM check_duplicate_doc(saplf0ka) USING <fs_l_pso>.
    ENDLOOP.

* Waehrungs- und Kursdaten:
    READ TABLE l_t_pso INDEX 1.
    DATA: lv_dmbtr TYPE dmbtr,
          lv_wrbtr TYPE wrbtr.
    lv_dmbtr = l_t_pso-dmbtr.
    lv_wrbtr = l_t_pso-wrbtr.
    CALL FUNCTION 'FI_PSO_CURRENCY_CHECK'
      EXPORTING
        i_bldat = l_t_pso-bldat
        i_budat = l_t_pso-budat
        i_bukrs = l_t_pso-bukrs
        i_blart = l_t_pso-blart
        i_waers = l_t_pso-waers
        i_xdia  = 'X'
        i_hwaer = l_t_pso-hwaer
        i_dmbtr = lv_dmbtr
        i_wrbtr = lv_wrbtr
      CHANGING
        c_kursf = l_t_pso-kursf
        c_wwert = l_t_pso-wwert.

*-----substitution of fields
    PERFORM fields_substitute(saplf0ka) TABLES l_t_pso
                                               l_t_item
                                        USING  l_activity
                                        CHANGING l_t_pssec[].

*---call BTE 00107040 for substitution
    CALL FUNCTION 'FM_FI_PROCESS_00107040_CALL'
      TABLES
        c_t_pso02  = l_t_pso
        c_t_pso02s = l_t_item.

*-----check no fipos!
    LOOP AT l_t_item WHERE NOT fipos IS INITIAL.
      MESSAGE e507(fq) WITH ' ' sy-tabix.
*   Beleg &1 Satz &2: Feld 'FIPEX' statt 'FIPOS' muß gefüllt werden
    ENDLOOP.

    "THKR_DUE_DATE"
* FI_PSO_WHOLE_ORDER_CHECK' führt bei Ratenstundung zu Fehler,
* nicht alle Belege zur AO einfließen. Fall ist eigentlich nicht vorgesehen.
* Prüfungen werden zuvor schon in Klasse /THKR/CL_PSM_AO_APPL gemacht, daher kan die Prüfung entfallen.
    IF i_due_date_deferral IS INITIAL.
*-----Pruefungen auf der Gesamttabelle der Belege:
      l_okcode = char_voll.
      CALL FUNCTION 'FI_PSO_WHOLE_ORDER_CHECK'
        EXPORTING
          i_okcode        = l_okcode
          i_psotyp        = t_bbkpf-psoty
          i_who_activ     = l_who_activ
        TABLES
          i_t_pso         = l_t_pso
          i_t_fipso_accit = l_t_item
          i_t_fipso_bsec  = l_t_pssec
          u_t_pso_mass    = t_pso50.
    ENDIF.


*----check if documents are consistent for BGAs
    CALL FUNCTION 'FMBGA_PSO_CHECK'
      TABLES
        t_pso_head = l_t_pso
        t_pso_item = l_t_item.

*-----Wenn Einnahmeart verwendet wird, muessen in den zusaetzlichen
*-----Sachkontenzeilen die HHSt gleich sein:
    CALL FUNCTION 'FI_PSO_ITEMS_AND_EART_CHECK'
      TABLES
        i_t_pso        = l_t_pso
        i_t_item       = l_t_item
        i_t_fipso_bsec = l_t_pssec.

* Bestimme die Art der Steuerfortschreibung anhand des Bukreises:
    CALL FUNCTION 'FI_PSO_TAX_MODE_DETERMINE'
      EXPORTING
        i_bukrs    = t_bbkpf-bukrs
      IMPORTING
        e_tax_mode = l_tax_mode.

* Hinweis 905576
    LOOP AT l_t_pso ASSIGNING  <fs_l_pso> .

      READ TABLE l_t_item WITH
            KEY itabkey = <fs_l_pso>-itabkey ASSIGNING <fs_l_item>.

      IF sy-subrc = 0.

        CALL FUNCTION 'FI_PSO_TAX_FIPOS_CHECK'
          EXPORTING
            i_f_pso   = <fs_l_pso>
            i_f_item  = <fs_l_item>
          IMPORTING
            e_psosf   = <fs_l_pso>-psosf
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.

    ENDLOOP.
* Hinweis 905576 Ende


*-----VB* Tabellen fuellen
    READ TABLE l_t_pso INDEX 1.
    READ TABLE l_t_pssec INDEX 1.

**********************************************************************
* THKR Zusatz für Nutzung des DI
    IF t_bbkpf IS NOT INITIAL AND t_bbkpf[ 1 ]-lotkz IS NOT INITIAL.
      " Damit ändern funktioniert, muss das PSO old gefüllt werden.
      l_f_pso_old = l_t_pso.
    ENDIF.

    IF i_mig_data IS NOT INITIAL.
      l_t_pso-resubmission = i_mig_data-resubmission.
      LOOP AT l_t_vbkpf ASSIGNING FIELD-SYMBOL(<fs_vbkpf>).
        <fs_vbkpf>-resubmission = i_mig_data-resubmission.
      ENDLOOP.
    ENDIF.

* bei Stundung muss der SD Beleg auch das Feld MANST und MANSP übernehmen, das geht im Std. nicht
    IF ( t_bbkpf-psoty EQ char_06 OR t_bbkpf-psoty EQ char_07 OR t_bbkpf-psoty EQ char_08 ).
      l_t_pso-manst = t_bbseg[ 1 ]-manst.
      l_t_pso-mansp = t_bbseg[ 1 ]-mansp.
      l_t_pso[ 1 ]-manst = t_bbseg[ 1 ]-manst.
      l_t_pso[ 1 ]-mansp = t_bbseg[ 1 ]-mansp.
    ENDIF.

**********************************************************************


    CALL FUNCTION 'FI_PSO_FI_TABLES_FILL'
      EXPORTING
        i_f_pso        = l_t_pso
        i_f_pso_old    = l_f_pso_old
        i_f_pssec      = l_t_pssec
        i_f_pssec_old  = l_f_ppsec_old
        i_xprfg        = i_xprfg
        i_tax_mode     = l_tax_mode
        i_direct_input = char_x
      TABLES
        u_t_item       = l_t_item
        u_t_item_old   = l_t_item_old
        c_t_vbkpf      = l_t_vbkpf
        c_t_vbkpf_old  = l_t_vbkpf_old
        c_t_vbseg      = l_t_vbseg
        c_t_vbseg_old  = l_t_vbseg_old
        c_t_vbsec      = l_t_vbsec
        c_t_vbsec_old  = l_t_vbsec_old
        c_t_vbset      = l_t_vbset
        c_t_vbset_old  = l_t_vbset_old
      EXCEPTIONS
        OTHERS         = 1.

    IF l_xpp IS INITIAL AND i_check IS INITIAL.
* Fuer Niederschlagung und Erlaß den Stornogrund PSOSG setzen,
* jedoch nur wenn gebucht wird.
      CALL FUNCTION 'FI_PSO_VBKPF_PSOSG_SET'
        EXPORTING
          i_psotyp  = t_bbkpf-psoty
        TABLES
          c_t_vbkpf = l_t_vbkpf.
    ENDIF.

* Tabelle auf AO-Format testen:
    CALL FUNCTION 'FI_PSO_CONVENTION_CHECK'
      EXPORTING
        i_psotyp = t_bbkpf-psoty
      TABLES
        t_vbseg  = l_t_vbseg.

* Pruefe Steuerdaten auf Korrektkeit:
    PERFORM check_tax_data TABLES     l_t_vbkpf
                                      l_t_vbseg
                                      l_t_vbset
                                      t_bbtax
                           USING      l_activity
                                      l_tax_mode
                           CHANGING   l_psosf
                                      l_subrc.

*   Fuelle Steuerzeilen:
    IF l_tax_mode EQ fmfi_con_mwst_sep.
      CALL FUNCTION 'FI_PSO_FIPOS_GET_FROM_FIPEX'
        EXPORTING
          i_fipex = l_psosf
        IMPORTING
          e_fipos = l_fipos.

      CALL FUNCTION 'FI_PP_TAX_LINE_GENERATE'
        EXPORTING
          i_fipos          = l_fipos
          i_non_deductible = char_space
        TABLES
          t_vbkpf_new      = l_t_vbkpf
          t_vbset_new      = l_t_vbset
          t_vbseg_new      = l_t_vbseg.

    ENDIF.

  ENDLOOP.

* ENDE: AUFBAU der TABELLEN

* Je nach Transaktion und Mode OKCODE belegen:
  IF l_xpp EQ char_x.
    l_okcode = char_voll.
    CLEAR l_flg_post.
    l_flg_save = char_x.
    IF NOT i_check IS INITIAL.
      CLEAR: l_flg_save.
    ENDIF.
  ELSE.
    l_okcode   = char_post.
    l_flg_post = char_x.
    IF NOT i_check IS INITIAL.
      CLEAR: l_flg_post.
    ENDIF.
  ENDIF.

* only check?
  IF NOT i_check IS INITIAL OR l_xpp EQ char_x.
    CALL FUNCTION 'FI_PSO_FI_TABLES_CHECK'
      EXPORTING
        i_psosu_pa    = l_psosum
        i_post        = l_flg_post
        i_who_activ   = l_who_activ
        i_itabkey     = l_f_pso-itabkey
        i_okcode      = l_okcode
      TABLES
        u_t_vbkpf_new = l_t_vbkpf
        u_t_vbkpf_old = l_t_vbkpf_old
        u_t_vbseg_new = l_t_vbseg
        u_t_vbseg_old = l_t_vbseg_old
        u_t_vbsec_new = l_t_vbsec
        u_t_vbsec_old = l_t_vbsec_old
        u_t_vbset_new = l_t_vbset
        u_t_vbset_old = l_t_vbset_old
      CHANGING
        c_subrc       = l_subrc
        c_check       = l_flg_check
        c_save        = l_flg_save.

    IF l_subrc NE 0.
      MESSAGE e607(fq).
    ENDIF.
  ENDIF.

* nach erfolgreichem Check Nummer ziehen:
  IF i_check IS INITIAL.

* THKR_DUE_DATE"
* wenn LOTKZ bekannt dann direkt übernehmen
    IF i_due_date_deferral IS INITIAL OR l_f_pso-lotkz IS INITIAL.
*   Lotkz belegen:
      PERFORM lotkz_determine USING    t_bbkpf
                                       l_f_pso
                                       i_intlot
                                       i_nrkrs_lot
                                       i_lotkz_alloc
                                       l_xpp
                                       i_inverse_posting
                                       i_no_check
                              CHANGING l_lotkz.
    ELSE.
      l_lotkz = l_f_pso-lotkz.
    ENDIF.

    l_f_pso-lotkz = l_lotkz.
    e_lotkz = l_lotkz.
    LOOP AT l_t_vbkpf.
      l_t_vbkpf-lotkz = l_lotkz.
      MODIFY l_t_vbkpf.
    ENDLOOP.
* Note 890629 + 968005
    IF i_no_fi_number IS INITIAL.
      IF NOT l_xpp EQ char_x.
*       FI-Belegnummer belegen:
        CALL FUNCTION 'FI_PP_NUMBER'
          TABLES
            t_vbkpf_new = l_t_vbkpf
            t_vbsec_new = l_t_vbsec
            t_vbseg_new = l_t_vbseg
            t_vbset_new = l_t_vbset
          EXCEPTIONS
            OTHERS      = 1.
        READ TABLE l_t_vbkpf INDEX 1.
        e_bukrs = l_t_vbkpf-bukrs.
        e_belnr = l_t_vbkpf-belnr.
        e_lotkz = l_t_vbkpf-lotkz.
        e_gjahr = l_t_vbkpf-gjahr.
      ENDIF.
    ENDIF.
  ELSE.
* set company code and year for export (if only check mode)
    READ TABLE l_t_vbkpf INDEX 1.
    e_bukrs = l_t_vbkpf-bukrs.
    e_gjahr = l_t_vbkpf-gjahr.
    CLEAR: e_lotkz.
    CLEAR: e_belnr.

  ENDIF.

  LOOP AT l_t_vbkpf WHERE tcode = 'F871' OR tcode = 'F881'.     "note1366159
    IF l_t_vbkpf-xblnr = '*' AND                                "note1366159
      ( l_t_vbkpf-belnr IS NOT INITIAL OR                       "note1366159
        e_belnr         IS NOT INITIAL ) .                      "note1366159
      l_t_vbkpf-xblnr = l_t_vbkpf-belnr.                        "note1366159
      MODIFY l_t_vbkpf.                                         "note1366159
    ENDIF.                                                      "note1366159
  ENDLOOP.                                                      "note1366159

* Nur Vorerfassen:
  IF l_xpp EQ char_x.

*   Workflow vorbereiten
    CALL FUNCTION 'FI_PSO_FMPSO_WF_MAIN'
      EXPORTING
        i_lotkz      = l_t_vbkpf-lotkz
        i_ausbk      = l_t_vbkpf-ausbk
        i_blart      = l_t_vbkpf-blart
        i_hwaer      = l_t_vbkpf-hwaer
        i_event      = 'CREATED'
        i_xprfg_new  = 'X'
        i_xprfg_old  = ' '
      IMPORTING
        e_psoxwf_new = l_psoxwf
      TABLES
        t_vbseg_new  = l_t_vbseg.

*   Kennzeichen setzen: Workflowrelevant
    IF NOT l_psoxwf IS INITIAL.
      LOOP AT l_t_vbkpf.
        l_t_vbkpf-psoxwf = l_psoxwf.
        MODIFY l_t_vbkpf.
      ENDLOOP.
    ENDIF.

*-----S P E I C H E R N (falls erwuenscht):

    IF i_check IS INITIAL.

* THKR_DUE_DATE"
* die Oldfelder dürfen nie gefüllt sein.
* Bei Ratenstundung mit mehreren Belegen wäre das aber der Fall
      IF i_due_date_deferral IS NOT INITIAL.
        CLEAR: l_t_vbkpf_old[], l_t_vbseg_old[], l_t_vbsec_old[], l_t_vbset_old[].
        REFRESH: l_t_vbkpf_old, l_t_vbseg_old, l_t_vbsec_old, l_t_vbset_old.
      ENDIF.

* begin of note1710829
      TRY.
          CALL FUNCTION 'FI_PSO_FI_TABLES_WRITE'
            EXPORTING
              i_itabkey     = l_t_pso-itabkey
              i_check       = 'X'  "Daten wurden geprueft
            TABLES
              u_t_vbkpf     = l_t_vbkpf
              u_t_vbkpf_old = l_t_vbkpf_old
              u_t_vbseg     = l_t_vbseg
              u_t_vbseg_old = l_t_vbseg_old
              u_t_vbsec     = l_t_vbsec
              u_t_vbsec_old = l_t_vbsec_old
              u_t_vbset     = l_t_vbset
              u_t_vbset_old = l_t_vbset_old
              u_t_tiban     = l_t_tiban
            CHANGING
              c_subrc       = l_subrc.

        CATCH cx_sy_dyn_call_param_not_found.

          IF l_t_tiban[] IS INITIAL.
* end of note1710829
            CALL FUNCTION 'FI_PSO_FI_TABLES_WRITE'
              EXPORTING
                i_itabkey     = l_t_pso-itabkey
                i_check       = 'X'  "Daten wurden geprueft
              TABLES
                u_t_vbkpf     = l_t_vbkpf
                u_t_vbkpf_old = l_t_vbkpf_old
                u_t_vbseg     = l_t_vbseg
                u_t_vbseg_old = l_t_vbseg_old
                u_t_vbsec     = l_t_vbsec
                u_t_vbsec_old = l_t_vbsec_old
                u_t_vbset     = l_t_vbset
                u_t_vbset_old = l_t_vbset_old
              CHANGING
                c_subrc       = l_subrc.
          ELSE.                                         "note1710829
            MESSAGE e246(fq) WITH TEXT-400.             "note1710829
          ENDIF.                                        "note1710829

      ENDTRY.                                         "note1710829
      IF l_subrc EQ 0.
*     Workflow-Event ausloesen:
        CALL FUNCTION 'FI_PSO_FMPSO_WF_EVENT_CREATE'
          EXPORTING
            i_lotkz   = l_t_vbkpf-lotkz
            i_ausbk   = l_t_vbkpf-ausbk
          EXCEPTIONS
            no_memory = 1
            OTHERS    = 2.

        READ TABLE l_t_vbkpf INDEX 1.
        e_bukrs = l_t_vbkpf-bukrs.
        e_belnr = l_t_vbkpf-belnr.
        e_lotkz = l_t_vbkpf-lotkz.
        e_gjahr = l_t_vbkpf-gjahr.

      ELSE.
*     Workflow-Event zuruecknehmen:
        CALL FUNCTION 'FI_PSO_FMPSO_WF_EVENT_REFRESH'.
        MESSAGE e607(fq).
      ENDIF.
    ENDIF.
  ELSE.

    IF i_check IS INITIAL.

*     Mittelreservierung muss wissen, dass sie aus Direct-Input auf-
*     gerufen wird:
      EXPORT flg_direct_input FROM l_flg_direct_input TO MEMORY ID
                         'SAPLF0KC'.

      CALL FUNCTION 'FI_PSO_DOC_DIRECT_POST'
        IMPORTING
          e_belnr = e_belnr
        TABLES
          t_vbkpf = l_t_vbkpf
          t_vbsec = l_t_vbsec
          t_vbseg = l_t_vbseg
          t_vbset = l_t_vbset
          t_bwith = t_bwith.

      FREE MEMORY ID 'SAPLF0KC'.

      READ TABLE l_t_vbkpf INDEX 1.
      e_bukrs = l_t_vbkpf-bukrs.
      e_gjahr = l_t_vbkpf-gjahr.

      l_tabkey(4)    = e_bukrs.
      l_tabkey+4(10) = e_belnr.
      l_tabkey+14(4) = e_gjahr.
      CALL FUNCTION 'TRANSFER_IBAN'
        EXPORTING
          i_tabname = 'BKPF'
          i_tabkey  = l_tabkey.

      CALL FUNCTION 'UPDATE_IBAN'
        EXPORTING
          execute_in_update_task = 'X'.

    ENDIF.
*end of note 1710829

    IF l_flg_inverse = 'X' AND l_t_pso-psoty <> 06. " Stundung wird au´ßerhalb erledigt
*-----post an inverse document to the reference document in case
*-----of deferral request

*-----Beim Buchen einer Stundung Usprungsbeleg stornieren
      LOOP AT l_t_vbkpf WHERE psoty EQ char_06.
*-----Fuer alle Stundungen: Ursprungsbeleg ermitteln und stornieren
        LOOP AT l_t_vbseg WHERE ausbk = l_t_vbkpf-ausbk
                          AND   belnr = l_t_vbkpf-belnr
                          AND   gjahr = l_t_vbkpf-gjahr
                          AND ( koart = con_konto_debitor OR
                                koart = con_konto_kreditor ).
          EXIT.
        ENDLOOP.

        IF sy-subrc = 0 AND l_t_vbseg-rebzg <> space.
*         Ermittle Ursprungsbeleg, falls vorhanden
          READ TABLE l_t_belnr WITH KEY belnr = l_t_vbseg-rebzg.
          IF sy-subrc NE 0.
            SELECT belnr INTO l_belnr FROM bsad
                                      WHERE belnr = l_t_vbseg-rebzg
                                        AND bukrs = l_t_vbseg-bukrs
                                        AND gjahr = l_t_vbseg-gjahr.
              EXIT.
            ENDSELECT.
            IF sy-subrc NE 0.
*             Beleg ist noch nicht ausgeglichen:
              CLEAR l_t_pso.
              REFRESH l_t_pso.
              MOVE-CORRESPONDING l_t_vbkpf TO l_t_pso.
              MOVE-CORRESPONDING l_t_vbseg TO l_t_pso.
              APPEND l_t_pso.
**         Der Ursprungsbeleg muss beim Buchen storniert werden:
*              CALL FUNCTION 'FI_PSO_DOCUMENT_REVERSAL_COMP'
*                   EXPORTING
*                        I_T_PSO          = L_F_PSO
*                   CHANGING
*                        C_SUBRC_REVERSAL = L_SUBRC.

*             Umkehrbuchung zum urspruenglichen Beleg

*             are there any data from outside for the invers posting?
              IF t_pso50 IS INITIAL.
*             1. Daten fuer Umkehrbuchung mitgeben:
                l_t_pso50-bukrs = l_t_pso-bukrs.
                l_t_pso50-psoty = l_t_pso-psoty.
                l_t_pso50-belnr = l_t_pso-rebzg.
                l_t_pso50-gjahr = l_t_pso-rebzj.
                l_t_pso50-psosum = l_t_pso-dmbtr.
                l_t_pso50-hwaer = l_t_pso-hwaer.
                l_t_pso50-lotkz = l_t_pso-lotkz.
                APPEND l_t_pso50.
              ELSE.
                l_t_pso50 = t_pso50.
                l_t_pso50[] = t_pso50[].
                LOOP AT l_t_pso50.
                  l_t_pso50-lotkz = l_t_pso-lotkz.
                  MODIFY l_t_pso50.
                ENDLOOP.
              ENDIF.


*** THKR **********************************************************************
* for clearing
              CONSTANTS con_partner_line LIKE pso02-buzei VALUE '001'.

              TYPES: BEGIN OF in_po_re_ty,

                       bukrs TYPE bukrs,
                       belnr TYPE belnr_d,
                       gjahr TYPE gjahr,
                       buzei TYPE buzei,
                       rebzg TYPE rebzg,
                     END OF in_po_re_ty.

              DATA:
                l_t_pso4clear              TYPE TABLE OF  pso02         WITH HEADER LINE,
                l_t_docs4clear             TYPE TABLE OF  ifmdocs4clear WITH HEADER LINE,
                l_t_inverse_postings_rebzg TYPE STANDARD TABLE OF in_po_re_ty WITH HEADER LINE,
                l_t_inverse_postings       TYPE       STANDARD TABLE OF bseg_key WITH HEADER LINE,
                l_t_pso_invers             TYPE TABLE OF  pso02         WITH HEADER LINE,
                l_t_pso504clear            TYPE TABLE OF  pso50         WITH HEADER LINE.
*** / THKR

*             2. Umkehrbuchung:
              CALL FUNCTION 'FI_PSO_INVERS_POSTING'
                EXPORTING
                  i_budat              = l_t_pso-budat
                  i_check              = i_check
                  i_okcode             = 'POST'
                  i_direct_input       = 'X'
                  i_psosg              = l_t_pso-psosg
                TABLES
                  t_pso50              = l_t_pso50
                  t_pso                = l_t_pso
*** THKR **********************************************************************
                  e_t_pso4clear        = l_t_pso_invers
                  e_t_pso504clear      = l_t_pso504clear
                  e_t_inverse_postings = l_t_inverse_postings.
*** / THKR

*             Der Stornogrund muss im Ursprungsbeleg gesetzt werden:
              IF    l_subrc EQ 0 AND i_check IS INITIAL.
*               Stornogrund im Bezugsbeleg setzen:
                IF con_an_backpsotyp CS l_t_pso-psoty AND
                   l_t_pso-psoty NE space.
                  IF l_t_pso-psosg EQ con_stundung_storno_new.
                    LOOP AT l_t_pso50.
                      CALL FUNCTION 'FI_PSO_UPDATE_BKPF_PSOSG'
                        EXPORTING
                          i_belnr = l_t_pso50-belnr
                          i_bukrs = l_t_pso50-bukrs
                          i_gjahr = l_t_pso50-gjahr
                          i_psosg = con_stundung_storno
                          i_msgty = char_i
                        CHANGING
                          c_subrc = l_subrc.
                    ENDLOOP.
                  ELSE.
                    CALL FUNCTION 'FI_PSO_PSOSG_SET'
                      EXPORTING
                        i_psoty = l_t_pso-psoty
                        i_rebzg = l_t_pso-rebzg
                        i_bukrs = l_t_pso-bukrs
                        i_rebzj = l_t_pso-rebzj
                        i_msgty = char_i
                      CHANGING
                        c_subr  = l_subrc.
                  ENDIF.
                ENDIF.
                IF l_subrc NE 0.
*                 Abbruch-Message, damit ROLLBACK durchgefuehrt wird:
                  MESSAGE a897(fq)  WITH l_t_pso-lotkz
                                         l_t_pso-bukrs.
                ENDIF.
              ELSEIF l_subrc NE 0.
*               Abbruch-Message, damit ROLLBACK durchgefuehrt wird:
                MESSAGE a890(fq) WITH  l_t_pso-rebzg
                                       l_t_pso-bukrs
                                       l_t_pso-rebzj.
              ENDIF.

**** THKR **********************************************************************
**** Ausgleichsbelege Ausgelagert in PSM APPL Klasse ans Ende der Buchung
**** da für Ratenstundung das nur einmalig über den Gesamtbetrag/Ursprungsbeleg+Invers gemacht werden muss.
*      COMMIT WORK AND WAIT.
*      SET PARAMETER ID 'LOT' FIELD l_t_pso-lotkz.
*      SET PARAMETER ID 'PSOTY' FIELD l_t_pso-lotkz.
**      MESSAGE s850(fq) WITH u_t_pso-lotkz u_t_pso-bukrs.
*
**     clearing the open items:
**     Deferral Request, Orig. Doc.
**     and any Partial Payment or old Deferral Requests
**     may exists already
*
**     Rechnungsbezüge nachlesen.
*              LOOP AT l_t_inverse_postings.
*                MOVE-CORRESPONDING l_t_inverse_postings TO l_t_inverse_postings_rebzg.
*                SELECT SINGLE rebzg
*                FROM bseg
*                INTO
*                l_t_inverse_postings_rebzg-rebzg
*                WHERE
*                    bukrs = l_t_inverse_postings_rebzg-bukrs AND
*                    belnr = l_t_inverse_postings_rebzg-belnr AND
*                    gjahr = l_t_inverse_postings_rebzg-gjahr AND
*                    buzei = 1.
*                IF sy-subrc = 0.
*                  APPEND l_t_inverse_postings_rebzg.
*                ELSE.
*                  MESSAGE i246(fq) WITH 'Datenbank Problem '
*                                        'Include LF0KAF10 '
*                                        'Line 1327 '.
*                ENDIF.
*              ENDLOOP.
*
*
**     Hinweis 1044289
*              SORT l_t_pso504clear.
*              DELETE ADJACENT DUPLICATES FROM l_t_pso504clear COMPARING mandt bukrs psoty belnr gjahr.
**     Doppelte Einträge löschen, Nur verschiedene Belege nicht
**     verschiedene Sackkontenzeilen interessieren.
*
*              SORT l_t_pso_invers BY belnr gjahr.
*              LOOP AT l_t_pso504clear ASSIGNING FIELD-SYMBOL(<pso50>).
*                CLEAR l_t_docs4clear.
*                REFRESH l_t_docs4clear.
*
**       read the line which refers to the original document
*                READ TABLE l_t_pso_invers WITH KEY belnr = <pso50>-belnr
*                                                   gjahr = <pso50>-gjahr
*                                          BINARY SEARCH.
*                IF sy-subrc EQ 0.
*
*
** Begin of NOTE 993376 PI 03.11.2006  Part 3/3
*
*                  IF l_t_pso-psoty = 06.
*                    READ TABLE l_t_pso WITH KEY rebzg = l_t_pso_invers-belnr
*                                                rebzj = l_t_pso_invers-gjahr
*                                                rebzz = l_t_pso_invers-buzei.
*                    l_belnr = l_t_pso-belnr.
*                  ELSE.
*                    CLEAR l_belnr.
*                  ENDIF.
**         get all related documents
*                  CALL FUNCTION 'FI_PSO_AMOUNT_FOLLOWING_ORDER'
*                    EXPORTING
*                      i_bukrs   = l_t_pso_invers-bukrs
*                      i_lifnr   = l_t_pso_invers-lifnr
*                      i_kunnr   = l_t_pso_invers-kunnr
*                      i_rebzg   = l_t_pso_invers-belnr
*                      i_rebzj   = l_t_pso_invers-gjahr
*                      i_rebzz   = l_t_pso_invers-buzei
*                      i_shkzg   = l_t_pso_invers-shkzg
*                      i_belnr   = l_belnr
*                      i_psoty   = l_t_pso-psoty
*                    TABLES
*                      e_t_pso02 = l_t_pso4clear.
*
** End of NOTE 993376 PI 03.11.2006  Part 3/3
*
**         transfer related documents to clearing interface
*                  LOOP AT l_t_pso4clear.
*                    READ TABLE l_t_pso504clear WITH KEY belnr = l_t_pso4clear-belnr
*                                    bukrs = l_t_pso4clear-bukrs
*                                    gjahr = l_t_pso4clear-gjahr.
*                    IF sy-subrc NE 0.
*                      MOVE-CORRESPONDING l_t_pso4clear TO l_t_docs4clear.
*                      l_t_docs4clear-kunnr = l_t_pso_invers-kunnr.         "note1346821
*                      l_t_docs4clear-lifnr = l_t_pso_invers-lifnr.         "note1346821
*                      APPEND l_t_docs4clear.
*                    ENDIF.
*                  ENDLOOP.
*
**         add the original document, too
*                  CLEAR l_t_docs4clear.
*                  l_t_docs4clear-bukrs = l_t_pso_invers-bukrs.
*                  l_t_docs4clear-belnr = l_t_pso_invers-belnr.
*                  l_t_docs4clear-gjahr = l_t_pso_invers-gjahr.
*                  l_t_docs4clear-buzei = con_partner_line.
*                  l_t_docs4clear-kunnr = l_t_pso_invers-kunnr.
*                  l_t_docs4clear-lifnr = l_t_pso_invers-lifnr.
*                  l_t_docs4clear-umskz = l_t_pso_invers-umskz.             "note1346821
*                  APPEND l_t_docs4clear.
*
**         no balance check required for defferal requests
*
** Hinweis 1082332
** Dokumente aus der Gegenbuchung zum Ausgleich hinzufügen.
*
*                  LOOP AT l_t_inverse_postings_rebzg WHERE  rebzg = <pso50>-belnr.
*                    CLEAR l_t_docs4clear.
*                    MOVE-CORRESPONDING  l_t_inverse_postings_rebzg TO l_t_docs4clear.
*                    APPEND l_t_docs4clear.
*                  ENDLOOP.
*
**         clear documents
*                  CALL FUNCTION 'FM_DOCUMENT_CLEAR'
*                    EXPORTING
*                      u_bukrs        = l_t_pso_invers-bukrs
*                      u_budat        = l_t_pso_invers-budat
*                      u_bldat        = l_t_pso_invers-bldat
*                      u_koart        = l_t_pso_invers-koart
*                      u_waers        = l_t_pso_invers-waers
*                    TABLES
*                      u_t_docs4clear = l_t_docs4clear
*                    EXCEPTIONS
*                      error_message  = 1.
*
*                  IF sy-subrc = 1.
** save the raised message
*                    MESSAGE ID sy-msgid  TYPE sy-msgty NUMBER sy-msgno
*                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
**                    l_c_msgid = sy-msgid.
**                    l_c_msgno = sy-msgno.
**                    l_c_msgv1 = sy-msgv1.
**                    l_c_msgv2 = sy-msgv2.
**                    l_c_msgv3 = sy-msgv3.
**                    l_c_msgv4 = sy-msgv4.
*** display error in clearing process; the same in the loop only one time
**                    IF l_c_msgid NE l_c2_msgid AND
**                       l_c_msgno NE l_c2_msgno.
**                      MESSAGE i276(fq) WITH u_t_pso-rebzg
**                                            u_t_pso-lotkz
**                                            l_c_msgid
**                                            l_c_msgno.
*** display reason why clearing was not possible
**                      MESSAGE ID l_c_msgid TYPE 'I' NUMBER l_c_msgno
**                      WITH l_c_msgv1 l_c_msgv2 l_c_msgv3 l_c_msgv4.
*** remember the last message
**                      l_c2_msgid = l_c_msgid.
**                      l_c2_msgno = l_c_msgno.
**                    ENDIF.
*                  ELSE.
*** no clearing errors
**                    MESSAGE s850(fq) WITH u_t_pso-lotkz
**                                          u_t_pso-bukrs.
*
*                  ENDIF.
*                ENDIF.
*              ENDLOOP.
*
**** / THKR
            ENDIF.
            APPEND l_t_vbseg-rebzg TO l_t_belnr.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDIF.                               " End of L_XPP NE CHAR_X.


ENDFUNCTION.
