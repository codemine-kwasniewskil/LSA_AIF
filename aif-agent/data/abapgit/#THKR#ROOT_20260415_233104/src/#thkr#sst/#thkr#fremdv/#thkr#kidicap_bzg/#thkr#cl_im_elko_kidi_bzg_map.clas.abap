class /THKR/CL_IM_ELKO_KIDI_BZG_MAP definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_FIEB_MAPPING_X .
protected section.

  methods GET_KIDICAP_CUST
    importing
      !I_STRING type STRING
    returning
      value(CUSTOMIZING) type /THKR/SST_KIDICAP_BZG_CUST .
  methods GET_FEBKO_DATA
    importing
      !I_STRING type STRING
    returning
      value(FEBKO) type FEBKO_TY .
  methods GET_FEBEP_LINE
    importing
      !VERWZW type STRING
      !BETRAG type KWBTR_EB
      !VORZEICHEN type CHAR1 default 'S'
    returning
      value(ITEM) type ITEM_FEB .
private section.
ENDCLASS.



CLASS /THKR/CL_IM_ELKO_KIDI_BZG_MAP IMPLEMENTATION.


  METHOD if_fieb_mapping_x~mapp_bank_statement.
    DATA(line)    = VALUE /thkr/sst_kidicap_bzg_income( ).
    DATA(summe) = VALUE kwbtr_eb( )..

** Get Customizing
    DATA(cust) = me->get_kidicap_cust( i_string = i_string ).
    IF cust IS INITIAL.
      RAISE not_possible.
    ENDIF.

** Generate Header
    ct_acct_statement = VALUE #( ( febko = me->get_febko_data( i_string ) ) ).
    TRY.
** Split lines from txt and process per line as febep:
        SPLIT i_string AT cl_abap_char_utilities=>cr_lf INTO TABLE DATA(lines).
        LOOP AT lines INTO DATA(stringline).
          CHECK stringline IS NOT INITIAL.
          SPLIT stringline AT ';' INTO line-bzg line-type line-verwzw line-buchungsstelle line-bzg_kassz line-betrag .
          DATA(betrag) = CONV kwbtr_eb( replace( val = line-betrag sub = ',' with = '.' ) ).

          DATA(item) = me->get_febep_line( betrag = betrag vorzeichen = cust-vorz_line verwzw = |{ line-bzg_kassz } { line-verwzw }| ).
          ct_acct_statement[ 1 ]-items_feb = VALUE #( BASE ct_acct_statement[ 1 ]-items_feb ( item )  ) .

          summe += betrag.
        ENDLOOP.
      CATCH cx_sy_conversion_no_number.
        et_bapiret = VALUE #( ( type = 'E' message = 'Datei ist fehlerhaft.' ) ).
        RAISE not_possible.
    ENDTRY.

** Add last line with sum
    item = me->get_febep_line( betrag = summe vorzeichen = cust-vorz_summe verwzw = CONV #( cust-ao_kz ) ).
    ct_acct_statement[ 1 ]-items_feb = VALUE #( BASE ct_acct_statement[ 1 ]-items_feb ( item )  ) .
    ct_acct_statement[ 1 ]-febko-sumha = REDUCE #( INIT sum TYPE kwbtr FOR febitem IN ct_acct_statement[ 1 ]-items_feb WHERE ( febep-epvoz = 'H' ) NEXT sum += febitem-febep-kwbtr ).
    ct_acct_statement[ 1 ]-febko-sumso = REDUCE #( INIT sum TYPE kwbtr FOR febitem IN ct_acct_statement[ 1 ]-items_feb WHERE ( febep-epvoz = 'S' ) NEXT sum += febitem-febep-kwbtr )..
    ct_acct_statement[ 1 ]-febko-esbtr = 0.

  ENDMETHOD.


  METHOD get_febko_data.
    febko = VALUE #( azidt   = |{ i_string+0(2) }{ i_string+3(3) }{ sy-datum+2(6) }{ sy-uzeit }|
                     bankkey = '81000000'
                     bankacc = '0081001540'
                     hkont   = '2810450500'
                     hbkid   = 'BBKSO'
                     hktid   = '4505' ).
    febko-aznum = |{ sy-datum+2(6) }{ sy-uzeit }|.
  ENDMETHOD.


  METHOD get_febep_line.

    IF betrag >= 0.
      data(new_vorz) = vorzeichen.
    ELSEIF betrag < 0.
      IF vorzeichen = 'H'.
          new_vorz = 'S'.
       else.
          new_vorz = 'H'.
      ENDIF.
    ENDIF.

    item  = VALUE item_feb( febep-kwaer = 'EUR'
                            febep-kwbtr = abs( betrag )
                            febep-vozei = COND #( WHEN new_vorz = 'S' THEN 'D' ELSE 'C' )
                            febep-epvoz = new_vorz
                            febep-valut = sy-datum
                            febep-vgext = COND #( WHEN new_vorz = 'S' THEN '05 000' ELSE '51 000' )
                            vwezw       = VALUE #( ( vwezw = verwzw ) ) ).

  ENDMETHOD.


  METHOD get_kidicap_cust.

** Get customizing:
    SELECT SINGLE FROM /thkr/kidcap_bzg
       FIELDS
          annao_kz
         ,ausao_kz
         ,epvoz
       WHERE bzg      = @i_string+0(2) "K1
          AND process = @i_string+3(3) "ABS
       INTO @DATA(kidicap_cust).

    customizing = VALUE #( ao_kz      = COND #( WHEN kidicap_cust-epvoz = 'S' THEN kidicap_cust-annao_kz ELSE kidicap_cust-ausao_kz )
                           vorz_line  = kidicap_cust-epvoz
                           vorz_summe = COND #( WHEN kidicap_cust-epvoz = 'S' THEN 'H' ELSE 'S' ) ).

  ENDMETHOD.
ENDCLASS.
