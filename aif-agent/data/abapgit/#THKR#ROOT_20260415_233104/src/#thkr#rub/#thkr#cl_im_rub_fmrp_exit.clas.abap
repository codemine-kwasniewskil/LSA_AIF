class /THKR/CL_IM_RUB_FMRP_EXIT definition
  public
  final
  create public .

public section.

  interfaces IF_EX_FMRP_RFFMEPGAX_EXIT .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_IM_RUB_FMRP_EXIT IMPLEMENTATION.


  method IF_EX_FMRP_RFFMEPGAX_EXIT~CHANGE_LIST_LINE.
  endmethod.


  METHOD if_ex_fmrp_rffmepgax_exit~change_list_table.

    DATA: lt_partner TYPE STANDARD TABLE OF bu_partner,
          ls_partner TYPE bu_partner.

    DATA: lv_object TYPE xuobject.

    lv_object = /thkr/cl_auth_check=>get_bupa_object( ).

    LOOP AT c_t_line_item ASSIGNING FIELD-SYMBOL(<fs_line>) WHERE kunnr IS NOT INITIAL OR lifnr IS NOT INITIAL.
      IF <fs_line>-kunnr IS NOT INITIAL.
        ls_partner = <fs_line>-kunnr.
      ELSEIF <fs_line>-lifnr IS NOT INITIAL.
        ls_partner = <fs_line>-lifnr.
      ELSE.
        CONTINUE.
      ENDIF.
      APPEND ls_partner TO lt_partner.
    ENDLOOP.

    SORT lt_partner ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_partner.

    LOOP AT lt_partner ASSIGNING FIELD-SYMBOL(<fs_partner>).

      DATA(lv_no_auth) = /thkr/cl_auth_check=>check_bupa_auth(
                        EXPORTING iv_partner = <fs_partner>
                          iv_object = lv_object
                              ).

      IF lv_no_auth = abap_true.

        DELETE c_t_line_item[] WHERE lifnr = <fs_partner> OR kunnr = <fs_partner>.

      ENDIF.

    ENDLOOP.

    IF lines( c_t_line_item[] ) = 0.
      MESSAGE 'Sie besitzen keine Berechtigungen für die Einzelbelege.' TYPE 'S'.
      LEAVE PROGRAM.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
