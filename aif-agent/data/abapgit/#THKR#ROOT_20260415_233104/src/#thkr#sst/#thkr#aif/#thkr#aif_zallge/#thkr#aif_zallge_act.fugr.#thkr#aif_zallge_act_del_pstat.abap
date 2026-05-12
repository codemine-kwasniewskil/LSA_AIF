*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Geschäftspartner"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_del_pstat .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA)
*"     REFERENCE(CURR_LINE)
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  "BREAK-POINT.                                             "#EC NOBREAK
*"----------------------------------------------------------------------

  " erfolgreich verarbeitete und abgebrochene Nachrichten lassen
  " sich nicht mehr neu starten.
  " daher werden sie in der Verarbeitungstabelle /THKR/T_AIF_OBJ
  " nicht mehr gebraucht
  DATA: lo_reproc    TYPE REF TO /thkr/cl_aif_reproc.

  lo_reproc = NEW /thkr/cl_aif_reproc( ).

  "Löschen von abgebrochenen Nachrichten
  lo_reproc->deltet_canceled_msgs(
    CHANGING
      ct_return_tab = return_tab[]                 " Returntabelle
  ).

  "Löschen fehlerhafter Nachrichten aus Statustabelle, die im AIF erfolgreich verarbeitet wurden.
  lo_reproc->deletet_successful_aif_msgs(
    CHANGING
      ct_return_tab = return_tab[]                 " Returntabelle
  ).

  "Löschen von erfolgreich verarbeiteten Nachrichtenbestanteilen.
  success = lo_reproc->delete_successfull_msgs(
              CHANGING
                ct_return_tab = return_tab[]                 " Returntabelle
            ).

ENDFUNCTION.
