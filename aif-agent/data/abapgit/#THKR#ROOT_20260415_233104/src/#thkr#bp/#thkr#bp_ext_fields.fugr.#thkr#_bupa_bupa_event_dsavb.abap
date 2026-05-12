FUNCTION /THKR/_BUPA_BUPA_EVENT_DSAVB.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------

 DATA: ls_but000 LIKE but000.
  DATA: lv_fgrp_stat LIKE bus000flds-fldstat.
  CONSTANTS: lc_fldgr TYPE bu_fldgr VALUE '0601'.

* If NV field group is suppressed, do not
* overwrite natpers flag.
  CALL FUNCTION 'BUS_FMOD_STATUS_GET'
    EXPORTING
*     I_OBJAP  =
      i_fldgr  = lc_fldgr
*     I_XVIEWS = 'X'
    IMPORTING
      e_status = lv_fgrp_stat.
  IF lv_fgrp_stat <> gc_fstat_suppressed.
    ls_but000-/THKR/gsber = gv_zzgsber.
*    ls_but000-/THKR/SST = gv_rfc.
    IF ls_but000-/THKR/GSBER IS NOT INITIAL.
*      ls_but000-zzgsber = gv_zzgsber.
    ENDIF.
    ls_but000-/THKR/sst = gv_zzsst.
    IF ls_but000-/THKR/GSBER IS NOT INITIAL.

    ENDIF.

    CALL FUNCTION 'BUP_BUPA_BUT000_COLLECT'
      EXPORTING
        i_subname = '/THKR/S_INC1_BUT'
        i_but000  = ls_but000.
  ENDIF.


ENDFUNCTION.
