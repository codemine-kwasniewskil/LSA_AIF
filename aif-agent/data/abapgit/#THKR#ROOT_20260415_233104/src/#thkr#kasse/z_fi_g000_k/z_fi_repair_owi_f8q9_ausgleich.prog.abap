*&---------------------------------------------------------------------*
*& Report Z_FI_REPAIR_OWI_F8Q9_AUSGLEICH
*&---------------------------------------------------------------------*
*& Reparatur auf Basis der Störungsmeldung zu OWI v. 03.01.2023 (Bauer/Kielmann)
*&   Über diesen Report wird der abgebrochene Ausgleich zwischen OWI-AD-Anordnung
*%   und OWI-KZ-Anzahlung mittels clear_docs aus F8Q9 nachgeholt und damit
*%   der Schiefstand in AD(XBLNR, NSI_GROUP) beseitigt.
*&---------------------------------------------------------------------*
REPORT z_fi_repair_owi_f8q9_ausgleich.

TABLES: bsid.

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


PARAMETERS:       p_ba_ad LIKE bsid-blart DEFAULT 'AD' OBLIGATORY.
SELECT-OPTIONS:   s_kz_ad FOR bsid-xblnr OBLIGATORY.
PARAMETERS:       p_ba_dz LIKE bsid-blart DEFAULT 'DZ' OBLIGATORY.
SELECT-OPTIONS:   s_kz_dz FOR bsid-xblnr.

START-OF-SELECTION.


  SELECT ad~bukrs, ad~budat, ad~bldat, 'D', ad~waers, ad~lotkz,    " generiert über QView Z_JS_OWI_AD
         ad~bukrs, ad~belnr, ad~gjahr, ad~kunnr, ad~augbl,                    "AD~BLART AD~XBLNR
         dz~bukrs, dz~belnr, dz~gjahr, dz~buzei, dz~kunnr, dz~augbl, dz~umskz "DZ~BLART DZ~XBLNR
                                                                              "DZ~DMBTR DZ~SGTXT
  FROM ( bsid  AS ad
         INNER JOIN bsid  AS dz
         ON  dz~dmbtr = ad~dmbtr
         AND dz~sgtxt = ad~sgtxt )
       WHERE ad~blart = @p_ba_ad
         AND ad~xblnr IN @s_kz_ad
         AND dz~blart = @p_ba_dz
         AND dz~xblnr IN @s_kz_dz
  INTO TABLE @t_data4clear.

  LOOP AT t_data4clear.
    WRITE: / TEXT-001, t_data4clear-ibelnr, '/', t_data4clear-ibukrs, '/', t_data4clear-igjahr,
             TEXT-002, t_data4clear-belnr, '/', t_data4clear-bukrs, '/', t_data4clear-gjahr.
  ENDLOOP.

* clear the down payment and the corresponding invoice
  PERFORM clear_docs(rffmkg03)                                     " aus RFFMKG03
  TABLES  t_data4clear.

  COMMIT WORK AND WAIT.
