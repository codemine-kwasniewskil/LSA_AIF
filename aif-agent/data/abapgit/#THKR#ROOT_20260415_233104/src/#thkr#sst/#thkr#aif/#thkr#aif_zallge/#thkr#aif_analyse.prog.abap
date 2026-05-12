*&---------------------------------------------------------------------*
* Gereon Koks  28.1.2026  T-Systems
*&---------------------------------------------------------------------*
* Analyse von AIF-Nachrichten.
*&---------------------------------------------------------------------*
*& Report /THKR/AIF_ANALYSE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/AIF_ANALYSE LINE-SIZE 1023.
*&---------------------------------------------------------------------*
TABLES: /AIF/PERS_QMSG.
*&---------------------------------------------------------------------*
TYPES:
  BEGIN OF TY_COL,
    FIELDNAME TYPE FIELDNAME,
* das ist der längste Wert
    VALUE(90),
    ANZ       TYPE I,
  END OF TY_COL,

  BEGIN OF TY_COL2,
    BTYP      TYPE /THKR/AIF_BTYP,
    FIELDNAME TYPE FIELDNAME,
* das ist der längste Wert
    VALUE(90),
    ANZ       TYPE I,
  END OF TY_COL2,

  BEGIN OF TY_COL3,
    BTYP     TYPE /THKR/AIF_BTYP,
* Was für ein Fall ist aufgetreten ?
* a) 12_OEH gefüllt = 05_QUELLE
* b) 12_OEH nicht gefüllt aber 05_QUELLE gefüllt
* c) 12_OEH gefüllt <> 05_QUELLE
    FALL(40),
    ANZ      TYPE I,
  END OF TY_COL3,

* Belastungsvorankündigung
  BEGIN OF TY_COL4,
* a)73_BDRUCKDATUM und 74_BDRUCKUSER beide gefüllt
* b)73_BDRUCKDATUM und 74_BDRUCKUSER beide leer
* c)73_BDRUCKDATUM gefüllt und 74_BDRUCKUSER leer
* d)73_BDRUCKDATUM leer und 74_BDRUCKUSER gefüllt
    FALL(60),
    ANZ      TYPE I,
  END OF TY_COL4.
*&---------------------------------------------------------------------*
TYPES: BEGIN OF TY_HEADER,
         NS          TYPE /AIF/NS,
         IFNAME      TYPE /AIF/IFNAME,
         IFVERSION   TYPE /AIF/IFVERSION,
         CREATE_USER TYPE /AIF/CREATE_USER,
         CREATE_DATE TYPE /AIF/CREATE_DATE,
         CREATE_TIME TYPE /AIF/CREATE_TIME.
TYPES: END OF TY_HEADER.

TYPES: BEGIN OF TY_GP.
         INCLUDE TYPE TY_HEADER.
         INCLUDE TYPE /THKR/S_AIF_SAP_GP.
TYPES: END OF TY_GP.

TYPES: BEGIN OF TY_AO.
         INCLUDE TYPE TY_HEADER.
         INCLUDE TYPE /THKR/S_AIF_SAP_AO.
TYPES: END OF TY_AO.

TYPES: BEGIN OF TY_KONT.
         INCLUDE TYPE TY_HEADER.
         INCLUDE TYPE /THKR/S_DTO_PSM_AO_KONT.
