
CLASS lcl_events IMPLEMENTATION.
*  METHOD on_double_click.
*    MESSAGE | { row } , { column } | TYPE 'I'.
*  ENDMETHOD.
  METHOD on_link_click.
    DATA: bdcdata_tab TYPE TABLE OF bdcdata,
          opt         TYPE ctu_params.
    READ TABLE gt_result INTO DATA(e_result) INDEX row.
    IF NOT e_result IS INITIAL.
      CASE column.
        WHEN 'KNBELNR'.
          bdcdata_tab = VALUE #(
              ( program  = 'SAPMF05L' dynpro   = '0100' dynbegin = 'X' )
              ( fnam = 'RF05L-BELNR' fval = e_result-knbelnr )
              ( fnam = 'RF05L-BUKRS' fval = e_result-bukrs )
              ( fnam = 'RF05L-GJAHR' fval = e_result-kngjahr )
              ( fnam = 'BDC_OKCODE'       fval = '=WEITE' ) ).

          opt-dismode = 'E'.
*        opt-defsize = 'X'.
          TRY.
              CALL TRANSACTION 'FB03' WITH AUTHORITY-CHECK  USING bdcdata_tab OPTIONS FROM opt.
            CATCH cx_sy_authorization_error.
                    MESSAGE i049 WITH 'FB03'.
          ENDTRY.
        WHEN 'AUGBL'.
          bdcdata_tab = VALUE #(
              ( program  = 'SAPMF05L' dynpro   = '0100' dynbegin = 'X' )
              ( fnam = 'RF05L-BELNR' fval = e_result-augbl )
              ( fnam = 'RF05L-BUKRS' fval = e_result-bukrs )
              ( fnam = 'RF05L-GJAHR' fval = e_result-auggj )
              ( fnam = 'BDC_OKCODE'       fval = '=WEITE' ) ).

          opt-dismode = 'E'.

          TRY.
              CALL TRANSACTION 'FB03' WITH AUTHORITY-CHECK USING bdcdata_tab OPTIONS FROM opt.
            CATCH cx_sy_authorization_error.
                    MESSAGE i049 WITH 'FB03'.
          ENDTRY.
      ENDCASE.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
