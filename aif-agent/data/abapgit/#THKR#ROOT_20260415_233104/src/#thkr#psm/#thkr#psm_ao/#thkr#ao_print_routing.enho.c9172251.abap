"Name: \FU:FM_WRITE_ANORDNUNG\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/AO_PRINT_ROUTING.
  "** The fields PSOTY is missing in structure l_t_ifmkanor.
  "** To access the global VBKPF in init_script_form we gonna prefill it here:
  TRY.
      vbkpf = t_vbkpf[ 1 ].
    CATCH cx_sy_itab_line_not_found.
      "nothing to do
  ENDTRY.

ENDENHANCEMENT.
