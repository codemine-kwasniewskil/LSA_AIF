*&---------------------------------------------------------------------*
*& Report  /THKR/FI_KLEINBETRAG                                                  *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Funktion:
*
* Das Programm dient der gemäß Vorgabe des Mahnbereiches
* mittels Debitorengutschrift oder Debitorenrechnung direkt im Modul FI
* ohne Vier-Augen-Prinzip ausgebucht werden.
*
* die Buchungen finden nur für Debitoren auf Basis der Referenz statt
*
*_______________________________________________________________________
* Hinweise:
* in LSA zweite Kleinbetragsgrenze über Mahnstufe und nich Mahnsperre wie in BW
* in LSA keine Ausbuchung von MWSKZ = A1 / A2, da Steuerzeile  "ausgesternt"
*_______________________________________________________________________

REPORT /thkr/fi_kleinbetrag MESSAGE-ID /thkr/fi_nachr.


*----------------------------------------------------------------------*
*  general data declaration                                            *
*----------------------------------------------------------------------*
TYPE-POOLS: slis.

TABLES: t041a,
        kna1,
        knb1,
*        lfa1,
*        lfb1,
        bkpf,
        bsec,
        bsid,
        bsik.

* define table with bsid + additional fields
DATA: BEGIN OF g_t_bsid_ext OCCURS 0,
        grpkey(32) TYPE c.
        INCLUDE    STRUCTURE bsid.
DATA:   psoty      LIKE bkpf-psoty,
        cputm      LIKE bkpf-cputm, "003
        bktxt      LIKE bkpf-bktxt,
        dbblg      LIKE bkpf-dbblg,
        faedt      LIKE bsid-zfbdt,
        name1      LIKE bsec-name1,
        name2      LIKE bsec-name2,
        name3      LIKE bsec-name3,
        name4      LIKE bsec-name4,
        pstlz      LIKE bsec-pstlz,
        pstl2      LIKE bsec-pstl2,
        ort01      LIKE bsec-ort01,
        stras      LIKE bsec-stras,
        pfach      LIKE bsec-pfach,
        land1      LIKE bsec-land1,
      END   OF g_t_bsid_ext.

DATA: l_t_bsid_ext LIKE g_t_bsid_ext OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF g_t_bsid_ext_cpd OCCURS 0,
        empfg LIKE bsec-empfg.
        INCLUDE    STRUCTURE bsid.
DATA:   psoty LIKE bkpf-psoty,
        bktxt LIKE bkpf-bktxt,
        dbblg LIKE bkpf-dbblg,
        faedt LIKE bsid-zfbdt,
        name1 LIKE bsec-name1,
        name2 LIKE bsec-name2,
        name3 LIKE bsec-name3,
        name4 LIKE bsec-name4,
        pstlz LIKE bsec-pstlz,
        pstl2 LIKE bsec-pstl2,
        ort01 LIKE bsec-ort01,
        stras LIKE bsec-stras,
        pfach LIKE bsec-pfach,
        land1 LIKE bsec-land1,
      END   OF g_t_bsid_ext_cpd.



DATA: BEGIN OF g_t_cust OCCURS 0,
        bukrs LIKE knb1-bukrs,
        kunnr LIKE knb1-kunnr,
        xcpdk LIKE kna1-xcpdk,
      END   OF g_t_cust.

DATA: gt_kb_buch LIKE /thkr/kb_buch OCCURS 0 WITH HEADER LINE,
      gt_kb_betr LIKE /thkr/kb_betr OCCURS 0 WITH HEADER LINE,
      gt_t047m   LIKE t047m OCCURS 0 WITH HEADER LINE,
      gt_kb_co   LIKE /thkr/kb_co OCCURS 0 WITH HEADER LINE.

DATA: gs_kb_buch TYPE /thkr/kb_buch,
      gs_kb_co   TYPE /thkr/kb_co.
DATA: BEGIN OF gf_maber,
        maber TYPE maber,
      END   OF gf_maber.

* work area for all flags together
DATA: BEGIN OF g_f_flags,
        upay   LIKE boole-boole,
        opay   LIKE boole-boole,
        recur  LIKE boole-boole,
        post   LIKE boole-boole,
        detail LIKE boole-boole,
        testr  LIKE boole-boole,
      END   OF g_f_flags.

DATA: g_blart_string TYPE cstring.

DATA: g_hwaer          LIKE bkpf-hwaer,
      g_gjahr          LIKE bkpf-gjahr,
      g_flg_exit       LIKE boole-boole,
      g_numb_upay      LIKE sy-tabix, "counter for number of fi docs per
      g_numb_opay      LIKE sy-tabix, "request for over- or underpayment
      l_f_bsid_ext_cpd LIKE g_t_bsid_ext_cpd,
      l_var1           LIKE sy-msgv1,
      l_var2           LIKE sy-msgv2,
      l_var3           LIKE sy-msgv3,
      l_var4           LIKE sy-msgv4.


* data for application log
DATA: g_s_log             TYPE bal_s_log,
      g_log_handle        TYPE balloghndl,
      g_t_log_handle      TYPE bal_t_logh,
      g_s_display_profile TYPE bal_s_prof.

* for schedule manager
DATA: g_aplstat        TYPE smmain-aplstat,
      g_f_schedman_key TYPE schedman_key.


CONSTANTS:
  gc_off     TYPE c VALUE ' ',
  gc_on      TYPE c VALUE 'X',
  gc_hash    TYPE c VALUE '#',
  gc_trennz  TYPE c VALUE '-',
  gc_char_h  TYPE shkzg VALUE 'H',
  gc_char_s  TYPE shkzg VALUE 'S',
  gc_char_t  TYPE shkzg VALUE 'T',
  gc_shkzg_h TYPE shkzg VALUE 'H',
  gc_shkzg_s TYPE shkzg VALUE 'S'.

CONSTANTS:
  gc_mansp_3    TYPE mansp VALUE '3',
  gc_mansp_leer TYPE mansp VALUE ' ',
  gc_manst_1    like bsid-manst VALUE 1,
* ---- activity = post
  con_act_post  LIKE tact-actvt VALUE '10',
  gc_blart_di   TYPE blart VALUE 'DI',
  gc_blart_sn   TYPE blart VALUE 'SN'.
DATA: g_flg_post LIKE boole-boole VALUE 'X'. "for debugging

*----------------------------------------------------------------------*
*  parameters                                                          *
*----------------------------------------------------------------------*

* general selection fields
SELECTION-SCREEN  BEGIN OF BLOCK sf WITH FRAME TITLE TEXT-001.

  PARAMETERS: p_bukrs LIKE bkpf-bukrs MEMORY ID buk OBLIGATORY.
  SELECT-OPTIONS: s_kunnr FOR bsid-kunnr.
  PARAMETERS: p_faedt LIKE psowf-faedt DEFAULT sy-datum OBLIGATORY.
*-----------------------------------------------------------------------
* Änderung dxc Roch: 002
* Selektion nach Mahnbereich
  SELECT-OPTIONS: s_maber FOR bsid-maber.
*-----------------------------------------------------------------------
*----------------------------------------------------------------------*
*Kontenart Debitor ist vorgegeben
*----------------------------------------------------------------------*
SELECTION-SCREEN  END OF BLOCK sf.

*----------------------------------------------------------------------*
* Verdichtung nach Referenz ist vorgegeben
*----------------------------------------------------------------------*
PARAMETERS: p_xblnr  TYPE xfeld DEFAULT gc_on NO-DISPLAY.

*----------------------------------------------------------------------*
* several control flags: bereits fest vorgegeben
*----------------------------------------------------------------------*
SELECTION-SCREEN  BEGIN OF BLOCK cont WITH FRAME TITLE TEXT-003.
  PARAMETERS: p_upay  TYPE xfeld DEFAULT gc_on.
  PARAMETERS: p_opay  TYPE xfeld DEFAULT gc_on.
*----------------------------------------------------------------------*
* keine Stundungen , und Daueranordnungen-Parameter nur als Hinweis
*
*----------------------------------------------------------------------*
*  parameters: p_defer type xfeld default gc_on  .
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 2(42) TEXT-020.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN  END OF BLOCK cont.


SELECTION-SCREEN  BEGIN OF BLOCK post WITH FRAME TITLE TEXT-004.
* fields for posting
  PARAMETERS:
    p_budat LIKE bsid-budat DEFAULT sy-datum,
    p_bldat LIKE bsid-bldat DEFAULT sy-datum,
    p_zfbdt LIKE bsid-zfbdt DEFAULT sy-datum.
SELECTION-SCREEN  END OF BLOCK post.

SELECTION-SCREEN  BEGIN OF BLOCK flag WITH FRAME TITLE TEXT-005.
* general flags
  PARAMETERS: p_detail LIKE rfpdo-allgprin  DEFAULT 'X'.
  PARAMETERS: p_testr  LIKE rfpdo1-allgtest DEFAULT 'X'.
  PARAMETERS: p_check TYPE xfeld DEFAULT gc_off.
  PARAMETERS: p_defk TYPE xfeld DEFAULT gc_off NO-DISPLAY. " in LSA gibt es keine Default-Kostenstellen
SELECTION-SCREEN  END OF BLOCK flag.

* Daten FM_FYC_SCHEDMAN_INIT
INCLUDE rkasmawf.
*----------------------------------------------------------------------*
*        S E L E K T I O N S B I L D      VERARBEITEN (PBO)            *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name CS 'P_UPAY' OR
      screen-name CS 'P_OPAY'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
*----------------------------------------------------------------------*
*  main program                                                        *
*----------------------------------------------------------------------*
START-OF-SELECTION.

*----- initialize schedman monitor
*----- note: commit work executed
  CALL FUNCTION 'FM_FYC_SCHEDMAN_INIT'
    EXPORTING
      i_repid          = sy-repid           "report id
      i_tcode          = '/THKR/KLEINBETRAG'          "transaction code
      i_wfitem         = wf_witem           "parameter of RKASMAWF
      i_wflist         = wf_wlist           "parameter of RKASMAWF
      i_flg_test       = p_testr            "flag for test mode
    IMPORTING
      e_f_schedman_key = g_f_schedman_key.

* set status for schedman
  g_aplstat = '0'.    "success

*---initialize application log
  g_s_log-extnumber = 'Kleinbetraege bearbeiten'.           "#EC NOTEXT
  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log      = g_s_log
    IMPORTING
      e_log_handle = g_log_handle
    EXCEPTIONS
      OTHERS       = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* fill all flags together
  g_f_flags-upay   = p_upay.
  g_f_flags-opay   = p_opay.
  g_f_flags-detail = p_detail.
  g_f_flags-testr  = p_testr.



* select the customizing tables and set global data
  PERFORM select_customizing TABLES   gt_kb_buch
                                      gt_kb_betr
                                      gt_kb_co
                                      gt_t047m
                             USING    p_bukrs
                             CHANGING g_hwaer
                                      g_gjahr
                                      gs_kb_buch
                                      gs_kb_co
                                      g_blart_string
                                      g_flg_exit.

  IF g_flg_exit = 'X'.
    g_aplstat = '4'.    "error

    PERFORM write_protocol.

*----- send info to schedman monitor
*----- note: commit work executed!
    CALL FUNCTION 'FM_FYC_SCHEDMAN_CLOSE'
      EXPORTING
        i_f_schedman_key = g_f_schedman_key "obtained from schedman init
        i_wfitem         = wf_witem           "parameter of RKASMAWF
        i_wfokey         = wf_okey            "parameter of RKASMAWF
        i_aplstat        = g_aplstat.         "result filled

    EXIT.
  ENDIF.
*----------------------------------------------------------------------*
* authority check für Buchungskreis und Belegarten/Bergru der
*                 Belegarten
*----------------------------------------------------------------------*
  PERFORM authority_check USING gs_kb_buch.



* select all customers
  PERFORM select_customers TABLES s_kunnr
                                  g_t_cust
                           USING  p_bukrs.


* process every customer separately
* Bukrs-Kunnr-xcpdk
  LOOP AT g_t_cust.

*   refresh all necessary tables
    REFRESH: g_t_bsid_ext,
             g_t_bsid_ext_cpd.
    CLEAR:   g_t_bsid_ext,
             g_t_bsid_ext_cpd,
             g_flg_exit.

*   select open documents for customer
    PERFORM select_docs_customer TABLES   g_t_bsid_ext
                                          g_t_bsid_ext_cpd
                                 USING    p_bukrs
                                          g_t_cust-kunnr
                                          g_t_cust-xcpdk
                                 CHANGING g_flg_exit.
    IF g_flg_exit = 'X'.
      CONTINUE.
    ENDIF.

*   work on each group of documents
    IF g_t_cust-xcpdk IS INITIAL.
      PERFORM process_customer TABLES   g_t_bsid_ext
                               USING    g_t_cust-kunnr
                                        g_t_cust-xcpdk.
    ELSE.

      REFRESH: l_t_bsid_ext.
      CLEAR: l_t_bsid_ext.
*     group documents according to cpd key
      SORT g_t_bsid_ext_cpd BY empfg.

      LOOP AT g_t_bsid_ext_cpd.
        MOVE: g_t_bsid_ext_cpd TO l_f_bsid_ext_cpd.

        AT NEW empfg.
          REFRESH: l_t_bsid_ext.
        ENDAT.

        MOVE-CORRESPONDING: g_t_bsid_ext_cpd TO l_t_bsid_ext.
        APPEND: l_t_bsid_ext.

        AT END OF empfg.
