PROCESS BEFORE OUTPUT.
  MODULE status_0509.

PROCESS AFTER INPUT.
  MODULE leave_dynpro AT EXIT-COMMAND.

  CHAIN.
    FIELD gv_fictr MODULE update_fields_0509 ON CHAIN-REQUEST.
  ENDCHAIN.
  CHAIN.
    FIELD gv_email_addr  MODULE gv_email_addr_modify ON CHAIN-REQUEST.
  ENDCHAIN.

  MODULE user_command_0509.
