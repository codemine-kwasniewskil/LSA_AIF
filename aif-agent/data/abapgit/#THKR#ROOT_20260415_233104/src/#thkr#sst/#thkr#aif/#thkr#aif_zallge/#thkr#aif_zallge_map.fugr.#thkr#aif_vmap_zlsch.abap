FUNCTION /thkr/aif_vmap_zlsch .
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
  "Ermittlung des Zahlweges

  "VALUE_IN = PSOTY (01 = Auszahlungsanordnung, 02 = Annahmeanordnung)
  "VALUE_IN2 = 16_BETR2 (19. Stelle; E = Einzahlung; M oder D = Lastschrift (Mandat) )
  "gilt nur für Annahmeanordnungen; Auszahlungen nutzen dieses Feld für Steuerzahlungsangaben
  "VALUE_IN3 = 21_BKZ / Belastsungs-/Entlastungskennzeichen
  "Bei Annahmeanordnung:
  " E = Einmalige Einzahlung
  " A = Allgemeine Annahmeanordnung
  " W = Wiederkehrende Einnahme
  " B = nicht-zum-Soll-Anordnung
  " D = Splittbuchung
  "Bei Auszahlungsanordnung
  " X = Auszahlung auf Referenz
  " Z = Einmalige Auszahlung
  " D = Dauerauszahlung
  " S = Splittauszahlung
  "VALUE_In4 = BVTYP (Bankverbindung; Für Zahlweg D (Überweisung) ist eine Bankverbindung verpflichtend)
  " value_in5 = 22_RES1 (Enthält Information, ob es sich um eine Überweisung handelt; Allerdings befinden sich hier auch andere Informationen wie, LAND,PLZ oder Zweitschulderkennzeichen9
  " also nicht jede Schnittstelle liefert in diesem Feld, was für die Ermittlung der Bankverbindung notwendig ist. Das Kennzeichen befindet sich an der 11. Stelle

*"----------------------------------------------------------------------
  CASE Value_in. "PSOTY
***********************************************************************************
*                                   Auszahlung
***********************************************************************************
    WHEN: '01'.
      "Auszahlungsanordnung
*"----------------------------------------------------------------------
      CASE value_in3. "21_BKZ
*"----------------------------------------------------------------------
        WHEN: 'X'.
          "Auszahlungsanordnung mit Referenz auf Einnahmesollstellung
          value_out = value_in3.
*"----------------------------------------------------------------------
        WHEN: 'Z' OR 'S'.
          "Z = Einmalige Auszahlung
          "S = Splitauszahlung

          "EDAS / OASIS übertragen keine Bankinformation über die Anordnung,
          "sondern über die Zahlpartnerdatei. In der Anordnung steht lediglich, dass es sich um eine Überweisung handelt.
          DATA(lv_transfer_type) = value_in5.
          CASE strlen( value_in5 ).
            WHEN: 0.
              "Feld ist leer.
              CLEAR: lv_transfer_type.
            WHEN: 1.
              "bereits aufbereiteter Wert.
              lv_transfer_type = value_in5.
            WHEN: OTHERS.
              "Bei Verwendung von Untertabellen (Kontextwechsel) kommt das AIF nicht mit der Angabe von Offset und Länge zurecht
              "Es liefert in solchen Fällen den gesamten Text.
              lv_transfer_type = value_in5+10(1).
          ENDCASE.
          CASE lv_transfer_type.
            WHEN: 'D'.
              "D = Überweiseung
              value_out = 'D'.
            WHEN: 'G'.
              "G = Bezüge
              value_out = 'G'.
            WHEN: OTHERS.
              IF VALUE_In4 IS NOT INITIAL.
                "Es wurde kein Typ angegeben. Aber es existiert eine Bankverbindung. Also Überweisung
                "Bankverbindung vorhanden Zahlweg D möglich
                value_out = 'D'. "Überweisung
              ELSE.
                "Keine Zuordnung möglich.
                value_out = 'A'. "manuelle Buchung
              ENDIF.
          ENDCASE.
*"----------------------------------------------------------------------
        WHEN OTHERS.
          CLEAR: value_out.
*"----------------------------------------------------------------------
      ENDCASE.
***********************************************************************************
*                                   Einzahlung
***********************************************************************************
    WHEN: '02'.
      "Annahmeanordnung
*"----------------------------------------------------------------------
      CASE value_in3. "21_BKZ
*"----------------------------------------------------------------------
        WHEN: 'E'.
          "Einmalige Einnahme

          "Bei Referenzen greifen die Parameter Offset und Länge aus AIF Customizing nicht.
          "Daher aufarbeiten.

          DATA(lv_betr2)  = value_in2.
          CONDENSE lv_betr2 NO-GAPS.

          CASE lv_betr2. "16_BETR2
            WHEN: 'E'.
              value_out = lv_betr2.  "E = Einzahlung
            WHEN: 'M' OR 'D'.
              value_out = 'M'.  "SEPA-Mandat / Lastschrift
            WHEN OTHERS.
              value_out = value_in2. "E = Einzahlung
          ENDCASE.
*"----------------------------------------------------------------------
        WHEN: 'X'.
          "Bei Auszahlungen mit Referenz auf Einnahmesollstellung wird die Annahmeanordnung aus einer allgemeinen Anordnung
          "und Daten aus der Auszahlungsanordnung aufgebaut.
          value_out = 'E'. "Einzahlung
*"----------------------------------------------------------------------
        WHEN OTHERS.
          value_out = 'A'. "manuelle Buchung
*"----------------------------------------------------------------------
      ENDCASE.
*"----------------------------------------------------------------------
    WHEN: OTHERS.
      CLEAR: value_out.
*"----------------------------------------------------------------------
  ENDCASE.
*"----------------------------------------------------------------------
ENDFUNCTION.
