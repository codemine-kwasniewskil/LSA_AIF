*"----------------------------------------------------------------------
* Gereon Koks  TSI  6.2.2025
*"----------------------------------------------------------------------
* Check if Zweitschuldner is ment
* Beide werden durch BTYP = SST getriggered.
* Es wird ein zusätzliches Attribut benötigt, ob AO oder AO_ZWEI
* prozessiert werden soll.
*"----------------------------------------------------------------------
* Input
* VALUE1  29_GRUND / 29_SGTXT
* VALUE2  %AO oder %AO_ZWEI
* VALUE3
* VALUE4
* VALUE5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT BLART
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_chk_zweit .
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
* 29_GRUND = 'ZWS: Kassenzeichen xyz'
*  BREAK-POINT.
  DATA: lv_kassz      TYPE string,
        lv_length     TYPE i,
        lv_length_xyz TYPE i,
        ls_bkpf       TYPE bkpf.

  error = abap_true.

  IF value1+0(18) = 'ZWS: Kassenzeichen'.
    lv_length     = strlen( value1 ).
    lv_length_xyz = lv_length - 19.
    lv_kassz = value1+19(lv_length_xyz).

    SELECT * FROM bkpf INTO ls_bkpf
      WHERE xblnr = lv_kassz
      AND   blart = 'D2'.

      error = abap_false.
    ENDSELECT.
  ENDIF.
*"----------------------------------------------------------------------
* Im Falle AO: umgekehrte Mimik
  IF value2 = 'AO'.
    IF error = abap_false.
      error = abap_true.
    ELSE.
      error = abap_false.
    ENDIF.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
