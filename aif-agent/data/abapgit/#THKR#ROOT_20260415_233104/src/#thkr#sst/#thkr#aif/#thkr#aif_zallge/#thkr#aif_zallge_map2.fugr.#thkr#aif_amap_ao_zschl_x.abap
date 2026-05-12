FUNCTION /thkr/aif_amap_ao_zschl_x .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT)
*"     REFERENCE(RAW_LINE) TYPE  /THKR/S_AIF_BIC_ZEILE
*"     REFERENCE(SMAP) TYPE  /AIF/T_SMAP
*"     REFERENCE(INTREC) TYPE  /AIF/T_INTREC
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(OUT_STRUCT) TYPE  /THKR/S_AIF_SAP
*"     REFERENCE(DEST_LINE) TYPE  /THKR/S_AIF_SAP_AO
*"     REFERENCE(DEST_TABLE) TYPE  /THKR/T_DTO_PSM_AO_BEL_CREATE
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------

  DATA: lv_rc TYPE nrreturn.
  IF dest_line-annao_ref_zhlwg_x IS NOT INITIAL.
    "Wenn das Feld annao_ref_zhlwg_x gefüllt ist, gibt es Verrechnungen (Zahlweg x)
    "Muss aktiv im AIF gemappt werden.


    "Für Auszahlungsanordnung mit Referenz auf Einnahmesollstellung
    " Es wird aus einem FUA Datensatz sowohl die Annahme- als auch die Auszahlungsanordnung erzeugt
    " Nach Anlage der Annahmeanordnung muss die Referenz in die entsprechende Auszahlungsanordnung geschrieben werden.
    DATA(lv_count) = 0.


    "Sondermechanismus für BIENE, um die Annahme- bzw. Auszahlungsanordnung des Landes(01) mit der des Bundes (03) und Kommune (02) zu verknüpfen.
    "In diesem Fall wird das Kassenzeichen der allg. Annahmeanordnung sowohl im Belegkopftext als auch in das Referenzfeld geschrieben (sind also gleich)
    "SAMBA benötigt diese Regelung nicht. Hier dürfen die erzeugen Annahmeanordnung nicht miteinander verkettet werden.
    "SAMBA liefert im Belegkopftext das Kassenzeichen der allg. Annahmeanordnung und im Referenzfeld die eindeutige Zeilenidentifikation
    IF dest_line-bktxt <> dest_line-annao_ref_zhlwg_x AND dest_line-psoty = 02.
      "Verknüpfung der Annahme- oder Auszahlungsanordnung für das Land (01)
      "mit Annahmeanorndung für Bund (03) und Kommune (02) (Im Rahmen der Verrechnung)
      READ TABLE dest_table ASSIGNING FIELD-SYMBOL(<ls_ao>) WITH KEY bktxt = dest_line-bktxt
                                                                     annao_ref_zhlwg_x = dest_line-bktxt.

      "Ermittlung des Kassenzeichen für die Annahmeanordnung
      IF sy-subrc = 0.
        dest_line-bktxt = <ls_ao>-xblnr.

*        lv_count += 1.

        "Kassenzeichen im Mapping bilden
        IF dest_line-xblnr IS INITIAL.
          /thkr/cl_kassenzeichen=>create( EXPORTING i_fonds = dest_line-t_kont[ 1 ]-geber
                                                                i_gsber = dest_line-t_kont[ 1 ]-gsber
                                                                i_nrnr  = '00'
                                                      IMPORTING e_kaz   = dest_line-xblnr
                                                                e_rc    = lv_rc ).
        ENDIF.
*
*        IF 1 = 0. MESSAGE s067(/thkr/sst) WITH dest_line-lotkz dest_line-xblnr. ENDIF.
*        APPEND VALUE #( id         = '/THKR/SST'
*                         number     = 067
*                         type       = 'S'
*                         message_v1 = dest_line-lotkz
*                         message_v2 = |{ CONV string( lv_count ) ALPHA = OUT }|
*                         message_v3 = dest_line-xblnr ) TO return_tab.
*      ELSE.
*        IF 1 = 0. MESSAGE e066(/thkr/sst) WITH dest_line-bukrs dest_line-gjahr dest_line-belnr. ENDIF.
*        APPEND VALUE #( id         = '/THKR/SST'
*                         number     = 066
*                         type       = 'E'
*                         message_v1 = dest_line-bukrs
*                         message_v2 = dest_line-gjahr
*                         message_v3 = dest_line-belnr ) TO return_tab.
*        "Keine AnnAO auf der Datenbank.
*        "Also Schleife verlassen.
*
      ENDIF.
    ENDIF.

    "Verknüpfung Annahmeanordung von Bund (03) und Kommune (02) zu Auszahlungsannordnung Bund (03) und Kommune (02)
    lv_count = 0.
    IF dest_line-psoty = 01 AND dest_line-zlsch = 'X'.
      "Verknüpfung nur anlegen, sofern es sich um eine Auszahlungsanordnung handelt.
      "Lese passende Annahmeanordnung
      READ TABLE dest_table ASSIGNING FIELD-SYMBOL(<ls_ausao>) WITH KEY annao_ref_zhlwg_x = dest_line-annao_ref_zhlwg_x
                                                                        psoty = '02'.

      "Ermittlung des Kassenzeichen für die Annahmeanordnung
      IF sy-subrc = 0.
        dest_line-bktxt = <ls_ausao>-xblnr.

        lv_count += 1.
        "Übernehme Kassenzeichen der Annahmeanordnung in Belegzeile
*          dest_line-xblnr = <ls_ausao>-bktxt.

*          IF 1 = 0. MESSAGE s065(/thkr/sst) WITH dest_line-lotkz dest_line-xblnr. ENDIF.
*          APPEND VALUE #( id         = '/THKR/SST'
*                           number     = 065
*                           type       = 'S'
*                           message_v1 = dest_line-lotkz
*                           message_v2 = |{ CONV string( lv_count ) ALPHA = OUT }|
*                           message_v3 = dest_line-xblnr ) TO return_tab.
*        ELSE.
*          IF 1 = 0. MESSAGE e066(/thkr/sst) WITH dest_line-bukrs dest_line-gjahr dest_line-belnr. ENDIF.
*          APPEND VALUE #( id         = '/THKR/SST'
*                           number     = 066
*                           type       = 'E'
*                           message_v1 = dest_line-bukrs
*                           message_v2 = dest_line-gjahr
*                           message_v3 = dest_line-belnr ) TO return_tab.
*          "Keine AnnAO auf der Datenbank.
*          "Also Schleife verlassen.
*          EXIT.
      ENDIF.
    ENDIF.

*"----------------------------------------------------------------------
    dest_line-msg = return_tab[].
  ENDIF.


ENDFUNCTION.
