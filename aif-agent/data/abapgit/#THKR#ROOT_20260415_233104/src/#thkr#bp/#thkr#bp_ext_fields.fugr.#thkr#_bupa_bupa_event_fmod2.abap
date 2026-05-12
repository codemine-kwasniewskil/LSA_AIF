FUNCTION /thkr/_bupa_bupa_event_fmod2.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(FLDGR) TYPE  TBZ3W-FLDGR
*"     REFERENCE(IN_STATUS) TYPE  BUS000FLDS-FLDSTAT OPTIONAL
*"  EXPORTING
*"     VALUE(OUT_STATUS) TYPE  BUS000FLDS-FLDSTAT
*"----------------------------------------------------------------------
* Bedeutung der Kürzel zum Feldstatus
*       +	Mußeingabe
*       .	Kanneingabe
*       *	Anzeige
*       -	Ausgeblendet


  DATA ls_but000 TYPE but000.
*if g_current_type eq '1'.
*
*  out_status = in_status.
*  Else .
*  out_Status = '-'.
*  Endif.

  IF screen-name = '/THKR/S_INC1_BUT-/THKR/GSBER' OR FLDGR = '601'.
    IF gs_current_control-aktyp EQ '01'.
             "gs_current_control-aktyp EQ '02'.

      out_status = '+'.
    ELSE.
      out_status = '*'.
    ENDIF.
  ENDIF.

*  IF fldgr = '601'.
*    IF gs_current_control-aktyp EQ '01' OR
*             gs_current_control-aktyp EQ '02'.
*
*      out_status = '+'.
*    ELSE.
*      out_status = '*'.
*    ENDIF.
*  ELSE.
*    out_status = '*'.
*  ENDIF.

*   IF screen-name = '/THKR/S_INC1_BUT-/THKR/SST'.
*    IF gs_current_control-aktyp EQ '01' OR
*             gs_current_control-aktyp EQ '02'.
*
*      out_status = '+'.
*    ELSE.
*      out_status = '*'.
*    ENDIF.
*  ENDIF.



ENDFUNCTION.
