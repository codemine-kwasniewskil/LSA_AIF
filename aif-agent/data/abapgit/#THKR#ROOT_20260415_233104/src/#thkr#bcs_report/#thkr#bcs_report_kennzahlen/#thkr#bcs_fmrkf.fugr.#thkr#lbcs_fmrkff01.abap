*----------------------------------------------------------------------*
***INCLUDE /THKR/LBCS_FMRKFF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  read_all_kfdata
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_all_kfdata TABLES t_keyfigs TYPE fmkf_kftab.


  DATA: l_f_kfds TYPE type_kfds.

* assign key figures <-> data sources


  SELECT * FROM /thkr/kf_kfdsrc                             " zcbb_bukf_kfdsrc - ennzahlen - Relation Kennzahl/Datenquellen
           INTO CORRESPONDING FIELDS OF TABLE g_t_kfds
           WHERE applic = con_applic.

* data sources
  SELECT * FROM /thkr/kf_dsrc                               " zcbb_bukf_dsrc - Kennzahlen - Datenquelle
           INTO CORRESPONDING FIELDS OF TABLE g_t_ds
           WHERE applic = con_applic.


* field groups
  SELECT * FROM /thkr/kf_fg_fld                            " zcbb_bukf_fg_fld - Kennzahlen - Felder der Feldgruppe (Tab: BUKF_FG_FIELD)
           INTO CORRESPONDING FIELDS OF TABLE g_t_fg
           WHERE applic = con_applic.


* if key figures are given through the interface, delete the
* ones we do not need
  CHECK NOT t_keyfigs[] IS INITIAL.
  SORT t_keyfigs BY keyfig.

  LOOP AT g_t_kfds INTO l_f_kfds.
    READ TABLE t_keyfigs WITH KEY keyfig = l_f_kfds-keyfig
                         BINARY SEARCH
                         TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      DELETE g_t_kfds.
    ENDIF.
  ENDLOOP.


*--------------------------------------------------------------------*
* Orig
*--------------------------------------------------------------------*
***  data: l_f_kfds type type_kfds.
***
**** assign key figures <-> data sources
***  select * from bukf_kfdsrc
***           into corresponding fields of table g_t_kfds
***           where applic = con_applic.
***
**** data sources
***  select * from bukf_dsrc into table g_t_ds
***           where applic = con_applic.
***
***
**** field groups
***  select * from bukf_fg_field into table g_t_fg
***           where applic = con_applic.
***
***
**** if key figures are given through the interface, delete the
**** ones we do not need
***  check not t_keyfigs[] is initial.
***  sort t_keyfigs by keyfig.
***
***  loop at g_t_kfds into l_f_kfds.
***    read table t_keyfigs with key keyfig = l_f_kfds-keyfig
***                         binary search
***                         transporting no fields.
***    if sy-subrc <> 0.
***      delete g_t_kfds.
***    endif.
***  endloop.
*--------------------------------------------------------------------*


ENDFORM.                               " read_all_kfdata
*&---------------------------------------------------------------------*
*&      Form  generate_kf_forms
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM generate_kf_forms USING u_gjahr TYPE gjahr.

  DATA: l_t_lines TYPE type_progtab,
        l_f_kfds  TYPE type_kfds.

* loop over key figures
  LOOP AT g_t_kfds INTO l_f_kfds.

    AT NEW keyfig.

*     Prüfung auf unzulässige Zeichen
      PERFORM check_keyfigure USING l_f_kfds-keyfig.

*     Vorbereitng des Codes für den Subroutine-Pool
      PERFORM generate_single_kf USING l_f_kfds-keyfig
                                       u_gjahr
                              CHANGING l_t_lines.
    ENDAT.

  ENDLOOP.

* generate form pool
  PERFORM generate_subroutines CHANGING g_formpool
                                        l_t_lines.

ENDFORM.                               " generate_kf_forms
*&---------------------------------------------------------------------*
*&      Form  generate_single_kf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_T_LINES  text
*      -->P_G_T_KEYFIGS  text
*----------------------------------------------------------------------*
FORM generate_single_kf USING u_keyfig  TYPE bukf_keyfig
                              u_gjahr   TYPE gjahr
                     CHANGING c_t_lines TYPE type_progtab.



  DATA: l_t_terms TYPE REF TO data,
        l_f_kfds  TYPE type_kfds,
        l_f_ds    TYPE bukf_dsrc,
        l_ref_kf  TYPE REF TO cl_bukf_kf.

  FIELD-SYMBOLS: <ft> TYPE STANDARD TABLE.


