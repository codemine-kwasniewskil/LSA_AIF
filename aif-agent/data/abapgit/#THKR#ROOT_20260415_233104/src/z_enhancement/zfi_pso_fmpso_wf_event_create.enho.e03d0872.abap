"Name: \FU:FI_PSO_FMPSO_WF_EVENT_CREATE\SE:BEGIN\EI
ENHANCEMENT 0 ZFI_PSO_FMPSO_WF_EVENT_CREATE.

*  CALL METHOD zcl_klsa856=>get_and_write_ao
*    EXPORTING
*      i_lotkz = g_f_memory-lotkz
*      i_bukrs = g_f_memory-ausbk.
*      .
  CALL METHOD zcl_klsa856=>get_and_write_ao
    EXPORTING
      i_lotkz = i_lotkz
      i_bukrs = i_ausbk.
      .


ENDENHANCEMENT.
