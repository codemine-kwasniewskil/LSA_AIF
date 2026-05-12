PROGRAM zrggbr000 .
*---------------------------------------------------------------------*
*                                                                     *
*   Regeln: EXIT-Formpool for Uxxx-Exits                              *
*                                                                     *
*   This formpool is used by SAP for demonstration purposes only.     *
*                                                                     *
*   Note: If you define a new user exit, you have to enter your       *
*         user exit in the form routine GET_EXIT_TITLES.              *
*                                                                     *
*---------------------------------------------------------------------*
INCLUDE fgbbgd00.               "Data types


*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*
*    PLEASE INCLUDE THE FOLLOWING "TYPE-POOL"  AND "TABLES" COMMANDS  *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM         *
*TYPE-POOLS: GB002. " TO BE INCLUDED IN
*TABLES: BKPF,      " ANY SYSTEM THAT
*        BSEG,      " HAS 'FI' INSTALLED
*        COBL,
*        GLU1.

"{ Begin ENHO DIMP_GENERAL_RGGBR000 IS-A DIMP_GENERAL }
*{   INSERT         KA5K001798                                        1
TYPE-POOLS: gb002.
TABLES: cnmmdates.
*}   INSERT
"{ End ENHO DIMP_GENERAL_RGGBR000 IS-A DIMP_GENERAL }

*ENHANCEMENT-POINT RGGBR000_01 SPOTS ES_RGGBR000 STATIC.
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*


*----------------------------------------------------------------------*
*       FORM GET_EXIT_TITLES                                           *
*----------------------------------------------------------------------*
*       returns name and title of all available standard-exits         *
*       every exit in this formpool has to be added to this form.      *
*       You have to specify a parameter type in order to enable the    *
*       code generation program to determine correctly how to          *
*       generate the user exit call, i.e. how many and what kind of    *
*       parameter(s) are used in the user exit.                        *
*       The following parameter types exist:                           *
*                                                                      *
*       TYPE                Description              Usage             *
*    ------------------------------------------------------------      *
*       C_EXIT_PARAM_NONE   Use no parameter         Subst. and Valid. *
*                           except B_RESULT                            *
*       C_EXIT_PARAM_CLASS  Use a type as parameter  Subst. and Valid  *
*----------------------------------------------------------------------*
*  -->  EXIT_TAB  table with exit-name and exit-titles                 *
*                 structure: NAME(5), PARAM(1), TITEL(60)
*----------------------------------------------------------------------*
FORM get_exit_titles TABLES etab.

  DATA: BEGIN OF exits OCCURS 50,
          name(5)   TYPE c,
          param     LIKE c_exit_param_none,
          title(60) TYPE c,
        END OF exits.
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*  EXITS-NAME  = 'U101'.
*  EXITS-PARAM = C_EXIT_PARAM_CLASS.
*  EXITS-TITLE = TEXT-100.                 "Posting date check
*  APPEND EXITS.

  exits-name  = 'U100'.
  exits-param = c_exit_param_none.        "Complete data used in exit.
  exits-title = TEXT-101.                 "Posting date check
  APPEND exits.

* forms for SAP_EIS
  exits-name  = 'US001'.                  "single validation: only one
  exits-param = c_exit_param_none.        "data record used
  exits-title = TEXT-102.                 "Example EIS
  APPEND exits.

  exits-name  = 'UM001'.                  "matrix validation:
  exits-param = c_exit_param_class.       "complete data used in exit.
  exits-title = TEXT-103.                 "Example EIS
  APPEND exits.

  exits-name  = 'U500'.
  exits-param = c_exit_param_none.
  exits-title = TEXT-500.                 "Posting date check
  APPEND exits.

  exits-name = 'U600'.
  exits-param = c_exit_param_none.
  exits-title = TEXT-600.
  APPEND exits.

  exits-name = 'U601'.
  exits-param = c_exit_param_none.
  exits-title = TEXT-601.
  APPEND exits.

  exits-name = 'U602'.
  exits-param = c_exit_param_none.
  exits-title = TEXT-602.
  APPEND exits.

  exits-name = 'U603'.
  exits-param = c_exit_param_none.
  exits-title = TEXT-603.
  APPEND exits.

  exits-name = 'U604'.
  exits-param = c_exit_param_none.
  exits-title = TEXT-604.
  APPEND exits.

  exits-name = 'U605'.
  exits-param = c_exit_param_none.
  exits-title = TEXT-605.
  APPEND exits.


  exits-name = 'U606'.
  exits-param = c_exit_param_none.
  exits-title = TEXT-606.
  APPEND exits.

