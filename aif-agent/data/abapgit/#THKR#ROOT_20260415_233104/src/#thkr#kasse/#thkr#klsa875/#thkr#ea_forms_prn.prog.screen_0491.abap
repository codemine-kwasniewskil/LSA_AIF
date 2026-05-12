PROCESS BEFORE OUTPUT.
  MODULE status_0507.

PROCESS AFTER INPUT.
  MODULE leave_dynpro AT EXIT-COMMAND.

  CHAIN.
    FIELD gv_ao_kassze MODULE update_fields_0491 ON CHAIN-REQUEST.
  ENDCHAIN.

*  CHAIN.
*    FIELD gv_fictr MODULE update_fields_0507 ON CHAIN-REQUEST.
*  ENDCHAIN.
*  CHAIN.
*    FIELD gs_fp_data-status MODULE update_address_0507 ON
* CHAIN-REQUEST.
*  ENDCHAIN.
  CHAIN.
    FIELD gv_email_addr  MODULE gv_email_addr_modify ON CHAIN-REQUEST.
  ENDCHAIN.

  MODULE user_command_0507.
