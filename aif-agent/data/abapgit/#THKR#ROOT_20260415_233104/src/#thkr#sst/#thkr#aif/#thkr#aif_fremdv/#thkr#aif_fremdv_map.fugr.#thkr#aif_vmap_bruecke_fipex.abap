*"----------------------------------------------------------------------
* Gereon Koks  TSI  15.10.2024
*"----------------------------------------------------------------------
* Map AD_STREET
*"----------------------------------------------------------------------
* Housenumber is taken out of the field and returned
* because housenumber belongs to ADDR1_DATA-HOUSE_NUM1 (SAP)
* and not to ADDR1_DATA-STREET (SAP)
*"----------------------------------------------------------------------
* Input
* VALUE_IN  39 inpres5
* VALUE_IN2
* VALUE_IN3
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT AD_HSNM1
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_bruecke_fipex.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(VALUE_IN) TYPE  STRING
*"     REFERENCE(VALUE_IN2) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN3) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN4) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN5) TYPE  STRING OPTIONAL
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"     REFERENCE(VALUE_FOUND) TYPE  C OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------
  CLEAR value_out.
*"----------------------------------------------------------------------
  "VALUE_in = FIPEX
  "VALUE_in2 = Antragsnummer

  "1. Ermittlung Unterkonto zu Antragsnummer
  "2. Setze FIPEX und Unterkonto zusammen.

  "1. Unterkontoermittlung
  data: lt TYPE match_result_tab.
  FIND FIRST OCCURRENCE OF '-' IN value_in2 MATCH OFFSET DATA(lv_off).

  DATA(lv_antr) = value_in2(lv_off).

  SELECT SINGLE int_value
    FROM /aif/t_vmapval
   WHERE ns = 'FREMDV'
     AND vmapname = 'MAP_BRUECKE_UKONTEN'
     AND ext_value = @lv_antr
   INTO @DATA(lv_ukonto).
  IF sy-subrc = 0.
    "2. Zusammensetzung.
    value_out = value_in && lv_ukonto.
  else.
    "Keine Antragsart gefunden
    "Keine FIPEX
    CLEAR value_out.
  endif.
*"----------------------------------------------------------------------
ENDFUNCTION.
