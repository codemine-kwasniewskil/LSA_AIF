class /THKR/CL_IM_FM_REQUESTS definition
  public
  final
  create public .

public section.

  interfaces IF_EX_FM_REQUESTS .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_IM_FM_REQUESTS IMPLEMENTATION.


  METHOD if_ex_fm_requests~docs_check.
    DATA: ls_vbkpf LIKE LINE OF i_t_vbkpf.
    DATA: ls_vbseg LIKE LINE OF i_t_vbseg.
    DATA: lv_answer(1).
    DATA: lv_text TYPE string.
    DATA: lv_partner TYPE bu_partner,
          lv_type    TYPE c LENGTH 1.

    LOOP AT i_t_vbseg INTO ls_vbseg.
      CASE ls_vbseg-maber.
        WHEN 'M1' OR 'M2' OR 'M3' OR 'M4'.
          LOOP AT i_t_vbkpf INTO ls_vbkpf.
            IF ls_vbkpf-z_intrate IS INITIAL AND sy-tcode(3) <> 'F89' AND sy-tcode <> 'F889' AND sy-tcode <> 'F886'. "DF-1705
              MESSAGE e001(/thkr/klsa966) WITH ls_vbseg-maber.
            ENDIF.
          ENDLOOP.
        WHEN 'P1'.
          LOOP AT i_t_vbkpf INTO ls_vbkpf.
            IF ls_vbkpf-z_intrate IS INITIAL  AND sy-tcode(3) <> 'F89' AND sy-tcode <> 'F889' AND sy-tcode <> 'F886'. "DF-1705
              CONCATENATE 'Es wurde kein individueller Zinssatz eingetragen.'
                          'Stattdessen wird der hinterlegte Zinssatz im Zinskennzeichen verwendet.'
                          'Wollen Sie dies wirklich?' INTO lv_text SEPARATED BY space.
              CALL FUNCTION 'POPUP_TO_CONFIRM'
                EXPORTING
                  titlebar              = 'Zinssatz'
*                 DIAGNOSE_OBJECT       = ' '
                  text_question         = lv_text
                  text_button_1         = 'Ja'(001)
*                 ICON_BUTTON_1         = ' '
                  text_button_2         = 'Nein'(002)
*                 ICON_BUTTON_2         = ' '
                  default_button        = ' '
                  display_cancel_button = ' '
*                 USERDEFINED_F1_HELP   = ' '
*                 START_COLUMN          = 25
*                 START_ROW             = 6
*                 POPUP_TYPE            =
*                 IV_QUICKINFO_BUTTON_1 = ' '
*                 IV_QUICKINFO_BUTTON_2 = ' '
                IMPORTING
                  answer                = lv_answer
*               TABLES
*                 PARAMETER             =
                EXCEPTIONS
                  text_not_found        = 1
                  OTHERS                = 2.
              IF sy-subrc <> 0.
* Implement suitable error handling here
              ENDIF.
              IF lv_answer = '2'.
                MESSAGE e001(/thkr/klsa966) WITH ls_vbseg-maber.
              ENDIF.
            ENDIF.
          ENDLOOP.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
*    ENDIF.

DATA(lv_object) = /thkr/cl_auth_check=>get_bupa_object( ).

    LOOP AT i_t_vbseg ASSIGNING FIELD-SYMBOL(<fs_bseg>).



      IF <fs_bseg>-lifnr IS NOT INITIAL.
        lv_partner = <fs_bseg>-lifnr.
        lv_type = 'K'.
      ELSEIF <fs_bseg>-kunnr IS NOT INITIAL.
        lv_partner = <fs_bseg>-kunnr.
        lv_type = 'D'.
      ENDIF.

      IF lv_partner IS NOT INITIAL.

        DATA(no_auth_l) = /thkr/cl_auth_check=>check_bupa_auth(
          iv_partner = lv_partner
          iv_type    = lv_type
          iv_object = lv_object ).
        IF no_auth_l EQ abap_true.

          MESSAGE e010(/thkr/bp)  WITH lv_partner.

        ENDIF.

      ENDIF.

      CLEAR: lv_partner, lv_type.

    ENDLOOP.

  ENDMETHOD.


  METHOD if_ex_fm_requests~react_on_okcode.
    DATA: ls_pso02        TYPE pso02,
          lv_answer       TYPE string,
          lv_default      TYPE c,
          ls_klsa966_incl TYPE /thkr/s_klsa966_incl.

    FIELD-SYMBOLS: <fs_pso02> TYPE pso02.
* Nur sinnvoll, falls Belegdaten vorhanden
    READ TABLE i_t_pso02 ASSIGNING <fs_pso02> INDEX 1.
*
    IF ( sy-subrc <> 0 ).
      RETURN.
    ENDIF.

    CASE c_okcode.
* --- ---
      WHEN 'ZINS'.
        IF sy-tcode <> 'F889' AND sy-tcode <> 'F886'. "DF-1705 27.10.2025

          CALL FUNCTION '/THKR/KLSA966_CALL_SCREEN_9010'
            EXPORTING
              iv_bukrs    = <fs_pso02>-bukrs
              iv_belnr    = <fs_pso02>-belnr
              iv_gjahr    = <fs_pso02>-gjahr
              iv_activity = i_activity
              iv_dbbdt    = <fs_pso02>-dbbdt
              iv_lotkz    = <fs_pso02>-lotkz.
