FUNCTION-POOL Z_FI_BN_BELEG.                "MESSAGE-ID ..

* INCLUDE LZ_FI_BN_BELEGD...                 " Local class definition

TABLES: ZFI_F_DTO_NACHR,
        zfi_bn_druck.

  types: begin of t_zfi_za,
           maber type maber.
  types: end of t_zfi_za.
constants: c_maber_55 type maber value '55' ,
           c_maber_90 type maber value '90',
           c_char_s type c value 'S',
            c_char_h type c value 'H',
           c_char_t type c value 'T',
           c_char_d type c value 'D',
           c_char_K type c value 'K',
           c_char_y type c value 'Y',
           c_char_p type c value 'P',
           c_off type xfeld value ' ',
           c_on type xfeld value 'X',
           c_za type char02 value 'ZA'.


DATA: ok_code like sy-ucomm.
DATA: g_ftext TYPE zfi_cu_bn_ftext.

  data: gt_zfi_za    type standard table of  t_zfi_za,
           gv_za_string type cstring.

data:
     gs_out      type zfi_bn_druck.
