class /THKR/CL_MIG_PSM_AO_APPL definition
  public
  inheriting from /THKR/CL_PSM_AO_APPL
  final
  create public .

public section.

  methods CONSTRUCTOR .
  class-methods MIG_GET_INSTANCE
    returning
      value(R_INSTANCE) type ref to /THKR/CL_MIG_PSM_AO_APPL .
  methods CREATE_PSM_AO_BELEG1
    importing
      !I_DTO_PSM_AO_BEL_CREATE type /THKR/S_DTO_MIG_AO_BEL_CREATE
      !I_MIG_OBJ type /THKR/MIG_OBJ_AO optional
      !I_FM_DOCUMENT_CLEAR type FLAG optional
    exporting
      !E_PSM_AO_DOCUMENT_NUMBER type /THKR/S_PSM_AO_DOCUMENT_NUMBER
      !E_ERROR_CLEAR type FLAG
    raising
      /THKR/CX_PSM_INT_FI .

  methods CREATE_DUE_DATE_DEFERRAL
    redefinition .
  methods CREATE_PSM_AO_VERRECHNUNG
    redefinition .
protected section.

  data MT_FM_T_BBKPF type FM_T_BBKPF .
  data MT_FM_T_BBSEG type FM_T_BBSEG .

  methods AMOUNT_CHECK_COMPLETE_OR_CHECK
    importing
      !I_BSEG type FM_T_BBSEG
    raising
      /THKR/CX_PSM_INT_FI .
  methods FI_PSO_INVERS_POSTING
    importing
      !I_DTO_PSM_AO_BEL_CREATE type /THKR/S_DTO_PSM_AO_BEL_CREATE
    raising
      /THKR/CX_PSM_INT_FI .
  methods FM_DOCUMENT_CLEAR
    importing
      !I_DTO_PSM_AO_BEL_CREATE type /THKR/S_DTO_PSM_AO_BEL_CREATE
    raising
      /THKR/CX_PSM_INT_FI .
  methods CLEAR_DATA .

  methods CHANGE_PSO_DUE_DATES_DATA
    redefinition .
  methods CHECK_FIPEX
    redefinition .
  methods MAP_DTO_BELEG_TO_BSEG
    redefinition .
  methods PSO_DOCUMENT_CHECK
    redefinition .
  methods PSO_DOCUMENT_POST
    redefinition .
private section.

  class-data INSTANCE type ref to /THKR/CL_MIG_PSM_AO_APPL .
  data MIG_AO_BELEG type /THKR/S_DTO_MIG_AO_BELEG .
  data MIG_OBJ type /THKR/MIG_OBJ_AO .
ENDCLASS.



CLASS /THKR/CL_MIG_PSM_AO_APPL IMPLEMENTATION.


  METHOD amount_check_complete_or_check.
* wenn die AO nur einen FI-Beleg enthaelt und dieser Beleg den
* Betrag Null hat, kann man die AO nicht vollstaendig setzen
* Wenn die Anordnung insgesamt die Summe Null hat darf nicht gespeichert werden.
* enthalten im FI_PSO_WHOLE_ORDER_PRE_CHECK der im DI nicht aufgerufen wird
* FI_PSO_AMOUNT_NULL_CHECK
* im Dialog in * AMOUNT_CHECK_COMPLETE_OR_CHECK  SAPLF0KA    LF0KAF15
* Es gibt damit 4 verschiedene Meldungen im Std. es wurde sich für die hier entschieden:

    DATA:
          lt_return TYPE bapiret2_t.


    DATA(lv_betrag) = CONV wrbtr( REDUCE #( INIT x TYPE wrbtr FOR wa IN i_bseg NEXT x += wa-wrbtr ) ).
    IF lv_betrag = 0.
      IF ms_ao_param-psoxb EQ abap_true.
          " andere Meldung bei IOS/VSA von Kasse gewünscht
        CASE mig_obj.
          WHEN 'IOS'.
            MESSAGE ID '/THKR/MIG' TYPE 'E' NUMBER '038' INTO DATA(lv_msg).
          WHEN 'VSA'.
            MESSAGE ID '/THKR/MIG' TYPE 'E' NUMBER '039' INTO lv_msg.
          WHEN OTHERS.
            "SAP STd. Fehlermeldung
          MESSAGE ID 'FQ' TYPE 'E' NUMBER '777' INTO lv_msg.
        ENDCASE.
      ELSE.
        MESSAGE ID 'FQ' TYPE 'E' NUMBER '730' INTO lv_msg.
      ENDIF.
      APPEND VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                      message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ) TO lt_return.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        EXPORTING bapiret2_tab = lt_return.
    ENDIF.

  ENDMETHOD.


  method CHANGE_PSO_DUE_DATES_DATA.
