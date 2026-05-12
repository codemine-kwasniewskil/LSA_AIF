*&---------------------------------------------------------------------*
*& Report ZFI_EA_FORMS_PRN
*&---------------------------------------------------------------------*
************************************************************************
* Verwahr und Vorschussbearbeitung
* Für in Verwahrung gebuchte Geldeingänge und in Vorschuss gebuchte
* Lastschriften werden aus der Klärungsbearbeitung heraus Korrespondenzen
* (Mail, Fax, Service-BW oder Druckausgabe/Brief) erzeugt.

* Diese können an folgende Adressaten gehen:
*	- an den Einzahler bzw. Veranlasser der Gutschrift/Lastschrift
*	- an die Bank
*	- an die Dienststellen
*
* Der Aufruf der neuen Korrespondenz erfolgt hierbei direkt aus der
* Nachbearbeitung des elektronischen Kontoauszugs
* Transaktion "FEBAN/FEB_BSPROC".
************************************************************************
* Autor: Andreas Mühr
* Firma: DXC Technology Deutschland GmbH
************************************************************************

INCLUDE /THKR/EA_FORMS_PRN_TOP.
INCLUDE /THKR/EA_FORMS_PRN_O01.
INCLUDE /THKR/EA_FORMS_PRN_O02.
INCLUDE /THKR/EA_FORMS_PRN_I01.
INCLUDE /THKR/EA_FORMS_PRN_I02.
INCLUDE /THKR/EA_FORMS_PRN_F01.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_kukey.
  PERFORM febep_values.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_esnum.
  PERFORM febep_values.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_formid.
  PERFORM form_values.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM form_values.

START-OF-SELECTION.

  gv_formid  = p_formid.
  gv_variant = p_vari.
  gv_kukey   = p_kukey.
  gv_esnum   = p_esnum.

  PERFORM entry.
