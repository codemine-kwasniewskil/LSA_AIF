PROCESS BEFORE OUTPUT.

  MODULE gtc_email_addr_change_tc_attr.

  LOOP AT   gt_email_addr
       INTO gs_email_addr
       WITH CONTROL gtc_email_addr
       CURSOR gtc_email_addr-current_line.

  ENDLOOP.
*
PROCESS AFTER INPUT.

  LOOP AT gt_email_addr.
    CHAIN.
      FIELD gs_email_addr-receiver.
      MODULE gtc_email_addr_modify ON CHAIN-REQUEST.
    ENDCHAIN.
  ENDLOOP.

  MODULE user_command_0105.
