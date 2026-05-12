FUNCTION zfi_feb_2_buchung .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_AUGLV)
*"     REFERENCE(I_FEBEP) LIKE  FEBEP STRUCTURE  FEBEP
*"     REFERENCE(I_FEBKO) LIKE  FEBKO STRUCTURE  FEBKO
*"  TABLES
*"      T_FEBCL STRUCTURE  FEBCL
*"      T_FEBRE STRUCTURE  FEBRE
*"      T_FTCLEAR STRUCTURE  FTCLEAR
*"      T_FTPOST STRUCTURE  FTPOST
*"      T_FTTAX STRUCTURE  FTTAX
*"----------------------------------------------------------------------

  DATA: ls_ftpost  LIKE ftpost,
        ls_ftclear LIKE ftclear,
        lv_str     TYPE text20,
        lv_diff    TYPE wrbtr,
        lv_wrbtr   TYPE wrbtr,
        lv_waers1  TYPE waers,
        lv_waers2  TYPE waers,
        lv_tabix   TYPE sy-tabix,
        lv_umskz   TYPE umskz,
        lv_belnr   TYPE belnr_d,
        lv_gjahr   TYPE gjahr,
        lv_bukrs   TYPE bukrs,
        lv_zfbdt   TYPE bdc_fval.


  READ TABLE t_ftpost INTO ls_ftpost WITH KEY stype = 'K' "#EC CI_STDSEQ
                                              count = '001'
                                              fnam  = 'BKPF-WAERS'.
  IF sy-subrc = 0.
    lv_waers1 = ls_ftpost-fval.
  ENDIF.
  lv_diff = 0.
  LOOP AT t_ftclear INTO ls_ftclear WHERE selfd = 'BELNR'. "#EC CI_STDSEQ
    SELECT SINGLE umskz, wrbtr, waers INTO (@lv_umskz, @lv_wrbtr, @lv_waers2) FROM bsid WHERE bukrs = @ls_ftclear-agbuk "#EC WARNOK
                                                                        AND belnr = @ls_ftclear-selvon
                                                                        AND gjahr = @ls_ftclear-selvon+10.
    IF lv_waers1 = lv_waers2.
      lv_diff = lv_diff + lv_wrbtr.
    ENDIF.
*"----------------------------------------------------------------------
* Umsetzung für deb. Zahlungen auf Sonderhauptbuchvorgänge  L,N,O,V,X
* Repro-Roc 15.02.2021-so kann jede Zeile ein eignes SHBkz bekommen
*"----------------------------------------------------------------------
    IF i_febep-vgint = '0008' OR
       i_febep-vgint = '0027' OR
       i_febep-vgint = '0040' OR
       i_febep-vgint = '0043' OR
      ( i_febep-vgint(1) = 'Z' AND
      ( i_febep-vgint+2(2) = '08' OR
        i_febep-vgint+2(2) = '27' OR
        i_febep-vgint+2(2) = '40' OR
        i_febep-vgint+2(2) = '43' ) ).
      IF lv_umskz CA 'LNOVX'.
        CLEAR ls_ftclear-xnops.
        ls_ftclear-agums = lv_umskz.
        MODIFY t_ftclear FROM ls_ftclear TRANSPORTING xnops agums.
      ENDIF.
    ENDIF.
  ENDLOOP.
*----------------------------------------------------------------------
*Repro-Roc 15.02.2021- falls TZ-auf SHBKZ --> ZFBDT
*----------------------------------------------------------------------
  READ TABLE t_ftpost INTO ls_ftpost WITH KEY stype = 'K' "#EC CI_STDSEQ
                                              count = '001'
                                              fnam  = 'BKPF-BUDAT'.
  lv_zfbdt = ls_ftpost-fval.
