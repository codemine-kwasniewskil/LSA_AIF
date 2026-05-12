class /THKR/CL_MIG_PSM_MV_APPL definition
  public
  inheriting from /THKR/CL_PSM_MV_APPL
  create public .

public section.

  class-methods MIG_GET_INSTANCE
    returning
      value(R_INSTANCE) type ref to /THKR/CL_MIG_PSM_MV_APPL .
protected section.

  methods CHECK_MV_DATA
    redefinition .
private section.

  class-data INSTANCE type ref to /THKR/CL_MIG_PSM_MV_APPL .
ENDCLASS.



CLASS /THKR/CL_MIG_PSM_MV_APPL IMPLEMENTATION.


  METHOD check_mv_data.

* Call Super
    CALL METHOD super->check_mv_data
      CHANGING
        c_dto_psm_mv_bel_create = c_dto_psm_mv_bel_create
        c_head_data             = c_head_data
        c_pos_data              = c_pos_data.


** Migration Zusatzprüfungen


* Bei nicht übegebenen Sachkonto kann es bei der Ableitung aus der Finanzposition
* zum Aufruf einen Auswahl Popup kommen. Um das in der Migration zu verhindern,
* wird der Fall hier abgefangen.

    LOOP AT c_pos_data ASSIGNING FIELD-SYMBOL(<fs_pos_data>) WHERE fipos IS NOT INITIAL." AND saknr IS INITIAL.
      TRY.DATA(ls_kont) = c_dto_psm_mv_bel_create-t_kont[ 1 ].CATCH cx_sy_itab_line_not_found. ENDTRY.

      CALL FUNCTION '/THKR/MIG_FI_FM_ACCOUNT_DETERM'
        EXPORTING
          i_gjahr                 = c_dto_psm_mv_bel_create-budat+0(4)
          i_bukrs                 = c_dto_psm_mv_bel_create-bukrs
          i_fipex                 = ls_kont-fipex "CONV fm_fipex( <fs_pos_data>-fipos )
          i_saknr                 = ls_kont-hkont
          i_fistl                 = ls_kont-fistl
          i_geber                 = ls_kont-geber
          i_fkber                 = ls_kont-fkber
          i_blart                 = c_dto_psm_mv_bel_create-blart
        EXCEPTIONS
          account_not_found       = 1
          account_free_assignable = 2
          account_not_possible    = 3
          fipex_multible_saknr    = 4
          OTHERS                  = 5.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /thkr/cx_psm_int_fi
          MESSAGE ID sy-msgid NUMBER sy-msgno
          EXPORTING
            bapiret2 = VALUE #( type       = sy-msgty id         = sy-msgid number     = sy-msgno
                                message_v1 = sy-msgv1 message_v2 = sy-msgv2 message_v3 = sy-msgv3 message_v4 = sy-msgv4 ).
      ENDIF.



    ENDLOOP.






  ENDMETHOD.


  METHOD mig_get_instance.

    IF instance IS INITIAL.
      instance = NEW #( ).
    ENDIF.

    r_instance = instance.


  ENDMETHOD.
ENDCLASS.
