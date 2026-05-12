*&---------------------------------------------------------------------*
*& Include          /THKR/LFI_APAR_SEPA_MANDATEF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  authority_check_mandate
*&---------------------------------------------------------------------*
FORM authority_check_mandate USING VALUE(i_bukrs) TYPE bukrs
                                   VALUE(i_actvt) TYPE activ_auth
                          CHANGING e_power TYPE xfeld.
  AUTHORITY-CHECK OBJECT 'F_MANDATE' ID 'BUKRS' FIELD i_bukrs
                                     ID 'ACTVT' FIELD i_actvt.
  CASE sy-subrc.
    WHEN 0.      e_power = 'X'.
    WHEN OTHERS. e_power = space.
  ENDCASE.
ENDFORM. " authority_check_mandate
*&---------------------------------------------------------------------*
*& Form authority_check_mandate_kunnr
*&---------------------------------------------------------------------*
FORM authority_check_mandate_kunnr USING VALUE(i_kunnr) TYPE kunnr
                                   VALUE(i_actvt) TYPE activ_auth
                          CHANGING e_power TYPE xfeld.
  DATA: kna1 TYPE kna1.
  PERFORM db_read_kna1 USING i_kunnr CHANGING kna1.

  CLEAR e_power.

  AUTHORITY-CHECK OBJECT 'F_KNA1_APP'
    ID 'ACTVT' FIELD i_actvt
    ID 'APPKZ' DUMMY.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  IF kna1-begru <> space.
    AUTHORITY-CHECK OBJECT 'F_KNA1_BED'
      ID 'BRGRU' FIELD kna1-begru
      ID 'ACTVT' FIELD i_actvt.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'F_KNA1_GEN'
    ID 'ACTVT' FIELD i_actvt.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  IF kna1-ktokd <> space.
    AUTHORITY-CHECK OBJECT 'F_KNA1_GRP'
      ID 'KTOKD' FIELD kna1-ktokd
      ID 'ACTVT' FIELD i_actvt.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
  ENDIF.
*all check passed, assign e_power and return
  e_power = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  db_read_t001
*&---------------------------------------------------------------------*
*       Liest Buchungskreistabelle T001
*----------------------------------------------------------------------*
FORM db_read_t001 USING VALUE(i_bukrs) TYPE bukrs
               CHANGING es_t001 TYPE t001.
  STATICS: st_buffer LIKE es_t001 OCCURS 0 WITH HEADER LINE.
  DATA: l_tabix TYPE sytabix.

  CLEAR es_t001.

  CHECK i_bukrs IS NOT INITIAL.
  IF i_bukrs <> st_buffer-bukrs.
*   Wurden die Daten bereits gelesen?
    READ TABLE st_buffer WITH KEY bukrs = i_bukrs BINARY SEARCH.
    IF sy-subrc <> 0.
      l_tabix = sy-tabix.
      CLEAR st_buffer.
      SELECT SINGLE * FROM t001 INTO st_buffer WHERE bukrs = i_bukrs.
      IF sy-subrc = 0.
        INSERT st_buffer INDEX l_tabix.
      ENDIF.
    ENDIF. " sy-subrc <> 0
  ENDIF. " i_bukrs <> st_buffer-bukrs

  es_t001 = st_buffer.
ENDFORM. " db_read_t001

*&---------------------------------------------------------------------*
*&      Form  plausi_zbukr
*&---------------------------------------------------------------------*
FORM plausi_zbukr USING VALUE(i_zbukr) TYPE dzbukr
               CHANGING es_return TYPE bapiret1.
  DATA: ls_t001 TYPE t001.

  CLEAR es_return.

* Does company code I_ZBUKR exist?
  PERFORM db_read_t001 USING i_zbukr CHANGING ls_t001.
  IF ls_t001 IS INITIAL.
    PERFORM set_message USING 'E' 'F2' '219' i_zbukr '' '' ''
                     CHANGING es_return.
    IF 1 = 2.   " Only for the where-used list
      MESSAGE e219(f2).                                     "#EC *
    ENDIF.
  ENDIF. " ls_t001 is initial
ENDFORM. " plausi_zbukr

*&---------------------------------------------------------------------*
*&      Form  plausi_kunnr_zbukr
*&---------------------------------------------------------------------*
*       Check the plausibility of the combination KUNNR - ZBUKR
*----------------------------------------------------------------------*
FORM plausi_kunnr_zbukr USING VALUE(i_kunnr) TYPE kunnr
                              VALUE(i_zbukr) TYPE dzbukr
                     CHANGING es_return TYPE bapiret1.
  DATA: lt_knb1     TYPE knb1 OCCURS 0 WITH HEADER LINE,
        ls_t042     TYPE t042,
        l_bupa_flag,
        l_found     TYPE xfeld.
  DATA: ls_kna1 TYPE kna1,
        lt_lfb1 TYPE lfb1 OCCURS 0 WITH HEADER LINE.

  CLEAR es_return.
  CHECK gs_fix_data-rec_id IS INITIAL.
  PERFORM non_apar_partner_check USING i_kunnr CHANGING l_bupa_flag.
  IF NOT ( sy-tcode = 'XD01' OR sy-tcode = 'FD01'
    OR l_bupa_flag = 'X' ). "Business partner in customer role
