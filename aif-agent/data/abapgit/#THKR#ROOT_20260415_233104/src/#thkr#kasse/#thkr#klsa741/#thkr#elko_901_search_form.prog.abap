*&---------------------------------------------------------------------*
*& Include          /THKR/ELKO_901_SEARCH_FORM
*&---------------------------------------------------------------------*
*&-----------------------------------------------------------------*
*&      Form selektion_daten
*&-----------------------------------------------------------------*
 FORM selektion_daten CHANGING xt_ausgabe LIKE gt_ausgabe.
   DATA: lv_note_to_payee TYPE string,
         lv_shkzg         TYPE shkzg,
         lv_ueberz        TYPE char1,
         lv_kassenz       TYPE string,
         ls_ausgabe       TYPE /thkr/ts_901_search,
         ls_febep         TYPE febep,
         lt_avip_out      TYPE /thkr/tt_avip,
         lt_febre         TYPE feb_t_febre,
         lt_bsid          TYPE /thkr/tt_elko_items.

   IF pa_febre EQ abap_true.
     SELECT * FROM febko INTO TABLE @DATA(lt_febko)
       WHERE kukey IN @so_kukey
       AND   bukrs IN @so_bukrs.


     IF lt_febko IS NOT INITIAL.
       SELECT * FROM febep INTO TABLE @DATA(lt_febep)
         FOR ALL ENTRIES IN @lt_febko
         WHERE kukey EQ @lt_febko-kukey
         AND   esnum IN @so_esnum
         AND   gjahr IN @so_gjahr.
     ENDIF.

     IF lt_febep IS NOT INITIAL.
       SELECT * FROM febre INTO TABLE @DATA(lt_febre_ges)
         FOR ALL ENTRIES IN @lt_febep
         WHERE kukey EQ @lt_febep-kukey
           AND esnum EQ @lt_febep-esnum
           AND rsnum IN @so_rsnum.
     ENDIF.
   ELSE.
     lv_note_to_payee = pa_vwezw.
   ENDIF.

   IF pa_febre IS NOT INITIAL.
     LOOP AT lt_febep ASSIGNING FIELD-SYMBOL(<ls_febep>).
       READ TABLE lt_febko ASSIGNING FIELD-SYMBOL(<ls_febko>)
                  WITH KEY kukey = <ls_febep>-kukey.

       LOOP AT lt_febre_ges ASSIGNING FIELD-SYMBOL(<ls_febre_ges>)
             WHERE kukey = <ls_febep>-kukey
             AND   esnum = <ls_febep>-esnum.
         APPEND <ls_febre_ges> TO lt_febre.
       ENDLOOP.

       LOOP AT lt_febre ASSIGNING FIELD-SYMBOL(<ls_febre>).
         CONCATENATE <ls_febre>-vwezw lv_note_to_payee INTO lv_note_to_payee.
       ENDLOOP.

       DATA(lv_test)  = abap_true.
       DATA(lv_elko)  = abap_true.
       EXPORT test  FROM lv_test    TO   MEMORY ID 'ELKO_TEST'.
       EXPORT elko  FROM lv_elko    TO   MEMORY ID 'ELKO_TAB'.
       EXPORT febko FROM <ls_febko> TO   MEMORY ID 'FEBKO_901'.
       EXPORT febep FROM <ls_febep> TO   MEMORY ID 'FEBEP_901'.
       IF     pa_901 EQ abap_true.
         CALL FUNCTION 'Z_FIEB_901_ALGORITHM'
           EXPORTING
             i_note_to_payee = lv_note_to_payee
           TABLES
             t_avip_out      = lt_avip_out.
       ELSEIF pa_902 EQ abap_true.
         CALL FUNCTION 'Z_FIEB_902_ALGORITHM'
           EXPORTING
             i_note_to_payee = lv_note_to_payee
           TABLES
             t_avip_out      = lt_avip_out.

       ENDIF.
       IMPORT lt_bsid   TO lt_bsid    FROM MEMORY ID 'LT_BSID'.
       IMPORT lv_ueberz TO lv_ueberz  FROM MEMORY ID 'ELKO_UEBERZ'.
       CLEAR: ls_febep.
