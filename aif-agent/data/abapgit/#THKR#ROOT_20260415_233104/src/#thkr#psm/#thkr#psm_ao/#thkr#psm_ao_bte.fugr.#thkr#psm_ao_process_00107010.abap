FUNCTION /thkr/psm_ao_process_00107010.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_F_PSO02) LIKE  PSO02 STRUCTURE  PSO02
*"  EXPORTING
*"     VALUE(E_FLG_CHANGE) LIKE  BOOLE-BOOLE
*"  TABLES
*"      T_PSO02S STRUCTURE  PSO02S
*"      T_PSO02S_SUBST STRUCTURE  PSO02S_SUBST
*"  CHANGING
*"     VALUE(C_F_PSO02_SUBST) LIKE  PSO02_SUBST STRUCTURE  PSO02_SUBST
*"----------------------------------------------------------------------
  "Funktion:
  "Der BTE wird bei der Anlage von Annahmeanordnungen durchlaufen.

  "Entwicklungsübernahme laut Programm
  DATA: lt_org TYPE STANDARD TABLE      " Original data
                  OF pso02s_subst.

  FIELD-SYMBOLS:
    <ls_subst_s>  TYPE pso02s_subst,    " Possible substitutions
    <ls_pso02_l1> TYPE pso02s.          " First line clearing


* Substitution of text on G/L-Account-Item for payment, acceptance,
* payment-deduction, acceptance-deduction and clearing requests only

  IF    i_f_pso02-psoty GT '05'.
    RETURN.
  ENDIF.

* Substitution of text on G/L-Account-Item by text of payment data,
* if text of payment data is not initial.

  lt_org = t_pso02s_subst[].

  CASE i_f_pso02-psoty.

    WHEN '01' OR '02' OR '04' OR '05'.

*     Payment request, Acceptance Request,
*     Payment-Deduction Request, Acceptance-Deduction Request

      IF i_f_pso02-sgtxt IS NOT INITIAL.

        LOOP AT t_pso02s_subst ASSIGNING <ls_subst_s>
          WHERE itabkey EQ i_f_pso02-itabkey.            "#EC CI_STDSEQ
          IF <ls_subst_s>-sgtxt IS INITIAL.                "#LK
            <ls_subst_s>-sgtxt = i_f_pso02-sgtxt.
          ENDIF.                                           "#LK
        ENDLOOP.

      ENDIF.

    WHEN '03'.

*     Clearing request

      READ TABLE t_pso02s ASSIGNING <ls_pso02_l1>
        WITH KEY bzkey = '001'.                          "#EC CI_STDSEQ
      IF <ls_pso02_l1> IS NOT ASSIGNED.
        RETURN.
      ENDIF.
      IF <ls_pso02_l1>-sgtxt IS NOT INITIAL.
        LOOP AT t_pso02s_subst ASSIGNING <ls_subst_s>
          WHERE bzkey NE '001'.                          "#EC CI_STDSEQ

          IF <ls_subst_s>-sgtxt IS INITIAL.                "#LK
            <ls_subst_s>-sgtxt = <ls_pso02_l1>-sgtxt.
          ENDIF.                                           "#LK
        ENDLOOP.
      ENDIF.

  ENDCASE.

  IF t_pso02s_subst[] NE lt_org.
    e_flg_change = abap_true.
  ENDIF.


ENDFUNCTION.
