*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* CUSTOMER anhängen.
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_amap_storno .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT)
*"     REFERENCE(RAW_LINE)
*"     REFERENCE(SMAP) TYPE  /AIF/T_SMAP
*"     REFERENCE(INTREC) TYPE  /AIF/T_INTREC
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(OUT_STRUCT)
*"     REFERENCE(DEST_LINE) TYPE  /THKR/S_AIF_SAP_STORNO
*"     REFERENCE(DEST_TABLE) TYPE  /THKR/T_DTO_PSM_STORNO
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------

  "Lesen der Belege zu einem Kassenzeichen
  SELECT bukrs, belnr, gjahr, lotkz
   FROM bkpf
    WHERE xblnr = @dest_line-kassz
      AND xref1_hd = @dest_line-st_sst
    INTO TABLE @DATA(lt_bkpf).
  IF sy-subrc <> 0.
    "Es konnte kein Datensatz gefunden werden.
    "Fehlermeldung erzeugen
    IF 1 = 0. MESSAGE e016(/thkr/sst) WITH dest_line-kassz.ENDIF.
    APPEND VALUE bapiret2( id = '/THKR/SST'
                           number = 016
                           type = 'E'
                           message_v1 = dest_line-kassz ) TO dest_line-msg.
    dest_line-proc_status = 'E'.
    RETURN.
  ELSE.
    "Schreiben der Beleginformation von der Datenbank in Zielstruktur
    LOOP AT lt_bkpf  ASSIGNING FIELD-SYMBOL(<ls_bkpf>).
      MOVE-CORRESPONDING <ls_bkpf> TO dest_line.
      APPEND dest_line TO dest_table.

    ENDLOOP.



    "Doppelte Einträge löschen.
    SORT dest_table BY bukrs belnr ASCENDING.
    DELETE ADJACENT DUPLICATES FROM dest_table.


    "aktuelle Zeile nicht hinzufügen
    "Wurde zuvor mit APPEND - Befehl erledigt.
    append_flag = abap_false.
  ENDIF.

ENDFUNCTION.
*"----------------------------------------------------------------------
