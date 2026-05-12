FUNCTION /THKR/PSM_FI_F4_TAXCODE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------

  TABLES: PHELP.
  DATA: PROGNAME     LIKE SY-REPID,
        STRING(30)   TYPE C,
        STRING1(30)  TYPE C,
        STRING2(30)  TYPE C,
        STRING3(30)  TYPE C,
        STRING4(30)  TYPE C,
        TYPE_INFO    LIKE DFIES,
        LAND1        LIKE T005-LAND1,
        BUKRS        LIKE T001-BUKRS,
        LIFNR        LIKE BSEG-LIFNR,
        KUNNR        LIKE BSEG-KUNNR,
        BUDAT        LIKE BKPF-BUDAT,
        EXIT(1)      TYPE C,
        WA_FIELDS    LIKE DFIES,
        OFFSET       TYPE I,
        X_AKTTYP(1)  TYPE C,
        XSHOW(1)     TYPE C.

  DATA: XMWSKZ       LIKE T007A-MWSKZ.
  DATA: X_EXIT       TYPE XFELD.                                      "N2074351
  DATA: L_subc       TYPE subc.                                       "N2074351
  DATA: WA_interface type DDSHIFACE.                                  "N2074351
  DATA: WA_SELOPT    type DDSHSELOPT.                                 "N2074351

  FIELD-SYMBOLS: <F>, <G>, <H>, <I>, <J>.

  "Ticket IN-2128083 / S 5000000484
  "Feste Einschränkung auf TAXD.
  clear wa_selopt.
  WA_SELOPT-shlpname  = 'T007A'.
  wa_selopt-shlpfield = 'KALSM'.
  wa_selopt-sign      = 'I'.
  wa_selopt-option    = 'EQ'.
  wa_selopt-LOW       = 'TAXD'.
  append wa_selopt to shlp-selopt.

* Begin of "N2074351
* Bei Step SELECT  - SELOPT für XINACT einfügen.
  IF CALLCONTROL-STEP = 'SELECT'.
*   Prüfen rufendes Programm. Wenn Report -- Inactive anzeigen

* Aufruf F4_Hilfe-Anzeige, ohne inactive Steuerkz. wenn der Aufruf nicht aus
* einem Report erfolgt.  (Feld SUBC in REPOSRC = 1 ) über FB.
    SELECT SINGLE subc
      FROM reposrc
      INTO        L_subc
      WHERE progname = sy-cprog
        AND r3state  = 'A'.
    IF sy-subrc <> 0 or L_SUBC = '1'.
*    Ausnahme report für FICA -Transaktion FKKORD1                    "N2334550
     IF sy-cprog = 'FKK_ORDERSTART'.                                  "N2334550
     ELSE.                                                            "N2334550
      EXIT.
     ENDIF.                                                           "N2334550
    ENDIF.
*   Lesen des übergebenen kalk.Schemas SHLPFIELD
    READ TABLE SHLP-FIELDDESCR INTO WA_FIELDS
                          WITH KEY FIELDNAME = 'KALSM'.
    IF sy-subrc = 0.
      WA_FIELDS-FIELDNAME = 'XINACT'.
      WA_FIELDS-Position  = '4'.
      WA_FIELDS-offset    = 122.
      WA_FIELDS-leng      = '1'.
      WA_FIELDS-intlen    = '2'.
      WA_FIELDS-DOMNAME   = 'XINACT'.
      WA_FIELDS-ROLLNAME  = 'XINACT'.
      WA_FIELDS-OUTPUTLEN = '1'.
      WA_FIELDS-DYNPFLD   = ' '.
      WA_FIELDS-LFIELDNAME = SPACE.
      WA_FIELDS-COMPTYPE  = ' '.

      append wa_fields to SHLP-FIELDDESCR.

*     Select-option für XINACT aufbauen
      clear wa_selopt.
      WA_SELOPT-shlpname   = 'T007A'.
      WA_SELOPT-SHLPFIELD  = 'XINACT'.
      WA_SELOPT-SIGN       = 'I'.
      WA_SELOPT-OPTION     = 'NE'.
      WA_SELOPT-LOW        = 'X'.
      WA_SELOPT-HIGH       = space.
      append wa_selopt to SHLP-SELOPT.
    ENDIF.

  ENDIF.
* END OF NOTE "N2074351
                                                                      "N2074351
  CHECK CALLCONTROL-STEP = 'PRESEL1'.
  IMPORT PHELP FROM MEMORY ID 'PHELP'.
  PROGNAME = PHELP-PROGRAMM.
  CASE PROGNAME.
    WHEN 'SAPLJ1AT'.
