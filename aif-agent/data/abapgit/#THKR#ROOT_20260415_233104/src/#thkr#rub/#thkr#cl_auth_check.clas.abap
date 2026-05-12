class /THKR/CL_AUTH_CHECK definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF gty_kontierung,
        fistl   TYPE fistl,
        fipos   TYPE fipos,
        fonds   TYPE bp_geber,
        fkber   TYPE fkber,
        gsber   TYPE gsber,
        measure TYPE fm_measure,
        fikrs   TYPE fikrs,
      END OF gty_kontierung .
  types:
    gtt_kontierung TYPE STANDARD TABLE OF gty_kontierung .
  types:
    BEGIN OF gty_partner,
        partner TYPE bu_partner,
      END OF gty_partner .
  types:
    gtt_partner TYPE STANDARD TABLE OF gty_partner .

  constants GC_FICA_UTK type XUOBJECT value 'Z_FICA_UTK' ##NO_TEXT.
  constants GC_FICA_TRG type XUOBJECT value 'Z_FICA_TRG' ##NO_TEXT.
  constants GC_BUPA_GSB type XUOBJECT value 'Z_BUPA_GSB' ##NO_TEXT.
  constants GC_BUPA_GRP type XUOBJECT value 'Z_BUPA_GRP' ##NO_TEXT.

  class-methods CHECK_BUPA_AUTH
    importing
      !IV_PARTNER type BU_PARTNER
      !IV_TYPE type C optional
      !IV_RELEASE_CHECK type FLAG optional
      !IV_OBJECT type XUOBJECT optional
    returning
      value(RV_NO_AUTH) type FLAG .
  class-methods CHECK_AORD_AUTH_SINGLE
    importing
      !IV_LOTKZ type LOTKZ
      !IV_BUKRS type BUKRS
      !IV_RELEASE_CHECK type FLAG optional
      !IV_OBJECT_FICA type XUOBJECT optional
      !IV_OBJECT_BUPA type XUOBJECT optional
    returning
      value(RV_NO_AUTH) type FLAG .
  class-methods GET_AORD_DATA
    importing
      !IV_LOTKZ type LOTKZ
      !IV_BUKRS type BUKRS
    exporting
      !ET_PARTNER type GTT_PARTNER
      !ET_KONTIERUNG type GTT_KONTIERUNG .
  class-methods CHECK_FICA_OBJECT
    importing
      !IV_OBJECT type XUOBJECT optional
      !IV_KONTIERUNG type GTY_KONTIERUNG
      !IV_ACTVT type ACTIV_AUTH default '03'
    returning
      value(RV_NO_AUTH) type FLAG .
  class-methods CHECK_FMRE_AUTH
    importing
      !IV_OBJECT_FICA type XUOBJECT optional
      !IV_BELNR type FMR_SBELNR
      !IV_BLPOS type FMR_SBLPOS
      !IV_RELEASE_CHECK type FLAG optional
      !IV_OBJECT_BUPA type XUOBJECT optional
    returning
      value(RV_NO_AUTH) type FLAG .
  class-methods GET_FMRE_DATA
    importing
      !IV_BELNR type FMR_SBELNR
      !IV_BLPOS type FMR_SBLPOS
    exporting
      !ET_KONTIERUNG type GTT_KONTIERUNG
      !ET_PARTNER type GTT_PARTNER .
  class-methods GET_BKPF_DATA
    importing
      !IV_BELNR type BELNR_D
      !IV_BUKRS type BUKRS
      !IV_GJAHR type GJAHR
    exporting
      !ET_KONTIERUNG type GTT_KONTIERUNG
      !ET_PARTNER type GTT_PARTNER .
  class-methods CHECK_BKPF_AUTH
    importing
      !IV_BUKRS type BUKRS
      !IV_BELNR type BELNR_D
      !IV_GJAHR type GJAHR
      !IV_RELEASE_CHECK type FLAG optional
      !IV_OBJECT_FICA type XUOBJECT optional
      !IV_OBJECT_BUPA type XUOBJECT optional
    returning
      value(RV_NO_AUTH) type FLAG .
  class-methods CHECK_SEPA_AUTH
    importing
      !IV_ORG_REC_CRDID type SEPA_CRDID_ORIGIN
      !IV_ORG_MNDID type SEPA_MNDID_ORIGIN
      !IV_RELEASE_CHECK type FLAG optional
      !IV_OBJECT_BUPA type XUOBJECT optional
    returning
      value(RV_NO_AUTH) type FLAG .
  class-methods CHECK_BUPA_OBJECT
    importing
      !IV_AUGRP type BU_AUGRP
      !IV_GSBER type /THKR/DTE_BU_GSBER
      !IV_OBJECT type XUOBJECT optional
      !IV_ACT type ACTIV_AUTH default '03'
    returning
      value(RV_NO_AUTH) type FLAG .
  class-methods GET_BUPA_OBJECT
    returning
      value(RV_BUPA_OBJECT) type XUOBJECT .
  class-methods GET_FICA_OBJECT
    returning
      value(RV_FICA_OBJECT) type XUOBJECT .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_AUTH_CHECK IMPLEMENTATION.


  METHOD check_aord_auth_single.

    DATA: ls_kontierung TYPE gty_kontierung,
          lt_kontierung TYPE STANDARD TABLE OF gty_kontierung.
    DATA: ls_partner TYPE gty_partner,
          lt_partner TYPE STANDARD TABLE OF gty_partner.

    CALL METHOD /thkr/cl_auth_check=>get_aord_data(
      EXPORTING
        iv_bukrs      = iv_bukrs
        iv_lotkz      = iv_lotkz
      IMPORTING
        et_kontierung = lt_kontierung
        et_partner    = lt_partner
    ).

    LOOP AT lt_partner ASSIGNING FIELD-SYMBOL(<fs_partner>).

      DATA(lv_return_bp) = /thkr/cl_auth_check=>check_bupa_auth(
      EXPORTING iv_partner = <fs_partner>-partner
                iv_object  = iv_object_bupa ).
      IF lv_return_bp = abap_true.
        rv_no_auth = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_kontierung ASSIGNING FIELD-SYMBOL(<fs_kontierung>).

      DATA(lv_return_kont) = /thkr/cl_auth_check=>check_fica_object(
      EXPORTING iv_kontierung = <fs_kontierung>
                iv_object = iv_object_fica
      ).

      IF lv_return_kont = abap_true.
        rv_no_auth = abap_true.
        RETURN.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD check_bkpf_auth.

    DATA: ls_kontierung TYPE gty_kontierung,
          lt_kontierung TYPE STANDARD TABLE OF gty_kontierung.
    DATA: ls_partner TYPE gty_partner,
          lt_partner TYPE STANDARD TABLE OF gty_partner.

    CALL METHOD /thkr/cl_auth_check=>get_bkpf_data(
      EXPORTING
        iv_belnr      = iv_belnr
        iv_bukrs      = iv_bukrs
        iv_gjahr      = iv_gjahr
      IMPORTING
        et_kontierung = lt_kontierung
        et_partner    = lt_partner ).

    LOOP AT lt_partner ASSIGNING FIELD-SYMBOL(<fs_partner>).

      DATA(lv_return_bp) = /thkr/cl_auth_check=>check_bupa_auth(
      EXPORTING iv_partner = <fs_partner>-partner
                iv_object = iv_object_bupa ).
      IF lv_return_bp = abap_true.
        rv_no_auth = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_kontierung ASSIGNING FIELD-SYMBOL(<fs_kontierung>).

      DATA(lv_return_kont) = /thkr/cl_auth_check=>check_fica_object(
      EXPORTING iv_kontierung = <fs_kontierung>
                iv_object = iv_object_fica
      ).

      IF lv_return_kont = abap_true.
        rv_no_auth = abap_true.
        RETURN.
      ENDIF.

    ENDLOOP.



  ENDMETHOD.


  METHOD check_bupa_auth.


    CHECK iv_partner IS NOT INITIAL.

    SELECT SINGLE * FROM /thkr/c_tpbr_par
      INTO @DATA(ls_tpbr_par)
      WHERE programm = 'Z_BUPA_CHECK'
      AND fieldname = 'STATUS'.

    CHECK sy-subrc = 0.
    CHECK ls_tpbr_par-low = 'X'.

    "Ausnahme für Benutzer?

    SELECT sign, boption, low, high FROM /thkr/c_tpbr_par
      WHERE programm = 'Z_BUPA_CHECK' AND fieldname = 'USER'
      INTO TABLE @DATA(lt_user_excep).
    IF sy-subrc = 0 AND lt_user_excep IS NOT INITIAL.
      IF sy-uname IN lt_user_excep AND sy-uname IS NOT INITIAL..
        rv_no_auth = abap_false.
        RETURN.
      ENDIF.
    ENDIF.

    "Ausnahme für Programm?
    SELECT sign, boption, low, high FROM /thkr/c_tpbr_par
     WHERE programm = 'Z_BUPA_CHECK' AND fieldname = 'PROGNAME'
     INTO TABLE @DATA(lt_prog_excep).
    IF sy-subrc = 0 AND lt_prog_excep IS NOT INITIAL.
      IF sy-cprog IN lt_prog_excep AND sy-cprog IS NOT INITIAL.
        rv_no_auth = abap_false.
        RETURN.
      ENDIF.
    ENDIF.

    "Ausnahme für TCODE
    SELECT sign, boption, low, high FROM /thkr/c_tpbr_par
     WHERE programm = 'Z_BUPA_CHECK' AND fieldname = 'TCODE'
     INTO TABLE @DATA(lt_tcode_excep).
    IF sy-subrc = 0 AND lt_tcode_excep IS NOT INITIAL.
      IF sy-tcode IN lt_tcode_excep AND sy-tcode IS NOT INITIAL..
        rv_no_auth = abap_false.
        RETURN.
      ENDIF.
    ENDIF.
    "Auslesen Berechtigungsgruppe und Geschäftsbereich
    SELECT SINGLE augrp, /THKR/gsber
      FROM but000 WHERE partner = @iv_partner
      INTO @DATA(ls_bp_data).
    IF sy-subrc = 0.
      "Wenn Gruppe gefüllt, dann prüfen
      IF ls_bp_data-augrp IS NOT INITIAL.
        AUTHORITY-CHECK OBJECT 'B_BUPA_GRP'
         ID 'ACTVT' FIELD '03'
         ID 'BEGRU' FIELD ls_bp_data-augrp.
        IF sy-subrc <> 0.
          rv_no_auth = abap_true.
          RETURN.
        ENDIF.
      ENDIF.

      DATA(lv_no_auth) = /thkr/cl_auth_check=>check_bupa_object(
                          EXPORTING iv_act = '03'
                          iv_augrp = ls_bp_data-augrp
                          iv_gsber = ls_bp_data-/thkr/gsber
                          iv_object = iv_object
                           ).
      if lv_no_auth = abap_true.
        rv_no_auth = abap_true.
        return.
        ENDIF.

      IF iv_release_check IS NOT INITIAL.

        lv_no_auth = /thkr/cl_auth_check=>check_bupa_object(
                          EXPORTING iv_act = '43'
                          iv_augrp = ls_bp_data-augrp
                          iv_gsber = ls_bp_data-/thkr/gsber
                          iv_object = iv_object
                           ).
         if lv_no_auth = abap_true.
        rv_no_auth = abap_true.
        return.
        ENDIF.

      ENDIF.

    ELSE.

      rv_no_auth = abap_true.
      RETURN.
    ENDIF.

    IF iv_type = 'K'.

      SELECT SINGLE ktokk FROM lfa1 WHERE lifnr = @iv_partner
        INTO @DATA(lv_ktokk).
      IF sy-subrc = 0.
        IF lv_ktokk IS NOT INITIAL.
          AUTHORITY-CHECK OBJECT 'F_LFA1_GRP'
          ID 'KTOKK' FIELD lv_ktokk
          ID 'ACTVT' FIELD '03'.
          IF sy-subrc <> 0.
            rv_no_auth = abap_true.
            RETURN.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDIF.

    IF iv_type = 'D'.

      SELECT SINGLE ktokd FROM kna1 WHERE kunnr = @iv_partner
        INTO @DATA(lv_ktokd).
      IF sy-subrc = 0.
        IF lv_ktokd IS NOT INITIAL.
          AUTHORITY-CHECK OBJECT 'F_KNA1_GRP'
          ID 'KTOKD' FIELD lv_ktokd
          ID 'ACTVT' FIELD '03'.
          IF sy-subrc <> 0.
            rv_no_auth = abap_true.
            RETURN.
          ENDIF.

        ENDIF.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD check_bupa_object.

    DATA: lv_object TYPE xuobject.

    IF iv_object IS NOT INITIAL.
      lv_object = iv_object.
    ELSE.

      lv_object = /thkr/cl_auth_check=>get_bupa_object( ).

    ENDIF.

    CASE lv_object.
      WHEN /thkr/cl_auth_check=>gc_bupa_grp. "Kombination aus GSBER und BEGRU
        IF iv_gsber IS NOT INITIAL AND iv_augrp IS NOT INITIAL.
          AUTHORITY-CHECK OBJECT 'Z_BUPA_GRP'
           ID 'ACTVT' FIELD iv_act
           ID 'BEGRU' FIELD iv_augrp
           ID 'GSBER' FIELD iv_gsber.
          IF sy-subrc <> 0.
            rv_no_auth = abap_true.
            RETURN.
          ENDIF.
        ELSEIF iv_gsber IS NOT INITIAL AND iv_augrp IS INITIAL.
          AUTHORITY-CHECK OBJECT 'Z_BUPA_GRP'
        ID 'ACTVT' FIELD iv_act
        ID 'BEGRU' DUMMY
        ID 'GSBER' FIELD iv_gsber.
          IF sy-subrc <> 0.
            rv_no_auth = abap_true.
            RETURN.
          ENDIF.
        ELSEIF iv_gsber IS INITIAL AND iv_augrp IS NOT INITIAL.
          AUTHORITY-CHECK OBJECT 'Z_BUPA_GRP'
         ID 'ACTVT' FIELD iv_act
         ID 'BEGRU' FIELD iv_augrp
         ID 'GSBER' DUMMY.
          IF sy-subrc <> 0.
            rv_no_auth = abap_true.
            RETURN.
          ENDIF.
        ELSE.
          AUTHORITY-CHECK OBJECT 'Z_BUPA_GRP'
         ID 'ACTVT' FIELD iv_act
         ID 'BEGRU'  DUMMY
         ID 'GSBER'  DUMMY.
          IF sy-subrc <> 0.
            rv_no_auth = abap_true.
            RETURN.
          ENDIF.
        ENDIF.

      WHEN OTHERS. "Standart ist immer Z_BUPA_GSB

         IF iv_gsber IS NOT INITIAL.
          AUTHORITY-CHECK OBJECT 'Z_BUPA_GSB'
           ID 'ACTVT' FIELD iv_act
           ID 'GSBER' FIELD iv_gsber.
          IF sy-subrc <> 0.
            rv_no_auth = abap_true.
            RETURN.
          ENDIF.
        ELSE.
          AUTHORITY-CHECK OBJECT 'Z_BUPA_GRP'
         ID 'ACTVT' FIELD iv_act
         ID 'GSBER'  DUMMY.
          IF sy-subrc <> 0.
            rv_no_auth = abap_true.
            RETURN.
          ENDIF.
        ENDIF.

    ENDCASE.


  ENDMETHOD.


  METHOD check_fica_object.
    DATA: lv_fipex  TYPE fipex,
          lv_subrc  TYPE n,
          lv_actvt  TYPE fm_authact,
          lv_object TYPE xuobject.

    lv_actvt = iv_actvt.

    IF iv_object IS INITIAL.
      lv_object = /thkr/cl_auth_check=>get_fica_object( ).
    ELSE.
      lv_object = iv_object.
    ENDIF.

    IF iv_kontierung-fistl IS NOT INITIAL.
      SELECT SINGLE augrp FROM fmfctr INTO @DATA(lv_auth_grp_fistl)
          WHERE fikrs EQ @iv_kontierung-fikrs AND fictr EQ @iv_kontierung-fistl.
    ENDIF.

    IF iv_kontierung-fipos IS NOT INITIAL.
      SELECT SINGLE augrp FROM fmci INTO @DATA(lv_auth_grp_fipos)
                WHERE fikrs EQ @iv_kontierung-fikrs AND fipos EQ @iv_kontierung-fipos.
    ENDIF.


    IF iv_kontierung-fonds IS NOT INITIAL.
      SELECT SINGLE augrp FROM fmfincode INTO @DATA(lv_auth_grp_fond)
                  WHERE fincode EQ @iv_kontierung-fonds AND fikrs EQ @iv_kontierung-fikrs.
    ENDIF.

    IF  iv_kontierung-measure IS NOT INITIAL.
      SELECT SINGLE authgrp FROM fmmeasure INTO @DATA(lv_auth_grp_hhp)
                    WHERE measure EQ @iv_kontierung-measure AND fmarea  EQ @iv_kontierung-fikrs.
    ENDIF.
    IF iv_kontierung-fkber IS NOT INITIAL.
      SELECT SINGLE authgrp FROM tfkb INTO @DATA(lv_auth_grp_farea)
      WHERE fkber EQ @iv_kontierung-fkber.
    ENDIF.

    CLEAR lv_subrc.
    CASE lv_object.
      WHEN /THKR/CL_AUTH_CHECK=>GC_FICA_UTK.

        IF iv_kontierung-fipos IS NOT INITIAL.
        SELECT SINGLE fipex FROM fmfxpo
        INTO lv_fipex
        WHERE fipos = iv_kontierung-fipos.
        IF lv_fipex IS INITIAL.
          lv_fipex = iv_kontierung-fipos.
        ENDIF.
        ENDIF.

        CALL FUNCTION '/THKR/CHECK_FICA_UTK'
          EXPORTING
            activity           = lv_actvt
            fm_area            = iv_kontierung-fikrs
            fm_fincode_authgrp = lv_auth_grp_fond
            fm_fmfctr_authgrp  = lv_auth_grp_fistl
            fm_fipex           = lv_fipex
            fm_measure_authgrp = lv_auth_grp_hhp
            fm_farea_authgrp   = lv_auth_grp_farea
            iv_user            = sy-uname
          IMPORTING
            ex_subrc           = lv_subrc.
        IF lv_subrc <> 0.
          rv_no_auth = abap_true.
          RETURN.
        ENDIF.

      WHEN OTHERS.

        CALL FUNCTION 'Z_CHECK_FICA_TRG'
          EXPORTING
            activity           = lv_actvt
            fm_area            = iv_kontierung-fikrs
            fm_fincode_authgrp = lv_auth_grp_fond
            fm_fmfctr_authgrp  = lv_auth_grp_fistl
            fm_fipex_authgrp   = lv_auth_grp_fipos
            fm_measure_authgrp = lv_auth_grp_hhp
            fm_farea_authgrp   = lv_auth_grp_farea
            iv_user            = sy-uname
          IMPORTING
            ex_subrc           = lv_subrc.
        IF lv_subrc <> 0.
          rv_no_auth = abap_true.
          RETURN.
        ENDIF.

    ENDCASE.



  ENDMETHOD.


  METHOD check_fmre_auth.

    DATA: ls_kontierung TYPE gty_kontierung,
          lt_kontierung TYPE STANDARD TABLE OF gty_kontierung.
    DATA: ls_partner TYPE gty_partner,
          lt_partner TYPE STANDARD TABLE OF gty_partner.

    CALL METHOD /thkr/cl_auth_check=>get_fmre_data(
      EXPORTING
        iv_belnr      = iv_belnr
        iv_blpos      = iv_blpos
      IMPORTING
        et_kontierung = lt_kontierung
        et_partner    = lt_partner
    ).

    LOOP AT lt_partner ASSIGNING FIELD-SYMBOL(<fs_partner>).

      DATA(lv_return_bp) = /thkr/cl_auth_check=>check_bupa_auth(
      EXPORTING iv_partner = <fs_partner>-partner
                iv_object = iv_object_bupa ).
      IF lv_return_bp = abap_true.
        rv_no_auth = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_kontierung ASSIGNING FIELD-SYMBOL(<fs_kontierung>).

      DATA(lv_return_kont) = /thkr/cl_auth_check=>check_fica_object(
      EXPORTING iv_kontierung = <fs_kontierung>
                iv_object = iv_object_fica
      ).

      IF lv_return_kont = abap_true.
        rv_no_auth = abap_true.
        RETURN.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD check_sepa_auth.

    DATA: ls_sepa    TYPE sepa_mandate,
          lv_partner TYPE bu_partner.

    IF iv_org_rec_crdid IS NOT INITIAL AND iv_org_mndid IS NOT INITIAL.

      SELECT SINGLE * FROM sepa_mandate
        INTO ls_sepa
        WHERE origin_rec_crdid = iv_org_rec_crdid
        AND origin_mndid = iv_org_mndid
        AND mvers = '0'.

    ELSEIF iv_org_rec_crdid IS NOT INITIAL.

      SELECT SINGLE * FROM sepa_mandate
        INTO ls_sepa
        WHERE
        mguid = iv_org_rec_crdid
        AND mvers = '0'.

    ELSE.
      rv_no_auth = abap_true.
      RETURN.
    ENDIF.

    CHECK ls_sepa IS NOT INITIAL.

    AUTHORITY-CHECK OBJECT 'ZF_MANDATE'
    ID 'ACTVT' FIELD '03'
    ID 'GSBER' FIELD  ls_sepa-/thkr/gsber.
    IF sy-subrc <> 0.
      rv_no_auth = abap_true.
      RETURN.
    ENDIF.

    IF iv_release_check IS NOT INITIAL.
      AUTHORITY-CHECK OBJECT 'ZF_MANDATE'
       ID 'ACTVT' FIELD '43'
       ID 'GSBER' FIELD  ls_sepa-/thkr/gsber.
      IF sy-subrc <> 0.
        rv_no_auth = abap_true.
        RETURN.
      ENDIF.
    ENDIF.

    IF ls_sepa-snd_type = 'BUS3007' OR ls_sepa-snd_type = 'BUS1006'.

      lv_partner = ls_sepa-snd_id.

      rv_no_auth = /thkr/cl_auth_check=>check_bupa_auth(
      EXPORTING  iv_partner = lv_partner
        iv_type = 'D'
        iv_object = iv_object_bupa
      ).

    ENDIF.

  ENDMETHOD.


  METHOD get_aord_data.

    DATA: lt_vbseg  TYPE STANDARD TABLE OF fvbseg,
          lt_FVBKPF TYPE STANDARD TABLE OF fvbkpf,
          lt_FVBSEC TYPE STANDARD TABLE OF fvbsec,
          lt_FVBSET TYPE STANDARD TABLE OF fvbset,

          lT_VBKPF  TYPE STANDARD TABLE OF  vbkpf,
          lT_PSOSEC TYPE STANDARD TABLE OF  psosec,
          lT_PSOSET	TYPE STANDARD TABLE OF psoset.


    DATA: ls_kontierung      TYPE gty_kontierung,
          lt_kontierung      TYPE STANDARD TABLE OF gty_kontierung,
          lt_kontierung_temp TYPE STANDARD TABLE OF gty_kontierung,
          lt_psoseg          TYPE STANDARD TABLE OF psoseg,
          lt_PSOKPF          TYPE STANDARD TABLE OF psokpf.

    DATA: ls_partner      TYPE gty_partner,
          lt_partner      TYPE STANDARD TABLE OF gty_partner,
          lt_partner_temp TYPE STANDARD TABLE OF gty_partner,
          lv_fikrs        TYPE fikrs.

    CALL FUNCTION 'FM_FI_RECURRING_EXISTS_CHECK'
      EXPORTING
        i_lotkz   = iv_lotkz
        i_bukrs   = iv_bukrs
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc <> 0.

      SELECT Belnr, gjahr, bukrs, fikrs
        FROM bkpf
        INTO TABLE @DATA(lt_bkpf)
        WHERE bukrs = @iv_bukrs
        AND lotkz = @iv_lotkz.
      IF sy-subrc = 0.

        LOOP AT lt_bkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf>).
          lv_fikrs = <fs_bkpf>-fikrs.
          CALL FUNCTION 'PRELIMINARY_POSTING_DOC_READ'
            EXPORTING
              belnr                   = <fs_bkpf>-belnr
              bukrs                   = <fs_bkpf>-bukrs
              gjahr                   = <fs_bkpf>-gjahr
            TABLES
              t_vbseg                 = lt_vbseg
              t_vbkpf                 = lt_fvbkpf
              t_vbsec                 = lt_fvbsec
              t_vbset                 = lT_fVBSEt
            EXCEPTIONS
              document_line_not_found = 1
              document_not_found      = 2
              input_incomplete        = 3
              OTHERS                  = 4.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.
          lt_kontierung_temp = VALUE #(
          FOR l_vbseg IN lt_vbseg (
          fistl = l_vbseg-fistl
          fipos = l_vbseg-fipos
          fkber = l_vbseg-fkber
          fonds = l_vbseg-geber
          gsber = l_vbseg-gsber
          measure = l_vbseg-measure
          fikrs = lv_fikrs
          )
          ).
          APPEND LINES OF lt_kontierung_temp TO lt_kontierung.
          CLEAR lt_kontierung_temp.
          lt_partner_temp = VALUE #(
            FOR l_vbseg IN lt_vbseg WHERE ( lifnr IS NOT INITIAL ) (
            partner = l_vbseg-lifnr

            )
           ).
          IF lt_partner_temp IS NOT INITIAL.
            APPEND LINES OF lt_partner_temp TO lt_partner.
            CLEAR lt_partner_temp.
          ENDIF.

          lt_partner_temp = VALUE #(
         FOR l_vbseg IN lt_vbseg WHERE ( kunnr IS NOT INITIAL ) (
         partner = l_vbseg-kunnr

         )
        ).
          IF lt_partner_temp IS NOT INITIAL.
            APPEND LINES OF lt_partner_temp TO lt_partner.
            CLEAR lt_partner_temp.
          ENDIF.


        ENDLOOP.
        IF lt_kontierung IS INITIAL.

          SELECT * FROM bseg
            INTO TABLE @DATA(lt_bseg)
            FOR ALL ENTRIES IN @lt_bkpf
            WHERE belnr = @lt_bkpf-belnr
            AND gjahr = @lt_bkpf-gjahr
            AND bukrs = @lt_bkpf-bukrs.

          lt_kontierung_temp = VALUE #(
       FOR l_bseg IN lt_bseg (
       fistl = l_bseg-fistl
       fipos = l_bseg-fipos
       fkber = l_bseg-fkber
       fonds = l_bseg-geber
       gsber = l_bseg-gsber
       measure = l_bseg-measure
       )
       ).
          APPEND LINES OF lt_kontierung_temp TO lt_kontierung.
          CLEAR lt_kontierung_temp.

          lt_partner_temp = VALUE #(
            FOR l_bseg IN lt_bseg WHERE ( lifnr IS NOT INITIAL ) (
            partner = l_bseg-lifnr

            )
           ).
          IF lt_partner_temp IS NOT INITIAL.
            APPEND LINES OF lt_partner_temp TO lt_partner.
            CLEAR lt_partner_temp.
          ENDIF.

          lt_partner_temp = VALUE #(
         FOR l_bseg IN lt_bseg WHERE ( kunnr IS NOT INITIAL ) (
         partner = l_bseg-kunnr

         )
        ).
          IF lt_partner_temp IS NOT INITIAL.
            APPEND LINES OF lt_partner_temp TO lt_partner.
            CLEAR lt_partner_temp.
          ENDIF.

        ENDIF.

      ENDIF.

    ELSE.

      CALL FUNCTION 'FI_PSO_FI_VIA_RECURRING'
        EXPORTING
          i_bukrs  = iv_bukrs
          i_lotkz  = iv_lotkz