* Is I_ZBUKR a paying company code for I_KUNNR?
    SELECT * FROM knb1 INTO TABLE lt_knb1 WHERE kunnr = i_kunnr.
    LOOP AT lt_knb1.
      PERFORM db_read_t042 USING lt_knb1-bukrs CHANGING ls_t042.
      IF ls_t042-zbukr = i_zbukr.
        l_found = 'X'.
        EXIT. " loop
      ENDIF.
    ENDLOOP. " at lt_knb1
    IF l_found IS INITIAL.
*     is I_ZBUKR a paying company code for the linked creditor I_KUNNR?
      SELECT SINGLE * FROM kna1 INTO ls_kna1 WHERE kunnr = i_kunnr.
      IF ls_kna1-lifnr IS NOT INITIAL.
        SELECT * FROM lfb1 INTO TABLE lt_lfb1
          WHERE lifnr = ls_kna1-lifnr.
        LOOP AT lt_lfb1.
          PERFORM db_read_t042 USING lt_lfb1-bukrs CHANGING ls_t042.
          IF ls_t042-zbukr = i_zbukr.
            l_found = 'X'.
            EXIT. " loop
          ENDIF.
        ENDLOOP. " at lt_lfb1
      ENDIF.
    ENDIF.

    IF l_found IS INITIAL.
      PERFORM set_message USING 'E' 'FIN_SEPA' '006'
                                i_zbukr i_kunnr ls_kna1-lifnr ''
                       CHANGING es_return.
      IF 1 = 2.   " Only for the where-used list
        MESSAGE e006(fin_sepa).                             "#EC *
      ENDIF.
    ENDIF. " l_found is initial
  ENDIF.

ENDFORM. " plausi_kunnr_zbukr

*&---------------------------------------------------------------------*
*&      Form  db_read_t042
*&---------------------------------------------------------------------*
*       Liest Parameter zum Zahlungsverkehr T042
*----------------------------------------------------------------------*
FORM db_read_t042 USING VALUE(i_bukrs) TYPE bukrs
               CHANGING es_t042 TYPE t042.
  STATICS: st_buffer LIKE es_t042 OCCURS 0 WITH HEADER LINE.
  DATA: l_tabix TYPE sytabix.

  CLEAR es_t042.

  CHECK i_bukrs IS NOT INITIAL.
  IF i_bukrs <> st_buffer-bukrs.
*   Wurden die Daten bereits gelesen?
    READ TABLE st_buffer WITH KEY bukrs = i_bukrs BINARY SEARCH.
    IF sy-subrc <> 0.
      l_tabix = sy-tabix.
      CLEAR st_buffer.
      SELECT SINGLE * FROM t042 INTO st_buffer WHERE bukrs = i_bukrs.
      IF sy-subrc = 0.
        INSERT st_buffer INDEX l_tabix.
      ENDIF.
    ENDIF. " sy-subrc <> 0
  ENDIF. " i_bukrs <> st_buffer-bukrs

  es_t042 = st_buffer.
ENDFORM. " db_read_t042

*&---------------------------------------------------------------------*
*&      Form  db_read_kna1
*&---------------------------------------------------------------------*
FORM db_read_kna1 USING VALUE(i_kunnr) TYPE kunnr
               CHANGING es_kna1 TYPE kna1.
  STATICS: st_buffer LIKE es_kna1 OCCURS 0 WITH HEADER LINE.
  DATA: l_tabix TYPE sytabix,
        ls_kna1 TYPE kna1.

  CLEAR es_kna1.

  CHECK i_kunnr IS NOT INITIAL.
  IF i_kunnr <> st_buffer-kunnr.
*   Wurden die Daten bereits gelesen?
    READ TABLE st_buffer WITH KEY kunnr = i_kunnr BINARY SEARCH.
    IF sy-subrc <> 0.
      l_tabix = sy-tabix.
      CLEAR st_buffer.
      SELECT SINGLE * FROM kna1 INTO st_buffer WHERE kunnr = i_kunnr.
      IF sy-subrc = 0.
        IF cl_iav_mapping_util=>is_iav_active( ) EQ 'X'.
* EhP6 IAV
          CLEAR ls_kna1.
          CALL METHOD cl_iav_mapping_util=>get_address_as_kna1
            EXPORTING
              iv_adrnr                 = st_buffer-adrnr
              iv_application_component = 'SD_CUSTOMER'
            CHANGING
              cs_kna1                  = ls_kna1.
          st_buffer-name1 = ls_kna1-name1.
          st_buffer-ort01 = ls_kna1-ort01.
        ENDIF.
        INSERT st_buffer INDEX l_tabix.
      ENDIF.
    ENDIF. " sy-subrc <> 0
  ENDIF. " i_kunnr <> st_buffer-kunnr

  es_kna1 = st_buffer.
ENDFORM. " db_read_kna1

*&---------------------------------------------------------------------*
*&      Form  db_read_bsec
*&---------------------------------------------------------------------*
FORM db_read_bsec USING VALUE(i_docref) TYPE fsepa_ref_belnr
               CHANGING es_bsec TYPE bsec.
  STATICS: st_buffer LIKE es_bsec OCCURS 0 WITH HEADER LINE.
  DATA: ls_bsec TYPE bsec.

  DATA:
    BEGIN OF l_id,
      bukrs TYPE bukrs,
      belnr TYPE belnr_d,
      gjahr TYPE gjahr,
      buzei TYPE buzei,
    END OF l_id.

  CLEAR es_bsec.

  CHECK i_docref IS NOT INITIAL.

  l_id = i_docref.
  IF l_id-bukrs <> st_buffer-bukrs
    OR l_id-belnr <> st_buffer-belnr
    OR l_id-gjahr <> st_buffer-gjahr
    OR l_id-buzei <> st_buffer-buzei.
