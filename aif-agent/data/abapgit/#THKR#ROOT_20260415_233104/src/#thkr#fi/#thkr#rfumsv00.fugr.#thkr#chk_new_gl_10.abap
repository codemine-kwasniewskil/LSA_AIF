FUNCTION /thkr/chk_new_gl_10.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_GJAHR) TYPE  BKK_R_GJAHR
*"     VALUE(IT_BELNR) TYPE  BKK_R_BELNR
*"     VALUE(IT_BUKRS) TYPE  ICL_BUKRS_RANGE
*"     REFERENCE(IT_GSBER) TYPE  BKK_R_GSBER
*"     REFERENCE(IT_PRCTR) TYPE  HRPP_SEL_PRCTR
*"     REFERENCE(IT_SEGMENT) TYPE  HRPP_SEL_SEGMT
*"  CHANGING
*"     REFERENCE(CT_NEW_GL) TYPE  STANDARD TABLE
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  CONSTANTS: lc_rldnr_0l      TYPE fagl_rldnr VALUE '0L'.

  DATA: lt_bseg_from_glflex TYPE fagl_t_bseg_ext,
        lt_glflex           TYPE fagl_t_bseg_ext,
        lv_anzahl_1         TYPE n,
        lv_anzahl_2         TYPE n.
  DATA: zeile  TYPE i.
  TYPES: BEGIN OF ty_belnr,
           bukrs TYPE bukrs,
           belnr TYPE belnr_d,
           gjahr TYPE gjahr,
         END OF ty_belnr.
  DATA: gt_belnr TYPE STANDARD TABLE OF ty_belnr.
  DATA: lr_gjahr TYPE  bkk_r_gjahr,
        lr_belnr TYPE  bkk_r_belnr,
        lr_bukrs TYPE  icl_bukrs_range.
  TYPES: BEGIN OF ty_glflex_temp,
           bukrs TYPE bukrs,
           gjahr TYPE gjahr,
           belnr TYPE belnr_d,
           buzei TYPE buzei,
         END OF ty_glflex_temp.
  DATA: lt_glflex_temp TYPE STANDARD TABLE OF ty_glflex_temp.
  DATA: lv_buzei              TYPE buzei.
  FIELD-SYMBOLS: <fs_table>   TYPE STANDARD TABLE.

*--------------------------------------------------------------------*
* falls keine Einschränkung auf
* - GSBER (Geschäftsbereich)
* - RPCTR (Profitcenter)
* - SEGMENT
* vorgenommen wurde -> Funktion verlassen
*--------------------------------------------------------------------*
  IF lines( it_gsber )    EQ 0 AND
     lines( it_prctr )    EQ 0 AND
     lines( it_segment )  EQ 0.
    EXIT.
  ENDIF.
  LOOP AT ct_new_gl  ASSIGNING FIELD-SYMBOL(<fs_new_gl>).
    ASSIGN COMPONENT 'PRCTR' OF STRUCTURE <fs_new_gl> TO FIELD-SYMBOL(<fs_comp_prctr>).
    IF sy-subrc NE 0 OR <fs_comp_prctr> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    ASSIGN COMPONENT 'SEGMENT' OF STRUCTURE <fs_new_gl> TO FIELD-SYMBOL(<fs_comp_segment>).
    IF sy-subrc NE 0 OR <fs_comp_segment> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    ASSIGN COMPONENT 'GSBER' OF STRUCTURE <fs_new_gl> TO FIELD-SYMBOL(<fs_comp_gsber>).
    IF sy-subrc NE 0 OR <fs_comp_gsber> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    ASSIGN COMPONENT 'BUZID' OF STRUCTURE <fs_new_gl> TO FIELD-SYMBOL(<fs_comp_buzid>).
    IF sy-subrc NE 0 OR <fs_comp_buzid> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    IF <fs_comp_buzid> = space OR <fs_comp_buzid> IS INITIAL.
      IF NOT <fs_comp_prctr> IN it_prctr
         OR NOT <fs_comp_gsber> IN it_gsber
         OR NOT <fs_comp_gsber> IN it_segment.
        DELETE ct_new_gl INDEX sy-tabix.
      ENDIF.
    ELSEIF  <fs_comp_buzid> EQ 'T'.

    ENDIF.
  ENDLOOP.
  UNASSIGN: <fs_new_gl>.
  IF lines( it_bukrs ) EQ 0.
    PERFORM prepare_select_data_10
            TABLES ct_new_gl
                   lr_bukrs
             USING 'BUKRS'.
  ELSE.
    lr_bukrs = it_bukrs.
  ENDIF.

  IF lines( it_belnr ) EQ 0.
    PERFORM prepare_select_data_10
            TABLES ct_new_gl
                   lr_belnr
             USING 'BELNR'.
  ELSE.
    lr_belnr = it_belnr.
  ENDIF.

  IF lines( it_gjahr ) EQ 0.
    PERFORM prepare_select_data_10
            TABLES ct_new_gl
                   lr_gjahr
             USING 'GJAHR'.
  ELSE.
    lr_gjahr = it_gjahr.
  ENDIF.
  SELECT DISTINCT bukrs,belnr,gjahr
    INTO TABLE @gt_belnr                                    "hch100522
    FROM bseg
    WHERE gjahr IN @lr_gjahr
      AND bukrs IN @lr_bukrs
      AND belnr IN @lr_belnr
    ORDER BY bukrs,belnr,gjahr.
