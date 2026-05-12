*****           Implementation of object type ZLSA_FMPSO           *****
INCLUDE <object>.
begin_data object. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
  " begin of private,
  "   to declare private attributes remove comments and
  "   insert private attributes here ...
  " end of private,
  BEGIN OF key,
    sourcecompanycode LIKE vbkpf-ausbk,
    requestnumber     LIKE vbkpf-lotkz,
  END OF key,
  isdauerao TYPE syst-ftype.
end_data object. " Do not change.. DATA is generated

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Methode: ZGetBasicData
"Beschreibung: Die Methode ermittelt die Kontierungselemente
"zur Anordnungsnummer.
"Eine Anordnung kann aus mehrere Belegen bestehen.
"Für jede auftretende Kombination der Kontierungselemente wird
"ein Eitnrag zurückgegeben.
"Eine Verknüpfung der Kontierungselemente zu den Belegnummern
"kann über die laufene Nummer in den Tabellen T_POS_DATA und T_POS
"hergestellt werden.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
begin_method zgetbasicdata changing container.
"Datendeklarationen
DATA:
  t_pos_data  TYPE /thkr/t_aord_pos_data,
  t_pos       TYPE /thkr/t_aord_pos,
  t_bkpf      TYPE STANDARD TABLE OF bkpf,
  t_bseg      TYPE STANDARD TABLE OF bseg,
  t_fvbkpf    LIKE fvbkpf      OCCURS 0 WITH HEADER LINE,
  t_fvbsec    LIKE fvbsec      OCCURS 0 WITH HEADER LINE,
  t_fvbseg    LIKE fvbseg      OCCURS 0 WITH HEADER LINE,
  t_fvbseg_2  LIKE fvbseg      OCCURS 0 WITH HEADER LINE,
  t_fvbset    LIKE fvbset      OCCURS 0 WITH HEADER LINE,
  v_lfdnr     TYPE lfdnr,
  t_psokpf    LIKE psokpf      OCCURS 0 WITH HEADER LINE,
  t_psoseg    LIKE psoseg      OCCURS 0 WITH HEADER LINE,
  t_psosec    LIKE psosec      OCCURS 0 WITH HEADER LINE,
  t_psoset    LIKE psoset      OCCURS 0 WITH HEADER LINE,
  v_isdauerao TYPE char1.

swc_get_property self 'IsDauerAo' v_isdauerao.
"Anordnung ist keine Daueranordnung
IF v_isdauerao IS INITIAL.
  "Belegköpfe der Anordnung ermitteln.
  SELECT  *
    FROM bkpf
    INTO TABLE t_bkpf
    WHERE bukrs = object-key-sourcecompanycode
    AND lotkz = object-key-requestnumber.

  IF sy-subrc = 0.
    "Verarbeitung pro Belegkopf
    LOOP AT t_bkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf>).
      "Ermitteln der Belege anhand der Belegnummern
      "aus den Belegköpfen
      CALL FUNCTION 'PRELIMINARY_POSTING_DOC_READ'
        EXPORTING
          belnr                   = <fs_bkpf>-belnr
          bukrs                   = object-key-sourcecompanycode
          gjahr                   = <fs_bkpf>-gjahr
        TABLES
          t_vbkpf                 = t_fvbkpf
          t_vbsec                 = t_fvbsec
          t_vbseg                 = t_fvbseg
          t_vbset                 = t_fvbset
*         T_VACSPLT               =
*         T_VSPLTWT               =
        EXCEPTIONS
          document_line_not_found = 1
          document_not_found      = 2
          input_incomplete        = 3
          OTHERS                  = 4.
      IF sy-subrc <> 0.
        "Wenn keine Daten ermittelt werden konnten,
        "dann selektiere Daten zu Belegen aus Tabelle BSEG
        CLEAR t_fvbseg.
        SELECT * FROM bseg INTO CORRESPONDING FIELDS OF TABLE t_fvbseg
          WHERE belnr = <fs_bkpf>-belnr
          AND bukrs = object-key-sourcecompanycode
          AND gjahr = <fs_bkpf>-gjahr.

      ENDIF.
      "Abspeichern der Daten in Hilfstabelle zur weiteren Verarbeitung
      APPEND LINES OF t_fvbseg TO t_fvbseg_2.
    ENDLOOP.
    "Verarbeitung der einzelnen Belegdaten

    LOOP AT t_fvbseg_2 ASSIGNING FIELD-SYMBOL(<fs_bseg>)
      WHERE
         fipos IS NOT INITIAL AND fistl IS NOT INITIAL AND
        gsber IS NOT INITIAL AND geber IS NOT INITIAL AND fkber IS NOT INITIAL.
      "Prüfen: Ist die Kombination der Kontierungselemente
      "bereits zwischengespeichert?
      READ TABLE t_pos_data WITH KEY
      gsber = <fs_bseg>-gsber
      fistl = <fs_bseg>-fistl
      fipos = <fs_bseg>-fipos
      fonds = <fs_bseg>-geber
      fkber = <fs_bseg>-fkber
      bukrs = object-key-sourcecompanycode
      ASSIGNING FIELD-SYMBOL(<fs_existing_pos_data>).
      "Wenn ja, dann erweitere Verknüpfungstabelle um die Belegnummer
      "und die laufende Nummer.
      IF sy-subrc = 0.
        APPEND INITIAL LINE TO t_pos ASSIGNING FIELD-SYMBOL(<fs_pos>).
        <fs_pos>-lfdnr = <fs_existing_pos_data>-lfdnr.
        <fs_pos>-belnr = <fs_bseg>-belnr.
        "Wenn nein, dann nehm Kontierugnselemente in Hilfstabelle auf und
        "erweitere Verknüpfungstabelle.
      ELSE.

        APPEND INITIAL LINE TO t_pos_data ASSIGNING FIELD-SYMBOL(<fs_pos_data>).
        <fs_pos_data>-gsber = <fs_bseg>-gsber.
        <fs_pos_data>-bukrs = object-key-sourcecompanycode.
        <fs_pos_data>-fistl = <fs_bseg>-fistl.
        <fs_pos_data>-fipos = <fs_bseg>-fipos.
        <fs_pos_data>-fonds = <fs_bseg>-geber.
        <fs_pos_data>-fkber = <fs_bseg>-fkber.
        v_lfdnr = v_lfdnr + 1.
        <fs_pos_data>-lfdnr = v_lfdnr.
        APPEND INITIAL LINE TO t_pos ASSIGNING <fs_pos>.
        <fs_pos>-lfdnr = v_lfdnr.
        <fs_pos>-belnr = <fs_bseg>-belnr.

      ENDIF.

      EXIT.

    ENDLOOP.
  ENDIF.
  "Wenn Anordnung eine Daueranordnung ist
ELSE.
  "Ermitteln von Belegkopf und Belegsegmenten der Daueranordnung
  CALL FUNCTION 'FI_PSO_FI_VIA_RECURRING'
    EXPORTING
      i_bukrs  = object-key-sourcecompanycode
      i_lotkz  = object-key-requestnumber