*       IMPORT lv_kblk   TO lv_klbk    FROM MEMORY ID 'ELKO_KBLK'.

       SORT lt_bsid BY xblnr.
       DELETE ADJACENT DUPLICATES FROM lt_bsid COMPARING xblnr.
       CLEAR: lv_kassenz.
       LOOP AT lt_bsid ASSIGNING FIELD-SYMBOL(<ls_bsid>).
         CONCATENATE <ls_bsid>-xblnr lv_kassenz INTO lv_kassenz SEPARATED BY ';'.
       ENDLOOP.

       LOOP AT lt_avip_out ASSIGNING FIELD-SYMBOL(<ls_out>).
         AT FIRST.
           DATA(lv_first) = abap_true.
           CLEAR: ls_ausgabe.
         ENDAT.

         MOVE-CORRESPONDING <ls_out>   TO ls_ausgabe.
         MOVE-CORRESPONDING <ls_febep> TO ls_ausgabe.
         CLEAR: lv_shkzg.
         SELECT shkzg FROM bseg INTO lv_shkzg
                      UP TO 1 ROWS
                      WHERE bukrs EQ <ls_out>-abwbu
                      AND  belnr  EQ <ls_out>-swert+0(10)
                      AND  gjahr  EQ <ls_out>-swert+10(4)
                      AND  koart  EQ 'D'.
         ENDSELECT.
         IF lv_shkzg EQ 'H'.
           <ls_out>-wrbtr = <ls_out>-wrbtr * -1.
         ENDIF.
         ls_ausgabe-opbtr   = <ls_out>-wrbtr.
         ls_ausgabe-wrbtr   = <ls_out>-wrbtr - <ls_out>-diffw.
         ls_ausgabe-vwezw   = lv_note_to_payee.
         ls_ausgabe-xblnr   = <ls_out>-xblnr.
         ls_ausgabe-kassenz = lv_kassenz.
         IF lv_first EQ abap_true.
           ls_ausgabe-kwbtr = <ls_febep>-kwbtr.
           CLEAR: lv_first.
         ELSE.
           CLEAR: ls_ausgabe-kwbtr.
         ENDIF.

         IF lv_ueberz EQ abap_true.
           ls_ausgabe-ueberz = abap_true.
         ENDIF.
         APPEND ls_ausgabe TO xt_ausgabe.

       ENDLOOP.

       IF ls_febep IS NOT INITIAL.
         CLEAR: ls_ausgabe.
         MOVE-CORRESPONDING ls_febep TO ls_ausgabe.
         ls_ausgabe-kblk = abap_true.
         ls_ausgabe-vwezw = lv_note_to_payee.
         ls_ausgabe-opbtr = ls_ausgabe-wrbtr = ls_ausgabe-kwbtr.
         APPEND ls_ausgabe TO xt_ausgabe.
         CLEAR: ls_febep.
       ENDIF.

       CLEAR: lv_note_to_payee,
              lv_first,
              lv_ueberz,
              lt_febre,
              lt_avip_out,
              lt_bsid.
       FREE MEMORY ID  'ELKO_UEBERZ'.
       FREE MEMORY ID  'ELKO_KBLK'.
     ENDLOOP.
   ELSE.
     lv_test  = abap_true.
     EXPORT test    FROM lv_test  TO   MEMORY ID 'ELKO_TEST'.
     EXPORT kwbtr   FROM pa_kwbtr TO   MEMORY ID 'KWBTR_901'.
     IF pa_901 EQ abap_true.
       CALL FUNCTION 'Z_FIEB_901_ALGORITHM'
         EXPORTING
           i_note_to_payee = lv_note_to_payee
         TABLES
           t_avip_out      = lt_avip_out.
     ELSEIF pa_902 EQ abap_true.
       CALL FUNCTION 'Z_FIEB_902_ALGORITHM'
         EXPORTING
           i_note_to_payee = lv_note_to_payee
         TABLES
           t_avip_out      = lt_avip_out.
     ENDIF.

     IMPORT lt_bsid   TO lt_bsid    FROM MEMORY ID 'LT_BSID'.
     IMPORT lv_ueberz TO lv_ueberz  FROM MEMORY ID 'ELKO_UEBERZ'.
     CLEAR: ls_febep.
