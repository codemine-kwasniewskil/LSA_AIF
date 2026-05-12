FUNCTION z_fieb_902_algorithm.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_NOTE_TO_PAYEE) TYPE  STRING OPTIONAL
*"     REFERENCE(I_COUNTRY) TYPE  LAND1 OPTIONAL
*"  TABLES
*"      T_AVIP_IN STRUCTURE  AVIP OPTIONAL
*"      T_AVIP_OUT STRUCTURE  AVIP
*"      T_FILTER1 OPTIONAL
*"      T_FILTER2 OPTIONAL
*"----------------------------------------------------------------------
  DATA: lv_gebkz  TYPE char1,
        lv_acctmp TYPE feb_acctmp,
        lt_kassz  TYPE /thkr/tt_xblnr,
        lt_bsik   TYPE bsik_tt,
        lt_kblk   TYPE /thkr/tt_kblk.

  CONSTANTS:
        lc_vgint      TYPE vgint_eb VALUE '1025'.

  TRY.

      DATA(lr_elko) = NEW /thkr/cl_elko_appl( ).

      lr_elko->free_memory_id( ).

      lr_elko->set_refresh_itab( CHANGING xt_kassz    = lt_kassz
                                          xt_bsik     = lt_bsik
                                          xt_kblk     = lt_kblk
                                          xt_avip_out = t_avip_out[] ).

      lr_elko->get_kassenz_aus_gebkz( CHANGING xv_gebkz  = lv_gebkz
                                               xt_kassz  = lt_kassz
                                               xv_acctmp = lv_acctmp ).

      CHECK lv_acctmp IS INITIAL. "Verarbeitung nur wenn keine Kontierungsvorlage vorliegt.

      lr_elko->get_kassenz_aus_febre( EXPORTING iv_vwezw = i_note_to_payee
                                      CHANGING  xt_kassz = lt_kassz ).

      lr_elko->get_kassenz_suchm( EXPORTING iv_vwezw = i_note_to_payee
                                  CHANGING  xt_kassz = lt_kassz ).

      lr_elko->check_pruefziffern(    CHANGING  xt_kassz    = lt_kassz ).

      lr_elko->get_bsik_aus_kassenz( EXPORTING it_kassz = lt_kassz
                                     CHANGING  xt_bsik  = lt_bsik ).

      lr_elko->set_avip_902_out( EXPORTING it_bsik     = lt_bsik
                                 CHANGING  xt_avip_out = t_avip_out[] ).

      lr_elko->get_kblk_902_kassenz( EXPORTING it_bsik  = lt_bsik
                                               it_kassz = lt_kassz
                                     CHANGING  xt_kblk  = lt_kblk ).

      lr_elko->check_avip_kblk( CHANGING xt_avip_out = t_avip_out[]
                                         xt_kblk     = lt_kblk ).

      lr_elko->set_febep_aus_kblk( EXPORTING it_kblk  = lt_kblk
                                             iv_vgint = lc_vgint
                                             iv_kred  = abap_true ).

      lr_elko->set_sgtxt_to_febep( EXPORTING iv_vwezw = i_note_to_payee ).

    CATCH /thkr/cx_elko INTO DATA(err). " Fehlerkasse Init.
      LOOP AT err->bapiret2_tab ASSIGNING FIELD-SYMBOL(<ls_return>).
        cl_feb_appl_log_handler=>add_message( i_msgid = <ls_return>-id
                                              i_msgty = <ls_return>-type
                                              i_msgno = <ls_return>-number
                                              i_msgv1 = <ls_return>-message_v1
                                              i_msgv2 = <ls_return>-message_v2
                                              i_msgv3 = <ls_return>-message_v3
                                              i_msgv4 = <ls_return>-message_v4 ).
      ENDLOOP.
  ENDTRY.
ENDFUNCTION.
