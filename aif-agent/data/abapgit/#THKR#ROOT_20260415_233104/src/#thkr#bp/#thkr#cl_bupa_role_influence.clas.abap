CLASS /thkr/cl_bupa_role_influence DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES if_ex_bupa_role_influence .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_BUPA_ROLE_INFLUENCE IMPLEMENTATION.


  METHOD if_ex_bupa_role_influence~influence_roles.
    IF cv_default_role IS INITIAL.
      GET PARAMETER ID 'BPOG' FIELD cv_default_role.
    ENDIF.
    CHECK cv_default_role IS NOT INITIAL.
    READ TABLE ct_possible_roles WITH KEY key = cv_default_role TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      CLEAR: cv_default_role, cv_number_group.
      SET PARAMETER ID 'BPP' FIELD space.
    ELSE.
      cv_number_group = /thkr/cl_bp_general=>get_bp_groupping( type          = iv_partner_type
                                                               role_grouping = cv_default_role ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
