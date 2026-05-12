*&---------------------------------------------------------------------*
* Gereon Koks  28.1.2026  T-Systems
*&---------------------------------------------------------------------*
* Analyse von AIF-Nachrichten.
*&---------------------------------------------------------------------*
*& Report /THKR/AIF_ANALYSE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/aif_analyse_polizei LINE-SIZE 1023.
*&---------------------------------------------------------------------*
TABLES: /aif/pers_qmsg.
*&---------------------------------------------------------------------*
TYPES:
  BEGIN OF ty_col,
    fieldname TYPE fieldname,
* das ist der längste Wert
    value(90),
    anz       TYPE i,
  END OF ty_col,

  BEGIN OF ty_col2,
    btyp      TYPE /thkr/aif_btyp,
    fieldname TYPE fieldname,
* das ist der längste Wert
    value(90),
    anz       TYPE i,
  END OF ty_col2,

  BEGIN OF ty_col3,
    btyp     TYPE /thkr/aif_btyp,
* Was für ein Fall ist aufgetreten ?
* a) 12_OEH gefüllt = 05_QUELLE
* b) 12_OEH nicht gefüllt aber 05_QUELLE gefüllt
* c) 12_OEH gefüllt <> 05_QUELLE
    fall(40),
    anz      TYPE i,
  END OF ty_col3,

* Belastungsvorankündigung
  BEGIN OF ty_col4,
* a)73_BDRUCKDATUM und 74_BDRUCKUSER beide gefüllt
* b)73_BDRUCKDATUM und 74_BDRUCKUSER beide leer
* c)73_BDRUCKDATUM gefüllt und 74_BDRUCKUSER leer
* d)73_BDRUCKDATUM leer und 74_BDRUCKUSER gefüllt
    fall(60),
    anz      TYPE i,
  END OF ty_col4,

  BEGIN OF ty_col5,
    xblnr    TYPE xblnr1,
    gjahr(4),
    blart    TYPE blart,
    anz      TYPE i,
  END OF ty_col5,

  BEGIN OF ty_col6,
    gjahr(4),
    blart    TYPE blart,
    anz      TYPE i,
  END OF ty_col6,

* Wie kombinieren die Fälle
  BEGIN OF ty_col7,
* absetzen
    d1_gjahr(4),
    d1_blart    TYPE blart,
    d5_gjahr(4),
    d5_blart    TYPE blart,
    d6_gjahr(4),
    d6_blart    TYPE blart,
    dr_gjahr(4),
    dr_blart    TYPE blart,
* nicht absetzen
    go_gjahr(4),
    go_blart    TYPE blart,
    mo_gjahr(4),
    mo_blart    TYPE blart,
    vo_gjahr(4),
    vo_blart    TYPE blart,
    bz_gjahr(4),
    bz_blart    TYPE blart,
    dg_gjahr(4),
    dg_blart    TYPE blart,
* Frage
    k1_gjahr(4),
    k1_blart    TYPE blart,
    dz_gjahr(4),
    dz_blart    TYPE blart,
* Sonst
    ds_gjahr(4),
    ds_blart    TYPE blart,
    anz         TYPE i,
  END OF ty_col7.