*            importing
*              e_z_vzskz   = <fs_pso02>-z_vzskz
*              e_Z_INTRATE = <fs_pso02>-z_intrate.

        ENDIF.

      WHEN 'ZAHLANZ'.
        CLEAR: lv_answer, lv_default, ls_klsa966_incl.
        FREE MEMORY ID 'ZAHLANZ'.

        CALL FUNCTION '/THKR/KLSA966_GET_INCL'
          EXPORTING
            iv_bukrs        = <fs_pso02>-bukrs
            iv_belnr        = <fs_pso02>-belnr
            iv_gjahr        = <fs_pso02>-gjahr
          IMPORTING
            es_klsa966_incl = ls_klsa966_incl.
        IF sy-subrc EQ 0.
          IF ls_klsa966_incl-z_009 EQ '1'.
            lv_default = '1'.
          ELSE.
            lv_default = '2'.
          ENDIF.
        ENDIF.
        CALL FUNCTION 'K_KKB_POPUP_RADIO2'
          EXPORTING
            i_title   = 'Wünschen Sie eine Zahlungsanzeige?'
            i_text1   = 'Ja'
            i_text2   = 'Nein'
            i_default = lv_default
          IMPORTING
            i_result  = lv_answer
          EXCEPTIONS
            cancel    = 1
            OTHERS    = 2.

        IF lv_answer EQ '1'.
          EXPORT zahlanz FROM abap_true TO MEMORY ID 'ZAHLANZ'.
        ENDIF.

        "**********************************************************************
        "** This solution is temporaly until the MVO Modul will be installed and should be deactivated then.
        "** We're using the popup preparing the TSI-MVO Addon in advance
        "**********************************************************************
      WHEN 'MVO'.
        DATA(line) = /thkr/cl_data_store=>get( id = 'MVO' )->get_attr( 'ITEM_LINE_NO' ).
        line = COND #( WHEN line IS INITIAL THEN '1' ELSE line ).
        TRY.
            "**
            DATA(lotkz) = i_t_pso02[ line ]-lotkz.
            SELECT SINGLE FROM bkpf FIELDS z_mvo_relevant WHERE lotkz = @lotkz AND z_mvo_relevant = @abap_true INTO @DATA(header_mvo).
            DATA(belnr) = i_t_pso02[ line ]-belnr.
            DATA(gjahr) = i_t_pso02[ line ]-gjahr.
            DATA(bukrs) = i_t_pso02[ line ]-bukrs.
            "** We are changing the flag without AO logic: We must read it again.
            SELECT SINGLE FROM bkpf FIELDS z_mvo_relevant WHERE bukrs = @bukrs AND belnr = @belnr AND gjahr = @gjahr INTO @DATA(mvoflag).
            IF sy-subrc <> 0.
              mvoflag = /thkr/cl_data_store=>get( id = 'MVO' )->get_attr( 'FLAG' ).
            ENDIF.
            "** Read Only:
            DATA(field_control) = COND #( WHEN i_activity = 01 OR i_activity = 02 THEN '  ' ELSE '02' ).
            DATA(fields) = VALUE ty_sval( ( tabname = 'BKPF'  fieldname = 'Z_MVO_RELEVANT' fieldtext = 'AO ist relevant' field_attr = '02'          value = header_mvo ) "display only!
                                          ( tabname = '*BKPF' fieldname = 'Z_MVO_RELEVANT' fieldtext = 'Pos. ist relev.' field_attr = field_control value = mvoflag ) ).

            "** Store for save process:
            /thkr/cl_data_store=>get( 'MVO' )->set_attr( key = 'BUKRS' value = CONV #( bukrs ) ).
            /thkr/cl_data_store=>get( 'MVO' )->set_attr( key = 'BELNR' value = CONV #( belnr ) ).
            /thkr/cl_data_store=>get( 'MVO' )->set_attr( key = 'GJAHR' value = CONV #( gjahr ) ).

            CALL FUNCTION 'POPUP_GET_VALUES_USER_BUTTONS'
              EXPORTING
                formname          = 'HANDLE_CODE'
                programname       = '/THKR/PSM_AO_MVO_HANDLER'
                popup_title       = 'MVO Kennzeichen'
                ok_pushbuttontext = 'Speichern'
              TABLES
                fields            = fields.
            IF sy-subrc <> 0.
              "Catch error but we can do nothing here!
            ENDIF.
          CATCH cx_sy_itab_line_not_found.
            "No line found, should not occur!
        ENDTRY.
        "**********************************************************************
    ENDCASE.

  ENDMETHOD.


  method IF_EX_FM_REQUESTS~SET_PFSTATUS.
* STATUS - Extra-Buttons
    case c_pfstatus.
* ---
      when 'MAIN'.
*        if sy-tcode(3) <> 'F89'.
        if sy-tcode(3) <> 'F89' and sy-tcode <> 'F889' and sy-tcode <> 'F886'. "DF-1705 27.10.2025
        c_progname = '/THKR/SAPLKLSA966_FG'.
        c_pfstatus = 'MAIN'.
        endif.
      endcase.

  endmethod.
ENDCLASS.
