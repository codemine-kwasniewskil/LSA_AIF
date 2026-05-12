CLASS /thkr/cl_bupa_number_group DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_ex_bupa_number_group .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_BUPA_NUMBER_GROUP IMPLEMENTATION.


  METHOD if_ex_bupa_number_group~valid_number_group.
    DATA(group) = /thkr/cl_bp_general=>get_bp_groupping( type          = iv_request->gs_navigation-bupa-creation_type
                                                         role_grouping = iv_request->gs_navigation-bupa-partner_role-role ).
    IF group IS NOT INITIAL.
      DELETE et_dropdown_values WHERE key <> group.
    ELSE.
      CLEAR et_dropdown_values.
    ENDIF.

    EXPORT group = group TO MEMORY ID 'GP_KIND'.
  ENDMETHOD.
ENDCLASS.
