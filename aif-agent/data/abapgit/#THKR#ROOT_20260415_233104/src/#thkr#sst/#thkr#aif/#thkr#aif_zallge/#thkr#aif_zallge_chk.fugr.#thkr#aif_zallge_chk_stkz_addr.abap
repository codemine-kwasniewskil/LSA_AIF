FUNCTION /THKR/AIF_ZALLGE_CHK_STKZ_ADDR .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(DATA_STRUCT)
*"     REFERENCE(DATA_LINE)
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

"VALUE1 = Feld aus der Zusatzstruktur LS_IADDR_PSO
"VALUE2 = Kennzeichen natürliche Person (STKZN )

  if VALUE2 = abap_true.
    "Natürliche Person.
    if VALUE1 is INITIAL.
      "Es gibt kein Wert aus der zusätzlichen Struktur LS_IADDR_PSO
      "Nimm Feld aus BSEC
      error = abap_true.
    else.
      "Es gibt ein Wert aus der zusätzlichen Struktur LS_IADDR_PSO
      error = abap_false.
    endif.
  else.
    "organisation. Nimm aus BSEC
    error = abap_true.
  ENDIF.

ENDFUNCTION.
