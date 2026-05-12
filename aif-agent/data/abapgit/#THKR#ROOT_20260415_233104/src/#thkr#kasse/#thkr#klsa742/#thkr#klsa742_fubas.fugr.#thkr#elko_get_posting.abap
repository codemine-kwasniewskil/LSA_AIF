FUNCTION /thkr/elko_get_posting.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_VGEXT) TYPE  VGEXT_EB
*"     REFERENCE(I_TEXTS) TYPE  TEXTS_EB
*"     REFERENCE(I_VOZEI) TYPE  EPVOZ_EB
*"     REFERENCE(I_BUTXT) TYPE  BUTXT_EB
*"     REFERENCE(I_KUKEY) TYPE  KUKEY_EB OPTIONAL
*"     REFERENCE(I_ESNUM) TYPE  ESNUM_EB OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_VGINT) TYPE  VGINT_EB
*"     REFERENCE(E_INTAG) TYPE  INTAG_EB
*"--------------------------------------------------------------------

  DATA: lv_vgint TYPE vgint_eb,
        lv_intag TYPE intag_eb.

  DATA: lt_butxt  TYPE TABLE OF butxt,
        lt_febre  TYPE TABLE OF febre,
        lv_butxt  TYPE butxt,
        lv_string TYPE string.

*--- Buchungsregel und evtl. Algorithmus aus Customizing bestimmen
  SELECT SINGLE vgint intag FROM /thkr/verw_br INTO ( lv_vgint, lv_intag ) WHERE vgext = i_vgext
                                                                           AND texts = i_texts
                                                                           AND vozei = i_vozei
                                                                           AND butxt = i_butxt.
  IF sy-subrc = 0.
    e_intag = lv_intag.
    e_vgint = lv_vgint.
    PERFORM build_message USING i_kukey i_esnum lv_vgint.
  ELSE.
*--- Lesen der Schlüsselwörter, falls keine Übereinstimmung mit dem Text existiert
    SELECT butxt FROM /thkr/verw_br INTO TABLE @lt_butxt WHERE vgext = @i_vgext.
    CLEAR lv_butxt.
*--- Suche im übergebenen Text BUTXT
    LOOP AT lt_butxt ASSIGNING FIELD-SYMBOL(<fs>).
      FIND <fs> IN i_butxt.
      IF sy-subrc = 0.
        lv_butxt = <fs>.
        EXIT.                                           "#EC CI_NOORDER
      ENDIF.
    ENDLOOP.
*--- evtl. Suche in FEBRE
    IF lv_butxt IS INITIAL.
      SELECT * FROM febre INTO TABLE lt_febre WHERE kukey = i_kukey
                                                AND esnum = i_esnum.
      CLEAR lv_string.
      LOOP AT lt_febre ASSIGNING FIELD-SYMBOL(<fs_febre>).
        CONCATENATE lv_string <fs_febre>-vwezw INTO lv_string.
      ENDLOOP.
      LOOP AT lt_butxt ASSIGNING <fs>.
        FIND <fs> IN lv_string.
        IF sy-subrc = 0.
          lv_butxt = <fs>.
          EXIT.                                         "#EC CI_NOORDER
        ENDIF.
      ENDLOOP.
    ENDIF.
    SELECT SINGLE vgint intag FROM /thkr/verw_br INTO ( lv_vgint, lv_intag ) WHERE vgext = i_vgext
                                                                             AND texts = i_texts
                                                                             AND vozei = i_vozei
                                                                             AND butxt = lv_butxt.
    IF sy-subrc = 0.
      e_intag = lv_intag.
      e_vgint = lv_vgint.
      PERFORM build_message USING i_kukey i_esnum lv_vgint.
    ENDIF.
  ENDIF.
ENDFUNCTION.

FORM build_message USING p_kukey TYPE febep-kukey
                         p_esnum TYPE febep-esnum
                         p_vgint TYPE febep-vgint.

  IF NOT p_kukey IS INITIAL.
    DATA: gv_esnum_str TYPE bapi_fld,
          lv_data(70)  TYPE c.

    FIELD-SYMBOLS: <fs_tab> TYPE bapiret2_t.
    lv_data = '(RFEBBU10)_t_bapiret2'.
    ASSIGN (lv_data) TO <fs_tab>.

    CLEAR gv_esnum_str.

    CONCATENATE 'ESNUM' p_esnum p_kukey INTO gv_esnum_str.

    PERFORM bapi_message
            TABLES <fs_tab>
            USING  '/THKR/ELKO' 'S' '001' p_vgint
                   space space space space '0' gv_esnum_str.
  ENDIF.
ENDFORM.

FORM bapi_message
  TABLES p_return STRUCTURE bapiret2
  USING  VALUE(p_class)     TYPE symsgid
         VALUE(p_type)      TYPE symsgty
         VALUE(p_number)    TYPE symsgno
         VALUE(p_par1)
         VALUE(p_par2)
         VALUE(p_par3)
         VALUE(p_par4)
         VALUE(p_parameter) TYPE bapi_param
         VALUE(p_row)       TYPE bapi_line
         VALUE(p_field)     TYPE bapi_fld.
*         E_FLAG             TYPE XFLAG.
  CONSTANTS:
    msg_warning LIKE sy-msgty VALUE 'W',
    msg_ok      LIKE sy-msgty VALUE 'S',
    msg_abort   LIKE sy-msgty VALUE 'A',
    msg_error   LIKE sy-msgty VALUE 'E'.
  DATA: ld_par1   TYPE symsgv,
        ld_par2   TYPE symsgv,
        ld_par3   TYPE symsgv,
        ld_par4   TYPE symsgv,
        ld_class  TYPE symsgid,
        ld_type   TYPE symsgty,
        ld_number TYPE symsgno,
        ls_return TYPE bapiret2.

  IF p_type IS INITIAL.
    ld_type  = msg_error.
  ELSE.
    ld_type  = p_type.
  ENDIF.
  IF p_class IS INITIAL OR p_number IS INITIAL.
*    LD_CLASS  = MESSAGE_ID.
*    LD_NUMBER = UNKNOWN_ERROR.
  ELSE.
    ld_class  = p_class.
    ld_number = p_number.
  ENDIF.

  IF p_type = 'E' OR p_type = 'A'.
*    E_FLAG = 'X'.
  ENDIF.

  ld_par1 = p_par1.
  ld_par2 = p_par2.
  ld_par3 = p_par3.
  ld_par4 = p_par4.

  CALL FUNCTION 'BALW_BAPIRETURN_GET2'
    EXPORTING
      type      = ld_type
      cl        = ld_class
      number    = ld_number
      par1      = ld_par1
      par2      = ld_par2
      par3      = ld_par3
      par4      = ld_par4
      parameter = p_parameter
      row       = p_row
      field     = p_field
    IMPORTING
      return    = ls_return.

  IF p_field(5) = 'ESNUM'.                                  "n1841192
    MOVE p_field+5(5) TO ls_return-log_msg_no.
    CONCATENATE 'KUKEY' p_field+10(8) INTO ls_return-field.
    CLEAR p_field.                                          "n1950441
  ENDIF.

  APPEND ls_return TO p_return.

ENDFORM.                    "BAPI_MESSAGE
