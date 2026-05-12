function /THKR/KLSA966_PROCESS_00001074.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_AUSDT) LIKE  F150V-AUSDT
*"     VALUE(I_TRACE) TYPE  BOOLE-BOOLE
*"  TABLES
*"      T_MHND_EXT STRUCTURE  MHND_EXT
*"      T_T047B STRUCTURE  T047B
*"      T_FIMSG STRUCTURE  FIMSG
*"  CHANGING
*"     VALUE(CS_MHNK) LIKE  MHNK STRUCTURE  MHNK
*"  EXCEPTIONS
*"      NOT_FOUND
*"--------------------------------------------------------------------

  data: l_t_mhnd       like mhnd       occurs 0  with header line,
        l_t_mhnd_group like mhnd_group occurs 0  with header line,
        l_t_mhnd_all   like mhnd       occurs 0  with header line,
        l_t_fimsg      like fimsg      occurs 10 with header line.

  data: l_gruppe like mhnd_group-gruppe,
        l_lines  like sy-tabix.

  data: l_flg_clear_sum like boole-boole value 'X'.

  "kLSA966 Zinskennzeichen
  DATA: ls_bkpf_int TYPE bkpf.
  DATA: ls_bseg_int TYPE bseg.
  DATA: lt_t047n TYPE TABLE OF t047n.
  DATA: ls_t047n TYPE t047n.
  DATA: lv_WZSBT LIKE mhnd_ext-wzsbt.
  DATA: lv_ZSBTR LIKE mhnd_ext-zsbtr.
  DATA: h_ref1(16) TYPE p.
  DATA: h_ref2(16) TYPE p.
  field-symbols: <fs_mhnd_ext> type mhnd_ext.

  loop at t_mhnd_ext assigning <fs_mhnd_ext>.

  SELECT * FROM t047n INTO TABLE lt_t047n WHERE spras = 'D'.
  SELECT SINGLE * FROM bkpf INTO ls_bkpf_int
         WHERE bukrs = <fs_mhnd_ext>-bbukrs
           AND belnr = <fs_mhnd_ext>-belnr
           AND gjahr = <fs_mhnd_ext>-gjahr.
*           and buzei = <fs_items>-buzei.
  SELECT SINGLE * FROM bseg INTO ls_bseg_int
         WHERE bukrs = <fs_mhnd_ext>-bbukrs
           AND belnr = <fs_mhnd_ext>-belnr
           AND gjahr = <fs_mhnd_ext>-gjahr
           AND buzei = <fs_mhnd_ext>-buzei.
  IF sy-subrc = 0.
    "check Nebenforderungen -> nicht verzinsen
    CASE ls_bkpf_int-blart.
      WHEN 'MG' OR 'SN' OR 'SG'.
        clear <fs_mhnd_ext>-zinst.
        clear <fs_mhnd_ext>-wzsbt.
        clear <fs_mhnd_ext>-zsbtr.
    ENDCASE.

    "check maber=M8 -> Schonfrist
    IF ls_bseg_int-maber = 'M8'.
      IF <fs_mhnd_ext>-zinst < 30.
        clear <fs_mhnd_ext>-zinst.
        clear <fs_mhnd_ext>-wzsbt.
        clear <fs_mhnd_ext>-zsbtr.
      ENDIF.
    ENDIF.

    "check ZAO -> nur ZAO individueller Zinssatz
    READ TABLE lt_t047n INTO ls_t047n WITH KEY bukrs = ls_bseg_int-bukrs
                                               maber = ls_bseg_int-maber.
    IF sy-subrc = 0 AND ls_t047n-text1 CS 'ZAO'.

      IF ls_bkpf_int-z_intrate IS NOT INITIAL.
        REPLACE '.' IN ls_bkpf_int-z_intrate WITH ''.
        REPLACE ',' IN ls_bkpf_int-z_intrate WITH '.'.
        <fs_mhnd_ext>-zinss = ls_bkpf_int-z_intrate.
        CLEAR <fs_mhnd_ext>-wzsbt.
        CLEAR <fs_mhnd_ext>-zsbtr.
        h_ref1 = <fs_mhnd_ext>-wrshb * <fs_mhnd_ext>-zinss.
        h_ref1 = h_ref1 * <fs_mhnd_ext>-zinst.                          "1380670
        h_ref2 = h_ref1 / 360.      "360              "1380670

        lv_WZSBT = h_ref2 / 100.                            "1380670

        CALL FUNCTION 'ROUND_AMOUNT'
          EXPORTING
            company    = <fs_mhnd_ext>-bukrs
            currency   = <fs_mhnd_ext>-waers
            amount_in  = lv_WZSBT
          IMPORTING
            amount_out = lv_WZSBT.

        <fs_mhnd_ext>-wzsbt = lv_wzsbt.
        <fs_mhnd_ext>-zsbtr = lv_wzsbt.

      ENDIF.
    ENDIF.
  ENDIF.
  endloop.

*-----refresh message table
  refresh: t_fimsg.
  clear: t_fimsg.

* check if account has a vzskz if not do not print any interest
  if cs_mhnk-vzskz = space.
*-----no interests for every document
    loop at t_mhnd_ext where laufd  = cs_mhnk-laufd and
                             laufi  = cs_mhnk-laufi and
                             koart  = cs_mhnk-koart and
                             bukrs  = cs_mhnk-bukrs and
                             kunnr  = cs_mhnk-kunnr and
                             lifnr  = cs_mhnk-lifnr and
                             cpdky  = cs_mhnk-cpdky and
                             sknrze = cs_mhnk-sknrze and
                             smaber = cs_mhnk-smaber and
                             smahsk = cs_mhnk-smahsk.
      t_mhnd_ext-xzins = 'X'.
      modify t_mhnd_ext.
    endloop.
    exit.
  endif.