*&---------------------------------------------------------------------*
DATA: l_/aif/pers_qmsg  TYPE /aif/pers_qmsg,
      lt_/aif/pers_qmsg TYPE TABLE OF /aif/pers_qmsg,
      lr_appl_engine    TYPE REF TO /aif/if_application_engine,
      lv_sxmsguid       TYPE sxmsguid,
      ls_xmlparse       TYPE /aif/xmlparse_data,
      l_dd03l           TYPE dd03l,
      lv_01_btyp        LIKE /thkr/s_aif_bic_zeile-01_btyp,
      lv_05_quelle      LIKE /thkr/s_aif_bic_zeile-05_quelle,
      lv_12_oeh         LIKE /thkr/s_aif_bic_zeile-12_oeh,
      lv_73_bdruckdatum LIKE /thkr/s_aif_bic_zeile-73_bdruckdatum,
      lv_74_bdruckuser  LIKE /thkr/s_aif_bic_zeile-74_bdruckuser,
      ls_col            TYPE ty_col,
      lt_col            TYPE TABLE OF ty_col,
      ls_col2           TYPE ty_col2,
      lt_col2           TYPE TABLE OF ty_col2,
      ls_col3           TYPE ty_col3,
      lt_col3           TYPE TABLE OF ty_col3,
      ls_col4           TYPE ty_col4,
      lt_col4           TYPE TABLE OF ty_col4,
      ls_col5           TYPE ty_col5,
      lt_col5           TYPE TABLE OF ty_col5,
      ls_col6           TYPE ty_col6,
      lt_col6           TYPE TABLE OF ty_col6,
      ls_col7           TYPE ty_col7,
      lt_col7           TYPE TABLE OF ty_col7,
      lv_btyp           TYPE /thkr/aif_btyp,
      lv_ifdirection    TYPE /aif/ifdirection,
      lv_transform_data TYPE flag,
      lt_return         TYPE STANDARD TABLE OF bapiret2,
      lref_data_trg     TYPE REF TO data,
      lv_nr             TYPE i,
      l_bkpf            TYPE bkpf,
      lv_nr_nachricht   TYPE i,
      lv_nr_xblnr       TYPE i,
      lv_nr_bkpf        TYPE i,
      lv_nr_abs         TYPE i.
*&---------------------------------------------------------------------*
FIELD-SYMBOLS: <ls_src>    TYPE data,
               <ls_values> TYPE any,
               <ls_items>  TYPE any,
               <ls_item>   TYPE any,
               <lt_pso02>  TYPE any,
               <ls_pso02>  TYPE any,
               <xblnr>     TYPE any.
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b_sel WITH FRAME TITLE TEXT-001.
  PARAMETERS:     p_ns     TYPE /aif/pers_qmsg-ns.
*  PARAMETERS:     p_ifname TYPE /aif/pers_qmsg-ifname.
  SELECT-OPTIONS: p_ifname FOR /aif/pers_qmsg-ifname.
  PARAMETERS:     p_ifver  TYPE /aif/pers_qmsg-ifversion.
  SELECT-OPTIONS: p_date   FOR  /aif/pers_qmsg-create_date.
  SELECT-OPTIONS: p_time   FOR  /aif/pers_qmsg-create_time.
SELECTION-SCREEN END OF BLOCK b_sel.
*&---------------------------------------------------------------------*
*SELECTION-SCREEN BEGIN OF BLOCK b_ana WITH FRAME TITLE TEXT-002.
** SST Name ausgeben
*  PARAMETERS:     ak_pol AS CHECKBOX.
*SELECTION-SCREEN END OF BLOCK b_ana.
*&---------------------------------------------------------------------*
SELECT * FROM /aif/pers_qmsg INTO TABLE lt_/aif/pers_qmsg
  WHERE ns          =  p_ns
*    AND ifname      =  p_ifname
    AND ifname      IN p_ifname
    AND ifversion   =  p_ifver
    AND create_date IN p_date
    AND create_time IN p_time.

IF sy-subrc = 0.
*&---------------------------------------------------------------------*
  LOOP AT lt_/aif/pers_qmsg INTO l_/aif/pers_qmsg.
*&---------------------------------------------------------------------*
    ADD 1 TO lv_nr_nachricht.
    CLEAR lv_nr_xblnr.
    ULINE.
    WRITE: /1 'Nachricht:',
              lv_nr_nachricht,
              l_/aif/pers_qmsg-ns,
              l_/aif/pers_qmsg-ifname,
              l_/aif/pers_qmsg-ifversion,
              l_/aif/pers_qmsg-create_user,
              l_/aif/pers_qmsg-create_date,
              l_/aif/pers_qmsg-create_time.
