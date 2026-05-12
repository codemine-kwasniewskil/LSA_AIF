class /THKR/CL_IM_ELKO_KIDICAP_BZG definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_FIEB_GET_BANK_STMTS_X .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_IM_ELKO_KIDICAP_BZG IMPLEMENTATION.


  method IF_FIEB_GET_BANK_STMTS_X~PARSE.

    es_log_file-bank_id           = '81000000'.
    es_log_file-bank_account      = '0081001540'.
    es_log_file-bank_statement_id = |{ i_string+0(2) }{ i_string+3(3) }{ sy-datum+2(6) }{ sy-uzeit }|.

  endmethod.


  METHOD if_fieb_get_bank_stmts_x~split.

    et_string = VALUE #( ( i_string ) ).

  ENDMETHOD.
ENDCLASS.