TYPES: END OF TY_KONT.
*&---------------------------------------------------------------------*
DATA: L_/AIF/PERS_QMSG  TYPE /AIF/PERS_QMSG,
      LT_/AIF/PERS_QMSG TYPE TABLE OF /AIF/PERS_QMSG,
      LR_APPL_ENGINE    TYPE REF TO /AIF/IF_APPLICATION_ENGINE,
      LV_SXMSGUID       TYPE SXMSGUID,
      LS_XMLPARSE       TYPE /AIF/XMLPARSE_DATA,
      L_DD03L           TYPE DD03L,
      LV_01_BTYP        LIKE /THKR/S_AIF_BIC_ZEILE-01_BTYP,
      LV_05_QUELLE      LIKE /THKR/S_AIF_BIC_ZEILE-05_QUELLE,
      LV_12_OEH         LIKE /THKR/S_AIF_BIC_ZEILE-12_OEH,
      LV_73_BDRUCKDATUM LIKE /THKR/S_AIF_BIC_ZEILE-73_BDRUCKDATUM,
      LV_74_BDRUCKUSER  LIKE /THKR/S_AIF_BIC_ZEILE-74_BDRUCKUSER,
      LS_COL            TYPE TY_COL,
      LT_COL            TYPE TABLE OF TY_COL,
      LS_COL2           TYPE TY_COL2,
      LT_COL2           TYPE TABLE OF TY_COL2,
      LS_COL3           TYPE TY_COL3,
      LT_COL3           TYPE TABLE OF TY_COL3,
      LS_COL4           TYPE TY_COL4,
      LT_COL4           TYPE TABLE OF TY_COL4,
      LV_BTYP           TYPE /THKR/AIF_BTYP,
      LV_IFDIRECTION    TYPE /AIF/IFDIRECTION,
      LV_TRANSFORM_DATA TYPE FLAG,
      LT_RETURN         TYPE STANDARD TABLE OF BAPIRET2,
      LREF_DATA_TRG     TYPE REF TO DATA,
      LT_GP             TYPE TABLE OF TY_GP,
      LS_GP             TYPE TY_GP,
      LT_AO             TYPE TABLE OF TY_AO,
      LS_AO             TYPE TY_AO,
      LT_KONT           TYPE TABLE OF TY_KONT,
      LS_KONT           TYPE TY_KONT,
      LV_NR             TYPE I.
*&---------------------------------------------------------------------*
FIELD-SYMBOLS: <LS_SRC>       TYPE DATA,
               <LS_TRG>       TYPE ANY,
*               <ls_line>      TYPE any,
               <LS_LINE>      TYPE STANDARD TABLE,
               <LS_ZEILE>     TYPE ANY,
               <FT_GP>        TYPE ANY,
               <FS_GP>        TYPE ANY,
               <FT_AO>        TYPE ANY,
               <FS_AO>        TYPE ANY,
               <FT_KONT>      TYPE ANY,
               <FS_KONT>      TYPE ANY,
               <LS_T_MANDATE> TYPE ANY,
               <LS_ANY>       TYPE ANY.
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B_SEL WITH FRAME TITLE TEXT-001.
  PARAMETERS:     P_NS     TYPE /AIF/PERS_QMSG-NS.
*  PARAMETERS:     p_ifname TYPE /aif/pers_qmsg-ifname.
  SELECT-OPTIONS: P_IFNAME FOR /AIF/PERS_QMSG-IFNAME.
  PARAMETERS:     P_IFVER  TYPE /AIF/PERS_QMSG-IFVERSION.
  SELECT-OPTIONS: P_DATE   FOR  /AIF/PERS_QMSG-CREATE_DATE.
  SELECT-OPTIONS: P_TIME   FOR  /AIF/PERS_QMSG-CREATE_TIME.
SELECTION-SCREEN END OF BLOCK B_SEL.
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK B_ANA WITH FRAME TITLE TEXT-002.
* SST Name ausgeben
  PARAMETERS:     AK_TST5 AS CHECKBOX.
* Geschäftspartner
  PARAMETERS:     AK_GP AS CHECKBOX.
* Anordnung
  PARAMETERS:     AK_AO AS CHECKBOX.
* Kontierung
  PARAMETERS:     AK_KONT AS CHECKBOX.
* Belastungsankündigung
  PARAMETERS:     AK_TST1 AS CHECKBOX.
* Ausprägung von Feldern
  PARAMETERS:     AK_TST2 AS CHECKBOX.
* BIC-Felder je 01_BTYP
  PARAMETERS:     AK_TST3 AS CHECKBOX.
* 05_QUELLE gegen 12_OEH
* Ergebnisse
* a) 12_OEH gefüllt = 05_QUELLE
* b) 12_OEH nicht gefüllt aber 05_QUELLE gefüllt
* c) 12_OEH gefüllt <> 05_QUELLE
  PARAMETERS:     AK_TST6 AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK B_ANA.
*&---------------------------------------------------------------------*
SELECT * FROM /AIF/PERS_QMSG INTO TABLE LT_/AIF/PERS_QMSG
  WHERE NS          =  P_NS