*----------------------------------------------------------------------
  READ TABLE t_ftpost WITH KEY stype = 'P'               "#EC CI_STDSEQ
                               count = '001'
                               fnam  = 'BSEG-REBZG'.
  IF sy-subrc = 0.
    lv_tabix = sy-tabix.
    ls_ftpost-stype = 'P'.
    ls_ftpost-count = '002'.
    ls_ftpost-fnam = 'BSEG-BSCHL'.     "'BSEG-BSCHL'.
    ls_ftpost-fval = '15'.
    INSERT ls_ftpost INTO t_ftpost INDEX lv_tabix.
*--- zusätzliche Prüfung, falls das Konto nicht gefüllt ist - analog zu ZFI_FEB_1_BUCHUNG
    IF NOT i_febep-avkon IS INITIAL. " Korrektur OSS Meldung 239616 / 2022
      lv_tabix = lv_tabix + 1.
      ls_ftpost-stype = 'P'.
      ls_ftpost-count = '002'.
      ls_ftpost-fnam = 'BSEG-HKONT'.     "'BSEG-HKONT'.
      ls_ftpost-fval = i_febep-avkon.
      INSERT ls_ftpost INTO t_ftpost INDEX lv_tabix.
    ENDIF.                            " Korrektur OSS Meldung 239616 / 2022

    LOOP AT t_ftpost ASSIGNING FIELD-SYMBOL(<po>) WHERE stype = 'P' AND count = 1 AND fnam(8) = 'BSEG-REB'. "#EC CI_STDSEQ
      <po>-count = 2.
      MODIFY t_ftpost FROM <po>.
    ENDLOOP.

    LOOP AT t_ftpost ASSIGNING <po> WHERE stype = 'P' AND count = 1 AND fnam(11) = 'RF05A-NEWBK'. "#EC CI_STDSEQ
      <po>-count = 2.
      MODIFY t_ftpost FROM <po>.
    ENDLOOP.

    READ TABLE t_ftpost INTO ls_ftpost WITH KEY stype = 'P' "#EC CI_STDSEQ
                                                count = '001'
                                                fnam  = 'BSEG-WRBTR'.
    IF sy-subrc = 0.
      ls_ftpost-count = 2.
      IF lv_diff <> 0.
        lv_str   = ls_ftpost-fval.
        sy-subrc = 0.
        WHILE sy-subrc NE 4.
          REPLACE '.' WITH ' ' INTO lv_str.
        ENDWHILE.
        CONDENSE lv_str NO-GAPS.
        REPLACE ',' IN lv_str WITH '.'.
        lv_wrbtr = lv_str.
        lv_wrbtr = lv_wrbtr - lv_diff.
        WRITE lv_wrbtr TO ls_ftpost-fval LEFT-JUSTIFIED.
      ENDIF.
      APPEND ls_ftpost TO t_ftpost.
    ENDIF.

*--ggf Änderung Buchungsschlüssel, Kennzeichen bei Teilzahlung auf SHBKZ
    IF i_febep-vgint = '0008' OR
          i_febep-vgint = '0027' OR
          i_febep-vgint = '0040' OR
          i_febep-vgint = '0043' OR
      ( i_febep-vgint(1) = 'Z' AND
      ( i_febep-vgint+2(2) = '08' OR
        i_febep-vgint+2(2) = '27' OR
        i_febep-vgint+2(2) = '40' OR
        i_febep-vgint+2(2) = '43' ) ).

      SELECT umskz  INTO  @lv_umskz   FROM bsid "#EC CI_EMPTY_SELECT   "#EC CI_NOORDER
                            WHERE bukrs = @i_febep-fval1
                             AND  belnr = @i_febep-fval2
                             AND  gjahr = @i_febep-fval3
                             AND  shkzg = 'S'
                             AND  zlspr <> 'E'.
        CONTINUE.
      ENDSELECT.

      IF lv_umskz CA 'LNOVX'.
