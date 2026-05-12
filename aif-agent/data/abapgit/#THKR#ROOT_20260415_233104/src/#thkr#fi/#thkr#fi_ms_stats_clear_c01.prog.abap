*&---------------------------------------------------------------------*
*& Include          /THKR/FI_MS_STATS_CLEAR_C01
*&---------------------------------------------------------------------*
CLASS lcl_appl DEFINITION.
  PUBLIC SECTION.
    TYPES: tt_belnr TYPE RANGE OF kblnr.
    CLASS-METHODS:
      main IMPORTING it_belnr TYPE tt_belnr
                     iv_gjahr TYPE gjahr
                     iv_test  TYPE xflag.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_docs,
             belnr TYPE kblk-belnr,
             blpos TYPE kblp-blpos,
             stats TYPE kblp-stats,
           END OF ty_docs.
    CONSTANTS:
      mc_blart_ms TYPE blart VALUE 'MS',
      mc_blart_ma TYPE blart VALUE 'MA',
      mc_blart_mv TYPE blart VALUE 'MBV'.
    CLASS-DATA:
      testmode     TYPE xflag,
      mt_belnr     TYPE RANGE OF kblnr,
      used_belnr   TYPE /thkr/t_keyvalue,
      mt_proc_docs TYPE TABLE OF kblp, "ty_docs,
      mv_gjahr     TYPE gjahr,
      salv         TYPE REF TO  cl_salv_table.

    CLASS-METHODS:
      select_data,
      update_bd.
ENDCLASS.

CLASS lcl_appl IMPLEMENTATION.
  METHOD main.
    testmode = iv_test.
    mv_gjahr = iv_gjahr.
    mt_belnr = it_belnr.
    select_data( ).
    update_bd( ).

    "** Create ALV
    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = salv
                                CHANGING  t_table      = used_belnr ).
        IF testmode = abap_true.
          salv->get_display_settings( )->set_list_header( 'Testmode' ).
        ENDIF.
        salv->get_functions( )->set_all( abap_true ).
        salv->get_columns( )->set_optimize( abap_true ).
        salv->get_display_settings( )->set_striped_pattern( abap_true ).
        salv->get_columns( )->get_column( 'KEY' )->set_short_text( 'MB/Pos' ).
        salv->get_columns( )->get_column( 'KEY' )->set_medium_text( 'MB/Pos' ).
        salv->display( ).
      CATCH cx_salv_msg.
        "** No display only
    ENDTRY.

  ENDMETHOD.
  METHOD select_data.
    SELECT kblp~*
      FROM kblk
      INNER JOIN kblp ON kblk~belnr = kblp~belnr
      WHERE kblk~belnr IN @mt_belnr
        AND ( kblk~blart = @mc_blart_ms OR kblk~blart = @mc_blart_mv OR kblk~blart = @mc_blart_ma )
        AND kblp~fdatk BETWEEN @( |{ mv_gjahr }0101| ) AND @( |{ mv_gjahr }1231| ) AND
            kblp~stats = @abap_true
      ORDER BY kblp~belnr
      INTO CORRESPONDING FIELDS OF TABLE @mt_proc_docs.
  ENDMETHOD.
  METHOD update_bd.
    DATA: lt_posdata TYPE TABLE OF fmr_interface_det.
    IF mt_proc_docs IS INITIAL.
      MESSAGE s000 DISPLAY LIKE 'E'.
    ELSE.
      "**  Update MB first
      LOOP AT mt_proc_docs ASSIGNING FIELD-SYMBOL(<fs_proc_doc>).
        <fs_proc_doc>-aende = sy-uname.
        <fs_proc_doc>-aedat = sy-datum.
        CLEAR <fs_proc_doc>-stats.
        INSERT VALUE #( key = |{ <fs_proc_doc>-belnr }/{ <fs_proc_doc>-blpos }| ) INTO TABLE used_belnr.
      ENDLOOP.

      IF testmode = abap_true.
        EXIT.
      ENDIF.

      CALL FUNCTION 'FMR3_UPDATE_KBLKPW' IN UPDATE TASK
        TABLES
          t_kblp = mt_proc_docs.
      COMMIT WORK AND WAIT.

      "** Start processing for AVK tables
      LOOP AT mt_proc_docs ASSIGNING <fs_proc_doc>.
        DATA t_kbfm TYPE TABLE OF kbfm.
        CALL FUNCTION 'FMR3_FILL_KBFM_FROM_KBLX'
          EXPORTING
            i_belnr         = <fs_proc_doc>-belnr
          TABLES
            in_kbfm         = t_kbfm
          EXCEPTIONS
            not_found       = 1
            bukrs_not_found = 2
            invalid_waers   = 3
            OTHERS          = 4.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        DELETE t_kbfm WHERE blpos <> <fs_proc_doc>-blpos.
* fortschreibung nur bei commit work
        CALL FUNCTION 'FMR3_RWIN_CALL_WITH_KBFM'
          EXPORTING
            ip_process    = 'GENDOCU'
            ip_event      = 'OPENITEM'
            ip_orgvg      = 'KCOM' "MB only
            i_flg_end_avc = abap_true
          TABLES
            t_kbfm        = t_kbfm.
        CALL FUNCTION 'FMR3_RW_GENDOCU_POST'.
        COMMIT WORK AND WAIT.
      ENDLOOP.
      MESSAGE s001 DISPLAY LIKE 'I'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
