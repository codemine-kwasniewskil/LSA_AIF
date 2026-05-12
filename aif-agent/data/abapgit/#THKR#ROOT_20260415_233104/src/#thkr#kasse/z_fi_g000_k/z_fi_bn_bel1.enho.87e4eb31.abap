"Name: \PR:SAPF110S\FO:AUSNAHMEN_AUSGEBEN\SE:END\EI
ENHANCEMENT 0 Z_FI_BN_BEL1.
* Nachrichtentabelle füllen

  IF reguh-xvorl <> 'X'.

  LOOP AT lt_regup ASSIGNING FIELD-SYMBOL(<regup>).

*   Belegdaten:
    MOVE-CORRESPONDING <regup> to ls_bnbel.
*   Schlüsselfelder aus reguh
    ls_bnbel-laufd = reguh-laufd.
    ls_bnbel-laufi = reguh-laufi.
    ls_bnbel-zbukr = reguh-zbukr.
    ls_bnbel-lifnr = reguh-lifnr.
    ls_bnbel-kunnr = reguh-kunnr.
*    ls_bnbel-empfg = reguh-empfg.
    ls_bnbel-vblnr = reguh-vblnr. "?

*   Fehler
    ls_fherk-herk = 'Z'.
    ls_fherk-fehlernr = <regup>-poken.

    zcl_fi_bn_nachrichten=>get_instance( )->add_beleg(
      EXPORTING
        i_bnbel = ls_bnbel
        i_fherk = ls_fherk ).

  ENDLOOP.

  ENDIF.

ENDENHANCEMENT.
