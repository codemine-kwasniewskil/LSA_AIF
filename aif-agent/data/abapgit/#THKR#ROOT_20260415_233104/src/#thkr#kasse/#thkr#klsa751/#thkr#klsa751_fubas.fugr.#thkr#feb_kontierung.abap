FUNCTION /thkr/feb_kontierung .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_AUGLV)
*"     REFERENCE(I_FEBEP) LIKE  FEBEP STRUCTURE  FEBEP
*"     REFERENCE(I_FEBKO) LIKE  FEBKO STRUCTURE  FEBKO
*"     REFERENCE(I_AREA) TYPE  T033F-EIGR2
*"  TABLES
*"      T_FEBCL STRUCTURE  FEBCL
*"      T_FEBRE STRUCTURE  FEBRE
*"      T_FTCLEAR STRUCTURE  FTCLEAR
*"      T_FTPOST STRUCTURE  FTPOST
*"      T_FTTAX STRUCTURE  FTTAX
*"----------------------------------------------------------------------
*--- Datendefintionen für Zusatzkontierungen
  DATA: lv_book  TYPE t033f-attr2,                " Buchungsart
        lv_count TYPE ftpost-count.

  DATA: ls_ftpost TYPE ftpost.


*--- 1. Ermittlung der Buchungsart aus der Kontenfindung für Buchungsbereich 1 oder 2
  SELECT SINGLE attr2 FROM t033f INTO lv_book WHERE anwnd = '0001'
                                                AND eigr1 = i_febep-vgint
                                                AND eigr2 = i_area
                                                AND eigr3 = space
                                                AND eigr4 = space.
*--- 2. Ermittlung der Buchungszeile
  CASE lv_book.
    WHEN '2'.
      lv_count = '002'.
    WHEN '1'.
      lv_count = '001'.
    WHEN OTHERS.
      lv_count = '001'.
  ENDCASE.

*--------------------------------------------------------------------------
  DATA: ls_kontierung TYPE zfi_kontierung.

  SELECT SINGLE gsber prctr geber fipex measure segment fkber
         INTO CORRESPONDING FIELDS OF ls_kontierung
         FROM /thkr/kontierung
         WHERE bukrs = i_febko-bukrs.


  DATA: o_desc TYPE REF TO cl_abap_structdescr.
  o_desc ?= cl_abap_structdescr=>describe_by_name( '/THKR/KONTIERUNG' ).
  DATA(lt_ddic_fields) = o_desc->get_ddic_field_list( ).

  LOOP AT lt_ddic_fields INTO DATA(ls_ddic_field) WHERE fieldname <> 'MANDT' AND fieldname <> 'BUKRS'. "#EC CI_STDSEQ
    ASSIGN COMPONENT ls_ddic_field-fieldname OF STRUCTURE ls_kontierung TO FIELD-SYMBOL(<v_value>).
    IF NOT <v_value> IS INITIAL.
      CONCATENATE 'COBL-' ls_ddic_field-fieldname INTO ls_ftpost-fnam.
      ls_ftpost-fval  = <v_value>.
      ls_ftpost-stype = 'P'.
      ls_ftpost-count = lv_count.
      APPEND ls_ftpost TO t_ftpost.
    ENDIF.
  ENDLOOP.
ENDFUNCTION.