*&---------------------------------------------------------------------*
* Die Engine wird zum Lesen der Nachrichten benötigt.
    lr_appl_engine = /aif/cl_aif_engine_factory=>get_engine(
          iv_ns            = l_/aif/pers_qmsg-ns
          iv_ifname        = l_/aif/pers_qmsg-ifname
          iv_ifversion     = l_/aif/pers_qmsg-ifversion
             ).

    lv_sxmsguid = l_/aif/pers_qmsg-msgguid.

* Nachrichten zur GUID lesen
    CALL METHOD lr_appl_engine->read_msg_from_persistency
      EXPORTING
        iv_msgguid  = lv_sxmsguid
        iv_ns       = l_/aif/pers_qmsg-ns
        iv_ifname   = l_/aif/pers_qmsg-ifname
        iv_ifver    = l_/aif/pers_qmsg-ifversion
      CHANGING
        cs_xmlparse = ls_xmlparse.

    ASSIGN ls_xmlparse-xi_data->* TO <ls_src>.
    ASSIGN COMPONENT 'VALUES' OF STRUCTURE <ls_src> TO <ls_values>.
    ASSIGN COMPONENT 'ITEMS' OF STRUCTURE <ls_values> TO <ls_items>.

    LOOP AT <ls_items> ASSIGNING <ls_item>.
      ASSIGN COMPONENT 'LT_PSO02' OF STRUCTURE <ls_item> TO <lt_pso02>.

      LOOP AT <lt_pso02> ASSIGNING <ls_pso02>.
        ASSIGN COMPONENT 'XBLNR' OF STRUCTURE <ls_pso02> TO <xblnr>.

        AT NEW <xblnr>.
          ADD 1 TO lv_nr_xblnr.
          CLEAR lv_nr_bkpf.
          IF NOT ls_col7 IS INITIAL.
            ls_col7-anz = 1.
            COLLECT ls_col7 INTO lt_col7.
          ENDIF.
          CLEAR ls_col7.
          ULINE.
        ENDAT.

        SELECT * FROM bkpf INTO l_bkpf
          WHERE xblnr = <xblnr>.

          ADD 1 TO lv_nr_bkpf.
          ADD 1 TO lv_nr_abs.

          WRITE: /1 lv_nr_nachricht,
                    lv_nr_xblnr,
                    lv_nr_bkpf,
                    lv_nr_abs,
                    'XBLNR:', l_bkpf-xblnr,
                    'BUKRS:', l_bkpf-bukrs,
                    'BELNR:', l_bkpf-belnr,
                    'LOTKZ:', l_bkpf-lotkz,
                    'GJAHR:', l_bkpf-gjahr,
                    'BLART:', l_bkpf-blart,
                    'BLDAT:', l_bkpf-bldat,
                    'BUDAT:', l_bkpf-budat,
                    'CPUDT:', l_bkpf-cpudt,
                    'CPUTM:', l_bkpf-cputm,
                    'USNAM:', l_bkpf-usnam.

          ls_col5-xblnr = l_bkpf-xblnr.
          ls_col5-gjahr = l_bkpf-gjahr.
          ls_col5-blart = l_bkpf-blart.
          ls_col5-anz = 1.
          COLLECT ls_col5 INTO lt_col5.

          ls_col6-gjahr = l_bkpf-gjahr.
          ls_col6-blart = l_bkpf-blart.
          ls_col6-anz = 1.
          COLLECT ls_col6 INTO lt_col6.

          CASE l_bkpf-blart.
* absetzen
            WHEN 'D1'.
              ls_col7-d1_gjahr = l_bkpf-gjahr.
              ls_col7-d1_blart = l_bkpf-blart.
            WHEN 'D5'.
              ls_col7-d5_gjahr = l_bkpf-gjahr.
              ls_col7-d5_blart = l_bkpf-blart.
            WHEN 'D6'.
              ls_col7-d6_gjahr = l_bkpf-gjahr.
              ls_col7-d6_blart = l_bkpf-blart.
            WHEN 'DR'.
              ls_col7-dr_gjahr = l_bkpf-gjahr.
              ls_col7-dr_blart = l_bkpf-blart.
