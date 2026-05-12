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
FUNCTION /THKR/AIF_ZALLGE_CHK_PSO_NO_MB .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(DATA_STRUCT) TYPE  /THKR/S_DE_PSO_XML_FILE
*"     REFERENCE(DATA_LINE) TYPE  PSO02
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
  DATA: ls_pso02s TYPE pso02s.
  READ TABLE data_struct-VALUES-items[ KEY-lotkz = data_line-lotkz KEY-gjahr = data_line-gjahr Key-belnr = data_line-belnr ]-lt_pso02s
   WITH KEY itabkey = data_line-itabkey Into ls_pso02s.
  if sy-subrc = 0.
    if ls_pso02s-kblnr is INITIAL.
      error = abap_false.
    else.
      error = abap_true.
    endif.
  else.
    error = abap_true.
  endif.

ENDFUNCTION.