* Überschrieben, da die mig_ao_beleg-t_kont Tabelle geändert werden muss

    IF i_due_dates IS INITIAL.
* Dann keine Änderng notwendig
      RETURN.
    ENDIF.

* Fälligkeitsdatum setzen
    ms_ao_beleg-zfbdt = i_due_dates-dzfbdt.

* Betrag auf Kontierung anpassen unter Beachtung Mehrfachkontierung
    DATA(lv_wrbtr) = round( val = i_due_dates-wrbtr / lines( mig_ao_beleg-t_kont ) dec = 2 ).
    LOOP AT mig_ao_beleg-t_kont ASSIGNING FIELD-SYMBOL(<fs_kont>).
      <fs_kont>-wrbtr = lv_wrbtr.
    ENDLOOP.

* Wenn zu einem Beleg schon eine AO angelegt wurden, alle weiteren Belege zu dieser AO hinzufügen
    IF ms_psm_ao_document_number IS NOT INITIAL.
      ms_ao_header-lotkz = ms_psm_ao_document_number-lotkz.
      ms_ao_header-gjahr = ms_psm_ao_document_number-gjahr.
      ms_ao_header-bukrs = ms_psm_ao_document_number-bukrs.
    ENDIF.
  endmethod.


  METHOD check_fipex.

*Call Super
    CALL METHOD super->check_fipex
      EXPORTING
        i_bseg = i_bseg.

** Migration eigene Prüfungen


  ENDMETHOD.


  METHOD clear_data.

    CLEAR:
    mv_due_date_deferral,
    mt_pso50,
    mt_due_dates,
    ms_psm_ao_document_number,
    mv_koart,
    mv_koart_tbnam,
    mv_shkzg,
    mv_blart,
    mv_bltyp,
    ms_ao_header,
    ms_ao_beleg,
    ms_ao_param,
    mv_belnr_in,
    ms_ao_settings,
    ms_ao_beleg_kont,
    mt_ao_beleg,
    mig_ao_beleg,
    mig_obj,
    mt_fm_t_bbkpf,
    mt_fm_t_bbseg.

  ENDMETHOD.


  METHOD constructor.
    super->constructor( ).

  ENDMETHOD.


  METHOD create_due_date_deferral.


    MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO mig_ao_beleg EXPANDING NESTED TABLES.

    CALL METHOD super->create_due_date_deferral
      EXPORTING
        i_dto_psm_ao_bel_create  = i_dto_psm_ao_bel_create
      IMPORTING
        e_psm_ao_document_number = e_psm_ao_document_number.

* Wenn Stundung erfolgreich war, dann Original Beleg und Gegenbuchung erzeugen und ausgleichen
    IF e_psm_ao_document_number-belnr IS NOT INITIAL AND i_dto_psm_ao_bel_create-test_run IS INITIAL.

      " Umkehrbuchung
      fi_pso_invers_posting( i_dto_psm_ao_bel_create ).

      " Commit notwendig damit Belege vorhanden sind (analog dialog FORM pso_post(LF0KAF10))
      " Coding für Ausgleichsbuchung ist in FI_PSO_DOC_DIRECT_INPUT nicht enthalten
      COMMIT WORK AND WAIT.

      " Ausbuchung
      fm_document_clear( i_dto_psm_ao_bel_create ).
    ENDIF.

  ENDMETHOD.


  METHOD create_psm_ao_beleg1.

    DATA: l_dto_psm_ao_bel_create TYPE /thkr/s_dto_psm_ao_bel_create.

    MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO mig_ao_beleg EXPANDING NESTED TABLES.
    MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO l_dto_psm_ao_bel_create EXPANDING NESTED TABLES.
    mig_obj = i_mig_obj.

