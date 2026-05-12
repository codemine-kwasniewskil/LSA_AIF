FUNCTION /THKR/BCS_INIT.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_GJAHR) TYPE  GJAHR
*"     VALUE(I_T_KEYFIGS) TYPE  FMKF_KFTAB OPTIONAL
*"  EXCEPTIONS
*"      GEN_ERROR
*"      DATA_FAIL
*"----------------------------------------------------------------------

* Zunächst einmal alle Kennzahlendaten lesen. Das ist u.U. billiger
* als die Daten einzeln zu lesen. Performance ist an dieser Stelle
* nicht kritisch
  PERFORM read_all_kfdata TABLES i_t_keyfigs.


* Formroutinen generieren
  PERFORM generate_kf_forms USING i_gjahr.


ENDFUNCTION.
