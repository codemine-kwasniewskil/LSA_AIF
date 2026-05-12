*"----------------------------------------------------------------------
* Gereon Koks  TSI  18.11.2024
*"----------------------------------------------------------------------
* Prüfungen:
* 1.) Sind die Buchungscodes (01_BTYP) für diese Schnittstelle zugelassen ?
* 2.) Kommen die Dateien in der richtigen Reihenfolge ?
*     => Wird in den Fileadpter mit komplett neuer Mimik verlagert.
* 3.) Ist 06_QBELNR innerhalb der Datei eindeutig ?
*"----------------------------------------------------------------------
* Input
*"----------------------------------------------------------------------
* Output
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_chk_interface .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_AIF_BIC
*"     REFERENCE(RETURN_TAB_MAPPING) TYPE  BAPIRETTAB
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"         OPTIONAL
*"  EXPORTING
*"     REFERENCE(CLEAR_ERROR_MESSAGES) TYPE  BOOLEAN
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(OUT_STRUCT)
*"--------------------------------------------------------------------
  DATA: lo_init_check TYPE REF TO /thkr/cl_if_initial_check.

  lo_init_check = NEW /thkr/cl_if_initial_check( ).
*"----------------------------------------------------------------------
  "Prüfung Buchungscode:
  lo_init_check->check_btyp(
    EXPORTING
      it_lines  = raw_struct-line
      iv_empf   = raw_struct-header-empf                 " Feld der Laenge 3 Bytes
    CHANGING
      ct_return = return_tab[]
  ).
*"----------------------------------------------------------------------
*  "Prüfung Dateireihenfolge
*  lo_init_check->check_file_order(
*    EXPORTING
*      iv_gennr = CONV num4( raw_struct-header-gennr )                " Nicht näher def. Bereich, evtl. für Patchlevels verwendbar
*    CHANGING
*      ct_return = return_tab[]
*  ).
*"----------------------------------------------------------------------
* Gereon Koks  T-Systems  9.5.2025
*"----------------------------------------------------------------------
  "Prüfung Eindeutigkeit 06_QBELNR
  lo_init_check->check_qbelnr(
    EXPORTING
      it_lines  = raw_struct-line
    CHANGING
      ct_return = return_tab[]
  ).
*"----------------------------------------------------------------------
ENDFUNCTION.
