*****           Implementation of object type /THKR/2086           *****
INCLUDE <OBJECT>.
BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
  BEGIN OF KEY,
      RESERVDOCNUMBER LIKE KBLPS-BELNR,
      RESERVDOCITEM LIKE KBLPS-BLPOS,
      DOCUMENTNUMBER LIKE KBLPS-BPENT,
  END OF KEY.
END_DATA OBJECT. " Do not change.. DATA is generated

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Methode: ZGetBasicData
"Beschreibung: Die Methode ermittelt die Kontierungselemente
"der zugrundeliegenden Mittelvormerkung für die spätere
"Ermittlung des Genehmigers.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
BEGIN_METHOD ZGETBASICDATA CHANGING CONTAINER.
DATA:
      S_POS_DATA LIKE /THKR/S_AORD_POS_DATA,
      s_kblp type kblp,
      s_kblk type kblk.
    "Auslesen Belegkopf
    Select SINGLE * from kblk into s_kblk
      where belnr = object-key-reservdocnumber.
    "Auslesen einer Belegposition
    "AHCHTUNG: Annahme: alle Positionen sind gleich kontiert
    Select SINGLE * FROM KBLP into s_kblp
      where belnr = object-key-reservdocnumber and
      blpos = object-key-reservdocitem.
      "Übertragen der Kontierungselemente
      s_pos_data-bukrs = s_kblk-bukrs.
      s_pos_data-gsber = s_kblp-gsber.
      s_pos_data-fipos = s_kblp-fipos.
      s_pos_data-fistl = s_kblp-fistl.
      s_pos_data-fonds = s_kblp-geber.
      s_pos_data-fkber = s_kblp-fkber.
  "Übergabe der Kontierungselemente an den WF-Container
  SWC_SET_ELEMENT CONTAINER 'S_POS_DATA' S_POS_DATA.
END_METHOD.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Methode: ZCheckIfVe
"Beschreibung: Eine Wertanpassung einer Mittelbindung
"(Belegart MB) ist nur dann genehmigungspflichtig, wenn
"mindestens eine Belegposition ein Fällig am Datum besitzt,
"welches in einem Folgejahr liegt.
"Rückgabewert: XSUBRC - 5 - Wertanpassung muss genehmigt werden
"                       0 - keine Genehmigung notwendig
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
BEGIN_METHOD ZCHECKIFVE CHANGING CONTAINER.
DATA:
      XSUBRC TYPE SYST-SUBRC,
       s_kblk type kblk,
  t_kblp TYPE STANDARD TABLE OF kblp.

SELECT SINGLE *
  FROM kblk
  INTO s_kblk
  WHERE belnr = object-key-reservdocnumber.

SELECT *
FROM kblp
INTO TABLE t_kblp
WHERE belnr = object-key-reservdocnumber
AND blpos = object-key-reservdocitem.
IF sy-subrc <> 0.

  SELECT *
FROM kblp
INTO TABLE t_kblp
WHERE belnr = object-key-reservdocnumber.

ENDIF.

if s_kblk-blart = 'MB'.

Loop at t_kblp ASSIGNING FIELD-SYMBOL(<fs_kblp>).

    if <fs_kblp>-fdatk(4) > sy-datum(4).

      XSUBRC = 5.

      exit.

      ENDIF.

  ENDLOOP.


ENDIF.

  SWC_SET_ELEMENT CONTAINER 'XSUBRC' XSUBRC.
END_METHOD.

BEGIN_METHOD ZADDATTACHEMENTS CHANGING CONTAINER.
DATA:
      lV_WIID TYPE SWWWIHEAD-WI_ID,
      lv_XSUBRC TYPE SYST-SUBRC,
      lv_objkey type SWO_TYPEID.
      SWC_GET_ELEMENT CONTAINER 'V_WIID' LV_WIID.

Move object-key to lv_objkey.

  CALL FUNCTION '/THKR/WF_OBJ_RELAT_CREATE'
  EXPORTING
    iv_objkey                            = lv_objkey
    iv_objtype                           = 'BUS2086'
    iv_wi_id                             = lv_wiid
 EXCEPTIONS
   RELATION_COULD_NOT_CREATE            = 1
   ERROR_READING_ATTACHEMENTS           = 2
   ERROR_READING_ATTACHEMENT_TYPE       = 3
   OTHERS                               = 4
          .
IF sy-subrc <> 0.
lv_xsubrc = 2.
ENDIF.

  SWC_GET_ELEMENT CONTAINER 'V_WIID' lV_WIID.
  SWC_SET_ELEMENT CONTAINER 'XSUBRC' lv_XSUBRC.
END_METHOD.
