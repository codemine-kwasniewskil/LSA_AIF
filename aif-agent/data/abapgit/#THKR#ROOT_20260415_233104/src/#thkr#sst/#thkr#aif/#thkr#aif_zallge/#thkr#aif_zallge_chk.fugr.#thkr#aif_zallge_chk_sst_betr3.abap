FUNCTION /thkr/aif_zallge_chk_sst_betr3 .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(DATA_STRUCT) TYPE  /THKR/S_AIF_BIC
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
" VALUE1 = 01_BTYP
" VALUE2 = 18_BETR3

 "in SST wird bei Verrechungsanordnungen das Kassenzeichen
 " als Referenz im Feld 18_BETR3 mitgegeben
" wenn es leer ist, dann keine Verrechnungsanordnung
  CASE value1.
    WHEN: 'SST'.
      READ TABLE data_struct-line with key 01_BTYP = 'UBE'
                                           18_BETR3 = VALUE2
                                           TRANSPORTING NO FIELDS.
      if sy-subrc = 0.
        error = abap_true.
      else.
        error = abap_false.
      ENDIF.
    WHEN: OTHERS.
      error = abap_true.
  ENDCASE.
ENDFUNCTION.
