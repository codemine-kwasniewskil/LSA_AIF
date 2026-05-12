*----------------------------------------------------------------------*
***INCLUDE /THKR/LMIG_FI_FMF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CHECK_SAKNR_POSSIBLE
*&---------------------------------------------------------------------*
*       check if given account u_saknr is in table u_t_payac01
*----------------------------------------------------------------------*
FORM check_saknr_possible TABLES   u_t_payac01 STRUCTURE payac01
                          USING    u_saknr     LIKE payac01-saknr
                          CHANGING c_flg_possible.

  c_flg_possible = ' '.

* is account in table?
  READ TABLE u_t_payac01 WITH KEY saknr = u_saknr.
  IF sy-subrc = 0.
*   account is possible
    c_flg_possible = 'X'.
  ELSE.
* is account freely assignable?

    READ TABLE u_t_payac01 WITH KEY saknr = '*'.
    IF sy-subrc = 0.
*     account is freely assignable
      c_flg_possible = 'X'.
    ELSE.
*     account given is not possible
      c_flg_possible = ' '.
    ENDIF.

  ENDIF.

ENDFORM.                               " CHECK_SAKNR_POSSIBLE
*&---------------------------------------------------------------------*
*&      Form  FIND_GEN_ENTRIES
*&---------------------------------------------------------------------*
*       Search for all generic entries
*----------------------------------------------------------------------*
FORM find_gen_entries TABLES   u_t_payac01_h TYPE      fipso_t_payac01
                               c_t_payac01_h TYPE      fipso_t_payac01
                      USING    u_geber LIKE payac01-geber
                               u_fistl LIKE payac01-fistl
                               u_psoty LIKE payac01-psoty
                      CHANGING c_exakt LIKE boole-boole.

  DATA: l_lines LIKE sy-tabix.



  CLEAR: c_exakt.

*-----search all entries which fit to u_geber and u_fistl
  LOOP AT u_t_payac01_h WHERE geber EQ u_geber AND
                              fistl EQ u_fistl.
    MOVE-CORRESPONDING u_t_payac01_h TO c_t_payac01_h.
    APPEND c_t_payac01_h.
  ENDLOOP.
  CHECK sy-subrc IS INITIAL.

*-----check request type
  IF u_psoty NE space.
    READ TABLE c_t_payac01_h WITH KEY psoty = u_psoty.
    IF sy-subrc EQ 0.
      DELETE c_t_payac01_h WHERE psoty NE u_psoty.
      c_exakt = 'X'.
    ELSE.
      DELETE c_t_payac01_h WHERE psoty NE space.
      DESCRIBE TABLE c_t_payac01_h LINES l_lines.
      IF l_lines NE 0.
        c_exakt = 'X'.
      ENDIF.
    ENDIF.
  ELSE.
*   for eu psoty is initial -> no deletion necessary
    DESCRIBE TABLE c_t_payac01_h LINES l_lines.
    IF l_lines NE 0.
      c_exakt = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                               " FIND_GEN_ENTRIES
*&---------------------------------------------------------------------*
*&      Form  FIND_EXACT_ENTRIES
*&---------------------------------------------------------------------*
*       Search for all entries with the exact given fipex U_FIPEX
*----------------------------------------------------------------------*
FORM find_exact_entries TABLES   u_t_payac01 STRUCTURE payac01
                                 c_t_payac01 TYPE      fipso_t_payac01
                        USING    u_fipex LIKE payac01-fipex
                                 u_geber LIKE payac01-geber
                                 u_fistl LIKE payac01-fistl
                                 u_psoty LIKE payac01-psoty
                        CHANGING c_exakt LIKE boole-boole.

  DATA: l_tabix LIKE sy-tabix,
        l_lines LIKE sy-tabix.



  CLEAR: c_exakt.

*-----search first entry by binary search
  READ TABLE u_t_payac01 WITH KEY fipex = u_fipex
                                  geber = u_geber
                                  fistl = u_fistl
                         BINARY SEARCH.
  CHECK sy-subrc IS INITIAL.

  l_tabix = sy-tabix.
  MOVE-CORRESPONDING u_t_payac01 TO c_t_payac01.
*-----reverse priority for descending sort later
  c_t_payac01-prio1 = ABS( c_t_payac01-prio1 - 999 ).
  APPEND: c_t_payac01.

