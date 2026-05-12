FUNCTION /THKR/AIF_ZALLGE_CHK_PRC_CHAIN .
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
"Es gibt Verarbeitungsketten. Wenn ein Fehler im vorherigen Prozess auftauchen
"können die nachgelagerten Prozesse nicht erfolgreich durchlaufen werden.
"Wenn es Fehler im vorgelagerten Prozess gibt, dann führe
"den aktuellen Prozess nicht auf.
"Verarbeitungskette:
    "1. Geschäftspartner
    "2. Mittelbindung
    "3. Anordnung
    "4. Sollzugang, Sollabgang (beziehen sich auf Anordnung)
  DATA: lo_chk_prc_chain TYPE REF TO /thkr/cl_aif_chk.

  FIELD-SYMBOLS <ls_curr> TYPE any.
  FIELD-SYMBOLS <ls_data_sturc> TYPE any.
  FIELD-SYMBOLS <lt_data> TYPE STANDARD TABLE.
  FIELD-SYMBOLS <lt_msg> TYPE bapiret2_tt.
  ASSIGN data_line TO <ls_curr>.
  ASSIGN data_struct to <ls_data_sturc>.
  ASSIGN data_table[] to <lt_data>.

  lo_chk_prc_chain = NEW /thkr/cl_aif_chk( ).

error = lo_chk_prc_chain->check_process_chain(
          EXPORTING
            is_data_struc = <ls_data_sturc>
            is_curr_line  = <ls_curr>
          CHANGING
            ct_return_tab = return_tab[]
            ct_data       = <lt_data>                " Tabellentyp für BAPIRET2
        ).
ENDFUNCTION.