*      EXIT.                                                          "N2074351
      X_EXIT = 'X'.                                                   "N2074351

    WHEN 'SAPMF05A' OR 'SAPMF05L' OR 'SAPLF040'.
      CONCATENATE '(' PROGNAME ')t001-bukrs' INTO STRING.
      CONCATENATE '(' PROGNAME ')bkpf-budat' INTO STRING3.
      CONCATENATE '(' PROGNAME ')bseg-kunnr' INTO STRING1.
      ASSIGN (STRING1) TO <G>.
      KUNNR = <G>.
      CONCATENATE '(' PROGNAME ')bseg-lifnr' INTO STRING2.
      ASSIGN (STRING2) TO <H>.
      LIFNR = <H>.
*        if no KUNNR or LIFNR found --> standard F4 help
      IF KUNNR IS INITIAL AND LIFNR IS INITIAL.
*       EXIT.                                                         "N2074351
        X_EXIT = 'X'.                                                 "N2074351
      ENDIF.

    WHEN 'SAPLMR1M'.
      CONCATENATE '(' PROGNAME ')rbkpv-bukrs' INTO STRING.
      CONCATENATE '(' PROGNAME ')rbkpv-budat' INTO STRING3.
      CONCATENATE '(' PROGNAME ')rbkpv-lifnr' INTO STRING2.
      CONCATENATE '(' PROGNAME ')akt_typ'     INTO STRING4.
      ASSIGN (STRING2) TO <H>.
      LIFNR = <H>.
      IF LIFNR IS INITIAL.
*       EXIT.                                                         "N2074351
        X_EXIT = 'X'.                                                 "N2074351
      ENDIF.
    WHEN OTHERS.
*      EXIT.                                                          "N2074351
      X_EXIT = 'X'.                                                   "N2074351

  ENDCASE.

  IF X_EXIT is initial.                                               "N2074351
  ASSIGN (STRING) TO <F>.
  BUKRS = <F>.
  ASSIGN (STRING3) TO <I>.
  BUDAT = <I>.
  ASSIGN (STRING4) TO <J>.
  X_AKTTYP = <J>.
  IF X_AKTTYP = 'A'.
    XSHOW = 'X'.
  ENDIF.

  CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
       EXPORTING
            BUKRS     = BUKRS
            COMPONENT = 'AR'
       EXCEPTIONS
            OTHERS    = 1.
  IF SY-SUBRC = 0.

    CALL FUNCTION 'FI_TAX_INPUT_CHECK'
         EXPORTING
              I_BUKRS = BUKRS
              I_KUNNR = KUNNR
              I_LIFNR = LIFNR
              I_BUDAT = BUDAT
              I_XSHOW = XSHOW
         IMPORTING
              E_MWSKZ = XMWSKZ
              E_EXIT  = EXIT
         EXCEPTIONS
              OTHERS  = 0.

    IF EXIT = 'X'.
      CALLCONTROL-STEP = 'EXIT'.
    ELSE.
      SELECT SINGLE * FROM T001
        INTO @DATA(ls_t001)
         WHERE BUKRS = @BUKRS.
      SELECT SINGLE * FROM T005
        into @DATA(ls_t005)
         WHERE LAND1 = @ls_t001-LAND1.
      READ TABLE SHLP-FIELDDESCR INTO WA_FIELDS
                                 WITH KEY FIELDNAME = 'KALSM'.
      OFFSET = WA_FIELDS-OFFSET.
      MOVE ls_t005-KALSM TO RECORD_TAB-STRING+OFFSET(5).
      READ TABLE SHLP-FIELDDESCR INTO WA_FIELDS
                                 WITH KEY FIELDNAME = 'MWSKZ'.
      OFFSET = WA_FIELDS-OFFSET.
      MOVE XMWSKZ TO RECORD_TAB-STRING+OFFSET(2).
      OFFSET = OFFSET + 2.
      WRITE ' ' TO RECORD_TAB-STRING+OFFSET(1).
      APPEND RECORD_TAB.
*      READ TABLE SHLP-FIELDDESCR INDEX 2 INTO TYPE_INFO
*                                  TRANSPORTING LENG.
*      TYPE_INFO-LENG = '2'.
*      MODIFY SHLP-FIELDDESCR INDEX 2 FROM TYPE_INFO
*                             TRANSPORTING LENG.
      CALLCONTROL-STEP = 'RETURN'.
    ENDIF.
  ELSE.                                                               "N2074351
    X_EXIT = 'X'.                                                     "N2074351
  ENDIF.
  ENDIF.                                                              "N2074351

ENDFUNCTION.
