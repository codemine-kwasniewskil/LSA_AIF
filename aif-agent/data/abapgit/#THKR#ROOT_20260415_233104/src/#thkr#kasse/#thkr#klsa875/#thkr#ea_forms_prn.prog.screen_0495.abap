PROCESS BEFORE OUTPUT.
MODULE STATUS_0495.
*
PROCESS AFTER INPUT.
  MODULE leave_dynpro AT EXIT-COMMAND.

  CHAIN.
    FIELD gv_bankl MODULE update_fields_0495 ON CHAIN-REQUEST.
    FIELD gv_email_addr  MODULE gv_email_addr_modify ON CHAIN-REQUEST.

  ENDCHAIN.

  MODULE user_command_0495.

PROCESS ON VALUE-REQUEST.
  FIELD gv_bankl MODULE get_bankl_banks_values_0495.