*DF 1895
* Migrierte Anordnungen, die über den aktiven Zahlungsverkehr abgewickelt werden, müssen in der Folgeverarbeitung den Belegpositionstext ausbringen.
* Dies wird durch einen * vor dem Belegpositionstext je Beleg erreicht. Diese Funktionalität ist bei allen Anordnungen umzusetzen,
* die eine Zahlart/SAP Zahlweg M, D, C haben

    IF mig_ao_beleg-zlsch CA 'MDC'.
      LOOP AT mig_ao_beleg-t_kont ASSIGNING FIELD-SYMBOL(<fs_kont>).
        <fs_kont>-sgtxt = '*' && <fs_kont>-sgtxt.
      ENDLOOP.
      LOOP AT l_dto_psm_ao_bel_create-t_kont ASSIGNING FIELD-SYMBOL(<fs_kont2>).
        <fs_kont2>-sgtxt = '*' && <fs_kont2>-sgtxt.
      ENDLOOP.
    ENDIF.

    IF i_fm_document_clear IS INITIAL.

* Bei Migration immer diretk buchen
      l_dto_psm_ao_bel_create-psoxb = abap_true.

      create_psm_ao_beleg(
        EXPORTING
          i_dto_psm_ao_bel_create  = l_dto_psm_ao_bel_create
        IMPORTING
          e_psm_ao_document_number = e_psm_ao_document_number ).

    ENDIF.

