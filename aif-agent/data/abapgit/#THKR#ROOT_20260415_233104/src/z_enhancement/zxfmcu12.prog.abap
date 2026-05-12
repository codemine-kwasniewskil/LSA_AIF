*&---------------------------------------------------------------------*
*& Include          ZXFMCU12
*&---------------------------------------------------------------------*

"Ersteller:           ZHM000000038 Andreas Baier
"Anforderung:         EOL-0014_A2.6.9 / A2.6.63 - Allgemeine Anordnung
"Angefordert durch:   ZHM000000041 Theresa Berenbold
"Beschreibung:
"Bei Allgemeinen Anordnungen darf nur eine Belegzeile als Kontierungshülle
"erfasst werden. Allgemeine Anordnungen umfassen die Belegarten AU und AN.
"Beim öffnen der Anlage- oder Bearbeitungstrankstion wird dafür der
"Hinweis: Bitte nur eine Belegzeile erfassen! in der Statusleiste ausgegeben.


  if i_tctype = '01'.
    perform set_kassenzeichen tables t_kbld changing f_kblk.
  endif.


case sy-tcode.

  when 'FMZ1' or 'FMZ2'.

if f_kblk-blart = 'AU'.

  MESSAGE 'Bitte nur eine Zeile erfassen!' Type 'S'.

  ENDIF.

  when 'FMV1' or 'FMV2'.

    if f_kblk-blart = 'AN'.

  MESSAGE 'Bitte nur eine Zeile erfassen!' Type 'S'.

  ENDIF.

    ENDCASE.