*   Wurden die Daten bereits gelesen?
    READ TABLE st_buffer WITH KEY bukrs = l_id-bukrs
      belnr = l_id-belnr  gjahr = l_id-gjahr  buzei = l_id-buzei.
    IF sy-subrc <> 0.
      CLEAR st_buffer.
      SELECT SINGLE * FROM bsec INTO st_buffer
        WHERE bukrs = l_id-bukrs
          AND belnr = l_id-belnr
          AND gjahr = l_id-gjahr
          AND buzei = l_id-buzei.
      IF sy-subrc = 0.
        APPEND st_buffer TO st_buffer.
      ENDIF.
    ENDIF. " sy-subrc <> 0
  ENDIF.

  es_bsec = st_buffer.
ENDFORM. " db_read_bsec

*&---------------------------------------------------------------------*
*&      Form  db_read_vbsec
*&---------------------------------------------------------------------*
FORM db_read_vbsec USING VALUE(i_docref) TYPE fsepa_ref_belnr
               CHANGING es_vbsec TYPE vbsec.
  STATICS: st_buffer LIKE es_vbsec OCCURS 0 WITH HEADER LINE.
  DATA: ls_vbsec TYPE vbsec.

  DATA:
    BEGIN OF l_id,
      ausbk TYPE bukrs,
      belnr TYPE belnr_d,
      gjahr TYPE gjahr,
      buzei TYPE buzei,
    END OF l_id.

  CLEAR es_vbsec.

  CHECK i_docref IS NOT INITIAL.

  l_id = i_docref.
  IF l_id-ausbk <> st_buffer-ausbk
    AND l_id-belnr <> st_buffer-belnr
    AND l_id-gjahr <> st_buffer-gjahr
    AND l_id-buzei <> st_buffer-buzei.
*   Wurden die Daten bereits gelesen?
    READ TABLE st_buffer WITH KEY ausbk = l_id-ausbk
      belnr = l_id-belnr  gjahr = l_id-gjahr  buzei = l_id-buzei.
    IF sy-subrc <> 0.
      CLEAR st_buffer.
*       try VBSEC (Beleg nur vorerfasst?)
      SELECT SINGLE * FROM vbsec INTO st_buffer
        WHERE ausbk = l_id-ausbk
          AND belnr = l_id-belnr
          AND gjahr = l_id-gjahr
          AND buzei = l_id-buzei.
      IF sy-subrc = 0.
        APPEND st_buffer TO st_buffer.
      ENDIF.
    ENDIF. " sy-subrc <> 0
  ENDIF.

  es_vbsec = st_buffer.
ENDFORM. " db_read_vbsec

*&---------------------------------------------------------------------*
*&      Form  db_read_t005
*&---------------------------------------------------------------------*
*       Liest Laendertabelle T005
*----------------------------------------------------------------------*
FORM db_read_t005 USING VALUE(i_land1) TYPE land1
               CHANGING es_t005 TYPE t005.
  STATICS: st_buffer LIKE es_t005 OCCURS 0 WITH HEADER LINE.
  DATA: l_tabix TYPE sytabix.

  CLEAR es_t005.

  CHECK i_land1 IS NOT INITIAL.
  IF i_land1 <> st_buffer-land1.
*   Wurden die Daten bereits gelesen?
    READ TABLE st_buffer WITH KEY land1 = i_land1 BINARY SEARCH.
    IF sy-subrc <> 0.
      l_tabix = sy-tabix.
      CLEAR st_buffer.
      SELECT SINGLE * FROM t005 INTO st_buffer WHERE land1 = i_land1.
      IF sy-subrc = 0.
        INSERT st_buffer INDEX l_tabix.
      ENDIF.
    ENDIF. " sy-subrc <> 0
  ENDIF. " i_land1 <> st_buffer-land1

  es_t005 = st_buffer.
ENDFORM. " db_read_t005

*&---------------------------------------------------------------------*
*&      Form  bankkey_determine
*&---------------------------------------------------------------------*
*       Ermittelt den Bankschluessel
*----------------------------------------------------------------------*
FORM bankkey_determine USING VALUE(i_banks) TYPE banks
                             VALUE(i_bankl) TYPE bankk
                             VALUE(i_bankn) TYPE bankn
                    CHANGING e_bankkey TYPE bankk.
  DATA: ls_t005 TYPE t005.

  CLEAR e_bankkey.
  PERFORM db_read_t005 USING i_banks CHANGING ls_t005.
  CHECK ls_t005 IS NOT INITIAL.
  IF ls_t005-bnkey = '2'.
    e_bankkey = i_bankn.
  ELSE.
    e_bankkey = i_bankl.
  ENDIF.
ENDFORM. " bankkey_determine

*&---------------------------------------------------------------------*
*&      Form  check_field_filled
*&---------------------------------------------------------------------*
FORM check_field_filled USING VALUE(is_mandate)  TYPE sepa_mandate
                              VALUE(i_fieldname) TYPE fieldname
                     CHANGING es_return TYPE bapiret1.
  DATA: l_lfieldname   TYPE dfies-lfieldname,              " \TP 1121996
        l_field_descri TYPE dfies-scrtext_l.               " \TP 1121996
  FIELD-SYMBOLS <fs> TYPE any.

  CLEAR es_return.
  ASSIGN COMPONENT i_fieldname OF STRUCTURE is_mandate TO <fs>.
  IF sy-subrc <> 0.
    PERFORM set_message USING 'E' 'SEPA' 009
                              'CHECK_FIELD_FILLED' sy-repid '' ''
                     CHANGING es_return.
    IF 1 = 2.   " Only for the where-used list
      MESSAGE e009(sepa).                                   "#EC *
    ENDIF.
  ELSEIF <fs> IS INITIAL.
    l_lfieldname = i_fieldname.                            " \TP 1121996
    PERFORM field_description_get USING 'SEPA_MANDATE'     " \TP 1121996
                                        l_lfieldname       " \TP 1121996
                               CHANGING l_field_descri.    " \TP 1121996
