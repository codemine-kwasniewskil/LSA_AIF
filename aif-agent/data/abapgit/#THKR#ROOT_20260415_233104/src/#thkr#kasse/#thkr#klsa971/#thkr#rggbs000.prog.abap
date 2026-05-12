PROGRAM /thkr/rggbs000 .
*---------------------------------------------------------------------*
* Corrections/ repair
* wms092357 070703 Note 638886: template routines to be used for
*                  workaround to substitute bseg-bewar from bseg-xref1/2
*---------------------------------------------------------------------*
*                                                                     *
*   Substitutions: EXIT-Formpool for Uxxx-Exits                       *
*                                                                     *
*   This formpool is used by SAP for testing purposes only.           *
*                                                                     *
*   Note: If you define a new user exit, you have to enter your       *
*         user exit in the form routine GET_EXIT_TITLES.              *
*                                                                     *
*---------------------------------------------------------------------*
INCLUDE /thkr/fgbbgd00.
*INCLUDE fgbbgd00.              "Standard data types


*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*
*    PLEASE INCLUDE THE FOLLOWING "TYPE-POOL"  AND "TABLES" COMMANDS  *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM         *
TYPE-POOLS: gb002. " TO BE INCLUDED IN                       "wms092357
TABLES: bkpf,      " ANY SYSTEM THAT                         "wms092357
        bseg,      " HAS 'FI' INSTALLED                      "wms092357
        cobl,                                               "wms092357
        csks,                                               "wms092357
        anlz,                                               "wms092357
        glu1.                                               "wms092357
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*


*----------------------------------------------------------------------*
*       FORM GET_EXIT_TITLES                                           *
*----------------------------------------------------------------------*
*       returns name and title of all available standard-exits         *
*       every exit in this formpool has to be added to this form.      *
*       You have to specify a parameter type in order to enable the    *
*       code generation program to determine correctly how to          *
*       generate the user exit call, i.e. how many and what kind of    *
*       parameter(s) are used in the user exit.                        *
*       The following parameter types exist:                           *
*                                                                      *
*       TYPE                Description              Usage             *
*    ------------------------------------------------------------      *
*       C_EXIT_PARAM_NONE   Use no parameter         Subst. and Valid. *
*                           except B_RESULT                            *
*       C_EXIT_PARAM_FIELD  Use one field as param.  Only Substitution *
*       C_EXIT_PARAM_CLASS  Use a type as parameter  Subst. and Valid  *
*                                                                      *
*----------------------------------------------------------------------*
*  -->  EXIT_TAB  table with exit-name and exit-titles                 *
*                 structure: NAME(5), PARAM(1), TITEL(60)
*----------------------------------------------------------------------*
FORM get_exit_titles TABLES etab.

  DATA: BEGIN OF exits OCCURS 50,
          name(5)   TYPE c,
          param     LIKE c_exit_param_none,
          title(60) TYPE c,
        END OF exits.

  exits-name  = 'U100'.
  exits-param = c_exit_param_none.
  exits-title = TEXT-100.             "Cost center from CSKS
  APPEND exits.

  exits-name  = 'U101'.
  exits-param = c_exit_param_field.
  exits-title = TEXT-101.             "Cost center from CSKS
  APPEND exits.

* begin of insertion                                          "wms092357
  exits-name  = 'U200'.
  exits-param = c_exit_param_field.
  exits-title = TEXT-200.             "Cons. transaction type
  APPEND exits.                       "from xref1/2

* begin of insertion                                          "wms092357
  exits-name  = 'U300'.
  exits-param = c_exit_param_none.
  exits-title = TEXT-300.             "Cons. transaction type
  APPEND exits.                       "from xref1/2

  exits-name  = 'U400'.
  exits-param = c_exit_param_none.
  exits-title = TEXT-400.             "Cons. transaction type
  APPEND exits.                       "from xref1/2

  exits-name  = 'U500'.
  exits-param = c_exit_param_none.
  exits-title = TEXT-500.             "Cons. transaction type
  APPEND exits.                       "from xref1/2


* end of insertion                                            "wms092357


