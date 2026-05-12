*&---------------------------------------------------------------------*
*& Report /THKR/VERWAHR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/VERWAHR line-size 132.
************************************************************************
* ELKO: Automatische Verbuchung fehlerhafter Buchungen der Nebenbuchhaltung
************************************************************************
* Beschreibung:
*
* Das Programm ermöglicht die Verarbeitung fehlerhafter Buchungen. Dazu müssen
* nach dem Auftreten von Fehlern entsprechende Korrekturen vorgenommen werden.
*
* Ursprünglich zielte das Programm lediglich darauf ab, fehlende Verwahr-
* Kassenzeichen zu bebuchen.
* In der Vorgabe wurde jedoch der Wunsch vermerkt, auch weitere fehlerhafte
* Buchungen evtl. automatisch zu bebuchen.
* Deshalb wurde ein zusätzlicher Schalter eingebaut, der alle fehlerhaften
* Buchungen des vorgegebenen Zeitraumes selektiert.
* Mit einem weiteren Schalter kann das Programm in enem Simulationsmodus ge-
* startet werden. Dabei werden keine Buchungen erzeugt.
*
* Die Funktionalität des Buchungslaufes sollte in einen Hintergrundjob des
* Tagesabschlusses integriert sein.
*
************************************************************************

TABLES:
  t012k, febko, febep, tcurc.

TYPES:
      ty_detail TYPE zfi_s_verwahr.

DATA: ls_detail TYPE ty_detail,
      lt_detail TYPE TABLE OF ty_detail.

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
    p_stdat LIKE febko-azdat OBLIGATORY DEFAULT sy-datum,
    p_imdat LIKE febko-edate.
SELECTION-SCREEN END OF BLOCK 2.

SELECTION-SCREEN BEGIN OF BLOCK 3 WITH FRAME TITLE TEXT-003.
  PARAMETERS:
    p_simu TYPE c DEFAULT 'X',
    p_all  TYPE c DEFAULT ' ',
    p_err  TYPE c DEFAULT ' '.  " 2023-01-24 Performance
SELECTION-SCREEN END OF BLOCK 3.

DATA: gs_docs TYPE febko.

TYPES: BEGIN OF lines,
         azdat LIKE febko-azdat,
         kukey LIKE febko-kukey,
         esnum LIKE febep-esnum,
         kwbtr LIKE febep-kwbtr,
         kwaer LIKE febep-kwaer,
         vwezw LIKE febre-vwezw,
       END OF   lines.
DATA:  g_itab TYPE TABLE OF lines WITH HEADER LINE.


INITIALIZATION.
  p_stdat = sy-datum - 90.
  REFRESH lt_detail.

START-OF-SELECTION.

  DATA: lv_lines  TYPE integer.

  IF p_all = 'X'.

    SELECT k~kukey, k~azdat, p~esnum, p~kwbtr, p~kwaer, f~vwezw
      FROM ( ( febko AS k
        INNER JOIN febep AS p ON p~kukey = k~kukey
                             AND k~azdat GE @p_stdat
                             AND p~vb2ok IS INITIAL )
        INNER JOIN febre AS f ON f~kukey = p~kukey
                             AND f~esnum = p~esnum
                             AND f~rsnum = '001' )
      WHERE k~azdat GE @p_stdat
        AND k~kukey IN @s_kukey
        AND k~anwnd IN @s_anwnd
        AND k~bukrs IN @s_bukrs
        AND k~hbkid IN @s_hbkid
        AND k~hktid IN @s_hktid
        AND k~waers IN @s_curr
        AND p~esnum IN @s_esnum
      INTO CORRESPONDING FIELDS OF TABLE @g_itab BYPASSING BUFFER.

  ELSE.

    SELECT k~kukey, k~azdat, p~esnum, p~kwbtr, p~kwaer, f~vwezw
     FROM ( ( febko AS k
       INNER JOIN febep AS p ON p~kukey = k~kukey
                              AND p~vb2ok IS INITIAL )
       INNER JOIN febre AS f ON f~kukey = p~kukey
                            AND f~esnum = p~esnum
                            AND f~vwezw LIKE 'V%' )
      WHERE k~azdat GE @p_stdat
        AND k~kukey IN @s_kukey
        AND k~anwnd IN @S_anwnd
        AND k~bukrs IN @s_bukrs
        AND k~hbkid IN @s_hbkid
        AND k~hktid IN @s_hktid
        AND k~waers IN @s_curr
        AND p~esnum IN @s_esnum
     INTO CORRESPONDING FIELDS OF TABLE @g_itab BYPASSING BUFFER.

  ENDIF.


