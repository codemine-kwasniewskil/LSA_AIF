*----------------------------------------------------------------------*
***INCLUDE LZ_FI_ELKO_BTEI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_8000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_8000 input.


  case g_ok_code.
*    when 'REP_UPD_0'.
*      g_status = gc_0.
*      perform zzstatus_update using g_status.
*      clear: g_ok_code, g_status.
*    when 'REP_UPD_25'.
*      g_status = gc_25.
*      perform zzstatus_update using g_status.
*      clear: g_ok_code, g_status.
*   when 'REP_UPD_50'.
*      g_status = gc_50.
*      perform zzstatus_update using g_status.
*      clear: g_ok_code, g_status.
*    when 'REP_UPD_75'.
*      g_status = gc_75.
*      perform zzstatus_update using g_status.
*      clear: g_ok_code, g_status.
*   when 'REP_UPD_100'.
*      g_status = gc_100.
*      perform zzstatus_update using g_status.
*      clear: g_ok_code, g_status.
*   when 'REP_AV'.
*      perform zzavdata_update .
*      clear: g_ok_code.
*   when 'REP_WV'.
*
*      perform zzwvdata_update .
*      clear: g_ok_code.
    when 'REP_FORMS'.
      if /thkr/dynp_elko_bte-formid is initial or
         /thkr/dynp_elko_bte-variant is initial.
        message w002(/thkr/fi_nachr) with text-020.
      else.

      submit /thkr/ea_forms_prn
              with p_esnum  = g_febep-esnum
              with p_kukey  = g_febep-kukey
              with p_formid = /thkr/dynp_elko_bte-formid
              with p_vari   = /thkr/dynp_elko_bte-variant
              and return.

            g_febep_new = g_febep.
      endif.
      clear g_ok_code.
*    when 'REP_KASSZ'.
*      perform n2p_append.

* aktuell kein Bearbeitervermerk
**     when 'REP_BAVM'.
**      perform bavm_append.

*
*     when 'WL_ITEM_CHANGED'.
*       clear  g_febep_new.
  endcase.

endmodule.
*&---------------------------------------------------------------------*
*&      Module  USER_HELP_8000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_help_8000 input.

  perform form_values.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  WVDATA_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module wvdata_check input.
* perform wvdata_check.

endmodule.
