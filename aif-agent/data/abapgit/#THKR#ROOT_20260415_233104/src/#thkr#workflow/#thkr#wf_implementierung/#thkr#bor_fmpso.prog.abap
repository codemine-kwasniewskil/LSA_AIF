*****           Implementation of object type /THKR/FMPSO           *****
INCLUDE <object>.
begin_data object. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
  " begin of private,
  "   to declare private attributes remove comments and
  "   insert private attributes here ...
  " end of private,
  BEGIN OF key,
    sourcecompanycode LIKE vbkpf-ausbk,
    requestnumber     LIKE vbkpf-lotkz,
  END OF key.
end_data object. " Do not change.. DATA is generated

begin_method zgetbasicdata changing container.
DATA:
  v_gsber TYPE bseg-gsber,
  v_fistl TYPE bseg-fistl,
  v_fipos TYPE bseg-fipos,
  v_fonds TYPE bseg-geber,
  v_fkber TYPE bseg-fkber,
*      I_BUKRS TYPE BSEG-BUKRS,
*      I_LOTZK TYPE VBKPF-LOTKZ,
  s_bkpf  TYPE bkpf,
  t_bseg  TYPE STANDARD TABLE OF bseg.

*
*  SWC_GET_ELEMENT CONTAINER 'I_BUKRS' I_BUKRS.
*  SWC_GET_ELEMENT CONTAINER 'I_LOTZK' I_LOTZK.

SELECT SINGLE * FROM bkpf INTO  s_bkpf WHERE bukrs = object-key-sourcecompanycode AND lotkz = object-key-requestnumber.
SELECT * FROM bseg WHERE bukrs = @object-key-sourcecompanycode AND belnr = @s_bkpf-belnr AND gsber is not INITIAL
  and fistl is not INITIAL and fipos is not INITIAL and geber is not INITIAL and fkber is not INITIAL
  INTO TABLE @t_bseg.
READ TABLE T_Bseg INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_bseg>).
v_gsber = <fs_bseg>-gsber.
v_fistl = <fs_bseg>-fistl.
v_fipos = <fs_bseg>-fipos.
v_fonds = <fs_bseg>-geber.
v_fkber = <fs_bseg>-fkber.


swc_set_element container 'V_GSBER' v_gsber.
swc_set_element container 'V_FISTL' v_fistl.
swc_set_element container 'V_FIPOS' v_fipos.
swc_set_element container 'V_FONDS' v_fonds.
swc_set_element container 'V_FKBER' v_fkber.
end_method.
