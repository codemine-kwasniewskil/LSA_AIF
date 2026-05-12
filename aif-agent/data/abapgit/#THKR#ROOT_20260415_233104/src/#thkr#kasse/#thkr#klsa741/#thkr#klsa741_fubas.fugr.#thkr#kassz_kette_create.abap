FUNCTION /THKR/KASSZ_KETTE_CREATE .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      T_RETURN STRUCTURE  BAPIRET2
*"      T_KETTE STRUCTURE  /THKR/KASSZ_KETT
*"----------------------------------------------------------------------
  TRY.

      NEW /thkr/cl_elko_appl( )->create_kassenz_kette( it_kette = t_kette[] ).

    CATCH /thkr/cx_elko INTO DATA(err). " Fehlerkasse Init.
      LOOP AT err->bapiret2_tab INTO t_return.
        CHECK t_return-type = 'E'.
        WRITE: |Type { t_return-type }: { t_return-message } |. NEW-LINE.
        APPEND t_return.
      ENDLOOP.
  ENDTRY.

ENDFUNCTION.
