*----------------------------------------------------------------------*
***INCLUDE LZ_FI_ELKO_BTEF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form FORM_VALUES
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM form_values .
  DATA: ls_shlp        TYPE shlp_descr,
        ls_selopt      TYPE ddshselopt,
        lt_retval      TYPE TABLE OF ddshretval,
        ls_retval      TYPE ddshretval,
        lt_fields      TYPE TABLE OF dynpread,
        ls_fields      TYPE dynpread,
        lv_choice      TYPE i,
        lt_/thkr/ea_fo TYPE TABLE OF /thkr/ea_fo_long,
        ls_/thkr/ea_fo TYPE /thkr/ea_fo_long.

  FIELD-SYMBOLS: <if>        TYPE ddshiface,
                 <form_line> TYPE /thkr/ea_fo_long,
                 <fieldcat>  TYPE slis_fieldcat_alv.

  CLEAR lt_fields.

  CALL FUNCTION 'F4IF_GET_SHLP_DESCR'
    EXPORTING
      shlpname = '/THKR/EA_FORMID_HLP'
      shlptype = 'SH'
    IMPORTING
      shlp     = ls_shlp.

  LOOP AT ls_shlp-interface ASSIGNING <if>.
    IF <if>-shlpfield = 'FORMID'.
      <if>-valfield   = 'FORMID'.
    ENDIF.
    IF <if>-shlpfield = 'VARIANT'.
      <if>-valfield   = 'VARIANT'.
    ENDIF.
  ENDLOOP.

* Benutzereingabe vor PAI holen
  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      i_field = '/THKR/DYNP_ELKO_BTE-FORMID'
      i_repid = '/THKR/SAPLFI_ELKO_BTE'
      i_dynnr = sy-dynnr
    CHANGING
      o_value = /thkr/dynp_elko_bte-formid.

  CALL FUNCTION 'GET_DYNP_VALUE'
    EXPORTING
      i_field = '/THKR/DYNP_ELKO_BTE-VARIANT'
      i_repid = '/THKR/SAPLFI_ELKO_BTE'
      i_dynnr = sy-dynnr
    CHANGING
      o_value = /thkr/dynp_elko_bte-variant.


  IF NOT /thkr/dynp_elko_bte-formid IS INITIAL.
    ls_selopt-shlpfield  = 'FORMID'.
    ls_selopt-sign       = 'I'.
    IF /thkr/dynp_elko_bte-formid CS '*'.
      ls_selopt-option     = 'CP'.
    ELSE.
      ls_selopt-option     = 'EQ'.
    ENDIF.
    ls_selopt-low        = /thkr/dynp_elko_bte-formid.

    APPEND ls_selopt TO ls_shlp-selopt.
  ENDIF.

  IF NOT /thkr/dynp_elko_bte-variant IS INITIAL.
    ls_selopt-shlpfield  = 'VARIANT'.
    ls_selopt-sign       = 'I'.
    IF /thkr/dynp_elko_bte-variant CS '*'.
      ls_selopt-option     = 'CP'.
    ELSE.
      ls_selopt-option     = 'EQ'.
    ENDIF.
    ls_selopt-low        = /thkr/dynp_elko_bte-variant.

    APPEND ls_selopt TO ls_shlp-selopt.
  ENDIF.

  CALL FUNCTION 'F4IF_START_VALUE_REQUEST'
    EXPORTING
      shlp          = ls_shlp
    TABLES
      return_values = lt_retval.

  IF NOT lt_retval IS INITIAL.