*    AND ifname      =  p_ifname
    AND IFNAME      IN P_IFNAME
    AND IFVERSION   =  P_IFVER
    AND CREATE_DATE IN P_DATE
    AND CREATE_TIME IN P_TIME.

IF SY-SUBRC = 0.
*&---------------------------------------------------------------------*
  LOOP AT LT_/AIF/PERS_QMSG INTO L_/AIF/PERS_QMSG.
*&---------------------------------------------------------------------*
    IF AK_TST5 = 'X'.
      ULINE.
      WRITE: /1 'Nachricht:',
                SY-TABIX,
                L_/AIF/PERS_QMSG-NS,
                L_/AIF/PERS_QMSG-IFNAME,
                L_/AIF/PERS_QMSG-IFVERSION,
                L_/AIF/PERS_QMSG-CREATE_USER,
                L_/AIF/PERS_QMSG-CREATE_DATE,
                L_/AIF/PERS_QMSG-CREATE_TIME.
      ULINE.
    ENDIF.
*&---------------------------------------------------------------------*
*    AT NEW CREATE_TIME.
*      ULINE.
*    ENDAT.
*&---------------------------------------------------------------------*
* Die Engine wird zum Lesen der Nachrichten benötigt.
    LR_APPL_ENGINE = /AIF/CL_AIF_ENGINE_FACTORY=>GET_ENGINE(
          IV_NS            = L_/AIF/PERS_QMSG-NS
          IV_IFNAME        = L_/AIF/PERS_QMSG-IFNAME
          IV_IFVERSION     = L_/AIF/PERS_QMSG-IFVERSION
             ).

    LV_SXMSGUID = L_/AIF/PERS_QMSG-MSGGUID.

* Nachrichten zur GUID lesen
    CALL METHOD LR_APPL_ENGINE->READ_MSG_FROM_PERSISTENCY
      EXPORTING
        IV_MSGGUID  = LV_SXMSGUID
        IV_NS       = L_/AIF/PERS_QMSG-NS
        IV_IFNAME   = L_/AIF/PERS_QMSG-IFNAME
        IV_IFVER    = L_/AIF/PERS_QMSG-IFVERSION
      CHANGING
        CS_XMLPARSE = LS_XMLPARSE.

    ASSIGN LS_XMLPARSE-XI_DATA->* TO <LS_SRC>.
    ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_SRC> TO <LS_LINE>.
    DATA LV_TABIX TYPE SY-TABIX.
    LOOP AT <LS_LINE> ASSIGNING <LS_ZEILE>.
      ASSIGN COMPONENT '01_BTYP' OF STRUCTURE <LS_ZEILE> TO <LS_ANY>.
      IF <LS_ANY> IS INITIAL.
        DELETE <LS_LINE> INDEX SY-TABIX.
      ENDIF.
    ENDLOOP.
*&---------------------------------------------------------------------*
    LV_IFDIRECTION    = 'I'.
    LV_TRANSFORM_DATA = 'X'.

    CREATE DATA LREF_DATA_TRG TYPE ('/thkr/s_aif_sap').
    ASSIGN LREF_DATA_TRG->* TO <LS_TRG>.

* Mapping nur, wenn auch das Ergebnis ausgewertet werden soll.
    IF AK_GP = 'X' OR
       AK_AO = 'X' OR
       AK_KONT = 'X'.
      TRY.
          CALL FUNCTION '/AIF/FILE_TRANSFORM_DATA'
            EXPORTING
              NS                     = L_/AIF/PERS_QMSG-NS
              IFNAME                 = L_/AIF/PERS_QMSG-IFNAME
              IFVERSION              = L_/AIF/PERS_QMSG-IFVERSION
              XI_FLAG                = ABAP_TRUE
              IFDIRECTION            = LV_IFDIRECTION
              TRANSFORM_DATA         = LV_TRANSFORM_DATA
            IMPORTING
              OUT_STRUCT             = <LS_TRG>
            TABLES
              RETURN_TAB             = LT_RETURN
            CHANGING
              RAW_STRUCT             = <LS_SRC>
            EXCEPTIONS
              NOT_FOUND              = 1
              CUSTOMIZING_INCOMPLETE = 2
              MAX_ERRORS_REACHED     = 3
              CANCEL                 = 4
              OTHERS                 = 5.

        CATCH CX_ROOT.
          CONTINUE.
      ENDTRY.
    ENDIF.
