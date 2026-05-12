*"----------------------------------------------------------------------
* Gereon Koks  TSI  15.10.2024
*"----------------------------------------------------------------------
* Map AD_STREET
*"----------------------------------------------------------------------
* Housenumber is taken out of the field,
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
* VALUE_OUT AD_STREET
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_ad_street.
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
* suchen nach Hausnummern in value_in
    DATA(matcher) = cl_abap_matcher=>create_pcre( pattern = '\s[0-9]{1,}[\/ \-0-9a-zA-Z]*$'
                                             text = value_in
                                             ignore_case = abap_true ).

* Tabelle mit den Suchergebnissen
    DATA(it_matches) = matcher->find_all( ).

    IF NOT it_matches IS INITIAL.
* der letzte Eintrag sollte die Hausnummer sein
      DATA(lv_last_entry) = it_matches[ lines( it_matches ) ].

* Straße
      value_out = substring( val = value_in
                          off = 0
                          len = lv_last_entry-offset ).
    else.
      "Keine Hausnummer geliefet. Nur Straße.
      value_out = value_in.
    ENDIF.
*"----------------------------------------------------------------------

    SHIFT value_out LEFT DELETING LEADING space.

*"----------------------------------------------------------------------
ENDFUNCTION.