*--------------------------------------------------------------------*
* FAGLFLEXA/ACDOCA Daten bestimmen
*--------------------------------------------------------------------*
  LOOP AT gt_belnr ASSIGNING FIELD-SYMBOL(<fs_belnr>).      "gaa180122
    CALL METHOD cl_fins_get_bseg=>map_acdoca_to_bseg_ext
      EXPORTING
        iv_bukrs    = <fs_belnr>-bukrs          "hch100522
*       iv_belnr    = <fs_belnr>-low                   "gaa180122
        iv_belnr    = <fs_belnr>-belnr                  "gaa180122
        iv_gjahr    = <fs_belnr>-gjahr          "hch100522
        iv_rldnr    = lc_rldnr_0l
      IMPORTING
        et_bseg_ext = lt_bseg_from_glflex
      EXCEPTIONS
        not_found   = 1.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.
************************************************************
*** Beginn Einfügung Gartner 13.01.2023   "gaa130123     ***
************************************************************
    LOOP AT lt_bseg_from_glflex ASSIGNING FIELD-SYMBOL(<fs_glflex>).
      INSERT CORRESPONDING #( <fs_glflex> ) INTO TABLE lt_glflex_temp.

      IF <fs_glflex>-koart     = 'D' OR
         <fs_glflex>-koart     = 'K' OR
         <fs_glflex>-prctr     NOT IN it_prctr  OR
         <fs_glflex>-gsber     NOT IN it_gsber  OR
         <fs_glflex>-segment   NOT IN it_segment.
        DELETE lt_bseg_from_glflex INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
    UNASSIGN: <fs_glflex>.

    DESCRIBE TABLE lt_bseg_from_glflex LINES zeile.
    IF zeile = 0.
      CONTINUE.
    ENDIF.
************************************************************
*** Ende   Einfügung Gartner 13.01.2023   "gaa130123     ***
************************************************************
*************************************************************
    APPEND LINES OF lt_bseg_from_glflex TO lt_glflex.
    REFRESH: lt_bseg_from_glflex.

  ENDLOOP.

  DATA: lv_prctr TYPE prctr.