END-OF-SELECTION.

  DATA: lv_return  TYPE sy-subrc,
        lv_text    TYPE t100-text,
        lr_details TYPE REF TO feb_bsproc_detail_fe,
        ls_febep   TYPE febep.

  DATA: lt_febre TYPE STANDARD TABLE OF febre.
  DATA: lt_febcl TYPE re_t_ex_febcl,
        ls_febcl TYPE febcl.
  DATA: lt_msg   TYPE bapiret2_t.

  DATA: ls_febep_old TYPE febep.
  DATA: ls_febep_new TYPE febep.
  DATA: l_time LIKE  BALHDR-ALTIME.

  SORT g_itab BY kukey esnum.
  LOOP AT g_itab ASSIGNING FIELD-SYMBOL(<item>).
    l_time = sy-uzeit. "2023-01-24 js

    PERFORM get_febko   USING <item>-kukey.

    SELECT SINGLE * FROM febep INTO ls_febep WHERE kukey = <item>-kukey
                                               AND esnum = <item>-esnum.

    SELECT  * FROM febre INTO TABLE lt_febre WHERE kukey = <item>-kukey
                                               AND esnum = <item>-esnum.
    ls_febep_old = ls_febep.
    ls_febep_new = ls_febep.

    CLEAR: lv_text, ls_febep-fval1.

    CALL FUNCTION 'FEB_BSPROC_CALL_RFEBBU10'
      EXPORTING
        it_febre      = lt_febre
      IMPORTING
        et_febcl      = lt_febcl
        et_message    = lt_msg
      CHANGING
        c_febko       = gs_docs
        c_febep       = ls_febep_new
      EXCEPTIONS
        error_message = 1
        OTHERS        = 0.

    IF sy-subrc = 0.
      CLEAR lv_return.
      ROLLBACK WORK.
    ENDIF.

    ls_febep-fval1 = ls_febep_new-fval1.

    IF ls_febep_new-vgint <> ls_febep_old-vgint OR
       ls_febep_new-fnam1 <> ls_febep_old-fnam1 OR
       ls_febep_new-fval1 <> ls_febep_old-fval1 OR
       ls_febep_new-fnam2 <> ls_febep_old-fnam2 OR
       ls_febep_new-fval2 <> ls_febep_old-fval2 OR
       ls_febep_new-fnam3 <> ls_febep_old-fnam3 OR
       ls_febep_new-fval3 <> ls_febep_old-fval3 OR
       ls_febep_new-xblnr <> ls_febep_old-xblnr OR
       ls_febep_new-avkon <> ls_febep_old-avkon.    " CPD-Debitor kann sich auch ändern
      MODIFY febep FROM ls_febep_new.
      IF sy-subrc <> 0.
        MESSAGE e001(feb_bsproc) WITH 'FEBEP'.
*   Fehler bei Speichern der Einträge in Tabelle &
      ENDIF.
    ENDIF.

    DATA: lv_found TYPE Boolean.
    CLEAR lv_found.
    IF ls_febep-vozei = 'D'.
      lv_text = 'Es fehlt eine allg. Auszahlungsanordnung.'.
    ELSE.
      IF NOT ls_febep-fval1 IS INITIAL AND ls_febep-fnam1 = 'BSEG-KBLNR'.
        lv_text = 'Es ist eine Annahmeanordnung & vorhanden.'.
        REPLACE '&' IN lv_text WITH ls_febep-fval1.
        lv_found = 'X'.
      ELSE.
        lv_text = 'Es fehlt eine Annahmeanordnung.'.
      ENDIF.
    ENDIF.
    LOOP AT lt_febcl ASSIGNING FIELD-SYMBOL(<febcl>) WHERE selfd <> 'FB'.  "#EC CI_STDSEQ "#EC CI_NESTED
      lv_found = 'X'.
      lv_text = 'Belegbuchung mit FB01/FB05 ist möglich.'.
    ENDLOOP.
    IF lv_found IS INITIAL AND ls_febep_new-fnam1 = 'RF05A-NEWBK'.
      lv_text = 'Teilzahlung mit FB05 ist möglich.'.
    ENDIF.

    IF lv_return = 0.
      IF p_simu IS INITIAL.
