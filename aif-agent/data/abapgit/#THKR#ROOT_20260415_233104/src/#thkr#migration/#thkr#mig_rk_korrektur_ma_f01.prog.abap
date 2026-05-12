*----------------------------------------------------------------------*
***INCLUDE /THKR/MIG_RK_KORREKTUR_MA_F01.
*----------------------------------------------------------------------*

*/THKR/MIGDAO-KENNZEICHENSTUNDUNG
*S  Stundung
*R Ratenstundung
*N Befristete Niederschlagung
*U Unbefristete Niederschlagung

**********************************************************************
* Achtung das Include wird auch in /THKR/MIG_RK_KORREKTUR_MAHNST
* verwendet
**********************************************************************

*&---------------------------------------------------------------------*
*& Form check_change
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_MIG_DATA>_MADAT
*&      --> <FS_MIG_DATA>_MADAT
*&      --> P_CMDA
*&      <-- GV_CHANGE
*&---------------------------------------------------------------------*
FORM check_change  USING    pv_old     TYPE any
                            pv_new     TYPE any
                            pv_over    TYPE abap_bool
                            pv_never   TYPE abap_bool "Nie wegschreiben
                   CHANGING pv_change  TYPE abap_bool.


  pv_change = abap_false.


* Nie den Wert ändern
  IF pv_never EQ abap_true.
    EXIT.
  ENDIF.


  IF pv_old NE pv_new.  "Änderung liegt vor und ...

*   .. aber der vorhandene Wert soll nicht überschrieben werden
    IF pv_old IS NOT INITIAL AND pv_over EQ abap_true
    OR pv_old IS INITIAL.

      pv_change = abap_true.

    ENDIF.

  ENDIF.


ENDFORM.




**********************************************************************
* FORM GET_NEW_DATA
* Ermitteln der neu Belegdaten
**********************************************************************
FORM get_new_data CHANGING ps_data  TYPE ty_data
                           pv_error TYPE abap_bool.



* Mahndatum
  PERFORM get_new_madat CHANGING ps_data
                                 pv_error.

* Mahnsperre
  PERFORM get_new_mansp CHANGING ps_data
                                 pv_error.


* Mahnstufe
  PERFORM get_new_manst CHANGING ps_data
                                 pv_error.



* Datum Wiedervorlage
  PERFORM get_new_resubmission CHANGING ps_data
                                        pv_error.


  IF  ps_data-mansp NE ps_data-mansp_new.
    ps_data-mansp_changed = abap_true.
  ENDIF.

  IF ps_data-manst NE ps_data-manst_new.
    ps_data-manst_changed = abap_true.
  ENDIF.

  IF ps_data-madat NE ps_data-madat_new.
    ps_data-madat_changed = abap_true.
  ENDIF.

  IF ps_data-resubmission NE ps_data-resub_new.
    ps_data-resub_changed = abap_true.
  ENDIF.

ENDFORM.


**********************************************************************
* FORM GET_NEW_MADAT
* neues Mahndatum ermitteln
**********************************************************************
FORM get_new_madat  CHANGING ps_data  TYPE ty_data
                            pv_error TYPE abap_bool.

  DATA: lv_letzte TYPE dats.
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MOVE ps_data-dat_letz_mahnung TO lv_letzte.

  IF ps_data-dat_letz_mahnung NE '0'.
    lv_letzte = ps_data-dat_letz_mahnung.
  ENDIF.

  IF lv_letzte = '0' OR lv_letzte IS INITIAL.
    CLEAR lv_letzte.
  ENDIF.


*1. Wenn    /THKR/MIGDAO-KENNZEICHENSTUNDUNG         leer dann:
*    Datum der letzten Mahnung                     = DAT_LETZT_MAHNUNG
  IF ps_data-kennzeichenstundung = '' OR ps_data-kennzeichenstundung IS INITIAL.

    ps_data-madat_new = lv_letzte.

    EXIT.
  ENDIF.

*2. Wenn    /THKR/MIGDAO- KENNZEICHENSTUNDUNG = S oder R Und EPL = 11
*    Datum der letzten Mahnung                     = DAT_LETZT_MAHNUNG
  IF ( ps_data-kennzeichenstundung = 'S' OR ps_data-kennzeichenstundung = 'R' )
  AND ps_data-einzelplan = '11'.

    ps_data-madat_new = lv_letzte.

    EXIT.
  ENDIF.

