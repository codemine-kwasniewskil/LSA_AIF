*&---------------------------------------------------------------------*
*& Report /THKR/REPAIR_F8Q9_AUSGLEICH_K
*&---------------------------------------------------------------------*
*& Kopie aus REPRO-BW (Report Z_FI_REPAIR_OWI_F8Q9_AUSGLEICH)
*&   Über diesen Report wird der abgebrochene Ausgleich zwischen AK-Anordnung
*%   und KZ-Anzahlung mittels clear_docs aus F8Q9 nachgeholt und damit
*%   der Schiefstand in AK(XBLNR) beseitigt.
*&---------------------------------------------------------------------*
REPORT /THKR/REPAIR_F8Q9_AUSGLEICH_K.

TABLES: bsik.

* data for clearing                                                " aus RFFMKG03
DATA: BEGIN OF data4clear,
*       header data
        hbukrs LIKE pso02-bukrs,
        hbudat LIKE pso02-budat,
        hbldat LIKE pso02-bldat,
        hkoart LIKE pso02-koart,
        hwaers LIKE pso02-waers,
        hlotkz LIKE pso02-lotkz,
*       invoice data
        ibukrs LIKE pso02-bukrs,
        ibelnr LIKE pso02-belnr,
        igjahr LIKE pso02-gjahr,
        ikunnr LIKE pso02-kunnr,
        ilifnr LIKE pso02-lifnr.
*       downpayment data
        INCLUDE STRUCTURE ifmdocs4clear.
DATA: END OF data4clear.

* for clearing
DATA: t_data4clear LIKE TABLE OF  data4clear    WITH HEADER LINE.  " aus RFFMKG03


PARAMETERS:       p_ba_ak LIKE bsik-blart DEFAULT 'AK' OBLIGATORY.
SELECT-OPTIONS:   s_kz_ak FOR bsik-xblnr OBLIGATORY.
PARAMETERS:       p_ba_kz LIKE bsik-blart DEFAULT 'KZ' OBLIGATORY.
SELECT-OPTIONS:   s_kz_kz FOR bsik-xblnr.

START-OF-SELECTION.


  SELECT ak~bukrs, ak~budat, ak~bldat, 'K', ak~waers, ak~lotkz,    " generiert über QView Z_JS_OWI_ak
         ak~bukrs, ak~belnr, ak~gjahr, ak~lifnr, ak~augbl,                    "ak~BLART ak~XBLNR
         kz~bukrs, kz~belnr, kz~gjahr, kz~buzei, kz~lifnr, kz~augbl, kz~umskz "kz~BLART kz~XBLNR
                                                                              "kz~DMBTR kz~SGTXT
  FROM ( bsik  AS ak
         INNER JOIN bsik  AS kz
         ON  kz~dmbtr = ak~dmbtr
         AND kz~sgtxt = ak~sgtxt )
       WHERE ak~blart = @p_ba_ak
         AND ak~xblnr IN @s_kz_ak
         AND kz~blart = @p_ba_kz
         AND kz~xblnr IN @s_kz_kz
  INTO TABLE @t_data4clear.

  LOOP AT t_data4clear.
    WRITE: / TEXT-001, t_data4clear-ibelnr, '/', t_data4clear-ibukrs, '/', t_data4clear-igjahr,
             TEXT-002, t_data4clear-belnr, '/', t_data4clear-bukrs, '/', t_data4clear-gjahr.
  ENDLOOP.

* clear the down payment and the corresponding invoice
  PERFORM clear_docs(rffmkg03)                                     " aus RFFMKG03
  TABLES  t_data4clear.

  COMMIT WORK AND WAIT.
