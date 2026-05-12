FUNCTION /thkr/fi_apar_mandate_gen_reft.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(CT_REFTYPES) TYPE  VRM_VALUES
*"----------------------------------------------------------------------
* Implementation example No. 1:
* Hide the reference subscreen, removing all the standard ref. types
  CLEAR ct_reftypes.
* Implementation example No. 2:
* Add custom reference types with language dependent description
* DATA: ls_reftype TYPE vrm_value.
* ct_reftypes = it_reftypes.
* ls_reftype-key = 'LEASE'.
* CASE sy-langu.
*   WHEN 'E'.
*     ls_reftype-text = 'Leasing'.
*   WHEN 'D'.
*     ls_reftype-text = 'Miete'.
*   WHEN 'F'.
*     ls_reftype-text = 'Loyer'.
* ENDCASE.
* APPEND ls_reftype TO ct_reftypes.
* ls_reftype-key = 'GARBAGE'.
* CASE sy-langu.
*   WHEN 'E'.
*     ls_reftype-text = 'Garbage collection'.
*   WHEN 'D'.
*     ls_reftype-text = 'Muellabfuhr'.
*   WHEN 'F'.
*     ls_reftype-text = 'Ramassage des ordures'.
* ENDCASE.
* APPEND ls_reftype TO ct_reftypes.
* Implementation example No. 3:
* Do not hide the whole reference subscreen, but just the default
* value 'Loans'
*  INSERT INITIAL LINE INTO ct_reftypes INDEX 1.

ENDFUNCTION.