*--------------------------------------------------------------------*
* Orig
*--------------------------------------------------------------------*
**** get key figure to extract terms
***  CREATE OBJECT l_ref_kf
***    EXPORTING
***      im_applic = con_applic
***      im_keyfig = u_keyfig.
***
**** loop over all data sources
***  LOOP AT g_t_kfds INTO l_f_kfds WHERE keyfig = u_keyfig.
***
**** read datasource infos
***    READ TABLE g_t_ds INTO l_f_ds
***         WITH KEY datasource = l_f_kfds-datasource.
***    IF sy-subrc <> 0. RAISE data_fail. ENDIF.
***
**** get term tables
***    CREATE DATA l_t_terms TYPE (l_f_ds-tabletype).
***    ASSIGN l_t_terms->* TO <ft>.
***
***    PERFORM get_terms USING l_f_ds-datasource
***                            l_ref_kf
***                   CHANGING <ft>.
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* New
*--------------------------------------------------------------------*
* Berechnungsformel holen -> steht in der Tabelle ZCBBFMKF_REPTERM (für IST/Obligo)

* loop over all data sources
  LOOP AT g_t_kfds INTO l_f_kfds WHERE keyfig = u_keyfig.

** No creation for manual adding data:
  check l_f_kfds-datasource <> '0004'.

* read datasource infos
    READ TABLE g_t_ds INTO l_f_ds
         WITH KEY datasource = l_f_kfds-datasource.
    IF sy-subrc <> 0. RAISE data_fail. ENDIF.

* get term tables
    CREATE DATA l_t_terms TYPE (l_f_ds-tabletype).
    ASSIGN l_t_terms->* TO <ft>.
***
***    PERFORM get_terms USING l_f_ds-datasource
***                            l_ref_kf
***                   CHANGING <ft>.

    SELECT * FROM /thkr/kf_repterm                    " zcbbfmkf_repterm -  Kennzahlenterme fürs Reporting wg. neue Budgettabellen
         INTO CORRESPONDING FIELDS OF TABLE <ft>
      WHERE keyfig = u_keyfig.
    IF sy-subrc = 0.

* adapt the 2 year fields
      PERFORM adapt_yearfields USING u_gjahr
                                     l_f_ds
                            CHANGING <ft>.

* generate form for datasource
      PERFORM create_kf_ds_form USING l_f_kfds
                                      l_f_ds
                                      <ft>
                             CHANGING c_t_lines.

    ENDIF. " IF sy-subrc = 0.

  ENDLOOP.




ENDFORM.                               " generate_single_kf
*&---------------------------------------------------------------------*
*&      Form  get_terms
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_F_DS  text
*      <--P_L_T_TERMS  text
*      <--P_<FT>  text
*----------------------------------------------------------------------*
FORM get_terms USING u_datasource TYPE bukf_datasource
                     u_ref_kf TYPE REF TO cl_bukf_kf
            CHANGING c_t_terms TYPE STANDARD TABLE.

  DATA: l_ref_tm TYPE REF TO cl_bukf_terms.

* get terms
  CALL METHOD u_ref_kf->get_ref_terms
    EXPORTING
      im_datasource = u_datasource
    RECEIVING
      re_ref_terms  = l_ref_tm.

  CALL METHOD l_ref_tm->get_terms
    IMPORTING
      ex_terms = c_t_terms.

ENDFORM.                                                    " get_terms
*&---------------------------------------------------------------------*
*&      Form  get_ddic_infos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_U_F_DS_STRUCTURE  text
*----------------------------------------------------------------------*
FORM get_ddic_infos USING u_structure TYPE tabname
                 CHANGING c_maxlen_f  TYPE i
                          c_maxlen_v  TYPE i
                          c_t_dfies   TYPE type_dfiestab.

  STATICS: s_t_dfies TYPE type_dfiestab.

  DATA: l_fieldname      TYPE fieldname,
        l_t_dfies_native LIKE dfies OCCURS 0 WITH HEADER LINE,
        l_f_dfies        TYPE type_dfies,
        l_len            TYPE i,
        l_maxlen_v       TYPE i,
        l_maxlen_f       TYPE i.