*3. Wenn    /THKR/MIGDAO- KENNZEICHENSTUNDUNG = N oder U Und EPL = 11
*    Datum der letzten Mahnung                     = DAT_LETZT_MAHNUNG
  IF ( ps_data-kennzeichenstundung = 'N' OR ps_data-kennzeichenstundung = 'U' )
  AND ps_data-einzelplan = '11'.

    ps_data-madat_new = lv_letzte.

    EXIT.
  ENDIF.

*4. Wenn    /THKR/MIGDAO-KENNZEICHENSTUNDUNG = U und N  und EPL <> 11
*    Datum der letzten Mahnung                     = DAT_LETZT_MAHNUNG
  IF ( ps_data-kennzeichenstundung = 'U' OR ps_data-kennzeichenstundung = 'N' )
  AND ps_data-einzelplan NE '11'.

    ps_data-madat_new = lv_letzte.

    EXIT.
  ENDIF.


ENDFORM.


**********************************************************************
* FORM GET_NEW_MANSP
* neue Mahnsperre ermitteln
**********************************************************************
FORM get_new_mansp CHANGING ps_data  TYPE ty_data
                            pv_error TYPE abap_bool.

  DATA: lv_date TYPE dats.
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  MOVE ps_data-faellig_dtu TO lv_date.
  IF lv_date = '0' OR lv_date = ' ' OR lv_date = ''.
    CLEAR lv_date.
  ENDIF.


*1. Wenn    /THKR/MIGDAO-KENNZEICHENSTUNDUNG         leer dann:
*   Mahnsperre
*   /THKR/MIGDAO-ADFSCHLUESSEL
*     S1                                   = 8
*     S2                                   = 9
*   RK_POS-ADF_KEY
*     B1                                   = B
*   RK_POS-FAELLIG_DTU  > 31.12.2025       = A
  IF ps_data-kennzeichenstundung = ' ' OR ps_data-kennzeichenstundung IS INITIAL OR ps_data-kennzeichenstundung = ''.

    IF ps_data-adfschluessel = 'S1' OR ps_data-adfschluessel = 's1'.
      ps_data-mansp_new = '8'.

    ELSEIF ps_data-adfschluessel = 'S2' OR ps_data-adfschluessel = 's2'.
      ps_data-mansp_new = '9'.

    ELSEIF ps_data-adf_key = 'B1' OR ps_data-adf_key = 'b1'.
      ps_data-mansp_new = 'B'.

    ELSEIF lv_date > '20251231'.
      ps_data-mansp_new = 'A'.
    ENDIF.

    EXIT.
  ENDIF.

*2. Wenn    /THKR/MIGDAO- KENNZEICHENSTUNDUNG = S oder R Und EPL = 11
*    Mahnsperre   = E
  IF ( ps_data-kennzeichenstundung = 'S' OR ps_data-kennzeichenstundung = 'R' )
  AND ps_data-einzelplan = '11'.

    ps_data-mansp_new = 'E'.

    EXIT.
  ENDIF.

*3. Wenn    /THKR/MIGDAO- KENNZEICHENSTUNDUNG = N oder U Und EPL = 11
*    Mahnsperre  = F (bei befristeter Niederschlagung)
*    Mahnsperre  = G (bei unbefristeter Niederschlagung)
*   N Befristete Niederschlagung
*   U Unbefristete Niederschlagung
  IF ( ps_data-kennzeichenstundung = 'N' OR ps_data-kennzeichenstundung = 'U' )
  AND ps_data-einzelplan = '11'.

    CASE ps_data-kennzeichenstundung.
      WHEN 'N'. "Befristete Niederschlagung
        ps_data-mansp_new = 'F'.
      WHEN 'U'.
        ps_data-mansp_new = 'G'.
    ENDCASE.

    EXIT.
  ENDIF.

*4. Wenn    /THKR/MIGDAO-KENNZEICHENSTUNDUNG = U und N  und EPL <> 11
*    Mahnsperre  = 6 (bei befristeter Niederschlagung)
*    Mahnsperre  = 7 (bei unbefristeter Niederschlagung)
*   N Befristete Niederschlagung
*   U Unbefristete Niederschlagung
  IF ( ps_data-kennzeichenstundung = 'U' OR ps_data-kennzeichenstundung = 'N' )
  AND ps_data-einzelplan NE '11'.

    CASE ps_data-kennzeichenstundung.
      WHEN 'N'. "Befristete Niederschlagung
        ps_data-mansp_new = '6'.
      WHEN 'U'. "Unbefristete Niederschlagung
        ps_data-mansp_new = '7'.
    ENDCASE.

    EXIT.
  ENDIF.

