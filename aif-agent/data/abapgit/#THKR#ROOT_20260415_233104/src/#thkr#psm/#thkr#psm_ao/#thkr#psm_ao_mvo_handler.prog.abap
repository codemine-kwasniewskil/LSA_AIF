*&---------------------------------------------------------------------*
*& Report /THKR/PSM_AO_MVO_HANDLER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/psm_ao_mvo_handler.

"** Handler für Click Events aus /THKR/CL_IM_FM_REQUESTS IF_EX_FM_REQUESTS~REACT_ON_OKCODE
"** This solution is temporaly until the MVO Modul will be installed and should be deactivated then.
FORM handle_code TABLES   fields STRUCTURE sval
                 USING    code
                 CHANGING error  STRUCTURE svale show_popup.

  IF code = 'FURT'.
    DATA(belnr) = /thkr/cl_data_store=>get( 'MVO' )->get_attr( key = 'BELNR' ).
    DATA(gjahr) = /thkr/cl_data_store=>get( 'MVO' )->get_attr( key = 'GJAHR' ).
    DATA(bukrs) = /thkr/cl_data_store=>get( 'MVO' )->get_attr( key = 'BUKRS' ).
    TRY.
        DATA(mvoflag) = fields[ 2 ]-value.
        /thkr/cl_data_store=>get( 'MVO' )->set_attr( key = 'FLAG' value = CONV #( mvoflag ) ).
        UPDATE bkpf SET z_mvo_relevant = mvoflag WHERE bukrs = bukrs AND belnr = belnr AND gjahr = gjahr.
        IF sy-subrc <> 0.
          UPDATE vbkpf SET z_mvo_relevant = mvoflag WHERE bukrs = bukrs AND belnr = belnr AND gjahr = gjahr.
        ENDIF.
        IF sy-subrc = 0.
          COMMIT WORK AND WAIT.
        ELSE.
          ROLLBACK WORK.
        ENDIF.
      CATCH cx_sy_itab_line_not_found.
        "Nothing to save!
    ENDTRY.
  ENDIF.
ENDFORM.
