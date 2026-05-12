CLASS /THKR/CL_HLP DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    CLASS-METHODS get_incl_range
      IMPORTING vals           TYPE /thkr/t_char_tab
      RETURNING VALUE(rangtab) TYPE /thkr/t_gen_range .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_HLP IMPLEMENTATION.


  METHOD get_incl_range.
    rangtab = VALUE #( FOR val IN vals ( sign = cl_abap_range=>sign-including option = cl_abap_range=>option-equal low = val ) ).
  ENDMETHOD.
ENDCLASS.