*5. Wenn    /THKR/MIGDAO- KENNZEICHENSTUNDUNG = S oder R Und EPL = 11
*    Mahnsperre   = leer
  IF ( ps_data-kennzeichenstundung = 'S' OR ps_data-kennzeichenstundung = 'R' )
  AND ps_data-einzelplan NE '11'.

    CLEAR ps_data-mansp_new.

    EXIT.
  ENDIF.


ENDFORM.


**********************************************************************
* FORM GET_NEW_RESUBMISSION
* neues Wiedervcrlagedatum ermitteln
**********************************************************************
FORM get_new_RESUBMISSION CHANGING ps_data  TYPE ty_data
                                   pv_error TYPE abap_bool.

  DATA: lv_date TYPE dats.
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MOVE ps_data-stundungsende TO lv_date.
  IF lv_date = '0' OR lv_date = ' ' OR lv_date = ''.
    CLEAR lv_date.
  ENDIF.

*1. Wenn    /THKR/MIGDAO-KENNZEICHENSTUNDUNG         leer dann:
*   Resubmission = leer
  IF ps_data-kennzeichenstundung = '' OR ps_data-kennzeichenstundung IS INITIAL.
    CLEAR ps_data-resub_new.
    EXIT.
  ENDIF.

*2. Wenn    /THKR/MIGDAO- KENNZEICHENSTUNDUNG = S oder R Und EPL = 11
*   Resubmission = leer
  IF ( ps_data-kennzeichenstundung = 'S' OR ps_data-kennzeichenstundung = 'R' )
  AND ps_data-einzelplan = '11'.
    CLEAR ps_data-resub_new.
    EXIT.
  ENDIF.

*3. Wenn    /THKR/MIGDAO- KENNZEICHENSTUNDUNG = N oder U Und EPL = 11
*   Resubmission = /THKR/MIGDAO-Stundungsende
  IF ( ps_data-kennzeichenstundung = 'N' OR ps_data-kennzeichenstundung = 'U' )
  AND ps_data-einzelplan = '11'.

    ps_data-resub_new = lv_date.
    EXIT.
  ENDIF.

*4. Wenn    /THKR/MIGDAO-KENNZEICHENSTUNDUNG = U und N  und EPL <> 11
*   Resubmission = /THKR/MIGDAO-Stundungsende
  IF ( ps_data-kennzeichenstundung = 'U' OR ps_data-kennzeichenstundung = 'N' )
  AND ps_data-einzelplan NE '11'.

    ps_data-resub_new = lv_date.
    EXIT.
  ENDIF.

*5. Wenn    /THKR/MIGDAO- KENNZEICHENSTUNDUNG = S oder R Und EPL <> 11
*   Resubmission = leer
  IF ( ps_data-kennzeichenstundung = 'S' OR ps_data-kennzeichenstundung = 'R' )
  AND ps_data-einzelplan NE '11'.
    CLEAR ps_data-resub_new.
    EXIT.
  ENDIF.

ENDFORM.

**********************************************************************
* FORM GET_NEW_MANST
* neue Mahnstufe emitteln
**********************************************************************
FORM get_new_manst CHANGING ps_data  TYPE ty_data
                            pv_error TYPE abap_bool.

*Mahnstufe
*RK-POS-Mahnstatus      Mahnstufe
*0                      leer
*1                      1
*2-9 oder V             2
*R                      R

  CASE ps_data-mahnstatus.
    WHEN '0'.
      ps_data-manst_new = ' '.
    WHEN '1'.
      ps_data-manst_new = '1'.
    WHEN '2'.
      ps_data-manst_new = '2'.
    WHEN '3'.
      ps_data-manst_new = '2'.
    WHEN '4'.
      ps_data-manst_new = '2'.
    WHEN '5'.
      ps_data-manst_new = '2'.
    WHEN '6'.
      ps_data-manst_new = '2'.
    WHEN '7'.
      ps_data-manst_new = '2'.
    WHEN '8'.
      ps_data-manst_new = '2'.
    WHEN '9'.
      ps_data-manst_new = '2'.
    WHEN 'r' OR 'R'.
      ps_data-manst_new = 'R'.
    WHEN 'v' OR 'V'.
      ps_data-manst_new = '2'.
    WHEN OTHERS.
      ps_data-type = 'E'.
      ps_data-message = |ungültige Mahnstufe { ps_data-mahnstatus }|.
      pv_error = abap_true.
  ENDCASE.


