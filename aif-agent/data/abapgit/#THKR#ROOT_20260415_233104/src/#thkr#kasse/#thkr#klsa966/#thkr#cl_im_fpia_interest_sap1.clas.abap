class /THKR/CL_IM_FPIA_INTEREST_SAP1 definition
  public
  final
  create public .

public section.

*"* public components of class /THKR/CL_IM_FPIA_INTEREST_SAP1
*"* do not include other source files here!!!
  interfaces IF_EX_FI_INT_CUS01 .
protected section.
*"* protected components of class /THKR/CL_IM_FPIA_INTEREST_SAP1
*"* do not include other source files here!!!
private section.

  type-pools FINT .
  type-pools GLT9 .
  methods GET_ACC_ASSIGN
    importing
      !IS_T056U_EXT type FINT_TS_T056U_EXT
      !IS_ACCIT type ACCIT
      !IS_ACCCR type ACCCR
      !IS_ITEM_KEY type GLT9_BSEG_KEY_WA
      !IS_BSEG_KEY type GLT9_BSEG_KEY_WA
    exporting
      !ES_ACCIT type ACCIT .
  methods GET_GL_ACCOUNT
    importing
      !IS_IPF type INTIPF
      !IS_T001 type T001
      !IS_ACCCR type ACCCR
      !IS_ITEMS type INTIT_EXTF
    changing
      !CS_ACCIT type ACCIT .
  methods COLLECT_ACC
    importing
      !IS_IPF type INTIPF
      !IT_ACCIT type FINT_TT_ACCIT
      !IT_ACCCR type FINT_TT_ACCCR
    changing
      !CT_ACCIT type FINT_TT_ACCIT
      !CT_ACCCR type FINT_TT_ACCCR
      !CT_ITEMS type FINT_TT_INTIT_EXTF .
  methods DISTRIBUTE_TAX
    changing
      !CT_BSEG type BSEG_T .
  methods FIXED_AMOUNT
    importing
      !IS_IPF type INTIPF
      !IS_T001 type T001
    changing
      !CT_ACCIT type FINT_TT_ACCIT
      !CT_ACCCR type FINT_TT_ACCCR
      !CT_ITEMS type FINT_TT_INTIT_EXTF .
*"* private components of class /THKR/CL_IM_FPIA_INTEREST_SAP1
*"* do not include other source files here!!!
ENDCLASS.



CLASS /THKR/CL_IM_FPIA_INTEREST_SAP1 IMPLEMENTATION.


METHOD COLLECT_ACC.

  CONSTANTS: lc_posnr TYPE posnr_acc  VALUE '0000000000'.
  DATA: lt_accit_aux  TYPE fint_tt_accit,
        lt_acccr_aux  TYPE fint_tt_acccr,
        ls_accit      TYPE LINE OF fint_tt_accit,
        lt_acccr_reb  TYPE fint_tt_acccr,        "Rebuild acccr
        lt_accit_reb  TYPE fint_tt_accit,         "Rebuild accit
        lv_count      TYPE p,
        lv_count_reb  TYPE p,
        lv_lin        TYPE p,
        lv_exec       TYPE p,
        ls_accit_reb  TYPE LINE OF fint_tt_accit, "Rebuild accit
        ls_accit_raux TYPE LINE OF fint_tt_accit, "Rebuild accit
        ls_acccr_l1   TYPE LINE OF fint_tt_acccr,
        ls_acccr_l2   TYPE LINE OF fint_tt_acccr,
        lv_posnr      TYPE posnr_acc,
        lv_posnr_acr  TYPE posnr_acc,
        ls_acccr      TYPE LINE OF fint_tt_acccr.

  FIELD-SYMBOLS: <ct_items> TYPE LINE OF fint_tt_intit_extf,
                 <lt_acccr> TYPE LINE OF fint_tt_acccr.

  lt_accit_aux = it_accit.
  lt_acccr_aux = it_acccr.

*Clear lines with zero amount
  LOOP AT lt_acccr_aux INTO ls_acccr.
    IF ls_acccr-wrbtr = '0.00'.
      DELETE lt_accit_aux WHERE posnr = ls_acccr-posnr.
      DELETE lt_acccr_aux WHERE posnr = ls_acccr-posnr.
    ENDIF.
  ENDLOOP.

* Create new accit without Item number, Posting Key and Indicator
* This will allow us to "sum" the lines
  LOOP AT lt_accit_aux INTO ls_accit.
    CLEAR: ls_accit-posnr, ls_accit-bschl, ls_accit-shkzg.
    APPEND ls_accit TO lt_accit_reb.
  ENDLOOP.

* Get the number of lines to be processed
  DESCRIBE TABLE lt_accit_reb LINES lv_lin.

* Compare all the lines
  LOOP AT lt_accit_reb INTO ls_accit_reb.
* If the line was already processed on a previous step it is skiped
    IF ls_accit_reb-posnr NE '9999999999'.
      lv_count_reb = sy-tabix.
      lv_exec = lv_count_reb.
      DO.
        ADD 1 TO: lv_exec.
* Number of lines exceeded
        IF lv_exec GT lv_lin.
          EXIT.
        ENDIF.
* Read the next line
        READ TABLE lt_accit_reb INTO ls_accit_raux INDEX lv_exec.
        IF ls_accit_raux = ls_accit_reb.
* Read the 2 lines from the "original" table
          READ TABLE lt_acccr_aux INTO ls_acccr_l1 INDEX lv_count_reb.
          READ TABLE lt_acccr_aux INTO ls_acccr_l2 INDEX lv_exec.
          IF ABS( ls_acccr_l2-wrbtr ) GT ABS( ls_acccr_l1-wrbtr ).
* If the value of the second line is greater than the one we are
* currently processing
            ls_acccr_l2-wrbtr = ls_acccr_l2-wrbtr + ls_acccr_l1-wrbtr.
            IF ls_accit_raux-koart = 'K'.
* If we are processing a Vendor line we need to update CT_ITEMS
              LOOP AT ct_items ASSIGNING <ct_items>
                WHERE acc_posnr = ls_acccr_l1-posnr
                  AND array = is_ipf-array.
                <ct_items>-acc_posnr = ls_acccr_l2-posnr.
              ENDLOOP.
            ENDIF.
            MODIFY lt_acccr_aux INDEX lv_exec
              FROM ls_acccr_l2
              TRANSPORTING wrbtr.
* Mark the current line as processed
            MOVE '9999999999' TO: ls_acccr_l2-posnr,
                                  ls_accit_raux-posnr.
            MODIFY lt_acccr_aux FROM ls_acccr_l2
              INDEX lv_count_reb TRANSPORTING posnr.
            MODIFY lt_accit_aux FROM ls_accit_raux
              INDEX lv_count_reb TRANSPORTING posnr.
            EXIT.
          ELSE.
* If the value of the line we are currently processing is greater than
* the compared one
            ls_acccr_l1-wrbtr = ls_acccr_l2-wrbtr + ls_acccr_l1-wrbtr.
            MODIFY lt_acccr_aux INDEX lv_count_reb
              FROM ls_acccr_l1
              TRANSPORTING wrbtr.
            IF ls_accit_raux-koart = 'K'.
* If we are processing a Vendor line we need to update CT_ITEMS
              LOOP AT ct_items ASSIGNING <ct_items>
                WHERE acc_posnr = ls_acccr_l2-posnr
                  AND array = is_ipf-array.
                <ct_items>-acc_posnr = ls_acccr_l1-posnr.
              ENDLOOP.
            ENDIF.
* Mark the other line as processed
            MOVE '9999999999' TO: ls_acccr_l2-posnr,
                                  ls_accit_raux-posnr.
            MODIFY lt_acccr_aux FROM ls_acccr_l2
              INDEX lv_exec TRANSPORTING posnr.
            MODIFY lt_accit_reb FROM ls_accit_raux
             INDEX lv_exec TRANSPORTING posnr.
            MODIFY lt_accit_aux FROM ls_accit_raux
              INDEX lv_exec TRANSPORTING posnr.
          ENDIF.
        ENDIF.
      ENDDO.
    ENDIF.
  ENDLOOP.
* Delete the lines processed/joined
  DELETE lt_acccr_aux WHERE posnr = '9999999999'.
  DELETE lt_accit_aux WHERE posnr = '9999999999'.

  SORT lt_accit_aux BY koart posnr ASCENDING.
* Re-number POSNR
  lv_posnr = lv_posnr_acr = lc_posnr + 1.
  lv_posnr_acr(1) = '9'.

  LOOP AT lt_accit_aux INTO ls_accit.
    IF ls_accit-koart = 'K'.
* If we are processing a Vendor line we need to update CT_ITEMS
      LOOP AT ct_items ASSIGNING <ct_items>
        WHERE acc_posnr = ls_accit-posnr
          AND array = is_ipf-array.
        <ct_items>-acc_posnr = lv_posnr.
      ENDLOOP.
    ENDIF.
* Get the corresponding line on acccr
    READ TABLE lt_acccr_aux ASSIGNING <lt_acccr>
      WITH KEY posnr = ls_accit-posnr.
    IF sy-subrc = 0.
* Change the POSNR with a "modified" one so that we could not take the
* chance of at some point have the same POSNR on 2 different lines
      <lt_acccr>-posnr = lv_posnr_acr.
    ELSE.
* no line? Issue Error
    ENDIF.
    ls_accit-posnr = lv_posnr.
    ADD 1 TO: lv_posnr, lv_posnr_acr.
    APPEND ls_accit TO ct_accit.
  ENDLOOP.

  SORT lt_acccr_aux BY posnr ASCENDING.
  LOOP AT lt_acccr_aux INTO ls_acccr.
* rebuild the "normal" POSNR
    ls_acccr-posnr(1) = '0'.
    APPEND ls_acccr TO ct_acccr.
  ENDLOOP.
ENDMETHOD.


METHOD DISTRIBUTE_TAX.
  TYPES:  BEGIN OF ty_tax,
            mwskz TYPE mwskz,
            wrbtr TYPE wrbtr,
           END OF ty_tax.
  DATA: lt_bseg   TYPE TABLE OF bseg,
        ls_bseg   TYPE bseg,
        ls_tax    TYPE ty_tax,              " Total of tax Lines
        lt_tax    TYPE TABLE OF ty_tax,     " Total of tax Lines
        ls_batax  TYPE ty_tax,              " Total of base amount
        lt_batax  TYPE TABLE OF ty_tax.     " Total of base amount

  MOVE ct_bseg TO lt_bseg.
  REFRESH ct_bseg.

