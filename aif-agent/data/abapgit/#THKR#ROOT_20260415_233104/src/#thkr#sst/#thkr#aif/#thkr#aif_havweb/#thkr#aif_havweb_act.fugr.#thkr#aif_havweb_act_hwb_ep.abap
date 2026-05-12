FUNCTION /thkr/aif_havweb_act_hwb_ep .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  C
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA) TYPE  /THKR/S_DE_HVW_SAP
*"     REFERENCE(CURR_LINE)
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------
  DATA: lt_return TYPE bapiret2_t.
  ASSIGN data  TO FIELD-SYMBOL(<fs_data>).
  DATA(lo_int_appl) = /thkr/cl_psm_int=>get_instance( ).

  LOOP AT <fs_data>-einzelplan INTO DATA(ls_ep).
    PERFORM fo_process USING    lo_int_appl
                                ls_ep-fo
                                ls_ep-gjahr
                       CHANGING lt_return.
    APPEND LINES OF lt_return TO return_tab.
    IF line_exists( lt_return[ type = 'E' ] ).
      CONTINUE.
    ENDIF.

    LOOP AT ls_ep-fb INTO DATA(ls_fb).
      PERFORM fb_process USING lo_int_appl
                               ls_fb
                               ls_ep-gjahr
                   CHANGING lt_return.
      APPEND LINES OF lt_return TO return_tab.
      IF line_exists( lt_return[ type = 'E' ] ).
        CONTINUE.
      ENDIF.

      LOOP AT ls_ep-tg INTO DATA(ls_tg) WHERE fkber = ls_fb-fkber.
        PERFORM tg_process USING lo_int_appl
                                 ls_tg
                           CHANGING lt_return.
        APPEND LINES OF lt_return TO return_tab.
        IF line_exists( lt_return[ type = 'E' ] ).
          CONTINUE.
        ENDIF.

        LOOP AT ls_ep-fp INTO DATA(ls_fp) WHERE fipex CP |{ ls_fb-fkber }*| AND
                                                zz_tg = ls_tg-titelgrp.
          IF ls_tg-cfflg IS NOT INITIAL.
            ls_fp-cfflg = ls_tg-cfflg.
          ENDIF.
          PERFORM fp_process USING    lo_int_appl
                                      ls_fp
                             CHANGING lt_return.
          APPEND LINES OF lt_return TO return_tab.
          IF line_exists( lt_return[ type = 'E' ] ).
            CONTINUE.
          ENDIF.

          LOOP AT ls_ep-vr INTO DATA(ls_ve) WHERE text = |{ ls_fp-fikrs }{ ls_fp-gjahr }{ ls_fp-fipex }|.
            PERFORM ve_process USING    lo_int_appl
                                        ls_ve
                               CHANGING lt_return.
            APPEND LINES OF lt_return TO return_tab.
            PERFORM fp_longtext_process USING    lo_int_appl
                                                 ls_fp
                                                 ls_ve
                                        CHANGING lt_return.
            APPEND LINES OF lt_return TO return_tab.
          ENDLOOP.
          LOOP AT ls_ep-as INTO DATA(ls_as) WHERE fikrs = ls_fp-fikrs AND
                                                  gjahr = ls_fp-gjahr AND
                                                  fipex = ls_fp-fipex AND
                                                  ansatz IS NOT INITIAL.
            PERFORM beleg_process USING lo_int_appl
                                        ls_as
                                        ls_ep-mode
                               CHANGING lt_return.
            APPEND LINES OF lt_return TO return_tab.

          ENDLOOP.
          LOOP AT ls_ep-vs  INTO DATA(ls_vs) WHERE fikrs = ls_fp-fikrs AND
                                                   gjahr = ls_fp-gjahr AND
                                                   fipex = ls_fp-fipex AND
                                                   ansatz IS NOT INITIAL.
            PERFORM beleg_process USING lo_int_appl
                                        ls_vs
                                        ls_ep-mode
                               CHANGING lt_return.
            APPEND LINES OF lt_return TO return_tab.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

  IF testrun = abap_false.
    success = 'Y'.
  ELSE.
    ROLLBACK WORK.
  ENDIF.
ENDFUNCTION.