* nicht absetzen
            WHEN 'GO'.
              ls_col7-go_gjahr = l_bkpf-gjahr.
              ls_col7-go_blart = l_bkpf-blart.
            WHEN 'MO'.
              ls_col7-mo_gjahr = l_bkpf-gjahr.
              ls_col7-mo_blart = l_bkpf-blart.
            WHEN 'VO'.
              ls_col7-vo_gjahr = l_bkpf-gjahr.
              ls_col7-vo_blart = l_bkpf-blart.
            WHEN 'BZ'.
              ls_col7-bz_gjahr = l_bkpf-gjahr.
              ls_col7-bz_blart = l_bkpf-blart.
            WHEN 'DG'.
              ls_col7-dg_gjahr = l_bkpf-gjahr.
              ls_col7-dg_blart = l_bkpf-blart.
* Frage
            WHEN 'K1'.
              ls_col7-k1_gjahr = l_bkpf-gjahr.
              ls_col7-k1_blart = l_bkpf-blart.
            WHEN 'DZ'.
              ls_col7-dz_gjahr = l_bkpf-gjahr.
              ls_col7-dz_blart = l_bkpf-blart.
            WHEN OTHERS.
              ls_col7-ds_gjahr = l_bkpf-gjahr.
              ls_col7-ds_blart = l_bkpf-blart.
          ENDCASE.
        ENDSELECT.
      ENDLOOP.
    ENDLOOP.

* den letzten einsammeln
    ls_col7-anz = 1.
    COLLECT ls_col7 INTO lt_col7.
    CLEAR ls_col7.
*&---------------------------------------------------------------------*
* über alle Nachrichten
  ENDLOOP.
*&---------------------------------------------------------------------*
ENDIF.
*&---------------------------------------------------------------------*
SORT lt_col5.

ULINE.
WRITE: /1 'Vorkommen der Kombinationen GJAHR/BLART je XBLNR'.

LOOP AT lt_col5 INTO ls_col5.
  AT NEW xblnr.
    ULINE.
  ENDAT.

  WRITE: /1 sy-tabix,
            ls_col5-xblnr,
            ls_col5-gjahr,
            ls_col5-blart,
            ls_col5-anz.
ENDLOOP.
*&---------------------------------------------------------------------*
SORT lt_col6.

ULINE.
WRITE: /1 'Absolutes Vorkommen einer Kombination GJAHR/BLART'.
ULINE.

LOOP AT lt_col6 INTO ls_col6.
  WRITE: /1 sy-tabix,
            ls_col6-gjahr,
            ls_col6-blart,
            ls_col6-anz.
ENDLOOP.
*&---------------------------------------------------------------------*
SORT lt_col7.

ULINE.
WRITE: /1 'Vorkommen der Auswahlen JAHR/BLART'.
ULINE.

LOOP AT lt_col7 INTO ls_col7.
  WRITE: /1 sy-tabix,
* absetzen
            '|',
            ls_col7-d1_gjahr,
            ls_col7-d1_blart,
            '|',
            ls_col7-d5_gjahr,
            ls_col7-d5_blart,
            '|',
            ls_col7-d6_gjahr,
            ls_col7-d6_blart,
            '|',
            ls_col7-dr_gjahr,
            ls_col7-dr_blart,
* nicht absetzen
            '|',
            ls_col7-go_gjahr,
            ls_col7-go_blart,
            '|',
            ls_col7-mo_gjahr,
            ls_col7-mo_blart,
            '|',
            ls_col7-vo_gjahr,
            ls_col7-vo_blart,
            '|',
            ls_col7-bz_gjahr,
            ls_col7-bz_blart,
            '|',
            ls_col7-dg_gjahr,
            ls_col7-dg_blart,
* Frage
            '|',
            ls_col7-k1_gjahr,
            ls_col7-k1_blart,
            '|',
            ls_col7-dz_gjahr,
            ls_col7-dz_blart,
* Rest
            '|',
            ls_col7-ds_gjahr,
            ls_col7-ds_blart,
            ls_col7-anz.
ENDLOOP.
*&---------------------------------------------------------------------*