* Getting the Total amount for each tax code.
* Maybe it is impossible to have more that one tax line on the document
* for each tax code, but to keep it safe
  LOOP AT lt_bseg INTO ls_bseg WHERE buzid = 'T'.
    MOVE-CORRESPONDING ls_bseg TO ls_tax.
      IF ls_bseg-shkzg = 'H'.                         "2109925
        ls_tax-wrbtr = ls_tax-wrbtr * ( -1 ).         "2109925
      ENDIF.                                          "2109925
    COLLECT ls_tax INTO lt_tax.
  ENDLOOP.

  IF sy-subrc EQ 0.

* Already have the tax lines, no need to keep them
    DELETE lt_bseg WHERE buzid = 'T'.

* Getting the total of the base amount for each tax code.
    LOOP AT lt_bseg INTO ls_bseg.
      MOVE-CORRESPONDING ls_bseg TO ls_batax.
      IF ls_bseg-shkzg = 'H'.                         "2045010
        ls_batax-wrbtr = ls_batax-wrbtr * ( -1 ).     "2045010
      ENDIF.                                          "2045010
      COLLECT ls_batax INTO lt_batax.
    ENDLOOP.

* Distribute the tax amount for the corresponding lines
    LOOP AT lt_bseg INTO ls_bseg.
      READ TABLE lt_batax INTO ls_batax
        WITH TABLE KEY mwskz = ls_bseg-mwskz.
* No need for checks here as we will always find the line

      READ TABLE lt_tax INTO ls_tax
        WITH TABLE KEY mwskz = ls_bseg-mwskz.
* A check is needed here for 0% tax codes as no line is created
      IF sy-subrc EQ 0.
        ls_bseg-wrbtr = ls_bseg-wrbtr +
                      ( ls_bseg-wrbtr * ls_tax-wrbtr / ls_batax-wrbtr ).
        MODIFY lt_bseg FROM ls_bseg.
      ENDIF.
    ENDLOOP.
  ENDIF.
  ct_bseg = lt_bseg.
ENDMETHOD.


METHOD FIXED_AMOUNT.

  CONSTANTS: lc_fixam TYPE bewegart   VALUE 'FIXAM'.

  DATA: lv_totam      TYPE acbtr,
        lv_perc       TYPE p DECIMALS 6,
        lv_totaldoc   TYPE acccr-wrbtr,
        lv_totalsum   TYPE acccr-wrbtr,
        lv_dif        TYPE acccr-wrbtr,
        lv_higham     TYPE acccr-wrbtr,
        lv_highposnr  TYPE acccr-posnr,
        ls_accit      TYPE accit,
        ls_acccr      TYPE acccr,
        ls_items      TYPE intit_extf,
        lt_accit      TYPE TABLE OF accit,
        lt_acccr      TYPE TABLE OF acccr.

  lt_accit[] = ct_accit.
  lt_acccr[] = ct_acccr.

*Get total amount
  LOOP AT lt_accit INTO ls_accit
    WHERE lifnr IS INITIAL.
    READ TABLE lt_acccr INTO ls_acccr
      WITH KEY posnr = ls_accit-posnr.

    ADD ls_acccr-wrbtr TO lv_totam.

  ENDLOOP.

  LOOP AT lt_accit INTO ls_accit
    WHERE lifnr IS NOT INITIAL.
    READ TABLE lt_acccr INTO ls_acccr
      WITH KEY posnr = ls_accit-posnr.

    DELETE TABLE lt_accit FROM ls_accit.
    DELETE TABLE lt_acccr FROM ls_acccr.
  ENDLOOP.

* Run the FIXED amount items and create a new line for each lt_acccr
* and accit line
  LOOP AT ct_items INTO ls_items WHERE int_sign EQ lc_fixam
                                   AND array = is_ipf-array .
* We need to convert the amount to the opposite sign
    ls_items-int_amount = ls_items-int_amount * ( -1 ).
    lv_totaldoc = ls_items-int_amount.

    LOOP AT lt_accit INTO ls_accit.
      READ TABLE lt_acccr INTO ls_acccr
        WITH KEY posnr = ls_accit-posnr.

      IF ls_acccr-wrbtr NE 0.

* Get percentage
        IF lv_totam NE 0.             "Note 3129827
          lv_perc = ls_acccr-wrbtr / lv_totam.

        ELSE.                         "Note 3129827
          lv_perc = 0.                "Note 3129827

        ENDIF.                        "Note 3129827

        ls_acccr-wrbtr = ls_items-int_amount * lv_perc.

        ADD 50000 TO: ls_acccr-posnr,
                      ls_accit-posnr.

*Rounding Diferences
        ADD ls_acccr-wrbtr TO lv_totalsum.
        IF ls_acccr-wrbtr GT lv_higham.
          MOVE: ls_acccr-wrbtr TO lv_higham,
                ls_acccr-posnr TO lv_highposnr.
        ENDIF.

* Get the account
        CALL METHOD me->get_gl_account
          EXPORTING
            is_ipf   = is_ipf
            is_t001  = is_t001
            is_acccr = ls_acccr
            is_items = ls_items
          CHANGING
            cs_accit = ls_accit.

        APPEND ls_accit TO ct_accit.
        APPEND ls_acccr TO ct_acccr.
      ENDIF.
    ENDLOOP.
    IF lv_totalsum NE lv_totaldoc.
      lv_dif = lv_totaldoc - lv_totalsum.
      READ TABLE ct_acccr WITH KEY posnr = lv_highposnr INTO ls_acccr.
      ADD lv_dif TO ls_acccr-wrbtr .
      MODIFY TABLE ct_acccr FROM ls_acccr.
    ENDIF.
    CLEAR: lv_totalsum, lv_totaldoc, lv_higham.
  ENDLOOP.
ENDMETHOD.


METHOD GET_ACC_ASSIGN.

  MOVE-CORRESPONDING is_accit TO es_accit.

  CALL FUNCTION 'FM_DOCUMENT_GET_MUSTER'
    EXPORTING
      i_knbelnr          = is_bseg_key-belnr
      i_kngjahr          = is_bseg_key-gjahr
      i_knbuzei          = is_bseg_key-buzei
      i_bukrs            = is_bseg_key-bukrs
      i_budat            = is_accit-budat
*      i_fipex            = es_accit-fipos
      i_fipos            = es_accit-fipos
      i_fistl            = es_accit-fistl
      i_fonds            = es_accit-geber
      i_farea            = es_accit-fkber
      i_grant_nbr        = es_accit-grant_nbr
      i_measure          = es_accit-measure
    IMPORTING
      e_fipos            = es_accit-fipos
      e_fistl            = es_accit-fistl
      e_fonds            = es_accit-geber
      e_farea            = es_accit-fkber
      e_grant_nbr        = es_accit-grant_nbr
      e_measure          = es_accit-measure
    EXCEPTIONS
      document_not_found = 1
      OTHERS             = 2.


  IF sy-subrc <> 0.
* If the document was not found we need to assign the old values to
* the exporting structure again
    MOVE-CORRESPONDING is_accit TO es_accit.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMETHOD.


METHOD GET_GL_ACCOUNT.

  CONSTANTS: lc_fixam   TYPE bewegart   VALUE 'FIXAM'.

  DATA:   ls_ikofex     TYPE ikofi,
          ls_ikofim     TYPE ikofi.

  CASE is_ipf-koart.
    WHEN 'D'.
      ls_ikofex-anwnd = '0002'.
    WHEN 'K'.
      ls_ikofex-anwnd = '0009'.
  ENDCASE.
  ls_ikofex-eigr2 = is_ipf-bukrs.
  ls_ikofex-eigr3 = is_ipf-vzskz.
  ls_ikofex-fpart = '1'.
  ls_ikofex-komo1 = is_ipf-int_curr.
  ls_ikofex-komo2 = space.
  ls_ikofex-ktopl = is_t001-ktopl.
  ls_ikofex-sakin = space.

  IF  cs_accit-koart <> 'S'
  AND is_acccr-wrbtr > 0            "Forderung
  OR  cs_accit-koart = 'S'
  AND is_acccr-wrbtr < 0.           "Zinsertrag oder Steuern
    IF is_items-int_sign NE lc_fixam.
      ls_ikofex-eigr1 = '1000'.
    ELSE.
      ls_ikofex-eigr1 = '1100'.
    ENDIF.
  ELSE.
    IF is_items-int_sign NE lc_fixam.
      ls_ikofex-eigr1 = '2000'.
    ELSE.
      ls_ikofex-eigr1 = '2100'.
    ENDIF.
  ENDIF.

  ls_ikofex-eigr4 = cs_accit-gsber.

  CALL FUNCTION 'ACCOUNT_DETERMINATION'
    EXPORTING
      i_anwnd            = ls_ikofex-anwnd
      i_eigr1            = ls_ikofex-eigr1
      i_eigr2            = ls_ikofex-eigr2
      i_eigr3            = ls_ikofex-eigr3
      i_eigr4            = ls_ikofex-eigr4
      i_fpart            = ls_ikofex-fpart
      i_komo1            = ls_ikofex-komo1
      i_komo2            = ls_ikofex-komo2
      i_ktopl            = ls_ikofex-ktopl
      i_sakin            = ls_ikofex-sakin
      i_sakinb           = ls_ikofex-sakin
    IMPORTING
      e_ikofi            = ls_ikofex
    EXCEPTIONS
      input_missing      = 1
      input_wrong        = 2
      replace_impossible = 3
      rule_not_defined   = 4
      schema_not_found   = 5.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  IF is_acccr-wrbtr >= 0.
    cs_accit-shkzg = 'S'.
    cs_accit-bschl = ls_ikofex-bsch1.
    cs_accit-umskz = ls_ikofex-shbk1.
  ELSE.
    cs_accit-shkzg = 'H'.
    cs_accit-bschl = ls_ikofex-bsch2.
    cs_accit-umskz = ls_ikofex-shbk2.
  ENDIF.

*     HKONT is already filled for tax lines and may not be changed
  CALL FUNCTION 'ACCOUNT_DETERMINATION_REPLACE'
    EXPORTING
      i_anwnd            = ls_ikofex-anwnd
      i_komo1            = ls_ikofex-komo1
      i_komo2            = ls_ikofex-komo2
      i_ktopl            = ls_ikofex-ktopl
      i_ktos1            = ls_ikofex-ktos1
      i_ktos2            = ls_ikofex-ktos2
      i_sakin            = ls_ikofex-sakin
      i_sakinb           = ls_ikofex-sakin
    IMPORTING
      e_ikofi            = ls_ikofim
    EXCEPTIONS
      input_missing      = 1
      input_wrong        = 2
      replace_impossible = 3.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  IF is_acccr-wrbtr >= 0.
    cs_accit-hkont = ls_ikofim-sakn1.
  ELSE.
    cs_accit-hkont = ls_ikofim-sakn2.
  ENDIF.
  CLEAR: ls_ikofex, ls_ikofim.

ENDMETHOD.


  method IF_EX_FI_INT_CUS01~END_OF_PROGRAMM.
  endmethod.