* Daten im Puffer ?
  READ TABLE s_t_dfies WITH KEY tabname = u_structure
                       TRANSPORTING NO FIELDS.
  IF sy-subrc <> 0.

* Nametab einlesen
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname   = u_structure
      TABLES
        dfies_tab = l_t_dfies_native.

    LOOP AT l_t_dfies_native WHERE fieldname <> 'SIGN'
                               AND fieldname <> 'PERIOD_FROM'
                               AND fieldname <> 'PERIOD_TO'.

      l_f_dfies-tabname   = l_t_dfies_native-tabname.
      l_f_dfies-fieldname = l_t_dfies_native-fieldname.
      l_f_dfies-position  = l_t_dfies_native-position.
      l_f_dfies-leng      = l_t_dfies_native-leng.
      APPEND l_f_dfies TO c_t_dfies.
    ENDLOOP.

    APPEND LINES OF c_t_dfies TO s_t_dfies.
  ELSE.
    LOOP AT s_t_dfies INTO l_f_dfies WHERE tabname = u_structure.
      APPEND l_f_dfies TO c_t_dfies.
    ENDLOOP.
  ENDIF.

  SORT c_t_dfies BY position.

* Maximale Feldlänge bestimmen
  LOOP AT c_t_dfies INTO l_f_dfies.
    l_fieldname = l_f_dfies-fieldname.
    l_len = strlen( l_fieldname ).
    IF l_len > l_maxlen_f.
      l_maxlen_f = l_len.
    ENDIF.
    IF l_f_dfies-leng > l_maxlen_v.
      l_maxlen_v = l_f_dfies-leng.
    ENDIF.

  ENDLOOP.

  c_maxlen_f = l_maxlen_f.
  c_maxlen_v = l_maxlen_v.

ENDFORM.                               " get_ddic_infos
*&---------------------------------------------------------------------*
*&      Form  adapt_yearfields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_U_GJAHR  text
*      -->P_L_F_DS_DATASOURCE  text
*      <--P_<FT>  text
*----------------------------------------------------------------------*
FORM adapt_yearfields USING u_gjahr   TYPE gjahr
                            u_f_ds    TYPE bukf_dsrc
                   CHANGING u_t_terms TYPE STANDARD TABLE.

  DATA: l_fld_year   TYPE fieldname,
        l_fld_cfyear TYPE fieldname,
        l_f_term     TYPE REF TO data.

  FIELD-SYMBOLS: <fl>, <fy1>, <fy2>.

  CREATE DATA l_f_term TYPE (u_f_ds-structure).
  ASSIGN l_f_term->* TO <fl>.

  IF    u_f_ds-structure = '/THKR/SBCS_KF_S_FMAVCT_BCS'  " 'ZSBB_FMKF_S_FMAVCT_BCS'   Kennzahlen - Struktur für die Datenbanktabelle FMAVCT
     OR u_f_ds-structure = '/THKR/SBCS_KF_S_FMBDT_BCS '. " 'ZSBB_FMKF_S_FMBDT_BCS'.   Kennzahlen - Struktur für die Datenbanktabelle FMBDT

    PERFORM get_yearfields_bcs CHANGING l_fld_year
                                        l_fld_cfyear.

  ELSE.
    PERFORM get_yearfields CHANGING l_fld_year
                                    l_fld_cfyear.
  ENDIF.



  ASSIGN COMPONENT l_fld_year   OF STRUCTURE <fl> TO <fy1>.  " Geschäftsjahr
  ASSIGN COMPONENT l_fld_cfyear OF STRUCTURE <fl> TO <fy2>.  " Jahr der Kassenwirksamkeit



* In der Ist / Obligowerten aus der logischen Datenbank ist beim aktuellen Jahr sowohl das Geschäftsjahr
* als auch das Jahr der Kassenwirksamkeit identisch, wenn beides in das gleiche Jahr fällt.
*  Beispiel: GJAHR = 2021   -> cfyear = 2021.

