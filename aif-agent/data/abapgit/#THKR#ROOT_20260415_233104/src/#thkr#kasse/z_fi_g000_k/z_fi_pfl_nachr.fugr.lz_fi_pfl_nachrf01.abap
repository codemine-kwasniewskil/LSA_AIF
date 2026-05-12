*----------------------------------------------------------------------*
***INCLUDE LZ_FI_PFL_NACHRF01.
*----------------------------------------------------------------------*
FORM zz_create_bnkey.

  DATA: l_uuid    TYPE sysuuid_c32.

* Eindeutigen Systemschlüssel erzeugen

  IF zfi_bn_nachricht-bnkey IS INITIAL.

    TRY.
        l_uuid = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        l_uuid = 0.
        RETURN.
    ENDTRY.

    zfi_bn_nachricht-bnkey = l_uuid.

  ENDIF.

ENDFORM.