*#######################################################################
* Belastungsankündigung
    IF AK_TST1 = 'X'.
      CLEAR LV_NR.

      LOOP AT <LS_LINE> ASSIGNING <LS_ZEILE>.
        ADD 1 TO LV_NR.

        ASSIGN COMPONENT '01_BTYP' OF STRUCTURE <LS_ZEILE> TO <LS_ANY>.
        LV_01_BTYP = <LS_ANY>.

        ASSIGN COMPONENT '73_BDRUCKDATUM' OF STRUCTURE <LS_ZEILE> TO <LS_ANY>.
        LV_73_BDRUCKDATUM = <LS_ANY>.

        ASSIGN COMPONENT '74_BDRUCKUSER' OF STRUCTURE <LS_ZEILE> TO <LS_ANY>.
        LV_74_BDRUCKUSER = <LS_ANY>.

        IF LV_73_BDRUCKDATUM IS INITIAL.
          IF LV_74_BDRUCKUSER IS INITIAL.
            LS_COL4-FALL = 'b)73_BDRUCKDATUM und 74_BDRUCKUSER beide leer'.
          ELSE.
            LS_COL4-FALL = 'd)73_BDRUCKDATUM leer und 74_BDRUCKUSER gefüllt'.
          ENDIF.
        ELSE.
          IF LV_74_BDRUCKUSER IS INITIAL.
            LS_COL4-FALL = 'c)73_BDRUCKDATUM gefüllt und 74_BDRUCKUSER leer'.
          ELSE.
            LS_COL4-FALL = 'a)73_BDRUCKDATUM und 74_BDRUCKUSER beide gefüllt'.
          ENDIF.
        ENDIF.

        LS_COL4-ANZ = 1.
        COLLECT LS_COL4 INTO LT_COL4.

        WRITE: /1 LV_NR,
                  L_/AIF/PERS_QMSG-NS,
                  L_/AIF/PERS_QMSG-IFNAME,
                  L_/AIF/PERS_QMSG-IFVERSION,
                  L_/AIF/PERS_QMSG-CREATE_DATE ,
                  L_/AIF/PERS_QMSG-CREATE_TIME,
                  '01_BTYP       :', LV_01_BTYP,
                  '73_BDRUCKDATUM:', LV_73_BDRUCKDATUM,
                  '74_BDRUCKUSER :', LV_74_BDRUCKUSER,
                  LS_COL4-FALL.
      ENDLOOP.
    ENDIF.
*#######################################################################
* Ausprägung von Feldern
    IF AK_TST2 = 'X'.
      LOOP AT <LS_LINE> ASSIGNING <LS_ZEILE>.
        SELECT * FROM DD03L INTO L_DD03L
          WHERE TABNAME = '/THKR/S_AIF_BIC_ZEILE'.

          ASSIGN COMPONENT L_DD03L-FIELDNAME OF STRUCTURE <LS_ZEILE> TO <LS_ANY>.

          LS_COL-FIELDNAME = L_DD03L-FIELDNAME.
          LS_COL-VALUE     = <LS_ANY>.
          LS_COL-ANZ       = 1.
          COLLECT LS_COL INTO LT_COL.
        ENDSELECT.
      ENDLOOP.
    ENDIF.
*#######################################################################
    IF AK_TST3 = 'X'.
      LOOP AT <LS_LINE> ASSIGNING <LS_ZEILE>.
        SELECT * FROM DD03L INTO L_DD03L
          WHERE TABNAME = '/THKR/S_AIF_BIC_ZEILE'.

          ASSIGN COMPONENT L_DD03L-FIELDNAME OF STRUCTURE <LS_ZEILE> TO <LS_ANY>.

          IF L_DD03L-FIELDNAME = '01_BTYP'.
            LV_BTYP = <LS_ANY>.
          ELSE.
            LS_COL2-BTYP      = LV_BTYP.
            LS_COL2-FIELDNAME = L_DD03L-FIELDNAME.
            LS_COL2-VALUE     = <LS_ANY>.
            LS_COL2-ANZ       = 1.
            COLLECT LS_COL2 INTO LT_COL2.
          ENDIF.
        ENDSELECT.
      ENDLOOP.
    ENDIF.