*   if is_mandate-status = gc_status-active.
    PERFORM set_message USING 'E' 'SEPA' 102
                            l_field_descri '' '' ''      " \TP 1121996
                     CHANGING es_return.
*   endif.
    IF 1 = 2.   " Only for the where-used list
      MESSAGE e102(sepa).                                   "#EC *
    ENDIF.
  ENDIF.
ENDFORM. " check_field_filled

*&---------------------------------------------------------------------*
*&      Form  NON_APAR_IBAN_CHECKED
*&---------------------------------------------------------------------*
*&      Has IBAN already been checked by external application?
*&      Implemented for IS-H with call-back
*&      Implemented for IS-H and IS-M with call-back
FORM non_apar_iban_checked USING p_kunnr   TYPE kunnr    "begin n1870729
                                 p_iban    TYPE iban
                        CHANGING p_checked TYPE xfeld.

* IS-H business partner
  STATICS:
    l_ish_check_active TYPE boolean.
  DATA:
    l_ish_fname        TYPE rs38l_fnam
                       VALUE 'ISH_SEPA_MNDT_IBAN_CHECKED'.

  DATA: lr_badi_iban_check TYPE REF TO psm_fm_ci_core_sepa, "N2089963
        lr_badi_fi_check   TYPE REF TO fi_sepa_mandate.

* General partner check (IBAN)                              "N2089963
  GET BADI lr_badi_fi_check.
  CALL BADI lr_badi_fi_check->iban_bic
    EXPORTING
      i_kunnr = p_kunnr
      i_iban  = p_iban
    CHANGING
      c_found = p_checked.

  CHECK p_checked IS INITIAL.

* IS-H business partner
  IF l_ish_check_active IS INITIAL.
    CALL FUNCTION 'FUNCTION_EXISTS'
      EXPORTING
        funcname = l_ish_fname
      EXCEPTIONS
        OTHERS   = 1.
    IF sy-subrc IS INITIAL.
      l_ish_check_active = 'X'.
    ELSE.
      l_ish_check_active = '-'.
    ENDIF.
  ENDIF.
  IF l_ish_check_active EQ 'X'.
    CALL FUNCTION l_ish_fname
      EXPORTING
        id_customer = p_kunnr
        id_iban     = p_iban
      IMPORTING
        ef_checked  = p_checked.
  ENDIF.                                                   "end n1870729

  CHECK p_checked IS INITIAL.                            "begin n1932735

* IS-M business partner
  STATICS:
    l_ism_check_active TYPE boolean.
  DATA:
    l_ism_fname        TYPE rs38l_fnam
                       VALUE 'ISM_SEPA_MNDT_IBAN_CHECKED'.

  IF l_ism_check_active IS INITIAL.
    CALL FUNCTION 'FUNCTION_EXISTS'
      EXPORTING
        funcname = l_ism_fname
      EXCEPTIONS
        OTHERS   = 1.
    IF sy-subrc IS INITIAL.
      l_ism_check_active = 'X'.
    ELSE.
      l_ism_check_active = '-'.
    ENDIF.
  ENDIF.
  IF l_ism_check_active EQ 'X'.
    CALL FUNCTION l_ism_fname
      EXPORTING
        id_customer = p_kunnr
        id_iban     = p_iban
      IMPORTING
        ef_checked  = p_checked.
  ENDIF.                                                   "end n1932735

  CHECK p_checked IS INITIAL.

* CVI: customer sepa mandate
  STATICS:
    lv_func_exists TYPE boolean.
  DATA:
    lv_func_name TYPE rs38l-name VALUE 'CVIS_SEPA_IBAN_CHECK'.

  IF lv_func_exists IS INITIAL.
    CALL FUNCTION 'FUNCTION_EXISTS'
      EXPORTING
        funcname = lv_func_name
      EXCEPTIONS
        OTHERS   = 1.
    IF sy-subrc IS INITIAL.
      lv_func_exists = 'X'.
    ELSE.
      lv_func_exists = '-'.
    ENDIF.
  ENDIF.
  IF lv_func_exists EQ 'X'.
    CALL FUNCTION lv_func_name
      EXPORTING
        id_customer = p_kunnr
        id_iban     = p_iban
      IMPORTING
        ef_checked  = p_checked.
  ENDIF.

  CHECK p_checked IS INITIAL.                              "begin N2089963