***********************************************************************
** EXIT EXAMPLES FROM PUBLIC SECTOR INDUSTRY SOLUTION
**
** PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINE
** TO ENABLE PUBLIC SECTOR EXAMPLE SUBSTITUTION EXITS
***********************************************************************
  INCLUDE rggbr_ps_titles.

***********************************************************************
** EXIT EXAMPLES FROM Argentina Legal Change - Law Res 177
***********************************************************************
  INCLUDE rggbs_ar_titles.

  REFRESH etab.
  LOOP AT exits.
    etab = exits.
    APPEND etab.
  ENDLOOP.

ENDFORM.                    "GET_EXIT_TITLES

*eject
*----------------------------------------------------------------------*
*       FORM U100                                                      *
*----------------------------------------------------------------------*
*       Example of an exit for a boolean rule                          *
*       This exit can be used in FI for callup points 1,2 or 3.        *
*----------------------------------------------------------------------*
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*
FORM u100  USING b_result.

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*
*   IF SY-DATUM = BKPF-BUDAT.
*     B_RESULT  = B_TRUE.
*  ELSE.
*    B_RESULT  = B_FALSE.
*  ENDIF.

  DATA: tmp_datum LIKE sy-datum.    "{ ENHO DIMP_GENERAL_RGGBR000 IS-A DIMP_GENERAL }

*ENHANCEMENT-POINT RGGBR000_02 SPOTS ES_RGGBR000 STATIC.


  "{ Begin ENHO DIMP_GENERAL_RGGBR000 IS-A DIMP_GENERAL }
  tmp_datum = cnmmdates-badat + 10.
  IF cnmmdates-bdter > tmp_datum.
    b_result = b_true.
  ENDIF.
  "{ End ENHO DIMP_GENERAL_RGGBR000 IS-A DIMP_GENERAL }

*ENHANCEMENT-POINT RGGBR000_03 SPOTS ES_RGGBR000.


ENDFORM.                                                    "U100

*eject
*----------------------------------------------------------------------*
*       FORM U101                                                      *
*----------------------------------------------------------------------*
*       Example of an exit using the complete data from one            *
*       multi-line rule.                                               *
*       This exit is intended for use from callup point 3, in FI.      *
*                                                                      *
*       If account 400000 is used, then account 399999 must be posted  *
*       to in another posting line.                                    *
*----------------------------------------------------------------------*
*  -->  BOOL_DATA   The complete posting data.                         *
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*FORM u101 USING    bool_data TYPE gb002_015
*          CHANGING B_RESULT.
*  DATA: B_ACC_400000_USED LIKE D_BOOL VALUE 'F'.
*
*  B_RESULT = B_TRUE.
** Has account 400000 has been used?
*  LOOP AT BOOL_DATA-BSEG INTO BSEG
*                 WHERE HKONT  = '0000400000'.
*     B_ACC_400000_USED = B_TRUE.
*     EXIT.
*  ENDLOOP.
*
** Check that account 400000 has been used.
*  CHECK B_ACC_400000_USED = B_TRUE.
*
*  B_RESULT = B_FALSE.
*  LOOP AT BOOL_DATA-BSEG INTO BSEG
*                 WHERE HKONT  = '0000399999'.
*     B_RESULT = B_TRUE.
*     EXIT.
* ENDLOOP.
*
*ENDFORM.

*eject
*----------------------------------------------------------------------*
*       FORM US001
*----------------------------------------------------------------------*
*       Example of an exit for a boolean rule in SAP-EIS
*       for aspect 001 (single validation).
*       one data record is transfered in structure CF<asspect>
*----------------------------------------------------------------------
*       Attention: for any FORM one has to make an entry in the
*       form GET_EXIT_TITLES at the beginning of this include
*----------------------------------------------------------------------*
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*
FORM us001 USING b_result.

*TABLES CF001.                                 "table name aspect 001
*
*  IF ( CF001-SPART = '00000001' OR
*       CF001-GEBIE = '00000001' ) AND
*       CF001-ERLOS >= '1000000'.
*
**   further checks ...
*
*    B_RESULT  = B_TRUE.
*  ELSE.
*
**   further checks ...
*
*    B_RESULT  = B_FALSE.
*  ENDIF.

ENDFORM.                                                    "US001

*eject
*----------------------------------------------------------------------*
*       FORM UM001
*----------------------------------------------------------------------*
*       Example of an exit for a boolean rule in SAP-EIS
*       for aspect 001 (matrix validation).
*       Data is transfered in BOOL_DATA:
*       BOOL_DATA-CF<aspect> is intern table of structure CF<asspect>
*----------------------------------------------------------------------
*       Attention: for any FORM one has to make an entry in the
*       form GET_EXIT_TITLES at the beginning of this include
*----------------------------------------------------------------------*
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*
FORM um001 USING bool_data    "TYPE GB002_<boolean class of aspect 001>
           CHANGING b_result.

