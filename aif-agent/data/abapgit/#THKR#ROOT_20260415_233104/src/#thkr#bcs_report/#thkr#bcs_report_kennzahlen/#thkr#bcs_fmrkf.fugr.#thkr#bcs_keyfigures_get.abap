FUNCTION /thkr/bcs_keyfigures_get.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_F_DATA) TYPE  ANY
*"     VALUE(I_DATATYPE) TYPE  BUKF_DATASOURCE
*"     REFERENCE(I_ZERO) TYPE  XFELD OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_T_KEYFIGS) TYPE  FMRKF_T_KEYFIG
*"----------------------------------------------------------------------

  DATA: l_f_keyfigs     TYPE fmrkf_s_keyfig,
        l_f_kfds        TYPE type_kfds,
        l_formname(30)  TYPE c,
        l_f_keyfigs_old TYPE fmrkf_s_keyfig.



  LOOP AT g_t_kfds INTO l_f_kfds WHERE datasource = i_datatype.
    l_f_keyfigs-keyfig = l_f_kfds-keyfig.
    l_formname = 'CHK_'.
    WRITE i_datatype TO l_formname+4.
    l_formname+8 = l_f_kfds-keyfig.

* to get lines with value 0,00, for example from FMJO, we need a special
* logic because zero values are not taken over by default
    IF i_datatype = '0002'.

      FIELD-SYMBOLS: <fs_data> TYPE fmtox.
      ASSIGN i_f_data TO <fs_data>.
      l_f_keyfigs_old-value = <fs_data>-fkbtrp.

      PERFORM (l_formname) IN PROGRAM (g_formpool)
                           USING i_f_data
                           CHANGING l_f_keyfigs-value.

      CHECK NOT l_f_keyfigs-value IS INITIAL OR
                ( i_zero = 'X' AND
                  l_f_keyfigs-value = l_f_keyfigs_old-value )." AND
*                <fs_data>-btart = '0350' ).
      COLLECT l_f_keyfigs INTO e_t_keyfigs.
      CLEAR l_f_keyfigs-value.

    ELSE.

      PERFORM (l_formname) IN PROGRAM (g_formpool)
                           USING i_f_data
                        CHANGING l_f_keyfigs-value.

      CHECK NOT l_f_keyfigs-value IS INITIAL OR
                 i_zero = 'X'.
      COLLECT l_f_keyfigs INTO e_t_keyfigs.
      CLEAR l_f_keyfigs-value.

    ENDIF.
  ENDLOOP.

ENDFUNCTION.