* IS-PS partner
* As of EhP6 the Public Sector Supplement for revenue types
* support SEPA mandates. The bank details for these revenue
* types are stored in table KNEA and not always in KNBK.
  IF cl_psm_core_switch_check=>psm_fm_ci_core_rev_4( ) IS NOT INITIAL.
    IF p_kunnr IS NOT INITIAL AND gs_fix_data-snd_iban IS INITIAL.
      TRY.
          GET BADI lr_badi_iban_check.
        CATCH cx_badi_not_implemented.                  "#EC NO_HANDLER
        CATCH cx_badi_initial_reference.                "#EC NO_HANDLER
      ENDTRY.
      IF lr_badi_iban_check IS NOT INITIAL.
        CALL BADI lr_badi_iban_check->check_iban
          EXPORTING
            i_kunnr = p_kunnr
            i_iban  = p_iban
          CHANGING
            c_found = p_checked.
      ENDIF.
    ENDIF.
  ENDIF.                                                   "end N2089963

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  NON_APAR_PARTNER_CHECK
*&---------------------------------------------------------------------*
*&      Check if a non-APAR-partner is being handled right now
*&---------------------------------------------------------------------*
FORM non_apar_partner_check USING p_kunnr CHANGING p_flag.

* integration of FI SEPA Mandate into FS Business Partner
  STATICS:
    lv_func_checked TYPE boole_d,
    lv_func_exists  TYPE boole_d,
    lv_last_kunnr   TYPE kunnr,
    lv_last_result  TYPE boole_d.
  DATA:
    lv_func_name   LIKE rs38l-name VALUE 'CVIS_SEPA_CUSTOMER_CHECK',
    lv_partner_tmp TYPE boole_d.
  CONSTANTS:
    true         TYPE boole_d VALUE 'X'.

  IF lv_func_checked IS INITIAL.
    lv_func_checked = true.
    CALL FUNCTION 'FUNCTION_EXISTS'
      EXPORTING
        funcname = lv_func_name
      EXCEPTIONS
        OTHERS   = 2.
    IF sy-subrc = 0.
      lv_func_exists = true.
    ENDIF.
  ENDIF.
  IF NOT lv_func_exists IS INITIAL.
    IF p_kunnr NE lv_last_kunnr AND p_kunnr NE space.       "nte1854371
      lv_last_kunnr = p_kunnr.
      CLEAR lv_last_result.
      CALL FUNCTION lv_func_name
        EXPORTING
          iv_customer    = lv_last_kunnr
        IMPORTING
          ev_cust_temp   = lv_partner_tmp
        EXCEPTIONS
          cust_not_found = 1.
      IF sy-subrc = 0 AND lv_partner_tmp = true.
        p_flag         = true.
        lv_last_result = true.
      ENDIF.
    ELSE.
      p_flag = lv_last_result.
    ENDIF.
  ENDIF.

  CHECK p_flag IS INITIAL.

* IS-H-business-partner
  STATICS:
    ish_partner_checked,
    ish_partner_active,
    ish_last_kunnr      TYPE kunnr,
    ish_last_flag.
  DATA:
    ish_partner_fname LIKE rs38l-name VALUE 'ISH_SEPA_MNDT_CUSTOMER_CHECK',
    ish_partner_tmp   TYPE boole_d.

  IF ish_partner_checked IS INITIAL.
    ish_partner_checked = 'X'.
    CALL FUNCTION 'FUNCTION_EXISTS'
      EXPORTING
        funcname = ish_partner_fname
      EXCEPTIONS
        OTHERS   = 2.
    IF sy-subrc = 0.
      ish_partner_active = 'X'.
    ENDIF.
  ENDIF.
  IF NOT ish_partner_active IS INITIAL.
    IF p_kunnr NE ish_last_kunnr AND p_kunnr NE space.
      ish_last_kunnr = p_kunnr.
      CLEAR ish_last_flag.
      CALL FUNCTION ish_partner_fname
        EXPORTING
          id_customer = ish_last_kunnr
        IMPORTING
          ef_tmp      = ish_partner_tmp
        EXCEPTIONS
          not_found   = 2.
      IF sy-subrc = 0 AND ish_partner_tmp = 'X'.
        p_flag = ish_last_flag = 'X'.
      ENDIF.
    ELSE.
      p_flag = ish_last_flag.
    ENDIF.
  ENDIF.

ENDFORM.                                         "NON_APAR_PARTNER_CHECK

*&---------------------------------------------------------------------*
*&      Form  plausi_iban_bic
*&---------------------------------------------------------------------*
FORM plausi_iban_bic USING VALUE(i_kunnr) TYPE kunnr
                           VALUE(i_iban)  TYPE iban
                           VALUE(i_bic)   TYPE swift
                  CHANGING es_return TYPE bapiret1.
  DATA: ls_knbk            TYPE knbk,
        ls_bnka            TYPE bnka,
        l_bankkey          TYPE bankk,
        l_iban             TYPE iban,
        lt_iban            LIKE TABLE OF tiban,
        l_tiban            TYPE tiban,
        l_found            TYPE xfeld,
        lr_badi_iban_check TYPE REF TO psm_fm_ci_core_sepa,
        lt_knbk            TYPE TABLE OF knbk.              "1969797

  STATICS: s_plausi_iban_bic(10),
           s_customizing_read.

  CLEAR es_return.

* Read customizing for SWIFT/BIC check
  IF s_customizing_read IS INITIAL.                         "1997183
    s_customizing_read = 'X'.
    CALL FUNCTION 'SEPA_CUSTOMIZING_READ'
      EXPORTING
        i_anwnd           = 'F'
        i_parameter_id    = 'PLAUSI_IBAN_BIC'
      IMPORTING
        e_parameter_value = s_plausi_iban_bic
      EXCEPTIONS
        not_activ         = 1
        OTHERS            = 2.
    CHECK sy-subrc = 0.
    IF s_plausi_iban_bic NE 'X' AND s_plausi_iban_bic NE 'ENABLED'.
      CLEAR s_plausi_iban_bic.
    ENDIF.
  ENDIF.                                                    "1997183