* Bei den Budgetwerten ist es nicht so. In der BUDT und AVCT steht das aktuelle Geschäftsjahr (z.B. 2021) und im Jahr der
* Kassenwirksamkeit steht 0 (Initialwert = 0000).

* Beim Generieren der Kennzahl wird im Customizing geschaut und bei Null und leer jeweils das aktuelle GJahr eingesetzt.
* Für AVCT und BUDT ist das falsch


  LOOP AT u_t_terms INTO <fl>.

* Umsetzen des Geschäftsjahres
    PERFORM modify_year USING u_gjahr
                     CHANGING <fy1>.

* Umsetzen des Jahres der Kassenwirksamkeit

    IF   ( u_f_ds-structure = '/THKR/SBCS_KF_S_FMAVCT_BCS' AND <fy2> IS INITIAL )   " ZSBB_FMKF_S_FMAVCT_BCS - Kennzahlen - Struktur für die Datenbanktabelle FMAVCT
      OR ( u_f_ds-structure = '/THKR/SBCS_KF_S_FMBDT_BCS'  AND <fy2> IS INITIAL ) . " ZSBB_FMKF_S_FMBDT_BCS  - Kennzahlen - Struktur für die Datenbanktabelle FMBDT

      <fy2> = '0000'.
    ELSE.
      PERFORM modify_year USING u_gjahr
                       CHANGING <fy2>.
    ENDIF.

    MODIFY u_t_terms FROM <fl>.
  ENDLOOP.

ENDFORM.                               " adapt_yearfields
*&---------------------------------------------------------------------*
*&      Form  get_yearfields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_U_DATASOURCE  text
*      <--P_L_FLD_YEAR  text
*      <--P_L_FLD_CFYEAR  text
*----------------------------------------------------------------------*
FORM get_yearfields CHANGING c_fld_year   TYPE fieldname
                             c_fld_cfyear TYPE fieldname.

  c_fld_year   = 'GJAHR'.   " Geschäftsjahr
  c_fld_cfyear = 'GNJHR'.   " Jahr der Kassenwirksamkeit

ENDFORM.                               " get_yearfields


* DS20210824
*&---------------------------------------------------------------------*
*&      Form  GET_YEARFIELDS_BCS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_FLD_YEAR  text
*      <--P_L_FLD_CFYEAR  text
*----------------------------------------------------------------------*
FORM get_yearfields_bcs  CHANGING c_fld_year   TYPE fieldname
                                  c_fld_cfyear TYPE fieldname.


  c_fld_year   = 'RYEAR'.       " Geschäftsjahr
  c_fld_cfyear = 'CEFFYEAR_9'.  " Jahr der Kassenwirksamkeit

ENDFORM.



*&---------------------------------------------------------------------*
*&      Form  modify_year
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_U_GJAHR  text
*      <--P_<FY1>  text
*----------------------------------------------------------------------*
FORM modify_year USING VALUE(u_gjahr) TYPE gjahr
              CHANGING c_year TYPE c.

  DATA: l_ofs  TYPE i,
        l_sign TYPE c VALUE '+'.

  IF c_year(1) CO '+-'.
    l_sign = c_year(1).
    SHIFT c_year LEFT.
  ENDIF.

  IF c_year CO '0123456789 '.
    l_ofs = c_year.
  ENDIF.

  IF l_sign = '+'.
    ADD l_ofs TO u_gjahr.
  ELSE.
    SUBTRACT l_ofs FROM u_gjahr.
  ENDIF.

  IF c_year(1) = '*'.
    c_year = '*'.
    EXIT.
  ENDIF.

  c_year = u_gjahr.

ENDFORM.                               " modify_year
*&---------------------------------------------------------------------*
*&      Form  generate_subroutines
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_T_LINES  text
*      <--P_G_FORMPOOL  text
*----------------------------------------------------------------------*
FORM generate_subroutines CHANGING c_name     TYPE c
                                   c_t_lines  TYPE type_progtab.

  DATA: l_msg(240),
        l_name(8),
        l_msgid LIKE trmsg.

  DATA: l_f_line TYPE type_prog.

  l_f_line = 'PROGRAM SUBPOOLS.'.
  INSERT l_f_line INTO c_t_lines INDEX 1.

  GENERATE SUBROUTINE POOL c_t_lines NAME l_name
           MESSAGE l_msg MESSAGE-ID l_msgid.
  IF sy-subrc <> 0.
    MESSAGE e398(00) WITH l_msg space space space RAISING gen_error.
  ENDIF.

  c_name = l_name.

