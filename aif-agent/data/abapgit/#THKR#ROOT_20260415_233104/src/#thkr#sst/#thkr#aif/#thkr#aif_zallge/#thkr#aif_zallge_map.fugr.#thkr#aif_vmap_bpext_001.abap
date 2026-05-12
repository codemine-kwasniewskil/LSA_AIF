FUNCTION /THKR/AIF_VMAP_BPEXT_001 .
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
  "Feld value_in = 38_RES4   -> 1. Teil des Namen
  "Feld value_in2 = 46_NAME2  -> 2. Teil des Namens (ggf. mit Geburtsdatum)
  "Feld value_in3 = 39_RES5  -> Straße und Hausnummer
  "Feld value_in4 = 22_RES1  -> Land und Postleitzahl
  "Feld value_in5 = 24_RES2  -> Ort / Stadt

  "Einmalzahler haben keine eindeutige Kennung im Quellsystem.
  "Daher wird über einen Hash-Algorithmus eine Zahl erzeugt
  "Als Basis für diese Zahl werden die oben aufgeführten Feldinhalte verwendet.
  DATA: lv_hash TYPE xstring.
  try.
    DATA(lv_string) = value_in && value_in2 && value_in3 && value_in4(9) && value_in5.
  catch cx_sy_range_out_of_bounds.
    lv_string = value_in && value_in2 && value_in3 && value_in4 && value_in5.
  ENDTRY.
  TRY.
      cl_abap_message_digest=>calculate_hash_for_char(
        EXPORTING
*      if_algorithm     = 'SHA1'           " Hash-Algorithmus
          if_data          = lv_string                 " Daten
*      if_length        = 0                " Eingabelänge (0: strlen(data))
        IMPORTING
*      ef_hashstring    =                  " Hash-Wert als Hex-Encoded String
*      ef_hashxstring   =                  " Hash-Wert binär als XString
*      ef_hashb64string =                  " Hash-Wert als Base64-Encoded String
          ef_hashx         = lv_hash                 " Hash-Wert als XSequence
      ).
      value_out = lv_hash.
    CATCH cx_abap_message_digest. " Ausnahmeklasse für Message Digest
      CLEAR value_out.
  ENDTRY.
ENDFUNCTION.