* Wenn Stundung erfolgreich war, dann Original Beleg und Gegenbuchung erzeugen und ausgleichen
    IF ms_ao_header-psoty = c_psoty_stundung_06 AND e_psm_ao_document_number-belnr IS NOT INITIAL AND i_dto_psm_ao_bel_create-test_run IS INITIAL
      OR i_fm_document_clear = abap_true.

      " Umkehrbuchung
      fi_pso_invers_posting( l_dto_psm_ao_bel_create ).

      " Commit notwendig damit Belege vorhanden sind (analog dialog FORM pso_post(LF0KAF10))
      " Coding für Ausgleichsbuchung ist in FI_PSO_DOC_DIRECT_INPUT nicht enthalten
      COMMIT WORK AND WAIT.
      TRY.
          fm_document_clear( l_dto_psm_ao_bel_create ).

        CATCH /thkr/cx_psm_int_fi.
          e_error_clear = abap_true.
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD create_psm_ao_verrechnung.


    MOVE-CORRESPONDING i_psm_ao_verrechnung TO mig_ao_beleg EXPANDING NESTED TABLES.
    MOVE-CORRESPONDING i_psm_ao_verrechnung-t_sender_kont TO  mig_ao_beleg-t_kont EXPANDING NESTED TABLES.

    CALL METHOD super->create_psm_ao_verrechnung
      EXPORTING
        i_psm_ao_verrechnung     = i_psm_ao_verrechnung
      IMPORTING
        e_psm_ao_document_number = e_psm_ao_document_number.

  ENDMETHOD.


  METHOD fi_pso_invers_posting.

    DATA:
      lt_return TYPE bapiret2_t,
      l_subrc   LIKE sy-subrc,
      lt_pso    TYPE TABLE OF pso02,
      ls_pso    TYPE pso02,
      ls_pso50  TYPE pso50,
      lt_pso50  TYPE TABLE OF  pso50.


    IF mt_fm_t_bbkpf IS INITIAL.
      DATA:
        lt_bkpf	TYPE fm_t_bbkpf,
        lt_bseg	TYPE fm_t_bbseg,
        lt_btax	TYPE fm_t_bbtax.

      MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ms_ao_header.
      MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ms_ao_beleg.
      MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ms_ao_param.
      MOVE-CORRESPONDING i_dto_psm_ao_bel_create TO ms_ao_settings.
      mv_belnr_in = i_dto_psm_ao_bel_create-belnr.

      " Mapping Daten abhängig vom PSOTYP
      map_psoty_data( ).

      "Aufbau FI Kopfdaten
      map_dto_hdr_to_bkpf(
        CHANGING
          c_bkpf = lt_bkpf
          c_bseg = lt_bseg
          c_btax = lt_btax
      ).

      " Aufbau FI Belegzeilen
      map_dto_beleg_to_bseg(
        CHANGING
          c_bkpf = lt_bkpf
          c_bseg = lt_bseg
          c_btax = lt_btax
      ).

      mt_fm_t_bbkpf = lt_bkpf.
      mt_fm_t_bbseg = lt_bseg.
    ENDIF.

    READ TABLE mt_fm_t_bbkpf INTO DATA(ls_bkpf) INDEX 1.
    READ TABLE mt_fm_t_bbseg INTO DATA(ls_bseg) INDEX 1. " Debitor oder Kreditor Zeile, steht immer an 1


    MOVE-CORRESPONDING ls_bkpf TO ls_pso.
    MOVE-CORRESPONDING ls_bseg TO ls_pso.

    IF ls_pso-rebzg IS INITIAL.
      ls_pso-rebzg = i_dto_psm_ao_bel_create-belnr.
      ls_pso-rebzj = i_dto_psm_ao_bel_create-gjahr.
    ENDIF.

    " neue Stundungsbelegnummer
    ls_pso-belnr = ms_psm_ao_document_number-belnr.
    APPEND ls_pso TO lt_pso.


    ls_pso50-bukrs = ls_pso-bukrs.
    ls_pso50-psoty = ls_pso-psoty.
    ls_pso50-belnr = ls_pso-rebzg.
    ls_pso50-gjahr = ls_pso-rebzj.
    " gesamtbetrag übergaben und nicht die einzelne Rate
    ls_pso50-psosum = CONV wrbtr( REDUCE #( INIT x TYPE wrbtr FOR wa IN i_dto_psm_ao_bel_create-t_kont NEXT x += wa-wrbtr ) + i_dto_psm_ao_bel_create-wmwst ).  "ls_pso-dmbtr.
    ls_pso50-hwaer = ls_pso-hwaer.
    " Stundungs AO
    ls_pso50-lotkz = ms_psm_ao_document_number-lotkz.
    APPEND ls_pso50 TO lt_pso50.

    "lt_pso wird in FI_PSO_INVERS_POSTING nur für Fehlerausgabe genutzt, daher reicht dort eine Zeile

* Umkehrbuchung
    CALL FUNCTION 'FI_PSO_INVERS_POSTING'
      EXPORTING
        i_budat        = ls_pso-budat
        i_check        = i_dto_psm_ao_bel_create-test_run
        i_okcode       = 'POST'
        i_direct_input = abap_true
        i_psosg        = ''
      TABLES
        t_pso50        = lt_pso50
        t_pso          = lt_pso
      EXCEPTIONS
        error_message  = 1.

*             Der Stornogrund muss im Ursprungsbeleg gesetzt werden:
    IF sy-subrc EQ 0 AND i_dto_psm_ao_bel_create-test_run IS INITIAL.
*               Stornogrund im Bezugsbeleg setzen:
      CALL FUNCTION 'FI_PSO_PSOSG_SET'
        EXPORTING
          i_psoty = ls_pso-psoty
          i_rebzg = ls_pso-rebzg
          i_bukrs = ls_pso-bukrs
          i_rebzj = ls_pso-rebzj
          i_msgty = 'I'
        CHANGING
          c_subr  = l_subrc.
      IF l_subrc NE 0.
*                 Abbruch-Message, damit ROLLBACK durchgefuehrt wird:
        MESSAGE a897(fq)  WITH ls_pso-lotkz ls_pso-bukrs INTO DATA(lv_msg).
        APPEND VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                        message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ) TO lt_return.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          EXPORTING bapiret2_tab = lt_return.
      ENDIF.
    ELSE.
*               Abbruch-Message, damit ROLLBACK durchgefuehrt wird:
      MESSAGE a890(fq) WITH  ls_pso-rebzg ls_pso-bukrs  ls_pso-rebzj INTO lv_msg.

      APPEND VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                      message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ) TO lt_return.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        EXPORTING bapiret2_tab = lt_return.
    ENDIF.


  ENDMETHOD.


  METHOD fm_document_clear.
    DATA:
      lt_return     TYPE bapiret2_t,
      lt_docs4clear TYPE TABLE OF ifmdocs4clear.

    " Bei Tests gab es hier Probleme mit dem Lesen der Belege nach dem vorherigen Buchen
    WAIT UP TO 1 SECONDS.