method IF_EX_FI_INT_CUS01~GET_INT_SIGN.
    RETURN. "empty implementation for this method
*  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
*    IS NOT INITIAL.
*...
*  ENDIF.
endmethod.


method IF_EX_FI_INT_CUS01~INT_ADD_ITEMS.
  data: lt_pso47 type table of pso47.
  data: ls_pso47 type pso47.
  data: lt_t047b type table of t047b.
  data: ls_t047b type t047b.
  data: ls_bseg type bseg.
  data: lt_items_del type FINT_TT_INTIT_EXTF.
  data: ls_items type LINE OF FINT_TT_INTIT_EXTF.
  data: ls_frange type fint_frange.
  data: ls_selopt type fintselopt.
  data: lv_zins_bis type DUZIBSZT.
  select * from pso47 into table lt_pso47.
  select * from t047b into table lt_t047b where mahns = '1'.
  read table it_frange into ls_frange with key fieldname = 'A_END'.
  clear lv_zins_bis.
  if sy-subrc = 0.
    loop at ls_frange-selopt_t into ls_selopt.
      lv_zins_bis = ls_selopt-low.
    endloop.
  endif.
  loop at ct_items into ls_items.
    select single * from bseg into ls_bseg
           where bukrs = ls_items-bukrs
             and belnr = ls_items-belnr
             and gjahr = ls_items-gjahr
             and buzei = ls_items-buzei
             and augbl = ''. "nur offene Posten
    if sy-subrc = 0.
      read table lt_pso47 into ls_pso47 with key bukrs = ls_bseg-bukrs
                                                 maber = ls_bseg-maber.
      if sy-subrc = 0.
        read table lt_t047b into ls_t047b with key mahna = ls_pso47-mahna.
        if sy-subrc = 0.
          if lv_zins_bis - ls_items-zfbdt < ls_t047b-VERTG.
            append ls_items to lt_items_del.
          endif.
        endif.
      endif.
    endif.
  endloop.
  loop at lt_items_del into ls_items.
    delete ct_items where bukrs = ls_items-bukrs
                      and gjahr = ls_items-gjahr
                      and belnr = ls_items-belnr
                      and buzei = ls_items-buzei
                      and int_end = ls_items-int_end.
  endloop.
  clear lt_items_del.
  refresh lt_items_del.
*  RETURN. "empty implementation for this method
*  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
*    IS NOT INITIAL.
*...
*  ENDIF.
endmethod.


METHOD IF_EX_FI_INT_CUS01~INT_CHANGE_ITEMS.
  DATA: ls_item        TYPE intit_extf,
        ls_log         LIKE LINE OF ct_log,
        go_int_manager TYPE REF TO cl_fpia_srv_int_mgr,
        lo_interest    TYPE REF TO cl_fpia_srv_interest,
        lt_fi_key      TYPE fpia_t_key_fi,
        lt_fi_idx      TYPE fpia_t_fi_idx,
        ls_interest    TYPE fpia_interest,
        ls_fi_idx      TYPE fpia_fi_idx,
        ls_fi_key      TYPE fpia_s_key_fi,
        lv_idx1        TYPE sy-tabix,
        lv_idx2        TYPE sy-tabix,
        old            TYPE c LENGTH 10,
        new            TYPE c LENGTH 10,
        l_zbd1t_ext(5) TYPE n.
  DATA:  lo_exception  TYPE REF TO cx_fpia_common_exception.
  DATA: lv_msgid TYPE symsgid,
        lv_msgno TYPE symsgno,
        lv_msgty TYPE symsgty,
        lv_msgv1 TYPE symsgv.

  DATA: lv_retumskz TYPE ret_umskz.     "Note 3127177

"kLSA966 Zinskennzeichen
data: ls_bkpf_int type bkpf.
data: ls_bseg_int type bseg.
data: lt_t047n type table of t047n.
data: ls_t047n type t047n.
select * from t047n into table lt_t047n where spras = 'D'.
loop at ct_items assigning field-symbol(<fs_items>).
*  break zhm000000052.
  select single * from bseg into ls_bseg_int
         where bukrs = <fs_items>-bukrs
           and belnr = <fs_items>-belnr
           and gjahr = <fs_items>-gjahr
           and buzei = <fs_items>-buzei.
  if sy-subrc = 0.
*    <fs_items>-zfbdt = ls_bseg_int-zfbdt.
    read table lt_t047n into ls_t047n with key bukrs = ls_bseg_int-bukrs
                                               maber = ls_bseg_int-maber.
    if sy-subrc = 0 and ls_t047n-text1 cs 'ZAO'.
      clear ls_bkpf_int.
      select single * from bkpf into ls_bkpf_int
             where bukrs = <fs_items>-bukrs
               and belnr = <fs_items>-belnr
               and gjahr = <fs_items>-gjahr.
      if sy-subrc = 0.
        if sy-tcode <> 'F889' and sy-tcode <> 'F886'. "DF-1705 27.10.2025
        if ls_bkpf_int-Z_INTRATE is not initial.
          replace '.' in ls_bkpf_int-z_intrate with ''.
          replace ',' in ls_bkpf_int-z_intrate with '.'.
          <fs_items>-int_rate = ls_bkpf_int-Z_INTRATE.
        elseif ls_bkpf_int-Z_VZSKZ is not initial.
          <fs_items>-int_ind = ls_bkpf_int-z_vzskz.
        endif.
        endif.
        <fs_items>-xblnr = ls_bkpf_int-xblnr.
      endif.
    endif.
  endif.
endloop.


  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
    IS NOT INITIAL.

    go_int_manager = cl_fpia_factory=>get_interest_manager( ).

    IF NOT ct_items[] IS INITIAL.

*     Begin of note 3127177
*     ==> get sGL indicator customized for retention documents
      READ TABLE    ct_items
             INTO   ls_item
             INDEX  1.

      SELECT SINGLE retumskz
             INTO   lv_retumskz
             FROM   t169p
             WHERE  bukrs     = ls_item-bukrs.

      IF sy-subrc NE 0.
        CLEAR lv_retumskz.

      ENDIF.
*     End of note 3127177

      LOOP AT ct_items INTO ls_item.
        lv_idx1 = sy-tabix.
        ls_fi_key-bukrs = ls_item-bukrs.
        ls_fi_key-gjahr = ls_item-gjahr.
        ls_fi_key-belnr = ls_item-belnr.
        ls_fi_key-buzei = ls_item-buzei.
        READ TABLE ct_log INTO ls_log WITH KEY
                         account = ls_item-account
                         belnr   = ls_item-belnr
                         gjahr   = ls_item-gjahr
                         buzei   = ls_item-buzei.
        TRY.
            lo_interest = go_int_manager->get_interest_by_fi( ls_fi_key ).
            IF lo_interest IS BOUND.
              TRY.
                  lo_interest->set_mode( iv_mode = 'C' ).
                  go_int_manager->set_m_fintap( ).
                CATCH cx_fpia_common_exception INTO lo_exception. "#EC NO_HANDLER.
                  lv_msgty = lo_exception->msgtype.
                  lv_msgid = lo_exception->if_t100_message~t100key-msgid.
                  lv_msgno = lo_exception->if_t100_message~t100key-msgno.
                  lv_msgv1 = lo_exception->if_t100_message~t100key-attr1.
                  MESSAGE ID lv_msgid TYPE lv_msgty NUMBER lv_msgno
                       INTO ls_log-ltext WITH lv_msgv1.
                  ls_log-msgno = lv_msgno.
                  COLLECT ls_log INTO ct_log.
                  ls_item-int_status = 'ERROR'.
              ENDTRY.
              INSERT ls_fi_key INTO TABLE lt_fi_key.
              lt_fi_idx   = lo_interest->get_fi_idx( lt_fi_key ).
              ls_interest = lo_interest->get_interest( ).
              READ TABLE lt_fi_idx INDEX 1 INTO ls_fi_idx.
              IF ls_item-belnr NE ls_item-augbl.
                IF ls_fi_idx-line_type NE 'RT'.
                  CLEAR: old, new.
                  WRITE ls_item-netdt TO old.
                  ls_item-zfbdt = ls_fi_idx-zfbdt.
                  TRY.
                      ls_item-zbd1t = ls_fi_idx-zbd1t + ls_interest-delay_br +
                                      ls_interest-delay_ac.
                      IF NOT ls_fi_idx-zfbdt IS INITIAL.
                        ls_item-netdt = ls_fi_idx-zfbdt + ls_item-zbd1t.
                      ELSE.
                        CLEAR: ls_item-netdt.
                      ENDIF.
                    CATCH cx_sy_arithmetic_overflow.
                      IF NOT ls_fi_idx-zfbdt IS INITIAL.
                        l_zbd1t_ext = ls_fi_idx-zbd1t + ls_interest-delay_br +
                                      ls_interest-delay_ac.
                        ls_item-netdt = ls_fi_idx-zfbdt + l_zbd1t_ext.
                      ELSE.
                        CLEAR: ls_item-netdt.
                      ENDIF.
                      ls_item-zbd1t = '999'.
                  ENDTRY.
                  WRITE ls_item-netdt TO new.
                  IF old NE new.
                    READ TABLE ct_log INTO ls_log WITH KEY
                               account = ls_item-account
                               belnr   = ls_item-belnr
                               gjahr   = ls_item-gjahr
                               buzei   = ls_item-buzei
                               msgno   = '188'.
                    IF sy-subrc EQ 0.
                      lv_idx2 = sy-tabix.
                      REPLACE old WITH new INTO ls_log-ltext.
                      MODIFY ct_log FROM ls_log INDEX lv_idx2.
                    ENDIF.
                  ENDIF.
                  READ TABLE ct_log INTO ls_log WITH KEY
                                   account = ls_item-account
                                   belnr   = ls_item-belnr
                                   gjahr   = ls_item-gjahr
                                   buzei   = ls_item-buzei.
                  IF NOT ls_interest-delay_br IS INITIAL.
                    CLEAR: ls_log-msgno, ls_log-ltext.
                    MESSAGE ID 'FPIA' TYPE 'I' NUMBER '260'
                       INTO ls_log-ltext WITH ls_interest-delay_br ls_interest-reason_br.
                    ls_log-msgno = '260'.
                    COLLECT ls_log INTO ct_log.
                  ENDIF.
                  IF NOT ls_interest-delay_ac IS INITIAL.
                    CLEAR: ls_log-msgno, ls_log-ltext.
                    MESSAGE ID 'FPIA' TYPE 'I' NUMBER '261'
                       INTO ls_log-ltext WITH ls_interest-delay_ac ls_interest-reason_ac.
                    ls_log-msgno = '261'.
                    COLLECT ls_log INTO ct_log.
                  ENDIF.
                  IF NOT ls_interest-delay_br IS INITIAL OR
                     NOT ls_interest-delay_ac IS INITIAL.
                    CLEAR: ls_log-msgno, ls_log-ltext.
                    MESSAGE ID 'FPIA' TYPE 'I' NUMBER '262'
                    INTO ls_log-ltext WITH old new.
                    ls_log-msgno = '262'.
                    COLLECT ls_log INTO ct_log.
                  ENDIF.
                ELSEIF ls_fi_idx-line_type = 'RT'.
                  ls_item-zfbdt = ls_fi_idx-zfbdt.
                  ls_item-netdt = ls_fi_idx-zfbdt.
                ENDIF.
                IF NOT ls_interest-vzskz IS INITIAL.
                  IF ls_item-int_ind NE ls_interest-vzskz.
                    CLEAR: ls_log-msgno, ls_log-ltext.
                    MESSAGE ID 'FPIA' TYPE 'I' NUMBER '098'
                       INTO ls_log-ltext WITH ls_interest-vzskz.
                    ls_log-msgno = '098'.
                    COLLECT ls_log INTO ct_log.
                  ENDIF.
                  ls_item-int_ind = ls_interest-vzskz.
                  MODIFY ct_items FROM ls_item INDEX lv_idx1.
                ENDIF.
              ENDIF.
            ELSE.
              CLEAR: ls_log-msgno, ls_log-ltext.
              MESSAGE ID 'FPIA' TYPE 'I' NUMBER '099'
                 INTO ls_log-ltext.
              ls_log-msgno = '099'.
              COLLECT ls_log INTO ct_log.
            ENDIF.
          CATCH cx_fpia_common_exception.               "#EC NO_HANDLER

        ENDTRY.

        DATA: lt_bseg TYPE TABLE OF bseg,
              ls_bseg TYPE bseg.

        ls_item-array = ls_item-belnr.
        IF ls_item-bstat = 'S'.
          IF NOT ls_item-augbl IS INITIAL.
            SELECT * FROM bseg INTO TABLE lt_bseg
                           WHERE bukrs = ls_item-bukrs
                             AND belnr = ls_item-augbl
                             AND gjahr = ls_item-augdt(4)
                             AND koart = 'S'
                             AND buzid NE 'T'
                             ORDER BY PRIMARY KEY. " Note 1789038
            IF lt_bseg[] IS INITIAL.
            ELSE.
              READ TABLE lt_bseg INDEX 1 INTO ls_bseg.
              ls_item-rebzg = ls_item-augbl.
              ls_item-rebzj = ls_item-augdt(4).
              ls_item-rebzz = ls_bseg-buzei.
            ENDIF.
          ENDIF.
        ENDIF.

