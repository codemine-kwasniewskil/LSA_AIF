*&---------------------------------------------------------------------*
*& Report /THKR/MIG_RK_KETT_MAHNST
*&---------------------------------------------------------------------*
*& Dieser Korrektur-Report soll alle <KASSENZEICHEN> aus dem Datenbestand Mig-RK ermitteln,
*& die in ProFiskal verkettet waren, d.h. die <KEZ_KENN_KENNZ> ungleich 0 haben
*&---------------------------------------------------------------------*
REPORT /thkr/mig_rk_kett_mahnst.


TYPES: BEGIN OF ty_message,
         type      TYPE syst-msgty,
         bukrs     TYPE bukrs,
         xblnr     TYPE xblnr,
         mansp     TYPE mansp,
         mahns_old TYPE mahns_d,
         mahns_new TYPE mahns_d,
         message   TYPE char100,
         msgid     TYPE syst_msgid,
         msgno     TYPE syst_msgno,
         cnt       TYPE int4,
       END OF ty_message.

DATA:
  gv_bukrs    TYPE bukrs,
  gv_xblnr    TYPE xblnr,
  gv_mansp    TYPE mansp,
  gv_mahns_d  TYPE mahns_d,
  gt_messages TYPE TABLE OF ty_message.


SELECT-OPTIONS:
            so_bukrs FOR gv_bukrs,
            so_xblnr FOR gv_xblnr,
            so_mansp FOR gv_mansp,
            so_manst FOR gv_mahns_d DEFAULT '2' OPTION LT.

PARAMETERS:
            p_test TYPE flag.

INITIALIZATION.
  APPEND VALUE #( sign = 'I' option = 'EQ' low = 'R090' ) TO so_bukrs[].
  APPEND VALUE #( sign = 'I' option = 'EQ' low = 'E' ) TO so_mansp[].
  APPEND VALUE #( sign = 'I' option = 'EQ' low = 'F' ) TO so_mansp[].
  APPEND VALUE #( sign = 'I' option = 'EQ' low = 'G' ) TO so_mansp[].


AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name CS 'SO_MANST'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


START-OF-SELECTION.
  DATA:
        lt_accchg TYPE table_type_accchg.

* selektion der Daten
  SELECT * FROM /thkr/migd_rk INTO TABLE @DATA(lt_rk) WHERE kez_kett_kennz <> 0 AND kassenzeichen IN @so_xblnr.

  SELECT * FROM bsid_view INTO TABLE @DATA(lt_bsid) FOR ALL ENTRIES IN @lt_rk
    WHERE xblnr = @lt_rk-kassenzeichen AND bukrs IN @so_bukrs AND mansp IN @so_mansp AND manst IN @so_manst.

  LOOP AT lt_bsid ASSIGNING FIELD-SYMBOL(<fs_bsid>).
    CLEAR lt_accchg.
    APPEND VALUE #(
                   fdname = 'MANST'
                   oldval = <fs_bsid>-manst
                   newval = so_manst-low
                  ) TO lt_accchg.


    CALL FUNCTION 'FI_DOCUMENT_CHANGE'
      EXPORTING
        x_lock               = 'X'
        i_bukrs              = <fs_bsid>-bukrs
        i_belnr              = <fs_bsid>-belnr
        i_gjahr              = <fs_bsid>-gjahr
        i_buzei              = <fs_bsid>-buzei
      TABLES
        t_accchg             = lt_accchg
      EXCEPTIONS
        no_reference         = 1
        no_document          = 2
        many_documents       = 3
        wrong_input          = 4
        overwrite_creditcard = 5
        OTHERS               = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO DATA(lv_msg).
      APPEND VALUE #(
                      type      = sy-msgty
                      bukrs     = <fs_bsid>-bukrs
                      xblnr     = <fs_bsid>-xblnr
                      mansp     = <fs_bsid>-mansp
                      mahns_old = <fs_bsid>-manst
                      mahns_new = so_manst-low
                      message   = lv_msg
                      msgid     = sy-msgid
                      msgno     = sy-msgno
                      cnt       = 1
                    ) TO gt_messages.
    ELSE.
      APPEND VALUE #(
                      type      = 'S'
                      bukrs     = <fs_bsid>-bukrs
                      xblnr     = <fs_bsid>-xblnr
                      mansp     = <fs_bsid>-mansp
                      mahns_old = <fs_bsid>-manst
                      mahns_new = so_manst-low
                      message   = |Mahnstufe auf { so_manst-low } geändert.|
                      cnt       = 1
                    ) TO gt_messages.
    ENDIF.
  ENDLOOP.

  IF  p_test IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
  ENDIF.

* Ausgabe
  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_salv)
                              CHANGING  t_table      = gt_messages ).

      SET PARAMETER ID 'EXCEL_INPLACE' FIELD space.
      lo_salv->get_functions( )->set_all( abap_true ).
      lo_salv->get_columns( )->set_optimize( abap_true ).
      lo_salv->get_columns( )->get_column( 'MAHNS_OLD' )->set_short_text( 'Alt' ).
      lo_salv->get_columns( )->get_column( 'MAHNS_OLD' )->set_long_text( 'MAHNS Alt' ).
      lo_salv->get_columns( )->get_column( 'MAHNS_OLD' )->set_medium_text( 'MAHNS Alt' ).
      lo_salv->get_columns( )->get_column( 'CNT' )->set_short_text( 'Zähler' ).
      lo_salv->get_columns( )->get_column( 'CNT' )->set_long_text( 'Zähler' ).
      lo_salv->get_columns( )->get_column( 'CNT' )->set_medium_text( 'Zähler' ).
      lo_salv->get_columns( )->get_column( 'MESSAGE' )->set_short_text( 'Nachricht' ).
      lo_salv->get_columns( )->get_column( 'MESSAGE' )->set_long_text( 'Nachricht' ).
      lo_salv->get_columns( )->get_column( 'MESSAGE' )->set_medium_text( 'Nachricht' ).

      lo_salv->display( ).

    CATCH cx_root INTO DATA(lx_txt).
      WRITE: / lx_txt->get_text( ).
  ENDTRY.
