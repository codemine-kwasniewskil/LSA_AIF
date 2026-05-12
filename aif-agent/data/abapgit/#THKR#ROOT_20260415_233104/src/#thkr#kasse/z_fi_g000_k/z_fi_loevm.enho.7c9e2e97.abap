"Name: \PR:SAPMF02B\FO:BNKA_UPDATE\SE:END\EI
ENHANCEMENT 0 Z_FI_LOEVM.
* Wenn das Löschkennzeichen geändert wurde - dann in zfi_bnka einen Satz eintragen/löschen

 DATA: l_zfi_bnka type zfi_bnka.

  IF *bnka NE bnka
     OR addr-update = 'X'
     OR addr-update = 'D'.

    if bnka-loevm = 'X'.
      select single * from zfi_bnka into l_zfi_bnka where banks = bnka-banks
                                                    and   bankl = bnka-bankl.
      if sy-subrc <> 0.
        MOVE-CORRESPONDING bnka to l_zfi_bnka.
        l_zfi_bnka-erdat = sy-datum.
        l_zfi_bnka-ernam = sy-uname.
        MODIFY zfi_bnka from l_zfi_bnka.
      endif.

    else.
      select single * from zfi_bnka into l_zfi_bnka where banks = bnka-banks
                                                    and   bankl = bnka-bankl.
      if sy-subrc = 0.
        delete from zfi_bnka where banks = bnka-banks
                             and   bankl = bnka-bankl.
      endif.

    endif.
  endif.

ENDENHANCEMENT.