*     I_ITABKEY       =
    TABLES
      t_psokpf = t_psokpf
      t_vbkpf  = t_fvbkpf
      t_psoseg = t_psoseg
      t_psosec = t_psosec
      t_psoset = t_psoset.
  "Verarbeiteungder einzelnen Belege
  LOOP AT t_psoseg ASSIGNING FIELD-SYMBOL(<fs_psoseg>) "WHERE shkzg = 'S'.
     WHERE
         fipos IS NOT INITIAL AND fistl IS NOT INITIAL AND
        gsber IS NOT INITIAL AND geber IS NOT INITIAL AND fkber IS NOT INITIAL.
    "Prüfen: Ist die Kombination der Kontierungselemente
    "bereits zwischengespeichert?
    READ TABLE t_pos_data WITH KEY
    gsber = <fs_psoseg>-gsber
    fistl = <fs_psoseg>-fistl
    fipos = <fs_psoseg>-fipos
    fonds = <fs_psoseg>-geber
    fkber = <fs_psoseg>-fkber
    bukrs = object-key-sourcecompanycode
    ASSIGNING <fs_existing_pos_data>.
    "Wenn ja, dann erweitere Verknüpfungstabelle um die Belegnummer
    "und die laufende Nummer.
    IF sy-subrc = 0.

      APPEND INITIAL LINE TO t_pos ASSIGNING <fs_pos>.
      <fs_pos>-lfdnr = <fs_existing_pos_data>-lfdnr.
      <fs_pos>-belnr = <fs_psoseg>-itabkey.
      "Wenn nein, dann nehm Kontierugnselemente in Hilfstabelle auf und
      "erweitere Verknüpfungstabelle.
    ELSE.

      APPEND INITIAL LINE TO t_pos_data ASSIGNING <fs_pos_data>.
      <fs_pos_data>-gsber = <fs_psoseg>-gsber.
      <fs_pos_data>-bukrs = object-key-sourcecompanycode.
      <fs_pos_data>-fistl = <fs_psoseg>-fistl.
      <fs_pos_data>-fipos = <fs_psoseg>-fipos.
      <fs_pos_data>-fonds = <fs_psoseg>-geber.
      <fs_pos_data>-fkber = <fs_psoseg>-fkber.
      v_lfdnr = v_lfdnr + 1.
      <fs_pos_data>-lfdnr = v_lfdnr.
      APPEND INITIAL LINE TO t_pos ASSIGNING <fs_pos>.
      <fs_pos>-lfdnr = v_lfdnr.
      <fs_pos>-belnr = <fs_psoseg>-itabkey.

    ENDIF.

    EXIT.

  ENDLOOP.

ENDIF.
"Wenn keine Kontierugnselemente ermittelt werden konnten,
"dann gib Fehlermeldung aus.
IF t_pos_data IS INITIAL.

  MESSAGE e000(/thkr/wf).

ENDIF.
"Übergabe der Kontierungselemente und der Verknüpfungstabelle
"an den WF-Container
swc_set_table container 'T_POS_DATA' t_pos_data.
swc_set_table container 'T_POS' t_pos.

end_method.

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Methode: ZCheckApproved
"Beschreibung: Prüfen, ob alle Kontierungselement-Kombinationen
"freigegeben wurden.
"Rückgabewert: XSUBRC - 1 - Alle Workitems wurden freigegeben
"                       2 - Mindestens ein Workitem wurde abgelehnt
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

begin_method zcheckapproved changing container.
DATA:
  xsubrc     TYPE syst-subrc,
  t_pos_data LIKE /thkr/s_aord_pos_data OCCURS 0.

swc_get_table container 'T_POS_DATA' t_pos_data.

LOOP AT t_pos_data ASSIGNING FIELD-SYMBOL(<fs_pos_data>)
     WHERE freigegeben IS INITIAL.

  xsubrc = 8.
  EXIT.

ENDLOOP.

IF xsubrc <> 8 AND t_pos_data IS NOT INITIAL.

  xsubrc = 1.

ELSEIF t_pos_data IS INITIAL.

  MESSAGE e001(/thkr/wf).

ENDIF.

swc_set_element container 'XSUBRC' xsubrc.
end_method.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Methode: ZSetPartApproved
"Beschreibung: Nach Genehmigung einer Kontierugnselement-Kombination
"wird diese in der Hilfstabelle als genehmigt deklariert und der
"Bearbeiter dokumentiert.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
begin_method zsetpartapproved changing container.

DATA:
  i_actual_agent TYPE wfsyst-act_agent,
  s_pos_data     LIKE /thkr/s_aord_pos_data.
swc_get_element container 'S_POS_DATA' s_pos_data.
swc_get_element container 'I_ACTUAL_AGENT' i_actual_agent.

s_pos_data-freigegeben = 'X'.
s_pos_data-freigeber = i_actual_agent.

swc_set_element container 'S_POS_DATA' s_pos_data.
end_method.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Methode: ZErfasserKorrigieren
"Beschreibung: Die Methode korrigiert den Erfasser und den
"Vorerfasser der Anordnung, da diese Felder im Standart nicht
"korrekt belegt werden.
"Der Antragsteller der Anordnung wird als Vorerfasser eingetragen,
"ein Genehmiger als Erfasser.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
begin_method zerfasserkorrigieren changing container.
DATA:
  t_bkpf      TYPE STANDARD TABLE OF bkpf,
  t_pos_data  TYPE /thkr/t_aord_pos_data,
  t_pos       TYPE /thkr/t_aord_pos,
  i_initiator TYPE wfsyst-initiator,
  v_isdauerao TYPE char1,
  t_psokpf    TYPE STANDARD TABLE OF psokpf.
swc_get_element container 'I_INITIATOR' i_initiator.
swc_get_table container 'T_POS_DATA' t_pos_data.
swc_get_table container 'T_POS' t_pos.

swc_get_property self 'IsDauerAo' v_isdauerao.
"Wenn Anordnung keine Daueranordnung ist
IF v_isdauerao IS INITIAL.

  SELECT  *
    FROM bkpf
    INTO TABLE t_bkpf
    WHERE bukrs = object-key-sourcecompanycode
    AND lotkz = object-key-requestnumber.

  IF sy-subrc = 0.

    LOOP AT t_bkpf ASSIGNING FIELD-SYMBOL(<fs_beleg_kopf>).

      READ TABLE t_pos WITH KEY belnr = <fs_beleg_kopf>-belnr
      ASSIGNING FIELD-SYMBOL(<fs_pos_nr>).
      IF sy-subrc = 0.

        READ TABLE t_pos_data WITH KEY lfdnr = <fs_pos_nr>-lfdnr
        ASSIGNING FIELD-SYMBOL(<fs_freigeber>).
        IF sy-subrc = 0.

          <fs_beleg_kopf>-usnam = <fs_freigeber>-freigeber+2.
          <fs_beleg_kopf>-ppnam = i_initiator+2.

        ENDIF.

      ENDIF.

    ENDLOOP.

    UPDATE bkpf FROM TABLE t_bkpf.

  ENDIF.
  "Wenn Anordnung eine Daueranordnung ist
ELSE.

  SELECT *
    FROM psokpf
    INTO TABLE t_psokpf
     WHERE bukrs = object-key-sourcecompanycode
     AND lotkz = object-key-requestnumber.

  IF sy-subrc = 0.

    LOOP AT t_psokpf ASSIGNING FIELD-SYMBOL(<fs_dauerao_kopf>).

      READ TABLE t_pos WITH KEY belnr = <fs_dauerao_kopf>-itabkey
      ASSIGNING <fs_pos_nr>.
      IF sy-subrc = 0.

        READ TABLE t_pos_data WITH KEY lfdnr = <fs_pos_nr>-lfdnr
        ASSIGNING <fs_freigeber>.
        IF sy-subrc = 0.

          <fs_dauerao_kopf>-usnam = <fs_freigeber>-freigeber+2.
          <fs_dauerao_kopf>-ppnam = i_initiator+2.

        ENDIF.

      ENDIF.

    ENDLOOP.

    UPDATE psokpf FROM TABLE t_psokpf.

  ENDIF.