*------------------------------------------------------------
*  dxc Roch 002: CpD-Kunden ohne den interessierenden Mahnbereich
*  werden nicht weiter beachtet
*  da ggf.mehrere Mahnbereiche vorhanden pro Referenz - das wäre
*  ein Fehler  wird nicht danach selektiert sondern geprüft
*------------------------------------------------------------
          LOOP AT l_t_bsid_ext TRANSPORTING NO FIELDS WHERE maber IN s_maber.
            EXIT.
          ENDLOOP.
          IF sy-subrc = 0.
            IF g_f_flags-detail = 'X'.
              IF 1 = 2.
                MESSAGE s473(fq) WITH l_f_bsid_ext_cpd-name1
                                  l_f_bsid_ext_cpd-stras
                                  l_f_bsid_ext_cpd-ort01.
*             Verarbeitung: &1, &2, &3
              ENDIF.
              l_var1 = l_f_bsid_ext_cpd-name1.
              l_var2 = l_f_bsid_ext_cpd-stras.
              l_var3 = l_f_bsid_ext_cpd-ort01.
              CLEAR: l_var4.
              PERFORM message_store USING 'FQ' 'S' '473'
                                          l_var1 l_var2 l_var3 l_var4
                                          g_t_cust-kunnr space space.
            ENDIF.
            PERFORM process_customer TABLES   l_t_bsid_ext
                                     USING    g_t_cust-kunnr
                                              g_t_cust-xcpdk.
          ENDIF.
        ENDAT.
      ENDLOOP.

    ENDIF.

  ENDLOOP.


* write protocol
  PERFORM write_protocol.

*----- send info to schedman monitor
*----- note: commit work executed!
  CALL FUNCTION 'FM_FYC_SCHEDMAN_CLOSE'
    EXPORTING
      i_f_schedman_key = g_f_schedman_key "obtained from schedman init
      i_wfitem         = wf_witem           "parameter of RKASMAWF
      i_wfokey         = wf_okey            "parameter of RKASMAWF
      i_aplstat        = g_aplstat.         "result filled

*&---------------------------------------------------------------------*
*&      Form  WRITE_PROTOCOL
*&---------------------------------------------------------------------*
FORM write_protocol.


* define how message should be displayed
  PERFORM create_display_profile USING    p_testr
                                 CHANGING g_s_display_profile.

* display log
  INSERT g_log_handle INTO TABLE g_t_log_handle.
  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXPORTING
      i_s_display_profile = g_s_display_profile
      i_t_log_handle      = g_t_log_handle
    EXCEPTIONS
      OTHERS              = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
             WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                               " WRITE_PROTOCOL

*&---------------------------------------------------------------------*
*&      Form  SELECT_DOCS_CUSTOMER
*&---------------------------------------------------------------------*
*       select open items for customer
*
*       Es werden keine Dauerbelege selektiert
*       keine Fälle mit SD: Geschäftsnummer
*       1 Referenz mit Dauer und norm. Buchung sollte nicht auftreten
*       1 Referenz mit SD und ohne SD sollte nicht auftreten
*       WIE SIEHT DAS
*----------------------------------------------------------------------*
FORM select_docs_customer
                 TABLES   c_t_bsid_ext     STRUCTURE g_t_bsid_ext
                          c_t_bsid_ext_cpd STRUCTURE g_t_bsid_ext_cpd
                 USING    u_bukrs       LIKE knb1-bukrs
                          u_kunnr       LIKE knb1-kunnr
                          u_xcpdk       LIKE kna1-xcpdk
                 CHANGING c_flg_exit.

  DATA: BEGIN OF l_t_bkpf_bsid OCCURS 0,
          bkpf LIKE bkpf,
          bsid LIKE bsid,
        END  OF l_t_bkpf_bsid.

  DATA: l_faede LIKE faede,
        l_lines LIKE sy-tabix,
        l_var1  LIKE sy-msgv1,
        l_var2  LIKE sy-msgv2,
        l_var3  LIKE sy-msgv3,
        l_var4  LIKE sy-msgv4,
        l_dbblg TYPE dbblg.




  CLEAR  l_dbblg.
  CLEAR: c_flg_exit.

* select documents and headers
  SELECT * INTO TABLE l_t_bkpf_bsid
           FROM bkpf AS k INNER JOIN bsid AS d
           ON    k~bukrs =  d~bukrs
           AND   k~belnr =  d~belnr
           AND   k~gjahr =  d~gjahr
           WHERE d~bukrs =  u_bukrs
           AND   d~kunnr =  u_kunnr
           AND   k~dbblg = l_dbblg.
*------------------------------------------------------------
*  dxc Roch 002: Kunden ohne den interessierenden Mahnbereich
*  werden nicht weiter beachtet
*  da ggf.mehrere Mahnbereiche vorhanden pro Referenz (Fehler)
*  wird nicht danach selektiert
*------------------------------------------------------------
  LOOP AT l_t_bkpf_bsid TRANSPORTING NO FIELDS WHERE bsid-maber IN s_maber.
    EXIT.
  ENDLOOP.

  IF sy-subrc = 0. "dxc Roch 002
    IF u_xcpdk IS INITIAL.
* no cpd account
      LOOP AT l_t_bkpf_bsid.
        CLEAR: c_t_bsid_ext.
        MOVE-CORRESPONDING: l_t_bkpf_bsid-bkpf TO c_t_bsid_ext.
        MOVE-CORRESPONDING: l_t_bkpf_bsid-bsid TO c_t_bsid_ext.

*     determine due date
        CLEAR: l_faede.
        MOVE-CORRESPONDING c_t_bsid_ext TO l_faede.
        l_faede-koart = 'D'.
        CALL FUNCTION 'DETERMINE_DUE_DATE'
          EXPORTING
            i_faede = l_faede
          IMPORTING
            e_faede = l_faede
          EXCEPTIONS
            OTHERS  = 1.
        c_t_bsid_ext-faedt = l_faede-netdt.

        APPEND: c_t_bsid_ext.
      ENDLOOP.

      DESCRIBE TABLE c_t_bsid_ext LINES l_lines.

    ELSE.
* cpd account
      LOOP AT l_t_bkpf_bsid.
        CLEAR: c_t_bsid_ext.
        MOVE-CORRESPONDING: l_t_bkpf_bsid-bkpf TO c_t_bsid_ext_cpd.
        MOVE-CORRESPONDING: l_t_bkpf_bsid-bsid TO c_t_bsid_ext_cpd.

*     determine due date
        CLEAR: l_faede.
        MOVE-CORRESPONDING c_t_bsid_ext_cpd TO l_faede.
        l_faede-koart = 'D'.
        CALL FUNCTION 'DETERMINE_DUE_DATE'
          EXPORTING
            i_faede = l_faede
          IMPORTING
            e_faede = l_faede
          EXCEPTIONS
            OTHERS  = 1.
        c_t_bsid_ext_cpd-faedt = l_faede-netdt.

*     determine cpd key
        PERFORM fill_cpdkey_debi CHANGING c_t_bsid_ext_cpd.

        APPEND: c_t_bsid_ext_cpd.
      ENDLOOP.

      DESCRIBE TABLE c_t_bsid_ext_cpd LINES l_lines.

    ENDIF.
  ENDIF. "dxc Roch 002
  IF l_lines IS INITIAL.
    c_flg_exit = 'X'.
    IF g_f_flags-detail = 'X'.
      IF 1 = 2.
        MESSAGE s453(fq) WITH u_kunnr.
*   Keine Belege für Debitor &1 vorhanden
      ENDIF.
      l_var1 = u_kunnr.
      CLEAR: l_var2, l_var3, l_var4.
      PERFORM message_store USING 'FQ' 'S' '453'
                                  l_var1 l_var2 l_var3 l_var4
                                  u_kunnr space space.
    ENDIF.
  ENDIF.

ENDFORM.                               " SELECT_DOCS_CUSTOMER

*&---------------------------------------------------------------------*
*&      Form  SELECT_CUSTOMERS
*&---------------------------------------------------------------------*
*       select all customers of range u_kunnr
*----------------------------------------------------------------------*
FORM select_customers TABLES   u_kunnr  STRUCTURE s_kunnr
                               c_t_cust STRUCTURE g_t_cust
                      USING    u_bukrs  LIKE knb1-bukrs.


  SELECT b~bukrs b~kunnr a~xcpdk
         INTO CORRESPONDING FIELDS OF TABLE c_t_cust
         FROM knb1 AS b INNER JOIN kna1 AS a
         ON    b~kunnr =  a~kunnr
         WHERE b~bukrs =  u_bukrs
         AND   b~kunnr IN u_kunnr.

  SORT c_t_cust BY kunnr.

ENDFORM.                               " SELECT_CUSTOMERS

*&---------------------------------------------------------------------*
*&      Form  CHECK_DEBI_ACCOUNT
*&---------------------------------------------------------------------*
*       check if balance of account is zero
*       check if payments without assignment e.g. down payments
*
*       eine Prüfung auf nicht zugeordnete Zahlungen (Akonto) findet hier
*       nicht statt - (Merkmale? Buchungsschlüssel Zahlung und kein Beleg
*       mit gleichem S/H Kennzeichen vorhanden).
*----------------------------------------------------------------------*
FORM check_debi_account TABLES   u_t_bsid_ext STRUCTURE g_t_bsid_ext
                        USING    u_kunnr      LIKE      knb1-kunnr
                        CHANGING c_flg_exit.

  DATA: l_sum_h         LIKE bsid-dmbtr,
        l_sum_s         LIKE bsid-dmbtr,
        l_var1          LIKE sy-msgv1,
        l_var2          LIKE sy-msgv2,
        l_var3          LIKE sy-msgv3,
        l_var4          LIKE sy-msgv4,
        l_flg_no_assign LIKE boole-boole.

  DATA: l_zz_001_init TYPE /thkr/sd_vbak_zz001.

  CLEAR: c_flg_exit.

* look at every document
* - calculate sum
* - find not assign payments
  LOOP AT u_t_bsid_ext.


    IF u_t_bsid_ext-shkzg = 'H'.
      l_sum_h = l_sum_h + u_t_bsid_ext-dmbtr.

      IF NOT u_t_bsid_ext-umskz IS INITIAL.
        l_flg_no_assign = 'X'.
      ENDIF.

    ELSE.
      l_sum_s = l_sum_s + u_t_bsid_ext-dmbtr.
    ENDIF.

  ENDLOOP.

* balance is zero?
  IF l_sum_h = l_sum_s.
    c_flg_exit = 'X'.
    IF g_f_flags-detail = 'X'.
      IF 1 = 2.
        MESSAGE s457(fq) WITH u_kunnr.
*       Kontensaldo Null: Debitor &1 wird nicht bearbeitet
      ENDIF.
*002: Für CpD -Name zusätzlich angeben
      IF u_t_bsid_ext-name1 IS NOT INITIAL.
        CONCATENATE u_kunnr u_t_bsid_ext-name1 INTO l_var1 SEPARATED BY gc_trennz.
      ELSE.
        l_var1 = u_kunnr.
      ENDIF.
      CLEAR: l_var2, l_var3, l_var4.
      PERFORM message_store USING 'FQ' 'W' '457'
                                  l_var1 l_var2 l_var3 l_var4
                                  u_kunnr space space.
    ENDIF.
    EXIT.
  ENDIF.


* documents without assignments?
  IF l_flg_no_assign = 'X'.
    c_flg_exit = 'X'.
    IF g_f_flags-detail = 'X'.
      IF 1 = 2.
        MESSAGE s455(fq) WITH u_kunnr.
*       Nicht zugeordnete Zahlungen: Debitor &1 wird nicht bearbeitet
      ENDIF.
*002: Für CpD -Name zusätzlich angeben
      IF u_t_bsid_ext-name1 IS NOT INITIAL.
        CONCATENATE u_kunnr u_t_bsid_ext-name1 INTO l_var1 SEPARATED BY gc_trennz.
      ELSE.
        l_var1 = u_kunnr.
      ENDIF.
      CLEAR: l_var2, l_var3, l_var4.
      PERFORM message_store USING 'FQ' 'W' '455'
                                  l_var1 l_var2 l_var3 l_var4
                                  u_kunnr space space.
    ENDIF.
    EXIT.
  ENDIF.


ENDFORM.                               " CHECK_DEBI_ACCOUNT

*&---------------------------------------------------------------------*
*&      Form  MESSAGE_STORE
*&---------------------------------------------------------------------*
*       write message into message handler
*----------------------------------------------------------------------*
FORM message_store USING u_msgid LIKE sy-msgid
                         u_msgty LIKE sy-msgty
                         u_msgno LIKE sy-msgno
                         u_msgv1 LIKE sy-msgv1
                         u_msgv2 LIKE sy-msgv2
                         u_msgv3 LIKE sy-msgv3
                         u_msgv4 LIKE sy-msgv4
                         u_kunnr
                         u_lifnr
                         u_grpkey.

  DATA: l_s_msg        TYPE bal_s_msg.
  DATA: l_s_context    TYPE pso_bal_01.

  IF u_msgty = 'E' AND g_aplstat = '0'.
*   set status for schedman
    g_aplstat = '2'.    "warning
  ENDIF.

* define data of message for Application Log
  l_s_msg-msgty     = u_msgty.
  l_s_msg-msgid     = u_msgid.
  l_s_msg-msgno     = u_msgno.
  l_s_msg-msgv1     = u_msgv1.
  l_s_msg-msgv2     = u_msgv2.
  l_s_msg-msgv3     = u_msgv3.
  l_s_msg-msgv4     = u_msgv4.

* funktioniert nicht
  l_s_context-kunnr  = u_kunnr.
  l_s_context-lifnr  = u_lifnr.
  l_s_context-grpkey = u_grpkey.
  l_s_msg-context-tabname  = 'PSO_BAL_01'.
  l_s_msg-context-value    = l_s_context.