* end of insertion                                            "wms092357
************************************************************************
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*  EXITS-NAME  = 'U102'.
*  EXITS-PARAM = C_EXIT_PARAM_CLASS.
*  EXITS-TITLE = TEXT-102.             "Sum is used for the reference.
*  APPEND EXITS.


***********************************************************************
** EXIT EXAMPLES FROM PUBLIC SECTOR INDUSTRY SOLUTION
**
** PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINE
** TO ENABLE PUBLIC SECTOR EXAMPLE SUBSTITUTION EXITS
***********************************************************************
  INCLUDE /thkr/rggbs_ps_titles.
*  INCLUDE rggbs_ps_titles.

  REFRESH etab.
  LOOP AT exits.
    etab = exits.
    APPEND etab.
  ENDLOOP.

ENDFORM.                    "GET_EXIT_TITLES


* eject
*---------------------------------------------------------------------*
*       FORM U100                                                     *
*---------------------------------------------------------------------*
*       Reads the cost-center from the CSKS table .                   *
*---------------------------------------------------------------------*
FORM u100.

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*  SELECT * FROM CSKS
*            WHERE KOSTL EQ COBL-KOSTL
*              AND KOKRS EQ COBL-KOKRS.
*    IF CSKS-DATBI >= SY-DATUM AND
*       CSKS-DATAB <= SY-DATUM.
*
*      MOVE CSKS-ABTEI TO COBL-KOSTL.
*
*    ENDIF.
*  ENDSELECT.

ENDFORM.                                                    "U100

* eject
*---------------------------------------------------------------------*
*       FORM U101                                                     *
*---------------------------------------------------------------------*
*       Reads the cost-center from the CSKS table for accounting      *
*       area '0001'.                                                  *
*       This exit uses a parameter for the cost_center so it can      *
*       be used irrespective of the table used in the callup point.   *
*---------------------------------------------------------------------*
FORM u101 USING cost_center.

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*  SELECT * FROM CSKS
*            WHERE KOSTL EQ COST_CENTER
*              AND KOKRS EQ '0001'.
*    IF CSKS-DATBI >= SY-DATUM AND
*       CSKS-DATAB <= SY-DATUM.
*
*      MOVE CSKS-ABTEI TO COST_CENTER .
*
*    ENDIF.
*  ENDSELECT.

ENDFORM.                                                    "U101

* eject
*---------------------------------------------------------------------*
*       FORM U102                                                     *
*---------------------------------------------------------------------*
*       Inserts the sum of the posting into the reference field.      *
*       This exit can be used in FI for the complete document.        *
*       The complete data is passed in one parameter.                 *
*---------------------------------------------------------------------*


*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*FORM u102 USING bool_data TYPE gb002_015.
*DATA: SUM(10) TYPE C.
*
*    LOOP AT BOOL_DATA-BSEG INTO BSEG
*                    WHERE    SHKZG = 'S'.
*       BSEG-ZUONR = 'Test'.
*       MODIFY BOOL_DATA-BSEG FROM BSEG.
*       ADD BSEG-DMBTR TO SUM.
*    ENDLOOP.
*
*    BKPF-XBLNR = TEXT-001.
*    REPLACE '&' WITH SUM INTO BKPF-XBLNR.
*
*ENDFORM.


***********************************************************************
** EXIT EXAMPLES FROM PUBLIC SECTOR INDUSTRY SOLUTION
**
** PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINE
** TO ENABLE PUBLIC SECTOR EXAMPLE SUBSTITUTION EXITS
***********************************************************************
*INCLUDE rggbs_ps_forms.


*eject
* begin of insertion                                          "wms092357
*&---------------------------------------------------------------------*
*&      Form  u200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM u200 USING e_rmvct TYPE bseg-bewar.
  PERFORM xref_to_rmvct USING bkpf bseg 1 CHANGING e_rmvct.
ENDFORM.