*-----check following entries for relevance
  WHILE NOT l_tabix IS INITIAL.
    ADD 1 TO l_tabix.
    READ TABLE u_t_payac01 INDEX l_tabix.
    IF NOT sy-subrc IS INITIAL      OR
       u_t_payac01-fipex <> u_fipex OR
       u_t_payac01-geber <> u_geber OR
       u_t_payac01-fistl <> u_fistl.
      CLEAR: l_tabix.
    ELSE.
      MOVE-CORRESPONDING u_t_payac01 TO c_t_payac01.
*-----reverse priority for descending sort later
      c_t_payac01-prio1 = ABS( c_t_payac01-prio1 - 999 ).
      APPEND: c_t_payac01.
    ENDIF.
  ENDWHILE.

*-----check request type
  READ TABLE c_t_payac01 WITH KEY psoty = u_psoty.
  IF sy-subrc EQ 0.
    DELETE c_t_payac01 WHERE psoty NE u_psoty.
    c_exakt = 'X'.
  ELSE.
    DELETE c_t_payac01 WHERE psoty NE space.
    DESCRIBE TABLE c_t_payac01 LINES l_lines.
    IF l_lines NE 0.
      c_exakt = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                               " FIND_EXACT_ENTRIES
*&---------------------------------------------------------------------*
*&      Form  derive_gl_account_by_badi
*&---------------------------------------------------------------------*
*       call badi for GL account derivation
*----------------------------------------------------------------------*
FORM derive_gl_account_by_badi
                    TABLES   t_payac01       STRUCTURE payac01
                    USING    u_gjahr         LIKE payac02-gjahr
                             u_gjhid         LIKE payac01-gjhid
                             u_bukrs         LIKE payac07-bukrs
                             u_bukfm         LIKE payac01-bukfm
                             u_fipex         LIKE payac01-fipex
                             u_geber         LIKE payac01-geber
                             u_budget_pd     LIKE payac01-budget_pd
                             u_fistl         LIKE payac01-fistl
                             u_fkber         TYPE payac01-fkber
                             u_popup         LIKE boole-boole
                             u_psoty         LIKE payac01-psoty
                             u_saknr         LIKE payac01-saknr
                             u_blart         LIKE pso02-blart
                    CHANGING c_saknr         LIKE payac01-saknr.

  STATICS: s_badi_instance       TYPE REF TO if_ex_fm_request_gl_acc,
           s_flg_imp_existing(1) TYPE c,
           s_flg_badi_read       LIKE boole-boole.

  DATA: l_saknr LIKE payac01-saknr,
        lt_payac01 TYPE TABLE OF payac01.

  IF s_flg_badi_read IS INITIAL.
*   initialise BAdI and check if implementation exists
    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name              = 'FM_REQUEST_GL_ACC'
        null_instance_accepted = 'X'
      IMPORTING
        act_imp_existing       = s_flg_imp_existing
      CHANGING
        instance               = s_badi_instance.

    s_flg_badi_read = 'X'.

  ENDIF.

* call method for G/L account derivation if badi is implemented
  CHECK s_flg_imp_existing = 'X'.

  l_saknr = u_saknr.
  CALL METHOD s_badi_instance->derive_gl_account
    EXPORTING
      i_gjahr                 = u_gjahr
      i_gjhid                 = u_gjhid
      i_bukrs                 = u_bukrs
      i_bukfm                 = u_bukfm
      i_fipex                 = u_fipex
      i_geber                 = u_geber
      i_budget_pd             = u_budget_pd
      i_fistl                 = u_fistl
      i_fkber                 = u_fkber
      i_popup                 = u_popup
      i_psoty                 = u_psoty
      i_blart                 = u_blart
    CHANGING
      c_saknr                 = l_saknr
      c_payac01               = lt_payac01
    EXCEPTIONS
      account_not_found       = 1
      account_free_assignable = 2
      account_not_possible    = 3.

* in case of problems raise the according exceptions with messages
  IF sy-subrc = 1.
    MESSAGE e033(fq) RAISING account_not_found.
  ELSEIF sy-subrc = 2.
    MESSAGE e729(fq) RAISING account_free_assignable.
  ELSEIF sy-subrc = 3.
    MESSAGE e778(fq) WITH u_saknr RAISING account_not_possible.
  ELSE.
    c_saknr = l_saknr.
    t_payac01[] = lt_payac01.
  ENDIF.

ENDFORM.                    " derive_gl_account_by_badi