*--------------------------------------------------------------------*
* Bereinigen der Tabelle
*--------------------------------------------------------------------*
  IF lines( lt_glflex ) EQ 0.
    REFRESH: ct_new_gl.
  ENDIF.

  LOOP AT ct_new_gl  ASSIGNING FIELD-SYMBOL(<cs_new_gl>).
    DATA(lv_tabix) = sy-tabix.

    ASSIGN COMPONENT 'MWSKZ' OF STRUCTURE <cs_new_gl> TO FIELD-SYMBOL(<fs_comp_mwskz>).
    IF sy-subrc NE 0 OR <fs_comp_mwskz> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.

    ASSIGN COMPONENT 'BELNR' OF STRUCTURE <cs_new_gl> TO FIELD-SYMBOL(<fs_comp_belnr>).
    IF sy-subrc NE 0 OR <fs_comp_belnr> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.

    IF <fs_comp_mwskz> = 'U1' OR <fs_comp_mwskz> = 'U2' OR <fs_comp_mwskz> = 'V7'.

      ASSIGN COMPONENT 'BUZEI' OF STRUCTURE <cs_new_gl> TO FIELD-SYMBOL(<fs_comp_buzei>).
      IF sy-subrc NE 0 OR <fs_comp_buzei> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <cs_new_gl> TO FIELD-SYMBOL(<fs_comp_bukrs>).
      IF sy-subrc NE 0 OR <fs_comp_buzei> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT 'GJAHR' OF STRUCTURE <cs_new_gl> TO FIELD-SYMBOL(<fs_comp_gjahr>).
      IF sy-subrc NE 0 OR <fs_comp_buzei> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT 'TXGRP' OF STRUCTURE <cs_new_gl> TO FIELD-SYMBOL(<fs_comp_txgrp>).
      IF sy-subrc NE 0 OR <fs_comp_buzei> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      SELECT SINGLE buzei FROM bseg INTO lv_buzei
        WHERE bukrs = <fs_comp_bukrs> AND
              belnr = <fs_comp_belnr> AND
              gjahr = <fs_comp_gjahr> AND
              txgrp = <fs_comp_txgrp>.

      READ TABLE lt_glflex TRANSPORTING NO FIELDS WITH KEY belnr = <fs_comp_belnr>
                                                           mwskz = <fs_comp_mwskz>
                                                           buzei = lv_buzei.

      IF sy-subrc NE 0.
        DELETE ct_new_gl INDEX lv_tabix.
      ENDIF.

    ELSE.

      READ TABLE lt_glflex TRANSPORTING NO FIELDS WITH KEY belnr = <fs_comp_belnr>
                                                           mwskz = <fs_comp_mwskz>.

      IF sy-subrc NE 0.
        DELETE ct_new_gl INDEX lv_tabix.
      ENDIF.

    ENDIF.

  ENDLOOP.
  UNASSIGN: <cs_new_gl>
          .

  CHECK lines( lt_glflex ) GT 0.
  CHECK lines( ct_new_gl ) GT 0.

*--------------------------------------------------------------------*
* nach BUKRS prüfen
*--------------------------------------------------------------------*
  CLEAR: lv_tabix.
  LOOP AT ct_new_gl  ASSIGNING FIELD-SYMBOL(<cs_new_gl2>).
    lv_tabix = sy-tabix.

    ASSIGN COMPONENT 'HWBAS' OF STRUCTURE <cs_new_gl2> TO FIELD-SYMBOL(<fs_hwbas>).
    IF sy-subrc NE 0 OR <fs_hwbas> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    ASSIGN COMPONENT 'FWBAS' OF STRUCTURE <cs_new_gl2> TO FIELD-SYMBOL(<fs_fwbas>).
    IF sy-subrc NE 0 OR <fs_fwbas> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.

    ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <cs_new_gl2> TO FIELD-SYMBOL(<fs_comp>).
    IF sy-subrc NE 0 OR <fs_comp> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.

    LOOP AT lt_glflex ASSIGNING <fs_glflex>.
      IF abs( <fs_glflex>-bukrs ) EQ abs( <fs_comp> ).
        DATA(lv_exist) = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_exist EQ abap_false.
      DELETE ct_new_gl INDEX lv_tabix.
    ENDIF.
    CLEAR: lv_exist
         .
  ENDLOOP.

  CHECK lines( ct_new_gl ) GT 0.

  LOOP AT ct_new_gl ASSIGNING <cs_new_gl2>.
    lv_tabix = sy-tabix.
    ASSIGN COMPONENT 'BUZID' OF STRUCTURE <cs_new_gl2> TO FIELD-SYMBOL(<fs_buzid>).
    IF sy-subrc NE 0 OR <fs_buzid> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