*     IMPORT lv_kblk   TO lv_kblk    FROM MEMORY ID 'ELKO_KBLK'.

     SORT lt_bsid BY xblnr.
     DELETE ADJACENT DUPLICATES FROM lt_bsid COMPARING xblnr.
     CLEAR: lv_kassenz.
     LOOP AT lt_bsid ASSIGNING <ls_bsid>.
       CONCATENATE <ls_bsid>-xblnr lv_kassenz INTO lv_kassenz SEPARATED BY ';'.
     ENDLOOP.

     LOOP AT lt_avip_out ASSIGNING <ls_out>.
       AT FIRST.
         lv_first = abap_true.
         CLEAR: ls_ausgabe.
       ENDAT.
       MOVE-CORRESPONDING <ls_out>   TO ls_ausgabe.
       ls_ausgabe-opbtr = <ls_out>-wrbtr.
       CLEAR: lv_shkzg.
       SELECT shkzg FROM bseg INTO lv_shkzg
                    UP TO 1 ROWS
                    WHERE bukrs EQ <ls_out>-abwbu
                    AND   belnr EQ <ls_out>-swert+0(10)
                    AND   gjahr EQ <ls_out>-swert+10(4)
                    AND   koart EQ 'D'.
       ENDSELECT.
       IF lv_shkzg EQ 'H'.
         <ls_out>-wrbtr = <ls_out>-wrbtr * -1.
       ENDIF.

       ls_ausgabe-wrbtr = <ls_out>-wrbtr - <ls_out>-diffw.
       ls_ausgabe-vwezw = lv_note_to_payee.
       ls_ausgabe-xblnr = <ls_out>-xblnr.
       ls_ausgabe-kassenz = lv_kassenz.
       IF lv_first EQ abap_true.
         ls_ausgabe-kwbtr = pa_kwbtr.
         CLEAR: lv_first.
       ENDIF.

       CONCATENATE <ls_out>-xblnr ls_ausgabe-kassenz INTO ls_ausgabe-kassenz SEPARATED BY ';'.

       IF lv_ueberz EQ abap_true.
         ls_ausgabe-ueberz = abap_true.
       ENDIF.
       APPEND ls_ausgabe TO xt_ausgabe.
     ENDLOOP.

     IF ls_febep IS NOT INITIAL.
       CLEAR: ls_ausgabe.
       MOVE-CORRESPONDING ls_febep TO ls_ausgabe.
       ls_ausgabe-vwezw = lv_note_to_payee.
       ls_ausgabe-kblk  = abap_true.
       ls_ausgabe-opbtr = ls_ausgabe-wrbtr = ls_ausgabe-kwbtr.
       APPEND ls_ausgabe TO xt_ausgabe.
       CLEAR: ls_febep.
     ENDIF.

     CLEAR: lv_note_to_payee,
            lv_ueberz,
            lt_avip_out,
            lt_bsid,
            lv_first.
     FREE MEMORY ID  'ELKO_UEBERZ'.
     FREE MEMORY ID  'ELKO_KBLK'.
   ENDIF.
 ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  fieldcat_init