* Ausgeglichen werden muss der Ursprungsbeleg + Gegenbuchungen, also alle DR elege
    SELECT * FROM bseg INTO @DATA(ls_bseg) WHERE ( rebzg = @i_dto_psm_ao_bel_create-belnr OR belnr = @i_dto_psm_ao_bel_create-belnr ) AND bukrs = @i_dto_psm_ao_bel_create-bukrs
                                         AND gjahr = @i_dto_psm_ao_bel_create-gjahr AND h_blart = 'DR' AND ( koart = 'D' OR koart = 'K' ).
      APPEND VALUE #(
                      bukrs = ls_bseg-bukrs
                      belnr = ls_bseg-belnr
                      gjahr = ls_bseg-gjahr
                      buzei = ls_bseg-buzei
                      kunnr = ls_bseg-kunnr
                      lifnr = ls_bseg-lifnr
                    ) TO lt_docs4clear.
    ENDSELECT.


    CALL FUNCTION 'FM_DOCUMENT_CLEAR'
      EXPORTING
        u_bukrs        = i_dto_psm_ao_bel_create-bukrs
        u_budat        = i_dto_psm_ao_bel_create-budat
        u_bldat        = i_dto_psm_ao_bel_create-bldat
        u_koart        = COND #( WHEN ls_bseg-kunnr IS NOT INITIAL THEN 'D' ELSE 'K' )
        u_waers        = i_dto_psm_ao_bel_create-waers
      TABLES
        u_t_docs4clear = lt_docs4clear
      EXCEPTIONS
        error_message  = 1.
    IF sy-subrc <> 0.
      APPEND VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                      message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ) TO lt_return.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        EXPORTING bapiret2_tab = lt_return.
    ENDIF.


  ENDMETHOD.


  METHOD map_dto_beleg_to_bseg.



    DATA:
      ls_xsako TYPE xsako,
      ls_bseg  TYPE bbseg_fm.

* Prüfen ob Steuerkennzeichen bekannt, wenn Steuerbetrag vorhanden
    IF ms_ao_beleg-wmwst IS NOT INITIAL AND ms_ao_beleg-mwskz IS INITIAL.
      " Wenn Steuer vorhanden aber kein Steuerkennzeichen, dieses aus Sachkonto ableiten
      CALL FUNCTION 'FI_GL_ACCOUNT_DATA'
        EXPORTING
          i_bukrs = ms_ao_header-bukrs
          i_saknr = ms_ao_beleg-t_kont[ 1 ]-hkont
        IMPORTING
          e_sako  = ls_xsako
        EXCEPTIONS                                             "1596752
          OTHERS  = 4.
      IF sy-subrc = 0  AND NOT ls_xsako-mwskz IS INITIAL AND ls_xsako-xmwno IS INITIAL. "Kennzeichen: Steuerkennzeichen kein Mussfeld.
        IF ls_xsako-mwskz CA '><+*-.'.
          ms_ao_beleg-mwskz = 'V1'."Default da nicht eindeutig
        ELSE.
          ms_ao_beleg-mwskz = ls_xsako-mwskz .
        ENDIF.
      ELSE.
        ms_ao_beleg-mwskz = 'V1'. "Default
      ENDIF.

    ENDIF.



* Debitor/Kreditor Datenzeile muss immer Zeile 1 sein
* Bei Verrechnungsanordnung ist die 1. Zeile der Empfänger

    ls_bseg-tbnam = mv_koart_tbnam.