*       Begin of note 3127177 & 3147300
*       ==> new identification of retention documents
        IF  ls_item-umskz = lv_retumskz
        AND ls_item-umskz IS NOT INITIAL.
*       If ls_item-umskz = 'H'.
*       End of note 3127177 & 3147300

          ls_item-xumsw = 'X'.
        ENDIF.
        MODIFY ct_items FROM ls_item INDEX lv_idx1.
      ENDLOOP.
    ENDIF.

  ENDIF.
ENDMETHOD.


method IF_EX_FI_INT_CUS01~INT_FORMULA.
  RETURN. "empty implementation for this method
*  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
*    IS NOT INITIAL.
*...
*  ENDIF.
endmethod.


METHOD IF_EX_FI_INT_CUS01~INT_GROUP.
  DATA: ls_item   TYPE LINE OF fint_tt_intit_extf,
        ls_fi_idx TYPE fpia_fi_idx,
        ls_frange TYPE LINE OF fint_frange_t,
        lv_test   TYPE c,
        ls_log    LIKE LINE OF ct_log.

  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
    IS NOT INITIAL.

    CLEAR: lv_test.
    LOOP AT it_frange INTO ls_frange.
      IF ls_frange-fieldname = 'A_TESTL'.
        lv_test = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_test IS INITIAL.
      LOOP AT it_items INTO ls_item.
        IF ls_item-int_status = 'NOINT' OR  ls_item-int_status = 'ERROR' .
          CLEAR: ls_fi_idx.
          SELECT * FROM fpia_fi_idx INTO ls_fi_idx WHERE
                                        bukrs = ls_item-bukrs AND
                                        gjahr = ls_item-gjahr AND
                                        belnr = ls_item-belnr AND
                                        buzei = ls_item-buzei.
            IF sy-subrc = 0.
              IF NOT ( ls_fi_idx-int_doc_exist = 'X' OR ls_fi_idx-int_doc_exist = 'D' ).
                IF ls_item-int_status = 'NOINT'.
                  ls_fi_idx-int_doc_exist = 'N'.
                ELSEIF ls_item-int_status = 'ERROR'.
                  ls_fi_idx-int_doc_exist = 'E'.
                ENDIF.
              ENDIF.
              UPDATE  fpia_fi_idx FROM ls_fi_idx.
            ENDIF.
          ENDSELECT.
        ELSEIF ls_item-int_status = 'READY' OR  ls_item-int_status = 'PROCESS' .
          CLEAR: ls_log-msgno, ls_log-ltext.
          MESSAGE ID 'FPIA' TYPE 'S' NUMBER '097' WITH ls_item-belnr ls_item-gjahr ls_item-bukrs.
*             INTO ls_log-ltext
*          ls_log-msgno = '097'.
*          COLLECT ls_log INTO ct_log.
        ENDIF.
      ENDLOOP.
    ENDIF.
********************************************************************
* Special processing for garnishments and cautions
********************************************************************
    DATA: ls_items_validation TYPE intit_extf,
          ls_intithe          TYPE intithe,
          lv_var1             TYPE symsgv,
          lv_var2             TYPE symsgv.

    FIELD-SYMBOLS: <ls_items> TYPE intit_extf,
                   <ls_ipf>   TYPE intipf.

    LOOP AT it_items ASSIGNING <ls_items>
                         WHERE int_status = 'READY'.
      CLEAR: lv_var1, lv_var2, ls_intithe, ls_log.
      READ TABLE it_items INTO ls_items_validation
                   WITH KEY array = <ls_items>-array
                            int_status = 'NOINT'.
      IF sy-subrc = 0.
* Check if there is an interest
        SELECT SINGLE * FROM intithe
                        INTO ls_intithe
                       WHERE bukrs = ls_items_validation-bukrs
                         AND belnr = ls_items_validation-belnr
                         AND gjahr = ls_items_validation-gjahr
                         AND buzei = ls_items_validation-buzei.
        IF sy-subrc = 0.
          READ TABLE ct_log INTO ls_log WITH KEY
                                   account = <ls_items>-account
                                   belnr   = <ls_items>-belnr
                                   gjahr   = <ls_items>-gjahr
                                   buzei   = <ls_items>-buzei.

          CONCATENATE <ls_items>-belnr '/' <ls_items>-bukrs '/' <ls_items>-gjahr
                 INTO lv_var1.
          CONCATENATE ls_items_validation-belnr '/' ls_items_validation-bukrs '/'
                      ls_items_validation-gjahr
                 INTO lv_var2.
          MESSAGE ID 'FPIA' TYPE 'E' NUMBER '096'
                            INTO ls_log-ltext
                            WITH lv_var1
                                 lv_var2.
          ls_log-msgno = '096'.
          COLLECT ls_log INTO ct_log.
          READ TABLE ct_ipf ASSIGNING <ls_ipf>
                            WITH KEY array = <ls_items>-array.
          IF sy-subrc = 0.
            <ls_ipf>-int_status = 'NOINT'.
          ENDIF.
        ELSE.
* No Reason for int_status is 'NOITEM'
        ENDIF.
      ELSE.
*       All items will be processed together, no error
      ENDIF.
    ENDLOOP.

********************************************************************
* Special processing for garnishments and cautions
********************************************************************
  ENDIF.
ENDMETHOD.


method IF_EX_FI_INT_CUS01~INT_LIST_01.
  RETURN. "empty implementation for this method
*  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
*    IS NOT INITIAL.
*...
*  ENDIF.
endmethod.


method IF_EX_FI_INT_CUS01~INT_LIST_02.
  RETURN. "empty implementation for this method
*  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
*    IS NOT INITIAL.
*...
*  ENDIF.
endmethod.


method IF_EX_FI_INT_CUS01~INT_LIST_03.
  RETURN. "empty implementation for this method
*  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
*    IS NOT INITIAL.
*...
*  ENDIF.
endmethod.


method IF_EX_FI_INT_CUS01~INT_MODIFY_ITEMS.
  RETURN.
*  DATA: ls_log TYPE LINE OF fint_tt_log,
*        ls_item TYPE LINE OF fint_tt_intit_extf,
*        lt_log TYPE fint_tt_log,
*        lt_item TYPE fint_tt_intit_extf.
*
*  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
*    IS NOT INITIAL.
*
*    lt_log[] = ct_log[].
*    lt_item[] = ct_items[].
*    CLEAR: ct_log, ct_items.
*
*    LOOP AT lt_item INTO ls_item.
*      IF NOT ls_item-int_end IS INITIAL.
*        ls_item-int_end = ls_item-augdt.
*      ENDIF.
*      APPEND ls_item TO ct_items.
*    ENDLOOP.
*
*    LOOP AT lt_log INTO ls_log.
*      IF NOT ls_log-int_end IS INITIAL.
*        CLEAR ls_item.
*        READ TABLE ct_items WITH KEY belnr = ls_log-belnr
*                                    gjahr = ls_log-gjahr
*                                     buzei = ls_log-buzei
*                            INTO ls_item.
*        IF sy-subrc = 0.
*          ls_log-int_end = ls_item-augdt.
*        ENDIF.
*      ENDIF.
*      IF ls_log-msgno = '252'.
*      ELSE.
*        IF ls_log-msgno = '321'.
*          CLEAR: ls_item, ls_log-ltext.
*          READ TABLE ct_items WITH KEY belnr = ls_log-belnr
*                                      gjahr = ls_log-gjahr
*                                       buzei = ls_log-buzei
*                              INTO ls_item.
*          MESSAGE ID 'FPIA' TYPE 'I' NUMBER '321'
*                   INTO ls_log-ltext WITH ls_item-int_rate ls_item-int_begin.
*        ENDIF.
*        APPEND ls_log TO ct_log.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
endmethod.


