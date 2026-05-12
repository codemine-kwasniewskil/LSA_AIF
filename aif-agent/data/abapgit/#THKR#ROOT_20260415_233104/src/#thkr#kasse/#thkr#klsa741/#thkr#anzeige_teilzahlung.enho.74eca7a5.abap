"Name: \TY:CL_FEB_BSPROC_BS_ITEM\ME:GET_ITEMS\SE:END\EI
ENHANCEMENT 0 /THKR/ANZEIGE_TEILZAHLUNG.
 DATA: lv_elko  TYPE c,
       lt_avip  TYPE avip_tt,
       lv_disp  TYPE c,
       lv_zaehl TYPE i.

 IMPORT elko_ok  TO lv_elko  FROM MEMORY ID 'ELKO_OK'.
 IMPORT lt_avip  TO lt_avip  FROM MEMORY ID 'AVIP_OUT'.
 IMPORT lv_disp  TO lv_disp  FROM MEMORY ID 'DISPLAY'.
 IMPORT lv_zaehl TO lv_zaehl FROM MEMORY ID 'ITEM_ANZ'.

 IF lv_elko EQ abap_true AND lt_avip IS NOT INITIAL.
   ADD 1 TO lv_zaehl.
* Nur beim zweiten Durchlauf die Anzeige aufbereiten.
   IF lv_zaehl EQ '2'.
     LOOP AT lt_avip ASSIGNING FIELD-SYMBOL(<ls_avip>).

       READ TABLE rt_items ASSIGNING <fs_item>
                  WITH KEY bukrs = <ls_avip>-bukrs
                           belnr = <ls_avip>-belnr
                           gjahr = <ls_avip>-gjahr.
       IF sy-subrc EQ 0.

         IF <ls_avip>-diffw IS NOT INITIAL.
           IF <ls_avip>-diffw NE <fs_item>-psdif.
           <fs_item>-applied_amount =  <fs_item>-applied_amount -  <ls_avip>-diffw.
           <fs_item>-psdif          = <ls_avip>-diffw.
           ENDIF.
           <fs_item>-diff_post_type = '2'.
         ENDIF.

         EXPORT lv_disp FROM lv_disp TO MEMORY ID 'DISPLAY'.
         CLEAR: lv_disp.
         FREE MEMORY ID 'ELKO_OK'.
         FREE MEMORY ID 'ELKO_TAB'.
         FREE MEMORY ID 'AVIP_OUT'.
         FREE MEMORY ID 'LT_BSID'.
         FREE MEMORY ID 'ELKO_UEBERZ'.
         FREE MEMORY ID 'ITEM_ANZ'.
       ENDIF.
     ENDLOOP.
   ENDIF.
   EXPORT lv_zaehl FROM lv_zaehl TO MEMORY ID 'ITEM_ANZ'.
 ENDIF.


ENDENHANCEMENT.
