FUNCTION /THKR/_BUPA_BUPA_PAI_ZBU601 .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------

 DATA: ls_but000 LIKE  but000,
        lv_type   LIKE  but000-type.
  IF gv_aktyp <> '03'.
*
    IF  /THKR/S_INC1_BUT-/THKR/GSBER NE gv_zzgsber.
      "Muss wieder rein, sobald Tabelle ZVBV_RE_NV_T vorhanden ist
**      CLEAR  /THKR/S_INC1_BUT-/THKR/GSBER.
*      SELECT SINGLE nvbez FROM zvbv_re_nv_t
*        INTO zbu_s_nverwaltung-zzz_nvbez
*        WHERE spras EQ sy-langu
*          AND nvkey EQ zbu_s_nverwaltung-zzz_nvkey.
**      IF sy-subrc IS NOT INITIAL AND
**      /THKR/S_INC1_BUT-/THKR/GSBER IS NOT INITIAL.
*        zbu_s_nverwaltung-zzz_nvbez = '???'.
**      ENDIF.
*      MOVE gv_nvkey TO gv_nvkeyold.
      MOVE  /THKR/S_INC1_BUT-/THKR/GSBER TO gv_zzgsber.
*      MOVE zbu_s_nverwaltung-zzz_nvbez TO gv_nvbez.
    ENDIF.

    IF  /THKR/S_INC1_BUT-/THKR/SST NE gv_zzsst.

      MOVE /THKR/S_INC1_BUT-/THKR/SST to gv_zzsst.

      ENDIF.

  ENDIF.


ENDFUNCTION.