METHOD IF_EX_FI_INT_CUS01~INT_POST.
* The basic functionality for the FPIA solution
* is that only the paid documents are relevant
* for the interest calculation
* In the post method, the account assignment and the
* document split will be generated for the interest documents
* Also, a BAdI is called if an implementation exists, this BAdI
* will allow to derive or substitute the fields of the park doc.
* At the end an interest document will be parked.
************************************************************************
* reworked by note 1832818
************************************************************************
  CONSTANTS: lc_ready TYPE int_status VALUE 'READY',
             lc_posnr TYPE posnr_acc  VALUE '0000000000',
             lc_fixam TYPE bewegart   VALUE 'FIXAM'.


  DATA: lt_items      TYPE fint_tt_intit_extf,   "Items to be processed
        ls_items      TYPE intit_extf,           "Header for lt_items
        lt_sum        TYPE fint_tt_intit_extf,   "to be used in the BAdI
        lt_bseg       TYPE TABLE OF bseg,        "GL items to split
        "amount
        ls_bseg       TYPE bseg,                 "Header for lt_bseg
        lt_bseg_ret_l TYPE TABLE OF bseg,        "Retention 1 line
        ls_bseg_ret_l TYPE bseg,               "Header for lt_bseg_ret_l
        lt_bseg_ret   TYPE TABLE OF bseg,        "Retention lines
        ls_bseg_ret   TYPE bseg,                 "Header for lt_bseg_ret
        lt_bseg_ven   TYPE TABLE OF bseg,        "Vendor lines
        ls_bseg_ven   TYPE bseg,                 "Header for lt_bseg_ven
        lt_bseg_aux   TYPE TABLE OF bseg,        "Items from original
        "doc.of ret
        lt_bkpf       TYPE TABLE OF bkpf,
        ls_bkpf       TYPE bkpf,
        ls_accit      TYPE LINE OF fint_tt_accit,
        ls_accit_ret  TYPE LINE OF fint_tt_accit,
        ls_accit_wa   TYPE LINE OF fint_tt_accit,
        lt_accit      TYPE fint_tt_accit,        "Final accit to be post
        ls_acccr      TYPE LINE OF fint_tt_acccr,
        ls_acccrha    TYPE LINE OF fint_tt_acccr, "ID higher amount line
        lt_acccr      TYPE fint_tt_acccr,        "Final acccr to be post
        lt_acccr_aux  TYPE fint_tt_acccr,
        lv_posnr      TYPE posnr_acc,
        lt_dd03l      TYPE ddfields,
        ls_dd03l      TYPE dfies,
        s_text        TYPE char50,
        s_text1       TYPE char50,
        ls_item       TYPE fpia_c_interest_assignments,
        ls_item_key   TYPE glt9_bseg_key_wa,
        ls_bseg_key   TYPE glt9_bseg_key_wa,
        ls_t056u      TYPE t056u , " Get terms
        " of payment from interest indicator
        lv_value      TYPE p DECIMALS 5,
        lv_total      TYPE p DECIMALS 2,
        lv_totdoc     TYPE p DECIMALS 2,
        lv_sum        TYPE p DECIMALS 2,
        lv_sumrd      TYPE p DECIMALS 5,
        lv_highamount TYPE p DECIMALS 2,
        lv_difference TYPE p DECIMALS 2,
        lv_vendorl    TYPE p,
        lt_fi_ret     TYPE TABLE OF fpia_fi_idx,
        ls_fi_ret     TYPE fpia_fi_idx,
        lo_ref_rule   TYPE REF TO fpia_transfer,
        l_flg_rule    TYPE flag,
        con_on        TYPE xfeld    VALUE 'X',
        con_off       TYPE xfeld    VALUE ' ',
        lv_recproc    TYPE i,     " Records to be processed
        lv_onlyfix    TYPE flag,
        l_ref_error   TYPE REF TO cx_badi_not_implemented.  "#EC needed

* Variables for BSEG selection
  DATA: fagl_where   TYPE  tt_rsdswhere,
        fagl_where_w TYPE LINE OF tt_rsdswhere.

* Log variables
  DATA: ls_log   LIKE LINE OF ct_log,
        lv_msgid TYPE symsgid,
        lv_msgno TYPE symsgno,
        lv_msgty TYPE symsgty,
        lv_msgv1 TYPE symsgv,
        lv_msgv2 TYPE symsgv.


  FIELD-SYMBOLS: <fs_1>    TYPE any,
                 <fs_2>    TYPE any,
                 <l_acccr> TYPE acccr,
                 <ls_bseg> TYPE bseg.

  field-symbols: <fs_accit> TYPE accit.
  field-symbols: <fs_acchd> TYPE acchd.
  data: ls_bseg_int type bseg.
  break zhm000000052.
  loop at ct_accit assigning <fs_accit> where rebzg <> ''.
*    if <fs_accit>-xblnr is initial.
*      loop at ct_items into ls_items
*           where bukrs = <fs_accit>-bukrs
*             and gjahr = <fs_accit>-rebzj
*             and belnr = <fs_accit>-rebzg
*             and buzei = <fs_accit>-rebzz.
*        <fs_accit>-zfbdt = ls_items-zfbdt.
*        <fs_accit>-maber = ls_items-maber.
**        <fs_accit>-xblnr = ls_items-xblnr.
*      endloop.
      select single * from bseg into ls_bseg_int
           where bukrs = <fs_accit>-bukrs
             and gjahr = <fs_accit>-rebzj
             and belnr = <fs_accit>-rebzg
             and buzei = <fs_accit>-rebzz.
      if sy-subrc = 0.
        <fs_accit>-zfbdt = ls_bseg_int-zfbdt.
        <fs_accit>-maber = ls_bseg_int-maber.
      endif.
*    endif.
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr                   = '21'
          object                        = 'LOTNO'
*         QUANTITY                      = '1'
          SUBOBJECT                     = <fs_accit>-bukrs
*         TOYEAR                        = '0000'
*         IGNORE_BUFFER                 = ' '
        IMPORTING
          NUMBER                        = <fs_accit>-lotkz
*         QUANTITY                      =
*         RETURNCODE                    =
*       EXCEPTIONS
*         INTERVAL_NOT_FOUND            = 1
*         NUMBER_RANGE_NOT_INTERN       = 2
*         OBJECT_NOT_FOUND              = 3
*         QUANTITY_IS_0                 = 4
*         QUANTITY_IS_NOT_1             = 5
*         INTERVAL_OVERFLOW             = 6
*         BUFFER_OVERFLOW               = 7
*         OTHERS                        = 8
                .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      else.
*        <fs_accit>-xref1 = 'SZM1'.
*        loop at ct_acchd assigning <fs_acchd>.
*          <fs_acchd>-psoty = '02'.
*        endloop.
      ENDIF.

  endloop.

  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
        IS NOT INITIAL
        AND cs_ipf-koart EQ 'K'
        "Means that the calling TCODE is FINTAP
        AND cl_fpia_ioa_switch_check=>company_active( cs_ipf-bukrs ) =
        'X'.

* Control table: check if it's an invoice reference
    IF is_t056u_ext-postrebzg = 'X'.
      lv_posnr = lc_posnr.

      CLEAR: lv_recproc, lv_onlyfix.

      LOOP AT ct_items INTO ls_items
        WHERE array = cs_ipf-array
          AND int_status = lc_ready.
        ADD 1 TO lv_recproc.
      ENDLOOP.
* Get the lines from ct_items that will be processed within the same
* array
      LOOP AT ct_items INTO ls_items
        WHERE array = cs_ipf-array
          AND int_status = lc_ready.

        IF lv_recproc = 1 AND
            ls_items-int_sign EQ lc_fixam.
* We only have 1 record to process and it is only a fix amount
          MOVE 'X' TO lv_onlyfix.
        ENDIF.

        CLEAR: lv_sum, lv_sumrd, lv_highamount.
* Get vendor line item
        IF    ls_items-rebzg IS NOT INITIAL
          AND ls_items-rebzj IS NOT INITIAL
          AND ls_items-bukrs IS NOT INITIAL.
          READ TABLE ct_accit INTO ls_accit
                        WITH KEY koart = 'K'
                                 taxit = ' '
                                 rebzg = ls_items-rebzg
                                 rebzj = ls_items-rebzj
                                 rebzz = ls_items-rebzz.
        ELSE.
          READ TABLE ct_accit INTO ls_accit
                              WITH KEY koart = 'K'
                                       taxit = ' '
                                       rebzg = ls_items-belnr
                                       rebzj = ls_items-gjahr
                                       rebzz = ls_items-buzei.
        ENDIF.
        IF sy-subrc NE 0. "If no vendor line is found,
          EXIT.           " we are not processing FINTAP
        ENDIF.

        READ TABLE ct_acccr INTO ls_acccr
                            WITH KEY posnr = ls_accit-posnr.
        ADD 1 TO lv_posnr.
        MOVE lv_posnr  TO: ls_acccr-posnr,
                           ls_accit-posnr,
                           ls_items-acc_posnr.

        MODIFY TABLE ct_items FROM ls_items TRANSPORTING acc_posnr.

        ls_acccr-wrbtr = ls_items-int_amount. "Copy vendor line
        lv_total = abs( ls_acccr-wrbtr ).

        ls_accit-bschl = ls_items-bschl.
        ls_accit-shkzg = ls_items-shkzg.

**************** Get account info *-START-******************************
        CALL METHOD me->get_gl_account
          EXPORTING
            is_ipf   = cs_ipf
            is_t001  = is_t001
            is_acccr = ls_acccr
            is_items = ls_items
          CHANGING
            cs_accit = ls_accit.
********************** Get account info *-END-**************************
********** Get Terms of Payment for Interest indicator *-START-*********
        SELECT SINGLE * FROM t056u INTO ls_t056u
                            WHERE vzskz EQ ls_items-int_ind.
        IF sy-subrc = 0.
          ls_accit-zterm = ls_t056u-zterm.
        ENDIF.
********** Get Terms of Payment for Interest indicator *-END-***********


        COLLECT ls_accit INTO lt_accit.
        COLLECT ls_acccr INTO lt_acccr.

        IF ls_items-int_sign NE lc_fixam
          OR lv_onlyfix = 'X'.

          CLEAR: ls_accit, ls_acccr.

          READ TABLE ct_accit INTO ls_accit
                              WITH KEY koart = 'S'
                                       taxit = ' '.
          IF sy-subrc = 0.
            READ TABLE ct_acccr INTO ls_acccr
                                WITH KEY posnr = ls_accit-posnr.

