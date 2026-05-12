FUNCTION /thkr/bcs_keyfigures_get_all.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      T_KEYFIGS STRUCTURE  BUKF_KFDSRC
*"  EXCEPTIONS
*"      NO_KEYFIGERS
*"----------------------------------------------------------------------

  DATA l_f_kfds TYPE type_kfds.

*  if g_t_kfds[] is initial.
** "/ ggf. Kennzahlen nachlesen
*    call function 'FMRKF_INIT'
*         exporting
*              i_gjahr = i_gjahr.
*
*
*  endif.

  IF g_t_kfds[] IS INITIAL.
    RAISE no_keyfigers.
  ELSE.

    LOOP AT g_t_kfds INTO l_f_kfds.
* "/ Kennzahlen zurueckliefern
      MOVE-CORRESPONDING l_f_kfds TO t_keyfigs.
      APPEND t_keyfigs.
    ENDLOOP.

  ENDIF.


ENDFUNCTION.