* Check 1 - has the data been provided/checked by calling transaction?
  CHECK gs_fix_data-snd_bic IS INITIAL
    OR gs_fix_data-snd_iban IS INITIAL.

* Check 1a - IBAN checked by external application (IS-H)?      "n1870729
  PERFORM non_apar_iban_checked USING i_kunnr               "n1870729
                                      i_iban                "n1870729
                             CHANGING l_found.              "n1870729
  CHECK l_found IS INITIAL.                                 "n1870729

* Check 2 - Does I_KUNNR have a bank detail with I_IBAN?
  IF i_kunnr IS NOT INITIAL AND gs_fix_data-snd_iban IS INITIAL.
*    select * from knbk into table lt_knbk where kunnr = i_kunnr. "1969797
* First read bank buffer, if empty read from database             "1875266
    CALL FUNCTION 'FI_SEPA_MANDATE_BANK_BUF_GET'                  "1875266
      TABLES
        bank_data = lt_knbk.
    IF lt_knbk IS INITIAL.                                  "1875266
      SELECT * FROM knbk INTO TABLE lt_knbk WHERE kunnr = i_kunnr. "1875266
    ENDIF.                                                  "1875266
    LOOP AT lt_knbk INTO ls_knbk.                           "1969797
      PERFORM bankkey_determine USING ls_knbk-banks
                                      ls_knbk-bankl
                                      ls_knbk-bankn
                             CHANGING l_bankkey.
      CALL FUNCTION 'READ_IBAN_EXT'
        EXPORTING
          i_banks = ls_knbk-banks
          i_bankl = l_bankkey
          i_bankn = ls_knbk-bankn
          i_bkont = ls_knbk-bkont
          i_bkref = ls_knbk-bkref
        IMPORTING
          e_iban  = l_iban.
      IF l_iban = i_iban.
        l_found = 'X'.
        CALL FUNCTION 'READ_BANK_ADDRESS'                          "1875266
          EXPORTING
            bank_country = ls_knbk-banks
            bank_number  = l_bankkey                         "2165416
          IMPORTING
            bnka_wa      = ls_bnka
          EXCEPTIONS
            not_found    = 1
            OTHERS       = 2.
*        perform bnka_get using ls_knbk-banks ls_knbk-bankl ls_knbk-bankn
*                changing ls_bnka.                                 "1969797
        IF s_plausi_iban_bic IS INITIAL.                    "1997183
          IF ls_bnka-swift = i_bic.
            EXIT.
          ENDIF.
        ELSE.
          IF ls_bnka-swift(8) = i_bic(8).
            EXIT.
          ENDIF.
        ENDIF.                                              "1997183
      ENDIF.
    ENDLOOP.                                                "1969797
*    ENDSELECT. " * from knbk into ls_knbk where kunnr = i_kunnr
    IF l_found IS INITIAL.
      CLEAR ls_knbk.
    ENDIF.
  ENDIF.

* Check has been moved to the end of FORM 'non_apar_iban_checked'
** Check 3 - Is this a Public Sector partner?
** As of EhP6 the Public Sector Supplement for revenue types
** support SEPA mandates. The bank details for these revenue
** types are stored in table KNEA and not always in KNBK.
*  IF l_found IS INITIAL AND i_kunnr IS NOT INITIAL AND
*    gs_fix_data-snd_iban IS INITIAL AND
*    cl_psm_core_switch_check=>psm_fm_ci_core_rev_4( ) IS NOT INITIAL.
*    TRY.
*        GET BADI lr_badi_iban_check.
*      CATCH cx_badi_not_implemented.                    "#EC NO_HANDLER
*      CATCH cx_badi_initial_reference.                  "#EC NO_HANDLER
*    ENDTRY.
*    IF lr_badi_iban_check IS NOT INITIAL.
*      CALL BADI lr_badi_iban_check->check_iban
*        EXPORTING
*          i_kunnr = i_kunnr
*          i_iban  = i_iban
*        CHANGING
*          c_found = l_found.
*    ENDIF.
*  ENDIF.

  IF l_found IS INITIAL AND gs_fix_data-snd_iban IS INITIAL.
    PERFORM set_message USING 'E' 'SEPA' '055' i_kunnr i_iban '' ''
                     CHANGING es_return.
    EXIT.
    IF 1 = 2.   " Only for the where-used list
      MESSAGE e055(sepa).                                   "#EC *
    ENDIF.
  ENDIF.

  IF NOT i_bic IS INITIAL AND gs_fix_data-snd_bic IS INITIAL.
*   Do I_IBAN and I_BIC fit together?
    CALL FUNCTION 'READ_BANK_ADDRESS'                      "1875266
      EXPORTING
        bank_country = ls_knbk-banks
        bank_number  = l_bankkey                     "2165416
      IMPORTING
        bnka_wa      = ls_bnka
      EXCEPTIONS
        not_found    = 1
        OTHERS       = 2.
*    perform bnka_get using ls_knbk-banks ls_knbk-bankl ls_knbk-bankn
*                  changing ls_bnka.
    IF s_plausi_iban_bic IS INITIAL.
      IF ls_bnka-swift <> i_bic.
        PERFORM set_message USING 'E' 'SEPA' '056' i_iban i_bic '' ''
                         CHANGING es_return.
        IF 1 = 2.   " Only for the where-used list
          MESSAGE e056(sepa).                               "#EC *
        ENDIF.
      ENDIF.
    ELSE.
      IF ls_bnka-swift(8) <> i_bic(8).
        PERFORM set_message USING 'E' 'SEPA' '056' i_iban i_bic '' ''
                         CHANGING es_return.
        IF 1 = 2.   " Only for the where-used list
          MESSAGE e056(sepa).                               "#EC *
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF. " l_found is initial
ENDFORM. " plausi_iban_bic