*#######################################################################
    IF AK_GP = 'X'.
      PERFORM GP_FILL.
    ENDIF.
*#######################################################################
    IF AK_AO = 'X'.
      PERFORM AO_FILL.
    ENDIF.
*#######################################################################
    IF AK_KONT = 'X'.
      PERFORM KONT_FILL.
    ENDIF.
*#######################################################################
    IF AK_TST6 = 'X'.
      LOOP AT <LS_LINE> ASSIGNING <LS_ZEILE>.
        ASSIGN COMPONENT '01_BTYP' OF STRUCTURE <LS_ZEILE> TO <LS_ANY>.
        LV_01_BTYP = <LS_ANY>.

        ASSIGN COMPONENT '05_QUELLE' OF STRUCTURE <LS_ZEILE> TO <LS_ANY>.
        LV_05_QUELLE = <LS_ANY>.

        ASSIGN COMPONENT '12_OEH' OF STRUCTURE <LS_ZEILE> TO <LS_ANY>.
        LV_12_OEH = <LS_ANY>.

        WRITE: /1 SY-TABIX,
                  L_/AIF/PERS_QMSG-NS,
                  L_/AIF/PERS_QMSG-IFNAME,
                  L_/AIF/PERS_QMSG-IFVERSION,
                  L_/AIF/PERS_QMSG-CREATE_DATE ,
                  L_/AIF/PERS_QMSG-CREATE_TIME,
                  '01_BTYP  :', LV_01_BTYP,
                  '05_QUELLE:', LV_05_QUELLE,
                  '12_OEH   :', LV_12_OEH.

        LS_COL3-BTYP = LV_01_BTYP.
* a) 12_OEH gefüllt = 05_QUELLE
* b) 12_OEH gefüllt <> 05_QUELLE
* c) 12_OEH nicht gefüllt aber 05_QUELLE gefüllt
* d) beide nicht gefüllt
        IF NOT LV_12_OEH IS INITIAL.
          IF LV_12_OEH = LV_05_QUELLE.
            LS_COL3-FALL = '12_OEH gefüllt und gleich 05_QUELLE'.
          ELSE.
            LS_COL3-FALL = '12_OEH gefüllt und ungleich 05_QUELLE'.
          ENDIF.
        ELSE.
          IF LV_12_OEH = LV_05_QUELLE.
            LS_COL3-FALL = '12_OEH nicht gefüllt und gleich 05_QUELLE'.
          ELSE.
            LS_COL3-FALL = '12_OEH nich gefüllt aber 05_QUELLE gefüllt.'.
          ENDIF.
        ENDIF.

        LS_COL3-ANZ = 1.

        COLLECT LS_COL3 INTO LT_COL3.
      ENDLOOP.
    ENDIF.
*#######################################################################
* über alle Nachrichten
  ENDLOOP.
*&---------------------------------------------------------------------*
ENDIF.
*#######################################################################
* AUSGABE
*#######################################################################
* Belastungsankündigung
IF AK_TST1 = 'X'.
  ULINE.
  WRITE: /1 'Belastungsankündigung'.
  ULINE.

  SORT LT_COL4.

  LOOP AT LT_COL4 INTO LS_COL4.
    WRITE: /1 LS_COL4-FALL,
              LS_COL4-ANZ.
  ENDLOOP.
ENDIF.
*#######################################################################
IF AK_TST2 = 'X'.
  ULINE.
  WRITE: /1 'Ausprägung von Feldern'.
  ULINE.

  SORT LT_COL.

  LOOP AT LT_COL INTO LS_COL.
    WRITE: /1 LS_COL-FIELDNAME,
              LS_COL-VALUE(40),
              LS_COL-ANZ.
  ENDLOOP.
ENDIF.
*#######################################################################
IF AK_TST3 = 'X'.
  SORT LT_COL.

  LOOP AT LT_COL2 INTO LS_COL2.
    AT NEW BTYP.
      ULINE.
    ENDAT.
    WRITE: /1 LS_COL2-BTYP,
              LS_COL2-FIELDNAME,
              LS_COL2-VALUE(40),
              LS_COL2-ANZ.
  ENDLOOP.