* Buchungsschlüssel
    CALL FUNCTION 'FI_PSO_POSTING_KEY_DETERMINE'
      EXPORTING
        i_koart = mv_koart
        i_umskz = ''
        i_shkzg = mv_shkzg
      CHANGING
        c_bschl = ls_bseg-newbs.

    ls_bseg-newbk = ms_ao_header-bukrs.
    ls_bseg-newko = ms_ao_beleg-partner.
    ls_bseg-bvtyp = ms_ao_beleg-bvtyp.

    " Summe der Beträge aller Zeilen bilden
    ls_bseg-wrbtr =  CONV wrbtr( REDUCE #( INIT x TYPE wrbtr FOR wa IN mig_ao_beleg-t_kont NEXT x += wa-wrbtr ) + ms_ao_beleg-wmwst ).
    ls_bseg-wmwst = ms_ao_beleg-wmwst.
    ls_bseg-mwskz = ms_ao_beleg-mwskz.
    ls_bseg-sgtxt = ms_ao_beleg-t_kont[ 1 ]-sgtxt. "Positionszeilentext soll laut Kasse in allen Zeilen identisch sein
    ls_bseg-mansp = ms_ao_beleg-mansp.
    ls_bseg-maber = ms_ao_beleg-maber.
    ls_bseg-mschl = mig_ao_beleg-mschl.  "**MIG**
    ls_bseg-manst = mig_ao_beleg-manst.  "**MIG**
    ls_bseg-zuonr	= mig_ao_beleg-zuonr."**MIG**

    IF ms_ao_beleg-madat = 0.
      CLEAR ms_ao_beleg-madat.
    ELSE.
      ls_bseg-madat = ms_ao_beleg-madat.
    ENDIF.
    ls_bseg-zlsch = ms_ao_beleg-zlsch.
    ls_bseg-zterm = ms_ao_beleg-zterm.
    ls_bseg-zbd1t = ms_ao_beleg-zbd1t.
    ls_bseg-zfbdt = ms_ao_beleg-zfbdt.
    IF ms_ao_beleg_kont-gsber IS INITIAL.
      ls_bseg-gsber = ms_ao_beleg-t_kont[ 1 ]-gsber.
    ENDIF.
    ls_bseg-lzbkz = ms_ao_beleg-lzbkz.
    ls_bseg-landl = ms_ao_beleg-landl.

* Beim Buchen einer Stundung, einer Niederschlagung oder eines Erlasses
* muss über die Felder REBZG, REBZJ und REBZZ auf den Ursprungsbeleg verwiesen werden.
    IF mv_belnr_in IS NOT INITIAL AND ( ms_ao_header-psoty = c_psoty_stundung_06 OR ms_ao_header-psoty = c_psoty_niederschl_07 OR ms_ao_header-psoty = c_psoty_erlass_08
      OR ms_ao_header-psoty = c_psoty_ann_abs_05 ).
      ls_bseg-rebzg = mv_belnr_in.
      ls_bseg-rebzj = ms_ao_header-gjahr.
      ls_bseg-rebzz = ''."Buchungsposition
    ENDIF.

* bei Verrechnungs AO müssen die Empfängerkontierungsdaten übernommen werden.
    IF ms_ao_header-psoty = c_psoty_verr_03.
      MOVE-CORRESPONDING ms_ao_beleg_kont TO ls_bseg.
    ENDIF.

    APPEND ls_bseg TO c_bseg.



** Positionen / Sachkontozeilen
**MIG**    LOOP AT ms_ao_beleg-t_kont ASSIGNING FIELD-SYMBOL(<fs_kont>).
    LOOP AT mig_ao_beleg-t_kont ASSIGNING FIELD-SYMBOL(<fs_kont>).  "**MIG**
      CLEAR ls_bseg.

      ls_bseg-tbnam = 'VBSEGS'.
      ls_bseg-newko = <fs_kont>-hkont.
      ls_bseg-newbk = ms_ao_header-bukrs.

      DATA(lv_shkzg) = mv_shkzg.

      CALL FUNCTION 'FI_PSO_SHKZG_INVERS'
        CHANGING
          c_shkzg = lv_shkzg.

      CALL FUNCTION 'FI_PSO_POSTING_KEY_DETERMINE'
        EXPORTING
          i_koart = 'S'
          i_umskz = ''
          i_shkzg = lv_shkzg
        CHANGING
          c_bschl = ls_bseg-newbs.

      ls_bseg-wrbtr = <fs_kont>-wrbtr.
      ls_bseg-mwskz = COND #( WHEN <fs_kont>-mwskz IS INITIAL THEN ms_ao_beleg-mwskz ELSE <fs_kont>-mwskz ).

      ls_bseg-geber = <fs_kont>-geber.
      ls_bseg-zuonr = <fs_kont>-zuonr.
      ls_bseg-sgtxt = <fs_kont>-sgtxt.
      ls_bseg-kostl = <fs_kont>-kostl.
      ls_bseg-fistl = <fs_kont>-fistl.
      ls_bseg-fipex = <fs_kont>-fipex." es darf im DI nur fipex gefüllt sein, nicht fipos
      ls_bseg-fkber = <fs_kont>-fkber.
      ls_bseg-kblnr = <fs_kont>-kblnr. "Mittelvormerkung
      ls_bseg-gsber = <fs_kont>-gsber.
      ls_bseg-zfbdt = ms_ao_beleg-zfbdt.
      ls_bseg-aufnr = <fs_kont>-aufnr.
      ls_bseg-prctr = <fs_kont>-prctr.  "**MIG**
      ls_bseg-erlkz = <fs_kont>-erlkz.

      CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
        EXPORTING
          input  = <fs_kont>-ps_psp_pnr
        IMPORTING
          output = ls_bseg-projn.

      ls_bseg-projk = <fs_kont>-ps_psp_pnr.

      APPEND ls_bseg TO c_bseg.

    ENDLOOP.
  ENDMETHOD.


  METHOD MIG_GET_INSTANCE.

    IF instance IS INITIAL.
      instance = NEW #( ).
    ENDIF.

    instance->clear_data( ). "Für Massenverarveitung wichtig
    r_instance = instance.

  ENDMETHOD.


  METHOD pso_document_check.

    DATA:
      lt_return TYPE bapiret2_t,
      lt_mesg   TYPE tsmesg.


    IF mv_koart = c_konto_kreditor.
      CALL FUNCTION 'VENDOR_READ'
        EXPORTING
          i_bukrs       = ms_ao_header-bukrs
          i_lifnr       = ms_ao_beleg-partner
        EXCEPTIONS
          not_found     = 1
          lifnr_blocked = 2
          OTHERS        = 3.
      IF sy-subrc <> 0.
        APPEND VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                        message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ) TO lt_return.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          EXPORTING bapiret2_tab = lt_return.
      ENDIF.
    ELSEIF  mv_koart = c_konto_debitor.
      CALL FUNCTION 'CUSTOMER_READ'
        EXPORTING
          i_bukrs       = ms_ao_header-bukrs
          i_kunnr       = ms_ao_beleg-partner
        EXCEPTIONS
          not_found     = 1
          kunnr_blocked = 2
          OTHERS        = 3.
      IF sy-subrc <> 0.
        APPEND VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                        message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ) TO lt_return.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          EXPORTING bapiret2_tab = lt_return.
      ENDIF.

    ENDIF.

    check_fipex( EXPORTING i_bseg = c_bseg  ).