*DATA: LC_CF001 LIKE CF001.
*DATA: LC_COUNT TYPE I.

*  B_RESULT = B_TRUE.
*  CLEAR LC_COUNT.
*  process data records in BOOL_DATA
*  LOOP AT BOOL_DATA-CF001 INTO LC_CF001.
*    IF LC_CF001-SPART = '00000001'.
*      ADD 1 TO LC_COUNT.
*      IF LC_COUNT >= 2.
**       division '00000001' may only occur once !
*        B_RESULT = B_FALSE.
*        EXIT.
*      ENDIF.
*    ENDIF.
*
**   further checks ....
*
*  ENDLOOP.

ENDFORM.                                                    "UM001


***********************************************************************
** EXIT EXAMPLES FROM PUBLIC SECTOR INDUSTRY SOLUTION
**
** PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINE
** TO ENABLE PUBLIC SECTOR EXAMPLE SUBSTITUTION EXITS
***********************************************************************
*INCLUDE rggbr_ps_forms.

***********************************************************************
** EXIT EXAMPLES FROM Argentina Legal Change - Law Res 177
***********************************************************************
INCLUDE rggbs_ar_forms.


FORM u500
  CHANGING b_result.

  DATA: ls_bseg   TYPE bseg,
        ls_but020 TYPE but020,
        ls_adrc   TYPE adrc.

  b_result = b_true.

  IF bseg-lifnr IS NOT INITIAL.

    SELECT SINGLE * FROM but020 INTO ls_but020
      WHERE partner = bseg-lifnr.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM adrc INTO ls_adrc
         WHERE  addrnumber = ls_but020-addrnumber.
      IF sy-subrc = 0.

        IF ls_adrc-city1 IS INITIAL.

          b_result = b_false.
          RETURN.
        ENDIF.

        IF ls_adrc-post_code1 IS INITIAL.
          b_result = b_false.
          RETURN.
        ENDIF.

        IF ls_adrc-street IS INITIAL.
          b_result = b_false.
          RETURN.
        ENDIF.

      ENDIF.

    ENDIF.

  ELSEIF bseg-kunnr IS NOT INITIAL.

    SELECT SINGLE * FROM but020 INTO ls_but020
        WHERE partner = bseg-kunnr.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM adrc INTO ls_adrc
         WHERE  addrnumber = ls_but020-addrnumber.
      IF sy-subrc = 0.

        IF ls_adrc-city1 IS INITIAL.

          b_result = b_false.
          RETURN.
        ENDIF.

        IF ls_adrc-post_code1 IS INITIAL.
          b_result = b_false.
          RETURN.
        ENDIF.

        IF ls_adrc-street IS INITIAL.
          b_result = b_false.
          RETURN.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.


ENDFORM.


FORM u600
   CHANGING b_result.

  DATA:    ls_but000 TYPE but000.

  b_result = b_true.

  IF bseg-lifnr IS NOT INITIAL.

    SELECT SINGLE * FROM but000 INTO ls_but000
      WHERE partner = bseg-lifnr.
    IF sy-subrc = 0.

      IF ls_but000-bu_group = '0012'.
        b_result = b_false.
        RETURN.
      ENDIF.

    ENDIF.

  ELSEIF bseg-kunnr IS NOT INITIAL.

    SELECT SINGLE * FROM but000 INTO ls_but000
      WHERE partner = bseg-kunnr.
    IF sy-subrc  = 0.

      IF ls_but000-bu_group = '0012'.
        b_result = b_false.
        RETURN.
      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.

"Validierung: SEPA-Mandat aktiv
FORM u601
  CHANGING b_result.

  DATA: lv_partner TYPE bu_partner.

  b_result = b_true.

  IF bseg-kunnr IS NOT INITIAL.

    lv_partner = bseg-kunnr.

  ELSEIF bseg-lifnr IS NOT INITIAL.

    lv_partner = bseg-lifnr.

  ENDIF.

  IF lv_partner IS NOT INITIAL.

    SELECT SINGLE iban FROM but0bk
      INTO @DATA(lv_iban)
      WHERE partner = @lv_partner
      AND bkvid = @bseg-bvtyp.

    IF lv_iban IS INITIAL.

      SELECT SINGLE banks, bankl, bankn FROM but0bk
    INTO @DATA(ls_bank)
    WHERE partner = @lv_partner
      AND bkvid = @bseg-bvtyp.
      IF ls_bank IS NOT INITIAL.

        CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
          EXPORTING
            i_bank_account = ls_bank-bankn