*&---------------------------------------------------------------------*
 FORM fieldcat_init CHANGING xt_fieldcat TYPE lvc_t_fcat.

   CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
     EXPORTING
       i_structure_name       = '/THKR/TS_901_SEARCH'
     CHANGING
       ct_fieldcat            = xt_fieldcat
     EXCEPTIONS
       inconsistent_interface = 1
       program_error          = 2
       OTHERS                 = 3.
   IF sy-subrc EQ 0.
     IF pa_febre IS NOT INITIAL.
       LOOP AT xt_fieldcat ASSIGNING FIELD-SYMBOL(<ls_fcat>).
         IF <ls_fcat>-fieldname EQ 'KUKEY'
         OR <ls_fcat>-fieldname EQ 'ESNUM'
         OR <ls_fcat>-fieldname EQ 'RSNUM'
         OR <ls_fcat>-fieldname EQ 'BUKRS'
         OR <ls_fcat>-fieldname EQ 'KOART'
         OR <ls_fcat>-fieldname EQ 'KONTO'
         OR <ls_fcat>-fieldname EQ 'XBLNR'
         OR <ls_fcat>-fieldname EQ 'BELNR'
         OR <ls_fcat>-fieldname EQ 'ABWBU'
         OR <ls_fcat>-fieldname EQ 'WRBTR'
         OR <ls_fcat>-fieldname EQ 'SFELD'
         OR <ls_fcat>-fieldname EQ 'SWERT'
*         OR <ls_fcat>-fieldname EQ 'XAKTS'
*         OR <ls_fcat>-fieldname EQ 'XAKTP'
         OR <ls_fcat>-fieldname EQ 'DIFFW'
*         OR <ls_fcat>-fieldname EQ 'XPPMT'
         OR <ls_fcat>-fieldname EQ 'VWEZW'
         OR <ls_fcat>-fieldname EQ 'KWBTR'
         OR <ls_fcat>-fieldname EQ 'KASSENZ'
         OR <ls_fcat>-fieldname EQ 'OPBTR'
         OR <ls_fcat>-fieldname EQ 'UEBERZ'
         OR <ls_fcat>-fieldname EQ 'KBLK'.
           <ls_fcat>-no_out = abap_false.
         ELSE.
           <ls_fcat>-no_out = abap_true.
         ENDIF.
         IF <ls_fcat>-fieldname EQ 'VWEZW'.
           <ls_fcat>-coltext = 'Verwendungszweck'(005).
         ENDIF.
         IF <ls_fcat>-fieldname EQ 'KWBTR'.
           <ls_fcat>-coltext = 'Zahlbetrag'(006).
         ENDIF.
         IF <ls_fcat>-fieldname EQ 'WRBTR'.
           <ls_fcat>-coltext = 'Zugeordneter Betrag'(007).
         ENDIF.
         IF <ls_fcat>-fieldname EQ 'OPBTR'.
           <ls_fcat>-coltext = 'Offener Betrag'(008).
         ENDIF.
         IF <ls_fcat>-fieldname EQ 'KASSENZ'.
           <ls_fcat>-coltext = 'Kassenzeichen'(009).
         ENDIF.
         IF <ls_fcat>-fieldname EQ 'UEBERZ'.
           <ls_fcat>-coltext = 'Überzahlung'(010).
         ENDIF.
         IF <ls_fcat>-fieldname EQ 'KBLK'.
           <ls_fcat>-coltext = 'Annahmeanordnung'(011).
         ENDIF.
         <ls_fcat>-col_opt = abap_true.
       ENDLOOP.
     ELSE.
       LOOP AT xt_fieldcat ASSIGNING <ls_fcat>.
         IF <ls_fcat>-fieldname EQ 'BUKRS'
         OR <ls_fcat>-fieldname EQ 'KOART'
         OR <ls_fcat>-fieldname EQ 'KONTO'
         OR <ls_fcat>-fieldname EQ 'XBLNR'
         OR <ls_fcat>-fieldname EQ 'BELNR'
         OR <ls_fcat>-fieldname EQ 'ABWBU'
         OR <ls_fcat>-fieldname EQ 'WRBTR'
         OR <ls_fcat>-fieldname EQ 'SFELD'
         OR <ls_fcat>-fieldname EQ 'SWERT'