**** Bei Buchungszeilen ID = 'T' nichts  splitten
    IF <fs_buzid> = 'T'.                                    "gaa100522
      CONTINUE.                                             "gaa100522
    ENDIF.                                                  "gaa100522

*   wenn die Anzahl der Positionen zu dieser Belegnummer in den beiden Tabellen lt_glflex_temp und lt_glflex gleich ist, dann nichts machen.
    CLEAR: lv_anzahl_1, lv_anzahl_2.

    ASSIGN COMPONENT 'BELNR' OF STRUCTURE <cs_new_gl2> TO FIELD-SYMBOL(<fs_gl_belnr>).
    IF sy-subrc NE 0 OR <fs_gl_belnr> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <cs_new_gl2> TO FIELD-SYMBOL(<fs_gl_bukrs>).
    IF sy-subrc NE 0 OR <fs_gl_bukrs> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    ASSIGN COMPONENT 'GJAHR' OF STRUCTURE <cs_new_gl2> TO FIELD-SYMBOL(<fs_gl_gjahr>).
    IF sy-subrc NE 0 OR <fs_gl_gjahr> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.

    ASSIGN COMPONENT 'KTOSL_BSET' OF STRUCTURE <cs_new_gl2> TO FIELD-SYMBOL(<fs_gl_ktosl>).
    IF sy-subrc NE 0 OR <fs_gl_ktosl> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.

    LOOP AT  lt_glflex_temp TRANSPORTING NO FIELDS
      WHERE  bukrs = <fs_gl_bukrs> AND belnr = <fs_gl_belnr> AND gjahr = <fs_gl_gjahr>.
      lv_anzahl_1 = lv_anzahl_1 + 1.
    ENDLOOP.
    DELETE lt_glflex_temp WHERE bukrs =   <fs_gl_bukrs>
                            AND gjahr =   <fs_gl_gjahr>
                            AND belnr =   <fs_gl_belnr>.
    LOOP AT  lt_glflex TRANSPORTING NO FIELDS
      WHERE  bukrs = <fs_gl_bukrs> AND belnr = <fs_gl_belnr> AND gjahr = <fs_gl_gjahr>.
      lv_anzahl_2 = lv_anzahl_2 + 1.
    ENDLOOP.

    IF lv_anzahl_1 = lv_anzahl_2.
      CONTINUE.
    ENDIF.

    ASSIGN COMPONENT 'BELNR' OF STRUCTURE <cs_new_gl2> TO <fs_gl_belnr>.
    IF sy-subrc NE 0 OR <fs_gl_belnr> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    ASSIGN COMPONENT 'MWSKZ' OF STRUCTURE <cs_new_gl2> TO FIELD-SYMBOL(<fs_gl_mwskz>).
    IF sy-subrc NE 0 OR <fs_gl_mwskz> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    ASSIGN COMPONENT 'MWSKZ_BSET' OF STRUCTURE <cs_new_gl2> TO FIELD-SYMBOL(<fs_gl_mwskz_bset>).
    IF sy-subrc NE 0 OR <fs_gl_mwskz> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.

    ASSIGN COMPONENT 'HWSTE' OF STRUCTURE <cs_new_gl2> TO FIELD-SYMBOL(<fs_hwste>).
    IF sy-subrc NE 0 OR <fs_hwste> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    ASSIGN COMPONENT 'FWSTE' OF STRUCTURE <cs_new_gl2> TO FIELD-SYMBOL(<fs_fwste>).
    IF sy-subrc NE 0 OR <fs_fwste> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.

    REFRESH: lt_bseg_from_glflex.
*--------------------------------------------------------------------*
* nur die Zeilen lesen, die zu dem Beleg passen
*--------------------------------------------------------------------*
    UNASSIGN: <fs_glflex>.
    LOOP AT lt_glflex ASSIGNING <fs_glflex> WHERE belnr EQ <fs_gl_belnr>
                                              AND mwskz EQ <fs_gl_mwskz>
                                              AND ktosl NE 'MWS'
                                              AND ktosl NE 'VST'
                                              AND ktosl NE 'NVV'
                                              AND ktosl NE 'NAV'
                                              AND ktosl NE 'ESE'
                                              AND ktosl NE 'ESA'.
      APPEND <fs_glflex> TO lt_bseg_from_glflex.
    ENDLOOP.