FORM u300 USING e_xblnr TYPE xblnr.
  SELECT * FROM bsid_view INTO TABLE @DATA(lt_bsid)
                WHERE bukrs EQ @bseg-bukrs
                AND   xblnr EQ @e_xblnr
                AND   zlspr EQ @space.
  IF lt_bsid IS NOT INITIAL.
    SELECT * FROM bseg INTO TABLE @DATA(lt_bseg)
             FOR ALL ENTRIES IN @lt_bsid
             WHERE bukrs EQ @lt_bsid-bukrs
             AND   belnr EQ @lt_bsid-belnr
             AND   gjahr EQ @lt_bsid-gjahr
             AND   buzei EQ @lt_bsid-buzei.
  ENDIF.
  IF lt_bsid IS NOT INITIAL AND lt_bseg IS NOT INITIAL.
    LOOP AT lt_bseg ASSIGNING FIELD-SYMBOL(<ls_bseg>).
      <ls_bseg>-zlspr = 'L'. "Zahlsperre Lastschrifteinzug setzen.
    ENDLOOP.
    CALL FUNCTION 'CHANGE_DOCUMENT'
      TABLES
        t_bseg = lt_bseg.
  ENDIF.
  CLEAR: lt_bseg.

ENDFORM.

FORM u400.
*  DATA: lt_bseg TYPE TABLE OF bseg.
*  IF bseg-koart EQ 'D' AND bseg-sgtxt IS NOT INITIAL.
*    DATA(lv_sgtxt) = bseg-sgtxt.
*  ENDIF.
*  IF bseg-koart EQ 'D' AND bseg-sgtxt IS INITIAL AND lv_sgtxt IS NOT INITIAL.
*    bseg-sgtxt = lv_sgtxt.
*    APPEND bseg TO lt_bseg.
*
*    IF lt_bseg IS NOT INITIAL.
*      CALL FUNCTION 'CHANGE_DOCUMENT'
*        TABLES
*          t_bseg = lt_bseg[].
*    ENDIF.
*  ENDIF.
*
*  CLEAR: lv_sgtxt, lt_bseg.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  xref_to_rmvct
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM xref_to_rmvct
     USING    is_bkpf         TYPE bkpf
              is_bseg         TYPE bseg
              i_xref_field    TYPE i
     CHANGING c_rmvct         TYPE rmvct.

  DATA l_msgv TYPE symsgv.
  STATICS st_rmvct TYPE HASHED TABLE OF rmvct WITH UNIQUE DEFAULT KEY.

* either bseg-xref1 or bseg-xref2 must be used as source...
  IF i_xref_field <> 1 AND i_xref_field <> 2.
    MESSAGE x000(gk) WITH 'UNEXPECTED VALUE I_XREF_FIELD ='
      i_xref_field '(MUST BE = 1 OR = 2)' ''.
  ENDIF.
  IF st_rmvct IS INITIAL.
    SELECT trtyp FROM t856 INTO TABLE st_rmvct.
  ENDIF.
  IF i_xref_field = 1.
    c_rmvct = is_bseg-xref1.
  ELSE.
    c_rmvct = is_bseg-xref2.
  ENDIF.
  IF c_rmvct IS INITIAL.
    WRITE i_xref_field TO l_msgv LEFT-JUSTIFIED.
    CONCATENATE TEXT-m00 l_msgv INTO l_msgv SEPARATED BY space.
*   cons. transaction type is not specified => send an error message...
    MESSAGE e123(g3) WITH l_msgv.
*   Bitte geben Sie im Feld &1 eine Konsolidierungsbewegungsart an
  ENDIF.
* c_rmvct <> initial...
  READ TABLE st_rmvct TRANSPORTING NO FIELDS FROM c_rmvct.
  CHECK NOT sy-subrc IS INITIAL.
* cons. transaction type does not exist => send error message...
  WRITE i_xref_field TO l_msgv LEFT-JUSTIFIED.
  CONCATENATE TEXT-m00 l_msgv INTO l_msgv SEPARATED BY space.
  MESSAGE e124(g3) WITH c_rmvct l_msgv.
* KonsBewegungsart &1 ist ungültig (bitte Eingabe im Feld &2 korrigieren
ENDFORM.
* end of insertion                                            "wms092357

FORM u500.



ENDFORM.
