FUNCTION /thkr/aif_zallge_chk_vr_n_need .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(DATA_STRUCT) TYPE  /THKR/S_AIF_BIC
*"     REFERENCE(DATA_LINE) TYPE  /THKR/S_AIF_BIC_ZEILE
*"     REFERENCE(DATA_FIELD)
*"     REFERENCE(MSGTY) TYPE  SYMSGTY DEFAULT 'E'
*"     REFERENCE(VALUE1) TYPE  STRING
*"     REFERENCE(VALUE2) TYPE  STRING
*"     REFERENCE(VALUE3) TYPE  STRING
*"     REFERENCE(VALUE4) TYPE  STRING
*"     REFERENCE(VALUE5) TYPE  STRING
*"     REFERENCE(T_IFCHECK) TYPE  /AIF/T_IFCHECK OPTIONAL
*"     REFERENCE(T_IFACT) TYPE  /AIF/T_IFACT OPTIONAL
*"     REFERENCE(T_ACCHECK) TYPE  /AIF/T_ACCHECK OPTIONAL
*"     REFERENCE(T_FUNC) TYPE  /AIF/T_FUNC OPTIONAL
*"     REFERENCE(T_FMAPCOND) TYPE  /AIF/T_FMAPCOND OPTIONAL
*"     REFERENCE(T_CHECK) TYPE  /AIF/T_CHECK
*"     REFERENCE(T_TABCHK) TYPE  /AIF/T_TABCHK
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"      DATA_TABLE
*"  CHANGING
*"     REFERENCE(ERROR) TYPE  CHAR01
*"----------------------------------------------------------------------

  "Prüfung, ob eine Verrechnung notwendig ist.
  "Die Kapitel und Titel sind definiert, die am Ende verrechnet werden.

  "ERROR = FALSE -> Keine Verrechnung durchführen. Ausgleich über KIDICAP
  "ERROR = TRUE -> Führe Verrechnung durch. Ausgleich über Verrechnung


  error = /thkr/cl_biene_processing=>get_instance( )->check_vr_not_needed( iv_kapitel = CONV znsi_kapitel( data_line-10_kap ) iv_titel = data_line-11_titel  ).


ENDFUNCTION.