ENDIF.
end_method.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Methode: ZDauerAoWriteChangeDocs
"Beschreibung: Die Methode schreibt die Änderungsbelege für eine
"Daueranordnung, da diese im Standart nicht erfasst werden.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
begin_method zdaueraowritechangedocs changing container.
DATA:
  v_uname     TYPE wfsyst-act_agent,
  v_tcode     TYPE syst-tcode,
  t_fvbkpf    LIKE fvbkpf      OCCURS 0 WITH HEADER LINE,
  t_psokpf    LIKE psokpf      OCCURS 0 WITH HEADER LINE,
  t_psoseg    LIKE psoseg      OCCURS 0 WITH HEADER LINE,
  t_psosec    LIKE psosec      OCCURS 0 WITH HEADER LINE,
  t_psoset    LIKE psoset      OCCURS 0 WITH HEADER LINE,
  v_isdauerao TYPE char1,
  t_vbkpf     LIKE  vbkpf  OCCURS 0 WITH HEADER LINE,
  t_vbseg     LIKE  vbseg  OCCURS 0 WITH HEADER LINE,
  t_vbsec     LIKE  vbsec  OCCURS 0 WITH HEADER LINE,
  t_vbset     LIKE  vbset  OCCURS 0 WITH HEADER LINE,
  t_pso       LIKE pso02 OCCURS 0 WITH HEADER LINE,
  t_vbkpf_o   LIKE  vbkpf  OCCURS 0 WITH HEADER LINE,
  t_vbseg_o   LIKE  vbseg  OCCURS 0 WITH HEADER LINE,
  t_vbsec_o   LIKE  vbsec  OCCURS 0 WITH HEADER LINE,
  t_vbset_o   LIKE  vbset  OCCURS 0 WITH HEADER LINE,
  t_pso_o     LIKE pso02,
  lv_lines    LIKE sy-tabix.

swc_get_property self 'IsDauerAo' v_isdauerao.

swc_get_element container 'V_UNAME' v_uname.
swc_get_element container 'V_TCODE' v_tcode.
IF v_isdauerao = 'X'.

  SELECT * FROM psokpf INTO TABLE @DATA(lt_psokpf) WHERE
                              lotkz EQ @object-key-requestnumber AND
                              bukrs EQ @object-key-sourcecompanycode.
  IF sy-subrc IS INITIAL.
    READ TABLE lt_psokpf WITH KEY xdelt = space TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
*   alle geloeschten FI-Belege entfernen:
      DELETE lt_psokpf WHERE xdelt EQ 'X' AND bstat EQ space.
      DESCRIBE TABLE lt_psokpf LINES lv_lines.
      IF lv_lines EQ 0.
        RETURN.
      ENDIF.

    ENDIF.
  ELSE.
    RETURN.
  ENDIF.


  "Ermitteln der Anordnungsdaten
  CALL FUNCTION 'FI_PSO_FI_VIA_RECURRING'
    EXPORTING
      i_bukrs  = object-key-sourcecompanycode
      i_lotkz  = object-key-requestnumber
*     I_ITABKEY       =
    TABLES
      t_psokpf = t_psokpf
      t_vbkpf  = t_vbkpf
      t_psoseg = t_psoseg
      t_psosec = t_psosec
      t_psoset = t_psoset.
  "Verabeitung des Belegkopfs
  LOOP AT t_psokpf.
    CLEAR: t_vbkpf,
           t_vbseg,
           t_vbsec,
           t_vbset,
           t_pso.

    REFRESH: t_vbkpf,
             t_vbseg,
             t_vbsec,
             t_vbset,
             t_pso.

*     fill FI-Tables with one FI-document:
    LOOP AT t_psoseg WHERE lotkz   = t_psokpf-lotkz
                       AND   itabkey = t_psokpf-itabkey.
      MOVE-CORRESPONDING t_psoseg TO t_vbseg.
      APPEND t_vbseg.
    ENDLOOP.
    LOOP AT t_psosec WHERE lotkz   = t_psokpf-lotkz
                       AND   itabkey = t_psokpf-itabkey.
      MOVE-CORRESPONDING t_psosec TO t_vbsec.
      APPEND t_vbsec.
    ENDLOOP.
    LOOP AT t_psoset WHERE lotkz   = t_psokpf-lotkz
                       AND   itabkey = t_psokpf-itabkey.
      MOVE-CORRESPONDING t_psoset TO t_vbset.
      APPEND t_vbset.
    ENDLOOP.

    MOVE-CORRESPONDING t_psokpf TO t_pso.
    APPEND t_pso.

    MOVE-CORRESPONDING t_psokpf TO t_vbkpf.
    APPEND t_vbkpf.
    "Wenn Transaktion = Freigabetransaktion
    IF v_tcode = 'F8Q5'.

      t_pso_o     = t_pso.
      t_vbkpf_o[]   = t_vbkpf[].
      t_vbsec_o[]   = t_vbsec[].
      t_vbseg_o[]  = t_vbseg[].
      t_vbset_o[]   = t_vbset[].
      "Freigabekennzeichen des alten Belegs auf "V"
      "(vorerfasst) setzen.
      LOOP AT t_vbkpf_o.
        t_vbkpf_o-bstat = 'V'.
      ENDLOOP.
      t_pso_o-bstat = 'V'.

    ENDIF.
    "Änderugnsbeleg schreiben
    CALL FUNCTION '/THKR/WF_DAUERAO_CHANGE_WRITE'
      EXPORTING
        f_pso_old     = t_pso_o
        i_uname       = v_uname+2
        i_tcode       = v_tcode
      TABLES
        t_vbkpf_old   = t_vbkpf_o
        t_vbsec_old   = t_vbsec_o
        t_vbseg_old   = t_vbseg_o
        t_vbset_old   = t_vbset_o
        t_pso_new     = t_pso
        t_vbkpf_new   = t_vbkpf
        t_vbsec_new   = t_vbsec
        t_vbseg_new   = t_vbseg
        t_vbset_new   = t_vbset
      EXCEPTIONS
        error_message = 2
        OTHERS        = 3.

  ENDLOOP.

ENDIF.

end_method.
""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Attribut isdauerao
"Beschreibung: Ist die Anordnung eine Daueranordnung oder nicht?
""""""""""""""""""""""""""""""""""""""""""""""""""""""
get_property isdauerao changing container.
DATA:  t_bkpf     TYPE STANDARD TABLE OF bkpf.
"Wenn kein passender Beleg in der BKPF ermittelt werden kann,
"dann muss die Anordnung eine Daueranordnung sein
SELECT  *
  FROM bkpf
  INTO TABLE t_bkpf
  WHERE bukrs = object-key-sourcecompanycode
  AND lotkz = object-key-requestnumber.

IF sy-subrc <> 0.

  swc_set_element container 'IsDauerAo' 'X'.

ENDIF.

end_property.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Methode: ZCheckIfWorkflowNeeded
"Beschreibung: Prüfen, ob die Anordnung workflowrelevant ist.
"Die Tabelle /thkr/wfao_excep enthält alle Ausnahmen für Anorndungen
"Eine genauere Beschreibung der Tabelle befindet sich in der
"IT-Spezifikation EOL-002.
"Die Anordnung benötigt immer dann keine Freigabe,
"wenn für jeden Beleg der Anordnung mindestens eine Ausnahme
"gefunden wurde.
"Rückgabewert: XSUBRC - 0 - Anordnung muss freigegeben werden
"                       4 - Anordnung muss nicht freigegeben werden
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
begin_method zcheckifworkflowneeded changing container.
TYPES: BEGIN OF ty_list,
         belnr   TYPE belnr_d,
         no_need TYPE char1,
       END OF ty_list.

DATA:
  xsubrc           TYPE syst-subrc,
  t_bkpf           TYPE bkpf OCCURS 0 WITH HEADER LINE,
  t_psokpf         TYPE psokpf OCCURS 0 WITH HEADER LINE,
  t_wf_exceptions  TYPE STANDARD TABLE OF /thkr/wfao_excep,
  v_isdauerao      TYPE char1,
  v_tabname        TYPE tabname,
  o_tabline        TYPE REF TO data,
  v_condition      TYPE string,
  t_list           TYPE STANDARD TABLE OF ty_list,
  t_list_temp      TYPE STANDARD TABLE OF ty_list,
  s_list           TYPE ty_list,
  v_zahl           TYPE int4,
  v_aggregat       TYPE string,
  v_gjahr          TYPE gjahr,

  v_agg_int        TYPE p LENGTH 16 DECIMALS 2,
  v_compare_val    TYPE p LENGTH 16 DECIMALS 2,
  t_belnr          TYPE RANGE OF belnr_d,
  t_split          TYPE STANDARD TABLE OF string,
  v_operator       TYPE c LENGTH 2,
  v_pos_sum_excep  TYPE abap_bool,
  v_blart          TYPE blart,
  v_fname          TYPE char10,
  t_fields         TYPE STANDARD TABLE OF dfies,
  s_component      TYPE abap_componentdescr,
  t_component      TYPE abap_component_tab,
  lo_struct_descr  TYPE REF TO cl_abap_structdescr,
  lo_table_descr   TYPE REF TO cl_abap_tabledescr,
  f_ref_data_struc TYPE REF TO data,
  f_ref_data_table TYPE REF TO data.