ENDFORM.

**********************************************************************
* FORM SET_COLUMNS
* Tabellenüberschriften
**********************************************************************
FORM set_columns USING po_salv TYPE REF TO cl_salv_table.


  TRY.

      po_salv->get_columns( )->get_column( 'CNT' )->set_short_text( 'AnzFAP' ).
      po_salv->get_columns( )->get_column( 'CNT' )->set_long_text( 'AnzFAP' ).
      po_salv->get_columns( )->get_column( 'CNT' )->set_medium_text( 'AnzFAP' ).

      po_salv->get_columns( )->get_column( 'MADAT' )->set_short_text( 'MahnDat' ).
      po_salv->get_columns( )->get_column( 'MADAT' )->set_long_text( 'Mahndatum' ).
      po_salv->get_columns( )->get_column( 'MADAT' )->set_medium_text( 'Mahndatum' ).

      po_salv->get_columns( )->get_column( 'MADAT_NEW' )->set_short_text( 'MahDat neu' ).
      po_salv->get_columns( )->get_column( 'MADAT_NEW' )->set_long_text( 'MahnDat neu' ).
      po_salv->get_columns( )->get_column( 'MADAT_NEW' )->set_medium_text( 'MahnDat neu' ).

      po_salv->get_columns( )->get_column( 'MANSP_NEW' )->set_short_text( 'MahnSp neu' ).
      po_salv->get_columns( )->get_column( 'MANSP_NEW' )->set_long_text( 'MahnSp neu' ).
      po_salv->get_columns( )->get_column( 'MANSP_NEW' )->set_medium_text( 'MahnSp neu' ).

      po_salv->get_columns( )->get_column( 'MANST_NEW' )->set_short_text( 'ManSt neu' ).
      po_salv->get_columns( )->get_column( 'MANST_NEW' )->set_long_text( 'MahnSt neu' ).
      po_salv->get_columns( )->get_column( 'MANST_NEW' )->set_medium_text( 'MahnSt neu' ).

      po_salv->get_columns( )->get_column( 'RESUB_NEW' )->set_long_text( 'Wiedervorl. neu' ).
      po_salv->get_columns( )->get_column( 'RESUB_NEW' )->set_medium_text( 'Wiedervorl. neu' ).
      po_salv->get_columns( )->get_column( 'RESUB_NEW' )->set_medium_text( 'Wiedervorl. neu' ).

      po_salv->get_columns( )->get_column( 'DAT_LETZ_MAHNUNG' )->set_short_text( 'letzMahRK' ).
      po_salv->get_columns( )->get_column( 'DAT_LETZ_MAHNUNG' )->set_long_text( 'Datum letzte Mahn RK' ).
      po_salv->get_columns( )->get_column( 'DAT_LETZ_MAHNUNG' )->set_medium_text( 'Datum letzte Mahn RK' ).

      po_salv->get_columns( )->get_column( 'DAT_MAHNSPERRE_BIS' )->set_short_text( 'ManSpBisRK' ).
      po_salv->get_columns( )->get_column( 'DAT_MAHNSPERRE_BIS' )->set_long_text( 'MahnSp bis RK' ).
      po_salv->get_columns( )->get_column( 'DAT_MAHNSPERRE_BIS' )->set_medium_text( 'MahnSp bis RK' ).

      po_salv->get_columns( )->get_column( 'FAELLIG_DTU' )->set_short_text( 'Fälligk RK' ).
      po_salv->get_columns( )->get_column( 'FAELLIG_DTU' )->set_long_text( 'Fälligkeit RK' ).
      po_salv->get_columns( )->get_column( 'FAELLIG_DTU' )->set_medium_text( 'Fälligkeit RK' ).

      po_salv->get_columns( )->get_column( 'MAHNSTATUS' )->set_short_text( 'ManStRK' ).
      po_salv->get_columns( )->get_column( 'MAHNSTATUS' )->set_long_text( 'Mahnstatus RK' ).
      po_salv->get_columns( )->get_column( 'MAHNSTATUS' )->set_medium_text( 'Mahnstatus RK' ).

      po_salv->get_columns( )->get_column( 'ADF_KEY' )->set_short_text( 'ADF_KEY RK' ).
      po_salv->get_columns( )->get_column( 'ADF_KEY' )->set_long_text( 'ADF_KEY RK' ).
      po_salv->get_columns( )->get_column( 'ADF_KEY' )->set_medium_text( 'ADF_KEY RK' ).

      po_salv->get_columns( )->get_column( 'STUNDUNGSENDE' )->set_short_text( 'StundEndRK' ).
      po_salv->get_columns( )->get_column( 'STUNDUNGSENDE' )->set_long_text( 'Stundungsende RK' ).
      po_salv->get_columns( )->get_column( 'STUNDUNGSENDE' )->set_medium_text( 'Stundungsende RK' ).

      po_salv->get_columns( )->get_column( 'EINZELPLAN' )->set_short_text( 'EPL' ).
      po_salv->get_columns( )->get_column( 'EINZELPLAN' )->set_long_text( 'Einzelplan' ).
      po_salv->get_columns( )->get_column( 'EINZELPLAN' )->set_medium_text( 'Einzelplan' ).

      po_salv->get_columns( )->get_column( 'KENNZEICHENSTUNDUNG' )->set_short_text( 'KzStund' ).
      po_salv->get_columns( )->get_column( 'KENNZEICHENSTUNDUNG' )->set_long_text( 'KennzStundung' ).
      po_salv->get_columns( )->get_column( 'KENNZEICHENSTUNDUNG' )->set_medium_text( 'KennzStundung' ).

      po_salv->get_columns( )->get_column( 'ADFSCHLUESSEL' )->set_short_text( 'ADFSchl' ).
      po_salv->get_columns( )->get_column( 'ADFSCHLUESSEL' )->set_long_text( 'ADF Schl. MIGDAO' ).
      po_salv->get_columns( )->get_column( 'ADFSCHLUESSEL' )->set_medium_text( 'ADF Schl. MIGDAO' ).

      po_salv->get_columns( )->get_column( 'MANSP_CHANGED' )->set_short_text( 'ManSpÄnd' ).
      po_salv->get_columns( )->get_column( 'MANSP_CHANGED' )->set_long_text( 'ManSpÄndern' ).
      po_salv->get_columns( )->get_column( 'MANSP_CHANGED' )->set_medium_text( 'ManSpÄndern' ).

      po_salv->get_columns( )->get_column( 'MANST_CHANGED' )->set_short_text( 'ManStÄnd' ).
      po_salv->get_columns( )->get_column( 'MANST_CHANGED' )->set_long_text( 'ManStÄndern' ).
      po_salv->get_columns( )->get_column( 'MANST_CHANGED' )->set_medium_text( 'ManStÄndern' ).

      po_salv->get_columns( )->get_column( 'MADAT_CHANGED' )->set_short_text( 'MaDatÄnd' ).
      po_salv->get_columns( )->get_column( 'MADAT_CHANGED' )->set_long_text( 'MaDatÄndern' ).
      po_salv->get_columns( )->get_column( 'MADAT_CHANGED' )->set_medium_text( 'MaDatÄndern' ).

      po_salv->get_columns( )->get_column( 'RESUB_CHANGED' )->set_short_text( 'ResubÄnd' ).
      po_salv->get_columns( )->get_column( 'RESUB_CHANGED' )->set_long_text( 'ResubÄndern' ).
      po_salv->get_columns( )->get_column( 'RESUB_CHANGED' )->set_medium_text( 'ResubÄndern' ).

      po_salv->get_columns( )->get_column( 'CHANGENR' )->set_short_text( 'ChangeNR' ).
      po_salv->get_columns( )->get_column( 'CHANGENR' )->set_long_text( 'ChangeNR' ).
      po_salv->get_columns( )->get_column( 'CHANGENR' )->set_medium_text( 'ChangeNR' ).

      po_salv->get_columns( )->get_column( 'VALUE_OLD' )->set_short_text( 'ValueOld' ).
      po_salv->get_columns( )->get_column( 'VALUE_OLD' )->set_long_text( 'ValueOld' ).
      po_salv->get_columns( )->get_column( 'VALUE_OLD' )->set_medium_text( 'ValueOld' ).

      po_salv->get_columns( )->get_column( 'VALUE_NEW' )->set_short_text( 'ValueNew' ).
      po_salv->get_columns( )->get_column( 'VALUE_NEW' )->set_long_text( 'ValueNew' ).
      po_salv->get_columns( )->get_column( 'VALUE_NEW' )->set_medium_text( 'ValueNew' ).

      po_salv->get_columns( )->get_column( 'HAUP_NEBENFORDERUNG' )->set_short_text( 'HF' ).
      po_salv->get_columns( )->get_column( 'HAUP_NEBENFORDERUNG' )->set_long_text( 'HauptNeben' ).
      po_salv->get_columns( )->get_column( 'HAUP_NEBENFORDERUNG' )->set_medium_text( 'HauptNeben' ).

      po_salv->get_columns( )->get_column( 'HAUSHALTSJAHR' )->set_short_text( 'HausJahr' ).
      po_salv->get_columns( )->get_column( 'HAUSHALTSJAHR' )->set_long_text( 'Haushaltsjahr' ).
      po_salv->get_columns( )->get_column( 'HAUSHALTSJAHR' )->set_medium_text( 'Haushaltsjahr' ).

      po_salv->get_columns( )->get_column( 'SOLLHF' )->set_short_text( 'SollHF' ).
      po_salv->get_columns( )->get_column( 'SOLLHF' )->set_long_text( 'SollHF' ).
      po_salv->get_columns( )->get_column( 'SOLLHF' )->set_medium_text( 'SollHF' ).

      po_salv->get_columns( )->get_column( 'RK_POS_NR_HAUSHALTSJAHR' )->set_short_text( 'RK HaushJ' ).
      po_salv->get_columns( )->get_column( 'RK_POS_NR_HAUSHALTSJAHR' )->set_long_text( 'RK Haushaltsjahr' ).
      po_salv->get_columns( )->get_column( 'RK_POS_NR_HAUSHALTSJAHR' )->set_medium_text( 'RK Haushaltsjahr' ).

    CATCH cx_root INTO DATA(lr_cx).

  ENDTRY.