*--- evtl. Sperre aufheben
        CALL FUNCTION 'DEQUEUE_ALL'
          EXPORTING
            _synchron = 'X'.
        LOOP AT lt_febcl ASSIGNING FIELD-SYMBOL(<fs_febcl>).   "#EC CI_NESTED
          MODIFY febcl FROM <fs_febcl>.
        ENDLOOP.
        CALL FUNCTION 'FEB_BSPROC_POST_VB2'
          EXPORTING
            i_kukey = <item>-kukey
            i_esnum = <item>-esnum
            i_mode  = 'N'.
        IF sy-subrc = 0.
          lv_text = 'Bei der Buchung ist ein Fehler aufgetreten.'. " z.B. Fehler durch Sperre
          COMMIT WORK AND WAIT.
          SELECT SINGLE vb2ok nbbln gjahr FROM febep BYPASSING BUFFER
                  INTO CORRESPONDING FIELDS OF ls_febep
                  WHERE kukey       = <item>-kukey
                   AND esnum       = <item>-esnum.
          IF ls_febep-vb2ok = 'X'.
            MESSAGE s312(f5) WITH ls_febep-nbbln gs_docs-bukrs INTO lv_text.
          ELSE.
           IF p_err = 'X'.   " 2023-01-24 js  Performance
            DATA: lt_balhdr  TYPE TABLE OF balhdr,
                  ls_BALHDR  TYPE balhdr,
                  lt_range   TYPE bal_r_msgn,
                  lt_bal_msg TYPE bal_t_msgr.
* Reading appl-log data
            CALL FUNCTION 'APPL_LOG_READ_DB'
              EXPORTING
                object      = 'FIBL'
                subobject   = 'FEB_BS'
                date_from   = sy-datum
                date_to     = sy-datum
                time_from   = l_time    " 2023-01-24 js  Performance
                user_id     = sy-uname
              TABLES
                header_data = lt_balhdr.

            REFRESH lt_range.
            SORT lt_balhdr BY lognumber DESCENDING.   "#EC CI_SORTLOOP
            READ TABLE lt_BALHDR INTO ls_BALHDR INDEX 1.
            CALL FUNCTION 'BAL_DB_READ_MESSAGES'
              EXPORTING
                i_log_handle     = ls_BALHDR-log_handle
                it_r_msgnum      = lt_range
*               I_EXACT          = FALSE
*               I_READ_TEXTS     = FALSE
*               I_LANGU          = SY-LANGU
              IMPORTING
                et_msg           = lt_bal_msg
*               ET_EXC           =
              EXCEPTIONS
                not_supported    = 1
                enqueue_error    = 2
                wrong_block_size = 3
                OTHERS           = 4.
            IF sy-subrc <> 0.
*               Implement suitable error handling here
            ENDIF.
            LOOP AT lt_bal_msg ASSIGNING FIELD-SYMBOL(<ls_message>).      "#EC CI_NESTED
              DATA ls_symsg TYPE symsg.
              CLEAR ls_symsg.
              MOVE-CORRESPONDING <ls_message> TO ls_symsg.
              MESSAGE ID ls_symsg-msgid TYPE ls_symsg-msgty NUMBER ls_symsg-msgno
                INTO DATA(mtext)
                WITH ls_symsg-msgv1 ls_symsg-msgv2 ls_symsg-msgv3 ls_symsg-msgv4.
            ENDLOOP.
            IF not mtext IS INITIAL.
              lv_text = mtext.
            ENDIF.
           ELSE.    " 2023-01-24 js Performance
             lv_text = l_time. " damit wenigstens lv_text belegt und somit irgendetwas ausgegeben wird
           ENDIF.   " 2023-01-24 js Performance

          ENDIF.
        ELSE.
          ROLLBACK WORK.
          lv_text = 'Beim Buchen ist ein Fehler aufgetreten.'.
        ENDIF.
      ENDIF.
    ENDIF.

    MOVE-CORRESPONDING gs_docs   TO ls_detail.
    MOVE-CORRESPONDING <item>    TO ls_detail.
    IF ls_detail-siban IS INITIAL.
      ls_detail-siban = gs_docs-siban.
    ENDIF.
    ls_detail-butxt = lv_text.
    APPEND ls_detail TO lt_detail.
    CLEAR: lv_text.
*--- evtl. Sperre aufheben

  ENDLOOP.

*--- Einfache Liste als ALV ausgeben
  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_structure_name = 'ZFI_S_VERWAHR'
    TABLES
      t_outtab         = lt_detail
    EXCEPTIONS
      program_error    = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


*&---------------------------------------------------------------------*
FORM get_febko USING iv_kukey TYPE febep-kukey.

  IF gs_docs-kukey <> iv_kukey.
    SELECT SINGLE * FROM febko INTO gs_docs  WHERE kukey = iv_kukey.   "#EC CI_ALL_FIELDS_NEEDED
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