FIELD-SYMBOLS:  <fs_tab> TYPE ANY TABLE.

swc_get_property self 'IsDauerAo' v_isdauerao.

IF v_isdauerao IS INITIAL.
  "Belege auslesen
  v_fname = 'BELNR'.

  SELECT  *
  FROM bkpf
  INTO TABLE  t_bkpf
  WHERE bukrs = object-key-sourcecompanycode
  AND lotkz = object-key-requestnumber.

  LOOP AT t_bkpf.

    APPEND INITIAL LINE TO t_list ASSIGNING FIELD-SYMBOL(<fs_new_list_line>).
    <fs_new_list_line>-belnr = t_bkpf-belnr.
    v_gjahr = t_bkpf-gjahr.

  ENDLOOP.

  t_list_temp = t_list.

  READ TABLE t_bkpf INDEX 1.
  v_blart = t_bkpf-blart.

ELSE.
  "Daueranordnung auslesen
  v_fname = 'ITABKEY'.

  SELECT * FROM psokpf INTO TABLE t_psokpf
    WHERE bukrs = object-key-sourcecompanycode
  AND lotkz = object-key-requestnumber.

  LOOP AT t_psokpf.

    APPEND INITIAL LINE TO t_list ASSIGNING <fs_new_list_line>.
    <fs_new_list_line>-belnr = t_psokpf-itabkey.
    v_gjahr = t_psokpf-gjahr.
  ENDLOOP.

  t_list_temp = t_list.
  READ TABLE t_psokpf INDEX 1.
  v_blart = t_psokpf-blart.

ENDIF.
"Ausnahmetabelle auselesen
SELECT * FROM /thkr/wfao_excep INTO TABLE t_wf_exceptions
WHERE
 ( belegart = v_blart AND bukrs = object-key-sourcecompanycode ) OR
  ( belegart = '*' AND bukrs = object-key-sourcecompanycode ) OR
  ( belegart = v_blart AND bukrs = '*' ) OR
  ( belegart = '*' AND bukrs = '*' ).
IF sy-subrc = 0.
  "Verarbeitung der Ausnahmen
  LOOP AT t_wf_exceptions ASSIGNING FIELD-SYMBOL(<fs_except>).

    v_tabname = <fs_except>-tabname.
    IF v_isdauerao IS INITIAL.

      IF <fs_except>-zpart = 'K'.

        IF <fs_except>-funktion IS INITIAL.

          v_condition = |bukrs = @object-key-sourcecompanycode AND lotkz = @object-key-requestnumber AND gjahr = @v_gjahr AND |.
          CONCATENATE v_condition <fs_except>-bedingung INTO v_condition.

        ELSE.

          v_condition = |bukrs = @object-key-sourcecompanycode AND lotkz = @object-key-requestnumber AND gjahr = @v_gjahr|.

        ENDIF.
*
      ELSEIF <fs_except>-zpart = 'P'.

        IF <fs_except>-funktion IS INITIAL.
          v_condition = |belnr in @t_belnr AND ausbk = @object-key-sourcecompanycode AND gjahr = @v_gjahr AND |.
          CONCATENATE v_condition <fs_except>-bedingung INTO v_condition.

        ELSE.

          v_condition = |belnr in @t_belnr AND ausbk = @object-key-sourcecompanycode AND gjahr = @v_gjahr|.

        ENDIF.
      ENDIF.

    ELSE.

      IF <fs_except>-funktion IS INITIAL.

        v_condition = |bukrs = @object-key-sourcecompanycode AND lotkz = @object-key-requestnumber AND gjahr = @v_gjahr AND |.
        CONCATENATE v_condition <fs_except>-bedingung INTO v_condition.

      ELSE.

        v_condition = |bukrs = @object-key-sourcecompanycode AND lotkz = @object-key-requestnumber AND gjahr = @v_gjahr|.

      ENDIF.

    ENDIF.

    REPLACE ALL OCCURRENCES OF '*' IN v_condition WITH '%'.

    CLEAR t_fields.
    UNASSIGN <fs_tab>.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = v_tabname
*       FIELDNAME      = ' '
*       LANGU          = SY-LANGU
*       LFIELDNAME     = ' '
       ALL_TYPES      = 'X'
*       GROUP_NAMES    = ' '
*       UCLEN          =
*       DO_NOT_WRITE   = ' '
* IMPORTING
*       X030L_WA       =
*       DDOBJTYPE      =
*       DFIES_WA       =
*       LINES_DESCR    =
      TABLES
        dfies_tab      = t_fields
