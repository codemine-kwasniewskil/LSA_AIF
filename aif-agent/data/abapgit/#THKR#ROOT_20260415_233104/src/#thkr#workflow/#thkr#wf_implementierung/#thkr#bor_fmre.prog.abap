*****           Implementation of object type /THKR/FMRE            *****
INCLUDE <object>.
begin_data object. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
  " begin of private,
  "   to declare private attributes remove comments and
  "   insert private attributes here ...
  " end of private,
  BEGIN OF key,
    documentnumber LIKE kblk-belnr,
    documentitem   LIKE kblp-blpos,
  END OF key.
end_data object. " Do not change.. DATA is generated
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Methode ZGetBasicData
"Beschreibung: Die Methode ermittelt die Kontierungselemente einer
"Mittelbindung.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
begin_method zgetbasicdata changing container.
DATA:
  s_pos_data LIKE /thkr/s_aord_pos_data,
  s_kblk     TYPE kblk,
  s_kblp     TYPE kblp.
"Auslesen der Kopfdaten der Mittelbindung
SELECT SINGLE *
  FROM kblk
  INTO s_kblk
  WHERE belnr = object-key-documentnumber.
"Auslesen einer Position der Mittelbindung
"Achtung: Annahme: Eine Mittelbindung besitzt immer
"die gleichen Kontierungselemente.
SELECT SINGLE *
  FROM kblp
  INTO s_kblp
  WHERE belnr = object-key-documentnumber
  AND blpos = object-key-documentitem.
IF sy-subrc <> 0.

  SELECT SINGLE *
FROM kblp
INTO s_kblp
WHERE belnr = object-key-documentnumber.

ENDIF.
"Übertragen der Kontierungselemente
s_pos_Data-bukrs = s_kblk-bukrs.
s_pos_data-gsber = s_kblp-gsber.
s_pos_data-fkber = s_kblp-fkber.
s_pos_data-fonds = s_kblp-geber.
s_pos_data-fipos = s_kblp-fipos.
s_pos_data-fistl = s_kblp-fistl.
s_pos_data-lfdnr = s_kblp-blpos.

"Wenn keine Daten übertragen wurden, dann wird eine
"Fehlermeldung ausgegeben.
IF s_pos_data IS INITIAL.
  MESSAGE e000(/thkr/wf).
ENDIF.
"Übergabe der Kontierungselemente an den WF-Container
swc_set_element container 'S_POS_DATA' s_pos_data.
end_method.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"ACHTUNG: OBSOLET
"Methode: ZBelegBuchen
"Beschreibung: Die Methode ändert den Status der Mittelbindung
"von "Vorerfasst" in "Gebucht".
"ACHTUNG: OBSOLET
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
begin_method zbelegbuchen changing container.
DATA:
  l_f_kblk    LIKE kblk,
  l_t_init    LIKE fmresini1 OCCURS 5 WITH HEADER LINE,
  bdcdata_tab TYPE TABLE OF bdcdata,
  bdcdata     LIKE LINE OF bdcdata_tab,
  s_tstc      TYPE tstc.

DATA: o_reex_doc TYPE REF TO cl_reex_doc_fm.
DATA: o_beleg TYPE REF TO cl_fm_ef_document.
DATA: o_beleg2 TYPE REF TO cl_fm_ef_document.
DATA: o_factory TYPE REF TO cl_fm_ef_factory.

CREATE OBJECT o_reex_doc.
CALL METHOD o_reex_doc->get_document
  EXPORTING
    id_fmdocno  = object-key-documentnumber
  RECEIVING
    ro_document = o_beleg
  EXCEPTIONS
    error       = 1
    OTHERS      = 2.
IF sy-subrc <> 0.
  MESSAGE e002(/thkr/wf).
ENDIF.

o_factory = o_reex_doc->get_factory( ).

o_beleg->post( ).

o_factory->update_all( EXPORTING i_flg_do_post = 'X' ).

COMMIT WORK.