* Rückgabetabelle ist gefüllt:
    READ TABLE lt_retval INTO ls_retval WITH KEY fieldname = 'FORMID'.
    IF sy-subrc = 0.
      ls_fields-fieldvalue  = ls_retval-fieldval.
      ls_fields-fieldname   = '/THKR/DYNP_ELKO_BTE-FORMID'.
      APPEND ls_fields TO lt_fields.
    ENDIF.

    READ TABLE lt_retval INTO ls_retval WITH KEY fieldname = 'VARIANT'.
    IF sy-subrc = 0.
      ls_fields-fieldvalue  = ls_retval-fieldval.
      ls_fields-fieldname   = '/THKR/DYNP_ELKO_BTE-VARIANT'.
      APPEND ls_fields TO lt_fields.
    ENDIF.

    CALL FUNCTION 'DYNP_VALUES_UPDATE'
      EXPORTING
        dyname     = sy-cprog
        dynumb     = sy-dynnr
      TABLES
        dynpfields = lt_fields.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form N2P_APPEND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM n2p_append .
** nur falls aus dem Referenzteil kein Kassenzeichen ermittelt wurde
*  CHECK /thkr/dynp_elko_bte-vkassz IS INITIAL.
*
*  DATA:
*   lo_feb_bsproc           TYPE REF TO cl_feb_bsproc_bs_item.
*  DATA:
*    lt_n2p       TYPE cl_feb_n2p=>yt_note2payee,
*    lv_fistl     TYPE fistl,
*    lv_gjahr     TYPE gjahr,
*    ls_vkass     TYPE vwezw_eb,
*    lv_vkass_old TYPE xblnr,
*    lv_vkass     TYPE xblnr,
*    lv_kz_vkass  TYPE xfeld,
*    lv_subrc     TYPE sysubrc.
*  CLEAR:
*  lt_n2p.
**&---------------------------------------------------------------------*
** Auslesen Verwendungszweck
**&---------------------------------------------------------------------*
*  TRY.
*      CALL METHOD cl_feb_bsproc_bs_item=>get_instance
*        EXPORTING
*          i_kukey      = g_febep-kukey
*          i_esnum      = g_febep-esnum
**         ix_with_log  =
*        RECEIVING
*          ro_line_item = lo_feb_bsproc.
**try.
*      CALL METHOD lo_feb_bsproc->get_reference_record
**  exporting
**    i_original          =
*        RECEIVING
*          rt_reference_record = lt_n2p.
*    CATCH cx_feb .
*  ENDTRY.
**&---------------------------------------------------------------------*
** Verwahrkassenzeichen bereits vorhanden?
**&---------------------------------------------------------------------*
*  CLEAR lv_kz_vkass.
*  LOOP AT lt_n2p INTO ls_vkass.
*    IF ls_vkass+0(1) = gc_char_v AND ls_vkass+14(1) = gc_char_v.
*      lv_kz_vkass = gc_on.
*      lv_vkass_old = ls_vkass+1(13).
*      EXIT.
*    ENDIF.
*  ENDLOOP.
**&---------------------------------------------------------------------*
** Verwahrkassenzeichen anzeigen
**&---------------------------------------------------------------------*
*  IF  lv_kz_vkass = gc_on.
** call function 'POPUP_TO_CONFIRM'
** Idee war die Erzeugung eines weiteren Kassenzeichens bestätigen
** lassen, aber damit kann die Formularerzeugung heut nicht umgehen
** call function 'POPUP_TO_CONFIRM'
** deswegen einfach Kassenzeichen melden und raus
*
** normalerweise kann mit dem check auf das FElD /thkr/dynp_elko_bte-vkassz
** kein Kassenzeichen vorkommen, nur wenn der Anwender per Hand eines
** in den Verwendungszweck einträgt
*    MESSAGE i121 WITH lv_vkass_old.
*    EXIT.
*  ENDIF.
**&---------------------------------------------------------------------*
** Verwahrkassenzeichen neu ermitteln
**&---------------------------------------------------------------------*
*  CLEAR lv_vkass.
*  GET PARAMETER ID 'FIS' FIELD lv_fistl.
*
*  IF lv_fistl IS INITIAL.
*    lv_fistl = gc_fistl.
*  ENDIF.
*  lv_gjahr = sy-datum(4).
*
*
*
*  CALL FUNCTION 'Z_PSM_CREATE_KASSENZEICHEN'
*    EXPORTING
*      im_fistl         = lv_fistl
*      im_gjahr         = lv_gjahr
*      im_nrnr          = '00'
*    IMPORTING
*      ex_kassenzeichen = lv_vkass
**     ex_rc            =
*    EXCEPTIONS
*      wrong_dienst     = 1
*      wrong_checkno    = 2
*      wrong_number     = 3
*      wrong_gjahr      = 4
*      OTHERS           = 5.
*
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*    MESSAGE i122 WITH lv_fistl lv_gjahr .
*    EXIT.
*  ELSE.
*
*
**&---------------------------------------------------------------------*
** Verwendungszweck ergänzen
**&---------------------------------------------------------------------*
*
*    CONCATENATE gc_char_v lv_vkass  gc_char_v INTO  ls_vkass.
**    append  ls_vkass to lt_n2p.
*    /thkr/dynp_elko_bte-vkassz = ls_vkass.
*    MESSAGE i123 WITH /thkr/dynp_elko_bte-vkassz.
*  ENDIF.
*
*
*
***  try.
***
***      call method lo_feb_bsproc->set_reference_record
***        exporting
***          it_note2payee = lt_n2p.
***      .
***    catch cx_feb .
***  endtry.
***
***
***
***  try.
***      call method lo_feb_bsproc->save
***        exporting
***          i_draft  = gc_on
****         i_post   =
***        importing
***          ev_subrc = lv_subrc.
***    catch cx_feb .
***  endtry.
*
** brauchen wir hier noch ein Commit?
** brauchen wir ein "free" -um die Abfrage zu verhindern?
** free hat die Abfrage nicht verhindert, aber beim Verlassen des
** Programms und der free-Anweisung zum Dump geführt
****  try.
****      call method lo_feb_bsproc->free
****      exporting
****      ix_keep_enqueue = 'X'
****        .
****    catch cx_feb.
****  endtry.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ZZWVDATA_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zzwvdata_update .
** Übernahme der Daten-aktuell geht das noch nicht raus
*  IF g_febep-zz_wdvdat NE /thkr/dynp_elko_bte-wdvdat.
*    UPDATE febep SET zz_wdvdat = /thkr/dynp_elko_bte-wdvdat
*                 WHERE kukey  = g_febep-kukey
*                   AND esnum  = g_febep-esnum.
*
*    IF g_febep-kukey NE g_febep_new-kukey
*  OR g_febep-esnum NE g_febep_new-esnum.
*      g_febep_new = g_febep.
*    ENDIF.
*
*    g_febep_new-zz_wdvdat =  /thkr/dynp_elko_bte-wdvdat.
*    COMMIT WORK AND WAIT.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ZZAVDATA_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zzavdata_update .
** Übernahme der Daten-aktuell geht das noch nicht raus
*  IF g_febep-zz_avviso NE /thkr/dynp_elko_bte-avviso.
*    UPDATE febep SET zz_avviso = /thkr/dynp_elko_bte-avviso
*                 WHERE kukey  = g_febep-kukey
*                   AND esnum  = g_febep-esnum.
*    IF g_febep-kukey NE g_febep_new-kukey
*    OR g_febep-esnum NE g_febep_new-esnum.
*      g_febep_new = g_febep.
*    ENDIF.
*    g_febep_new-zz_avviso = /thkr/dynp_elko_bte-avviso.
*    COMMIT WORK AND WAIT.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form N2P_READ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM n2p_read .
*  DATA:
*   lo_feb_bsproc           TYPE REF TO cl_feb_bsproc_bs_item.
*  DATA:
*    lt_n2p       TYPE cl_feb_n2p=>yt_note2payee,
*    ls_vkass     TYPE vwezw_eb,
*    lv_vkass_old TYPE xblnr,
*    lv_vkass     TYPE xblnr,
*    lv_kz_vkass  TYPE xfeld,
*    lv_subrc     TYPE sysubrc.
*  CLEAR:
*  lt_n2p.
**&---------------------------------------------------------------------*
** Auslesen Verwendungszweck
**&---------------------------------------------------------------------*
*  TRY.
*      CALL METHOD cl_feb_bsproc_bs_item=>get_instance
*        EXPORTING
*          i_kukey      = g_febep-kukey
*          i_esnum      = g_febep-esnum
**         ix_with_log  =
*        RECEIVING
*          ro_line_item = lo_feb_bsproc.
**try.
*      CALL METHOD lo_feb_bsproc->get_reference_record
**  exporting
**    i_original          =
*        RECEIVING
*          rt_reference_record = lt_n2p.
*    CATCH cx_feb .
*  ENDTRY.
*
**&---------------------------------------------------------------------*
** Verwahrkassenzeichen bereits vorhanden?
**&---------------------------------------------------------------------*
*
*  LOOP AT lt_n2p INTO ls_vkass.
*    IF ls_vkass+0(1) = gc_char_v AND ls_vkass+14(1) = gc_char_v.
*      lv_vkass_old = ls_vkass+1(13).
*      EXIT.
*    ENDIF.
*  ENDLOOP.
**jetzt vollständig übernehmen
*  IF  lv_vkass_old IS NOT INITIAL.
*    /thkr/dynp_elko_bte-vkassz = ls_vkass(16).
*  ELSE.
*    CLEAR /thkr/dynp_elko_bte-vkassz.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ZZSTATUS_UPDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> _U_STATUS
*&---------------------------------------------------------------------*
FORM zzstatus_update  USING  u_status TYPE /thkr/el_bearbkz.
*
*  IF  g_febep-zz_status NE u_status.
*    UPDATE febep SET
*                        zz_status = u_status
*                    WHERE kukey  = g_febep-kukey
*                      AND esnum  = g_febep-esnum.
*    /thkr/dynp_elko_bte-status = u_status.
*    IF g_febep-kukey NE g_febep_new-kukey
*    OR g_febep-esnum NE g_febep_new-esnum.
*      g_febep_new = g_febep.
*    ENDIF.
*    g_febep_new-zz_status = u_status.
*    COMMIT WORK AND WAIT.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form wvdata_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM wvdata_check .
*  DATA: lv_vgl_dat TYPE dats.
*  CHECK /thkr/dynp_elko_bte-wdvdat IS NOT INITIAL.
*  CALL FUNCTION 'CALCULATE_DATE'
*    EXPORTING
**     DAYS        = '0'
*      months      = '12'
**     START_DATE  = SY-DATUM
*    IMPORTING
*      result_date = lv_vgl_dat.
*
*  IF /thkr/dynp_elko_bte-wdvdat  LT sy-datum OR
*     /thkr/dynp_elko_bte-wdvdat GT lv_vgl_dat.
*    MESSAGE e124.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_AZNUM
*&---------------------------------------------------------------------*
*&  f4-Hilfe für die Auszugsnummer aus SAPLNEW_FEBA
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_aznum.
*
*  DATA:
*    lt_dynpfields TYPE STANDARD TABLE OF dynpread
*                    WITH KEY fieldname,
*    ls_dynpfields TYPE dynpread,
*    lt_field      TYPE TABLE OF dfies,
*    lt_return     TYPE TABLE OF ddshretval,
*    ls_field      TYPE dfies,
*    ls_return     TYPE ddshretval,
*    BEGIN OF ls_value,
*      line(40),
*    END OF ls_value,
*    lt_value      LIKE TABLE OF ls_value,
*    lv_searchhelp TYPE shlpname,
*    lv_shlpparam  TYPE shlpfield,
*    lv_bukrs      TYPE bukrs,
*    lv_hbkid      TYPE hbkid,
*    lv_hktid      TYPE hktid,
*    lv_azdat_low  TYPE azdat_eb,
*    lv_azdat_high TYPE azdat_eb,
*    lv_kukey      TYPE kukey_eb,
*    lt_febko      TYPE TABLE OF febko,
*    ls_febko      TYPE febko.
*
*  ls_dynpfields-fieldname = 'SL_BUKRS-LOW'.
*  APPEND ls_dynpfields TO lt_dynpfields.
*  ls_dynpfields-fieldname = 'SL_HBKID-LOW'.
*  APPEND ls_dynpfields TO lt_dynpfields.
*  ls_dynpfields-fieldname = 'SL_HKTID-LOW'.
*  APPEND ls_dynpfields TO lt_dynpfields.
*  ls_dynpfields-fieldname = 'SL_AZDAT-LOW'.
*  APPEND ls_dynpfields TO lt_dynpfields.
*  ls_dynpfields-fieldname = 'SL_AZDAT-HIGH'.
*  APPEND ls_dynpfields TO lt_dynpfields.
*
*  CALL FUNCTION 'DYNP_VALUES_READ'
*    EXPORTING
*      dyname     = '/THKR/SAPLFI_ELKO_BTE'
*      dynumb     = '0060'
*    TABLES
*      dynpfields = lt_dynpfields.
*
*  READ TABLE lt_dynpfields INTO ls_dynpfields
*       WITH KEY fieldname = 'SL_BUKRS-LOW'.
*  lv_bukrs = ls_dynpfields-fieldvalue.
*  IF lv_bukrs IS INITIAL.
*    lv_bukrs = '%'.
*  ELSE.
*    TRANSLATE lv_bukrs TO UPPER CASE.
*  ENDIF.
*
*  READ TABLE lt_dynpfields INTO ls_dynpfields
*       WITH KEY fieldname = 'SL_HBKID-LOW'.
*  lv_hbkid = ls_dynpfields-fieldvalue.
*  IF lv_hbkid IS INITIAL.
*    lv_hbkid = '%'.
*  ELSE.
*    TRANSLATE lv_hbkid TO UPPER CASE.
*  ENDIF.
*
*  READ TABLE lt_dynpfields INTO ls_dynpfields
*       WITH KEY fieldname = 'SL_HKTID-LOW'.
*  lv_hktid = ls_dynpfields-fieldvalue.
*  IF lv_hktid IS INITIAL.
*    lv_hktid = '%'.
*  ELSE.
*    TRANSLATE lv_hktid TO UPPER CASE.
*  ENDIF.
*
*  READ TABLE lt_dynpfields INTO ls_dynpfields
*       WITH KEY fieldname = 'SL_AZDAT-LOW'.
*  CALL FUNCTION 'DATE_CONV_EXT_TO_INT'
*    EXPORTING
*      i_date_ext = ls_dynpfields-fieldvalue
*    IMPORTING
*      e_date_int = lv_azdat_low
*    EXCEPTIONS
*      OTHERS     = 1.
*  IF lv_azdat_low IS INITIAL OR sy-subrc NE 0.
*    lv_azdat_low  = '00000101'.
*  ENDIF.
*
*  READ TABLE lt_dynpfields INTO ls_dynpfields
*       WITH KEY fieldname = 'SL_AZDAT-HIGH'.
*  CALL FUNCTION 'DATE_CONV_EXT_TO_INT'
*    EXPORTING
*      i_date_ext = ls_dynpfields-fieldvalue
*    IMPORTING
*      e_date_int = lv_azdat_high
*    EXCEPTIONS
*      OTHERS     = 1.
*  IF lv_azdat_high IS INITIAL OR sy-subrc NE 0.
*    lv_azdat_high = '99991231'.
*  ENDIF.
*
*  SELECT * FROM febko INTO TABLE lt_febko
*    WHERE bukrs LIKE lv_bukrs
*      AND hbkid LIKE lv_hbkid
*      AND hktid LIKE lv_hktid
*      AND azdat BETWEEN lv_azdat_low AND lv_azdat_high.
*
*  ls_field-tabname   = 'FEBKO'.
*  ls_field-fieldname = 'BUKRS'. APPEND ls_field TO lt_field.
*  ls_field-fieldname = 'HBKID'. APPEND ls_field TO lt_field.
*  ls_field-fieldname = 'HKTID'. APPEND ls_field TO lt_field.
*  ls_field-fieldname = 'AZDAT'. APPEND ls_field TO lt_field.
*  ls_field-fieldname = 'AZNUM'. APPEND ls_field TO lt_field.
*  ls_field-fieldname = 'ABSND'. APPEND ls_field TO lt_field.
*  ls_field-fieldname = 'KUKEY'. APPEND ls_field TO lt_field.
*
*  LOOP AT lt_febko INTO ls_febko.
*    ls_value-line = ls_febko-bukrs.                   APPEND ls_value TO lt_value.
*    ls_value-line = ls_febko-hbkid.                   APPEND ls_value TO lt_value.
*    ls_value-line = ls_febko-hktid.                   APPEND ls_value TO lt_value.
*    WRITE ls_febko-azdat TO ls_value-line DD/MM/YYYY. APPEND ls_value TO lt_value.
*    ls_value-line = ls_febko-aznum.
*    SHIFT ls_value-line LEFT DELETING LEADING '0'.    APPEND ls_value TO lt_value.
*    ls_value-line = ls_febko-absnd.                   APPEND ls_value TO lt_value.
*    ls_value-line = ls_febko-kukey.                   APPEND ls_value TO lt_value.
*  ENDLOOP.
*
*  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*    EXPORTING
*      retfield        = 'KUKEY'
*    TABLES
*      value_tab       = lt_value
*      field_tab       = lt_field
*      return_tab      = lt_return
*    EXCEPTIONS
*      parameter_error = 1
*      no_values_found = 2
*      OTHERS          = 3.
*
*  READ TABLE lt_return INTO ls_return INDEX 1.
*  lv_kukey = ls_return-fieldval.
*
*  IF NOT lv_kukey IS INITIAL.
*    READ TABLE lt_febko INTO ls_febko WITH KEY kukey = lv_kukey.
*    IF sy-subrc EQ 0.
*
*      CLEAR:
*        ls_dynpfields,
*        lt_dynpfields.
*
*      ls_dynpfields-fieldname    = 'SL_BUKRS-LOW'.
*      ls_dynpfields-fieldvalue   = ls_febko-bukrs.
*      APPEND ls_dynpfields TO lt_dynpfields.
*
*      ls_dynpfields-fieldname    = 'SL_HBKID-LOW'.
*      ls_dynpfields-fieldvalue   = ls_febko-hbkid.
*      APPEND ls_dynpfields TO lt_dynpfields.
*
*      ls_dynpfields-fieldname    = 'SL_HKTID-LOW'.
*      ls_dynpfields-fieldvalue   = ls_febko-hktid.
*      APPEND ls_dynpfields TO lt_dynpfields.
*
*      ls_dynpfields-fieldname    = 'SL_AZDAT-LOW'.
*      WRITE ls_febko-azdat TO ls_dynpfields-fieldvalue DD/MM/YYYY.
*      APPEND ls_dynpfields TO lt_dynpfields.
*      ls_dynpfields-fieldname    = 'SL_AZDAT-HIGH'.
*      CLEAR ls_dynpfields-fieldvalue.
*      APPEND ls_dynpfields TO lt_dynpfields.
*
*      ls_dynpfields-fieldname    = 'SL_AZNUM-LOW'.
*      ls_dynpfields-fieldvalue   = ls_febko-aznum.
*      SHIFT ls_dynpfields-fieldvalue LEFT DELETING LEADING '0'.
*      APPEND ls_dynpfields TO lt_dynpfields.
*
*      CALL FUNCTION 'DYNP_VALUES_UPDATE'
*        EXPORTING
*          dyname     = '/THKR/SAPLFI_ELKO_BTE'
*          dynumb     = '0060'
*        TABLES
*          dynpfields = lt_dynpfields
*        EXCEPTIONS
*          OTHERS     = 0.
*
*    ENDIF.
*  ENDIF.

ENDFORM.
