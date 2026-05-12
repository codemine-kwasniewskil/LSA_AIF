*&---------------------------------------------------------------------*
*& Include          ZXFMCU19
*&---------------------------------------------------------------------*

"Ersteller:           ZHM000000038 Andreas Baier
"Anforderung:         EOL-0014_A2.6.9 / A2.6.63 - Allgemeine Anordnung
"Angefordert durch:   ZHM000000041 Theresa Berenbold
"Beschreibung:
"Bei Allgemeinen Anordnungen darf nur eine Belegzeile als Kontierungshülle
"erfasst werden. Allgemeine Anordnungen umfassen die Belegarten AU und AN.
"Sollte mehr als eine Belegzeile erfasst werden, wird eine entsprechende
"Fehlermeldung ausgegeben.

DATA: lv_lines TYPE i.

IF c_okcode = 'SAVE'.
  CASE sy-tcode.
    WHEN 'FMZ1' OR 'FMZ2'.
      LOOP AT t_kbld ASSIGNING FIELD-SYMBOL(<fs_kbld>).
        IF <fs_kbld>-blart = 'AU'.
          DESCRIBE TABLE t_kbld LINES lv_lines.
          IF lv_lines > 1.
            MESSAGE 'Bitte nur eine Zeile erfassen!' TYPE 'E'.
          ENDIF.
          """"
          CALL FUNCTION 'FI_TAX_INDICATOR_CHECK'
            EXPORTING
              i_bukrs  = <fs_kbld>-bukrs
              i_hkont  = <fs_kbld>-saknr  "Sach-/oder Abstimmkonto
              i_koart  = 'S'
              i_mwskz  = <fs_kbld>-zz_mwskz
              i_stbuk  = <fs_kbld>-bukrs
              i_umsks  = ' '
              x_dialog = ' '.
        ENDIF.
      ENDLOOP.

    WHEN 'FMV1' OR 'FMV2'.
      LOOP AT t_kbld ASSIGNING <fs_kbld>.
        IF <fs_kbld>-blart = 'AN'.
          DESCRIBE TABLE t_kbld LINES lv_lines.
          IF lv_lines > 1.
            MESSAGE 'Bitte nur eine Zeile erfassen!' TYPE 'E'.
          ENDIF.
          """"
          CALL FUNCTION 'FI_TAX_INDICATOR_CHECK'
            EXPORTING
              i_bukrs  = <fs_kbld>-bukrs
              i_hkont  = <fs_kbld>-saknr  "Sach-/oder Abstimmkonto
              i_koart  = 'S'
              i_mwskz  = <fs_kbld>-zz_mwskz
              i_stbuk  = <fs_kbld>-bukrs
              i_umsks  = ' '
              x_dialog = ' '.
          """"
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDIF.
