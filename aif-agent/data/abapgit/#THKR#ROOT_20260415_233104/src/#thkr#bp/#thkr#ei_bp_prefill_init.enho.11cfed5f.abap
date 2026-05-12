"Name: \FU:BUP_BUPA_EVENT_ISSTA\SE:END\EI
ENHANCEMENT 0 /THKR/EI_BP_PREFILL_INIT.

DATA(group) = VALUE bu_bpkind( ).
IMPORT group = group FROM MEMORY ID 'GP_KIND'.

CALL FUNCTION 'BUP_BUPA_FIELDVALUES_SET'
  EXPORTING
    i_busdefault = /thkr/cl_bp_general=>get_bpdefault_values( bpgrp = group ).

ENDENHANCEMENT.
