FUNCTION /THKR/_BUPA_BUPA_EVENT_ISSTA.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------

*------------------------------Local Data------------------------------*
  DATA: lv_flag LIKE boole-boole.

*-------------------------------Function Body--------------------------*

*------ Startparameter for Ident. Number(bpid001)---------------------*

  CALL FUNCTION 'BUS_PARAMETERS_ISSTA_GET'
    IMPORTING
      e_aktyp    = gv_aktyp
      e_xsave    = gv_xsave
      e_xinit    = gv_xinit
      e_xdinp    = gv_xdinp
      e_xupdtask = gv_xupdtask
      e_nodata   = gs_current_control-nodata
      e_xchdoc   = gv_xchdoc
    TABLES
      t_fldvl    = t_fldvl.
  CALL FUNCTION 'BUP_BUPA_BPROLES_GET'
    TABLES
      t_bproles = t_roles.
  gs_current_control-aktyp    = gv_aktyp.
  gs_current_control-xsave    = gv_xsave.
  gs_current_control-xinit    = gv_xinit.
  gs_current_control-xupdtask = gv_xupdtask.
  gs_current_control-xdinp    = gv_xdinp.
*------ Flag für phonetischen Strings clearen ------
  CLEAR: gv_flg_fs01_dsave_processed.



ENDFUNCTION.
