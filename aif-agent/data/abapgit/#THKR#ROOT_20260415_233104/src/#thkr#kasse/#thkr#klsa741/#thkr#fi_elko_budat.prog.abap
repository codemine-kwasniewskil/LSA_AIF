*&---------------------------------------------------------------------*
*& Report Z_FI_ELKO_BUDAT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/fi_elko_budat LINE-SIZE 80.

************************************************************************
* ELKO: Hilfprogramm zum Anpassen des Buchungsdatums
************************************************************************
* Beschreibung:
*
* Das Programm soll bei alten, fehlerhaften Kontoauszügen prüfen, ob die
* abgeleitete Buchungsperiode geöffnet ist. Die fehhlerhaften Buchungen
* befinden sich im Buchungsbereich 2 (Nebenbuch).
*
* Falls diese Buchungsperiode für Buchungen geschlossen ist, wird das Bu-
* chungsdatum in der Tabellle FEBEP aktualisiert.
*
* Die Funktionalität des Hilfprogrammes sollte in einen Hintergrundjob zum
* Monatsabschlusss integriert werden.
*
************************************************************************
* Autor: Jürgen Schedler
* Firma: DXC Technology Deutschland GmbH
************************************************************************

*TYPE-POOLS  slis.
TABLES:
  t012k, febko, febep, tcurc.


SELECTION-SCREEN BEGIN OF BLOCK 1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
  s_anwnd FOR febko-anwnd DEFAULT '0001',
  s_kukey FOR febko-kukey,
  s_esnum FOR febep-esnum,
  s_bukrs FOR t012k-bukrs,
  s_hbkid FOR t012k-hbkid,
  s_hktid FOR t012k-hktid,
  s_curr  FOR febko-waers.
SELECTION-SCREEN END OF BLOCK 1.

SELECTION-SCREEN BEGIN OF BLOCK 2 WITH FRAME TITLE TEXT-002.
  PARAMETERS:
    p_budat LIKE febep-budat OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK 2.

SELECTION-SCREEN BEGIN OF BLOCK 3 WITH FRAME TITLE TEXT-003.
  PARAMETERS:
    p_size TYPE integer OBLIGATORY DEFAULT 1000.
SELECTION-SCREEN END OF BLOCK 3.

TYPES: BEGIN OF ty_lines,
         bukrs LIKE febko-bukrs,
         kukey LIKE febko-kukey,
         esnum LIKE febep-esnum,
         budat LIKE febep-budat,
       END OF   ty_lines.
DATA:  gt_itab TYPE TABLE OF ty_lines WITH HEADER LINE.

DATA:  gt_febep   TYPE TABLE OF febep WITH HEADER LINE.
DATA:  gv_totals  TYPE integer.   " Zähler


INITIALIZATION.
*  p_budat = sy-datum.

START-OF-SELECTION.

  PERFORM get_data.

END-OF-SELECTION.

  PERFORM check_table CHANGING gv_totals.
  PERFORM result USING gv_totals.


*&---------------------------------------------------------------------*
FORM get_data.

  SELECT k~kukey, k~bukrs, p~esnum, p~budat
    FROM ( febko AS k
      INNER JOIN febep AS p ON p~kukey = k~kukey
                           AND p~vb2ok IS INITIAL )
    WHERE k~kukey IN @s_kukey
      AND k~anwnd IN @s_anwnd
      AND k~bukrs IN @s_bukrs
      AND k~hbkid IN @s_hbkid
      AND k~hktid IN @s_hktid
      AND k~waers IN @s_curr
      AND p~esnum IN @s_esnum
    INTO CORRESPONDING FIELDS OF TABLE @gt_itab BYPASSING BUFFER.

ENDFORM.
*&---------------------------------------------------------------------*
FORM check_table CHANGING cv_totals.

  DATA: lv_valid TYPE abap_boolean,
        lv_lines TYPE integer,
        lv_bukrs TYPE bukrs,
        lv_budat TYPE budat.

*--- Zähler für geänderte Zeilen initialisieren
  CLEAR cv_totals.

  CLEAR: lv_bukrs, lv_budat, lv_lines.
  SORT gt_itab BY bukrs budat.
  LOOP AT gt_itab ASSIGNING FIELD-SYMBOL(<item>).
    IF lv_bukrs <> <item>-bukrs OR lv_budat <> <item>-budat.
      lv_budat = <item>-budat.
      lv_bukrs = <item>-bukrs.
      PERFORM check_entry USING <item>-budat
                                <item>-bukrs
                        CHANGING lv_valid.
    ENDIF.
    IF lv_valid = 'X'.
      ADD 1 TO cv_totals.
      ADD 1 TO lv_lines.
      PERFORM build_tab USING <item>-kukey
                              <item>-esnum.
      IF lv_lines >= p_size.
        PERFORM update_febep.
        CLEAR lv_lines.
      ENDIF.
    ENDIF.
  ENDLOOP.
  PERFORM update_febep.

ENDFORM.

FORM check_entry USING iv_budat TYPE sy-datum
                       iv_bukrs TYPE t001-bukrs
              CHANGING ev_valid TYPE abap_boolean.

  DATA: lv_gjahr TYPE bkpf-gjahr,
        lv_poper TYPE t009b-poper,
        lv_valid TYPE abap_boolean.

  CLEAR ev_valid.

  CALL FUNCTION 'FI_PERIOD_DETERMINE'
    EXPORTING
      i_budat        = iv_budat
      i_bukrs        = iv_bukrs
    IMPORTING
      e_gjahr        = lv_gjahr
      e_poper        = lv_poper
    EXCEPTIONS
      fiscal_year    = 1
      period         = 2
      period_version = 3
      posting_period = 4
      special_period = 5
      version        = 6
      posting_date   = 7
      OTHERS         = 8.
  IF sy-subrc = 0.
    CALL FUNCTION 'FI_PERIOD_CHECK'
      EXPORTING
        i_bukrs          = iv_bukrs
*       I_OPVAR          = ' '
        i_gjahr          = lv_gjahr
        i_koart          = '+'
        i_konto          = '+'
        i_monat          = lv_poper
      EXCEPTIONS
        error_period     = 1
        error_period_acc = 2
        invalid_input    = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      ev_valid = 'X'.  "Periode nicht möglich, Update Budat erforderlich
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
FORM build_tab USING iv_kukey TYPE febko-kukey
                     iv_esnum TYPE febep-esnum.

  DATA: ls_febep TYPE febep.

  SELECT SINGLE * FROM febep INTO ls_febep
     WHERE kukey = iv_kukey AND esnum = iv_esnum.

  IF sy-subrc = 0.
    ls_febep-budat = p_budat.
    APPEND ls_febep TO gt_febep.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
FORM update_febep.

*        UPDATE febep SET  budat = p_BUDAT
*         WHERE kukey = <item>-kukey
*         AND esnum = <item>-esnum.
*

  UPDATE febep FROM TABLE @gt_febep.

  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.

  REFRESH gt_FEBEP.

ENDFORM.
*&---------------------------------------------------------------------*
FORM result USING iv_totals TYPE integer.

  DATA: lv_num     TYPE string.
  DATA: lv_msg     TYPE String.    " Message

  MOVE iv_totals TO lv_num .
  CONDENSE lv_num NO-GAPS.
  CONCATENATE TEXT-101 lv_num INTO lv_msg SEPARATED BY space.
  WRITE: / lv_msg.

ENDFORM.
*&---------------------------------------------------------------------*