*&---------------------------------------------------------------------*
*&      Form  plausi_kunnr
*&---------------------------------------------------------------------*
FORM plausi_kunnr USING VALUE(i_kunnr) TYPE kunnr
               CHANGING es_return TYPE bapiret1.
  DATA: ls_kna1     TYPE kna1,
        l_bupa_flag.
  CLEAR es_return.

  PERFORM db_read_kna1 USING i_kunnr CHANGING ls_kna1.
  PERFORM non_apar_partner_check USING i_kunnr CHANGING l_bupa_flag.
* check create transaction from debitor or business partner dialog
  IF NOT ( sy-tcode = 'XD01' OR sy-tcode = 'FD01'
    OR l_bupa_flag = 'X' ). "Business partner in customer role
    IF ls_kna1 IS INITIAL.
      PERFORM set_message USING 'E' 'F2' '153' i_kunnr '' '' ''
                       CHANGING es_return.
      IF 1 = 2.   " Only for the where-used list
        MESSAGE e153(f2).                                   "#EC *
      ENDIF.
      RETURN. " form
    ENDIF. " ls_kna1 is initial
  ENDIF.

ENDFORM. " plausi_kunnr

*&---------------------------------------------------------------------*
*&      Form  field_description_get
*&---------------------------------------------------------------------*
FORM field_description_get USING VALUE(i_tabname) TYPE tabname
                                 VALUE(i_fldname) TYPE dfies-lfieldname
                        CHANGING e_description TYPE dfies-scrtext_l.
  STATICS: BEGIN OF st_buffer OCCURS 0,
             tabname     LIKE i_tabname,
             fieldname   LIKE i_fldname,
             description LIKE e_description,
           END OF st_buffer.
  DATA: ls_dfies TYPE dfies,
        l_tabix  TYPE sytabix.

  CLEAR e_description.
  CHECK i_tabname IS NOT INITIAL AND i_fldname IS NOT INITIAL.
  IF i_tabname <> st_buffer-tabname
  OR i_fldname <> st_buffer-fieldname.
*   Wurden die Daten bereits gelesen?
    READ TABLE st_buffer WITH KEY tabname   = i_tabname
                                  fieldname = i_fldname BINARY SEARCH.
    IF sy-subrc <> 0.
      l_tabix = sy-tabix.
      CLEAR st_buffer.
      st_buffer-tabname   = i_tabname.
      st_buffer-fieldname = i_fldname.
      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname    = i_tabname
          lfieldname = i_fldname
          langu      = sy-langu
        IMPORTING
          dfies_wa   = ls_dfies
        EXCEPTIONS
          OTHERS     = 1.
      CASE sy-subrc.
        WHEN 0.
          IF ls_dfies-scrtext_l IS NOT INITIAL.
            st_buffer-description = ls_dfies-scrtext_l.
          ELSEIF ls_dfies-scrtext_m IS NOT INITIAL.
            st_buffer-description = ls_dfies-scrtext_m.
          ELSEIF ls_dfies-scrtext_s IS NOT INITIAL.
            st_buffer-description = ls_dfies-scrtext_s.
          ELSEIF ls_dfies-reptext IS NOT INITIAL.
            st_buffer-description = ls_dfies-reptext.
          ELSEIF ls_dfies-fieldtext IS NOT INITIAL.
            st_buffer-description = ls_dfies-fieldtext.
          ELSE.
            CONCATENATE i_tabname '-' i_fldname
              INTO st_buffer-description.
          ENDIF.
        WHEN OTHERS.
          CONCATENATE i_tabname '-' i_fldname
            INTO st_buffer-description.
      ENDCASE. " sy-subrc
      INSERT st_buffer INDEX l_tabix.
    ENDIF. " sy-subrc <> 0
  ENDIF. " i_tabname <> st_buffer-tabname or ...

  e_description = st_buffer-description.
ENDFORM. " field_description_get

*&---------------------------------------------------------------------*
*&      Form  set_message
*&---------------------------------------------------------------------*
FORM set_message USING VALUE(i_msgty) TYPE symsgty
                       VALUE(i_msgid) TYPE symsgid
                       VALUE(i_msgno) TYPE symsgno
                       VALUE(i_msgv1) TYPE any
                       VALUE(i_msgv2) TYPE any
                       VALUE(i_msgv3) TYPE any
                       VALUE(i_msgv4) TYPE any
              CHANGING es_message TYPE bapiret1.
  CLEAR es_message.
  es_message-type       = i_msgty.
  es_message-id         = i_msgid.
  es_message-number     = i_msgno.
  es_message-message_v1 = i_msgv1.
  es_message-message_v2 = i_msgv2.
  es_message-message_v3 = i_msgv3.
  es_message-message_v4 = i_msgv4.
  MESSAGE ID i_msgid TYPE i_msgty NUMBER i_msgno
        WITH i_msgv1 i_msgv2 i_msgv3 i_msgv4
        INTO es_message-message.
ENDFORM. " set_message

