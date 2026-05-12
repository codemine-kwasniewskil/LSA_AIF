*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* Action kapselt die Interne Schnittstelle "Geschäftspartner"
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_in_psoxml .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_PSO_XML_SAP
*"     REFERENCE(CURR_LINE) TYPE  /THKR/S_PSO_XML_SAP_OBJECTS
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  "BREAK-POINT.                                             "#EC NOBREAK
*"---------------------------------------------------------------------
  CONSTANTS: lc_ns TYPE /AIF/ns VALUE 'ZALLGE'.
  CONSTANTS: lc_vmap TYPE /aif/vmapname VALUE 'MAP_PSO_XML_BLART'.
  "Prüfen, ob Anordnungen, Mittelbindungen oder andere SAP Objekte erzeugt werden.
  "Meldung erzeugen.

  "Es gibt zwei Gründe, weshalb keine Datei gemappt wurde:
  "1. die Belegart ist nicht gepflegt.
  "2. Die Belegart ist gepflegt, aber im Falle von Mittelbindungen gab es keine Änderungen.
  "Aktion läuft immer auf erfolgreich. Es geht lediglich um die Nachrichtenerzeugung.
  IF curr_line-ao IS INITIAL
  AND curr_line-ao_reference IS INITIAL
  AND curr_line-ao_stu IS INITIAL
  AND curr_line-vr IS INITIAL
  AND curr_line-mb IS INITIAL
  AND curr_line-mb_up IS INITIAL
  AND curr_line-storno IS INITIAL.

    "Bereinigung von doppelten Einträgen
    SORT curr_line-blart_seltab BY low.
    DELETE ADJACENT DUPLICATES FROM curr_line-blart_seltab.

    "Ermittlung konfigurierter Belegarten für PSO-Mapping
    SELECT ext_value1
      FROM /aif/t_vmapval5
     WHERE ns = @lc_ns
      AND vmapname = @lc_vmap
      AND ext_value1 IN @curr_line-blart_seltab
      INTO TABLE @DATA(lt_blart).

    IF sy-subrc = 0.
      "Es wurden Belegarten gefunden.
      LOOP AT curr_line-blart_seltab ASSIGNING FIELD-SYMBOL(<ls_blart>).
        TRY.
            DATA(lv_blart) = lt_blart[ ext_value1 = <ls_blart>-low ]-ext_value1.
          CATCH cx_sy_itab_line_not_found.
            "Belegart wurde nicht konfiguriert. Schleife verlassen und
            CLEAR lv_blart.
            EXIT.
        ENDTRY.
      ENDLOOP.

      IF lv_blart IS INITIAL.
        "Belegart nicht konfiguriert. Fehlermeldung erzeugen.
        IF 1 = 0. MESSAGE e036(/thkr/sst).ENDIF.
        APPEND VALUE bapiret2( id = '/THKR/SST'
                               number = 36
                               type = 'E' ) TO return_tab.
        curr_line-txt_prot[ 1 ]-msgid = '/THKR/SST'.
        curr_line-txt_prot[ 1 ]-msgno = 36.
        curr_line-txt_prot[ 1 ]-msgty = 'E'.
        MESSAGE e036(/thkr/sst) INTO DATA(lv_text).
        curr_line-txt_prot[ 1 ]-msgtxt = lv_text.
        curr_line-txt_prot[ 1 ]-status = 'E'.
      ELSE.
        "Belegarten sind konfiguriert.
        "Keine Änderungen am Datenbestand
        "Infomeldung erzeugen.
        IF 1 = 0. MESSAGE i057(/thkr/sst).ENDIF.
        APPEND VALUE bapiret2( id = '/THKR/SST'
                               number = 57
                               type = 'I' ) TO return_tab.
        curr_line-txt_prot[ 1 ]-msgid = '/THKR/SST'.
        curr_line-txt_prot[ 1 ]-msgno = 57.
        curr_line-txt_prot[ 1 ]-msgty = 'I'.
        MESSAGE i057(/thkr/sst) INTO lv_text.
        curr_line-txt_prot[ 1 ]-msgtxt = lv_text.
        curr_line-txt_prot[ 1 ]-status = 'I'.
      ENDIF.
    ELSE.

      IF 1 = 0. MESSAGE e036(/thkr/sst).ENDIF.
      APPEND VALUE bapiret2( id = '/THKR/SST'
                             number = 36
                             type = 'E' ) TO return_tab.
      curr_line-txt_prot[ 1 ]-msgid = '/THKR/SST'.
      curr_line-txt_prot[ 1 ]-msgno = 36.
      curr_line-txt_prot[ 1 ]-msgty = 'E'.
      MESSAGE e036(/thkr/sst) INTO lv_text.
      curr_line-txt_prot[ 1 ]-msgtxt = lv_text.
      curr_line-txt_prot[ 1 ]-status = 'E'.
    ENDIF.
  ENDIF.

  Success = 'Y'.
*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
