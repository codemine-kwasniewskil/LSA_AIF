
* "/ Puffer der Datensourcen-Flags
DATA: g_flg_bud      TYPE c,
      g_flg_com_act  TYPE c,
      g_flg_fi_items TYPE c.


* "/ Puffer der Kennzahlen
DATA : BEGIN OF g_t_kf_fields OCCURS 0,
         keyfig     LIKE bukf_kfdsrc-keyfig,
         datasource LIKE bukf_kfdsrc-datasource,
         fieldgroup LIKE bukf_kfdsrc-fieldgroup,
       END OF g_t_kf_fields.

* "/ Globale Range der Feldnamen fuer die Vorzeichen-
* "/ behandlung
RANGES: g_r_fieldname   FOR dd03l-fieldname,

        g_r_bpby_fields FOR dd03l-fieldname,
        g_r_fmto_fields FOR dd03l-fieldname,
        g_r_fmfi_fields FOR dd03l-fieldname.



* "/ Tabelle der gueltigen Wertfelder
DATA : BEGIN OF g_t_value_fields OCCURS 0,
         fieldname LIKE dfies-fieldname,
       END OF g_t_value_fields.


**********************************************************************
**********************************************************************
* Anhand der Aufrufkennzeichen
*         I_BUDGET     = 'X'
*         I_COM_ACT    = 'X'
* werden die Felder, die gedreht werden sollen ermittelt
**********************************************************************


FUNCTION /thkr/bcs_fb_fmkbo_set_sign.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(TABNAME) TYPE  DD03L-TABNAME
*"     VALUE(I_BUDGET) DEFAULT 'X'
*"     VALUE(I_COM_ACT) DEFAULT 'X'
*"     VALUE(I_FI_ITEMS) OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_STRUCT)
*"  EXCEPTIONS
*"      NO_ENTRIES
*"----------------------------------------------------------------------


  DATA:
    l_dd03l LIKE x030l,
    l_dfies LIKE dfies OCCURS 0 WITH HEADER LINE.

  DATA: l_t_keyfigs LIKE bukf_kfdsrc OCCURS 0,
        l_f_keyfigs LIKE bukf_kfdsrc.


* Datenquelle gemäß Customizing: Tabelle ZCBB_BUKF_DSRC
  CONSTANTS:
    fmkf_fmbdt  TYPE bukf_datasource VALUE '0001',  " Budget: Budgetierungsdaten (logDB: BUDT ->  SAPTab:  FMBDT)
    fmkf_fmtox  TYPE bukf_datasource VALUE '0002',  " Summensätze Obligo & Ist
    fmkf_fmavct TYPE bukf_datasource VALUE '0003'.  " Budget: VbK-Daten (logDB: AVCT ->  SAPTab:  FMAVCT)


  FIELD-SYMBOLS: <value>.

  RANGES: r_datatype FOR dd03l-datatype.

* Initialisieren
  REFRESH: g_r_fieldname.
  CLEAR:   g_r_fieldname.


  IF g_t_kf_fields[] IS INITIAL.
* "/ Erstmal Kennzahlen einlesen ... " /THKR/KF_KFDSRC - Relation Kennzahl/Datenquellen
    SELECT * FROM /THKR/KF_KFDSRC INTO CORRESPONDING FIELDS OF TABLE g_t_kf_fields
       WHERE applic = 'ZB'.
  ENDIF.



  IF g_t_value_fields[] IS INITIAL.

* "/ Lediglich Felder des Datentyps CURR werden
* "/ fuer die Vorzeichendrehung herangezogen
    r_datatype-sign     = 'I'.
    r_datatype-option   = 'EQ'.
    r_datatype-low      = 'CURR'.
    APPEND r_datatype.


* "/ Feldnamen der Referenzstruktur ermitteln ...
    CLEAR l_dfies[].

    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname   = tabname
      TABLES
        dfies_tab = l_dfies
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.


    IF sy-subrc = 0.

      LOOP AT l_dfies WHERE datatype IN r_datatype.
* "/ ... und global puffern
        g_t_value_fields-fieldname = l_dfies-fieldname.
        APPEND g_t_value_fields.

      ENDLOOP.

    ELSE.
      RAISE no_entries.
    ENDIF.


  ENDIF. " IF g_t_value_fields[] IS INITIAL.




  IF g_r_fieldname[] IS INITIAL.

    CLEAR : g_r_bpby_fields[],
            g_r_fmto_fields[],
            g_r_fmfi_fields[].

* "/ Aufbau der Range fuer die Vorzeichenbehandlung
    LOOP AT g_t_value_fields.

      READ TABLE g_t_kf_fields
               WITH KEY keyfig = g_t_value_fields-fieldname.


      g_r_fieldname-sign   = 'I'.
      g_r_fieldname-option = 'EQ'.

* "/ Vorzeichenbehandlung in Abhaenigkeit der
* "/ Datenquellen
      CASE g_t_kf_fields-datasource.

* "/ Budgetadten
        WHEN fmkf_fmbdt OR fmkf_fmavct.
          IF i_budget = 'X'.
            g_r_bpby_fields-sign   = 'I'.
            g_r_bpby_fields-option = 'EQ'.
            g_r_bpby_fields-low = g_t_kf_fields-keyfig.
            APPEND g_r_bpby_fields.

          ENDIF. " IF i_budget = 'X'.


* "/ Obligo/Ist Daten
        WHEN fmkf_fmtox.
          IF i_com_act = 'X'.
            g_r_fmto_fields-sign    = 'I'.
            g_r_fmto_fields-option  = 'EQ'.
            g_r_fmto_fields-low = g_t_kf_fields-keyfig.
            APPEND g_r_fmto_fields.
          ENDIF. "  IF i_com_act = 'X'.


**** "/ FI-Einzelposten
***        WHEN con_fmfix.
***          IF i_fi_items = 'X'.
***            g_r_fmfi_fields-sign = 'I'.
***            g_r_fmfi_fields-option = 'EQ'.
***            g_r_fmfi_fields-low = g_t_kf_fields-keyfig.
***            APPEND g_r_fmfi_fields.
***          ENDIF.

      ENDCASE. " CASE g_t_kf_fields-datasource.



    ENDLOOP.

    APPEND LINES OF g_r_bpby_fields TO g_r_fieldname.
    APPEND LINES OF g_r_fmto_fields TO g_r_fieldname.
    APPEND LINES OF g_r_fmfi_fields TO g_r_fieldname.

  ENDIF.



* "/ Vorzeichendrehung nur, wenn entsprechende
* "/ Felder gefunden wurden.
  CHECK NOT g_r_fieldname[] IS INITIAL.

* "/ In allen Feldern der gepufferten Tabelle
* "/ wird das Vorzeichen gedreht.
  LOOP AT g_t_value_fields
      WHERE fieldname IN g_r_fieldname.

    ASSIGN COMPONENT g_t_value_fields-fieldname OF STRUCTURE value_struct
                                                 TO <value>.
    IF sy-subrc = 0.
      <value> = <value> * ( -1 ).
    ENDIF.


  ENDLOOP.


ENDFUNCTION.
