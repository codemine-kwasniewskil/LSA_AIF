FUNCTION /THKR/BP_F4IF_SHLP_EXIT_DEBI.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------

CONSTANTS: param TYPE CHAR30 VALUE 'KUNNR'.

CALL FUNCTION '/THKR/BP_F4IF_SHLP_EXIT_DISP'
  EXPORTING
    iv_param          = param
  tables
    shlp_tab          = shlp_tab
    record_tab        = record_tab
  CHANGING
    shlp              = shlp
    callcontrol       = callcontrol
          .



ENDFUNCTION.