ENDFORM.


**********************************************************************
* FROM SAVE_LOGGING
**********************************************************************
FORM save_logging USING pv_guid TYPE guid_32
                        ps_data TYPE  ty_data.

  DATA: ls_log TYPE /thkr/migkormst.
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  TRY.
      DATA(l_uuid_c32) = cl_system_uuid=>create_uuid_c32_static( ).
    CATCH cx_root INTO DATA(lo_pcx).
  ENDTRY.

  MOVE-CORRESPONDING ps_data TO ls_log.

  ls_log-chdate = sy-datum.
  ls_log-chtime = sy-uzeit.
  ls_log-chuser = sy-uname.
  ls_log-pguid  = l_uuid_c32.
  ls_log-kguid  = pv_guid.


  MODIFY /thkr/migkormst FROM ls_log.
  CALL FUNCTION 'DB_COMMIT'.

ENDFORM.




**********************************************************************
* Vorgaben
**********************************************************************
*Es wird nur geändert: /THKR/MIG_AO_SAP-BELNR
*
*S  Stundung
*R Ratenstundung
*N Befristete Niederschlagung
*U Unbefristete Niederschlagung
*
*
*Wenn    /THKR/MIGDAO-KENNZEICHENSTUNDUNG         leer dann:
*Resubmission                                                  = leer
*Mahnstufe
*RK-POS-Mahnstatus                                      Mahnstufe
*0                                                                            = leer
*1                                                                            = 1
*2-9 oder V                                                          = 2
*R                                                                            = R
*Mahnsperre
*/THKR/MIGDAO-ADFSCHLUESSEL
*S1                                                                          = 8
*S2                                                                          = 9
*RK_POS-ADF_KEY
*B1                                                                          = B
*RK_POS-FAELLIG_DTU  > 31.12.2025       = A
*
*Datum der letzten Mahnung                     = DAT_LETZT_MAHNUNG
*
*
*
*Wenn    /THKR/MIGDAO- KENNZEICHENSTUNDUNG = S oder R Und EPL = 11
*Resubmission                                                  = leer
*Mahnstufe
*RK-POS-Mahnstatus                                      Mahnstufe
*0                                                                            = leer
*1                                                                            = 1
*2-9 oder V                                                          = 2
*R                                                                            = R
*Mahnsperre                                                     = E
*Datum der letzten Mahnung                     = DAT_LETZT_MAHNUNG
*
*
*Wenn    /THKR/MIGDAO- KENNZEICHENSTUNDUNG = N oder U Und EPL = 11
*Resubmission                                                  = /THKR/MIGDAO-Stundungsende
*Mahnstufe
*RK-POS-Mahnstatus                                      Mahnstufe
*0                                                                            = leer
*1                                                                            = 1
*2-9 oder V                                                          = 2
*R                                                                            = R
*Mahnsperre                                                     = F bei (bei befristeter Niederschlagung)
*Mahnsperre                                                     = G (bei unbefristeter Niederschlagung)
*Datum der letzten Mahnung                     = DAT_LETZT_MAHNUNG
*
*
*Wenn    /THKR/MIGDAO-KENNZEICHENSTUNDUNG = U und N  und EPL <> 11
*Resubmission                                                  = /THKR/MIGDAO-Stundungsende
*Mahnstufe
*RK-POS-Mahnstatus                                      Mahnstufe
*0                                                                            = leer
*1                                                                            = 1
*2-9 oder V                                                          = 2
*R                                                                            = R
*Mahnsperre                                                     = 6 bei (bei befristeter Niederschlagung)
*Mahnsperre                                                     = 7 (bei unbefristeter Niederschlagung)
*Datum der letzten Mahnung                     = DAT_LETZT_MAHNUNG
*
*
*