*--------------------------------------------------------------------*
* Betrag prüfen und ggf. anpassen
*--------------------------------------------------------------------*
    PERFORM chk_hw_fw_bas_ste_10
            TABLES lt_bseg_from_glflex
             USING 'HWBAS'
                   'SK'            "Sachkonto
          CHANGING <cs_new_gl2>.

    PERFORM chk_hw_fw_bas_ste_10
            TABLES lt_bseg_from_glflex
             USING 'FWBAS'
                   'SK'            "Sachkonto
          CHANGING <cs_new_gl2>.

    IF <fs_gl_mwskz_bset> NE space.
      PERFORM chk_hw_fw_bas_ste_10
                  TABLES lt_bseg_from_glflex
                   USING 'HWBAS_BSET'
                         'SK'            "Sachkonto
                CHANGING <cs_new_gl2>.
    ENDIF.
    IF <fs_buzid> NE space.
      PERFORM chk_hw_fw_bas_ste_10
                  TABLES lt_bseg_from_glflex
                  USING 'DMBTR'
                        'SK'            "Sachkonto
                  CHANGING <cs_new_gl2>.

      PERFORM chk_hw_fw_bas_ste_10
                  TABLES lt_bseg_from_glflex
                  USING 'WRBTR'
                        'SK'            "Sachkonto
                  CHANGING <cs_new_gl2>.

    ENDIF.
    REFRESH: lt_bseg_from_glflex.
*--------------------------------------------------------------------*
* nur die Zeilen lesen, die zu dem Beleg passen
*--------------------------------------------------------------------*
    UNASSIGN: <fs_glflex>.
    LOOP AT lt_glflex ASSIGNING <fs_glflex> WHERE belnr EQ <fs_gl_belnr>
                                              AND mwskz EQ <fs_gl_mwskz_bset>
                                              AND koart EQ 'S'
                                              AND ktosl EQ <fs_gl_ktosl>.
      APPEND <fs_glflex> TO lt_bseg_from_glflex.
    ENDLOOP.

    IF NOT lt_bseg_from_glflex[] IS INITIAL.
      PERFORM chk_hw_fw_bas_ste_10
              TABLES lt_bseg_from_glflex
               USING 'HWSTE'
                     'ST'            "Sachkonto
              CHANGING <cs_new_gl2>.

      PERFORM chk_hw_fw_bas_ste_10
              TABLES lt_bseg_from_glflex
               USING 'FWSTE'
                     'ST'            "Sachkonto
               CHANGING <cs_new_gl2>.
    ELSE.
**** kein passender Steuerbetrag gefunden, also 0.
      <fs_hwste> = 0.
      <fs_fwste> = 0.
    ENDIF.
    IF h_nvv = 'X'.
