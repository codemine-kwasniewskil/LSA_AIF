*"----------------------------------------------------------------------
* Gereon Koks  TSI  11.10.2024
*"----------------------------------------------------------------------
* Check if AO is needed against /THKR/MAP_BLART
*"----------------------------------------------------------------------
* Input
* VALUE_IN  Interface €{0001,0002,...)
* VALUE_IN2 BTYP €{SST,FUA,...}
* VALUE_IN3 Field €{A;B}
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT BLART
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_chk_bankl_ist .
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

  SELECT SINGLE swift
    FROM bnka
    WHERE banks = @value1(2)
    AND   bankl = @value1+4(8)
    INTO @DATA(lv_swift).
  IF sy-subrc = 0.
    "Es existiert ein Eintrag.
    "Daher arbeite mit Value Mapping
    error = abap_true.
  ELSE.
    "Es existiert kein Eintrag.
    "Daher arbeite mit alternativen Mapping
    error = abap_true.
  ENDIF.
ENDFUNCTION.
