*"----------------------------------------------------------------------
* Input
* VALUE_IN  04_HHJ
* VALUE_IN2 @MB!BUKRS
* VALUE_IN3 @FIPEX
* VALUE_IN4 @FISTL
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT HKONT (SAKNR)
*"----------------------------------------------------------------------
FUNCTION /THKR/AIF_VMAP_HKONT_UBH .
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(VALUE_IN) TYPE  STRING
*"     REFERENCE(VALUE_IN2) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN3) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN4) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN5) TYPE  STRING OPTIONAL
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"         OPTIONAL
*"     REFERENCE(VALUE_FOUND) TYPE  C OPTIONAL
*"     REFERENCE(RAW_LINE)
*"     REFERENCE(RAW_STRUCT)
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"--------------------------------------------------------------------
  "zweistufiges Mapping für Sachkonto.
  "1. Zentrale Mappingtabelle aufrufen
  "2. Wenn nichts gefunden wurde, dann Ableitung des Sachkontos
*"----------------------------------------------------------------------
  "1. Zentrales Mappingtabelle
  DATA:       lo_struc      TYPE REF TO cl_abap_structdescr.
  DATA: lv_oeh TYPE string.
  DATA: lv_aob TYPE string.
  DATA: lv_kap TYPE string.
  DATA: lv_titel TYPE string.

    "Nicht BIC
    "Felder aus Festwerten lesen.
    lv_oeh = /thkr/cl_aif_map=>get_instance( )->get_fixvalues_for_hkont( iv_fieldname = 'OEH' ).
    lv_aob = /thkr/cl_aif_map=>get_instance( )->get_fixvalues_for_hkont( iv_fieldname = 'AOB' ).
    lv_kap = /thkr/cl_aif_map=>get_instance( )->get_fixvalues_for_hkont( iv_fieldname = 'KAPITEL' ).
    lv_titel = /thkr/cl_aif_map=>get_instance( )->get_fixvalues_for_hkont( iv_fieldname = 'TITEL' ).

  CALL FUNCTION '/THKR/AIF_VMAP_CENTRALMAP'
    EXPORTING
      value_in   = lv_oeh
      value_in2  = lv_aob
      value_in3  = 'SAKNR'
      value_in4  = lv_kap
      value_in5  = lv_titel
*     SENDING_SYSTEM       =
*     VALUE_FOUND          =
      raw_line   = raw_line
      raw_struct = raw_struct
*                  TABLES
*     RETURN_TAB =
    CHANGING
      value_out  = value_out
*                  EXCEPTIONS
*     NO_VALUE_FOUND       = 1
*     OTHERS     = 2
    .
*"----------------------------------------------------------------------
  "2. Ableitung
  IF value_out IS INITIAL.
    "nur wenn Buchungskreis gefüllt ist.
    "ohne Buchungskreis, keine Buchungskreisgruppe.
    IF /thkr/cl_pso_xml_processing=>get_instance( )->check_bukrs( iv_burks = CONV payac07-bukrs( value_in2 ) ).
      "Prüfung des Geschäftsjahres in PAYAC 02.
      "Wird in der Ableitung auch durchgeführt und eine Dialogausgabe
      "im Fehlerfall. Diese Dialogausgabe muss unterbunden werden, weil
      " sonst die Nachricht im AIF Monitor im Status "in Bearbeitung" stehen bleibt.
      "Also Ableitung erst gar nicht durchführen, wenn Geschäftsjahr ungültig.
      IF /thkr/cl_pso_xml_processing=>get_instance( )->check_gjhr( iv_gjahr = CONV payac02-gjahr( value_in ) ) = abap_true.
        value_out = /thkr/cl_pso_xml_processing=>get_instance( )->get_hkont(
          EXPORTING
            iv_gjahr = CONV payac02-gjahr( value_in )                " Geschäftsjahr
            iv_bukrs = CONV payac07-bukrs( value_in2 )                " Buchungskreis
            iv_fipex = CONV fmci-fipex( value_in3 )                 " Finanzposition
            iv_fistl = CONV payac01-fistl( value_in4 )                " Finanzstelle
            iv_psoty = CONV payac01-psoty( value_in5 )                " Belegtyp Zahlungsanordnungen
            iv_blart = ''                 " Belegart
        ).
      ELSE.
        CLEAR: value_out.
      ENDIF.
    ELSE.
      CLEAR: value_out.
    ENDIF.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
