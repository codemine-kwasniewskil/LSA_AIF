CLASS /thkr/cl_im_wf_bwp_filter DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_ex_wf_bwp_select_filter .

    TYPES: BEGIN OF gty_bor_bkpf_key,
             bukrs TYPE bukrs,
             belnr TYPE belnr_d,
             gjahr TYPE gjahr,
           END OF gty_bor_bkpf_key,

           BEGIN OF gty_bor_bupa_key,
             partner TYPE bu_partner,
           END OF gty_bor_bupa_key,

           BEGIN OF gty_bor_fmpso_key,
             bukrs TYPE bukrs,
             lotkz TYPE lotkz,
           END OF gty_bor_fmpso_key,

           BEGIN OF gty_bor_FMRE_KEY,
             belnr TYPE fmr_sbelnr,
             blpos TYPE fmr_sblpos,
           END OF gty_bor_fmre_key,

           BEGIN OF GTY_bor_sepa_key,
             origin_rec_crdid TYPE sepa_crdid_origin,
             origin_mndid     TYPE sepa_mndid_origin,
           END OF gty_bor_sepa_key,

           BEGIN OF gty_bor_2086_key,
             belnr TYPE fmr_sbelnr,
             blpos TYPE fmr_sblpos,
             docno TYPE fmsuppnr,
           END OF gty_bor_2086_key.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_IM_WF_BWP_FILTER IMPLEMENTATION.


  METHOD if_ex_wf_bwp_select_filter~apply_filter.
    DATA: lt_plans        TYPE tswhactor,
          ls_worklist     TYPE swr_wihdr,
          lv_gsber        TYPE /thkr/dte_bu_gsber,
          lv_augrp        TYPE bu_augrp,
          lv_No_auth      TYPE abap_bool,
          lv_No_auth_sa   TYPE abap_bool,
          lt_container    TYPE sww_tporbel,
          lv_partner      TYPE bu_partner,
          lt_info         TYPE TABLE OF swotrk,
          ls_objtype      TYPE swotobjid-objtype,
          lv_string       TYPE string,
          ls_key_bupa     TYPE gty_bor_bupa_key,
          ls_key_fmpso    TYPE gty_bor_fmpso_key,
          ls_key_fmre     TYPE gty_bor_fmre_key,
          ls_key_2086     TYPE gty_bor_2086_key,
          ls_key_bkpf     TYPE gty_bor_bkpf_key,
          ls_key_sepa     TYPE gty_bor_sepa_key,
          lt_key_fmpso_SA TYPE STANDARD TABLE OF gty_bor_fmpso_key,
          lv_object_fica  TYPE xuobject,
          lv_object_bupa  TYPE xuobject.

    IF im_worklist IS NOT INITIAL.

      SELECT SINGLE * FROM /thkr/c_tpbr_par
      INTO @DATA(ls_tpbr_par_filter)
      WHERE Programm = 'Z_SBWP'
      AND Fieldname = 'FILTER'.
      IF sy-subrc <> 0 OR ls_tpbr_par_filter-low IS INITIAL.
        re_worklist = im_worklist.
        RETURN.
      ENDIF.

      lv_object_bupa = /thkr/cl_auth_check=>get_bupa_object( ).
      lv_object_fica = /thkr/cl_auth_check=>get_fica_object( ).

      LOOP AT im_worklist ASSIGNING FIELD-SYMBOL(<workitem>).
        lv_no_auth = abap_true.
        CLEAR: lt_container, ls_key_2086, ls_key_bkpf, ls_key_bupa,
        ls_key_fmpso, ls_key_fmre, ls_key_sepa, lt_key_fmpso_sa.
        CALL FUNCTION 'SWW_WI_CONTAINER_READ_OBJECTS'
          EXPORTING
            wi_id             = <workitem>-wi_id
          IMPORTING
            container_objects = lt_container
          EXCEPTIONS
            no_objects_found  = 1
            OTHERS            = 2.

        IF sy-subrc <> 0 OR lt_container IS INITIAL.
          CONTINUE.
        ENDIF.

        CASE <workitem>-wi_rh_task.
          WHEN 'TS90100011' OR 'TS90100018'. "Geschäftspartner
            READ TABLE lt_container WITH KEY element = 'BUPA' ASSIGNING FIELD-SYMBOL(<fs_container>).
            IF sy-subrc IS INITIAL.
              MOVE <fs_container>-instid TO ls_key_bupa.
              IF ls_key_bupa IS NOT INITIAL.
                lv_no_auth = /thkr/cl_auth_check=>check_bupa_auth( iv_partner = ls_key_bupa-partner
                                                      iv_release_check = 'X'
                                                      iv_object = lv_object_bupa ).
              ENDIF.
            ENDIF.
          WHEN 'TS80500065'. "Anordnungen
            READ TABLE lt_container WITH KEY typeid = 'FMPSO' ASSIGNING <fs_container>.
            IF sy-subrc IS INITIAL.
              MOVE <fs_container>-instid TO ls_key_fmpso.
              IF ls_key_fmpso IS NOT INITIAL.
                lv_no_auth = /thkr/cl_auth_check=>check_aord_auth_single(
                EXPORTING iv_bukrs = ls_key_fmpso-bukrs
                          iv_lotkz = ls_key_fmpso-lotkz
                          iv_object_fica = lv_object_fica
                          iv_object_bupa = lv_object_bupa
                  ).
              ENDIF.
            ENDIF.
          WHEN 'TS50000006'. "allgemeine Anordnungen & Mittelbindungen
            READ TABLE lt_container WITH KEY typeid = 'FMRE' ASSIGNING <fs_container>.
            IF sy-subrc IS INITIAL.
              MOVE <fs_container>-instid TO ls_key_fmre.
              IF ls_key_fmre IS NOT INITIAL.
                lv_no_auth = /thkr/cl_auth_check=>check_fmre_auth(
                EXPORTING iv_belnr = ls_key_fmre-belnr
                          iv_blpos = ls_key_fmre-blpos
                          iv_object_fica = lv_object_fica
                          iv_object_bupa = lv_object_bupa ).
              ENDIF.
            ENDIF.
          WHEN 'TS80500051'. "Wertanpassung Mittelbindung
            READ TABLE lt_container WITH KEY typeid = 'AMOUNTADJUSTMENT' ASSIGNING <fs_container>.
            IF sy-subrc IS INITIAL.
              MOVE <fs_container>-instid TO ls_key_2086.
              IF ls_key_2086 IS NOT INITIAL.

                lv_no_auth = /thkr/cl_auth_check=>check_fmre_auth(
               EXPORTING iv_belnr = ls_key_2086-belnr
                         iv_blpos = ls_key_2086-blpos
                         iv_object_fica = lv_object_fica
                         iv_object_bupa = lv_object_bupa ).
              ENDIF.
            ENDIF.
          WHEN 'TS90100023' OR 'TS90100024'. " Änderungsworkflow & Stornoworkflow
            READ TABLE lt_container WITH KEY element = 'Z_BKPF' ASSIGNING <fs_container>.
            IF sy-subrc IS INITIAL.
              MOVE <fs_container>-instid TO ls_key_bkpf.
              IF ls_key_bkpf IS NOT INITIAL.
                lv_no_auth = /thkr/cl_auth_check=>check_bkpf_auth(
                 EXPORTING iv_belnr = ls_key_bkpf-belnr
                           iv_bukrs = ls_key_bkpf-bukrs
                           iv_gjahr = ls_key_bkpf-gjahr
                           iv_object_fica = lv_object_fica
                           iv_object_bupa = lv_object_bupa ).
              ENDIF.
            ENDIF.

          WHEN 'TS90100043'. "SEPA-Mandate
            READ TABLE lt_container WITH KEY Element = 'SEPA' ASSIGNING <fs_container>.
            IF sy-subrc IS INITIAL.
              MOVE <fs_container>-instid TO ls_key_sepa.
              IF ls_key_sepa IS NOT INITIAL.
                lv_no_auth = /thkr/cl_auth_check=>check_sepa_auth(
                EXPORTING iv_org_mndid = ls_key_sepa-origin_mndid
                  iv_org_rec_crdid = ls_key_sepa-origin_rec_crdid
                  iv_release_check = 'X'
                  iv_object_bupa = lv_object_bupa
                ).
              ENDIF.
            ENDIF.

          WHEN 'TS90100045'. "Sammelanordnung
            LOOP AT lt_container ASSIGNING <fs_container> WHERE element = 'T_AORD'.
              MOVE <fs_container>-instid TO ls_key_fmpso.
              APPEND ls_key_fmpso TO lt_key_fmpso_sa.
              CLEAR ls_key_fmpso.
            ENDLOOP.
            IF lt_key_fmpso_sa IS NOT INITIAL.
              "Hier Prüfung einbauen

              LOOP AT lt_key_fmpso_sa ASSIGNING FIELD-SYMBOL(<fs_fmpso_sa>).

                lv_no_auth_sa = /thkr/cl_auth_check=>check_aord_auth_single(
                EXPORTING iv_bukrs = <fs_fmpso_sa>-bukrs
                          iv_lotkz = <fs_fmpso_sa>-lotkz
                          iv_object_fica = lv_object_fica
                          iv_object_bupa = lv_object_bupa
                  ).

                IF lv_no_auth_sa EQ abap_true.
                  EXIT.
                ENDIF.

              ENDLOOP.
              lv_no_auth = lv_no_auth_sa.
            ENDIF.
          WHEN OTHERS.
            lv_no_auth = abap_false.
        ENDCASE.
        " lv_no_auth = abap_true.
        IF lv_no_auth EQ abap_false.
          APPEND <workitem> TO re_worklist.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