*&---------------------------------------------------------------------*
*&      Form  check_field_content
*&---------------------------------------------------------------------*
FORM check_field_content USING VALUE(is_mandate)   TYPE sepa_mandate
                               VALUE(i_fieldname)  TYPE fieldname
                               VALUE(i_fieldvalue) TYPE any
                      CHANGING es_return TYPE bapiret1.
  DATA: l_lfieldname   TYPE dfies-lfieldname,              " \TP 1121996
        l_field_descri TYPE dfies-scrtext_l.               " \TP 1121996
  FIELD-SYMBOLS <fs> TYPE any.

  CLEAR es_return.
  ASSIGN COMPONENT i_fieldname OF STRUCTURE is_mandate TO <fs>.
  IF sy-subrc <> 0.
    PERFORM set_message USING 'E' 'SEPA' 009
                              'CHECK_FIELD_CONTENT' sy-repid '' ''
                     CHANGING es_return.
    IF 1 = 2.   " Only for the where-used list
      MESSAGE e009(sepa).                                   "#EC *
    ENDIF.
  ELSEIF <fs> <> i_fieldvalue.
    l_lfieldname = i_fieldname.                            " \TP 1121996
    PERFORM field_description_get USING 'SEPA_MANDATE'     " \TP 1121996
                                        l_lfieldname       " \TP 1121996
                               CHANGING l_field_descri.    " \TP 1121996
    PERFORM set_message USING 'E' 'SEPA' 100
                              l_field_descri               " \TP 1121996
                              i_fieldvalue '' ''
                     CHANGING es_return.
    IF 1 = 2.   " Only for the where-used list
      MESSAGE e100(sepa).                                   "#EC *
    ENDIF.
  ENDIF.
ENDFORM. " check_field_content



*&---------------------------------------------------------------------*
*&      Form  plausi_iban_bic_bsec
*&---------------------------------------------------------------------*
FORM plausi_iban_bic_bseg USING VALUE(i_docref)  TYPE fsepa_ref_belnr
                                VALUE(i_iban)    TYPE iban
                                VALUE(i_bic)     TYPE swift
                       CHANGING es_return TYPE bapiret1.    "N2109583

  DATA: ls_bsec      TYPE bsec,
        ls_vbsec     TYPE vbsec,
        ls_bnka      TYPE bnka,
        ls_fix_data  TYPE sepa_mandate,
        ls_bank_data TYPE bsec.

  CLEAR: ls_bnka.

  IF gs_fix_data-snd_iban IS INITIAL.

    PERFORM db_read_bsec USING i_docref CHANGING ls_bsec.

    IF ls_bsec IS INITIAL. "try vbsec
      PERFORM db_read_vbsec USING gh_docref CHANGING ls_vbsec.
      MOVE-CORRESPONDING ls_vbsec TO ls_bsec.
    ENDIF.

    IF ls_bsec IS NOT INITIAL.

      CALL FUNCTION 'READ_IBAN_EXT'
        EXPORTING
          i_banks = ls_bsec-banks
          i_bankl = ls_bsec-bankl
          i_bankn = ls_bsec-bankn
          i_bkont = ls_bsec-bkont
          i_bkref = ls_bsec-bkref
        IMPORTING
          e_iban  = ls_fix_data-snd_iban.

      CALL FUNCTION 'READ_BANK_ADDRESS'
        EXPORTING
          bank_country = ls_bsec-banks
          bank_number  = ls_bsec-bankl
        IMPORTING
          bnka_wa      = ls_bnka
        EXCEPTIONS
          not_found    = 1
          OTHERS       = 2.
      ls_fix_data-snd_bic = ls_bnka-swift.

    ENDIF.

    IF ls_fix_data-snd_iban IS INITIAL. "get from document buffer

      CALL FUNCTION 'FI_SEPA_MANDATE_BANK_BSEC_GET' "try document buffer
        IMPORTING
          bank_data_line = ls_bank_data.

      IF ls_bank_data IS NOT INITIAL.

        CALL FUNCTION 'READ_IBAN_EXT'
          EXPORTING
            i_banks = ls_bank_data-banks
            i_bankl = ls_bank_data-bankl
            i_bankn = ls_bank_data-bankn
            i_bkont = ls_bank_data-bkont
            i_bkref = ls_bank_data-bkref
          IMPORTING
            e_iban  = ls_fix_data-snd_iban.

        CALL FUNCTION 'READ_BANK_ADDRESS'
          EXPORTING
            bank_country = ls_bank_data-banks
            bank_number  = ls_bank_data-bankl
          IMPORTING
            bnka_wa      = ls_bnka
          EXCEPTIONS
            not_found    = 1
            OTHERS       = 2.
        ls_fix_data-snd_bic = ls_bnka-swift.

      ENDIF.

    ENDIF.

  ELSE.

    ls_fix_data = gs_fix_data.

  ENDIF.

  IF ls_fix_data-snd_iban <> i_iban.

    PERFORM set_message USING 'E' 'FIN_SEPA' '012' i_iban '' '' ''
                     CHANGING es_return.
    EXIT.
    IF 1 = 2.   " only for the where-used list
      MESSAGE e012(fin_sepa).                               "#EC *
    ENDIF.

  ELSE.

    IF ls_fix_data-snd_bic <> i_bic.

      PERFORM set_message USING 'E' 'FIN_SEPA' '014' i_bic '' '' ''
                       CHANGING es_return.
      EXIT.
      IF 1 = 2.   " only for the where-used list
        MESSAGE e014(fin_sepa).                             "#EC *
      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.
