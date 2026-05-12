class /THKR/CL_FUNCTR_FUND_DISTR_LVL definition
  public
  final
  create public .

public section.

  class-methods GET_FUNDDISTR_LEVEL
    importing
      !FISTL type FISTL
      !FIKRS type FIKRS
      !HIVAR type FM_HIVARNT
      !ADJUST_LEVEL type I default 0
    returning
      value(DISTLVL) type /THKR/FUNDIST_LVL .
  class-methods GET_FUNDDISTR_BY_HILEVEL
    importing
      !HILEVEL type FM_HILEVEL
      !ADJUST_LEVEL type I default 0
      !FISTL type FISTL
    returning
      value(DISTLVL) type /THKR/FUNDIST_LVL .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_FUNCTR_FUND_DISTR_LVL IMPLEMENTATION.


  METHOD get_funddistr_by_hilevel.
    CHECK fistl IS NOT INITIAL.

    SELECT FROM /thkr/c_fund_dis
      FIELDS sort,
             fundist_lvl
      ORDER BY sort
      INTO TABLE @DATA(fundist_lvls).
** We check the last two digist:
** *02 = constant TV
    IF  substring( val = fistl off = strlen( fistl ) - 2 len = 2 ) = '02'
    AND adjust_level = 0.
      distlvl = fundist_lvls[ sort = lines( fundist_lvls ) ]-fundist_lvl.
** *01 = check by hierarchy level
    ELSE.
      TRY.
          distlvl = fundist_lvls[ sort = hilevel + adjust_level ]-fundist_lvl.
        CATCH cx_sy_itab_line_not_found.
          "Nothing found -> error
      ENDTRY.
    ENDIF.

  ENDMETHOD.


  METHOD get_funddistr_level.
    CHECK fistl IS NOT INITIAL.

    SELECT FROM /thkr/c_fund_dis
      FIELDS sort,
             fundist_lvl
      ORDER BY sort
      INTO TABLE @DATA(fundist_lvls).
** We check the last two digist:
** *02 = constant TV
    IF  substring( val = fistl off = strlen( fistl ) - 2 len = 2 ) = '02'
    AND adjust_level = 0.
      distlvl = fundist_lvls[ sort = lines( fundist_lvls ) ]-fundist_lvl.
** *01 = check by hierarchy
    ELSE.
      DATA(crawler) = /thkr/cl_fundctr_hier_crawler=>get( hivarnt = hivar fikrs = fikrs ).
      DATA(nodes) = crawler->get_all_nodes_path_up( fistl ).
      TRY.
** Calculate: amount of steps upwards = level of fund. distribution!
          distlvl = fundist_lvls[ sort = lines( nodes ) + adjust_level ]-fundist_lvl.

        CATCH cx_sy_itab_line_not_found.
          "Nothing found -> error
      ENDTRY.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