ENDFORM.                               " generate_subroutines
*&---------------------------------------------------------------------*
*&      Form  check_keyfigure
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_F_KFDS_KEYFIG  text
*----------------------------------------------------------------------*
FORM check_keyfigure  USING u_keyfig TYPE bukf_keyfig.

  DATA: l_keyfig TYPE bukf_keyfig.

  l_keyfig = u_keyfig.
  CONDENSE l_keyfig NO-GAPS.

  IF u_keyfig CA '^°"§&/()=?\ß[]{}.,²;<>|+~³#''' OR         "#EC *
     u_keyfig <> l_keyfig.
    MESSAGE e004(fmkw) WITH u_keyfig.
  ENDIF.

ENDFORM.                    " check_keyfigure
*&---------------------------------------------------------------------*
*&      Form  create_kf_ds_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_LINES  text
*      -->P_L_F_KFDS  text
*      -->P_L_F_DS  text
*      -->P_<FT>  text
*----------------------------------------------------------------------*
FORM create_kf_ds_form USING u_f_kfds   TYPE type_kfds
                             u_f_ds     TYPE bukf_dsrc
                             u_t_terms  TYPE STANDARD TABLE
                    CHANGING c_t_lines  TYPE type_progtab.


* table for if-statements: 1 = additive, 2 = subtractive
  DATA: l_t_lines_1 TYPE type_progtab,
        l_t_lines_2 TYPE type_progtab,
        l_f_line    TYPE type_prog.


  DATA: l_f_term        TYPE REF TO data,
        l_t_dfies       TYPE type_dfiestab,
        l_f_dfies       TYPE dfies,
        l_col_op        TYPE i,
        l_col_val       TYPE i,
        l_value(50)     TYPE c,
        l_maxlen_f      TYPE i,
        l_maxlen_v      TYPE i,
        l_flg_first_col TYPE boole-boole.

  CONSTANTS: con_pattern(10) TYPE c VALUE '''$*'''.


  FIELD-SYMBOLS: <fl>, <fs>, <ff>, <ft> TYPE STANDARD TABLE.


* create field symbol
  CREATE DATA l_f_term TYPE (u_f_ds-structure).
  ASSIGN l_f_term->* TO <fl>.


* form header
  PERFORM create_form_header USING u_f_kfds-keyfig
                                   u_f_ds
                          CHANGING c_t_lines.


* get ddic-infos
  PERFORM get_ddic_infos USING u_f_ds-structure
                      CHANGING l_maxlen_f
                               l_maxlen_v
                               l_t_dfies.


* check  for colums with same values in every row
  PERFORM check_values_col USING u_t_terms
                                 u_f_ds
                                 l_maxlen_f
                                 l_maxlen_v
                        CHANGING c_t_lines
                                 l_t_dfies.


  ASSIGN COMPONENT 'SIGN' OF STRUCTURE <fl> TO <fs>.

  l_col_op = l_maxlen_f + 18.
  l_col_val = l_col_op + 3.

* Loop über die Termtabelle
  LOOP AT u_t_terms INTO <fl>.

    IF <fs> = '+'.
      ASSIGN l_t_lines_1 TO <ft>.
    ELSE.
      ASSIGN l_t_lines_2 TO <ft>.
    ENDIF.

    l_flg_first_col = con_true.
    LOOP AT l_t_dfies INTO l_f_dfies.
      l_value = con_pattern.
      ASSIGN COMPONENT l_f_dfies-fieldname OF STRUCTURE <fl> TO <ff>.

      IF <ff> = '*' OR <ff> = '#'.
        CONTINUE.
      ENDIF.

      REPLACE '$*' WITH <ff> INTO l_value.

      CLEAR l_f_line.
* and/or
      IF l_flg_first_col = con_true.
        l_f_line+5 = 'OR '.
        CLEAR l_flg_first_col.
      ELSE.
        l_f_line+4 = 'AND '.
      ENDIF.

      l_f_line+8 = 'U_F_DATA-'.
      l_f_line+17 = l_f_dfies-fieldname.
      IF <ff> CA '*+#'.
        l_f_line+l_col_op  = 'cp'.
      ELSE.
        l_f_line+l_col_op  = '='.
      ENDIF.
      l_f_line+l_col_val = l_value.

      APPEND l_f_line TO <ft>.

    ENDLOOP.