* add this message to log file
  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      i_log_handle  = g_log_handle
      i_s_msg       = l_s_msg
    EXCEPTIONS
      log_not_found = 0
      OTHERS        = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                               " MESSAGE_STORE

*&---------------------------------------------------------------------*
*&      Form  CREATE_DISPLAY_PROFILE
*&---------------------------------------------------------------------*
*       Define how messages should be displayed
*----------------------------------------------------------------------*
FORM create_display_profile USING    u_testr
                            CHANGING
                               c_s_display_profile TYPE bal_s_prof.

  DATA: l_s_fcat TYPE bal_s_fcat,
        l_s_sort TYPE bal_s_sort.



* set title of dynpro
  IF u_testr EQ 'X'.
    c_s_display_profile-title     = TEXT-010.
  ELSE.
    c_s_display_profile-title     = TEXT-011.
  ENDIF.

* set header of tree
  c_s_display_profile-head_size = 35.
* set size of tree
  c_s_display_profile-tree_size = 22.

* set report for display variants
  c_s_display_profile-disvariant-report = sy-repid.

* all messages should be displayed immediately
  c_s_display_profile-show_all = 'X'.

* display as ALV-Grid -> necessary for accessibility
  c_s_display_profile-use_grid = 'X'.

************* define structure of message table

* customer
  CLEAR l_s_fcat.
  l_s_fcat-ref_table = 'PSO_BAL_01'.
  l_s_fcat-ref_field = 'KUNNR'.
  l_s_fcat-col_pos   = 1.
  APPEND l_s_fcat TO c_s_display_profile-mess_fcat.




* key of document group
  CLEAR l_s_fcat.
  l_s_fcat-ref_table = 'PSO_BAL_01'.
  l_s_fcat-ref_field = 'GRPKEY'.
  l_s_fcat-col_pos   = 4.
  APPEND l_s_fcat TO c_s_display_profile-mess_fcat.


* message text
  CLEAR l_s_fcat.
  l_s_fcat-ref_table = 'BAL_S_SHOW'.
  l_s_fcat-ref_field = 'T_MSG'.
  l_s_fcat-outputlen = 100.
  l_s_fcat-col_pos   = 5.
  APPEND l_s_fcat TO c_s_display_profile-mess_fcat.


  CLEAR l_s_fcat.
  l_s_fcat-ref_table = 'BAL_S_SHOW'.
  l_s_fcat-ref_field = 'MSGID'.
  l_s_fcat-outputlen = 20.
  l_s_fcat-col_pos   = 6.
  APPEND l_s_fcat TO c_s_display_profile-mess_fcat.

  CLEAR l_s_fcat.
  l_s_fcat-ref_table = 'BAL_S_SHOW'.
  l_s_fcat-ref_field = 'MSGNO'.
  l_s_fcat-outputlen = 10.
  l_s_fcat-col_pos   = 7.
  APPEND l_s_fcat TO c_s_display_profile-mess_fcat.

ENDFORM.                               " CREATE_DISPLAY_PROFILE

*&---------------------------------------------------------------------*
*&      Form  FILL_CPDKEY_DEBI
*&---------------------------------------------------------------------*
*       read BSEC and fill cpdkey
*----------------------------------------------------------------------*
FORM fill_cpdkey_debi CHANGING c_f_bsid_ext STRUCTURE g_t_bsid_ext_cpd.

  DATA: l_f_bsec LIKE bsec.



  SELECT SINGLE * FROM   bsec INTO l_f_bsec
                  WHERE  bukrs  = c_f_bsid_ext-bukrs
                  AND    belnr  = c_f_bsid_ext-belnr
                  AND    gjahr  = c_f_bsid_ext-gjahr
                  AND    buzei  = c_f_bsid_ext-buzei.

  IF sy-subrc IS INITIAL.
    c_f_bsid_ext-empfg = l_f_bsec-empfg.
    c_f_bsid_ext-name1 = l_f_bsec-name1.
    c_f_bsid_ext-name2 = l_f_bsec-name2.
    c_f_bsid_ext-name3 = l_f_bsec-name3.
    c_f_bsid_ext-name4 = l_f_bsec-name4.
    c_f_bsid_ext-pstlz = l_f_bsec-pstlz.
    c_f_bsid_ext-pstl2 = l_f_bsec-pstl2.
    c_f_bsid_ext-ort01 = l_f_bsec-ort01.
    c_f_bsid_ext-stras = l_f_bsec-stras.
    c_f_bsid_ext-pfach = l_f_bsec-pfach.
    c_f_bsid_ext-land1 = l_f_bsec-land1.
  ENDIF.

ENDFORM.                               " FILL_CPDKEY_DEBI

*&---------------------------------------------------------------------*
*&      Form  PROCESS_CUSTOMER
*&---------------------------------------------------------------------*
*       work on group of documents for customer
*----------------------------------------------------------------------*
FORM process_customer  TABLES   c_t_bsid_ext  STRUCTURE g_t_bsid_ext
                       USING    u_kunnr       LIKE knb1-kunnr
                                u_xcpdk       LIKE kna1-xcpdk.

  DATA: l_t_bsid_ext LIKE g_t_bsid_ext OCCURS 0 WITH HEADER LINE.

  DATA: l_flg_exit LIKE boole-boole,
        l_grpkey   LIKE g_t_bsid_ext-grpkey.



* check balance and payments of account
  PERFORM check_debi_account TABLES   c_t_bsid_ext
                             USING    u_kunnr
                             CHANGING l_flg_exit.
  IF l_flg_exit = 'X'.
    EXIT.
  ENDIF.

*   compress documents according to selection parameters
  PERFORM compress_docs_debi TABLES   c_t_bsid_ext
                             USING    u_kunnr.

  SORT c_t_bsid_ext BY grpkey.

  LOOP AT c_t_bsid_ext.
    AT NEW grpkey.
      REFRESH: l_t_bsid_ext.
    ENDAT.

    MOVE-CORRESPONDING: c_t_bsid_ext TO l_t_bsid_ext.
    APPEND: l_t_bsid_ext.
    l_grpkey = c_t_bsid_ext-grpkey.

    AT END OF grpkey.
      PERFORM process_docs_customer TABLES   l_t_bsid_ext
                                    USING    g_t_cust-bukrs
                                             g_t_cust-kunnr
                                             u_xcpdk
                                             l_grpkey.
    ENDAT.

  ENDLOOP.
ENDFORM.                               " PROCESS_CUSTOMER

*&---------------------------------------------------------------------*
*&      Form  COMPRESS_DOCS_DEBI
*&---------------------------------------------------------------------*
*       compress documents with same xblnr or belnr (get same grpkey)
*       documents with rebzg get key of reference document
*----------------------------------------------------------------------*
FORM compress_docs_debi TABLES   c_t_bsid_ext STRUCTURE g_t_bsid_ext
                        USING    u_kunnr      LIKE knb1-kunnr.

  DATA: l_t_bsid     LIKE bsid OCCURS 0 WITH HEADER LINE,
        l_t_bsid_ext LIKE g_t_bsid_ext OCCURS 0 WITH HEADER LINE.

  DATA: l_grpkey     LIKE g_t_bsid_ext-grpkey,
        l_f_bsid     LIKE bsid,
        l_tabix      LIKE sy-tabix,
        l_loop       LIKE sy-tabix,
        l_tabix_bsid LIKE sy-tabix,
        l_lines      LIKE sy-tabix.



  SORT c_t_bsid_ext BY belnr gjahr buzei.


  LOOP AT c_t_bsid_ext.

*     compression with xblnr

    c_t_bsid_ext-grpkey = c_t_bsid_ext-xblnr.

    IF     c_t_bsid_ext-xblnr IS INITIAL AND
       NOT c_t_bsid_ext-rebzg IS INITIAL.
      MOVE-CORRESPONDING: c_t_bsid_ext TO l_t_bsid.
      APPEND: l_t_bsid.
    ENDIF.


    MODIFY c_t_bsid_ext.
  ENDLOOP.



* process those documents which have a reference to another doc
* this is necessary if several documents in a chain
* not more than 10 loops in case of endless chain
  DESCRIBE TABLE l_t_bsid LINES l_lines.
  l_loop = 1.
  SORT l_t_bsid BY belnr gjahr buzei.

  WHILE l_lines <> 0 AND l_loop < 11.
    LOOP AT l_t_bsid.
      l_f_bsid = l_t_bsid.
      l_tabix  = sy-tabix.
      READ TABLE l_t_bsid WITH KEY belnr = l_f_bsid-rebzg
                                   gjahr = l_f_bsid-rebzj
                                   buzei = l_f_bsid-rebzz
                          BINARY SEARCH.
      IF sy-subrc = 0.
*       reference document still in help table -> check later
        CONTINUE.
      ELSE.
*       reference document not in help table -> check c_t_bsid_ext
        READ TABLE c_t_bsid_ext WITH KEY belnr = l_f_bsid-rebzg
                                         gjahr = l_f_bsid-rebzj
                                         buzei = l_f_bsid-rebzz
                                BINARY SEARCH.
        IF sy-subrc = 0.
*         take key of reference document
          l_grpkey = c_t_bsid_ext-grpkey.
*         write key into current document
          READ TABLE c_t_bsid_ext WITH KEY belnr = l_f_bsid-belnr
                                           gjahr = l_f_bsid-gjahr
                                           buzei = l_f_bsid-buzei
                                  BINARY SEARCH.
          IF sy-subrc = 0.
            l_tabix_bsid = sy-tabix.
            c_t_bsid_ext-grpkey = l_grpkey.
            MODIFY c_t_bsid_ext INDEX l_tabix_bsid.
          ENDIF.
        ENDIF.

        DELETE l_t_bsid INDEX l_tabix.
        CLEAR: l_t_bsid.
      ENDIF.
    ENDLOOP.

    DESCRIBE TABLE l_t_bsid LINES l_lines.
    l_loop = l_loop + 1.
  ENDWHILE.



ENDFORM.                               " COMPRESS_DOCS_DEBI

*&---------------------------------------------------------------------*
*&      Form  PROCESS_DOCS_CUSTOMER
*&---------------------------------------------------------------------*
*       work on a group of documents
*----------------------------------------------------------------------*
FORM process_docs_customer TABLES c_t_bsid_ext STRUCTURE g_t_bsid_ext
                           USING  u_bukrs      LIKE knb1-bukrs
                                  u_kunnr      LIKE knb1-kunnr
                                  u_xcpdk      LIKE kna1-xcpdk
                                  u_grpkey     LIKE g_t_bsid_ext-grpkey.

  DATA: l_flg_upay LIKE boole-boole,   "underpayment
        l_flg_opay LIKE boole-boole,   "overpayment
        l_dmbtr    LIKE bsid-dmbtr,
        l_lifnr    LIKE lfb1-lifnr,    "dummy
        l_flg_exit LIKE boole-boole,
        l_belnr    LIKE bseg-belnr,
        l_gjahr    LIKE bseg-gjahr,
        l_buzei    LIKE bseg-buzei,
        l_umskz    LIKE bseg-umskz.

  DATA: ls_kb_betr TYPE /thkr/kb_betr,
        l_maber    TYPE maber,
        l_mansp    TYPE mansp.

  DATA: l_h_ex  TYPE xfeld,
        l_s_ex  TYPE xfeld,
        l_xzahl TYPE xfeld.

  DATA: lt_pso02     TYPE STANDARD TABLE OF pso02,
        ls_pso02     TYPE pso02,
        l_diff       TYPE xfeld,
        ls_bsid_ext  LIKE LINE OF  g_t_bsid_ext,
        ls_bsid_extk LIKE LINE OF  g_t_bsid_ext.

* delete docs which aren't due (check with deferral requests)
  PERFORM delete_docs_customer TABLES   c_t_bsid_ext
***                                        l_t_belnr
                               USING    u_kunnr
                                        u_grpkey
                               CHANGING l_flg_exit
                                        l_maber.

  CHECK l_flg_exit = ' '.


* Kleinbetragsgrenze für den Mahnbereich
  PERFORM get_kb_betr USING l_maber
                    CHANGING  ls_kb_betr .


* sum docs and calculate if small amount is present
  PERFORM calculate_small_amount_debi
                                 TABLES   c_t_bsid_ext
                                 USING    u_kunnr
                                          u_grpkey
                                          ls_kb_betr
                                 CHANGING l_dmbtr
                                          l_flg_upay
                                          l_flg_opay
                                          l_mansp
                                          l_flg_exit
                                          l_h_ex
                                          l_s_ex
                                          ls_bsid_extk.

  CHECK l_flg_exit = ' '.


*----------------------------------------------------------------------*
* 20201215 neu
*----------------------------------------------------------------------*
* Sollen noch Reduktionen vorgenommen werden?
* nehmen Teilzahlungen raus, falls sie in der Auflistung sind
* und genau das umgekehrte vorzeichen haben
* das geht eigentlich nur, falls es keine Splitbuchungen sind
*----------------------------------------------------------------------*
  LOOP AT c_t_bsid_ext INTO ls_bsid_ext
                         WHERE
                             rebzg IS NOT INITIAL.
*20220119 welche REBZT relevant sind -regelt der FB selbst
*                           and ( rebzt eq 'Z'
*                                 or rebzt eq 'F' ).

    CALL FUNCTION 'FI_PSO_AMOUNT_FOLLOWING_ORDER'
      EXPORTING
        i_bukrs   = ls_bsid_ext-bukrs
        i_lifnr   = l_lifnr
        i_kunnr   = ls_bsid_ext-kunnr
        i_rebzg   = ls_bsid_ext-rebzg
        i_rebzj   = ls_bsid_ext-rebzj
        i_rebzz   = ls_bsid_ext-rebzz
        i_shkzg   = ls_bsid_ext-shkzg