* Get the original document
            MOVE 'KOART NE ''K''' TO fagl_where_w.
            APPEND fagl_where_w TO fagl_where.

            CALL FUNCTION 'FAGL_GET_BSEG'
              EXPORTING
                i_bukrs         = ls_items-bukrs
                i_belnr         = ls_items-belnr
                i_gjahr         = ls_items-gjahr
                it_where_clause = fagl_where
              IMPORTING
                et_bseg         = lt_bseg.

            CLEAR fagl_where_w.
            REFRESH fagl_where.

            IF lt_bseg IS INITIAL. " Retentions, Down Payments?
              IF ls_items-rebzt = 'U'.  "DownPayment

                CONCATENATE  'BUZEI NE ''' ls_items-buzei ''''
                             INTO fagl_where_w.
                APPEND fagl_where_w TO fagl_where.

                CALL FUNCTION 'FAGL_GET_BSEG'
                  EXPORTING
                    i_bukrs         = ls_items-bukrs
                    i_belnr         = ls_items-belnr
                    i_gjahr         = ls_items-gjahr
                    it_where_clause = fagl_where
                  IMPORTING
                    et_bseg         = lt_bseg.

                CLEAR fagl_where_w.
                REFRESH fagl_where.

              ELSE." Retention
* Get original FI invoice from MM invoice
                SELECT * FROM bkpf INTO TABLE lt_bkpf
                WHERE awtyp = ls_items-awtyp
                  AND awkey = ls_items-awkey
                  AND awsys = ls_items-awsys .
                IF sy-subrc = 0.
* Check if is an FI or an MM Retention
                  IF ls_items-awtyp EQ 'BKPF'.

                    IF ls_items-rebzg IS NOT INITIAL.  "N2860735: Avoid DUMP

*   Get the original document
                      MOVE 'KOART NE ''K''' TO fagl_where_w.
                      APPEND fagl_where_w TO fagl_where.

                      CALL FUNCTION 'FAGL_GET_BSEG'
                        EXPORTING
                          i_bukrs         = ls_items-bukrs
                          i_belnr         = ls_items-rebzg
                          i_gjahr         = ls_items-rebzj
                          it_where_clause = fagl_where
                        IMPORTING
                          et_bseg         = lt_bseg.

                      CLEAR fagl_where_w.
                      REFRESH fagl_where.

*   Get Vendor line item from the original document
                      CALL FUNCTION 'FAGL_GET_BSEG'
                        EXPORTING
                          i_bukrs = ls_items-bukrs
                          i_belnr = ls_items-rebzg
                          i_gjahr = ls_items-rebzj
                          i_buzei = ls_items-rebzz
                        IMPORTING
                          et_bseg = lt_bseg_ven.

                      READ TABLE lt_bseg_ven INTO ls_bseg_ven INDEX 1.


                      LOOP AT lt_bseg INTO ls_bseg.
                        ls_bseg-wrbtr = ( ls_items-wrbtr * ls_bseg-wrbtr )
                                         / ls_bseg_ven-wrbtr.
                        ls_bseg-bschl = ls_bseg_ven-bschl.
                        ls_bseg-shkzg = ls_bseg_ven-shkzg.
                        MODIFY lt_bseg FROM ls_bseg.
                      ENDLOOP.

                    ELSE.   "N2860735: Avoid DUMP => BEGIN

                      IF 1 = 2.
                        MESSAGE e308(ficore)
                          WITH 'IDENTIFY DOCUMENT' lv_msgv2.
                      ENDIF.
                      MOVE: '308'                TO lv_msgno,
                            'FICORE'             TO lv_msgid,
                            'E'                  TO lv_msgty,
                            'IDENTIFY DOCUMENT:' TO lv_msgv1.
                      CONCATENATE ls_items-belnr
                                  ls_items-bukrs
                                  ls_items-gjahr
                             INTO lv_msgv2 SEPARATED BY '/'.

                      MESSAGE ID lv_msgid TYPE lv_msgty NUMBER lv_msgno
                        INTO ls_log-ltext WITH lv_msgv1 lv_msgv2.

                      COLLECT ls_log INTO ct_log.
                      MOVE 'ERROR' TO cd_post_status.
                      MODIFY TABLE ct_items FROM ls_items
                        TRANSPORTING int_status.
                      RETURN.

                    ENDIF.  "N2860735: Avoid DUMP => END

                  ELSEIF ls_items-awtyp EQ 'RMRP'.
* Delete the document itself(retention), to find the FI original doc.
                    DELETE lt_bkpf WHERE bukrs EQ ls_items-bukrs
                                     AND belnr EQ ls_items-belnr
                                     AND gjahr EQ ls_items-gjahr.

                    CALL FUNCTION 'FAGL_GET_BSEG'
                    "Get the retention line
                      EXPORTING
                        i_bukrs = ls_items-bukrs
                        i_belnr = ls_items-belnr
                        i_gjahr = ls_items-gjahr
                        i_buzei = ls_items-buzei
                      IMPORTING
                        et_bseg = lt_bseg_ret_l.

                    READ TABLE lt_bseg_ret_l INTO ls_bseg_ret_l INDEX 1.

                    LOOP AT lt_bkpf INTO ls_bkpf.
                      CLEAR ls_bseg.

                      MOVE 'KOART NE ''K'''
                        TO fagl_where_w.
                      APPEND fagl_where_w TO fagl_where.

                      CALL FUNCTION 'FAGL_GET_BSEG'
                      "Get all lines of
                        EXPORTING
                        " original Invoice
                          i_bukrs         = ls_bkpf-bukrs
                          i_belnr         = ls_bkpf-belnr
                          i_gjahr         = ls_bkpf-gjahr
                          it_where_clause = fagl_where
                        IMPORTING
                          et_bseg         = lt_bseg_aux.

                      CLEAR fagl_where_w.
                      REFRESH fagl_where.

                      LOOP AT lt_bseg_aux INTO ls_bseg.
                        IF NOT ls_bseg_ret_l-ebeln IS INITIAL
                           AND ls_bseg_ret_l-ebeln EQ ls_bseg-ebeln
                           AND ls_bseg_ret_l-ebelp EQ ls_bseg-ebelp.
                          ls_bseg-wrbtr = ls_bseg_ret_l-wrbtr.
* Only the corresponding line of the original document

                          APPEND ls_bseg TO lt_bseg.

                        ELSEIF   ls_bseg_ret_l-ebeln IS INITIAL
                        AND NOT  ls_bseg-ebeln       IS INITIAL.