*   amount check for setting complete:
    amount_check_complete_or_check( i_bseg = c_bseg ).

* Bei der Stundung darf der Test nicht vor dem Echt Fuba laufen,
* ansonsten wird der Ausgleihcsbeleg nicht erzeugt
    IF ms_ao_header-psoty = c_psoty_stundung_06.
      RETURN.
    ENDIF.


    CALL FUNCTION 'MESSAGES_INITIALIZE'
      EXPORTING
        collect_and_send     = ' '
        reset                = 'X'
        i_store_duplicates   = 'X'
        i_no_duplicate_count = 0
        check_on_commit      = ' '
      EXCEPTIONS
        log_not_active       = 1
        wrong_identification = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
      APPEND VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                      message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ) TO lt_return.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
        EXPORTING bapiret2_tab = lt_return.
    ENDIF.

* first check
    IF mig_ao_beleg-resubmission <> 0.
      DATA(ls_mig_pso_data) = VALUE /thkr/s_mig_pso_di_data( resubmission = mig_ao_beleg-resubmission ).
    ENDIF.


    CALL FUNCTION '/THKR/FI_MIG_PSO_DOC_DI'
      EXPORTING
        i_nodata            = '/'
        i_del_nodata        = space
        i_intlot            = abap_true "Interne Nummernvergabe für Bündelungsnr.
        i_check             = abap_true
        i_due_date_deferral = mv_due_date_deferral
        i_mig_data          = ls_mig_pso_data
      TABLES
        t_bbkpf             = c_bkpf
        t_bbseg             = c_bseg
        t_bbtax             = c_btax
        t_pso50             = mt_pso50
      EXCEPTIONS
        error_message       = 1.
    IF sy-subrc = 1.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL FUNCTION 'MESSAGES_GIVE'
      TABLES
        t_mesg = lt_mesg.

    CALL FUNCTION 'MESSAGES_STOP'
      EXPORTING
        i_reset_messages  = abap_true
      EXCEPTIONS
        a_message         = 1
        e_message         = 2
        w_message         = 3
        i_message         = 4
        s_message         = 5
        deactivated_by_md = 6
        OTHERS            = 7.
    IF sy-subrc <> 0.