*       I_PRELIMINARY       = ' '
*       I_BELNR   = ' '
*       I_PSOTY   = ' '
*   IMPORTING
*       E_PSOSU_HWAER       =
*       E_RE_WAER1          =
*       E_PSOSU_WAERS       =
*       E_RE_WAER2          =
*       E_AMOUNT_TEMP       =
*       E_AMOUNT_REM        =
*       E_AMOUNT_DEDU       =
*       E_AMOUNT_PART       =
      TABLES
        e_t_pso02 = lt_pso02.

    LOOP AT lt_pso02 INTO ls_pso02.
      CLEAR l_diff .

      LOOP AT c_t_bsid_ext WHERE   bukrs = ls_pso02-bukrs AND
                                   belnr = ls_bsid_ext-rebzg AND
                                   gjahr = ls_bsid_ext-rebzj AND
                                   buzei = ls_bsid_ext-rebzz.


        IF c_t_bsid_ext-shkzg = gc_char_s.
          IF ls_pso02-shkzg = gc_char_h.
            c_t_bsid_ext-dmbtr = c_t_bsid_ext-dmbtr - ls_pso02-dmbtr.
            l_diff = gc_on.
          ENDIF.
        ELSE.
          IF ls_pso02-shkzg = gc_char_s.
            c_t_bsid_ext-dmbtr = c_t_bsid_ext-dmbtr - ls_pso02-dmbtr.
            l_diff = gc_on.
          ENDIF.
        ENDIF.
        IF l_diff = gc_on.
*          c_t_bsid_ext-modif = gc_on.
          MODIFY  c_t_bsid_ext TRANSPORTING dmbtr.
        ENDIF.
      ENDLOOP.

      IF l_diff = gc_on.
        DELETE c_t_bsid_ext WHERE bukrs = ls_pso02-bukrs AND
                                  belnr = ls_pso02-belnr AND
                                  gjahr = ls_pso02-gjahr AND
                                  buzei = ls_pso02-buzei.


      ENDIF.
    ENDLOOP.
  ENDLOOP.
*----------------------------------------------------------------------*
* 003  es gibt Gutschriften mit Rechnungsbezug, die
* durch FI_PSO_AMOUNT_FOLLOWING_ORDER (für Absetzungen und Teilzahlungen)
* nicht erfasst werden ; z. B. Gutschriften über das Kassenbuch
*----------------------------------------------------------------------*
* Hinweis: es gibt auch Fälle mit einem REBZG und gleichem SHKz, zB
* aus avviso - z.B. Vollstreckungskosten(hier auch andere Kontierung,
* deswegen dann 2 Belege zur Ausbuchung ok)

* Sortierung
  SORT c_t_bsid_ext BY cpudt cputm DESCENDING.
  LOOP AT c_t_bsid_ext INTO ls_bsid_ext
                         WHERE
                             rebzg IS NOT INITIAL.
    CLEAR l_diff.
*genau eine Position
    LOOP AT c_t_bsid_ext WHERE   bukrs = ls_bsid_ext-bukrs AND
                                 belnr = ls_bsid_ext-rebzg AND
                                 gjahr = ls_bsid_ext-rebzj AND
                                 buzei = ls_bsid_ext-rebzz.


      IF ls_bsid_ext-shkzg = gc_char_s.
        IF c_t_bsid_ext-shkzg = gc_char_h.
          c_t_bsid_ext-dmbtr = c_t_bsid_ext-dmbtr - ls_bsid_ext-dmbtr.
          l_diff = gc_on.
        ENDIF.
      ELSE.
        IF c_t_bsid_ext-shkzg = gc_char_s.
          c_t_bsid_ext-dmbtr = c_t_bsid_ext-dmbtr - ls_bsid_ext-dmbtr.
          l_diff = gc_on.
        ENDIF.
      ENDIF.
      IF l_diff = gc_on.
        MODIFY  c_t_bsid_ext  TRANSPORTING dmbtr.
      ENDIF.
    ENDLOOP.
    IF l_diff = gc_on.
      DELETE c_t_bsid_ext.
    ENDIF.
  ENDLOOP.
*----------------------------------------------------------------------*
* 003  für den Fall, dass der Betrag zu dem Belege im Rechnungsbezug
*      durch Zahlung oder Gutschrift überschritten, so wird #
*      c_t_bsid_ext-dmbtr negativ, dann werden die Belege separat ausgebucht
*      ggf. sollte vorher ein Ausgleich/Kontenpflege erfolgen
*      Hier wird eine Warnung ausgegeben
*----------------------------------------------------------------------*
  LOOP AT c_t_bsid_ext WHERE dmbtr LT 0.
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    IF 1 = 2.
      MESSAGE w313.
* Zu Debitor &1 Referenz &2 liegt ein Ausgleichbeleg &3 Gjahr &4 vor
    ENDIF.
    CLEAR:
    l_var1,
    l_var2,
    l_var3,
    l_var4 .
    PERFORM message_store USING '/THKR/FI_NACHR' 'W' '313'
                                l_var1 l_var2 l_var3 l_var4
                                u_kunnr space u_grpkey.
  ENDIF.
*----------------------------------------------------------------------*
* 20201215 neu Ende
*----------------------------------------------------------------------*
*003
  IF ( p_check  = gc_on OR p_testr = gc_off ) AND
     NOT l_dmbtr     IS INITIAL.
*----------------------------------------------------------------------*
* benötigt für CpD-Daten
*----------------------------------------------------------------------*
    READ TABLE c_t_bsid_ext INDEX 1.
*----------------------------------------------------------------------*
*   post request
*----------------------------------------------------------------------*

    PERFORM post_request_debi  TABLES   c_t_bsid_ext
                               USING    c_t_bsid_ext
                                      ls_bsid_extk
                                       u_kunnr
                                       u_xcpdk
                                       u_grpkey
                                       l_dmbtr
                                       l_flg_upay
                                       l_flg_opay
                                       l_h_ex
                                       l_s_ex
                                       l_maber
                                       l_mansp
                              CHANGING
                                       l_flg_exit.


  ENDIF.


ENDFORM.                               " PROCESS_DOCS_CUSTOMER

*&---------------------------------------------------------------------*
*&      Form  DELETE_DOCS_CUSTOMER
*&---------------------------------------------------------------------*
*       Kontrolle ein Mahnbereich für alle Belege
*       nehmen alle Fälle mit Mahnsperre <> leer oder 3 raus
*       Mahnsperre werden nur für Forderungen geprüft
*       Mahnbereiche - falls gefüllt müssen sie gleich sein
*       lassen leere zu
*
*       nehmen alle Fälle mit ZZ_001 raus - PKH --> Änderung 08/2021
*       PKH nicht rausnehmen, könnte
*
*       nehmen alle Fälle mit PSOTYP 06,07,08, oder 09
*       falls zur Referenz so etwas vorliegt geht die Referenz raus
*
*       Belege aus dem RE-FX dürfen nicht ausgebucht werden,
*       das ist Belegart DI oder SN-
*&---------------------------------------------------------------------*
*       delete docs which aren't due at p_zfbdt
*----------------------------------------------------------------------*
FORM delete_docs_customer TABLES   c_t_bsid_ext STRUCTURE g_t_bsid_ext
                          USING    u_kunnr      LIKE knb1-kunnr
                                   u_grpkey     LIKE g_t_bsid_ext-grpkey
                          CHANGING c_flg_exit
                                   c_maber TYPE maber.



  DATA: l_t_check_defer  LIKE g_t_bsid_ext OCCURS 0 WITH HEADER LINE,
        l_t_check_rebzg  LIKE g_t_bsid_ext OCCURS 0 WITH HEADER LINE,
        l_t_bsid_ext_del LIKE g_t_bsid_ext OCCURS 0 WITH HEADER LINE,
        l_t_bsid_ext_due LIKE g_t_bsid_ext OCCURS 0 WITH HEADER LINE.


  DATA: l_flg_one_doc   LIKE boole-boole,
        l_belnr         LIKE bsid-belnr,
        l_gjahr         LIKE bsid-gjahr,
        l_buzei         LIKE bsid-buzei,
        l_f_check_rebzg LIKE g_t_bsid_ext,
        l_tabix         LIKE sy-tabix,
        l_lines         LIKE sy-tabix,
        l_loop          LIKE sy-tabix,
        l_var1          LIKE sy-msgv1,
        l_var2          LIKE sy-msgv2,
        l_var3          LIKE sy-msgv3,
        l_var4          LIKE sy-msgv4,
        l_dateed(10)    TYPE c.        "date edited

  DATA: l_zz_001_init TYPE /thkr/sd_vbak_zz001,
        l_maber       TYPE maber.

  CLEAR: c_flg_exit.
  CLEAR: l_maber.

*----------------------------------------------------------------------*
* keine RE-FX Belege berücksichtigen´ für LSA nicht relevant bzw. falsch (SN)
*----------------------------------------------------------------------*
*****  LOOP AT c_t_bsid_ext TRANSPORTING NO FIELDS
*****        WHERE blart = gc_blart_sn OR blart = gc_blart_di.
*****    EXIT.
*****  ENDLOOP.
*****
*****  IF sy-subrc = 0.
*****    IF g_f_flags-detail = 'X'.
*****      IF 1 = 2.
*****        MESSAGE s309 WITH u_kunnr u_grpkey .
******  Zu Debitor &1 Referenz &2 gibt es Belege aus RE-FX
*****      ENDIF.
*****      l_var1 = u_kunnr.
*****      l_var2 = u_grpkey.
*****      CLEAR l_var3.
*****      CLEAR l_var4 .
*****      PERFORM message_store USING '/THKR/FI_NACHR' 'W' '309'
*****                                  l_var1 l_var2 l_var3 l_var4
*****                                  u_kunnr space u_grpkey.
*****    ENDIF.
*****    c_flg_exit = 'X'.
*****    RETURN.
*****  ENDIF.
*----------------------------------------------------------------------*
* keine Steuer-Belege berücksichtigen, das Steuerzeile "ausgesternt"
*----------------------------------------------------------------------*
  LOOP AT c_t_bsid_ext TRANSPORTING NO FIELDS
        WHERE mwskz IS NOT INITIAL AND mwskz+1(1) <> '0'.
    EXIT.
  ENDLOOP.

  IF sy-subrc = 0.
    IF g_f_flags-detail = 'X'.
      IF 1 = 2.
        MESSAGE s314 WITH u_kunnr u_grpkey .
*  Zu Debitor &1 Referenz &2 gibt es Belege mit Steueranteil
      ENDIF.
      l_var1 = u_kunnr.
      l_var2 = u_grpkey.
      CLEAR l_var3.
      CLEAR l_var4 .
      PERFORM message_store USING '/THKR/FI_NACHR' 'W' '314'
                                  l_var1 l_var2 l_var3 l_var4
                                  u_kunnr space u_grpkey.
    ENDIF.
    c_flg_exit = 'X'.
    RETURN.
  ENDIF.
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
  LOOP AT c_t_bsid_ext .

    IF l_maber IS INITIAL AND c_t_bsid_ext-maber  IS NOT INITIAL.
      l_maber = c_t_bsid_ext-maber.
    ELSE.
*&---------------------------------------------------------------------*
*       delete docs falls mehrere MABER
*----------------------------------------------------------------------*
      IF l_maber NE c_t_bsid_ext-maber
      AND c_t_bsid_ext-maber  IS NOT INITIAL.

        IF g_f_flags-detail = 'X'.
          IF 1 = 2.
            MESSAGE s305 WITH u_kunnr u_grpkey c_t_bsid_ext-mansp.
*  Bei Debitor &1 Referenz &2 gibt es mehrere Mahnbereiche
          ENDIF.
          l_var1 = u_kunnr.
          l_var2 = u_grpkey.
          l_var3 = c_t_bsid_ext-mansp.
          CLEAR l_var4 .
          PERFORM message_store USING '/THKR/FI_NACHR' 'W' '305'
                                      l_var1 l_var2 l_var3 l_var4
                                      u_kunnr space u_grpkey.
        ENDIF.
        c_flg_exit = 'X'.
        EXIT.
      ENDIF.
    ENDIF.
*&---------------------------------------------------------------------*
*       delete docs nach Mahnsperre
*----------------------------------------------------------------------*
    IF    c_t_bsid_ext-mansp NE  gc_mansp_leer AND
          c_t_bsid_ext-mansp NE  gc_mansp_3 AND
          c_t_bsid_ext-shkzg = gc_shkzg_s.


      IF g_f_flags-detail = 'X'.
        IF 1 = 2.
          MESSAGE s303 WITH u_kunnr u_grpkey c_t_bsid_ext-mansp.
*   Zu Debitor &1 Referenz &2 gibt es einen Beleg mit Mahnsperre &3
        ENDIF.
        l_var1 = u_kunnr.
        l_var2 = u_grpkey.
        l_var3 = c_t_bsid_ext-mansp.
        CLEAR l_var4 .
        PERFORM message_store USING '/THKR/FI_NACHR' 'w' '303'
                                    l_var1 l_var2 l_var3 l_var4
                                    u_kunnr space u_grpkey.
      ENDIF.
      c_flg_exit = 'X'.
      EXIT.
    ENDIF.
*&---------------------------------------------------------------------*
*       delete docs  mit bestimmten Anordnungstyp
*----------------------------------------------------------------------*
    IF    c_t_bsid_ext-psoty = '06' OR
          c_t_bsid_ext-psoty = '07' OR
          c_t_bsid_ext-psoty = '08' OR
          c_t_bsid_ext-psoty = '09'.


      IF g_f_flags-detail = 'X'.
        IF 1 = 2.
          MESSAGE s302 WITH u_kunnr u_grpkey c_t_bsid_ext-psoty.