*           I_BANK_CONTROL_KEY       = ' '
            i_bank_country = ls_bank-banks
            i_bank_number  = ls_bank-bankl
            i_bank_key     = ls_bank-bankl
          IMPORTING
            e_iban         = lv_iban
          EXCEPTIONS
            no_conversion  = 1
            OTHERS         = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ENDIF.

    ENDIF.

    IF lv_iban IS NOT INITIAL.

      SELECT SINGLE * FROM sepa_mandate
        INTO @DATA(ls_mandat)
        WHERE snd_id = @lv_partner
        AND snd_iban = @lv_iban
        AND mvers = '0'
        AND status = '1'.
      IF sy-subrc <> 0.

        b_result = b_false.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.

"Validierung: SEPA-Mandat freigegeben - Global Lock ist nicht gesetzt
FORM u602
CHANGING b_result.

  DATA: lv_partner TYPE bu_partner.

  b_result = b_true.

  IF bseg-kunnr IS NOT INITIAL.

    lv_partner = bseg-kunnr.

  ELSEIF bseg-lifnr IS NOT INITIAL.

    lv_partner = bseg-lifnr.

  ENDIF.

  IF lv_partner IS NOT INITIAL.

    SELECT SINGLE iban FROM but0bk
      INTO @DATA(lv_iban)
      WHERE partner = @lv_partner
      AND bkvid = @bseg-bvtyp.

    IF lv_iban IS INITIAL.

      SELECT SINGLE banks, bankl, bankn FROM but0bk
    INTO @DATA(ls_bank)
    WHERE partner = @lv_partner
      AND bkvid = @bseg-bvtyp.
      IF ls_bank IS NOT INITIAL.

        CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
          EXPORTING
            i_bank_account = ls_bank-bankn
*           I_BANK_CONTROL_KEY       = ' '
            i_bank_country = ls_bank-banks
            i_bank_number  = ls_bank-bankl
            i_bank_key     = ls_bank-bankl
          IMPORTING
            e_iban         = lv_iban
          EXCEPTIONS
            no_conversion  = 1
            OTHERS         = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ENDIF.

    ENDIF.

    IF lv_iban IS NOT INITIAL.

      SELECT SINGLE * FROM sepa_mandate
        INTO @DATA(ls_mandat)
        WHERE snd_id = @lv_partner
        AND snd_iban = @lv_iban
        AND mvers = '0'
        AND glock = ' '.
      IF sy-subrc <> 0.

        b_result = b_false.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.

"Validierung: Mandatsunterschrift vor Fälligkeit der Rechnung
FORM u603
CHANGING b_result.

  DATA: lv_partner TYPE bu_partner.

  b_result = b_true.

  IF bseg-kunnr IS NOT INITIAL.

    lv_partner = bseg-kunnr.

  ELSEIF bseg-lifnr IS NOT INITIAL.

    lv_partner = bseg-lifnr.

  ENDIF.

  IF lv_partner IS NOT INITIAL.

    SELECT SINGLE iban FROM but0bk
      INTO @DATA(lv_iban)
      WHERE partner = @lv_partner
      AND bkvid = @bseg-bvtyp.

    IF lv_iban IS INITIAL.

      SELECT SINGLE banks, bankl, bankn FROM but0bk
    INTO @DATA(ls_bank)
    WHERE partner = @lv_partner
      AND bkvid = @bseg-bvtyp.
      IF ls_bank IS NOT INITIAL.

        CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
          EXPORTING
            i_bank_account = ls_bank-bankn
*           I_BANK_CONTROL_KEY       = ' '
            i_bank_country = ls_bank-banks
            i_bank_number  = ls_bank-bankl
            i_bank_key     = ls_bank-bankl
          IMPORTING
            e_iban         = lv_iban
          EXCEPTIONS
            no_conversion  = 1
            OTHERS         = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ENDIF.

    ENDIF.

    IF lv_iban IS NOT INITIAL.

      SELECT SINGLE * FROM sepa_mandate
        INTO @DATA(ls_mandat)
        WHERE snd_id = @lv_partner
        AND snd_iban = @lv_iban
        AND mvers = '0'.
      IF sy-subrc = 0.

        IF ls_mandat-sign_date > bseg-zfbdt OR bseg-zfbdt IS INITIAL.

          b_result = b_false.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.

