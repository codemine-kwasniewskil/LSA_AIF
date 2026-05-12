FUNCTION /thkr/chk_new_gl.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_GJAHR) TYPE  BKK_R_GJAHR
*"     REFERENCE(IT_BELNR) TYPE  BKK_R_BELNR
*"     REFERENCE(IT_BUKRS) TYPE  ICL_BUKRS_RANGE
*"     VALUE(IT_GSBER) TYPE  BKK_R_GSBER
*"     VALUE(IT_PRCTR) TYPE  HRPP_SEL_PRCTR
*"     VALUE(IT_SEGMENT) TYPE  HRPP_SEL_SEGMT
*"     REFERENCE(SEL_KTOS) TYPE  FKK_RT_KTOSL
*"  CHANGING
*"     REFERENCE(CT_NEW_GL) TYPE  STANDARD TABLE
*"  EXCEPTIONS
*"      NOT_FOUND
*"----------------------------------------------------------------------
  CONSTANTS: lc_rldnr_0l      TYPE fagl_rldnr VALUE '0L'.
  DATA: lt_bseg_from_glflex TYPE fagl_t_bseg_ext,
        lt_glflex           TYPE fagl_t_bseg_ext,
        lt_glflex_temp      TYPE fagl_t_bseg_ext,
        lv_anzahl_1         TYPE n,
        lv_anzahl_2         TYPE n.
  DATA: lr_gjahr TYPE  bkk_r_gjahr,
        lr_belnr TYPE  bkk_r_belnr,
        lr_bukrs TYPE  icl_bukrs_range.
  TYPES: BEGIN OF ty_belnr,
           bukrs TYPE bukrs,
           belnr TYPE belnr_d,
           gjahr TYPE gjahr,
         END OF ty_belnr.
  DATA: gt_belnr TYPE STANDARD TABLE OF ty_belnr.
  DATA: lv_buzei              TYPE buzei.
  DATA: new_gl  TYPE ty_bkpf_bset.
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
  LOOP AT ct_new_gl ASSIGNING FIELD-SYMBOL(<fs_new_gl>).
    MOVE-CORRESPONDING <fs_new_gl> TO new_gl.
    IF NOT new_gl-ktosl IN sel_ktos.
      DELETE ct_new_gl.
    ENDIF.
  ENDLOOP.

  IF lines( it_bukrs ) EQ 0.
    PERFORM prepare_select_data
            TABLES ct_new_gl
                   lr_bukrs
             USING 'BUKRS'.
  ELSE.
    lr_bukrs = it_bukrs.
  ENDIF.

  IF lines( it_gjahr ) EQ 0.
    PERFORM prepare_select_data
            TABLES ct_new_gl
                   lr_gjahr
             USING 'GJAHR'.
  ELSE.
    lr_gjahr = it_gjahr.
  ENDIF.
  IF lines( it_belnr ) EQ 0.
    PERFORM prepare_select_data
            TABLES ct_new_gl
                   lr_belnr
             USING 'BELNR'.
  ELSE.
    lr_belnr = it_belnr.
  ENDIF.
  SELECT DISTINCT bukrs,belnr,gjahr INTO TABLE @gt_belnr
         FROM bseg
         WHERE gjahr IN @it_gjahr
           AND bukrs IN @it_bukrs
           AND belnr IN @it_belnr
    ORDER BY bukrs,belnr,gjahr.
*--------------------------------------------------------------------*
* FAGLFLEXA/ACDOCA Daten bestimmen
*--------------------------------------------------------------------*
  LOOP AT gt_belnr ASSIGNING FIELD-SYMBOL(<fs_belnr>).
    CALL METHOD cl_fins_get_bseg=>map_acdoca_to_bseg_ext
      EXPORTING
        iv_bukrs    = <fs_belnr>-bukrs    "hch100522
        iv_belnr    = <fs_belnr>-belnr    "gaa180122
        iv_gjahr    = <fs_belnr>-gjahr    "hch10522
        iv_rldnr    = lc_rldnr_0l
      IMPORTING
        et_bseg_ext = lt_bseg_from_glflex
      EXCEPTIONS
        not_found   = 1.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    APPEND LINES OF lt_bseg_from_glflex TO lt_glflex.
    REFRESH: lt_bseg_from_glflex.
  ENDLOOP.

  DATA: lv_prctr TYPE prctr.

