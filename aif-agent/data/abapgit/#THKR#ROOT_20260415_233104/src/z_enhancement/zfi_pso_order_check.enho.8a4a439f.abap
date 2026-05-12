"Name: \FU:FI_PSO_FI_HEADER_FILL\SE:END\EI
ENHANCEMENT 0 ZFI_PSO_ORDER_CHECK.
* Add Zinskennzeichen
 SELECT SINGLE FROM psokpf
   FIELDS z_intrate
   WHERE lotkz = @i_t_pso-lotkz
     AND bukrs = @i_t_pso-bukrs
     AND z_intrate IS NOT INITIAL
   INTO @DATA(intrate).
 IF sy-subrc = 0.
   TRY.
       ASSIGN c_t_vbkpf[ 1 ]-z_intrate TO FIELD-SYMBOL(<intrate>).
       IF <intrate> IS ASSIGNED.
         <intrate> = intrate.
       ENDIF.
     CATCH cx_sy_itab_line_not_found.
       "** Cannot occur!
   ENDTRY.
 ENDIF.

** Special Behaviour F8Q9: consider SST created MV!
 TRY.
     ASSIGN c_t_vbkpf[ 1 ] TO FIELD-SYMBOL(<vbkpf>).
     DATA(ve_blnr) = /thkr/cl_data_store=>get( 'SSTF8Q9' )->get_attr( key = 'VE_NO' ).
     IF <vbkpf>-tcode = 'F881'
     AND ve_blnr IS NOT INITIAL.
       "** Lets do the db the work:
       SELECT SINGLE FROM kblk AS k
          INNER JOIN /thkr/ao_us2sst AS c ON c~sstuser = k~kerfas
          FIELDS c~sstid
          WHERE k~belnr = @ve_blnr
          INTO @DATA(sstid).
       IF sy-subrc = 0.
         <vbkpf>-xref1_hd = sstid.
       ENDIF.
     ENDIF.
   CATCH cx_sy_itab_line_not_found.
     "** Cannot occur!
 ENDTRY.


ENDENHANCEMENT.