*         I_ITABKEY       =
        TABLES
          t_psokpf = lt_psokpf
          t_vbkpf  = lt_vbkpf
          t_psoseg = lt_psoseg
          t_psosec = lt_psosec
          t_psoset = lt_psoset.
      LOOP AT lt_psokpf ASSIGNING FIELD-SYMBOL(<fs_PSOKPF>).
        lv_fikrs = <fs_PSOKPF>-fikrs.
        EXIT.
      ENDLOOP.
      lt_kontierung_temp = VALUE #(
       FOR l_psoseg IN lt_psoseg (
       fistl = l_psoseg-fistl
       fipos = l_psoseg-fipos
       fkber = l_psoseg-fkber
       fonds = l_psoseg-geber
       gsber = l_psoseg-gsber
       measure = l_psoseg-measure
       fikrs = lv_fikrs
       )
       ).
      APPEND LINES OF lt_kontierung_temp TO lt_kontierung.
      CLEAR lt_kontierung_temp.
      lt_partner_temp = VALUE #(
        FOR l_psoseg IN lt_psoseg WHERE ( lifnr IS NOT INITIAL ) (
        partner = l_psoseg-lifnr

        )
       ).
      IF lt_partner_temp IS NOT INITIAL.
        APPEND LINES OF lt_partner_temp TO lt_partner.
        CLEAR lt_partner_temp.
      ENDIF.

      lt_partner_temp = VALUE #(
     FOR l_psoseg IN lt_psoseg WHERE ( kunnr IS NOT INITIAL ) (
     partner = l_psoseg-kunnr

     )
    ).
      IF lt_partner_temp IS NOT INITIAL.
        APPEND LINES OF lt_partner_temp TO lt_partner.
        CLEAR lt_partner_temp.
      ENDIF.

    ENDIF.

    IF lt_kontierung IS NOT INITIAL.

      SORT lt_kontierung.
      DELETE ADJACENT DUPLICATES FROM lt_kontierung.
      Delete lt_kontierung where fistl is INITIAL and fipos is INITIAL and fikrs is INITIAL and fonds is INITIAL.
      et_kontierung = lt_kontierung.
    ENDIF.

    IF lt_partner IS NOT INITIAL.

      SORT lt_partner.
      DELETE ADJACENT DUPLICATES FROM lt_partner.
      et_partner = lt_partner.
    ENDIF.



  ENDMETHOD.


  METHOD get_bkpf_data.

    DATA: ls_kontierung      TYPE gty_kontierung,
          lt_kontierung      TYPE STANDARD TABLE OF gty_kontierung,
          lt_kontierung_temp TYPE STANDARD TABLE OF gty_kontierung.

    DATA: ls_partner      TYPE gty_partner,
          lt_partner      TYPE STANDARD TABLE OF gty_partner,
          lt_partner_temp TYPE STANDARD TABLE OF gty_partner.

    SELECT SINGLE *
      FROM bkpf
      INTO @DATA(ls_bkpf)
      WHERE belnr = @iv_belnr
      AND gjahr = @iv_gjahr
      AND bukrs = @iv_bukrs.

    SELECT *
      FROM bseg
      INTO TABLE @DATA(lt_bseg)
      WHERE belnr = @iv_belnr
       AND gjahr = @iv_gjahr
       AND bukrs = @iv_bukrs
      .


    lt_kontierung_temp = VALUE #(
              FOR l_bseg IN lt_bseg (
              fistl = l_bseg-fistl
              fipos = l_bseg-fipos
              fkber = l_bseg-fkber
              fonds = l_bseg-geber
              gsber = l_bseg-gsber
              measure = l_bseg-measure
              fikrs = ls_bkpf-fikrs
              )
              ).
    APPEND LINES OF lt_kontierung_temp TO lt_kontierung.
    CLEAR lt_kontierung_temp.
    lt_partner_temp = VALUE #(
      FOR l_bseg IN lt_bseg WHERE ( lifnr IS NOT INITIAL ) (
      partner = l_bseg-lifnr

      )
     ).
    IF lt_partner_temp IS NOT INITIAL.
      APPEND LINES OF lt_partner_temp TO lt_partner.
      CLEAR lt_partner_temp.
    ENDIF.

    lt_partner_temp = VALUE #(
    FOR l_bseg IN lt_bseg WHERE ( kunnr IS NOT INITIAL ) (
   partner = l_bseg-kunnr

   )
  ).
    IF lt_partner_temp IS NOT INITIAL.
      APPEND LINES OF lt_partner_temp TO lt_partner.
      CLEAR lt_partner_temp.
    ENDIF.

    IF lt_kontierung IS NOT INITIAL.

      SORT lt_kontierung.
      DELETE ADJACENT DUPLICATES FROM lt_kontierung.
      DELETE lt_kontierung WHERE fistl IS INITIAL AND fipos IS INITIAL AND fikrs IS INITIAL AND fonds IS INITIAL.
      et_kontierung = lt_kontierung.
    ENDIF.

    IF lt_partner IS NOT INITIAL.

      SORT lt_partner.
      DELETE ADJACENT DUPLICATES FROM lt_partner.
      et_partner = lt_partner.
    ENDIF.
  ENDMETHOD.


  METHOD get_bupa_object.

    DATA: lv_object TYPE xuobject.

    SELECT SINGLE * FROM /thkr/c_tpbr_par
      INTO @DATA(ls_tpbr_par)
      WHERE programm = 'Z_BUPA_CHECK'
      AND fieldname = 'OBJEKT'.
    IF sy-subrc = 0 AND ls_tpbr_par-low IS NOT INITIAL.
      MOVE ls_tpbr_par-low TO lv_object.
    ELSE.
      lv_object = gc_bupa_gsb.
    ENDIF.

    rv_bupa_object = lv_object.

  ENDMETHOD.


  method GET_FICA_OBJECT.

    DATA: lv_object type xuobject.

    SELECT SINGLE * FROM /thkr/c_tpbr_par
      INTO @DATA(ls_tpbr_par)
      WHERE Programm = 'Z_FICA_CHECK'
      AND Fieldname = 'OBJEKT'.
    IF sy-subrc = 0 AND ls_tpbr_par-low IS NOT INITIAL.
      MOVE ls_tpbr_par-low TO lv_object.
    ELSE.
      lv_object = gc_fica_trg.
    ENDIF.

    rv_fica_object = lv_object.

  endmethod.


  METHOD get_fmre_data.

    DATA: ls_kontierung      TYPE gty_kontierung,
          lt_kontierung      TYPE STANDARD TABLE OF gty_kontierung,
          lt_kontierung_temp TYPE STANDARD TABLE OF gty_kontierung.

    DATA: ls_partner      TYPE gty_partner,
          lt_partner      TYPE STANDARD TABLE OF gty_partner,
          lt_partner_temp TYPE STANDARD TABLE OF gty_partner.


    SELECT SINGLE *
      FROM kblk
      INTO @DATA(ls_kblk)
      WHERE belnr = @iv_belnr.

    SELECT *
      FROM kblp
      INTO TABLE @DATA(lt_kblp)
      WHERE belnr = @iv_belnr
      AND blpos = @iv_blpos.
    IF sy-subrc <> 0.

      SELECT *
        FROM kblp
        INTO TABLE @lt_kblp
        WHERE belnr = @iv_belnr.

    ENDIF.

    lt_kontierung_temp = VALUE #(
          FOR l_kblp IN lt_kblp (
          fistl = l_kblp-fistl
          fipos = l_kblp-fipos
          fkber = l_kblp-fkber
          fonds = l_kblp-geber
          gsber = l_kblp-gsber
          measure = l_kblp-measure
          fikrs = ls_kblk-fikrs
          )
          ).
    APPEND LINES OF lt_kontierung_temp TO lt_kontierung.
    CLEAR lt_kontierung_temp.
    lt_partner_temp = VALUE #(
      FOR l_kblp IN lt_kblp WHERE ( lifnr IS NOT INITIAL ) (
      partner = l_kblp-lifnr

      )
     ).
    IF lt_partner_temp IS NOT INITIAL.
      APPEND LINES OF lt_partner_temp TO lt_partner.
      CLEAR lt_partner_temp.
    ENDIF.

    lt_partner_temp = VALUE #(
    FOR l_kblp IN lt_kblp WHERE ( kunnr IS NOT INITIAL ) (
   partner = l_kblp-kunnr

   )
  ).
    IF lt_partner_temp IS NOT INITIAL.
      APPEND LINES OF lt_partner_temp TO lt_partner.
      CLEAR lt_partner_temp.
    ENDIF.

    IF lt_kontierung IS NOT INITIAL.

      SORT lt_kontierung.
      DELETE ADJACENT DUPLICATES FROM lt_kontierung.
      DELETE lt_kontierung WHERE fistl IS INITIAL AND fipos IS INITIAL AND fikrs IS INITIAL AND fonds IS INITIAL.
      et_kontierung = lt_kontierung.
    ENDIF.

    IF lt_partner IS NOT INITIAL.

      SORT lt_partner.
      DELETE ADJACENT DUPLICATES FROM lt_partner.
      et_partner = lt_partner.
    ENDIF.




  ENDMETHOD.
ENDCLASS.