*--------------------------------------------------------------------*
* Bereinigen der Tabelle
*--------------------------------------------------------------------*
  lt_glflex_temp = lt_glflex.
  SORT lt_glflex_temp BY bukrs belnr gjahr.

  LOOP AT lt_glflex ASSIGNING FIELD-SYMBOL(<fs_glflex>)     "HCH100522
    WHERE prctr   NOT IN it_prctr
       OR gsber   NOT IN it_gsber
       OR segment NOT IN it_segment
       OR koart   EQ 'K'
       OR koart   EQ 'D'.                                   "gaa060322
    DELETE lt_glflex INDEX sy-tabix.
  ENDLOOP.
  UNASSIGN: <fs_glflex>.

  IF lines( lt_glflex ) EQ 0.
    REFRESH: ct_new_gl.
  ENDIF.

  LOOP AT ct_new_gl ASSIGNING <fs_new_gl>.
    DATA(lv_tabix) = sy-tabix.
    MOVE-CORRESPONDING <fs_new_gl> TO new_gl.

    IF new_gl-mwskz = 'U1' OR new_gl-mwskz = 'U2' OR new_gl-mwskz = 'V7'.
      CHECK new_gl-bukrs IS NOT INITIAL AND
            new_gl-belnr IS NOT INITIAL AND
            new_gl-gjahr IS NOT INITIAL AND
            new_gl-gjahr IS NOT INITIAL AND
            new_gl-txgrp IS NOT INITIAL.
      SELECT SINGLE buzei
        FROM bseg
        INTO lv_buzei
        WHERE bukrs = new_gl-bukrs AND
              belnr = new_gl-belnr AND
              gjahr = new_gl-gjahr AND
              txgrp = new_gl-txgrp.

      READ TABLE lt_glflex TRANSPORTING NO FIELDS WITH KEY belnr = new_gl-belnr
                                                           mwskz = new_gl-mwskz
                                                           buzei = lv_buzei.
      IF sy-subrc NE 0.
        DELETE ct_new_gl INDEX lv_tabix.
      ENDIF.
    ELSE.
      READ TABLE lt_glflex TRANSPORTING NO FIELDS WITH KEY belnr = new_gl-belnr
                                                           mwskz = new_gl-mwskz.
      IF sy-subrc NE 0.
        DELETE ct_new_gl INDEX lv_tabix.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CHECK lines( lt_glflex ) GT 0.
  CHECK lines( ct_new_gl ) GT 0.

*--------------------------------------------------------------------*
* nach BUKRS prüfen
*--------------------------------------------------------------------*
  CLEAR: lv_tabix.
  LOOP AT ct_new_gl ASSIGNING <fs_new_gl>.
    lv_tabix = sy-tabix.
    MOVE-CORRESPONDING <fs_new_gl> TO new_gl.

    LOOP AT lt_glflex ASSIGNING <fs_glflex>.
      IF abs( <fs_glflex>-bukrs ) EQ abs( new_gl-bukrs ).
        DATA(lv_exist) = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_exist EQ abap_false.
      DELETE ct_new_gl INDEX lv_tabix.
    ENDIF.
    CLEAR: lv_exist.
  ENDLOOP.

  CHECK lines( ct_new_gl ) GT 0.

  LOOP AT ct_new_gl ASSIGNING <fs_new_gl>.
    lv_tabix = sy-tabix.
    MOVE-CORRESPONDING <fs_new_gl> TO new_gl.
*   wenn die Anzahl der Positionen zu dieser Belegnummer in den beiden Tabellen lt_glflex_temp und lt_glflex gleich ist, dann nichts machen.
    CLEAR: lv_anzahl_1, lv_anzahl_2.

    LOOP AT  lt_glflex_temp TRANSPORTING NO FIELDS
      WHERE  bukrs = new_gl-bukrs AND belnr = new_gl-belnr AND gjahr = new_gl-gjahr.
      lv_anzahl_1 = lv_anzahl_1 + 1.
    ENDLOOP.

    LOOP AT  lt_glflex TRANSPORTING NO FIELDS
      WHERE  bukrs = new_gl-bukrs AND belnr = new_gl-belnr AND gjahr = new_gl-gjahr.
      lv_anzahl_2 = lv_anzahl_2 + 1.
    ENDLOOP.

    IF lv_anzahl_1 = lv_anzahl_2.
      CONTINUE.
    ENDIF.

    REFRESH: lt_bseg_from_glflex.
