"Name: \TY:CL_GOS_DOCUMENT_SERVICE\ME:EDIT_NOTE\SE:BEGIN\EI
ENHANCEMENT 0 Z_FI_BAVM_DEL.
*data: l_febre_zus type zfi_febre_zus.
*
* l_febre_zus-foltp = ip_note(3).
* l_febre_zus-folyr = ip_note+3(2).
* l_febre_zus-folno = ip_note+5(12).
* l_febre_zus-doctp = ip_note+17(3).
* l_febre_zus-docyr = ip_note+20(2).
* l_febre_zus-docno = ip_note+22(12).
*
** Mustereintrag
** FOL44000000000004RAW46000000001507
* select @abap_true from zfi_febre_zus
*   where foltp = @l_febre_zus-foltp
*     and folyr = @l_febre_zus-folyr
*     and folno = @l_febre_zus-folno
*     and doctp = @l_febre_zus-doctp
*     and docyr = @l_febre_zus-docyr
*     and docno = @l_febre_zus-docno
*     into @data(exists).
* exit.
* endselect.
* if exists = abap_true.
*   message i350(Z_FI_NACHR).
*   exit.
* endif.
ENDENHANCEMENT.
