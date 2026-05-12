CLASS /thkr/cl_epc_qrcode_generator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !iban             TYPE iban
        !bic              TYPE a9_fr
        !value            TYPE wrbtr
        !reference        TYPE char20
        !receiver_name    TYPE char80
        !reference_prefix TYPE char4 OPTIONAL .
    METHODS get_qrcode_as_xstring
      RETURNING
        VALUE(qrcode) TYPE xstring .
    METHODS get_qrcode_as_tmp_url
      RETURNING
        VALUE(url) TYPE url .
  PROTECTED SECTION.

    DATA iban TYPE iban .
    DATA bic TYPE a9_fr .
    DATA value TYPE wrbtr .
    DATA reference TYPE char20 .
    DATA receiver_name TYPE char80 .
    DATA reference_prefix TYPE char4 .
  PRIVATE SECTION.

    METHODS convert_value_to_char
      IMPORTING
        !betr        TYPE wrbtr
      RETURNING
        VALUE(value) TYPE char20 .
    METHODS get_epc_string
      RETURNING
        VALUE(qr_string) TYPE string .
ENDCLASS.



CLASS /THKR/CL_EPC_QRCODE_GENERATOR IMPLEMENTATION.


  METHOD constructor.
    me->iban = iban.
    me->bic = bic.
    me->value = value.
    me->reference = reference.
    me->receiver_name = receiver_name.
    me->reference_prefix = reference_prefix.
  ENDMETHOD.


  METHOD convert_value_to_char.
    value = |EUR{ betr  WIDTH = 18 ALIGN = LEFT }|.
    value = replace( val = value sub = `,` with = `.` ).
  ENDMETHOD.


  METHOD get_epc_string.

    DATA(wrvalue) = me->convert_value_to_char( value ).
    CONCATENATE
     'BCD' '\c013\\c010\'
     '001' '\c013\\c010\'
     '1' '\c013\\c010\'
     'SCT' '\c013\\c010\'
     me->bic '\c013\\c010\'
     me->receiver_name '\c013\\c010\'
     me->iban '\c013\\c010\'
     wrvalue '\c013\\c010\'
     '' '\c013\\c010\'
     '' '\c013\\c010\'
     me->reference_prefix space me->reference
     INTO qr_string.

  ENDMETHOD.


  METHOD get_qrcode_as_tmp_url.

    DATA(bin_bmp) = cl_bcs_convert=>xstring_to_solix( me->get_qrcode_as_xstring( ) ).
    DATA: lv_url TYPE swk_url.
* temporäre URL auf das Bild erzeugen
    CALL FUNCTION 'DP_CREATE_URL'
      EXPORTING
        type                 = 'image/bmp'
        subtype              = 'bmp'
      TABLES
        data                 = bin_bmp
      CHANGING
        url                  = url
      EXCEPTIONS
        dp_invalid_parameter = 1
        dp_error_put_table   = 2
        dp_error_general     = 3
        OTHERS               = 4.

  ENDMETHOD.


  METHOD get_qrcode_as_xstring.
    TRY.
        cl_rstx_barcode_renderer=>qr_code(
          EXPORTING
            i_module_size      = '15' " Size of smallest module (in pixel, max: 32000)
            i_mode             = 'U'  " Mode ('N', 'A', 'L', 'B', 'K', 'U', '1', '2'; note 2030263)
            i_error_correction = 'M'  " Error correction ('L', 'M', 'Q', 'H')
*           i_rotation         = 0    " Rotation (0, 90, 180 or 270)
            i_barcode_text     = me->get_epc_string( ) " Barcode text
          IMPORTING
            e_bitmap           = qrcode " Bitmap in BMP format
        ).
      CATCH cx_rstx_barcode_renderer. " Exception class of CL_RSTX_BARCODE_RENDERER
        " Delegate
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
