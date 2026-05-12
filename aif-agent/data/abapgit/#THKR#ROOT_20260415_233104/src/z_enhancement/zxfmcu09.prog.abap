*&---------------------------------------------------------------------*
*& Include          ZXFMCU09
*&---------------------------------------------------------------------*


"Ersteller: ZHM000000038       Andreas Baier
"Anforderung:
"Beschreibung:
"Anpassung: Durch das Ändern von Kontierungselementen wird
"der Betrag der Mittelbindung wieder änderbar und das
"Kennzeichen "Wertanpassungsbeleg erforderlich wird entfernt.
"Dieser Customer-Exit dient dazu, das Kennzeichen wieder zu setzen
"und die alten Betragswerte wieder aufzunehmen.
"Achtung: Nur gültig für Belegart MB und MR in den Transaktionen
"FMZ2 und FMX2.
DATA: t_param  TYPE STANDARD TABLE OF /thkr/t_wf_param,
      lv_no_wf TYPE abap_bool.

SELECT * FROM /thkr/t_wf_param
  INTO TABLE t_param
  WHERE object = 'WF_FMRE_NO_WF'.

READ TABLE t_param TRANSPORTING NO FIELDS
WITH KEY value_von = f_kbld-blart.
IF sy-subrc = 0.
  lv_no_wf = abap_true.
ENDIF.


IF sy-tcode = 'FMZ2' OR sy-tcode = 'FMX2'.
  IF f_kbld-blart = 'MB' OR lv_no_wf = abap_true .

    SELECT SINGLE * FROM kblk INTO @DATA(s_kblk)
      WHERE belnr = @f_kbld-belnr.

    SELECT SINGLE * FROM kblp INTO @DATA(s_kblp)
      WHERE belnr = @f_kbld-belnr AND blpos = @f_kbld-blpos.

    IF s_kblp-pmactive = 'X' AND s_kblk-wkapk = 'X'
      AND NOT f_kbld-pmactive = 'X'.

      f_kbld-pmactive  = 'X'.
      f_kbld-wtges = s_kblp-wtges.
      f_kbld-wtorig = s_kblp-wtorig.
      CLEAR f_KBLD-deltawtapp.
    ENDIF.


  ENDIF.

ENDIF.
