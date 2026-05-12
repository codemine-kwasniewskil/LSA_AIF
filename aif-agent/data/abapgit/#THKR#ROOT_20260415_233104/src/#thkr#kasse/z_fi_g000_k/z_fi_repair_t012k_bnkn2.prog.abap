*&---------------------------------------------------------------------*
*& Report Z_JS_REPAIR_T012K_BNKN2
*&---------------------------------------------------------------------*
*& Reparatur pro Mandant auf Basis der Störungsmeldung 2000001054:
*&   Über diesen Report wird die Kontonummer (mit Vornullen) in die
*%   alternative Kontonummer (ohne Vornullen) kopiert für Verarb. MT.940
*&---------------------------------------------------------------------*
REPORT z_fi_repair_t012k_bnkn2.

*SELECTION-SCREEN.
*PARAMETERS: p_psvor like fmpso_tagrp-psobt_vor,
*            p_psobt like fmpso_tagrp-psobt.
*
*START-OF-SELECTION.
FIELD-SYMBOLS <hk> TYPE fclm_bam_aclink2.

SELECT * FROM fclm_bam_aclink2                  "Lesen der Hausbankkonten
  WHERE bnkn2 IS INITIAL              "alternative Kontonummer bisher nicht gefüllt
  AND   bankn LIKE '0%'               "Kontonummer beginnt mit Vornullen
  INTO TABLE @DATA(lt_t012k).

LOOP AT lt_t012k ASSIGNING <hk>.
  IF <hk>-bankn(1) = '0'.
    <hk>-bnkn2 = <hk>-bankn.
    WHILE <hk>-bnkn2(1) = '0'.
      <hk>-bnkn2 = <hk>-bnkn2+1.      "führenen Nullen abschneiden in BNKN2
    ENDWHILE.
  ENDIF.
ENDLOOP.

IF lt_t012k IS NOT INITIAL.
  UPDATE fclm_bam_aclink2 FROM TABLE lt_t012k.  "Rückspeichern Hausbankkonten

  COMMIT WORK.
ENDIF.