"Validierung Mehfrachmandat bei Daueranordnung
FORM u604
CHANGING b_result.


  DATA: lv_partner TYPE bu_partner.

  b_result = b_true.

  IF bseg-kunnr IS NOT INITIAL.

    lv_partner = bseg-kunnr.

  ELSEIF bseg-lifnr IS NOT INITIAL.

    lv_partner = bseg-lifnr.

  ENDIF.

  IF lv_partner IS NOT INITIAL.

    SELECT SINGLE iban FROM but0bk
      INTO @DATA(lv_iban)
      WHERE partner = @lv_partner
      AND bkvid = @bseg-bvtyp.

    IF lv_iban IS INITIAL.

      SELECT SINGLE banks, bankl, bankn FROM but0bk
    INTO @DATA(ls_bank)
    WHERE partner = @lv_partner
      AND bkvid = @bseg-bvtyp.
      IF ls_bank IS NOT INITIAL.

        CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
          EXPORTING
            i_bank_account = ls_bank-bankn
*           I_BANK_CONTROL_KEY       = ' '
            i_bank_country = ls_bank-banks
            i_bank_number  = ls_bank-bankl
            i_bank_key     = ls_bank-bankl
          IMPORTING
            e_iban         = lv_iban
          EXCEPTIONS
            no_conversion  = 1
            OTHERS         = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ENDIF.

    ENDIF.

    IF lv_iban IS NOT INITIAL.

      SELECT SINGLE * FROM sepa_mandate
        INTO @DATA(ls_mandat)
        WHERE snd_id = @lv_partner
        AND snd_iban = @lv_iban
        AND mvers = '0'.
      IF sy-subrc = 0.

        IF ls_mandat-pay_type = '1'.

          b_result = b_false.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.

"Validierung: Gültigkeit des Mandats
FORM u605
CHANGING b_result.

  DATA: lv_partner TYPE bu_partner.

  b_result = b_true.

  IF bseg-kunnr IS NOT INITIAL.

    lv_partner = bseg-kunnr.

  ELSEIF bseg-lifnr IS NOT INITIAL.

    lv_partner = bseg-lifnr.

  ENDIF.

  IF lv_partner IS NOT INITIAL.

    SELECT SINGLE iban FROM but0bk
      INTO @DATA(lv_iban)
      WHERE partner = @lv_partner
      AND bkvid = @bseg-bvtyp.

    IF lv_iban IS INITIAL.

      SELECT SINGLE banks, bankl, bankn FROM but0bk
    INTO @DATA(ls_bank)
    WHERE partner = @lv_partner
      AND bkvid = @bseg-bvtyp.
      IF ls_bank IS NOT INITIAL.

        CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
          EXPORTING
            i_bank_account = ls_bank-bankn
*           I_BANK_CONTROL_KEY       = ' '
            i_bank_country = ls_bank-banks
            i_bank_number  = ls_bank-bankl
            i_bank_key     = ls_bank-bankl
          IMPORTING
            e_iban         = lv_iban
          EXCEPTIONS
            no_conversion  = 1
            OTHERS         = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

      ENDIF.

    ENDIF.

    IF lv_iban IS NOT INITIAL.

      SELECT SINGLE * FROM sepa_mandate
        INTO @DATA(ls_mandat)
        WHERE snd_id = @lv_partner
        AND snd_iban = @lv_iban
        AND mvers = '0'.
      IF sy-subrc = 0.

        IF ls_mandat-val_from_date > bseg-zfbdt OR ls_mandat-val_to_date < bseg-zfbdt.

          b_result = b_false.

        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.

"Validierung: Zahlweg X - AusAO Kassenzeichen gehört zu AnnAO!
FORM u606
CHANGING b_result.
*&*********************************************************************
*& Änderungen
*&---------------------------------------------------------------------
*& Auftrag/Incident        Datum      Benutzer (ÄnderungsKz.)
*& 4000000845/INC08746716  30.03.2026 ZHM000000379 (gb01)
*& Kurzdump wenn bktxt > 16 Zeichen und BLART AR ergänzt
**********************************************************************

  b_result = b_false.

  CHECK bkpf-bktxt IS NOT INITIAL.

  TRY.                                                        "ins gb01
      SELECT SINGLE FROM bkpf
        FIELDS belnr
        WHERE xblnr = @bkpf-bktxt
         AND ( blart = 'DR'
            OR blart = 'DD'
            OR blart = 'AR'                                   "ins gb01
            OR blart = 'D1' )
        INTO @DATA(belnr).
    CATCH cx_sy_open_sql_data_error INTO DATA(lr_cx_u606).    "ins gb01
      EXIT.                                                   "ins gb01
  ENDTRY.                                                     "ins gb01

  IF sy-subrc = 0.
    b_result = b_true.
  ENDIF.

ENDFORM.