*   Zu Debitor &1 Referenz &2 gibt es eine Anordnung mit Typ &3
        ENDIF.
        l_var1 = u_kunnr.
        l_var2 = u_grpkey.
        l_var3 = c_t_bsid_ext-psoty.
        CLEAR l_var4 .
        PERFORM message_store USING '/THKR/FI_NACHR' 'E' '302'
                                    l_var1 l_var2 l_var3 l_var4
                                    u_kunnr space u_grpkey.
      ENDIF.
      c_flg_exit = 'X'.
      EXIT.
    ENDIF.

*----------------------------------------------------------------------*
*       delete docs which aren't due at p_zfbdt
*----------------------------------------------------------------------*
    IF c_t_bsid_ext-faedt    <= p_faedt.
***       or
***       c_t_bsid_ext-bktxt(3) =  'KB-'.  "???
*      due docs or docs of this report -> relevant -> local table
      MOVE: c_t_bsid_ext TO l_t_bsid_ext_due.
      APPEND: l_t_bsid_ext_due.
    ELSE.

*----------------------------------------------------------------------*
* die Belege werden gesammelt , für eine aussagekräftige
* Fehlermeldung
*----------------------------------------------------------------------*
      MOVE: c_t_bsid_ext TO l_t_bsid_ext_del.
      APPEND: l_t_bsid_ext_del.
    ENDIF.

  ENDLOOP.
*&---------------------------------------------------------------------*
*      falls -kein Mahnbereich ermittelbar -> Fehler Ende, da Steuerung
*      über Mahnbereich
*      Meldung
*      Abfrage bleibt auch nach Änderung : Selektionsparamter MABER, weil
*      davon auszugehen ist, dass die Forderungen in der Regel alle einen
*      Mahnbereich haben
*----------------------------------------------------------------------*
  IF l_maber IS INITIAL.
    IF g_f_flags-detail = 'X'.
      IF 1 = 2.
        MESSAGE s306 WITH u_kunnr u_grpkey c_t_bsid_ext-mansp.
*  Bei Debitor &1 Referenz &2 ist der Mahnbereich leer
      ENDIF.
      l_var1 = u_kunnr.
      l_var2 = u_grpkey.
      CLEAR: l_var3, l_var4 .
      PERFORM message_store USING '/THKR/FI_NACHR' 'W' '306'
                                  l_var1 l_var2 l_var3 l_var4
                                  u_kunnr space u_grpkey.
    ENDIF.
    c_flg_exit = 'X'.
    EXIT.
  ENDIF.

*&---------------------------------------------------------------------*
*     002 dxc Roch : Mahnbereich ist Selektionskriterium
*     Mahnbereich konnte zuerst eindeutig ermittelt werden, dann
*     Prüfung auf Selektion
*----------------------------------------------------------------------*
  IF NOT ( l_maber IN s_maber ).
* keine weitere Meldung wegen Selektion
    c_flg_exit = 'X'.
    EXIT.
  ENDIF.

*&---------------------------------------------------------------------*
* Mahnbereich ermittelt
*&---------------------------------------------------------------------*
  c_maber = l_maber.
*&---------------------------------------------------------------------*
* falls es Belege gibt, die nicht geforderte Fälligkeit haben
* ist hier Ende für diese Referenz
*----------------------------------------------------------------------*
  DESCRIBE TABLE l_t_bsid_ext_del LINES l_lines.
  IF l_lines GT 0.
    IF g_f_flags-detail = 'X'.
      IF 1 = 2.
        MESSAGE s308  WITH l_belnr l_gjahr l_buzei p_faedt.
* Zu Debitor &1 Referenz &2 gibt es mind. &3 Belege mit Fälligkeit > &4
      ENDIF.
      WRITE p_faedt TO l_dateed DD/MM/YYYY.
      l_var1 = u_kunnr.
      l_var2 = u_grpkey.
*     l_var3 = l_lines.
      WRITE l_lines TO l_var3 LEFT-JUSTIFIED.
      l_var4 = l_dateed.
      PERFORM message_store USING '/THKR/FI_NACHR' 'W' '308'
                                  l_var1 l_var2 l_var3 l_var4
                                  u_kunnr space u_grpkey.

    ENDIF.
    c_flg_exit = 'X'.
    EXIT.
  ENDIF.

*----------------------------------------------------------------------*
* replace table with due documents
*----------------------------------------------------------------------*
  REFRESH: c_t_bsid_ext.
  CLEAR: c_t_bsid_ext.
  c_t_bsid_ext[] = l_t_bsid_ext_due[].

  IF c_flg_exit = gc_off.
* Any documents left?
    DESCRIBE TABLE c_t_bsid_ext LINES l_lines.
    IF l_lines IS INITIAL.
      c_flg_exit = 'X'.
      IF g_f_flags-detail = 'X'.
        IF 1 = 2.
          MESSAGE s310  WITH  p_faedt.
*   Es liegen keine Belege mit einem Fälligkeitsdatum kleiner &1 vor
        ENDIF.
        WRITE p_faedt TO l_dateed DD/MM/YYYY.
        l_var1 = l_dateed.
        CLEAR: l_var2, l_var3, l_var4.
        PERFORM message_store USING '/THKR/FI_NACHR' 'W' '310'
                                    l_var1 l_var2 l_var3 l_var4
                                    u_kunnr space u_grpkey.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                               " DELETE_DOCS_CUSTOMER
*&---------------------------------------------------------------------*
*&      Form  SELECT_CUSTOMIZING
*&---------------------------------------------------------------------*
*       Kleinbetragstabellen
*
*----------------------------------------------------------------------*
FORM select_customizing TABLES  ct_kb_buch STRUCTURE /thkr/kb_buch
                                ct_kb_betr STRUCTURE /thkr/kb_betr
                                ct_kb_co STRUCTURE /thkr/kb_co
                                ct_t047m STRUCTURE t047m
                        USING    u_bukrs   LIKE knb1-bukrs
                        CHANGING
                                 c_hwaer   LIKE bkpf-hwaer
                                 c_gjahr   LIKE bkpf-gjahr
                                 cs_kb_buch TYPE /thkr/kb_buch
                                 cs_kb_co STRUCTURE /thkr/kb_co
                                 c_blart_string TYPE cstring
                                 c_flg_exit.

  DATA: l_f_t001 LIKE t001,
        l_var1   LIKE sy-msgv1,
        l_var2   LIKE sy-msgv2,
        l_var3   LIKE sy-msgv3,
        l_var4   LIKE sy-msgv4.

*003 ins
  TYPES: BEGIN OF t_kb_blart,
           blart TYPE blart.
  TYPES: END OF t_kb_blart.
*003 ins end

  DATA: lt_kb_blart  TYPE STANDARD TABLE OF t_kb_blart.
*----------------------------------------------------------------------*
* determine year for posting
*----------------------------------------------------------------------*
  CALL FUNCTION 'FI_PERIOD_DETERMINE'
    EXPORTING
      i_budat = p_budat
      i_bukrs = u_bukrs
    IMPORTING
      e_gjahr = c_gjahr.
*----------------------------------------------------------------------*
* alle Mahnbereiche zum Buchungskreis
*----------------------------------------------------------------------*
  SELECT * FROM t047m INTO TABLE ct_t047m
    WHERE bukrs = u_bukrs.

*----------------------------------------------------------------------*
* Steuerung zum Buchungskreis
*----------------------------------------------------------------------*
  SELECT SINGLE * FROM /thkr/kb_buch INTO cs_kb_buch
    WHERE bukrs = u_bukrs.

*----------------------------------------------------------------------*
* Beträge für die Mahnbereiche
*----------------------------------------------------------------------*
  IF ct_t047m[] IS NOT INITIAL.
    SELECT * FROM /thkr/kb_betr INTO TABLE ct_kb_betr
     FOR ALL ENTRIES IN ct_t047m WHERE maber = ct_t047m-maber.
  ENDIF.

*----------------------------------------------------------------------*
* Default CO zum Buchungskreis
*----------------------------------------------------------------------*
  SELECT SINGLE * FROM /thkr/kb_co INTO cs_kb_co
    WHERE bukrs = u_bukrs.

*----------------------------------------------------------------------*
* Belegarten Nebenforderungen
*----------------------------------------------------------------------*
  SELECT  blart FROM /thkr/kb_blart INTO TABLE lt_kb_blart.
  CONCATENATE LINES OF lt_kb_blart INTO c_blart_string SEPARATED BY gc_hash.
  CONCATENATE gc_hash c_blart_string INTO c_blart_string.


* Customizing wird geprüft für Echtlauf und Testlauf
  IF cs_kb_buch IS INITIAL OR ct_kb_betr[] IS INITIAL
    OR cs_kb_co IS INITIAL OR lt_kb_blart[] IS INITIAL.

    IF 1 = 2.
      MESSAGE e301 WITH u_bukrs.
*   Customizing zum Kleinbetrag für Buchungskreis &1 fehlt
    ENDIF.
    l_var1 = u_bukrs.
    CLEAR: l_var2, l_var3, l_var4.
    PERFORM message_store USING '/THKR/FI_NACHR' 'E' '301'
                                l_var1 l_var2 l_var3 l_var4
                                space space space.
    c_flg_exit = gc_on.
  ENDIF.
*  endif.

* get currency of company code
  CALL FUNCTION 'COMPANY_CODE_READ'
    EXPORTING
      i_bukrs = u_bukrs
    IMPORTING
      e_t001  = l_f_t001.

  c_hwaer = l_f_t001-waers.

ENDFORM.                               " SELECT_CUSTOMIZING
*&---------------------------------------------------------------------*
*&      Form  CALCULATE_SMALL_AMOUNT_DEBI
*&---------------------------------------------------------------------*
*       calculate if small amount exists
*       --> cs_bsid_ext : stellt die älteste offene HF  oder älteste For
*           dar
*----------------------------------------------------------------------*
FORM calculate_small_amount_debi
                            TABLES   u_t_bsid_ext STRUCTURE g_t_bsid_ext
                            USING    u_kunnr      LIKE knb1-kunnr
                                     u_grpkey LIKE l_t_bsid_ext-grpkey
                                     u_s_kb_betr TYPE /thkr/kb_betr
                            CHANGING c_dmbtr      LIKE bsid-dmbtr
                                     c_flg_upay   LIKE boole-boole
                                     c_flg_opay   LIKE boole-boole
                                     c_mansp      TYPE mansp
                                     c_flg_exit   LIKE boole-boole
                                     c_h_ex  TYPE xfeld
                                     c_s_ex  TYPE xfeld
                                     cs_bsid_extk STRUCTURE g_t_bsid_ext.
  DATA: l_manst  LIKE bsid-manst,
        l_manst2 LIKE bsid-manst,
        l_found  TYPE xfeld.

  DATA: l_sum_h_dmbtr LIKE bsid-dmbtr,
        l_sum_s_dmbtr LIKE bsid-dmbtr,
        l_dmbtr_min   LIKE bsid-dmbtr,
        l_lines       LIKE sy-tabix,
        l_var1        LIKE sy-msgv1,
        l_var2        LIKE sy-msgv2,
        l_var3        LIKE sy-msgv3,
        l_var4        LIKE sy-msgv4.


  CLEAR: c_h_ex, c_s_ex.
  CLEAR: c_flg_exit.
  CLEAR: l_manst, l_found.
  CLEAR:  cs_bsid_extk.
*hier müssen wir jetzt die richtige


  SORT u_t_bsid_ext BY faedt.
*--------------------------------------------------------------------
* calculate sum for s and h
* move s docs to local table
*--------------------------------------------------------------------

  LOOP AT u_t_bsid_ext.
*--------------------------------------------------------------------
* falls keine Hauptforderung vorhanden ist
*--------------------------------------------------------------------
    IF sy-tabix = 1.
      l_manst2 = u_t_bsid_ext-manst.
*      cs_bsid_extk = u_t_bsid_ext.
    ENDIF.


    CONCATENATE gc_hash u_t_bsid_ext-blart INTO DATA(ls_search).
*--------------------------------------------------------------------
* Blart ist keine Nebenforderung -bisher nichts gefunden
*--------------------------------------------------------------------
    IF  g_blart_string NS ls_search .
      IF l_found = gc_off.
        l_manst = u_t_bsid_ext-manst.
        l_found = gc_on.
      ENDIF.
    ENDIF.

*--------------------------------------------------------------------
    IF u_t_bsid_ext-shkzg = 'H'.
      l_sum_h_dmbtr = l_sum_h_dmbtr + u_t_bsid_ext-dmbtr.
*     for debit-side (H) only collect revenue types not space
      c_h_ex = gc_on.
    ELSE.
*     for credit-side (S) collect all revenue types also space
      l_sum_s_dmbtr = l_sum_s_dmbtr + u_t_bsid_ext-dmbtr.
      c_s_ex = gc_on.
    ENDIF.
*--------------------------------------------------------------------
*--------------------------------------------------------------------
* Blart ist keine Nebenforderung- haben einen Beleg der Kontierungen hat
*--------------------------------------------------------------------
*003   if  g_blart_string ns ls_search .
*      cs_bsid_extk = u_t_bsid_ext.
*    endif.
*--------------------------------------------------------------------
  ENDLOOP.
*--------------------------------------------------------------------
* keine Hauptforderung vorhanden-Mahnsperre aus dem 1. Satz
*--------------------------------------------------------------------
  IF l_found = gc_off.
    l_manst =  l_manst2.
  ENDIF.