* Wenn Term keine Bedingung hat -> Bedingung ist immer erfüllt....
    IF l_flg_first_col = con_true.
      CLEAR l_f_line.
      l_f_line+5 = 'OR 1 = 1'.
      APPEND l_f_line TO <ft>.
    ENDIF.

  ENDLOOP.


* close if statements
  PERFORM close_ifstmt CHANGING l_t_lines_1.
  PERFORM close_ifstmt CHANGING l_t_lines_2.

* create the amount lines from the right amount field
  PERFORM create_amount_line USING '+'
                                   u_f_kfds
                                   u_f_ds
                          CHANGING l_t_lines_1.

  PERFORM create_amount_line USING '-'
                                   u_f_kfds
                                   u_f_ds
                          CHANGING l_t_lines_2.


  APPEND LINES OF l_t_lines_1 TO c_t_lines.
  APPEND LINES OF l_t_lines_2 TO c_t_lines.
  l_f_line = 'ENDFORM.'.
  APPEND l_f_line TO c_t_lines.


ENDFORM.                    " create_kf_ds_form
*&---------------------------------------------------------------------*
*&      Form  create_form_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_U_F_KFDS_KEYFIG  text
*      -->P_U_F_DS  text
*      <--P_T_LINES[]  text
*----------------------------------------------------------------------*
FORM create_form_header  USING u_keyfig   TYPE bukf_keyfig
                               u_f_ds     TYPE bukf_dsrc
                      CHANGING c_t_lines  TYPE type_progtab.

  DATA: l_line TYPE type_prog.

  l_line = 'FORM CHK_'.
  WRITE u_f_ds-datasource TO l_line+9.
  l_line+13 = u_keyfig.
  APPEND l_line TO c_t_lines.
  CLEAR l_line.

  l_line+10 = 'USING U_F_DATA TYPE &'.
  REPLACE '&' WITH u_f_ds-seltable INTO l_line.
  APPEND l_line TO c_t_lines.
  CLEAR l_line.

  l_line+7 = 'CHANGING C_AMOUNT TYPE FM_KEYFIG_VAL.'.
  APPEND l_line TO c_t_lines.
  CLEAR l_line.

ENDFORM.                    " create_form_header
*&---------------------------------------------------------------------*
*&      Form  check_values_col
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_U_T_TERMS  text
*      -->P_L_T_DFIES  text
*      <--P_T_LINES[]  text
*----------------------------------------------------------------------*
FORM check_values_col USING u_t_terms   TYPE STANDARD TABLE
                            u_f_ds      TYPE bukf_dsrc
                            u_maxlen_f  TYPE i
                            u_maxlen_v  TYPE i
                   CHANGING c_t_lines   TYPE type_progtab
                            c_t_dfies   TYPE type_dfiestab.


  DATA: l_f_dfies   TYPE type_dfies,
        l_f_term    TYPE REF TO data,
        l_f_line    TYPE type_prog,
        l_value(50) TYPE c,
        l_col_op    TYPE i,
        l_col_val   TYPE i,
        l_cnt       TYPE i.

  CONSTANTS: con_pattern(10) TYPE c VALUE '''$*'''.

  FIELD-SYMBOLS: <fl>, <ff>.

  DESCRIBE TABLE u_t_terms LINES l_cnt.
  CHECK l_cnt > 1.

  CLEAR l_cnt.
  l_col_op  = u_maxlen_f + 18.
  l_col_val = l_col_op + 3.

* create field string
  CREATE DATA l_f_term TYPE (u_f_ds-structure).
  ASSIGN l_f_term->* TO <fl>.