end_method.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Methode: ZErfasserKorrigieren
"Beschreibung: Die Methode ändert den Erfasser und den letzten
"Änderer der Mittelbindung.
"Hintergrund: Die Verarbeitung wird durch einen Jobuser durchgeführt.
"Damit dieser nicht in den Änderungsdaten steht, wird der Antragsteller
"der Mittelbindung als Erfasser hinterlegt und der Genehmiger als
"letzter Änderer.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
begin_method zerfasserkorrigieren changing container.
DATA:
  s_kblk         TYPE kblk,
  i_actual_agent TYPE wfsyst-act_agent,
  i_initiator    TYPE wfsyst-initiator.
swc_get_element container 'I_ACTUAL_AGENT' i_actual_agent.
swc_get_element container 'I_INITIATOR' i_initiator.

SELECT SINGLE *
FROM kblk
INTO s_kblk
WHERE belnr = object-key-documentnumber.

s_kblk-kerfas = i_initiator+2.
s_kblk-kaende = i_actual_agent+2.

UPDATE kblk FROM s_kblk.

end_method.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Methode: ZCheckIfVe
"Beschreibung: Die Methode prüft, ob die Mittelbindung eine
"Verpflichtigungsermächtigung ist. Eine VE liegt dann vor, wenn
"eine Mittelvormerkung mit dem Belegtyp "MB" eine Position enthält,
"die erst in einem folgenden Geschäftsjahr fällig ist.
"Eine Mittelvormerkung der Belegart "MB" ist nur dann relevant für
"denn WF, wenn sie eine VE ist.
"Alle anderen Mittelvormerkungen der Belegart "MB" sind nicht
"genehmigugnspflichtig.
"Alle anderen Mittelvormerkungen mit einer anderen Belegart sind
"genehmigungspflichtig.
"Rückgabewert: XSUBRC - 5 - Mittelvormerkung muss genehmigt werden
"                       0 - Keine Genehmigung notwendig
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
begin_method zcheckifve changing container.
DATA:
  xsubrc  TYPE syst-subrc,
  s_kblk  TYPE kblk,
  t_kblp  TYPE STANDARD TABLE OF kblp,
  t_param TYPE STANDARD TABLE OF /thkr/t_wf_param.

SELECT * FROM /thkr/t_wf_param
  INTO TABLE t_param
  WHERE object = 'WF_FMRE_NO_WF'.

"Auslesen des Belegkopfs
SELECT SINGLE *
  FROM kblk
  INTO s_kblk
  WHERE belnr = object-key-documentnumber.
"Auslesen der Belegpositionen
SELECT *
FROM kblp
INTO TABLE t_kblp
WHERE belnr = object-key-documentnumber
AND blpos = object-key-documentitem.
IF sy-subrc <> 0.

  SELECT *
FROM kblp
INTO TABLE t_kblp
WHERE belnr = object-key-documentnumber.

ENDIF.
"Wenn Belegart = MB ( Mittelbindung ) oder MS (Mittelbindung Statisch)
IF s_kblk-blart = 'MB'.
  "Prüfen aller Positionen
  LOOP AT t_kblp ASSIGNING FIELD-SYMBOL(<fs_kblp>).
    "Wenn Feld "Fällig am (Jahreszahl)" grüßer
    "als das aktuelle Jahr ist, dann ist eine VE vorhandem
    IF <fs_kblp>-fdatk(4) > sy-datum(4).

      xsubrc = 5.

      EXIT.

    ENDIF.

  ENDLOOP.
  "Wenn eine Belegart nicht freigegeben werden muss, dann
  "steht sie in der Parameter Tabelle
ELSEIF t_param IS NOT INITIAL.
  READ TABLE t_param TRANSPORTING NO FIELDS
  WITH KEY value_von = s_kblk-blart.
  IF sy-subrc <> 0.
    xsubrc = 5.
  ENDIF.
ELSE. "NOT s_kblk-blart = 'MR'.

  xsubrc = 5.

ENDIF.

swc_set_element container 'XSUBRC' xsubrc.

end_method.

begin_method zsetvalueadjustementflag changing container.
DATA:
  l_t_flags TYPE fmres_t_setflag WITH HEADER LINE,
  s_kblk    TYPE kblk,
  t_param   TYPE STANDARD TABLE OF /thkr/t_wf_param,
  lv_no_wf  TYPE abap_bool.

