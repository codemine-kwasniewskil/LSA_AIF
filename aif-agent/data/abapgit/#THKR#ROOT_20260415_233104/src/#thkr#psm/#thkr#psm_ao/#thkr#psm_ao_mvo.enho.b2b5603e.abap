"Name: \PR:SAPLF0KA\FO:OKCODE_MAIN\SE:END\EI
ENHANCEMENT 0 /THKR/PSM_AO_MVO.
* To mark the item as MVO relevant, we're keeping the current focus here!
  DATA(handler) = /thkr/cl_data_store=>get( id = 'MVO' ).
  handler->set_attr( key = 'ITEM_LINE_NO'  value = CONV #( g_loop_cursor ) ).

ENDENHANCEMENT.