*--------------------------------------------------------------------
*003 laut vorgabe
*-  für den Überzahlungsfall
*   Verwendung Kontierung des jüngsten DR-Beleges -nehmen entweder
*   jüngsten  Forderungs-Beleg überhaupt oder falls vorhanden
*   jüngsten  Beleg, der keine Hauptforderung ist
*   allerdings! eine Zahlung ohne Bezug ist nicht zu erwarten
*   fraglich, ob Forderungskontierung passt
*--------------------------------------------------------------------
  SORT u_t_bsid_ext BY cpudt cputm DESCENDING.

  LOOP AT u_t_bsid_ext WHERE shkzg = gc_char_s.
    IF sy-tabix = 1.
      cs_bsid_extk = u_t_bsid_ext.
    ENDIF.
    CLEAR ls_search.
    CONCATENATE gc_hash u_t_bsid_ext-blart INTO ls_search.
    IF  g_blart_string NS ls_search .
      cs_bsid_extk = u_t_bsid_ext.
      EXIT.
    ENDIF.
  ENDLOOP.

*--------------------------------------------------------------------
* kein Saldo vorhanden
*--------------------------------------------------------------------
  IF l_sum_h_dmbtr = l_sum_s_dmbtr.
* no small amount
    c_flg_exit = 'X'.
    EXIT.

  ELSEIF l_sum_s_dmbtr > l_sum_h_dmbtr.
* underpayment
    c_flg_upay = gc_on.
    c_dmbtr = l_sum_s_dmbtr - l_sum_h_dmbtr.
    IF l_manst = gc_manst_1.
      l_dmbtr_min = u_s_kb_betr-uza_3msp.
    ELSE.
      l_dmbtr_min = u_s_kb_betr-uza_omsp.
    ENDIF.
  ELSE.
* overpayment
    c_flg_opay = gc_on.
    c_dmbtr = l_sum_h_dmbtr - l_sum_s_dmbtr.
    l_dmbtr_min = u_s_kb_betr-ueza.
  ENDIF.

*

* amount smaller equal than minimum amount -> ok
  IF c_dmbtr <= l_dmbtr_min.
    IF g_f_flags-detail = 'X'.
      IF c_flg_upay = gc_on.
        WRITE c_dmbtr TO l_var1 CURRENCY g_hwaer LEFT-JUSTIFIED.
        IF 1 = 2.
          MESSAGE s466(fq) WITH l_var1 g_hwaer.
*   Es liegt eine Unterzahlung in Höhe von &1 vor
        ENDIF.
        l_var2 = g_hwaer.
        CLEAR: l_var3, l_var4.
        PERFORM message_store USING 'FQ' 'S' '466'
                                    l_var1 l_var2 l_var3 l_var4
                                    u_kunnr space u_grpkey.
      ELSEIF c_flg_opay = 'X'.
        WRITE c_dmbtr TO l_var1 CURRENCY g_hwaer LEFT-JUSTIFIED.
        IF 1 = 2.
          MESSAGE s467(fq) WITH l_var1 g_hwaer.
*   Es liegt eine Überzahlung in Höhe von &1 vor
        ENDIF.
        l_var2 = g_hwaer.
        CLEAR: l_var3, l_var4.
        PERFORM message_store USING 'FQ' 'S' '467'
                                    l_var1 l_var2 l_var3 l_var4
                                    u_kunnr space u_grpkey.
      ENDIF.
      WRITE l_dmbtr_min TO l_var1 CURRENCY g_hwaer LEFT-JUSTIFIED.
      IF 1 = 2.
        MESSAGE s469 WITH l_var1 g_hwaer.
*   Die ermittelte Kleinbetragsgrenze beträgt &1 &2
      ENDIF.
      l_var2 = g_hwaer.
      CLEAR: l_var3, l_var4.
      PERFORM message_store USING 'FQ' 'S' '469'
                                  l_var1 l_var2 l_var3 l_var4
                                  u_kunnr space u_grpkey.
    ENDIF.
  ELSE.
    c_flg_exit = 'X'.
    IF g_f_flags-detail = 'X'.
      WRITE c_dmbtr     TO l_var1 CURRENCY g_hwaer LEFT-JUSTIFIED.
      WRITE l_dmbtr_min TO l_var3 CURRENCY g_hwaer LEFT-JUSTIFIED.
      l_var2 = g_hwaer.
      l_var4 = g_hwaer.
      IF 1 = 2.
        MESSAGE s471(fq) WITH l_var1 l_var2 l_var3 l_var4.
*   Der Betrag &1 &2 liegt über der Kleinbetragsgrenze von &3 &4
      ENDIF.
      PERFORM message_store USING 'FQ' 'W' '471'
                                  l_var1 l_var2 l_var3 l_var4
                                  u_kunnr space u_grpkey.
    ENDIF.
  ENDIF.


ENDFORM.                               " CALCULATE_SMALL_AMOUNT_DEBI

*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK
*&---------------------------------------------------------------------*
FORM authority_check USING us_kb_buch TYPE /thkr/kb_buch.
* BLART:
  DATA: ls_t003    LIKE t003,
        l_dialog   LIKE boole,
        l_activity LIKE tact-actvt.

* authority check only if not testrun
  CHECK g_f_flags-testr = ' '.

* Company Code:
  CALL FUNCTION 'FI_PSO_BUKRS_AUTH_CHECK'
    EXPORTING
      i_act   = '10'             "con_act_post
      i_bukrs = p_bukrs.

  l_dialog-boole = gc_on.
  l_activity = con_act_post.


* Belegart bei Unterzahlung
  CALL FUNCTION 'FI_DOCUMENT_TYPE_DATA'
    EXPORTING
      i_blart  = us_kb_buch-uza_blart
      x_dialog = l_dialog
    IMPORTING
      e_t003   = ls_t003.

  CALL FUNCTION 'AUTHORITY_DOC_TYPE'
    EXPORTING
      i_begru = ls_t003-brgru
      i_actvt = l_activity
      i_dtype = ls_t003-blart.


* Belegart bei Überzahlung
  CALL FUNCTION 'FI_DOCUMENT_TYPE_DATA'
    EXPORTING
      i_blart  = us_kb_buch-ueza_blart
      x_dialog = l_dialog
    IMPORTING
      e_t003   = ls_t003.

  CALL FUNCTION 'AUTHORITY_DOC_TYPE'
    EXPORTING
      i_begru = ls_t003-brgru
      i_actvt = l_activity
      i_dtype = ls_t003-blart.


ENDFORM.                               " AUTHORITY_CHECK

*&---------------------------------------------------------------------*
*&      Form  POST_REQUEST_DEBI
*&---------------------------------------------------------------------*
*      lt_accounttax  -  bei Steuerkennzeichen
*      Buchungen ohne Steuerkennzeichen sind gesetzt
*
*      lt_extensions1 - Tabelle muss da sein, falls  BTE-Prozess
*      RWBAPI01 genutzt werden muss
*----------------------------------------------------------------------*
FORM post_request_debi TABLES   u_t_bsid_ext STRUCTURE g_t_bsid_ext
                        USING   u_f_bsid_ext STRUCTURE g_t_bsid_ext
                               u_bsid_extk STRUCTURE g_t_bsid_ext
                                u_kunnr      LIKE knb1-kunnr
                                u_xcpdk      LIKE kna1-xcpdk
                                u_grpkey     LIKE g_t_bsid_ext-grpkey
                                u_dmbtr      LIKE bsid-dmbtr
                                u_flg_upay   LIKE boole-boole
                                u_flg_opay   LIKE boole-boole
                                l_h_ex       TYPE xfeld
                                l_s_ex       TYPE xfeld
                                l_maber      TYPE maber
                                l_mansp      TYPE mansp
                        CHANGING

                                c_flg_exit.
  TYPES: BEGIN OF t_belnr,
           zaehler TYPE i,
           obj_key TYPE bapiache09-obj_key,   "Objektschlüssel
           bukrs   TYPE bukrs,
           belnr   TYPE belnr_d,
           gjahr   TYPE gjahr.
  TYPES: END OF t_belnr.
  FIELD-SYMBOLS: <fs_bseg> TYPE bseg,
                 <fs_bset> TYPE bset.
  DATA: ls_belnr TYPE t_belnr,
        lt_belnr TYPE STANDARD TABLE OF t_belnr.

  DATA: ls_bkpf TYPE bkpf,
        lt_bseg TYPE STANDARD TABLE OF bseg,
        lt_bset TYPE STANDARD TABLE OF bset.


  DATA: l_flg_message LIKE boole-boole,
        l_xlote       LIKE bbkpf_fm-xlote,
        l_intlotkz    LIKE bbkpf_fm-lotkz,
        l_lotkz       LIKE bbkpf_fm-lotkz,
        l_text        LIKE bbkpf_fm-bktxt,
        l_koart       LIKE payac10-koart,
        l_umsks       LIKE payac10-umsks,
        l_shkzg       LIKE bseg-shkzg,
        l_bschl_pers  LIKE bseg-bschl, "posting key customer/vendor
        l_bschl_glac  LIKE bseg-bschl, "posting key gl account
        l_msgid       LIKE sy-msgid,
        l_msgty       LIKE sy-msgty,
        l_msgno       LIKE sy-msgno,
        l_var1        LIKE sy-msgv1,
        l_var2        LIKE sy-msgv2,
        l_var3        LIKE sy-msgv3,
        l_var4        LIKE sy-msgv4.

  DATA: l_account TYPE hkont.
*Schnittstellendaten für Verbuchungs-BAPI
  DATA:
* Returnparameter des BAPIs
    l_obj_type        TYPE bapiache09-obj_type,  "Objekttyp
* Objektschlüssel erhält vom BAPI die Belegidentifikation:
* NNNNNNNNNNYYYYBBBB  N = Belegnummer, Y = GJahr, B = Buchungskreis
    l_obj_key         TYPE bapiache09-obj_key,   "Objektschlüssel
    l_obj_sys         TYPE bapiache09-obj_sys,   "log. System

* Belegkopf
    ls_documentheader TYPE bapiache09,
* falls CPD
    ls_customercpd    TYPE   bapiacpa09,

* Sachkontenpositionen
    lt_accountgl      TYPE TABLE OF bapiacgl09,
    ls_accountgl      TYPE bapiacgl09,

* Debitorenposition
    lt_accountrec     TYPE TABLE OF bapiacar09,
    ls_accountrec     TYPE bapiacar09,

* Steuerzeilen
*    lt_accounttax     type table of bapiactx09,
*    ls_accounttax     type bapiactx09,

* Betragsinformationen
    lt_currencyamount TYPE TABLE OF bapiaccr09,
    ls_currencyamount TYPE bapiaccr09.

  DATA: BEGIN OF  lt_currencyamount_glob OCCURS 0,
          zaehler        TYPE i,
          currencyamount TYPE  bapiaccr09.
  DATA: END OF lt_currencyamount_glob.
  DATA: ls_currencyamount_glob LIKE LINE OF lt_currencyamount_glob.

  DATA: BEGIN OF lt_accountgl_glob OCCURS 0,
          zaehler   TYPE i,
          accountgl TYPE  bapiacgl09.
  DATA: END OF lt_accountgl_glob.
  DATA: ls_accountgl_glob LIKE LINE OF lt_accountgl_glob.

  DATA: BEGIN OF lt_accountrec_glob OCCURS 0,
          zaehler    TYPE i,
          accountrec TYPE  bapiacar09.
  DATA: END OF lt_accountrec_glob.
  DATA: ls_accountrec_glob LIKE LINE OF lt_accountrec_glob.


* extension
*    lt_extensions1    type table of bapiacextc,
*    ls_extensions1    type  bapiacextc,

* Meldungen des BAPI's
  DATA: lt_return TYPE TABLE OF bapiret2,
        ls_return TYPE bapiret2,
        lv_error  TYPE xfeld.


  DATA:
    l_itemno           TYPE posnr_acc.           "Positionsnummer (s.u.)



  IF u_flg_opay = gc_on .
    l_account = gs_kb_buch-ueza_hkont.
  ELSE.
    "      u_flg_upay = gc_on .
    l_account = gs_kb_buch-uza_hkont.
  ENDIF.

*loop at u_t_bsid_ext.
**-----------------------------------------------------------------------
** Initialisierung Tabellen
**-----------------------------------------------------------------------
*  clear: lt_accountgl[],
**         lt_accounttax[],
*         lt_accountrec[],
*         lt_currencyamount[],
*         lt_return[].
**         lt_extensions1[].
*-----------------------------------------------------------------------
* Belegkopf
*-----------------------------------------------------------------------
  CLEAR ls_documentheader.
  ls_documentheader-bus_act    = 'RFBU'.         "Vorgang (fix)
  ls_documentheader-username   = sy-uname.       "Belegerfasser
  ls_documentheader-comp_code  = p_bukrs. "Buchungskreis
  ls_documentheader-doc_date   = p_bldat. "Belegdatum
  ls_documentheader-pstng_date = p_budat. "Buchungsdatum
  ls_documentheader-ref_doc_no = u_grpkey. "Referenznummer
  IF u_flg_upay = gc_on.
    ls_documentheader-doc_type   = gs_kb_buch-uza_blart. "Belegart
  ENDIF.
  IF u_flg_opay = gc_on.
    ls_documentheader-doc_type   = gs_kb_buch-ueza_blart. "Belegart
  ENDIF.
* text of header:
  CONCATENATE 'KB' sy-datlo p_faedt INTO l_text SEPARATED BY '-'.
  ls_documentheader-header_txt = l_text.


*** l_t_bbkpf-waers = g_hwaer. fehlt noch
*-----------------------------------------------------------------------
* falls cpd-Daten
*-----------------------------------------------------------------------
  CLEAR  ls_customercpd.
  IF u_xcpdk = 'X'.