ENDIF.
*#######################################################################
IF AK_GP = 'X'.
  WRITE: /1 'GP - Geschäftspartner'.
  ULINE.

  LOOP AT LT_GP INTO LS_GP.
    PERFORM GP_WRITE.
  ENDLOOP.
ENDIF.
*#######################################################################
IF AK_AO = 'X'.
  WRITE: /1 'AO - Anordnung'.
  ULINE.

  LOOP AT LT_AO INTO LS_AO.
    PERFORM AO_WRITE.
  ENDLOOP.
ENDIF.
*#######################################################################
IF AK_KONT = 'X'.
  WRITE: /1 'KONT - Kontierung'.
  ULINE.

  LOOP AT LT_KONT INTO LS_KONT.
    PERFORM KONT_WRITE.
  ENDLOOP.
ENDIF.
*#######################################################################
IF AK_TST6 = 'X'.
  ULINE.
  WRITE: /1 '05_QUELLE vs. 12_OEH'.
  ULINE.

  LOOP AT LT_COL3 INTO LS_COL3.
    WRITE: /1 SY-TABIX,
              LS_COL3-BTYP,
              LS_COL3-FALL,
              LS_COL3-ANZ.
  ENDLOOP.
ENDIF.
*#######################################################################
*&---------------------------------------------------------------------*
*& Form gp_write
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GP_WRITE .
*&---------------------------------------------------------------------*
  WRITE: /1 SY-TABIX,
            'NS:',         LS_GP-NS,
            '|IFNAME:',    LS_GP-IFNAME,
            '|IFVERSION:', LS_GP-IFVERSION,
            '|USER:',      LS_GP-CREATE_USER,
            '|DATE:',      LS_GP-CREATE_DATE,
            '|TIME:',      LS_GP-CREATE_TIME,
            '|PARTNER:',   LS_GP-PARTNER,
            '|BKVID:',     LS_GP-BKVID,
            '|BANKS:',     LS_GP-BANKS,
            '|INTCA:',     LS_GP-INTCA,
            '|BANKN:',     LS_GP-BANKN,
            '|BANKK:',     LS_GP-BANKK,
            '|BKONT:',     LS_GP-BKONT,
            '|BU_KOINH:',  LS_GP-BU_KOINH,
            '|XEZER:',     LS_GP-XEZER,
            '|IBAN:',      LS_GP-IBAN.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GP_FILL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GP_FILL .
*&---------------------------------------------------------------------*
  FIELD-SYMBOLS: <FS_FIELD> TYPE DATA.
*&---------------------------------------------------------------------*
  ASSIGN COMPONENT 'GP' OF STRUCTURE <LS_TRG> TO <FT_GP>.

  IF SY-SUBRC = 0.
    LOOP AT <FT_GP> ASSIGNING <FS_GP>.
      CLEAR LS_GP.

* HEADER füllen
      MOVE-CORRESPONDING L_/AIF/PERS_QMSG TO LS_GP.

* Felder füllen
      ASSIGN COMPONENT 'partner' OF STRUCTURE <FS_GP> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_GP-PARTNER = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'BKVID' OF STRUCTURE <FS_GP> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_GP-BKVID = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'banks' OF STRUCTURE <FS_GP> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_GP-BANKS = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'intca' OF STRUCTURE <FS_GP> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_GP-INTCA = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'bankn' OF STRUCTURE <FS_GP> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_GP-BANKN = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'bankk' OF STRUCTURE <FS_GP> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_GP-BANKK = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'bkont' OF STRUCTURE <FS_GP> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_GP-BKONT = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'bu_koinh' OF STRUCTURE <FS_GP> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_GP-BU_KOINH = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'xezer' OF STRUCTURE <FS_GP> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_GP-XEZER = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'iban' OF STRUCTURE <FS_GP> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_GP-IBAN = <FS_FIELD>. ENDIF.

      APPEND LS_GP TO LT_GP.
    ENDLOOP.
  ENDIF.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form AO_FILL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AO_FILL .
*&---------------------------------------------------------------------*
  FIELD-SYMBOLS: <FS_FIELD> TYPE DATA.