*--------------------------------------------------------------------*
* nur die Zeilen lesen, die zu dem Beleg passen
*--------------------------------------------------------------------*
    UNASSIGN: <fs_glflex>.
    LOOP AT lt_glflex ASSIGNING <fs_glflex> WHERE belnr EQ new_gl-belnr
                                              AND mwskz EQ new_gl-mwskz
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
    PERFORM chk_hw_fw_bas_ste
            TABLES lt_bseg_from_glflex
             USING 'HWBAS'
          CHANGING new_gl.

    PERFORM chk_hw_fw_bas_ste
            TABLES lt_bseg_from_glflex
             USING 'FWBAS'
          CHANGING new_gl.


    REFRESH: lt_bseg_from_glflex.
*--------------------------------------------------------------------*
* nur die Zeilen lesen, die zu dem Beleg passen
*--------------------------------------------------------------------*
    UNASSIGN: <fs_glflex> .
    LOOP AT lt_glflex ASSIGNING <fs_glflex> WHERE belnr EQ new_gl-belnr
                                              AND mwskz EQ new_gl-mwskz
                                              AND koart EQ 'S'
                                              AND ktosl EQ new_gl-ktosl.
      APPEND <fs_glflex> TO lt_bseg_from_glflex.
    ENDLOOP.

    PERFORM chk_hw_fw_bas_ste
            TABLES lt_bseg_from_glflex
             USING 'HWSTE'
          CHANGING new_gl.

    PERFORM chk_hw_fw_bas_ste
            TABLES lt_bseg_from_glflex
             USING 'FWSTE'
          CHANGING new_gl.

    IF h_nvv = 'X'.
      fs_glflex-dmbtr = new_gl-hwbas.
      fs_glflex-wrbtr = new_gl-fwbas.
*--------------------------------------------------------------------*
* nur die Zeilen lesen, die zu dem Beleg passen
*--------------------------------------------------------------------*
      LOOP AT lt_glflex INTO fs_glflexm       WHERE belnr EQ new_gl-belnr
                                                AND mwskz EQ new_gl-mwskz
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
        new_gl-hwbas = abs( fs_glflex-dmbtr ).
        new_gl-fwbas = abs( fs_glflex-wrbtr ).
      ENDLOOP.
    ENDIF.
    MOVE-CORRESPONDING new_gl TO <fs_new_gl>.
  ENDLOOP.

  LOOP AT ct_new_gl ASSIGNING <fs_new_gl>.
    MOVE-CORRESPONDING <fs_new_gl> TO new_gl.

    IF NOT new_gl-hkont = '0026000200' AND NOT new_gl-hkont = '0026000189'.
******************************************************************************************
*** das Sokk / Haben - Kennzeichen bezieht sich auf den Steuerbetrag, es bestimmt auch ***
*** das Vorzeichen des Steuerbasisbetrages                                             ***
******************************************************************************************
      new_gl-hwste = abs( new_gl-hwste ).
      new_gl-fwste = abs( new_gl-fwste ).
      new_gl-hwbas = abs( new_gl-hwbas ).
      new_gl-fwbas = abs( new_gl-fwbas ).
    ENDIF.
    MOVE-CORRESPONDING new_gl TO <fs_new_gl>.
  ENDLOOP.
ENDFUNCTION.

FORM chk_hw_fw_bas_ste TABLES it_bseg_from_glflex STRUCTURE fagl_bseg_ext
                        USING VALUE(iv_comp)
                     CHANGING is_new_gl           TYPE ty_bkpf_bset.

  DATA: lv_check(1) TYPE c.
  DATA: h_betrag    TYPE dmbtr.
  CLEAR: h_betrag, lv_check, h_nvv.

  LOOP AT it_bseg_from_glflex ASSIGNING FIELD-SYMBOL(<fs_glflex>).
    IF <fs_glflex>-mwskz(1) = 'N' OR <fs_glflex>-mwskz(1) = 'H' OR <fs_glflex>-mwskz(1) = 'S'.
      CLEAR lv_check.
      CLEAR h_nvv.
      SELECT SINGLE COUNT(*)
        FROM konp
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
      ASSIGN COMPONENT iv_comp OF STRUCTURE is_new_gl TO FIELD-SYMBOL(<fs_comp>).
      IF sy-subrc NE 0 OR <fs_comp> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      IF is_new_gl-shkzg = 'S'.
        ADD <fs_glflex>-dmbtr TO h_betrag.
      ELSEIF is_new_gl-shkzg = 'H'.
        SUBTRACT <fs_glflex>-dmbtr FROM h_betrag.
      ENDIF.
      <fs_comp> =  h_betrag .                               "gaa180122
      UNASSIGN: <fs_comp>.
    ENDIF.
  ENDLOOP.
ENDFORM.

FORM prepare_select_data TABLES ct_new_gl TYPE STANDARD TABLE
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