**1. Wenn    /THKR/MIGDAO-KENNZEICHENSTUNDUNG         leer dann:
*  IF ps_data-kennzeichenstundung = '' OR ps_data-kennzeichenstundung IS INITIAL.
*
*    EXIT.
*  ENDIF.
*
**2. Wenn    /THKR/MIGDAO- KENNZEICHENSTUNDUNG = S oder R Und EPL = 11
*  IF ( ps_data-kennzeichenstundung = 'S' OR ps_data-kennzeichenstundung = 'R' )
*  AND ps_data-einzelplan = '11'.
*
*    EXIT.
*  ENDIF.
*
**3. Wenn    /THKR/MIGDAO- KENNZEICHENSTUNDUNG = N oder U Und EPL = 11
*  IF ( ps_data-kennzeichenstundung = 'N' OR ps_data-kennzeichenstundung = 'U' )
*  AND ps_data-einzelplan = '11'.
*
*    EXIT.
*  ENDIF.
*
**4. Wenn    /THKR/MIGDAO-KENNZEICHENSTUNDUNG = U und N  und EPL <> 11
*  IF ( ps_data-kennzeichenstundung = 'N' OR ps_data-kennzeichenstundung = 'U' )
*  AND ps_data-einzelplan NE '11'.
*
*    EXIT.
*  ENDIF.
*&---------------------------------------------------------------------*
*& Form get_change_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_BUKRS
*&      --> GV_BELNR
*&      --> GV_JAHR
*&      <-- GS_MIG_DATA
*&---------------------------------------------------------------------*
FORM get_change_data  USING    pv_bukrs    TYPE bukrs
                               pv_belnr    TYPE belnr_d
                               pv_jahr     TYPE gjahr
                      CHANGING ps_mig_data TYPE ty_data.


  DATA: ls_cdpos    TYPE ty_cdpos,
        lv_objectid TYPE cdobjectv.
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  CLEAR ls_cdpos.

  lv_objectid = |{ sy-mandt }{ gv_bukrs }{ gv_belnr }{ gv_gjahr }|.    "100R09060002024002025

  SELECT changenr, value_new, value_old
    FROM cdpos
    WHERE objectclas = 'BELEG'
      AND objectid   = @lv_objectid
      AND tabname    = 'BSEG'
      AND fname      = 'MANST'
    ORDER BY changenr DESCENDING
    INTO CORRESPONDING FIELDS OF @ls_cdpos
    UP TO 1 ROWS.
  ENDSELECT.

  IF sy-subrc EQ 0.
    TRY.
        ps_mig_data-changenr = ls_cdpos-changenr.
        ps_mig_data-value_old = ls_cdpos-value_old.
        ps_mig_data-VALUE_new = ls_cdpos-VALUE_new.
      CATCH cx_root INTO DATA(lr_cx).
    ENDTRY.
  ENDIF.


ENDFORM.
