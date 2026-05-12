"Name: \PR:SAPLSGOSDS\FO:CREATE_NOTE\SE:END\EI
ENHANCEMENT 0 Z_FI_BAVM.
** falls im Titel der Notiz BAVM hinterlegen
*
*  if l_obj_data-objdes cs 'BAVM'
*    and l_obj_id is not initial. "Erfolg
*    move-corresponding document_id to g_document_id.
*    g_document_title = l_obj_data-objdes.
*  endif.

ENDENHANCEMENT.
