FUNCTION /THKR/_BUPA_BUPA_PBO_ZBU601 .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------
  DATA: lv_gtext type gtext.
  DATA: lv_sst_text type c LENGTH 40.
   MOVE  /THKR/S_INC1_BUT-/THKR/GSBER TO gv_zzgsber.
   MOVE  /THKR/S_INC1_BUT-/THKR/SST TO gv_zzsst.

   if /THKR/S_INC1_BUT-/THKR/GSBER is not INITIAL.

     Select SINGLE GTEXT
       FROM TGSBT
       INTO lv_gtext
       where
       spras = sy-langu and
       gsber = /THKR/S_INC1_BUT-/THKR/GSBER.

       if sy-subrc = 0.

       /THKR/S_INC1_BUT_TXT-/THKR/GSBER_TXT = lv_gtext.

     ENDIF.

     ENDIF.

    if /THKR/S_INC1_BUT-/THKR/SST is not INITIAL.

      Select SINGLE DESCR
        From /THKR/GPSSTTXT
        into lv_sst_text
        where sst = /THKR/S_INC1_BUT-/THKR/SST.

        if sy-subrc = 0.

        /THKR/S_INC1_BUT_TXT-/THKR/SST_TXT = lv_sst_text.

        ENDIF.

      ENDIF.

ENDFUNCTION.
