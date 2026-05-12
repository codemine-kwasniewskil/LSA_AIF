*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.11.2024
*"----------------------------------------------------------------------
* Map FIPEX
*"----------------------------------------------------------------------
* Input
* VALUE_IN  10_KAP
* VALUE_IN2 11_TITEL
* VALUE_IN3 13_MSN
* VALUE_IN4 09_AOB
* VALUE_IN5 leer
*"----------------------------------------------------------------------
* Output
* VALUE_OUT Wert des DTO-Feldes
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_fipex.
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
  DATA: lv_titel(6),
        lv_msn(6).
*"----------------------------------------------------------------------
  CLEAR value_out.
*"----------------------------------------------------------------------
  lv_titel = value_in2.
  REPLACE ` ` IN lv_titel WITH ``.

* Wenn Unterkonto '00' wird nichts angehangen
  IF value_in3 <> '00'.
    lv_msn = value_in3.
  ENDIF.

  "Kapitel ermitteln.
  "Wird für Kapitel der Kassen benötigt. Sie erhalten zum Teil neue Kapitel
  "Die Eindeutigikeit der Selektion wird durch den Einzelplan (Value_in4 / 09_AOB) und das Kapitel (Value_in / 10_KAP) erzielt
  SELECT SINGLE INT_VALUE
    FROM /aif/t_vmapval5
  WHERE ns = 'ZALLGE'
   AND vmapname = 'MAP_KAPITEL'
   AND ext_value1 = @value_in4
   AND ext_value2 = @value_in
  into @DATA(lv_kapitel).
    if sy-subrc <> 0.
      "Keinen Eintrag gefunden.
      "nimm Kapitel aus Struktur.
      lv_kapitel = value_in.
   endif.
*"----------------------------------------------------------------------
  CONCATENATE lv_kapitel lv_titel lv_msn INTO value_out.
*"----------------------------------------------------------------------
ENDFUNCTION.