*-----collect data belonging to cs_mhnk
  loop at t_mhnd_ext where laufd  = cs_mhnk-laufd and
                           laufi  = cs_mhnk-laufi and
                           koart  = cs_mhnk-koart and
                           bukrs  = cs_mhnk-bukrs and
                           kunnr  = cs_mhnk-kunnr and
                           lifnr  = cs_mhnk-lifnr and
                           cpdky  = cs_mhnk-cpdky and
                           sknrze = cs_mhnk-sknrze and
                           smaber = cs_mhnk-smaber and
                           smahsk = cs_mhnk-smahsk.

    clear: l_t_mhnd_group.
    move-corresponding: t_mhnd_ext to l_t_mhnd_group.
    append: l_t_mhnd_group.
  endloop.

*-----EXIT if no data
  describe table l_t_mhnd_group lines l_lines.
  check l_lines > 0.


* call BTE to make dunning groups for interest calculation
  call function 'OUTBOUND_CALL_00103005_P'
       EXPORTING
            i_psoxl      = 'X'
            cs_mhnk      = cs_mhnk
       tables
            t_mhnd_group = l_t_mhnd_group.

*-----copy every group and calculate interests for each group
  sort l_t_mhnd_group by gruppe.
  read table l_t_mhnd_group index 1.
  l_gruppe = l_t_mhnd_group-gruppe.

  loop at l_t_mhnd_group.

    if l_t_mhnd_group-gruppe = l_gruppe.
*-----add to current group
      clear: l_t_mhnd.
      move-corresponding l_t_mhnd_group to l_t_mhnd.
      append: l_t_mhnd.

    else.                              "l_t_mhnd_group-gruppe > l_gruppe

*-----calculate interests for current group
      call function 'FI_PSO_DUN_INTEREST_GROUP'
           exporting
                i_ausdt = i_ausdt
                i_mhnk  = cs_mhnk
                i_trace = i_trace
           tables
                t_t047b = t_t047b
                t_mhnd  = l_t_mhnd
                t_fimsg = l_t_fimsg.

*-----save the messages
      append lines of l_t_fimsg to t_fimsg.
      refresh: l_t_fimsg.

*-----collect changed MHND-entries
      append lines of l_t_mhnd to l_t_mhnd_all.

*-----start new group
      refresh: l_t_mhnd.
      clear:   l_t_mhnd.

      l_gruppe = l_t_mhnd_group-gruppe.

*-----add to new group
      move-corresponding: l_t_mhnd_group to l_t_mhnd.
      append: l_t_mhnd.

    endif.
  endloop.

*---calculate interest for the last group (if existing)
  describe table l_t_mhnd lines l_lines.
  if l_lines > 0.
    call function 'FI_PSO_DUN_INTEREST_GROUP'
         exporting
              i_ausdt = i_ausdt
              i_mhnk  = cs_mhnk
              i_trace = i_trace
         tables
              t_t047b = t_t047b
              t_mhnd  = l_t_mhnd
              t_fimsg = l_t_fimsg.

*-----save the messages
    append lines of l_t_fimsg to t_fimsg.
    refresh: l_t_fimsg.

*-----collect changed MHND-entries
    append lines of l_t_mhnd to l_t_mhnd_all.
  endif.


*-----move changed data back to t_mhnd_ext
  sort l_t_mhnd_all by bukrs belnr gjahr buzei.

  loop at t_mhnd_ext where laufd  = cs_mhnk-laufd and
                           laufi  = cs_mhnk-laufi and
                           koart  = cs_mhnk-koart and
                           bukrs  = cs_mhnk-bukrs and
                           kunnr  = cs_mhnk-kunnr and
                           lifnr  = cs_mhnk-lifnr and
                           cpdky  = cs_mhnk-cpdky and
                           sknrze = cs_mhnk-sknrze and
                           smaber = cs_mhnk-smaber and
                           smahsk = cs_mhnk-smahsk.

    read table l_t_mhnd_all with key bukrs  = t_mhnd_ext-bukrs
                                     belnr  = t_mhnd_ext-belnr
                                     gjahr  = t_mhnd_ext-gjahr
                                     buzei  = t_mhnd_ext-buzei
                            binary search.
    if sy-subrc is initial.
      move: l_t_mhnd_all-zinss to t_mhnd_ext-zinss,
            l_t_mhnd_all-zinst to t_mhnd_ext-zinst,
            l_t_mhnd_all-wzsbt to t_mhnd_ext-wzsbt,
            l_t_mhnd_all-zsbtr to t_mhnd_ext-zsbtr,
            l_t_mhnd_all-xzins to t_mhnd_ext-xzins.
      modify t_mhnd_ext.

      if l_t_mhnd_all-xzins = ' '.
*       if one position has interest
        clear: l_flg_clear_sum.
      endif.

*     add interest
      cs_mhnk-zinbt = cs_mhnk-zinbt + l_t_mhnd_all-wzsbt.
      cs_mhnk-zinhw = cs_mhnk-zinhw + l_t_mhnd_all-zsbtr.
    endif.

  endloop.

* sum of interests in header (mhnk) only if at least
* one position has XZINS = ' ' (interest has to be calculated).
  if l_flg_clear_sum = 'X'.
    clear: cs_mhnk-zinbt,
           cs_mhnk-zinhw.
  endif.

endfunction.
