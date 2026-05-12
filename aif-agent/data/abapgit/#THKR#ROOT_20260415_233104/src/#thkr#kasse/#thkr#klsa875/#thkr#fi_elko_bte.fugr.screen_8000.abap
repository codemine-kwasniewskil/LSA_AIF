PROCESS BEFORE OUTPUT.
  MODULE status_8000.
*
PROCESS AFTER INPUT.
*  FIELD /thkr/dynp_elko_bte-wdvdat
*       MODULE wvdata_check ON REQUEST.


  MODULE user_command_8000.

PROCESS ON VALUE-REQUEST.
  FIELD /thkr/dynp_elko_bte-formid      MODULE user_help_8000.
  FIELD /thkr/dynp_elko_bte-variant     MODULE user_help_8000.
