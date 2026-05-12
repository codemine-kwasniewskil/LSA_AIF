PROCESS BEFORE OUTPUT.
* MODULE STATUS_9110.
  module pbo_auth_check_9110.
  MODULE pbo_9110.

PROCESS AFTER INPUT.

  MODULE pai_9110.

PROCESS ON VALUE-REQUEST.
  FIELD zfi_f_dto_nachr-kzbnart
     MODULE display_fields_9110.
