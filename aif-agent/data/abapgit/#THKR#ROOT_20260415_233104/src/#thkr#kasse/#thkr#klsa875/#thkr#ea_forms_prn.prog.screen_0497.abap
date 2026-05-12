PROCESS BEFORE OUTPUT.
  MODULE status_0480.

PROCESS AFTER INPUT.
  MODULE leave_dynpro AT EXIT-COMMAND.

  CHAIN.
    FIELD gv_fictr MODULE update_fields_0480 ON CHAIN-REQUEST.
  ENDCHAIN.
  CHAIN.
    FIELD gv_email_addr  MODULE gv_email_addr_modify ON CHAIN-REQUEST.
  ENDCHAIN.

  MODULE update_faxnr_0480.

  MODULE user_command_0480.