*   fill cpd data
    ls_customercpd-name = u_f_bsid_ext-name1.
    ls_customercpd-name_2 = u_f_bsid_ext-name2.
    ls_customercpd-name_3 = u_f_bsid_ext-name3.
    ls_customercpd-name_4 = u_f_bsid_ext-name4.
    ls_customercpd-postl_code = u_f_bsid_ext-pstlz.
    ls_customercpd-city = u_f_bsid_ext-ort01.
    ls_customercpd-street = u_f_bsid_ext-stras.
    ls_customercpd-po_box = u_f_bsid_ext-pfach.
    ls_customercpd-country = u_f_bsid_ext-land1.
    IF u_f_bsid_ext-pstl2 NE space.    "Postleitzahl des Postfachs hat
      ls_customercpd-pobx_pcd = u_f_bsid_ext-pstl2."Priorität
    ENDIF.
  ENDIF.

*-----------------------------------------------------------------------
*bei dem BAPI gibt es kein Rechnungsbezug und kein Buchungsschlüssel
*-----------------------------------------------------------------------
  IF u_flg_opay = gc_on .
    l_account = gs_kb_buch-ueza_hkont.
  ELSE.
    "      u_flg_upay = gc_on .
    l_account = gs_kb_buch-uza_hkont.
  ENDIF.

  CLEAR: ls_belnr,
         lt_belnr[].

  LOOP AT u_t_bsid_ext WHERE shkzg = gc_char_h.

    ADD 1 TO ls_belnr-zaehler.
    APPEND ls_belnr TO lt_belnr.
**-----------------------------------------------------------------------
** Initialisierung Tabellen
**-----------------------------------------------------------------------
    CLEAR: lt_accountgl[],
           lt_accountrec[],
           lt_currencyamount[],
           lt_return[].

    CLEAR l_itemno.

* falls Gutschrift ohne Bezug -> dann eigene Kontierung
    IF u_t_bsid_ext-xzahl =  gc_off .
* 003 eine Kontierung aus der Zahlung zu nehmen macht
* keinen Sinn
*      or
*     ( u_t_bsid_ext-xzahl =  gc_on and  u_bsid_extk  is initial ).
*-----------------------------------------------------------------------
* Gutschriften-Kontierung ; allerdings aus Sachkontenzeile
*-----------------------------------------------------------------------
      CALL FUNCTION 'FI_DOCUMENT_READ1'
        EXPORTING
          i_docno   = u_t_bsid_ext-belnr
          i_byear   = u_t_bsid_ext-gjahr
          i_compy   = u_t_bsid_ext-bukrs
        IMPORTING
* falls wir die
          e_bkpf    = ls_bkpf
        TABLES
          t_bseg    = lt_bseg
*         T_BSEC    =
*         t_bset    = lt_bset
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc = 0.
*-----------------------------------------------------------------------
* falls es mehrere Zeilen gibt, kann man noch eine nach Kriterien ??
* bestimmen
*-----------------------------------------------------------------------
        LOOP AT lt_bseg ASSIGNING <fs_bseg> WHERE koart = gc_char_s  AND
        buzid NE gc_char_t.
          EXIT.
        ENDLOOP.
*-----------------------------------------------------------------------
* Änderung dxc Roch: 001
* bei Ausgleichbelegen -> keine Sachkontenzeile nicht bearbeiten
*-----------------------------------------------------------------------
        IF sy-subrc NE 0.
          IF 1 = 2.
            MESSAGE e311 WITH u_kunnr u_grpkey u_t_bsid_ext-belnr u_t_bsid_ext-gjahr.
* Zu Debitor &1 Referenz &2 liegt ein Ausgleichbeleg &3 Gjahr &4 vor
          ENDIF.
          l_var1 = u_kunnr.
          l_var2 = u_grpkey.
          l_var3 = u_t_bsid_ext-belnr.
          l_var4 = u_t_bsid_ext-gjahr.
          PERFORM message_store USING '/THKR/FI_NACHR' 'E' '311'
                                      l_var1 l_var2 l_var3 l_var4
                                      u_kunnr space u_grpkey.
          c_flg_exit = 'X'.
          EXIT.
        ENDIF.
*-----------------------------------------------------------------------
      ENDIF.
*-----------------------------------------------------------------------
*   Zahlungsvorgang ohne Rebzg
*   kann eigentlich nicht auftreten
* - Ersatzkontierung aus Forderung
*-----------------------------------------------------------------------
    ELSE.
*-----------------------------------------------------------------------
* haben mit u_bsid_extk den Wunschbeleg der für die Ursprungskontierung
* steht - brauchen die Sachkontenzeile
*-----------------------------------------------------------------------
      IF u_bsid_extk IS NOT INITIAL.
*-----------------------------------------------------------------------
        CALL FUNCTION 'FI_DOCUMENT_READ1'
          EXPORTING
            i_docno   = u_bsid_extk-belnr
            i_byear   = u_bsid_extk-gjahr
            i_compy   = u_bsid_extk-bukrs
          IMPORTING
* falls wir die
            e_bkpf    = ls_bkpf
          TABLES
            t_bseg    = lt_bseg
*           T_BSEC    =
*           t_bset    = lt_bset
          EXCEPTIONS
            not_found = 1
            OTHERS    = 2.
        IF sy-subrc = 0.
*-----------------------------------------------------------------------
* falls es mehrere Zeilen gibt, kann man noch eine nach Kriterien ??
* bestimmen
*-----------------------------------------------------------------------
          LOOP AT lt_bseg ASSIGNING <fs_bseg> WHERE koart = gc_char_s  AND
          buzid NE gc_char_t.
            EXIT.
          ENDLOOP.
*-----------------------------------------------------------------------
* Änderung dxc Roch: 001
* bei Ausgleichbelegen -> keine Sachkontenzeile nicht bearbeiten
*-----------------------------------------------------------------------
          IF sy-subrc NE 0.
            IF 1 = 2.
              MESSAGE e311 WITH u_kunnr u_grpkey u_bsid_extk-belnr u_bsid_extk-gjahr.
* Zu Debitor &1 Referenz &2 liegt ein Ausgleichbeleg &3 Gjahr &4 vor
            ENDIF.
            l_var1 = u_kunnr.
            l_var2 = u_grpkey.
            l_var3 = u_bsid_extk-belnr.
            l_var4 = u_bsid_extk-gjahr.
            PERFORM message_store USING '/THKR/FI_NACHR' 'E' '311'
                                        l_var1 l_var2 l_var3 l_var4
                                        u_kunnr space u_grpkey.
            c_flg_exit = 'X'.
            EXIT.
          ENDIF.
*-----------------------------------------------------------------------
        ENDIF.
*-----------------------------------------------------------------------
      ELSE.
*-----------------------------------------------------------------------
*  nicht erwartete Ausnahme : dass nur eine Zahlung übrig ist und
*  und keine Kontierung mehr ermittelt werden kann
*-----------------------------------------------------------------------

        IF 1 = 2.
          MESSAGE e312 WITH  u_t_bsid_ext-belnr u_t_bsid_ext-gjahr.
* Keine Kontierung für die Ausbuchung von Beleg &1 Gjahr &2 ermittelbar
        ENDIF.
*        l_var1 = u_kunnr.
*        l_var2 = u_grpkey.
        l_var1 = u_t_bsid_ext-belnr.
        l_var2 = u_t_bsid_ext-gjahr.
        CLEAR: l_var3, l_var4.
        PERFORM message_store USING '/THKR/FI_NACHR' 'E' '312'
                                    l_var1 l_var2 l_var3 l_var4
                                    u_kunnr space u_grpkey.
        c_flg_exit = 'X'.
        EXIT.
*-----------------------------------------------------------------------
      ENDIF.
*-----------------------------------------------------------------------
    ENDIF.
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
* Kunde im Soll
*-----------------------------------------------------------------------
    ADD 1 TO l_itemno.
    CLEAR: ls_accountrec, ls_currencyamount.

    ls_accountrec-itemno_acc     = l_itemno.       "Positionsidentifier
    ls_accountrec-customer       = u_kunnr.      "Debitor (Soll)
    ls_accountrec-item_text      = l_text. "Belegtext
*Zuordnung
    CONCATENATE u_t_bsid_ext-belnr
                u_t_bsid_ext-gjahr
                u_t_bsid_ext-buzei INTO ls_accountrec-alloc_nmbr.
    ls_accountrec-bline_date = p_zfbdt.
    ls_accountrec-dunn_block = l_mansp.
    ls_accountrec-dunn_area = l_maber.

* Betragssegment zur Sachkontenposition 1 mit identischem Identifier:
    ls_currencyamount-itemno_acc = ls_accountrec-itemno_acc.
    ls_currencyamount-currency   = g_hwaer.
* Fassung 1------------------------------------------------------------------
    ls_currencyamount-amt_doccur = u_t_bsid_ext-dmbtr.
*statt u_dmbtr


    ls_accountrec_glob-zaehler = ls_belnr-zaehler.
    ls_accountrec_glob-accountrec = ls_accountrec .
    ls_currencyamount_glob-zaehler = ls_belnr-zaehler.
    ls_currencyamount_glob-currencyamount = ls_currencyamount.

    APPEND: ls_accountrec     TO lt_accountrec,
            ls_currencyamount TO lt_currencyamount.

    APPEND: ls_accountrec_glob TO lt_accountrec_glob,
            ls_currencyamount_glob TO lt_currencyamount_glob.
*-----------------------------------------------------------------------
* Sachkonto Haben
*-----------------------------------------------------------------------
    ADD 1 TO l_itemno.
    CLEAR:   ls_accountgl,
             ls_currencyamount.
    ls_accountgl-itemno_acc      = l_itemno.
    ls_accountgl-gl_account      = l_account.
    ls_accountgl-bus_area = <fs_bseg>-gsber.
    ls_accountgl-func_area = <fs_bseg>-fkber.
    IF p_defk = gc_off.
      ls_accountgl-costcenter      = <fs_bseg>-kostl.
      ls_accountgl-orderid = <fs_bseg>-aufnr.
      ls_accountgl-profit_ctr     = <fs_bseg>-prctr.
    ELSE.
      ls_accountgl-costcenter = gs_kb_co-kostl.
    ENDIF.
    ls_accountgl-item_text       = l_text.
    ls_accountgl-cmmt_item       = <fs_bseg>-fipos.
    ls_accountgl-funds_ctr       = <fs_bseg>-fistl.
    ls_accountgl-fund            = <fs_bseg>-geber.
* Betragssegment zur Sachkontenposition 2 mit identischem Identifier:
    ls_currencyamount-itemno_acc = ls_accountgl-itemno_acc.
    ls_currencyamount-currency   = g_hwaer.
    ls_currencyamount-amt_doccur = u_t_bsid_ext-dmbtr * -1.   "Nettobetrag / Haben --> Minus

    APPEND: ls_accountgl      TO lt_accountgl,
            ls_currencyamount TO lt_currencyamount.

    ls_accountgl_glob-zaehler = ls_belnr-zaehler.
    ls_accountgl_glob-accountgl  = ls_accountgl. .
    ls_currencyamount_glob-zaehler = ls_belnr-zaehler.
    ls_currencyamount_glob-currencyamount = ls_currencyamount.

    APPEND: ls_accountgl_glob TO lt_accountgl_glob,
            ls_currencyamount_glob TO lt_currencyamount_glob.

*-----------------------------------------------------------------------
* für Rechnungsbezug Extensions1
* ls_extensions1-field1 = 'Kleinbetrag'.
*  append ls_extensions1 to lt_extensions1.
*-----------------------------------------------------------------------
*  CHECK wird immer durchlaufen
*-----------------------------------------------------------------------
*  if p_testr = 'X'.
*-----------------------------------------------------------------------
* BAPI-Aufruf
*-----------------------------------------------------------------------
    CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
      EXPORTING
        documentheader    = ls_documentheader
        customercpd       = ls_customercpd
*   IMPORTING
*       obj_type          = l_obj_type
*       obj_key           = l_obj_key
*       obj_sys           = l_obj_sys
      TABLES
        accountgl         = lt_accountgl
        accountreceivable = lt_accountrec
*       ACCOUNTPAYABLE    =
*       accounttax        = lt_accounttax
        currencyamount    = lt_currencyamount
*       CRITERIA          =
*       VALUEFIELD        =
*       extension1        = lt_extensions1
        return            = lt_return
*       PAYMENTCARD       =
*       CONTRACTITEM      =
*       EXTENSION2        =
*       REALESTATE        =
*       ACCOUNTWT         =
      .
    CLEAR lv_error.
    LOOP AT lt_return INTO ls_return WHERE
      type = 'E' OR
      type =  'X' OR
      type = 'A'.
      lv_error = gc_on.
      l_msgid = ls_return-id.
      l_msgty = ls_return-type.
      l_msgno = ls_return-number.
      l_var1 = ls_return-message_v1.
      l_var2 = ls_return-message_v2.
      l_var3 = ls_return-message_v3.
      l_var4 = ls_return-message_v4.
      PERFORM message_store USING l_msgid l_msgty l_msgno
                                  l_var1 l_var2 l_var3 l_var4
                                  u_kunnr space u_grpkey.
      .

    ENDLOOP.

    IF lv_error = gc_on.
      c_flg_exit = 'X'.
      EXIT.
    ENDIF.
    IF lv_error = gc_off.
      LOOP AT lt_return INTO ls_return WHERE
        type = 'S' .
        l_msgid = ls_return-id.
        l_msgty = ls_return-type.
        l_msgno = ls_return-number.
        l_var1 = ls_return-message_v1.
        l_var2 = ls_return-message_v2.
        l_var3 = ls_return-message_v3.
        l_var4 = ls_return-message_v4.
        PERFORM message_store USING l_msgid l_msgty l_msgno
                                    l_var1 l_var2 l_var3 l_var4
                                    u_kunnr space u_grpkey.
        .

      ENDLOOP.

    ENDIF.
  ENDLOOP.
  CHECK c_flg_exit = gc_off.

  LOOP AT u_t_bsid_ext WHERE shkzg = gc_char_s.