* If PO number is initial, it means that we are processing all item
* In this case, we need to match the line from bseg with the PO number
* and item
* If the bseg line(from the original document) do not have the PO,
* this means that it's not a retention, it's a normal GL line,
* therefore this line should not be processed as a retention, it will
* be processed with the original invoice

                          CONCATENATE  'BUZEI NE ''' ls_items-buzei
                                     ''' AND EBELN EQ ''' ls_bseg-ebeln
                                     ''' AND EBELP EQ ''' ls_bseg-ebelp
                                       ''''
                                       INTO fagl_where_w.
                          APPEND fagl_where_w TO fagl_where.

                          CALL FUNCTION 'FAGL_GET_BSEG'
                            EXPORTING
                              i_bukrs         = ls_items-bukrs
                              i_belnr         = ls_items-belnr
                              i_gjahr         = ls_items-gjahr
                              it_where_clause = fagl_where
                            IMPORTING
                              et_bseg         = lt_bseg_ret.

                          CLEAR fagl_where_w.
                          REFRESH fagl_where.
                          LOOP AT lt_bseg_ret INTO ls_bseg_ret.
                            ls_bseg-wrbtr = ls_bseg_ret-wrbtr.
                            ls_bseg-bschl = ls_bseg_ret-bschl.
                            ls_bseg-shkzg = ls_bseg_ret-shkzg.
                            APPEND ls_bseg TO lt_bseg.
                          ENDLOOP.
                        ENDIF.
                      ENDLOOP.
                    ENDLOOP.
                  ENDIF.
                ELSE.
                  IF 1 = 2.
                    MESSAGE e308(ficore)
                      WITH 'IDENTIFY DOCUMENT' lv_msgv2.
                  ENDIF.
                  MOVE: '308'                TO lv_msgno,
                        'FICORE'             TO lv_msgid,
                        'E'                  TO lv_msgty,
                        'IDENTIFY DOCUMENT:' TO lv_msgv1.
                  CONCATENATE ls_items-belnr
                              ls_items-bukrs
                              ls_items-gjahr
                         INTO lv_msgv2 SEPARATED BY '/'.

                  MESSAGE ID lv_msgid TYPE lv_msgty NUMBER lv_msgno
                    INTO ls_log-ltext WITH lv_msgv1 lv_msgv2.

                  COLLECT ls_log INTO ct_log.
                  MOVE 'ERROR' TO cd_post_status.
                  MODIFY TABLE ct_items FROM ls_items
                    TRANSPORTING int_status.
                  RETURN.
                ENDIF.
              ENDIF.
            ENDIF.

            IF lt_bseg IS NOT INITIAL.

              IF ls_items-rebzt = 'U'.  "DownPayment

                CONCATENATE  'BUZEI NE ''' ls_items-buzei ''''
                             INTO fagl_where_w.
                APPEND fagl_where_w TO fagl_where.

                CALL FUNCTION 'FAGL_GET_BSEG'
                  EXPORTING
                    i_bukrs         = ls_items-bukrs
                    i_belnr         = ls_items-belnr
                    i_gjahr         = ls_items-gjahr
                    it_where_clause = fagl_where
                  IMPORTING
                    et_bseg         = lt_bseg.

                CLEAR fagl_where_w.
                REFRESH fagl_where.
              ENDIF.

* We are getting the Tax lines at this point we need to distribute
* the tax amounts evenly (considering the TAX code) by all the
* document lines
              CALL METHOD me->distribute_tax
                CHANGING
                  ct_bseg = lt_bseg.

              LOOP AT lt_bseg INTO ls_bseg.
                CLEAR ls_bseg-werks.
                ADD 1 TO lv_posnr.
                MOVE lv_posnr TO: ls_acccr-posnr, ls_accit-posnr.
                ls_accit-bschl = ls_bseg-bschl.
                ls_accit-shkzg = ls_bseg-shkzg.
* Divide the amount by the FM account assignment determination
* Line without Fix Amount
                IF ls_items-int_sign NE lc_fixam.
* We will keep the value with 5 decimals to proccess the roundings
                  lv_value =  ( ls_items-int_days *
                  ( ls_items-int_rate / 100 ) *
                  ls_bseg-wrbtr ) / ls_items-int_basedays.
                ELSE.
* Line with Fix Amount
                  lv_value = ( ls_items-int_amount * ls_bseg-wrbtr ) /
                   ls_items-int_basamt.
                ENDIF.


                IF ls_accit-shkzg = 'H' AND lv_value > 0 OR
                   ls_accit-shkzg = 'S' AND lv_value < 0.
                  lv_value =  lv_value * -1.
                ENDIF.

                MOVE lv_value TO ls_acccr-wrbtr.

                MOVE-CORRESPONDING ls_bseg TO ls_item.
                ls_item-fkber = ls_bseg-fkber_long.
                ls_item-ps_psp_pnr = ls_bseg-projk.

                MOVE-CORRESPONDING ls_item TO ls_accit.
*** Clear BZDAT field
                CLEAR ls_accit-bzdat.

*** Account assignment for customer fields
                CALL FUNCTION 'DDIF_FIELDINFO_GET'
                  EXPORTING
                    tabname        = 'CI_COBL'
                  TABLES
                    dfies_tab      = lt_dd03l
                  EXCEPTIONS
                    not_found      = 1
                    internal_error = 2
                    OTHERS         = 3.

                IF sy-subrc = 0.
* Get Acc Assignment for Customer Fields
                  LOOP AT lt_dd03l INTO ls_dd03l.
                    CLEAR: s_text, s_text1.
                    CONCATENATE 'LS_ACCIT-' ls_dd03l-fieldname
                      INTO s_text.
                    CONCATENATE 'LS_BSEG-'  ls_dd03l-fieldname
                      INTO s_text1.

                    ASSIGN (s_text)   TO <fs_1>.
                    ASSIGN (s_text1)  TO <fs_2>.

                    <fs_1> = <fs_2>.
                  ENDLOOP.
                ENDIF.

                CLEAR ls_accit_wa.

                ls_item_key-bukrs = ls_items-bukrs.
                ls_item_key-belnr = ls_items-belnr.
                ls_item_key-gjahr = ls_items-gjahr.
                ls_item_key-buzei = ls_items-buzei.

                ls_bseg_key-bukrs = ls_bseg-bukrs.
                ls_bseg_key-belnr = ls_bseg-belnr.
                ls_bseg_key-gjahr = ls_bseg-gjahr.
                ls_bseg_key-buzei = ls_bseg-buzei.

                CALL METHOD me->get_acc_assign
                  EXPORTING
                    is_t056u_ext = is_t056u_ext
                    is_accit     = ls_accit
                    is_acccr     = ls_acccr
                    is_item_key  = ls_item_key "Vendor line
                    is_bseg_key  = ls_bseg_key "Bseg line
                  IMPORTING
                    es_accit     = ls_accit_wa.

                ls_accit = ls_accit_wa.

**************** Get account info *-START-******************************
                CALL METHOD me->get_gl_account
                  EXPORTING
                    is_ipf   = cs_ipf
                    is_t001  = is_t001
                    is_acccr = ls_acccr
                    is_items = ls_items
                  CHANGING
                    cs_accit = ls_accit.
********************** Get account info *-END-**************************

********** Process Rounding Differences *-START-************************
                lv_sumrd = lv_sumrd + lv_value.
                lv_sum = lv_sum + ls_acccr-wrbtr.
                IF abs( ls_acccr-wrbtr ) >= lv_highamount.
                  lv_highamount  = abs( ls_acccr-wrbtr ).
                  ls_acccrha = ls_acccr.
                ENDIF.
********** Process Rounding Differences *-END-**************************
                COLLECT ls_accit INTO lt_accit.
                COLLECT ls_acccr INTO lt_acccr.
              ENDLOOP.
            ELSE.
              IF 1 = 2.
                MESSAGE e308(ficore)
                  WITH 'SELECT BSEG DATA' lv_msgv2.
              ENDIF.
              MOVE: '308'                TO lv_msgno,
                    'FICORE'             TO lv_msgid,
                    'E'                  TO lv_msgty,
                    'SELECT BSEG DATA'   TO lv_msgv1.
              CONCATENATE ls_items-belnr
                          ls_items-bukrs
                          ls_items-gjahr
                     INTO lv_msgv2 SEPARATED BY '/'.

              MESSAGE ID lv_msgid TYPE lv_msgty NUMBER lv_msgno
                INTO ls_log-ltext WITH lv_msgv1 lv_msgv2.
              COLLECT ls_log INTO ct_log.
              MOVE 'ERROR' TO cd_post_status.
              MODIFY TABLE ct_items FROM ls_items
                TRANSPORTING int_status.
              RETURN.
            ENDIF.
          ELSE.
            " ISSUE ERROR ?!?!??!
          ENDIF.

********** Process Rounding Differences *-START-***********************
          MOVE  abs( lv_sumrd ) TO lv_totdoc.
          "IF lv_total = lv_totdoc. "Note 3315483
            IF lv_total  <>  abs( lv_sum ).
              IF lv_sum > 0.
                lv_difference =  lv_total - lv_sum .
              ELSE.
                lv_difference =  lv_total + lv_sum .
              ENDIF.
              READ TABLE lt_acccr FROM ls_acccrha
                                  ASSIGNING <l_acccr>.
              IF sy-subrc = 0.
                IF <l_acccr>-wrbtr >= 0.
                  <l_acccr>-wrbtr = <l_acccr>-wrbtr + lv_difference.
                ELSEIF <l_acccr>-wrbtr < 0.
                  <l_acccr>-wrbtr = <l_acccr>-wrbtr - lv_difference.
                ENDIF.
              ENDIF.
            ENDIF.
          "ENDIF. "Note 3315483
************ Process Rounding Differences *-END-************************
        ENDIF.
      ENDLOOP.

* PROCESS FIXED AMOUNT
      IF lv_onlyfix IS INITIAL.
        CALL METHOD me->fixed_amount
          EXPORTING
            is_ipf   = cs_ipf
            is_t001  = is_t001
          CHANGING
            ct_accit = lt_accit
            ct_acccr = lt_acccr
            ct_items = ct_items.
      ENDIF.

      REFRESH: ct_accit, ct_acccr.

      CALL METHOD me->collect_acc
        EXPORTING
          is_ipf   = cs_ipf
          it_accit = lt_accit
          it_acccr = lt_acccr
        CHANGING
          ct_accit = ct_accit
          ct_acccr = ct_acccr
          ct_items = ct_items.
    ENDIF.

*** Call Badi FPIA_TRANSFER_RULES *-BEGIN-******************************
*Allows to derive or substitute the fields of the interest park doc
    lt_items[] = ct_items[].
    lt_sum[]   = ct_sum[].

    TRY.
        GET BADI lo_ref_rule.
        l_flg_rule = con_on.
      CATCH cx_badi_not_implemented INTO l_ref_error.
        l_flg_rule = con_off.
    ENDTRY.

    IF l_flg_rule = con_on.
      CALL BADI lo_ref_rule->execute
        EXPORTING
          iis_t001      = is_t001
          iis_kna1      = is_kna1
          iis_lfa1      = is_lfa1
          iis_lfb1      = is_lfb1
          iis_t056u_ext = is_t056u_ext
          iit_frange    = it_frange
          iit_items     = lt_items
          iit_sum       = lt_sum
        CHANGING
          cct_acchd     = ct_acchd[]
          cct_accit     = ct_accit[]
          cct_acccr     = ct_acccr[]
          cct_accwt     = ct_accwt[].
    ENDIF.
*** Call Badi FPIA_TRANSFER_RULES *-END-********************************
*** Post the parked interest document

    CALL FUNCTION 'FI_INTIT_PARK'
      EXPORTING
        it_accit       = ct_accit
        it_acccr       = ct_acccr
        it_accwt       = ct_accwt
      IMPORTING
        et_accposnr    = ct_accposnr
        ed_post_status = cd_post_status
      CHANGING
        ct_acchd       = ct_acchd.

  ENDIF.

ENDMETHOD.


method IF_EX_FI_INT_CUS01~INT_PRINT_OPTIONS.
  RETURN. "empty implementation for this method
*  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
*    IS NOT INITIAL.
*...
*  ENDIF.
endmethod.


method IF_EX_FI_INT_CUS01~INT_PRINT_RESULTS.
  RETURN. "empty implementation for this method
*  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
*    IS NOT INITIAL.
*...
*  ENDIF.
endmethod.


method IF_EX_FI_INT_CUS01~INT_PRINT_SPOOL_CLOSED.
  RETURN. "empty implementation for this method
*  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
*    IS NOT INITIAL.
*...
*  ENDIF.
endmethod.


method IF_EX_FI_INT_CUS01~INT_REVERSE.

  DATA:     ls_intithex    TYPE fint_ts_intithex,
            ls_intititx    TYPE fint_ts_intititx,
            go_int_manager TYPE REF TO cl_fpia_srv_int_mgr,
            lo_interest    TYPE REF TO cl_fpia_srv_interest,
*           ls_interest    TYPE fpia_interest,
            ls_fi_key      TYPE fpia_s_key_fi.
  DATA:    lo_exception  TYPE REF TO cx_fpia_common_exception,
           lv_fpia_fi_idx  TYPE fpia_fi_idx.

  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
    IS NOT INITIAL.

    go_int_manager = cl_fpia_factory=>get_interest_manager( ).

    LOOP AT ct_intithex INTO ls_intithex WHERE xselp = 'X'.
      READ TABLE ct_intititx INTO ls_intititx
      WITH KEY bukrs_to = ls_intithex-bukrs
               gjahr_to = ls_intithex-gjahr
               belnr_to = ls_intithex-belnr
*             buzei_to = ls_intithex-buzei
               belnr    = ls_intithex-array.
      ls_fi_key-bukrs = ls_intititx-bukrs.
      ls_fi_key-gjahr = ls_intititx-gjahr.
      ls_fi_key-belnr = ls_intititx-belnr.
      ls_fi_key-buzei = ls_intititx-buzei.

      SELECT SINGLE * FROM  fpia_fi_idx INTO lv_fpia_fi_idx
             WHERE  bukrs   = ls_fi_key-bukrs
             AND    belnr   = ls_fi_key-belnr
             AND    gjahr   = ls_fi_key-gjahr
             AND    buzei   = ls_fi_key-buzei.
*Check if the doc.is already deleted
      CHECK lv_fpia_fi_idx-int_doc_exist NE 'D'.
      TRY.
          lo_interest = go_int_manager->get_interest_by_fi( ls_fi_key ).
          IF lo_interest IS BOUND.
            lo_interest->set_mode( iv_mode = 'C' ).
            lo_interest->set_int_doc_exist( is_key = ls_fi_key  iv_int_doc_exist = 'D').
          ENDIF.
        CATCH cx_fpia_common_exception INTO lo_exception. "#EC NO_HANDLER
          MESSAGE lo_exception TYPE 'E'.
      ENDTRY.
    ENDLOOP.
  ENDIF.
endmethod.


method IF_EX_FI_INT_CUS01~INT_SEL_MOD.
   RETURN. "empty implementation for this method
*  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
*    IS NOT INITIAL.
*...
*  ENDIF.
endmethod.


method IF_EX_FI_INT_CUS01~INT_SHOW_BUTTONS.
  RETURN. "empty implementation for this method
*  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
*    IS NOT INITIAL.
*...
*  ENDIF.
endmethod.


METHOD IF_EX_FI_INT_CUS01~INT_WRITE_ITEMS.

  DATA:     ls_intithe     TYPE intithe,
            go_int_manager TYPE REF TO cl_fpia_srv_int_mgr,
            lo_interest    TYPE REF TO cl_fpia_srv_interest,
*           ls_interest    TYPE fpia_interest,
            ls_fi_key      TYPE fpia_s_key_fi.

************************************************************************
*** IoA-Data as defaults for the interest document

  DATA: lo_int_mgr     TYPE REF TO cl_fpia_srv_int_mgr,
        is_ioadata     TYPE fpia_s_interest_fields,
        is_data        TYPE fpia_s_payment_terms,
        ls_set_field   TYPE fpia_s_interest_set_field,
*         lo_exception   TYPE REF TO cx_fpia_common_exception,
        ls_key_fi      TYPE fpia_s_key_fi,
        ls_sum         TYPE LINE OF fint_tt_intit_extf,
        ls_intitit     TYPE LINE OF fint_tt_intitit,
        ls_vbsegk      TYPE vbsegk,
        ls_intitfx     TYPE intitfx,
*          ls_vzskz       TYPE fpia_int_vzskz,
        ls_vzskz       TYPE fpia_intcal_ind,
lv_vzskz_new   TYPE t056-vzskz.                                                                .

*    FIELD-SYMBOLS <fs_vbsegk> TYPE vbsegk.

  IF cl_fpia_ioa_ex_switch_check=>filocfr_sfws_cs_02( )
    IS NOT INITIAL
    AND is_ipf-koart EQ 'K'    "Means that the calling TCODE is FINTAP
    AND cl_fpia_ioa_switch_check=>company_active( is_ipf-bukrs ) = 'X'.

    go_int_manager = cl_fpia_factory=>get_interest_manager( ).
    lo_int_mgr = cl_fpia_factory=>get_interest_manager( ).

    IF ct_intithe IS NOT INITIAL.

    LOOP AT ct_intithe INTO ls_intithe.
      ls_fi_key-bukrs = ls_intithe-bukrs.
      ls_fi_key-gjahr = ls_intithe-gjahr.
      ls_fi_key-belnr = ls_intithe-belnr.
      ls_fi_key-buzei = ls_intithe-buzei.
      TRY.
          lo_interest = go_int_manager->get_interest_by_fi( ls_fi_key ).
          IF lo_interest IS BOUND.
            lo_interest->set_mode( iv_mode = 'C' ).
            lo_interest->set_int_doc_exist( is_key = ls_fi_key ).
          ENDIF.
        CATCH cx_fpia_common_exception.                 "#EC NO_HANDLER
      ENDTRY.
    ENDLOOP.

      LOOP AT ct_intitit INTO ls_intitit.
      TRY.
          lo_int_mgr->start_tr( ).
          READ TABLE it_items INTO ls_sum WITH KEY bukrs = ls_intitit-bukrs
                                                   belnr = ls_intitit-belnr
                                                   gjahr = ls_intitit-gjahr
                                                   buzei = ls_intitit-buzei.
            SELECT SINGLE * FROM vbsegk
              INTO CORRESPONDING FIELDS OF ls_vbsegk
                WHERE ausbk = ls_intitit-bukrs_to
                                  AND gjahr = ls_intitit-gjahr_to
                                  AND belnr = ls_intitit-belnr_to
                                  AND buzei = ls_intitit-buzei_to.
* Table  fpia_int_vzskz has been replaced by fpia_intcal_ind
*          SELECT SINGLE * FROM fpia_int_vzskz INTO ls_vzskz WHERE vzskz = ls_intitit-int_ind.
            SELECT SINGLE * FROM fpia_intcal_ind INTO ls_vzskz
              WHERE vzskz = ls_intitit-int_ind.
          IF sy-subrc = 0.
            lv_vzskz_new = ls_vzskz-vzskz_int.
          ELSE.
            lv_vzskz_new = ls_intitit-int_ind.
          ENDIF.
* create interest and set data
          lo_interest = lo_int_mgr->create_interest( ).
          is_ioadata-zfbdt = ls_vbsegk-zfbdt.
          is_ioadata-zterm = ls_vbsegk-zterm.
          is_ioadata-zbd1t = ls_vbsegk-zbd1t.
          is_ioadata-zbd1p = ls_vbsegk-zbd1p.
          is_ioadata-zbd2t = ls_vbsegk-zbd2t.
          is_ioadata-zbd2p = ls_vbsegk-zbd2p.
          is_ioadata-zbd3t = ls_vbsegk-zbd3t.
          is_ioadata-rec_date_br      = sy-datum.
          is_ioadata-rec_date_ac      = sy-datum.
          is_ioadata-inv_validation_b = sy-datum.
*        is_ioadata-inv_validation_a = sy-datum.
          is_ioadata-vzskz            = lv_vzskz_new.
          ls_set_field-gsber = ls_vbsegk-gsber.
          ls_set_field-ioa_fields = is_ioadata.
* set change mode to lock record
          lo_interest->set_mode( lo_interest->co_mode_change ).
          lo_interest->set_interest( ls_set_field ).
          lo_interest->set_inv_val_date_br( is_ioadata-inv_validation_b ).
*        lo_interest->set_inv_val_date_ac( is_ioadata-inv_validation_a ).
* assign FI_IDX to interest
          ls_key_fi-bukrs = ls_intitit-bukrs_to.
          ls_key_fi-belnr = ls_intitit-belnr_to.
          ls_key_fi-gjahr = ls_intitit-gjahr_to.
          ls_key_fi-buzei = ls_intitit-buzei_to.
            lo_interest->assign_new_fi_idx( ls_key_fi ).
            is_data-zfbdt = ls_vbsegk-zfbdt.
            is_data-zterm = ls_vbsegk-zterm.
            is_data-zbd1t = ls_vbsegk-zbd1t.
            is_data-zbd1p = ls_vbsegk-zbd1p.
            is_data-zbd2t = ls_vbsegk-zbd2t.
            is_data-zbd2p = ls_vbsegk-zbd2p.
            is_data-zbd3t = ls_vbsegk-zbd3t.
            lo_interest->set_fi_idx( is_key  = ls_key_fi
                                     is_data = is_data ).
            lo_interest->set_int_gsber( is_key  = ls_key_fi
                                   iv_int_gsber = ls_vbsegk-gsber ).
            lo_int_mgr->end_tr( ).
          CATCH cx_fpia_common_exception.               "#EC NO_HANDLER
            lo_int_mgr->undo_tr( ).
        ENDTRY.
      ENDLOOP.
    ELSE.
      LOOP AT ct_intitfx INTO ls_intitfx.
        ls_fi_key-bukrs = ls_intitfx-bukrs.
        ls_fi_key-gjahr = ls_intitfx-gjahr.
        ls_fi_key-belnr = ls_intitfx-belnr.
        ls_fi_key-buzei = ls_intitfx-buzei.
        TRY.
          lo_interest = go_int_manager->get_interest_by_fi( ls_fi_key ).
            IF lo_interest IS BOUND.
              lo_interest->set_mode( iv_mode = 'C' ).
              lo_interest->set_int_doc_exist( is_key = ls_fi_key ).
            ENDIF.
          CATCH cx_fpia_common_exception.               "#EC NO_HANDLER
        ENDTRY.
      ENDLOOP.

      LOOP AT ct_intitfx INTO ls_intitfx.
        TRY.
            lo_int_mgr->start_tr( ).
       READ TABLE it_items INTO ls_sum
         WITH KEY bukrs = ls_intitfx-bukrs
                  belnr = ls_intitfx-belnr
                  gjahr = ls_intitfx-gjahr
                  buzei = ls_intitfx-buzei.

            SELECT SINGLE * FROM vbsegk
              INTO CORRESPONDING FIELDS OF ls_vbsegk
                WHERE ausbk = ls_intitfx-bukrs_to
                  AND gjahr = ls_intitfx-gjahr_to
                  AND belnr = ls_intitfx-belnr_to
                  AND buzei = ls_intitfx-buzei_to.

* Table  fpia_int_vzskz has been replaced by fpia_intcal_ind
*          SELECT SINGLE * FROM fpia_int_vzskz INTO ls_vzskz WHERE vzskz = ls_intitit-int_ind.
            SELECT SINGLE * FROM fpia_intcal_ind INTO ls_vzskz
              WHERE vzskz = ls_intitfx-int_ind.
            IF sy-subrc = 0.
              lv_vzskz_new = ls_vzskz-vzskz_int.
            ELSE.
              lv_vzskz_new = ls_intitfx-int_ind.
            ENDIF.

* create interest and set data
            lo_interest = lo_int_mgr->create_interest( ).
            is_ioadata-zfbdt = ls_vbsegk-zfbdt.
            is_ioadata-zterm = ls_vbsegk-zterm.
            is_ioadata-zbd1t = ls_vbsegk-zbd1t.
            is_ioadata-zbd1p = ls_vbsegk-zbd1p.
            is_ioadata-zbd2t = ls_vbsegk-zbd2t.
            is_ioadata-zbd2p = ls_vbsegk-zbd2p.
            is_ioadata-zbd3t = ls_vbsegk-zbd3t.
            is_ioadata-rec_date_br      = sy-datum.
            is_ioadata-rec_date_ac      = sy-datum.
            is_ioadata-inv_validation_b = sy-datum.
            is_ioadata-vzskz            = lv_vzskz_new.
            ls_set_field-gsber = ls_vbsegk-gsber.
            ls_set_field-ioa_fields = is_ioadata.
* set change mode to lock record
            lo_interest->set_mode( lo_interest->co_mode_change ).
            lo_interest->set_interest( ls_set_field ).
        lo_interest->set_inv_val_date_br( is_ioadata-inv_validation_b ).
* assign FI_IDX to interest
            ls_key_fi-bukrs = ls_intitfx-bukrs_to.
            ls_key_fi-belnr = ls_intitfx-belnr_to.
            ls_key_fi-gjahr = ls_intitfx-gjahr_to.
            ls_key_fi-buzei = ls_intitfx-buzei_to.
            lo_interest->assign_new_fi_idx( ls_key_fi ).
            is_data-zfbdt = ls_vbsegk-zfbdt.
            is_data-zterm = ls_vbsegk-zterm.
            is_data-zbd1t = ls_vbsegk-zbd1t.
            is_data-zbd1p = ls_vbsegk-zbd1p.
            is_data-zbd2t = ls_vbsegk-zbd2t.
            is_data-zbd2p = ls_vbsegk-zbd2p.
            is_data-zbd3t = ls_vbsegk-zbd3t.
            lo_interest->set_fi_idx( is_key  = ls_key_fi
                                     is_data = is_data ).
            lo_interest->set_int_gsber( is_key  = ls_key_fi
                                   iv_int_gsber = ls_vbsegk-gsber ).
            lo_int_mgr->end_tr( ).
          CATCH cx_fpia_common_exception.               "#EC NO_HANDLER
            lo_int_mgr->undo_tr( ).
        ENDTRY.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDMETHOD.


method IF_EX_FI_INT_CUS01~SORT_MASTER_DATA.
endmethod.
ENDCLASS.