*--------------------------------------------------------------------*
* nur die Zeilen lesen, die zu dem Beleg passen
*--------------------------------------------------------------------*

      LOOP AT lt_glflex INTO fs_glflexm       WHERE belnr EQ <fs_gl_belnr>
                                                AND mwskz EQ <fs_gl_mwskz_bset>
                                                AND koart EQ 'S'
                                                AND ( ktosl EQ 'MWS'
                                                 OR   ktosl EQ 'VST'
                                                 OR   ktosl EQ 'NVV'
                                                 OR   ktosl EQ 'NAV'
                                                 OR   ktosl EQ 'ESE'
                                                 OR   ktosl EQ 'ESA' ).
        IF fs_glflexm-shkzg = 'S'.
          ADD fs_glflexm-dmbtr  TO fs_glflex-dmbtr.
          ADD fs_glflexm-wrbtr  TO fs_glflex-wrbtr.
        ELSEIF fs_glflexm-shkzg = 'H'.
          SUBTRACT fs_glflexm-dmbtr  FROM fs_glflex-dmbtr.
          SUBTRACT fs_glflexm-wrbtr  FROM fs_glflex-wrbtr.
        ENDIF.
        <fs_hwbas> =  fs_glflex-dmbtr .
        <fs_fwbas> =  fs_glflex-wrbtr .
      ENDLOOP.
    ENDIF.
  ENDLOOP.
  LOOP AT ct_new_gl ASSIGNING <fs_new_gl>.
    ASSIGN COMPONENT 'HKONT' OF STRUCTURE <fs_new_gl> TO FIELD-SYMBOL(<fs_gl_hkont>).
    IF sy-subrc NE 0 OR <fs_gl_hkont> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    ASSIGN COMPONENT 'SHKZG_BSET' OF STRUCTURE <fs_new_gl> TO FIELD-SYMBOL(<fs_gl_shkzg>).
    IF sy-subrc NE 0 OR <fs_gl_shkzg> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    ASSIGN COMPONENT 'HWBAS' OF STRUCTURE <fs_new_gl> TO FIELD-SYMBOL(<fs_gl_hwbas>).
    IF sy-subrc NE 0 OR <fs_gl_hwbas> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    ASSIGN COMPONENT 'FWBAS' OF STRUCTURE <fs_new_gl> TO FIELD-SYMBOL(<fs_gl_fwbas>).
    IF sy-subrc NE 0 OR <fs_gl_fwbas> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    ASSIGN COMPONENT 'HWSTE' OF STRUCTURE <fs_new_gl> TO FIELD-SYMBOL(<fs_gl_hwste>).
    IF sy-subrc NE 0 OR <fs_gl_hwste> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    ASSIGN COMPONENT 'FWSTE' OF STRUCTURE <fs_new_gl> TO FIELD-SYMBOL(<fs_gl_fwste>).
    IF sy-subrc NE 0 OR <fs_gl_fwste> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fs_new_gl> TO FIELD-SYMBOL(<fs_gl_dmbtr>).
    IF sy-subrc NE 0 OR <fs_gl_fwste> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    IF NOT <fs_gl_hkont> = '0026000200' AND NOT <fs_gl_hkont> = '0026000189'.
      IF <fs_gl_hwste> LT 0.
        <fs_gl_hwste> = abs( <fs_gl_hwste> ).
        <fs_gl_fwste> = abs( <fs_gl_fwste> ).
      ELSEIF <fs_gl_hwste> GE 0.
        <fs_gl_hwste> = abs( <fs_gl_hwste> ).
        <fs_gl_fwste> = abs( <fs_gl_fwste> ).
      ENDIF.
      IF <fs_gl_dmbtr> LT 0.
        <fs_gl_dmbtr> = abs( <fs_gl_dmbtr> ).
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFUNCTION.

FORM chk_hw_fw_bas_ste_10 TABLES                    it_bseg_from_glflex STRUCTURE fagl_bseg_ext
                          USING                     VALUE(iv_comp)
                                                    u_kenn TYPE char02
                          CHANGING                  is_new_gl           TYPE any.

  DATA: lv_check(1) TYPE c.
  DATA: h_betrag  TYPE dmbtr.
  CLEAR: h_betrag.
  CLEAR lv_check.
  CLEAR h_nvv.
  ASSIGN COMPONENT 'HKONT' OF STRUCTURE is_new_gl TO FIELD-SYMBOL(<fs_hkont>).
  IF sy-subrc NE 0 OR <fs_hkont> IS NOT ASSIGNED.
    EXIT.
  ENDIF.

  LOOP AT it_bseg_from_glflex ASSIGNING FIELD-SYMBOL(<fs_glflex>).
    IF u_kenn = 'SK'.
      CHECK <fs_glflex>-hkont = <fs_hkont>.
    ENDIF.
    IF <fs_glflex>-mwskz(1) = 'N' OR <fs_glflex>-mwskz(1) = 'H' OR <fs_glflex>-mwskz(1) = 'S'.
      CLEAR lv_check.
      CLEAR h_nvv.
      SELECT SINGLE COUNT(*) FROM konp
        WHERE kschl = 'MWVZ' AND
              mwsk1 = <fs_glflex>-mwskz.
      IF sy-subrc = 0.
        h_nvv = 'X'.
      ENDIF.

    ENDIF.


    IF <fs_glflex>-hkont = '0026000200' OR <fs_glflex>-hkont = '0026000189' OR  lv_check = 'N'.
