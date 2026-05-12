*&---------------------------------------------------------------------*
*& Report Z_FI_LVM_BNKA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE Z_FI_LVM_BNKA_TOP.
INCLUDE Z_FI_LVM_BNKA_F01.

START-OF-SELECTION.

* Berechtigungsprüfung
  gv_actvt = '02'.
  AUTHORITY-CHECK OBJECT 'F_BNKA_MAN' ID 'ACTVT' FIELD gv_actvt.
  IF sy-subrc NE 0.
    MESSAGE e011.
  ENDIF.

* Bankenstamm sperren
  perform lock_data.

* Löschkennzeichen in BNKA setzen
  perform update_data.

* Liste ausgeben
  perform alv_data.

* Bankenstamm entsperren
  perform unlock_data.