*-----------------------------------------------------------------------
    ADD 1 TO ls_belnr-zaehler.
    APPEND ls_belnr TO lt_belnr.
**-----------------------------------------------------------------------
** Initialisierung Tabellen
**-----------------------------------------------------------------------
    CLEAR: lt_accountgl[],
           lt_accountrec[],
           lt_currencyamount[],
           lt_return[].

    CLEAR l_itemno.
*-----------------------------------------------------------------------
* haben mit u_bsid_ext_k den Wunschbeleg der für die Ursprungskontierung
* steht - brauchen die Sachkontenzeile
*-----------------------------------------------------------------------
    CALL FUNCTION 'FI_DOCUMENT_READ1'
      EXPORTING
        i_docno   = u_t_bsid_ext-belnr
        i_byear   = u_t_bsid_ext-gjahr
        i_compy   = u_t_bsid_ext-bukrs
      IMPORTING
* falls wir die
        e_bkpf    = ls_bkpf
      TABLES
        t_bseg    = lt_bseg
*       T_BSEC    =
*       t_bset    = lt_bset
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc = 0.
*-----------------------------------------------------------------------
* falls es mehrere Zeilen gibt, kann man noch eine nach Kriterien ??
* bestimmen
*-----------------------------------------------------------------------
      LOOP AT lt_bseg ASSIGNING <fs_bseg> WHERE koart = gc_char_s  AND
      buzid NE gc_char_t.
        EXIT.
      ENDLOOP.
*-----------------------------------------------------------------------
* Änderung dxc Roch: 001
* bei Ausgleichbelegen -> keine Sachkontenzeile nicht bearbeiten
*-----------------------------------------------------------------------
      IF sy-subrc NE 0.
        IF 1 = 2.
          MESSAGE e311 WITH u_kunnr u_grpkey u_t_bsid_ext-belnr u_t_bsid_ext-gjahr.
* Zu Debitor &1 Referenz &2 liegt ein Ausgleichbeleg &3 Gjahr &4 vor
        ENDIF.
        l_var1 = u_kunnr.
        l_var2 = u_grpkey.
        l_var3 = u_t_bsid_ext-belnr.
        l_var4 = u_t_bsid_ext-gjahr.
        PERFORM message_store USING '/THKR/FI_NACHR' 'E' '311'
                                    l_var1 l_var2 l_var3 l_var4
                                    u_kunnr space u_grpkey.
        c_flg_exit = 'X'.
        EXIT.
      ENDIF.
*-----------------------------------------------------------------------
    ENDIF.
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
* Sachkonto Soll
*-----------------------------------------------------------------------
    ADD 1 TO l_itemno.
    CLEAR:   ls_accountgl,
             ls_currencyamount.
    ls_accountgl-itemno_acc      = l_itemno.
    ls_accountgl-gl_account      = l_account.
    ls_accountgl-bus_area = <fs_bseg>-gsber.
    ls_accountgl-func_area = <fs_bseg>-fkber.
    IF p_defk = gc_off.
      ls_accountgl-costcenter      = <fs_bseg>-kostl.
      ls_accountgl-orderid = <fs_bseg>-aufnr.
      ls_accountgl-profit_ctr     = <fs_bseg>-prctr.
    ELSE.
      ls_accountgl-costcenter = gs_kb_co-kostl.
    ENDIF.
    ls_accountgl-item_text       = l_text.
    ls_accountgl-cmmt_item       = <fs_bseg>-fipos.
    ls_accountgl-funds_ctr       = <fs_bseg>-fistl.
    ls_accountgl-fund            = <fs_bseg>-geber.
* Betragssegment zur Sachkontenposition 2 mit identischem Identifier:
    ls_currencyamount-itemno_acc = ls_accountgl-itemno_acc.
    ls_currencyamount-currency   = g_hwaer.
    ls_currencyamount-amt_doccur = u_t_bsid_ext-dmbtr .   "Nettobetrag / Haben --> Minus

    APPEND: ls_accountgl      TO lt_accountgl,
            ls_currencyamount TO lt_currencyamount.

    ls_accountgl_glob-zaehler = ls_belnr-zaehler.
    ls_accountgl_glob-accountgl  = ls_accountgl. .
    ls_currencyamount_glob-zaehler = ls_belnr-zaehler.
    ls_currencyamount_glob-currencyamount = ls_currencyamount.


    APPEND: ls_accountgl_glob TO lt_accountgl_glob,
            ls_currencyamount_glob TO lt_currencyamount_glob.
*-----------------------------------------------------------------------
* Kunde im Haben - dann hier Zeile 2
*-----------------------------------------------------------------------
    ADD 1 TO l_itemno.
    CLEAR: ls_accountrec, ls_currencyamount.

    ls_accountrec-itemno_acc     = l_itemno.       "Positionsidentifier
    ls_accountrec-customer       = u_kunnr.      "Debitor (Soll)

    ls_accountrec-item_text      = l_text. "Belegtext
*Zuordnung
    CONCATENATE u_t_bsid_ext-belnr
                u_t_bsid_ext-gjahr
                u_t_bsid_ext-buzei INTO ls_accountrec-alloc_nmbr.
    ls_accountrec-bline_date = p_zfbdt.
    ls_accountrec-dunn_block = l_mansp.
    ls_accountrec-dunn_area = l_maber.

* Betragssegment zur Sachkontenposition 1 mit identischem Identifier:
    ls_currencyamount-itemno_acc = ls_accountrec-itemno_acc.
    ls_currencyamount-currency   = g_hwaer.
* Fassung 1------------------------------------------------------------------
*    ls_currencyamount-amt_doccur = u_dmbtr * -1 .
    ls_currencyamount-amt_doccur = u_t_bsid_ext-dmbtr * -1.


    APPEND: ls_accountrec     TO lt_accountrec,
            ls_currencyamount TO lt_currencyamount.

    ls_accountrec_glob-zaehler = ls_belnr-zaehler.
    ls_accountrec_glob-accountrec = ls_accountrec .
    ls_currencyamount_glob-zaehler = ls_belnr-zaehler.
    ls_currencyamount_glob-currencyamount = ls_currencyamount.

    APPEND: ls_accountrec_glob TO lt_accountrec_glob,
            ls_currencyamount_glob TO lt_currencyamount_glob.
*-----------------------------------------------------------------------
* für Rechnungsbezug Extensions1
* ls_extensions1-field1 = 'Kleinbetrag'.
*  append ls_extensions1 to lt_extensions1.
*-----------------------------------------------------------------------
*  CHECK wird immer durchlaufen
*-----------------------------------------------------------------------
*  if p_testr = 'X'.
*-----------------------------------------------------------------------
* BAPI-Aufruf
*-----------------------------------------------------------------------
    CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
      EXPORTING
        documentheader    = ls_documentheader
        customercpd       = ls_customercpd
*   IMPORTING
*       obj_type          = l_obj_type
*       obj_key           = l_obj_key
*       obj_sys           = l_obj_sys
      TABLES
        accountgl         = lt_accountgl
        accountreceivable = lt_accountrec
*       ACCOUNTPAYABLE    =
*       accounttax        = lt_accounttax
        currencyamount    = lt_currencyamount
*       CRITERIA          =
*       VALUEFIELD        =
*       extension1        = lt_extensions1
        return            = lt_return
*       PAYMENTCARD       =
*       CONTRACTITEM      =
*       EXTENSION2        =
*       REALESTATE        =
*       ACCOUNTWT         =
      .
    CLEAR lv_error.
    LOOP AT lt_return INTO ls_return WHERE
      type = 'E' OR
      type =  'X' OR
      type = 'A'.
      lv_error = gc_on.
      l_msgid = ls_return-id.
      l_msgty = ls_return-type.
      l_msgno = ls_return-number.
      l_var1 = ls_return-message_v1.
      l_var2 = ls_return-message_v2.
      l_var3 = ls_return-message_v3.
      l_var4 = ls_return-message_v4.
      PERFORM message_store USING l_msgid l_msgty l_msgno
                                  l_var1 l_var2 l_var3 l_var4
                                  u_kunnr space u_grpkey.
    ENDLOOP.

    IF lv_error = gc_on.
      c_flg_exit = 'X'.
      EXIT.
    ENDIF.
    IF lv_error = gc_off.
      LOOP AT lt_return INTO ls_return WHERE
        type = 'S' .
        l_msgid = ls_return-id.
        l_msgty = ls_return-type.
        l_msgno = ls_return-number.
        l_var1 = ls_return-message_v1.
        l_var2 = ls_return-message_v2.
        l_var3 = ls_return-message_v3.
        l_var4 = ls_return-message_v4.
        PERFORM message_store USING l_msgid l_msgty l_msgno
                                    l_var1 l_var2 l_var3 l_var4
                                    u_kunnr space u_grpkey.
      ENDLOOP.

    ENDIF.
  ENDLOOP.
  CHECK c_flg_exit = gc_off. " dxc Roch mit Änderung 001
*-----------------------------------------------------------------------
* BAPI-Aufruf POST
*-----------------------------------------------------------------------
  IF p_testr =  gc_off.
    IF g_flg_post = 'X'.

      LOOP AT lt_belnr INTO ls_belnr.

        CLEAR: lt_accountgl[],
             lt_accountrec[],
             lt_currencyamount[],
             lt_return[].

        LOOP AT lt_currencyamount_glob INTO ls_currencyamount_glob WHERE zaehler = ls_belnr-zaehler.
          ls_currencyamount = ls_currencyamount_glob-currencyamount.
          APPEND ls_currencyamount TO lt_currencyamount.
        ENDLOOP.
        LOOP AT lt_accountgl_glob INTO ls_accountgl_glob WHERE zaehler = ls_belnr-zaehler.
          ls_accountgl = ls_accountgl_glob-accountgl.
          APPEND ls_accountgl TO lt_accountgl.
        ENDLOOP.
        LOOP AT lt_accountrec_glob INTO ls_accountrec_glob WHERE zaehler = ls_belnr-zaehler.
          ls_accountrec =  ls_accountrec_glob-accountrec.
          APPEND ls_accountrec TO lt_accountrec.
        ENDLOOP.

        CLEAR:  l_obj_type,
                l_obj_key,
                l_obj_sys.


        CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
          EXPORTING
            documentheader    = ls_documentheader
            customercpd       = ls_customercpd
          IMPORTING
            obj_type          = l_obj_type
            obj_key           = l_obj_key
            obj_sys           = l_obj_sys
          TABLES
            accountgl         = lt_accountgl
            accountreceivable = lt_accountrec
*           ACCOUNTPAYABLE    =
*           accounttax        = lt_accounttax
            currencyamount    = lt_currencyamount
*           CRITERIA          =
*           VALUEFIELD        =
*           extension1        = lt_extensions1
            return            = lt_return
*           PAYMENTCARD       =
*           CONTRACTITEM      =
*           EXTENSION2        =
*           REALESTATE        =
*           ACCOUNTWT         =
          .
        CLEAR lv_error.
        LOOP AT lt_return INTO ls_return WHERE
          type = 'E' OR
          type =  'X' OR
          type = 'A'.
          lv_error = gc_on.
          l_msgid = ls_return-id.
          l_msgty = ls_return-type.
          l_msgno = ls_return-number.
          l_var1 = ls_return-message_v1.
          l_var2 = ls_return-message_v2.
          l_var3 = ls_return-message_v3.
          l_var4 = ls_return-message_v4.
          PERFORM message_store USING l_msgid l_msgty l_msgno
                                      l_var1 l_var2 l_var3 l_var4
                                      u_kunnr space u_grpkey.
          .

        ENDLOOP.

        IF lv_error = gc_on.
          ROLLBACK WORK.
          c_flg_exit = 'X'.
          EXIT.
        ENDIF.
*

*eigene erfolgsmeldung mit Objektschlüssel
* Objektschlüssel erhält vom BAPI die Belegidentifikation:
* NNNNNNNNNNYYYYBBBB  N = Belegnummer, Y = GJahr, B = Buchungskreis
*    l_obj_key         type bapiache09-obj_key,   "Objektschlüssel

        IF lv_error = gc_off.
          ls_belnr-obj_key = l_obj_key.
          ls_belnr-belnr = l_obj_key(10).
          ls_belnr-bukrs = l_obj_key+10(4).
          ls_belnr-gjahr = l_obj_key+14(4).
          MODIFY lt_belnr FROM ls_belnr.
        ENDIF.
      ENDLOOP.

      IF lv_error = gc_off.
        COMMIT WORK AND WAIT.


        CLEAR: l_var3, l_var4.
        LOOP AT lt_belnr INTO  ls_belnr.
          IF 1 = 2.
            MESSAGE s307 WITH ls_belnr-obj_key(10) ls_belnr-obj_key+10(4).
          ENDIF.
          l_var1 = ls_belnr-obj_key(10).
          l_var2 = ls_belnr-obj_key+10(4).
          PERFORM message_store USING '/THKR/FI_NACHR' 'S' '307'
                                      l_var1 l_var2 l_var3 l_var4
                                     u_kunnr space u_grpkey.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.



ENDFORM.                               " POST_REQUEST_DEBI
*&---------------------------------------------------------------------*
*& Form get_kb_buch
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> L_MABER
*&      <-- LS_KB_BUCH
*&---------------------------------------------------------------------*
FORM get_kb_betr  USING    u_maber TYPE maber
                  CHANGING cs_kb_betr  TYPE /thkr/kb_betr.
  READ TABLE gt_kb_betr INTO cs_kb_betr  WITH KEY maber = u_maber.
ENDFORM.
