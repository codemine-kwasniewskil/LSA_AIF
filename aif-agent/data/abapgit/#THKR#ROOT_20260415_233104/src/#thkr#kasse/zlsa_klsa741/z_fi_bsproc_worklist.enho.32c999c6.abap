"Name: \PR:FEB_BSPROC_FE\TY:LCL_CTRL_WORKLIST\ME:BUILD_FIELDCAT\SE:END\EI
ENHANCEMENT 0 Z_FI_BSPROC_WORKLIST.
* Überschreiben der Felder FNAM1-FNAM3 + JPDAT

data: lt_dtel_text type standard table of   DD04T.
data: ls_dtel_text type   DD04T.
clear lt_dtel_text[].

    SELECT  * FROM dd04t INTO table lt_dtel_text
          WHERE ( rollname  = 'ZFI_EL_BEARBKZ' or
                  rollname  = 'ZFI_EL_WDVDAT' or
                  rollname  = 'ZFI_EL_AVVISO' or
                  rollname  = 'ZFI_EL_OVER' )
            AND ddlanguage = 'D'.
.

  LOOP AT lt_wl_fieldcat REFERENCE INTO ld_fieldcat.
    CASE ld_fieldcat->fieldname.
        WHEN 'FNAM1'.
          READ TABLE lt_dtel_text INTO ls_dtel_text
          with key
          rollname  = 'ZFI_EL_BEARBKZ'
          ddlanguage = 'D'.
if sy-subrc = 0.
* geht nicht ld_fieldcat->fieldname = 'ZZ_STATUS'.
ld_fieldcat->REF_FIELD = 'ZZ_STATUS'.
ld_fieldcat->REF_TABLE ='FEBEP'.
ld_fieldcat->ROLLNAME = 'ZFI_EL_BEARBKZ'.
ld_fieldcat->COLTEXT = ls_dtel_text-reptext.
ld_fieldcat->SCRTEXT_L = ls_dtel_text-SCRTEXT_L.
ld_fieldcat->SCRTEXT_M = ls_dtel_text-SCRTEXT_M.
ld_fieldcat->SCRTEXT_S = ls_dtel_text-SCRTEXT_S.
ld_fieldcat->col_opt    = abap_true.
endif.
*        WHEN 'FNAM2'.
         WHEN 'JPDAT'.
          READ TABLE lt_dtel_text INTO ls_dtel_text
          with key
          rollname  = 'ZFI_EL_WDVDAT'
          ddlanguage = 'D'.
 if sy-subrc = 0.
ld_fieldcat->REF_FIELD = 'ZZ_WDVDAT'.
ld_fieldcat->REF_TABLE ='FEBEP'.
*ld_fieldcat->DATATYPE = 'DATS'.
*ld_fieldcat->NO_ZERO = abap_true. "nicht sinnvoll
*ld_fieldcat->INTTYPE  = 'D'. "stellt Filter in Datumsformat dar
*ld_fieldcat->OUTPUTLEN = '10'.
ld_fieldcat->col_opt    = abap_true.
*ld_fieldcat->convexit = 'MODAT'.
*ld_fieldcat->EDIT_MASK = 'DD/MM/YYYY'.
ld_fieldcat->ROLLNAME = 'ZFI_EL_WDVDAT'. "F1 Feldname
ld_fieldcat->COLTEXT = ls_dtel_text-reptext.
ld_fieldcat->SCRTEXT_L = ls_dtel_text-SCRTEXT_L.
ld_fieldcat->SCRTEXT_M = ls_dtel_text-SCRTEXT_M.
ld_fieldcat->SCRTEXT_S = ls_dtel_text-SCRTEXT_S.
endif.

           WHEN 'FNAM2'.
          READ TABLE lt_dtel_text INTO ls_dtel_text
          with key
          rollname  = 'ZFI_EL_OVER'
          ddlanguage = 'D'.
if sy-subrc = 0.
* geht nicht ld_fieldcat->fieldname = 'ZZ_STATUS'.
ld_fieldcat->REF_FIELD = 'ZZ_OVER'.
ld_fieldcat->REF_TABLE ='FEBEP'.
ld_fieldcat->ROLLNAME = 'ZFI_EL_OVER'.
ld_fieldcat->SELTEXT = ls_dtel_text-reptext.
ld_fieldcat->COLTEXT = ls_dtel_text-reptext.
ld_fieldcat->SCRTEXT_L = ls_dtel_text-SCRTEXT_L.
ld_fieldcat->SCRTEXT_M = ls_dtel_text-SCRTEXT_M.
ld_fieldcat->SCRTEXT_S = ls_dtel_text-SCRTEXT_S.
ld_fieldcat->col_opt    = abap_true.
endif.
           WHEN 'FNAM3'.
          READ TABLE lt_dtel_text INTO ls_dtel_text
          with key
          rollname  = 'ZFI_EL_AVVISO'
          ddlanguage = 'D'.
if sy-subrc = 0.
* geht nicht ld_fieldcat->fieldname = 'ZZ_STATUS'.
ld_fieldcat->REF_FIELD = 'ZZ_AVVISO'.
ld_fieldcat->REF_TABLE ='FEBEP'.
ld_fieldcat->ROLLNAME = 'ZFI_EL_AVVISO'.
ld_fieldcat->SELTEXT = ls_dtel_text-reptext.
ld_fieldcat->COLTEXT = ls_dtel_text-reptext.
ld_fieldcat->SCRTEXT_L = ls_dtel_text-SCRTEXT_L.
ld_fieldcat->SCRTEXT_M = ls_dtel_text-SCRTEXT_M.
ld_fieldcat->SCRTEXT_S = ls_dtel_text-SCRTEXT_S.
ld_fieldcat->col_opt    = abap_true.
endif.
  endcase.
  endloop.
ENDENHANCEMENT.
