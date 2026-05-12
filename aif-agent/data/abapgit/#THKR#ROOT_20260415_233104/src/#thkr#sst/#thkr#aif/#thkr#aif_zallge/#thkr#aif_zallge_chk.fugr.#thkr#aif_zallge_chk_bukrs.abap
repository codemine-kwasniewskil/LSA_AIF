FUNCTION /thkr/aif_zallge_chk_bukrs .
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
"Prüfung, ob der Buchunskreis initial ist
  DATA: lo_chk_burks TYPE REF TO /thkr/cl_aif_chk.

  FIELD-SYMBOLS <ls_curr> TYPE any.
  FIELD-SYMBOLS <lt_data> TYPE STANDARD TABLE.
  FIELD-SYMBOLS <lt_msg> TYPE bapiret2_tt.
  ASSIGN data_line TO <ls_curr>.
  ASSIGN data_table[] to <lt_data>.

  lo_chk_burks = NEW /thkr/cl_aif_chk( ).

  error = lo_chk_burks->check_bukrs_is_initial(
            EXPORTING
              is_curr_line  = <ls_curr>
            CHANGING
              ct_return_tab = return_tab[]                 " Tabellentyp für BAPIRET2
              ct_data = <lt_data>
          ).
ENDFUNCTION.