*&---------------------------------------------------------------------*
  ASSIGN COMPONENT 'AO' OF STRUCTURE <LS_TRG> TO <FT_AO>.

  IF SY-SUBRC = 0.
    LOOP AT <FT_AO> ASSIGNING <FS_AO>.
      CLEAR LS_AO.

* HEADER füllen
      MOVE-CORRESPONDING L_/AIF/PERS_QMSG TO LS_AO.

* Felder füllen
      ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-BUKRS = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'GJAHR' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-GJAHR = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'PSOTY' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-PSOTY = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'WAERS' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-WAERS = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'BELNR' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-BELNR = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'BLART' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-BLART = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'BLDAT' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-BLDAT = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'BUDAT' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-BUDAT = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'MONAT' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-MONAT = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'BKTXT' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-BKTXT = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'PSOFN' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-PSOFN = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'MWSKZ' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-MWSKZ = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'XMWST' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-XMWST = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'WMWST' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-WMWST = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'ZBD1T' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-ZBD1T = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'ZFBDT' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-ZFBDT = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'ZLSCH' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-ZLSCH = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'ZTERM' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-ZTERM = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'XBLNR' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-XBLNR = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'BVTYP' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-BVTYP = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'MABER' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-MABER = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'MANSP' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-MANSP = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'MADAT' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-MADAT = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'BSTAT' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-BSTAT = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'PSOAK' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-PSOAK = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'REBZG' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-REBZG = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'REBZJ' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-REBZJ = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'REBZZ' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-REBZZ = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'REBZT' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-REBZT = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'LZBKZ' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-LZBKZ = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'LANDL' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-LANDL = <FS_FIELD>. ENDIF.

      ASSIGN COMPONENT 'ZUONR' OF STRUCTURE <FS_AO> TO <FS_FIELD>.
      IF SY-SUBRC = 0. LS_AO-ZUONR = <FS_FIELD>. ENDIF.
    ENDLOOP.

    APPEND LS_AO TO LT_AO.
  ENDIF.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ao_WRITE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AO_WRITE .
*&---------------------------------------------------------------------*
  WRITE: /1 SY-TABIX,
            'NS:',         LS_AO-NS,
            '|IFNAME:',    LS_AO-IFNAME,
            '|IFVERSION:', LS_AO-IFVERSION,
            '|USER:',      LS_AO-CREATE_USER,
            '|DATE:',      LS_AO-CREATE_DATE,
            '|TIME:',      LS_AO-CREATE_TIME,
            '|BUKRS:',     LS_AO-BUKRS,
            '|GJAHR:',     LS_AO-GJAHR,
            '|PSOTY:',     LS_AO-PSOTY,
            '|WAERS:',     LS_AO-WAERS,
            '|BELNR:',     LS_AO-BELNR,
            '|BLART:',     LS_AO-BLART,
            '|BLDAT:',     LS_AO-BLDAT,
            '|BUDAT:',     LS_AO-BUDAT,
            '|MONAT:',     LS_AO-MONAT,
            '|BKTXT:',     LS_AO-BKTXT,
            '|PSOFN:',     LS_AO-PSOFN,
            '|MWSKZ:',     LS_AO-MWSKZ,
            '|XMWST:',     LS_AO-XMWST,
            '|WMWST:',     LS_AO-WMWST,
            '|ZBD1T:',     LS_AO-ZBD1T,
            '|ZFBDT:',     LS_AO-ZFBDT,
            '|ZLSCH:',     LS_AO-ZLSCH,
            '|ZTERM:',     LS_AO-BUKRS,
            '|XBLNR:',     LS_AO-XBLNR,
            '|BVTYP:',     LS_AO-BVTYP,
            '|MABER:',     LS_AO-MABER,
            '|MANSP:',     LS_AO-MANSP,
            '|MADAT:',     LS_AO-MADAT,
            '|BSTAT:',     LS_AO-BSTAT,
            '|PSOAK:',     LS_AO-PSOAK,
            '|REBZG:',     LS_AO-REBZG,
            '|REBZJ:',     LS_AO-REBZJ,
            '|REBZZ:',     LS_AO-REBZZ,
            '|REBZT:',     LS_AO-REBZT,
            '|LZBKZ:',     LS_AO-LZBKZ,
            '|LANDL:',     LS_AO-LANDL,
            '|ZUONR:',     LS_AO-ZUONR.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form kont_FILL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM KONT_FILL .
