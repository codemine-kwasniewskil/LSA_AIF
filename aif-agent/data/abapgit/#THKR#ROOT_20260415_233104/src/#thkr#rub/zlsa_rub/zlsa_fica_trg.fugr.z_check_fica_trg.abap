FUNCTION z_check_fica_trg .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(ACTIVITY) TYPE  FM_AUTHACT
*"     REFERENCE(FM_AREA) TYPE  FIKRS OPTIONAL
*"     REFERENCE(FM_FINCODE_AUTHGRP) TYPE  FM_AUTHGRF OPTIONAL
*"     REFERENCE(FM_FMFCTR_AUTHGRP) TYPE  FM_AUTHGRC OPTIONAL
*"     REFERENCE(FM_FIPEX_AUTHGRP) TYPE  FM_AUTHGRP OPTIONAL
*"     REFERENCE(FM_MEASURE_AUTHGRP) TYPE  FM_AUTHGR_MEASURE OPTIONAL
*"     REFERENCE(FM_FAREA_AUTHGRP) TYPE  FM_AUTHGR_FAREA OPTIONAL
*"     REFERENCE(IV_USER) TYPE  SY-UNAME DEFAULT SY-UNAME
*"  EXPORTING
*"     REFERENCE(EX_SUBRC) TYPE  N
*"--------------------------------------------------------------------
  "ACHTUNG:
  "Alle Änderungen, die an diesem Funktionsbaustein durchgeführt werden, bitte auch am Funktionsbaustein
  "/THKR/CHECK_FICA_TRG" durchführen.
  "Dieser Funktionsbaustein wurde nur implementiert, damit Programmübernahmen aus dem Referenzsystem
  "nicht auf Fehler laufen, sollte eine Prüfung auf Z_FICA_TRG implementiert sein.

  DATA ls_check TYPE c LENGTH 6.

  IF activity IS INITIAL.
    RETURN.
  ENDIF.

  IF fm_area IS NOT INITIAL.
    ls_check+0(1) = 'X'.
  ENDIF.
  IF fm_fincode_authgrp IS NOT INITIAL.
    ls_check+1(1) = 'X'.
  ENDIF.
  IF fm_fmfctr_authgrp IS NOT INITIAL.
    ls_check+2(1) = 'X'.
  ENDIF.
  IF fm_fipex_authgrp IS NOT INITIAL.
    ls_check+3(1) = 'X'.
  ENDIF.
  IF fm_measure_authgrp IS NOT INITIAL.
    ls_check+4(1) = 'X'.
  ENDIF.
  IF fm_farea_authgrp IS NOT INITIAL.
    ls_check+5(1) = 'X'.
  ENDIF.

  CASE ls_check.
    WHEN 'XXXXXX'.
      AUTHORITY-CHECK OBJECT  'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
      " jeweils ein Wert fehlt
    WHEN 'XXXXX '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' DUMMY.
    WHEN 'XXXX X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN 'XXX XX'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN 'XX XXX'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN 'X XXXX'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN ' XXXXX'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
      " jeweils zwei werte fehlen
    WHEN ' XXXX '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN ' XXX X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN ' XX XX'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN ' X XXX'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN '  XXXX'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN 'X XXX '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' DUMMY.
    WHEN 'X XX X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN 'X X XX'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN 'X  XXX'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN 'XX  XX'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN 'XX X X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN 'XX XX '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' DUMMY.
    WHEN 'XXX  X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN 'XXX X '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' DUMMY.
    WHEN 'XXXX  '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.
      " wenn drei Werte fehlen
    WHEN ' X XX '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' DUMMY.
    WHEN ' XX X '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' DUMMY.
    WHEN ' XXX  '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.
    WHEN '  XX X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN ' X X X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN ' XX  X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN '  X XX'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN ' X  XX'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN '   XXX'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN '  XXX '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' DUMMY.
    WHEN 'X  XX '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' DUMMY.
    WHEN 'X X X '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' DUMMY.
    WHEN 'X XX  '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.
    WHEN 'X  X X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN 'X X  X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN 'X   XX'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN 'XX   X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN 'XX  X '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' DUMMY.
    WHEN 'XX X  '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.
    WHEN 'XXX   '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.
      "--- wenn jeweils vier werte Fehlen
    WHEN 'XX    '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.
    WHEN 'X X   '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.
    WHEN 'X  X  '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.
    WHEN 'X   X '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' DUMMY.
    WHEN 'X    X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN ' XX   '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.
    WHEN ' X X  '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.
    WHEN ' X  X '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' DUMMY.
    WHEN ' X   X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN '  XX  '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.
    WHEN '  X X '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' DUMMY.
    WHEN '  X  X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN '   XX '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' DUMMY.
    WHEN '   X X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
    WHEN '    XX'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
      "--- wenn jeweils fünf Werte Fehlen
    WHEN 'X     '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   FIELD fm_area
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.
    WHEN ' X    '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' FIELD fm_fincode_authgrp
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.
    WHEN '  X   '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' FIELD fm_fmfctr_authgrp
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.
    WHEN '   X  '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' FIELD fm_fipex_authgrp
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.
    WHEN '    X '.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' FIELD fm_measure_authgrp
        ID 'FM_GRP_FAR' DUMMY.
    WHEN '     X'.
      AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' FIELD fm_farea_authgrp.
      "--- wenn kein Wert übergeben wird
    WHEN OTHERS.
      IF activity IS NOT INITIAL.

        AUTHORITY-CHECK OBJECT 'Z_FICA_TRG' FOR USER iv_user
        ID 'FM_AUTHACT' FIELD activity
        ID 'FM_FIKRS'   DUMMY
        ID 'FM_AUTHGRF' DUMMY
        ID 'FM_AUTHGRC' DUMMY
        ID 'FM_AUTHGRP' DUMMY
        ID 'FM_AUTHGRM' DUMMY
        ID 'FM_GRP_FAR' DUMMY.

      ELSE.
        ex_subrc = 0.
        RETURN.
      ENDIF.
  ENDCASE.

  ex_subrc = Sy-subrc.

*  "Prüfung kritische Kontierungsmuster
*  SELECT *
*    FROM zfi_krit_kon
*    INTO TABLE @DATA(lt_krit_kon). "#EC CI_GENBUFF
*
*  SELECT * FROM zfi_exce_user
*    INTO TABLE @DATA(lt_exce_user).
*
*  IF sy-tcode NE 'FMAO'.
*
*    LOOP AT lt_krit_kon ASSIGNING FIELD-SYMBOL(<fs_krit_kon>).
*
*      IF fm_fipex_authgrp CP <fs_krit_kon>-fipos
*        AND fm_fmfctr_authgrp CP <fs_krit_kon>-fistl.
*
*        READ TABLE lt_exce_user
*          WITH KEY id     = <fs_krit_kon>-id
*                   zuser  = iv_user
*          TRANSPORTING NO FIELDS.
*
*        IF sy-subrc NE 0.
*
*          READ TABLE lt_exce_user
*            WITH KEY id     = '*'
*                     zuser  = iv_user
*            TRANSPORTING NO FIELDS.
*
*          IF sy-subrc NE 0.
*
*            "Kritische Kontierungsfehler SUBRC 6
*            ex_subrc = 6.
*            RETURN.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.



ENDFUNCTION.
