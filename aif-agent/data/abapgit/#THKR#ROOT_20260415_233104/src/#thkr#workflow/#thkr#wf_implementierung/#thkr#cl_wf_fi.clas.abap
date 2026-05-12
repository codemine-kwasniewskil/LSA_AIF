class /THKR/CL_WF_FI definition
  public
  final
  create public .

public section.

  class-methods READ_DATA
    importing
      !BUKRS type BUKRS
      !GJAHR type GJAHR
      !BELNR type BELNR_D
    exporting
      !T_BSEG_ADD type FAGL_T_BSEG_ADD
      !T_BSET type BSET_TAB
      !T_BSEG type BSEG_T
      !T_BSED type BSED_T
      !T_BSEC type BSEC_T
      !T_BKPF type BKPF_T
      !T_BKDF type FDCT_BKDF .
  class-methods SET_MAHNSPERRE_TO_NF
    importing
      !LOTKZ type LOTKZ
      !BUKRS type BUKRS
      !GJAHR type GJAHR .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_WF_FI IMPLEMENTATION.


  METHOD read_data.

    SELECT FROM bkpf
          FIELDS *
           WHERE belnr  = @belnr
           AND   bukrs  = @bukrs
           AND   gjahr  = @gjahr
          INTO TABLE @t_bkpf .               "#EC CI_ALL_FIELDS_NEEDED.

    SELECT FROM bseg
         FIELDS *
          WHERE belnr  = @belnr
          AND   bukrs  = @bukrs
          AND   gjahr  = @gjahr
         INTO TABLE @t_bseg .                "#EC CI_ALL_FIELDS_NEEDED.

    SELECT FROM bkdf
          FIELDS *
           WHERE belnr  = @belnr
           AND   bukrs  = @bukrs
           AND   gjahr  = @gjahr
          INTO TABLE @t_bkdf .

    SELECT FROM bsec                          "#EC CI_ALL_FIELDS_NEEDED
          FIELDS *
           WHERE belnr  = @belnr
           AND   bukrs  = @bukrs
           AND   gjahr  = @gjahr
          INTO TABLE @t_bsec .

    SELECT FROM bsed                          "#EC CI_ALL_FIELDS_NEEDED
          FIELDS *
           WHERE belnr  = @belnr
           AND   bukrs  = @bukrs
           AND   gjahr  = @gjahr
          INTO TABLE @t_bsed .

    SELECT FROM bset                          "#EC CI_ALL_FIELDS_NEEDED
          FIELDS *
           WHERE belnr  = @belnr
           AND   bukrs  = @bukrs
           AND   gjahr  = @gjahr
          INTO TABLE @t_bset .


    SELECT FROM bseg_add
         FIELDS *
          WHERE belnr  = @belnr
          AND   bukrs  = @bukrs
          AND   gjahr  = @gjahr
         INTO TABLE @t_bseg_add .                "#EC CI_ALL_FIELDS_NEEDED.


  ENDMETHOD.


  METHOD set_mahnsperre_to_nf.
    "** Stundung reread Nebenforderungen

    "** relevant types:
    SELECT SINGLE FROM bkpf
      FIELDS xblnr,
             blart
      WHERE lotkz = @lotkz
        AND bukrs = @bukrs
        AND gjahr = @gjahr
      INTO @DATA(ao).


    "** Need Kassz AND type = Stundung or Storno Stundung
    CHECK ao-xblnr IS NOT INITIAL
    AND   ( ao-blart = 'SD' OR ao-blart = 'SR' ).

    DATA(belarten) = VALUE bkk_r_blart( sign = 'I' option = 'EQ' ( low = 'GK' )
                                                                 ( low = 'GO' )
                                                                 ( low = 'HA' )
                                                                 ( low = 'HB' )
                                                                 ( low = 'HO' )
                                                                 ( low = 'MG' )
                                                                 ( low = 'MO' )
                                                                 ( low = 'SG' )
                                                                 ( low = 'SN' )
                                                                 ( low = 'VK' )
                                                                 ( low = 'VO' ) ).

    SELECT FROM /thkr/cds_bjcube AS c
      FIELDS c~knbelnr
            ,c~bukrs
            ,c~gjahr
      WHERE documentreferenceid    = @ao-xblnr
        AND accountingdocumenttype IN @belarten
        AND offenessoll            <> 0
      INTO TABLE @DATA(nf_list).

    LOOP AT nf_list INTO DATA(nf).

      read_data(
        EXPORTING
          bukrs      = nf-bukrs      " Buchungskreis
          gjahr      = nf-gjahr      " Geschäftsjahr
          belnr      = nf-knbelnr      " Belegnummer eines Buchhaltungsbeleges
        IMPORTING
          t_bseg_add = DATA(t_bseg_add) " Tabelle mit BSEG-Zeilen
          t_bset     = DATA(t_bset)     " Belegsegment Steuerdaten
          t_bseg     = DATA(t_bseg)    " Tabellenart für BSEG
          t_bsed     = DATA(t_bsed)    " Belegsegment Wechselfelder
          t_bsec     = DATA(t_bsec)    " Tabellentyp BSEC
          t_bkpf     = DATA(t_bkpf)    " Standard-Tabellentyp für die BKPF
          t_bkdf     = DATA(t_bkdf)
      ).

      READ TABLE t_bseg WITH KEY koart = 'D' ASSIGNING FIELD-SYMBOL(<bseg>).
      IF <bseg> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      <bseg>-mansp = COND #( WHEN ao-blart = 'SD' THEN '5' ELSE space ).

      CALL FUNCTION 'CHANGE_DOCUMENT'
        TABLES
          t_bkdf     = t_bkdf
          t_bkpf     = t_bkpf
          t_bsec     = t_bsec
          t_bsed     = t_bsed
          t_bseg     = t_bseg
          t_bset     = t_bset
          t_bseg_add = t_bseg_add.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