*      Steuerzeilen keine Anpassung der Beträge.
    ELSE.
*--------------------------------------------------------------------*
* BSET-Betrag lesen
*--------------------------------------------------------------------*
      ASSIGN COMPONENT 'KTOSL' OF STRUCTURE is_new_gl TO FIELD-SYMBOL(<fs_ktosl>).
      IF sy-subrc NE 0 OR <fs_ktosl> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT iv_comp OF STRUCTURE is_new_gl TO FIELD-SYMBOL(<fs_comp>).
      IF sy-subrc NE 0 OR <fs_comp> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <fs_glflex> TO FIELD-SYMBOL(<fs_betrag>).
      IF sy-subrc NE 0 OR <fs_betrag> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      ASSIGN COMPONENT 'SHKZG' OF STRUCTURE <fs_glflex> TO FIELD-SYMBOL(<fs_shkzg>). "gaa180122
      IF sy-subrc NE 0 OR <fs_shkzg> IS NOT ASSIGNED.       "gaa180122
        CONTINUE.                                           "gaa180122
      ENDIF.                                                "gaa180122

      IF <fs_shkzg> = 'S'.                                  "gaa180122
*           <fs_comp> = <fs_betrag>.                                                   "gaa180122
        ADD <fs_betrag> TO h_betrag.                        "gaa180122
      ELSEIF <fs_shkzg> = 'H'.                              "gaa180122
        SUBTRACT <fs_betrag> FROM h_betrag.                 "gaa180122
      .       ENDIF.                                        "gaa180122
      <fs_comp> = h_betrag.                                 "gaa180122
      UNASSIGN: <fs_comp>, <fs_betrag>, <fs_ktosl> .
    ENDIF.
  ENDLOOP.
ENDFORM.

FORM prepare_select_data_10   TABLES ct_new_gl TYPE STANDARD TABLE
                                     ct_range
                              USING VALUE(i_comp).

  DATA: lr_struc   TYPE REF TO cl_abap_structdescr
      , lr_data    TYPE REF TO data
      .
  TRY .
      lr_struc ?= cl_abap_datadescr=>describe_by_data( p_data = ct_range ).
      CREATE DATA lr_data TYPE HANDLE lr_struc.
      ASSIGN lr_data->* TO FIELD-SYMBOL(<fs_struc>).
    CATCH cx_root.
  ENDTRY.

  LOOP AT ct_new_gl ASSIGNING FIELD-SYMBOL(<fs_new_gl>).
    ASSIGN COMPONENT i_comp OF STRUCTURE <fs_new_gl> TO FIELD-SYMBOL(<fs_comp>).
    IF sy-subrc NE 0 OR <fs_comp> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.

    APPEND INITIAL LINE TO ct_range ASSIGNING <fs_struc>.

    ASSIGN COMPONENT 'SIGN' OF STRUCTURE <fs_struc> TO FIELD-SYMBOL(<fs_range_comp>).
    IF sy-subrc NE 0 OR <fs_range_comp> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    <fs_range_comp> = 'I'.

    ASSIGN COMPONENT 'OPTION' OF STRUCTURE <fs_struc> TO <fs_range_comp>.
    IF sy-subrc NE 0 OR <fs_range_comp> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    <fs_range_comp> = 'EQ'.

    ASSIGN COMPONENT 'LOW' OF STRUCTURE <fs_struc> TO <fs_range_comp>.
    IF sy-subrc NE 0 OR <fs_range_comp> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.
    <fs_range_comp> = <fs_comp>.
  ENDLOOP.

  DATA(lv_fieldname) = 'LOW'.
  SORT ct_range BY (lv_fieldname).
  DELETE ADJACENT DUPLICATES FROM ct_range.
ENDFORM.
