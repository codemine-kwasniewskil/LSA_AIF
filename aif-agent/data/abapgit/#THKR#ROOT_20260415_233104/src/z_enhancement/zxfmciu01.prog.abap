*&---------------------------------------------------------------------*
***INCLUDE ZXFMCIF01.
*&---------------------------------------------------------------------*
 e_f_fmxci_std = CORRESPONDING #( i_f_ifmcidy ).
 e_f_fmxci_std-fivor = COND fm_fivor( WHEN e_f_fmxci_std-fivor IS NOT INITIAL THEN e_f_fmxci_std-fivor
                                      ELSE '30' ).
 e_f_fmxci_std-potyp = COND fm_potyp( WHEN e_f_fmxci_std-potyp IS NOT INITIAL       THEN e_f_fmxci_std-potyp
                                      WHEN e_f_fmxci_std-fipex+4(1) NA '0123456789' THEN ''
                                      WHEN e_f_fmxci_std-fipex+4(1) >= '4'          THEN '3'
                                      WHEN e_f_fmxci_std-fipex+4(1) < '4'           THEN '2' ).
 e_f_fmxci_cus = CORRESPONDING #( i_f_ifmcidy ).