*       FIXED_VALUES   =
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.

      CREATE DATA o_tabline TYPE TABLE OF (v_tabname).

      ASSIGN o_tabline->* TO <fs_tab>.

    ELSE.
      CLEAR t_component.
      LOOP AT t_fields ASSIGNING FIELD-SYMBOL(<fs_fields>).

        s_component-name = <fs_fields>-fieldname.
        s_component-type ?=  cl_abap_elemdescr=>describe_BY_NAME(
               p_name = <fs_fields>-rollname
          ).
        APPEND s_component TO t_component.
        CLEAR s_component.
      ENDLOOP.

      lo_struct_descr = cl_abap_structdescr=>create( t_component ).
      CREATE DATA f_ref_data_struc TYPE HANDLE lo_struct_descr.
      lo_table_descr = cl_abap_tabledescr=>create( lo_struct_descr ).
      CREATE DATA f_ref_data_table TYPE HANDLE lo_table_descr.

      ASSIGN f_ref_data_table->* TO <fs_tab>.

    ENDIF.
    IF <fs_tab> IS NOT ASSIGNED.
      CREATE DATA o_tabline TYPE TABLE OF (v_tabname).

      ASSIGN o_tabline->* TO <fs_tab>.
    ENDIF.

    IF <fs_Tab> IS ASSIGNED.
      """""""""""""""""""""""
      IF <fs_except>-zpart = 'P' AND v_isdauerao IS INITIAL.

        CLEAR t_belnr.
        LOOP AT t_bkpf.
          APPEND INITIAL LINE TO t_belnr ASSIGNING FIELD-SYMBOL(<fs_line_new>).
          <fs_line_new>-sign = 'I'.
          <fs_line_new>-option = 'EQ'.
          <fs_line_new>-low = t_bkpf-belnr.
        ENDLOOP.

      ENDIF.

      IF <fs_except>-funktion IS INITIAL.

        SELECT *
        FROM (v_tabname)
        WHERE (v_condition)
        INTO TABLE @<fs_tab>.
        IF sy-subrc = 0 AND <fs_except>-subrc = 0.

          LOOP AT <fs_tab> ASSIGNING FIELD-SYMBOL(<fs_tabline>).
            ASSIGN COMPONENT v_fname OF STRUCTURE <fs_tabline> TO FIELD-SYMBOL(<fs_belnr>).
            READ TABLE t_list WITH KEY belnr = <fs_belnr> ASSIGNING FIELD-SYMBOL(<fs_list_line>).
            IF sy-subrc = 0.
              <fs_list_line>-no_need = 'X'.
            ENDIF.
          ENDLOOP.

        ELSEIF sy-subrc = 0 AND <fs_except>-subrc = 4.

          LOOP AT <fs_tab> ASSIGNING <fs_tabline>.
            ASSIGN COMPONENT v_fname OF STRUCTURE <fs_tabline> TO <fs_belnr>.
            READ TABLE t_list_temp WITH KEY belnr = <fs_belnr> ASSIGNING <fs_list_line>.
            IF sy-subrc = 0.
              <fs_list_line>-no_need = 'X'.
            ENDIF.
          ENDLOOP.

          LOOP AT t_list_temp ASSIGNING <fs_list_line>.
            IF <fs_list_line>-no_need = 'X'.
              CLEAR <fs_list_line>-no_need.
            ELSE.
              READ TABLE t_list WITH KEY belnr = <fs_list_line>-belnr ASSIGNING FIELD-SYMBOL(<fs_l_l>).
              IF sy-subrc = 0.
                <fs_l_l>-no_need = 'X'.
              ENDIF.
            ENDIF.
          ENDLOOP.

        ELSEIF sy-subrc = 4 AND <fs_except>-subrc = 4.

          LOOP AT t_list ASSIGNING <fs_list_line>.
            <fs_list_line>-no_need = 'X'.
          ENDLOOP.
          v_pos_sum_excep ='X'.
        ENDIF.

      ELSE.

        CONCATENATE <fs_except>-funktion '(' INTO v_aggregat.
        CONCATENATE v_aggregat <fs_except>-fieldname ')' INTO v_aggregat SEPARATED BY ' '.

        SELECT SINGLE (v_aggregat) FROM (v_tabname) INTO @v_agg_int WHERE (v_condition).
        SPLIT <fs_except>-bedingung AT ' ' INTO TABLE t_split.
        v_operator = t_split[ 2 ].
        v_compare_val = t_split[ 3 ].
        "Vergleichoperatoren
        IF <fs_except>-subrc = 0.

          CASE v_operator.
            WHEN '<'.

              IF v_agg_int < v_compare_val.
                v_pos_sum_excep = 'X'.

              ENDIF.

            WHEN '>'.

              IF v_agg_int > v_compare_val.
                v_pos_sum_excep = 'X'.

              ENDIF.

            WHEN '='.

              IF v_agg_int = v_compare_val.
                v_pos_sum_excep = 'X'.

              ENDIF.

            WHEN '<='.

              IF v_agg_int <= v_compare_val.
                v_pos_sum_excep = 'X'.

              ENDIF.

            WHEN '>='.

              IF v_agg_int <= v_compare_val.
                v_pos_sum_excep = 'X'.

              ENDIF.

            WHEN '<>'.

              IF v_agg_int <> v_compare_val.
                v_pos_sum_excep = 'X'.

              ENDIF.

          ENDCASE.

        ELSEIF <fs_except>-subrc = 4.

          CASE v_operator.
            WHEN '<'.

              IF NOT v_agg_int < v_compare_val.
                v_pos_sum_excep = 'X'.

              ENDIF.

            WHEN '>'.

              IF NOT v_agg_int > v_compare_val.
                v_pos_sum_excep = 'X'.

              ENDIF.

            WHEN '='.

              IF NOT v_agg_int = v_compare_val.
                v_pos_sum_excep = 'X'.

              ENDIF.

            WHEN '<='.

              IF NOT v_agg_int <= v_compare_val.
                v_pos_sum_excep = 'X'.

              ENDIF.

            WHEN '>='.

              IF NOT v_agg_int <= v_compare_val.
                v_pos_sum_excep = 'X'.

              ENDIF.

            WHEN '<>'.

              IF NOT v_agg_int <> v_compare_val.
                v_pos_sum_excep = 'X'.

              ENDIF.

          ENDCASE.

        ENDIF.

      ENDIF.
      """"""""""""""""""
      IF v_pos_sum_excep = 'X'.
        xsubrc = 4.
        swc_set_element container 'XSUBRC' xsubrc.
        RETURN.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT t_list TRANSPORTING NO FIELDS WHERE no_need IS INITIAL.

    xsubrc = 0.
    EXIT.

  ENDLOOP.
  IF sy-subrc = 4 AND t_list IS NOT INITIAL.
    xsubrc = 4.
  ENDIF.

ELSE.
  xsubrc = 0.
ENDIF.

*xsubrc = 0.

swc_set_element container 'XSUBRC' xsubrc.

end_method.

begin_method zaddattachements changing container.
DATA:
  lv_xsubrc TYPE syst-subrc,
  lv_wiid   TYPE swwwihead-wi_id,
  lv_objkey TYPE swo_typeid.
swc_get_element container 'V_WIID' lv_wiid.
MOVE object-key TO lv_objkey.

CALL FUNCTION '/THKR/WF_OBJ_RELAT_CREATE'
  EXPORTING
    iv_objkey                      = lv_objkey
    iv_objtype                     = 'FMPSO'
    iv_wi_id                       = lv_wiid
  EXCEPTIONS
    relation_could_not_create      = 1
    error_reading_attachements     = 2
    error_reading_attachement_type = 3
    OTHERS                         = 4.
IF sy-subrc <> 0.
  lv_xsubrc = 2.
ENDIF.

swc_set_element container 'XSUBRC' lv_xsubrc.
end_method.

begin_method zgetmassbasicdata changing container.
TYPES: BEGIN OF lty_key,
         sourcecompanycode LIKE vbkpf-ausbk,
         requestnumber     LIKE vbkpf-lotkz,
       END OF lty_key.
DATA:
  t_aord      TYPE swc_object OCCURS 0,
  t_pos_data  TYPE /thkr/t_aord_pos_data,
  t_pos       TYPE /thkr/t_aord_pos,
  t_bkpf      TYPE STANDARD TABLE OF bkpf,
  t_bseg      TYPE STANDARD TABLE OF bseg,
  t_fvbkpf    LIKE fvbkpf      OCCURS 0 WITH HEADER LINE,
  t_fvbsec    LIKE fvbsec      OCCURS 0 WITH HEADER LINE,
  t_fvbseg    LIKE fvbseg      OCCURS 0 WITH HEADER LINE,
  t_fvbseg_2  LIKE fvbseg      OCCURS 0 WITH HEADER LINE,
  t_fvbset    LIKE fvbset      OCCURS 0 WITH HEADER LINE,
  v_lfdnr     TYPE lfdnr,
  t_psokpf    LIKE psokpf      OCCURS 0 WITH HEADER LINE,
  t_psoseg    LIKE psoseg      OCCURS 0 WITH HEADER LINE,
  t_psosec    LIKE psosec      OCCURS 0 WITH HEADER LINE,
  t_psoset    LIKE psoset      OCCURS 0 WITH HEADER LINE,
  lv_obj_key  TYPE swotobjid-objkey,
  ls_aord_key TYPE lty_key.

swc_get_table container 'T_AORD' t_aord.

LOOP AT t_aord ASSIGNING FIELD-SYMBOL(<fs_aord>).
  CLEAR: lv_obj_key, ls_aord_key,
  t_fvbseg_2[], t_fvbseg[], t_bkpf,
  t_fvbseg_2, t_fvbseg.

  swc_get_object_key <fs_aord> lv_obj_key.
  MOVE lv_obj_key TO ls_aord_key.

  IF ls_aord_key IS NOT INITIAL.

    """"""""""""""""""""""""""XXXXXXXXXXXXX
    "Belegköpfe der Anordnung ermitteln.
    SELECT  *
      FROM bkpf
      INTO TABLE t_bkpf
      WHERE bukrs = ls_aord_key-sourcecompanycode
      AND lotkz = ls_aord_key-requestnumber.

    IF sy-subrc = 0.
      "Verarbeitung pro Belegkopf
      LOOP AT t_bkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf>).
        CLEAR: t_fvbseg[], t_fvbseg.
        "Ermitteln der Belege anhand der Belegnummern
        "aus den Belegköpfen
        CALL FUNCTION 'PRELIMINARY_POSTING_DOC_READ'
          EXPORTING
            belnr                   = <fs_bkpf>-belnr
            bukrs                   = ls_aord_key-sourcecompanycode
            gjahr                   = <fs_bkpf>-gjahr
          TABLES
            t_vbkpf                 = t_fvbkpf
            t_vbsec                 = t_fvbsec
            t_vbseg                 = t_fvbseg
            t_vbset                 = t_fvbset
*           T_VACSPLT               =
*           T_VSPLTWT               =
          EXCEPTIONS
            document_line_not_found = 1
            document_not_found      = 2
            input_incomplete        = 3
            OTHERS                  = 4.
        IF sy-subrc <> 0.
          "Wenn keine Daten ermittelt werden konnten,
          "dann selektiere Daten zu Belegen aus Tabelle BSEG
          CLEAR: t_fvbseg, t_fvbseg_2[].
          SELECT * FROM bseg INTO CORRESPONDING FIELDS OF TABLE t_fvbseg
            WHERE belnr = <fs_bkpf>-belnr
            AND bukrs = ls_aord_key-sourcecompanycode
            AND gjahr = <fs_bkpf>-gjahr.

        ENDIF.
        "Abspeichern der Daten in Hilfstabelle zur weiteren Verarbeitung
        APPEND LINES OF t_fvbseg TO t_fvbseg_2.
      ENDLOOP.
      "Verarbeitung der einzelnen Belegdaten

      LOOP AT t_fvbseg_2 ASSIGNING FIELD-SYMBOL(<fs_bseg>)
        WHERE
         fipos IS NOT INITIAL AND fistl IS NOT INITIAL AND
        gsber IS NOT INITIAL AND geber IS NOT INITIAL AND fkber IS NOT INITIAL.

        "Prüfen: Ist die Kombination der Kontierungselemente
        "bereits zwischengespeichert?
        READ TABLE t_pos_data WITH KEY
        gsber = <fs_bseg>-gsber
        fistl = <fs_bseg>-fistl
        fipos = <fs_bseg>-fipos
        fonds = <fs_bseg>-geber
        fkber = <fs_bseg>-fkber
        bukrs = object-key-sourcecompanycode
        ASSIGNING FIELD-SYMBOL(<fs_existing_pos_data>).
        "Wenn ja, dann erweitere Verknüpfungstabelle um die Belegnummer
        "und die laufende Nummer.
        IF sy-subrc = 0.
          APPEND INITIAL LINE TO t_pos ASSIGNING FIELD-SYMBOL(<fs_pos>).
          <fs_pos>-lfdnr = <fs_existing_pos_data>-lfdnr.
          <fs_pos>-belnr = <fs_bseg>-belnr.
          "Wenn nein, dann nehm Kontierugnselemente in Hilfstabelle auf und
          "erweitere Verknüpfungstabelle.
        ELSE.

          APPEND INITIAL LINE TO t_pos_data ASSIGNING FIELD-SYMBOL(<fs_pos_data>).
          <fs_pos_data>-gsber = <fs_bseg>-gsber.
          <fs_pos_data>-bukrs = object-key-sourcecompanycode.
          <fs_pos_data>-fistl = <fs_bseg>-fistl.
          <fs_pos_data>-fipos = <fs_bseg>-fipos.
          <fs_pos_data>-fonds = <fs_bseg>-geber.
          <fs_pos_data>-fkber = <fs_bseg>-fkber.
          v_lfdnr = v_lfdnr + 1.
          <fs_pos_data>-lfdnr = v_lfdnr.
          APPEND INITIAL LINE TO t_pos ASSIGNING <fs_pos>.
          <fs_pos>-lfdnr = v_lfdnr.
          <fs_pos>-belnr = <fs_bseg>-belnr.

        ENDIF.
        "Nur eine Kontierungszeile wird für die Genehmigerfindung verwendet.
        EXIT.

      ENDLOOP.
    ENDIF.
    """"""""""""""XXXXXXXXXXXXXXXXXXXX
  ENDIF.

  IF t_pos_data IS NOT INITIAL.

    EXIT.

  ENDIF.

ENDLOOP.

IF t_pos_data IS INITIAL.

  MESSAGE 'Es konnte keine vollständige Kontierungszeile gefunden werden.' TYPE 'E'.

ENDIF.

swc_set_table container 'T_POS_DATA' t_pos_data.
swc_set_table container 'T_POS' t_pos.
end_method.

begin_method zmassrelease changing container.

TYPES: BEGIN OF lty_key,
         sourcecompanycode LIKE vbkpf-ausbk,
         requestnumber     LIKE vbkpf-lotkz,
       END OF lty_key.
DATA:
  t_aord       TYPE swc_object OCCURS 0,
  releasercode TYPE trwf_struc-app_rcode,
  lv_obj_key   TYPE swotobjid-objkey,
  ls_aord_key  TYPE lty_key.
DATA:
  l_subrc     LIKE sy-subrc,
  l_subrc2    LIKE sy-subrc,
  l_msgid     LIKE sy-msgid,
  l_msgno     LIKE sy-msgno,
  lt_pso      TYPE STANDARD TABLE OF psowf,
  lt_pso_all  TYPE STANDARD TABLE OF psowf,
  ls_status   TYPE fipso_doc_status,
  ls_exit     TYPE slis_exit_by_user,
  lv_cancel   TYPE abap_bool,
  l_app_rcode LIKE trwf_struc-app_rcode.

swc_get_table container 'T_AORD' t_aord.

""""""""""""""
LOOP AT t_aord ASSIGNING FIELD-SYMBOL(<fs_aord>).
  CLEAR: lv_obj_key, ls_aord_key.

  swc_get_object_key <fs_aord> lv_obj_key.
  MOVE lv_obj_key TO ls_aord_key.

  CALL FUNCTION 'FI_PSO_FMPSO_DOC_CHECK'
    EXPORTING
      i_bukrs = ls_aord_key-sourcecompanycode
      i_lotkz = ls_aord_key-requestnumber
    IMPORTING
      e_subrc = l_subrc
      e_msgno = l_msgno
      e_msgid = l_msgid.
  IF l_subrc <> 0.
    l_subrc2 = l_subrc.
    EXIT.
  ENDIF.

  """"""""""""
ENDLOOP.
IF l_subrc2 NE 0.
  CALL FUNCTION 'FI_PSO_RELEASE_BUTTON_SUPPRESS'
    EXPORTING
      i_suppress_button = 'X'.

  MESSAGE i369(fq) WITH object-key-requestnumber
                        object-key-sourcecompanycode
                        l_msgid l_msgno.
ELSE.
  CALL FUNCTION 'FI_PSO_RELEASE_BUTTON_SUPPRESS'
    EXPORTING
      i_suppress_button = ' '.
ENDIF.

LOOP AT t_aord ASSIGNING <fs_aord>.
  CLEAR: lv_obj_key, ls_aord_key.

  swc_get_object_key <fs_aord> lv_obj_key.
  MOVE lv_obj_key TO ls_aord_key.

  CALL FUNCTION 'FI_PSO_DOCS_FROM_LOTKZ_GET'
    EXPORTING
      i_lotkz   = ls_aord_key-requestnumber
      i_bukrs   = ls_aord_key-sourcecompanycode
*    IMPORTING
*     e_recurring = c_recurring
    TABLES
      t_psowf   = lt_pso
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

  IF lt_pso IS NOT INITIAL.
    APPEND LINES OF lt_pso TO lt_pso_all.
    CLEAR lt_pso.
  ENDIF.

ENDLOOP.

LOOP AT lt_pso_all ASSIGNING FIELD-SYMBOL(<fs_pso_all>).

  CALL FUNCTION 'ENQUEUE_EFBKPF'
    EXPORTING
      belnr = <fs_pso_all>-belnr
      gjahr = <fs_pso_all>-gjahr
      bukrs = <fs_pso_all>-ausbk.

ENDLOOP.


CALL FUNCTION 'FI_PSO_FMPSO_LIST_DISPLAY'
  EXPORTING
    i_activity    = '43'
  IMPORTING
    e_exit        = ls_exit
    e_f_status    = ls_status
  TABLES
    t_pso         = lt_pso_all
  EXCEPTIONS
    program_error = 1
    OTHERS        = 2.
* work item done?
IF    ls_exit        NE space       "ohne APP/REJ verlassen
   OR ls_status      EQ space       "kein Status bekannt
   OR sy-subrc        GT 0.           "Fehler aufgetreten

  lv_cancel = abap_true.

ENDIF.

CALL FUNCTION 'DEQUEUE_ALL'.

IF lv_cancel = 0.

  IF ls_status-all_docs_released = 'X'.
    l_app_rcode = '0001'.
  ELSEIF ls_status-all_docs_rejected = 'X'.
    l_app_rcode = '0002'.
  ELSE.
    exit_cancelled.
  ENDIF.

  swc_set_element container 'ReleaseRCode' l_app_rcode.
  swc_set_element container result l_app_rcode.
ELSE.

  exit_cancelled.

ENDIF.

end_method.

begin_method zmasspost changing container.
TYPES: BEGIN OF lty_key,
         sourcecompanycode LIKE vbkpf-ausbk,
         requestnumber     LIKE vbkpf-lotkz,
       END OF lty_key,

       BEGIN OF lty_result,
         include TYPE lty_key,
         result  TYPE char4,
       END OF lty_result.
DATA:
  lt_tfimsg      LIKE fimsg1 OCCURS 0,
  lt_tfimsg_temp LIKE fimsg1 OCCURS 0,
  t_aord         TYPE swc_object OCCURS 0,
  lv_obj_key     TYPE swotobjid-objkey,
  ls_aord_key    TYPE lty_key.
swc_get_table container 'T_AORD' t_aord.


LOOP AT t_aord ASSIGNING FIELD-SYMBOL(<fs_aord>).
  CLEAR: lv_obj_key, ls_aord_key.

  swc_get_object_key <fs_aord> lv_obj_key.
  MOVE lv_obj_key TO ls_aord_key.

  """""""""""""

  CALL FUNCTION 'FI_PSO_FMPSO_POST_ALL'
    EXPORTING
      i_lotkz     = ls_aord_key-requestnumber
      i_ausbk     = ls_aord_key-sourcecompanycode
    TABLES
      t_fimsg     = lt_tfimsg_temp
    EXCEPTIONS
      not_found   = 1001
      doc_locked  = 1002
      check_error = 1003
      post_error  = 1004
      OTHERS      = 01.
*
  CASE sy-subrc.
    WHEN 0.            " OK
    WHEN 1001.                                                " NOT_FOUND
*    EXIT_OBJECT_NOT_FOUND.
    WHEN 1002.         " DOC_LOCKED
*    EXIT_RETURN 1002 SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    WHEN 1003.         " CHECK_ERROR
*    EXIT_RETURN 1003 SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    WHEN 1004.         " POST_ERROR
*    SWC_SET_TABLE CONTAINER 'TFimsg' lt_TFIMSG.        "note2509403
*    EXIT_RETURN 1004 SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    WHEN OTHERS.       " to be implemented

  ENDCASE.

  """""""""""""


ENDLOOP.


swc_set_table container 'TFimsg' lt_tfimsg.
end_method.

begin_method zmassreleaseflagset changing container.
TYPES: BEGIN OF lty_key,
         sourcecompanycode LIKE vbkpf-ausbk,
         requestnumber     LIKE vbkpf-lotkz,
       END OF lty_key.
DATA:
  t_aord          TYPE swc_object OCCURS 0,
  o_aord          TYPE swc_object,
  lv_obj_key      TYPE swotobjid-objkey,
  ls_aord_key     TYPE lty_key,
  l_subrc         LIKE sy-subrc,
  l_subrc_char(3),
  l_t_fikey       TYPE fipso_fikey OCCURS 0 WITH HEADER LINE,
  l_recurring     LIKE boole-boole.

swc_get_table container 'T_AORD' t_aord.

LOOP AT t_aord ASSIGNING FIELD-SYMBOL(<fs_aord>).
  CLEAR: lv_obj_key, ls_aord_key.

  swc_get_object_key <fs_aord> lv_obj_key.
  MOVE lv_obj_key TO ls_aord_key.

  CLEAR: l_t_fikey, l_t_fikey[].
* get all FI docs
  CALL FUNCTION 'FI_PSO_FIKEY_DETERMINE'
    EXPORTING
      i_lotkz   = ls_aord_key-requestnumber
      i_bukrs   = ls_aord_key-sourcecompanycode
    TABLES
      t_fikey   = l_t_fikey
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc = 0.


    PERFORM fmpso_enqueue TABLES   l_t_fikey
                        USING    swo_%invoke
                                 ls_aord_key-requestnumber
                                 ls_aord_key-sourcecompanycode
                                 l_recurring
                        CHANGING l_subrc.

    CHECK l_subrc EQ 0.

*  check doc status and update database
    PERFORM releaseflag_set TABLES   l_t_fikey
                            USING    swo_%invoke
                                     ls_aord_key-requestnumber
                                     ls_aord_key-sourcecompanycode
                                     l_recurring
                            CHANGING l_subrc.
    IF l_subrc NE 0.
*      l_subrc_char = l_subrc.
*      swc_set_element container result l_subrc_char.
    ENDIF.

    PERFORM fmpso_dequeue TABLES   l_t_fikey
                          USING  ls_aord_key-requestnumber
                                 ls_aord_key-sourcecompanycode
                                 l_recurring.

  ENDIF.

ENDLOOP.

end_method.


*&---------------------------------------------------------------------*
*&      Form  RELEASEFLAG_SET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_T_FIKEY  text                                            *
*----------------------------------------------------------------------*
FORM releaseflag_set TABLES   u_t_fikey    TYPE      fipso_fikey_tab
                     USING    swo_%invoke  STRUCTURE swotinvoke
                              u_lotkz      LIKE      pso02-lotkz
                              u_bukrs      LIKE      pso02-bukrs
                              u_recurring  LIKE      boole-boole
                     CHANGING l_subrc      LIKE      sy-subrc.

  TABLES: vbkpf, psokpf.

  DATA: l_f_vbkpf LIKE vbkpf.

  IF u_recurring EQ space.
    LOOP AT u_t_fikey.
      CHECK l_subrc EQ 0.
      SELECT SINGLE * FROM  vbkpf      CLIENT SPECIFIED
             WHERE  mandt       = sy-mandt
             AND    ausbk       = u_t_fikey-bukrs
             AND    bukrs       = u_t_fikey-bukrs
             AND    belnr       = u_t_fikey-belnr
             AND    gjahr       = u_t_fikey-gjahr.

      IF sy-subrc NE 0.
        exit_object_not_found.
      ENDIF.

      PERFORM update_check USING    vbkpf
                           CHANGING l_subrc.

      IF l_subrc NE 0.
        EXIT.
      ENDIF.

      CALL FUNCTION 'PRELIMINARY_POSTING_REL_SET'
        EXPORTING
          belnr              = u_t_fikey-belnr
          bukrs              = u_t_fikey-bukrs
          gjahr              = u_t_fikey-gjahr
        EXCEPTIONS
          document_not_found = 01.
      IF sy-subrc NE 0.
        exit_object_not_found.
      ENDIF.

    ENDLOOP.

  ELSE.

    CHECK l_subrc EQ 0.
    SELECT SINGLE * FROM  psokpf      CLIENT SPECIFIED
           WHERE  mandt       = sy-mandt
           AND    lotkz       = u_lotkz
           AND    bukrs       = u_bukrs.

    IF sy-subrc NE 0.
      exit_object_not_found.
    ENDIF.

    MOVE-CORRESPONDING psokpf TO l_f_vbkpf.

    PERFORM update_check USING    l_f_vbkpf
                         CHANGING l_subrc.

    IF l_subrc NE 0.
      EXIT.
    ENDIF.

    CALL FUNCTION 'FI_FM_RECURRING_ORDER_REL_SET'
      EXPORTING
        i_lotkz            = u_lotkz
        i_bukrs            = u_bukrs
      EXCEPTIONS
        document_not_found = 1.
    IF sy-subrc NE 0.
      exit_object_not_found.
    ENDIF.

  ENDIF.

ENDFORM.                    " RELEASEFLAG_SET

*&---------------------------------------------------------------------*
*&      Form  UPDATE_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_SUBRC  text                                              *
*----------------------------------------------------------------------*
FORM update_check USING    l_f_vbkpf STRUCTURE vbkpf
                  CHANGING c_subrc LIKE sy-subrc.

  l_f_vbkpf-xfrge = 'X'.
  CALL FUNCTION 'PRELIMINARY_POSTING_POST_CHECK'
    EXPORTING
      i_vbkpf = l_f_vbkpf
    IMPORTING
      e_rc    = c_subrc
    EXCEPTIONS
      OTHERS  = 1.
  CASE c_subrc.
    WHEN 0.
    WHEN 8.
    WHEN OTHERS.
      c_subrc = 134.
      MESSAGE s134(fp) WITH l_f_vbkpf-upddt l_f_vbkpf-reldt
                            l_f_vbkpf-cputm l_f_vbkpf-reltm.
  ENDCASE.

ENDFORM.                    " UPDATE_CHECK

*&---------------------------------------------------------------------*
*&      Form  FMPSO_DEQUEUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_T_FIKEY  text                                            *
*----------------------------------------------------------------------*
FORM fmpso_dequeue   TABLES   u_t_fikey    TYPE  fipso_fikey_tab
                     USING    u_lotkz      LIKE pso02-lotkz
                              u_bukrs      LIKE pso02-bukrs
                              u_recurring  LIKE boole-boole.

  IF u_recurring EQ space.
    LOOP AT u_t_fikey WHERE bstat = 'V'.
*    dequeue all docs:
      CALL FUNCTION 'DEQUEUE_EFBKPF'
        EXPORTING
          belnr  = u_t_fikey-belnr
          bukrs  = u_t_fikey-bukrs
          gjahr  = u_t_fikey-gjahr
        EXCEPTIONS
          OTHERS = 1.

    ENDLOOP.

  ELSE.
    CALL FUNCTION 'DEQUEUE_EPSOKPF'
      EXPORTING
        lotkz  = u_lotkz
        bukrs  = u_bukrs
      EXCEPTIONS
        OTHERS = 3.

  ENDIF.
ENDFORM.                    " FMPSO_DEQUEUE

*&---------------------------------------------------------------------*
*&      Form  FMPSO_ENQUEUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_T_FIKEY  text                                            *
*      <--P_L_SUBRC  text                                              *
*----------------------------------------------------------------------*
FORM fmpso_enqueue  TABLES   u_t_fikey    TYPE  fipso_fikey_tab
                    USING    swo_%invoke  STRUCTURE swotinvoke
                             u_lotkz      LIKE pso02-lotkz
                             u_bukrs      LIKE pso02-bukrs
                             u_recurring  LIKE boole-boole
                    CHANGING c_subrc      LIKE sy-subrc.

  IF u_recurring EQ space.
    LOOP AT u_t_fikey WHERE bstat = 'V'.
*    enqueue all docs:
      CALL FUNCTION 'ENQUEUE_EFBKPF'
        EXPORTING
          belnr          = u_t_fikey-belnr
          bukrs          = u_t_fikey-bukrs
          gjahr          = u_t_fikey-gjahr
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2.

      c_subrc = sy-subrc.

      IF c_subrc EQ 1.
        exit_return 1001 u_t_fikey-belnr u_t_fikey-bukrs
                         u_t_fikey-gjahr space.
      ELSEIF c_subrc EQ 2.
        exit_return 1002 u_t_fikey-belnr u_t_fikey-bukrs
                         u_t_fikey-gjahr space.
      ENDIF.

    ENDLOOP.
  ELSE.
    CALL FUNCTION 'ENQUEUE_EPSOKPF'
      EXPORTING
        lotkz          = u_lotkz
        bukrs          = u_bukrs
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2.

    c_subrc = sy-subrc.

    IF c_subrc EQ 1.
      exit_return 1001 u_lotkz u_bukrs
                       u_t_fikey-gjahr space.
    ELSEIF c_subrc EQ 2.
      exit_return 1002 u_lotkz u_bukrs
                       u_t_fikey-gjahr space.
    ENDIF.
  ENDIF.

ENDFORM.                    " FMPSO_ENQUEUE

begin_method zpostf870 changing container.

DATA: v_isdauerao TYPE char1,
      lt_psowf    TYPE STANDARD TABLE OF psowf.

swc_get_property self 'IsDauerAo' v_isdauerao.

CALL FUNCTION 'FI_PSO_DOCS_FROM_LOTKZ_GET'
  EXPORTING
    i_lotkz   = object-key-requestnumber
    i_bukrs   = object-key-sourcecompanycode
* IMPORTING
*   E_RECURRING       =
  TABLES
    t_psowf   = lt_psowf
  EXCEPTIONS
    not_found = 1
    OTHERS    = 2.
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.


READ TABLE lt_psowf INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_psowf>).
IF sy-subrc = 0.

  CALL FUNCTION 'FI_PSO_PP_POST'
    EXPORTING
      i_lotkz          = object-key-requestnumber
      i_compy          = object-key-sourcecompanycode
      i_psotyp         = <fs_psowf>-psoty
      i_recurring      = v_isdauerao
      i_xdialog        = ' '
* TABLES
*     E_T_PSO4CLEAR    =
    EXCEPTIONS
      unknown_type     = 1
      cancelled        = 2
      no_key_specified = 3
      exit_all         = 4
      no_permission    = 5
      OTHERS           = 6.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  COMMIT WORK.

ELSE.

  MESSAGE 'BUCHUNGSFELHER' TYPE 'E'.

ENDIF.




end_method.

begin_method zadjustnebenforderung changing container.
DATA:
      xsubrc TYPE syst-subrc.

SELECT SINGLE gjahr
  FROM bkpf
  INTO @DATA(lv_gjahr)
  WHERE bukrs = @object-key-sourcecompanycode
  AND lotkz = @object-key-requestnumber.

*"" For Stundung:
*""  Check related Nebenforderung and add Mahnsperre = 5!
/thkr/cl_wf_fi=>set_mahnsperre_to_nf(
  lotkz = object-key-requestnumber
  bukrs = object-key-sourcecompanycode
  gjahr = lv_gjahr ).

swc_set_element container 'XSUBRC' xsubrc.
end_method.

begin_method zgetxref1sst changing container.
DATA: lv_xref1_hd TYPE xref1_hd,
      t_bkpf      TYPE STANDARD TABLE OF bkpf.

SELECT  *
  FROM bkpf
  INTO TABLE t_bkpf
  WHERE bukrs = object-key-sourcecompanycode
  AND lotkz = object-key-requestnumber.
IF sy-subrc = 0.

  LOOP AT t_bkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf>)
     WHERE xref1_hd IS NOT INITIAL.

    lv_xref1_hd = <fs_bkpf>-xref1_hd.
    EXIT.

  ENDLOOP.

ENDIF.

swc_set_element container 'V_XREF1_HD' lv_xref1_hd.
end_method.

begin_method zsetxref1sst changing container.
DATA:
  v_xref1_hd TYPE bkpf-xref1_hd,
  t_bkpf     TYPE STANDARD TABLE OF bkpf,
  lt_bseg    TYPE bseg_t,
  ls_bseg    TYPE bseg,
  lt_bkdf    TYPE STANDARD TABLE OF bkdf,
  lt_bsec    TYPE STANDARD TABLE OF bsec,
  lt_bsed    TYPE STANDARD TABLE OF bsed,
  lt_bset    TYPE STANDARD TABLE OF bset.

swc_get_element container 'V_XREF1_HD' v_xref1_hd.

IF v_xref1_hd IS NOT INITIAL.
  SELECT  *
  FROM bkpf
  INTO TABLE t_bkpf
  WHERE bukrs = object-key-sourcecompanycode
  AND lotkz = object-key-requestnumber.
  IF sy-subrc = 0.

    LOOP AT t_bkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf>).

      <fs_bkpf>-xref1_hd = v_xref1_hd.

    ENDLOOP.

    CALL FUNCTION 'CHANGE_DOCUMENT'
      TABLES
        t_bkdf = lt_bkdf
        t_bkpf = t_bkpf
        t_bsec = lt_bsec
        t_bsed = lt_bsed
        t_bseg = lt_bseg
        t_bset = lt_bset.
  ENDIF.


ENDIF.

end_method.
