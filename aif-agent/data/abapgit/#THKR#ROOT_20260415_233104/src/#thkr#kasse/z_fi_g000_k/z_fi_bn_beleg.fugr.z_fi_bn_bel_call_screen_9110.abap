FUNCTION z_fi_bn_bel_call_screen_9110.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_BUKRS) TYPE  BUKRS OPTIONAL
*"     REFERENCE(I_BELNR) TYPE  BELNR_D OPTIONAL
*"     REFERENCE(I_GJAHR) TYPE  GJAHR OPTIONAL
*"  CHANGING
*"     REFERENCE(C_DTO) TYPE  ZFI_F_DTO_NACHR
*"----------------------------------------------------------------------

* 1. User als Kasenmitarbeiter identifizieren
*  -> wird durch Berechtigung auf Transaktion gelöst

* 2. Gibt es überhaupt Benachrichtigungen zum Beleg
*  -> irrelevant, wenn aus Liste Z_FI_BN_DISPL aufgerufen

* 3. wenn ja, Nachricht anzeigen im Dynpro 9110
* Fehlertext dazu lesen
  SELECT SINGLE * FROM zfi_cu_bn_ftext INTO g_ftext
     WHERE herk = c_dto-herk
     AND   fehlernr = c_dto-fehlernr.
  IF sy-subrc = 0.
    IF g_ftext-alterntext IS NOT INITIAL.
      c_dto-ftext = g_ftext-alterntext.
    ELSE.
      c_dto-ftext = g_ftext-fehlertext.
    ENDIF.
  ENDIF.

  MOVE-CORRESPONDING c_dto TO zfi_f_dto_nachr.

  CALL SCREEN 9110 STARTING AT 5 5.

  CLEAR g_ftext.

ENDFUNCTION.
