"Name: \FU:SGOS_NOTE_CREATE_DIALOG\SE:END\EI
ENHANCEMENT 0 Z_FI_BAVM.
*falls Kontoauzug
*  if is_object-objtype = 'BUS4498'.
*data: ls_febre_zus type ZFI_FEBRE_ZUS.
*
*     if not document_id is initial and
*         document_id =  g_document_id.
*         ls_febre_zus-kukey = is_object-objkey(8).
*         ls_febre_zus-esnum = is_object-objkey+8(5).
**          ls_febre_zus-rsnum =  '001'.
*         move-corresponding  document_id to ls_febre_zus.
*         move g_document_title to ls_febre_zus-objdes.
*         shift ls_febre_zus-objdes left deleting leading ' '.
*         ls_febre_zus-ernam = sy-uname.
*         ls_febre_zus-erdat = sy-datum.
*         ls_febre_zus-ERTIM = sy-uzeit.
**         modify ZFI_FEBRE_ZUS from ls_febre_zus.
*          call function 'Z_FI_FEBRE_ZUS_UPDATE'
*                exporting I_FEBRE_ZUS = ls_febre_zus.
*
*     endif.
*
*  endif.
ENDENHANCEMENT.
