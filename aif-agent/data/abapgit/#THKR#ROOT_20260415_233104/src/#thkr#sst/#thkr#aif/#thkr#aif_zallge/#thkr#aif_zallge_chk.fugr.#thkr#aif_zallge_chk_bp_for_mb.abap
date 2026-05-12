FUNCTION /thkr/aif_zallge_chk_bp_for_mb .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(DATA_STRUCT)
*"     REFERENCE(DATA_LINE)
*"     REFERENCE(DATA_FIELD)
*"     REFERENCE(MSGTY) TYPE  SYMSGTY DEFAULT 'E'
*"     REFERENCE(VALUE1) TYPE  STRING
*"     REFERENCE(VALUE2) TYPE  STRING
*"     REFERENCE(VALUE3) TYPE  STRING
*"     REFERENCE(VALUE4) TYPE  STRING
*"     REFERENCE(VALUE5) TYPE  STRING
*"     REFERENCE(T_IFCHECK) TYPE  /AIF/T_IFCHECK OPTIONAL
*"     REFERENCE(T_IFACT) TYPE  /AIF/T_IFACT OPTIONAL
*"     REFERENCE(T_ACCHECK) TYPE  /AIF/T_ACCHECK OPTIONAL
*"     REFERENCE(T_FUNC) TYPE  /AIF/T_FUNC OPTIONAL
*"     REFERENCE(T_FMAPCOND) TYPE  /AIF/T_FMAPCOND OPTIONAL
*"     REFERENCE(T_CHECK) TYPE  /AIF/T_CHECK
*"     REFERENCE(T_TABCHK) TYPE  /AIF/T_TABCHK
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"      DATA_TABLE
*"  CHANGING
*"     REFERENCE(ERROR) TYPE  CHAR01
*"----------------------------------------------------------------------

  "Prüfung, ob für die Belegart ein Geschäftspartner hinterlegt werden soll oder nicht
  " Mapping MAP_GP_FOR_MB enthält die Konfiguration pro Belegart
  " INT_VALUE = X = ABAP_TRUE = Geschäftspartner soll gemappt werden -> führt zu error = abap_true -> Führe Mapping aus
  " INT_VALUE = <leer> = ABAP_FALSE = Geschäftspartner soll nicht gemappt werden -> führt zu error = abap_false -> Führe Mapping nicht aus
  CONSTANTS: lc_ns  TYPE /aif/ns VALUE 'ZALLGE'.
  CONSTANTS: lc_vmap TYPE /aif/vmapname VALUE 'MAP_GP_FOR_MB'.
  CONSTANTS: lc_asterik TYPE char1 VALUE '*'.

  DATA: lv_ns TYPE /aif/ns.
  DATA: lv_ifname TYPE /aif/ifname.
  DATA: lv_ifversion TYPE /aif/ifversion.

  "Auslesen der LAufzeitvariablen, um das Customizing pro Schnittstelle abzurufen
  CALL FUNCTION '/AIF/FILE_GET_GLOBALS'
    IMPORTING
      ns        = lv_ns
      ifname    = lv_ifname
      ifversion = lv_ifversion.
  "zuerst für Schnittstelle abrufen.
  " Error  = abap_true = führe Wertemapping aus
  " error = abap_false = führe Bedingung aus -> leeren Wert
  SELECT SINGLE int_value
    FROM /aif/t_vmapval5
   WHERE ns = @lc_ns
     AND vmapname = @lc_vmap
     AND ext_value1 = @lv_ns
     AND ext_value2 = @lv_ifname
     AND ext_value3 = @lv_ifversion
     AND ext_value4 = @value1
   INTO @error.
  IF sy-subrc <> 0.
    "Keine Schnittstellenspezifische Konfiguration gefunden.
    "Suche nach allgeimeinen Konfigurationen.
    " Error  = abap_true = führe Wertemapping aus
    " error = abap_false = führe Bedingung aus -> leeren Wert
    SELECT SINGLE int_value
      FROM /aif/t_vmapval5
     WHERE ns = @lc_ns
       AND vmapname = @lc_vmap
       AND ext_value1 = @lc_asterik
       AND ext_value2 = @lc_asterik
       AND ext_value3 = @lc_asterik
       AND ext_value4 = @value1
     INTO @error.
    "Es wurde weder für die Schnittstelle, noch eine allgemeine Konfiguration gefunden.
    IF sy-subrc <> 0.
      CLEAR: error.
    ENDIF.
  ENDIF.


ENDFUNCTION.
