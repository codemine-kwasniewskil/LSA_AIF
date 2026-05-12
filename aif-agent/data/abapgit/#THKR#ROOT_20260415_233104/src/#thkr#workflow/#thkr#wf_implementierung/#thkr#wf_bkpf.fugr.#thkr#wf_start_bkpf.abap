FUNCTION /THKR/WF_START_BKPF.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IS_FB02) TYPE  /THKR/FB02C
*"  EXCEPTIONS
*"      NO_WORKFLOW_START
*"      BEREITS_OFFENER_WORKFLOW
*"----------------------------------------------------------------------

DATA:
      lv_event  type  swo_event,
      lv_task    TYPE  swd_step_t,
      lv_objtype type swo_objtyp,
      lv_objkey  type  swo_typeid.


*    IF im_eban-estkz   = 'B' or im_eban-estkz   = 'U'.

      lv_event = 'zstarted'.
      lv_task = 'WS90100010'.
      lv_objtype = '/THKR/BKPF'.

    concatenate  IS_FB02-bukrs  IS_FB02-belnr IS_FB02-gjahr into lv_objkey .

      CALL FUNCTION 'SWE_EVENT_CREATE'
        EXPORTING
          objtype              = lv_objtype
          objkey               = lv_objkey
          event                = lv_event
          start_recfb_synchron = 'X'
        EXCEPTIONS
          objtype_not_found    = 1
          OTHERS               = 2.
      IF sy-subrc <> 0.
*        xxx
        endif.



ENDFUNCTION.