"Auslesen des Belegkopfs
SELECT SINGLE *
  FROM kblk
  INTO s_kblk
  WHERE belnr = object-key-documentnumber.

SELECT * FROM kblp
  INTO TABLE @DATA(t_kblp)
  WHERE belnr = @object-key-documentnumber.

SELECT * FROM /thkr/t_wf_param
INTO TABLE t_param
WHERE object = 'WF_FMRE_NO_WF'.

READ TABLE t_param TRANSPORTING NO FIELDS
WITH KEY value_von = s_kblk-blart.
IF sy-subrc = 0.
  lv_no_wf = abap_true.
ENDIF.

IF s_kblk-blart = 'MB' OR lv_no_wf = abap_true.

  IF s_kblk-fexec IS INITIAL.

    swc_get_element container 'AdjNecessary' l_t_flags-flag.

    LOOP AT t_kblp ASSIGNING FIELD-SYMBOL(<lf_kblp>).

      IF <lf_kblp>-erlkz IS INITIAL.

        l_t_flags-belnr = object-key-documentnumber.
        l_t_flags-blpos = <lf_kblp>-blpos..
        APPEND l_t_flags.

      ENDIF.

    ENDLOOP.



* Funktionsbaustein aufrufen
    CALL FUNCTION 'FMRB_SWITCH_TO_AMOUNTDOCS'
      EXPORTING
        i_flg_commit  = 'X'
      TABLES
        t_flags       = l_t_flags
      EXCEPTIONS
        error_message = 01
        OTHERS        = 02.

    IF sy-subrc NE 0.
* Beleg war gesperrt
      IF sy-msgno = 149.
        exit_return 2002 sy-msgno object-key-documentnumber
                         sy-msgv2 sy-msgv3.
      ELSE.
        exit_return 2005 sy-msgid sy-msgno sy-msgv1 sy-msgv2.
      ENDIF.
    ENDIF.

  ENDIF.
ENDIF.
end_method.

begin_method zaddattachements changing container.
DATA:
  lv_XSUBRC TYPE syst-subrc,
  lV_WIID   TYPE swwwihead-wi_id,
  lv_objkey TYPE swo_typeid.
swc_get_element container 'V_WIID' lv_wiid.

MOVE object-key TO lv_objkey.

CALL FUNCTION '/THKR/WF_OBJ_RELAT_CREATE'
  EXPORTING
    iv_objkey                      = lv_objkey
    iv_objtype                     = 'FMRE'
    iv_wi_id                       = lv_wiid
  EXCEPTIONS
    relation_could_not_create      = 1
    error_reading_attachements     = 2
    error_reading_attachement_type = 3
    OTHERS                         = 4.
IF sy-subrc <> 0.
  lv_xsubrc = 2.
ENDIF.



swc_get_element container 'V_WIID' lv_wiid.
swc_set_element container 'XSUBRC' lv_XSUBRC.
end_method.

"Methode ADD_KAZ
"Diese Methode dient zum Einfügen des Kassenzeichens.
"Die Zuständigkeit liegt bei Olaf Tegtmeier - ZHM000000091
begin_method add_kaz changing container.

DATA: ls_kblk_kaz TYPE  /thkr/kblk_kaz.
DATA: lt_kblk_kaz TYPE TABLE OF /thkr/kblk_kaz.
*DATA: lv_belnr TYPE kblk-belnr.
*swc_get_element container  'ZBELNR'         lv_belnr.

SELECT * FROM /thkr/kblk_kaz INTO TABLE lt_kblk_kaz WHERE belnr = object-key-documentnumber.
LOOP AT lt_kblk_kaz INTO ls_kblk_kaz.
  UPDATE kblk SET xblnr = ls_kblk_kaz-xblnr
         WHERE belnr = ls_kblk_kaz-belnr.
  IF sy-subrc = 0.
    DELETE FROM /thkr/kblk_kaz WHERE belnr = ls_kblk_kaz-belnr.
  ENDIF.
ENDLOOP.

end_method.