* loop over all colums
  LOOP AT c_t_dfies INTO l_f_dfies.

    ASSIGN COMPONENT l_f_dfies-fieldname OF STRUCTURE <fl> TO <ff>.

    LOOP AT u_t_terms INTO <fl>.
      IF sy-tabix = 1.
        l_value = <ff>.
      ELSEIF <ff> <> l_value.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF l_value = <ff>.

      IF l_value = '*'.
        DELETE TABLE c_t_dfies FROM l_f_dfies.
        CONTINUE.
      ENDIF.

      ADD 1 TO l_cnt.
      IF l_cnt = 1.
        l_f_line+2 = 'CHECK '.
      ELSE.
        l_f_line+2 = '  AND '.
      ENDIF.

      l_value = con_pattern.
      REPLACE '$*' WITH <ff> INTO l_value.

      l_f_line+8 = 'U_F_DATA-'.
      l_f_line+17 = l_f_dfies-fieldname.
      IF <ff> CA '*+#'.
        l_f_line+l_col_op  = 'cp'.
      ELSE.
        l_f_line+l_col_op  = '='.
      ENDIF.
      l_f_line+l_col_val = l_value.

      APPEND l_f_line TO c_t_lines.
      DELETE TABLE c_t_dfies FROM l_f_dfies.
    ENDIF.

  ENDLOOP.

  IF l_cnt > 0.
    DESCRIBE TABLE c_t_lines LINES sy-tfill.
    READ TABLE c_t_lines INTO l_f_line INDEX sy-tfill.
    CONCATENATE l_f_line '.' INTO l_f_line.
    MODIFY c_t_lines FROM l_f_line INDEX sy-tfill.
  ENDIF.

ENDFORM.                    " check_values_col
*&---------------------------------------------------------------------*
*&      Form  close_ifstmt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_L_T_LINES_1  text
*----------------------------------------------------------------------*
FORM close_ifstmt CHANGING c_t_lines TYPE type_progtab.

  DATA: l_f_line TYPE type_prog,
        l_count  TYPE i.

  DESCRIBE TABLE c_t_lines LINES l_count.
  CHECK l_count > 0.

  READ TABLE c_t_lines INTO l_f_line INDEX 1.
  l_f_line+2(6) = 'IF    '.
  MODIFY c_t_lines FROM l_f_line INDEX 1.

  READ TABLE c_t_lines INTO l_f_line INDEX l_count.
  CONCATENATE l_f_line '.' INTO l_f_line.
  MODIFY c_t_lines FROM l_f_line INDEX l_count.

ENDFORM.                    " close_ifstmt
*&---------------------------------------------------------------------*
*&      Form  create_amount_line
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1861   text
*      -->P_U_F_KFDS  text
*      -->P_U_F_DS  text
*      <--P_L_T_LINES_1  text
*----------------------------------------------------------------------*
FORM create_amount_line USING u_sign  TYPE sign_cl
                            u_f_kfds  TYPE type_kfds
                            u_f_ds    TYPE bukf_dsrc
                   CHANGING c_t_lines TYPE type_progtab.


  DATA: l_f_line TYPE type_prog,
        l_f_fg   TYPE bukf_fg_field.


  CHECK NOT c_t_lines[] IS INITIAL.

  l_f_line = '   # U_F_DATA-<'.

  LOOP AT g_t_fg INTO l_f_fg
                 WHERE datasource = u_f_ds-datasource
                   AND fieldgroup = u_f_kfds-fieldgroup.

* check if no period values
    CHECK l_f_fg-maxperiod = 0.
    REPLACE '<' WITH l_f_fg-fieldname INTO l_f_line.

    IF ( u_sign = '-' AND l_f_fg-sign = '+' ) OR
       ( u_sign = '+' AND l_f_fg-sign = '-' ).
      l_f_fg-sign = '-'.
    ELSE.
      l_f_fg-sign = '+'.
    ENDIF.

    IF l_f_fg-sign = '-'.
      REPLACE '#' WITH 'SUBTRACT' INTO l_f_line.
      CONCATENATE l_f_line ' FROM C_AMOUNT.' INTO l_f_line.
    ELSE.
      REPLACE '#' WITH 'ADD' INTO l_f_line.
      CONCATENATE l_f_line ' TO C_AMOUNT.' INTO l_f_line.
    ENDIF.

    APPEND l_f_line TO c_t_lines.

    CLEAR l_f_line.
    l_f_line = '  ENDIF.'.
    APPEND l_f_line TO c_t_lines.
    EXIT.

  ENDLOOP.

ENDFORM.                    " create_amount_line