*         OR <ls_fcat>-fieldname EQ 'XAKTS'
*         OR <ls_fcat>-fieldname EQ 'XAKTP'
         OR <ls_fcat>-fieldname EQ 'DIFFW'
*         OR <ls_fcat>-fieldname EQ 'XPPMT'
         OR <ls_fcat>-fieldname EQ 'VWEZW'
         OR <ls_fcat>-fieldname EQ 'KWBTR'
         OR <ls_fcat>-fieldname EQ 'KASSENZ'
         OR <ls_fcat>-fieldname EQ 'OPBTR'
         OR <ls_fcat>-fieldname EQ 'UEBERZ'
         OR <ls_fcat>-fieldname EQ 'KBLK'.
           <ls_fcat>-no_out = abap_false.
         ELSE.
           <ls_fcat>-no_out = abap_true.
         ENDIF.
         IF <ls_fcat>-fieldname EQ 'VWEZW'.
           <ls_fcat>-coltext = 'Verwendungszweck'(005).
         ENDIF.
         IF <ls_fcat>-fieldname EQ 'KWBTR'.
           <ls_fcat>-coltext = 'Zahlbetrag'(006).
         ENDIF.
         IF <ls_fcat>-fieldname EQ 'WRBTR'.
           <ls_fcat>-coltext = 'Zugeordneter Betrag'(007).
         ENDIF.
         IF <ls_fcat>-fieldname EQ 'OPBTR'.
           <ls_fcat>-coltext = 'Offener Betrag'(008).
         ENDIF.
         IF <ls_fcat>-fieldname EQ 'KASSENZ'.
           <ls_fcat>-coltext = 'Kassenzeichen'(009).
         ENDIF.
         IF <ls_fcat>-fieldname EQ 'UEBERZ'.
           <ls_fcat>-coltext = 'Überzahlung'(010).
         ENDIF.
         IF <ls_fcat>-fieldname EQ 'KBLK'.
           <ls_fcat>-coltext = 'Annahmeanordnung'(011).
         ENDIF.
         <ls_fcat>-col_opt = abap_true.
       ENDLOOP.
     ENDIF.
   ENDIF.

 ENDFORM.                    " fieldcat_init

*&---------------------------------------------------------------------*
*&      Form  double_click
*&---------------------------------------------------------------------*
 FORM double_click  USING    it_ausgabe LIKE gt_ausgabe
                             iv_row     TYPE lvc_s_row
                             iv_column  TYPE lvc_s_col.

   READ TABLE it_ausgabe INTO gs_ausgabe INDEX iv_row-index.

   IF sy-subrc EQ 0.
     CASE iv_column.
       WHEN 'KONTO'.
         SET PARAMETER ID 'KUN' FIELD gs_ausgabe-konto.
         SET PARAMETER ID 'BUK' FIELD gs_ausgabe-bukrs.
         CALL TRANSACTION 'FBL5' AND SKIP FIRST SCREEN.
       WHEN OTHERS.
     ENDCASE.

   ENDIF.
*
 ENDFORM.                    " double_click

*&---------------------------------------------------------------------*
*& Form modify_screen
*&---------------------------------------------------------------------*
 FORM modify_screen .
   LOOP AT SCREEN.
     IF pa_febre EQ abap_true.
       IF screen-group1 = 'FEB'.
         screen-input     = '0'.
         screen-output    = '0'.
         screen-invisible = '1'.
       ENDIF.
       IF screen-group1 = 'KUK'.
         screen-input     = '1'.
         screen-output    = '1'.
         screen-invisible = '0'.
       ENDIF.
     ELSE.
       IF screen-group1 = 'FEB'.
         screen-input     = '1'.
         screen-output    = '1'.
         screen-invisible = '0'.
       ENDIF.
       IF screen-group1 = 'KUK'.
         screen-input     = '0'.
         screen-output    = '0'.
         screen-invisible = '1'.
       ENDIF.
     ENDIF.
     MODIFY SCREEN.
   ENDLOOP.

 ENDFORM.