*&---------------------------------------------------------------------*
  FIELD-SYMBOLS: <FS_FIELD> TYPE DATA.
*&---------------------------------------------------------------------*
*  WRBTR
*  MWSKZ
*  SGTXT
*  FIPEX
*  FISTL
*  FIKRS
*  KOSTL
*  ZUONR
*  PS_PSP_PNR
*  FKBER
*  GEBER
*  HKONT
*  KBLNR
*  MEASURE
*  GSBER
*  AUFNR
*  ERLKZ
*&---------------------------------------------------------------------*

  ASSIGN COMPONENT 'AO' OF STRUCTURE <LS_TRG> TO <FT_AO>.

  IF SY-SUBRC = 0.
    LOOP AT <FT_AO> ASSIGNING <FS_AO>.
      ASSIGN COMPONENT 'T_KONT' OF STRUCTURE <FS_AO> TO <FT_KONT>.

      LOOP AT <FT_KONT> ASSIGNING <FS_KONT>.
        IF SY-SUBRC = 0.
          CLEAR LS_KONT.

* HEADER füllen
          MOVE-CORRESPONDING L_/AIF/PERS_QMSG TO LS_KONT.

* Felder füllen
          ASSIGN COMPONENT 'WRBTR' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-WRBTR = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'MWSKZ' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-MWSKZ = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'SGTXT' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-SGTXT = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'FIPEX' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-FIPEX = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'FISTL' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-FISTL = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'FIKRS' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-FIKRS = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'KOSTL' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-KOSTL = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'ZUONR' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-ZUONR = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'PS_PSP_PNR' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-PS_PSP_PNR = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'FKBER' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-FKBER = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'GEBER' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-GEBER = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'HKONT' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-HKONT = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'KBLNR' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-KBLNR = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'MEASURE' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-MEASURE = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'GSBER' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-GSBER = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'AUFNR' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-AUFNR = <FS_FIELD>. ENDIF.

          ASSIGN COMPONENT 'ERLKZ' OF STRUCTURE <FS_KONT> TO <FS_FIELD>.
          IF SY-SUBRC = 0. LS_KONT-ERLKZ = <FS_FIELD>. ENDIF.

          APPEND LS_KONT TO LT_KONT.
        ENDIF.
* über T_KONT
      ENDLOOP.
* über AO
    ENDLOOP.
  ENDIF.
*&---------------------------------------------------------------------*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form kont_WRITE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM KONT_WRITE .
*&---------------------------------------------------------------------*
  WRITE: /1 SY-TABIX,
            'NS:',          LS_KONT-NS,
            '|IFNAME:',     LS_KONT-IFNAME,
            '|IFVERSION:',  LS_KONT-IFVERSION,
            '|USER:',       LS_KONT-CREATE_USER,
            '|DATE:',       LS_KONT-CREATE_DATE,
            '|TIME:',       LS_KONT-CREATE_TIME,
            '|WRBTR:',      LS_KONT-WRBTR,
            '|MWSKZ:',      LS_KONT-MWSKZ,
            '|SGTXT:',      LS_KONT-SGTXT,
            '|FIPEX:',      LS_KONT-FIPEX,
            '|FISTL:',      LS_KONT-FISTL,
            '|FIKRS:',      LS_KONT-FIKRS,
            '|KOSTL:',      LS_KONT-KOSTL,
            '|ZUONR:',      LS_KONT-ZUONR,
            '|PS_PSP_PNR:', LS_KONT-PS_PSP_PNR,
            '|FKBER:',      LS_KONT-FKBER,
            '|GEBER:',      LS_KONT-GEBER,
            '|HKONT:',      LS_KONT-HKONT,
            '|KBLNR:',      LS_KONT-KBLNR,
            '|MEASURE:',    LS_KONT-MEASURE,
            '|GSBER:',      LS_KONT-GSBER,
            '|AUFNR:',      LS_KONT-AUFNR,
            '|ERLKZ:',      LS_KONT-ERLKZ.
*&---------------------------------------------------------------------*
ENDFORM.