*      RAISE EXCEPTION TYPE /thkr/cx_psm_ao MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT lt_mesg ASSIGNING FIELD-SYMBOL(<fs_mesg>).
      APPEND VALUE #( type       = <fs_mesg>-msgty id         = <fs_mesg>-arbgb number     = <fs_mesg>-txtnr message    = <fs_mesg>-text
                      message_v1 = <fs_mesg>-msgv1 message_v2 = <fs_mesg>-msgv2 message_v3 = <fs_mesg>-msgv3 message_v4 = <fs_mesg>-msgv4 ) TO lt_return.
    ENDLOOP.


    IF lt_return IS NOT INITIAL AND line_exists( lt_return[ type = 'E' ] ).
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
        MESSAGE e001(/thkr/psm_ao) WITH lt_return[ type = 'E' ]-message
        EXPORTING bapiret2_tab = lt_return.
    ENDIF.



  ENDMETHOD.


  METHOD pso_document_post.


    DATA:
      lt_return TYPE bapiret2_t,
      lt_mesg   TYPE tsmesg.


    CALL FUNCTION 'MESSAGES_INITIALIZE'
      EXPORTING
        collect_and_send     = ' '
        reset                = 'X'
        i_store_duplicates   = 'X'
        i_no_duplicate_count = 0
        check_on_commit      = ' '
      EXCEPTIONS
        log_not_active       = 1
        wrong_identification = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
* save
    IF mig_ao_beleg-resubmission <> 0.
      DATA(ls_mig_pso_data) = VALUE /thkr/s_mig_pso_di_data( resubmission = mig_ao_beleg-resubmission ).
    ENDIF.

    CALL FUNCTION '/THKR/FI_MIG_PSO_DOC_DI'
      EXPORTING
        i_nodata            = '/'
        i_del_nodata        = space
        i_intlot            = abap_true "Interne Nummernvergabe für Bündelungsnr.
        i_check             = ms_ao_param-test_run
        i_due_date_deferral = mv_due_date_deferral
        i_mig_data          = ls_mig_pso_data
      IMPORTING
        e_bukrs             = ms_psm_ao_document_number-bukrs
        e_gjahr             = ms_psm_ao_document_number-gjahr
        e_belnr             = ms_psm_ao_document_number-belnr
        e_lotkz             = ms_psm_ao_document_number-lotkz
      TABLES
        t_bbkpf             = c_bkpf
        t_bbseg             = c_bseg
        t_bbtax             = c_btax
        t_pso50             = mt_pso50
      EXCEPTIONS
        error_message       = 1.
    IF sy-subrc = 1.
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
        MESSAGE e001(/thkr/psm_ao) WITH sy-msgid sy-msgno sy-msgv1 sy-msgv2.
    ENDIF..


    CALL FUNCTION 'MESSAGES_GIVE'
      TABLES
        t_mesg = lt_mesg.

    CALL FUNCTION 'MESSAGES_STOP'
      EXPORTING
        i_reset_messages  = abap_true
      EXCEPTIONS
        a_message         = 1
        e_message         = 2
        w_message         = 3
        i_message         = 4
        s_message         = 5
        deactivated_by_md = 6
        OTHERS            = 7.
    IF sy-subrc <> 0.
*      RAISE EXCEPTION TYPE /thkr/cx_psm_ao MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT lt_mesg ASSIGNING FIELD-SYMBOL(<fs_mesg>).
      APPEND VALUE #( type       = <fs_mesg>-msgty id         = <fs_mesg>-arbgb number     = <fs_mesg>-txtnr message    = <fs_mesg>-text
                      message_v1 = <fs_mesg>-msgv1 message_v2 = <fs_mesg>-msgv2 message_v3 = <fs_mesg>-msgv3 message_v4 = <fs_mesg>-msgv4 ) TO lt_return.
    ENDLOOP.



    IF lt_return IS NOT INITIAL AND line_exists( lt_return[ type = 'E' ] ).
      RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
        MESSAGE e001(/thkr/psm_ao) WITH lt_return[ type = 'E' ]-message
        EXPORTING bapiret2_tab = lt_return.
    ENDIF.

    mt_fm_t_bbkpf = c_bkpf.
    mt_fm_t_bbseg = c_bseg.

  ENDMETHOD.
ENDCLASS.