*Buchungsschlüssel ändern
        LOOP AT t_ftpost ASSIGNING <po> WHERE            "#EC CI_STDSEQ
                                   stype = 'P'
                                   AND count = '002'
                                   AND fnam  = 'BSEG-BSCHL'
                                   AND fval = '15'.

          lv_tabix = sy-tabix.
          <po>-fval = '19'.
          MODIFY t_ftpost FROM <po> TRANSPORTING fval.
          EXIT.
        ENDLOOP.
        lv_tabix = lv_tabix + 1.
        ls_ftpost-stype = 'P'.
        ls_ftpost-count = '002'.
        ls_ftpost-fnam = 'RF05A-NEWUM'.
        ls_ftpost-fval = lv_umskz.
        INSERT ls_ftpost INTO t_ftpost INDEX lv_tabix.

        lv_tabix = lv_tabix + 1.
        ls_ftpost-stype = 'P'.
        ls_ftpost-count = '002'.
        ls_ftpost-fnam = 'BSEG-ZFBDT'.
        ls_ftpost-fval = lv_zfbdt .
        INSERT ls_ftpost INTO t_ftpost INDEX lv_tabix.

      ENDIF.
    ENDIF.
  ENDIF.


*--- zusätzliche Felder bei CPD füllen
  DATA: lv_buzei TYPE bseg-buzei,
        ls_bsec  TYPE bsec.

  CLEAR lv_buzei.
  SELECT buzei FROM bseg INTO lv_buzei WHERE bukrs = i_febep-fval1 "#EC CI_ALL_FIELDS_NEEDED  "#EC CI_EMPTY_SELECT
                                         AND belnr = i_febep-fval2 "#EC CI_NOORDER
                                         AND gjahr = i_febep-fval3
                                         AND koart = 'D'. "#EC CI_DB_OPERATION_OK[2431747]
  ENDSELECT.

  SELECT SINGLE * FROM bsec INTO ls_bsec WHERE bukrs = i_febep-fval1 "#EC CI_ALL_FIELDS_NEEDED
                                           AND belnr = i_febep-fval2
                                           AND gjahr = i_febep-fval3
                                           AND buzei = lv_buzei.
*  CALL FUNCTION 'READ_BSEC'
*    EXPORTING
*      xbelnr         = i_febep-fval2
*      xbukrs         = i_febep-fval1
*      xbuzei         = lv_buzei
*      xgjahr         = i_febep-fval3
*    IMPORTING
*      xbsec          = ls_bsec
*    EXCEPTIONS
*      key_incomplete = 1
*      not_authorized = 2
*      not_found      = 3
*      OTHERS         = 4.

  IF sy-subrc = 0.
    DATA: o_desc TYPE REF TO cl_abap_structdescr.
    o_desc ?= cl_abap_structdescr=>describe_by_name( 'BSEC' ).
    DATA(lt_ddic_fields) = o_desc->get_ddic_field_list( ).

    LOOP AT lt_ddic_fields INTO DATA(ls_ddic_field) WHERE fieldname <> 'MANDT' "#EC CI_STDSEQ
                                                      AND fieldname <> 'BUKRS'
                                                      AND fieldname <> 'BELNR'
                                                      AND fieldname <> 'GJAHR'
                                                      AND fieldname <> 'BUZEI'
                                                      AND fieldname <> 'ADRNR'
                                                      AND fieldname <> 'EMPFG'
                                                      AND fieldname <> 'XCPDK'.
      ASSIGN COMPONENT ls_ddic_field-fieldname OF STRUCTURE ls_bsec TO FIELD-SYMBOL(<v_value>).
      IF NOT <v_value> IS INITIAL.
        CONCATENATE 'BSEC-' ls_ddic_field-fieldname INTO ls_ftpost-fnam.
        ls_ftpost-fval  = <v_value>.
        ls_ftpost-stype = 'P'.
        ls_ftpost-count = 2.
        APPEND ls_ftpost TO t_ftpost.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.
