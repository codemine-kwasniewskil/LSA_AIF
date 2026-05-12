*----------------------------------------------------------------------*
***INCLUDE LZMIGR_MASTERDATAF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form funds_ctr_data_extension
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT_FUNDS_CTR_DATA
*&---------------------------------------------------------------------*
FORM funds_ctr_data_extension  TABLES   p_it_funds_ctr_data STRUCTURE FMFUNDS_CTR_DATA "it_funds_ctr_data.

*  DATA: l_badi_ext_tab TYPE REF TO badi_fm_fc_ext_tab,
*        lt_fields           TYPE fieldname_tab,
*        ls_fields           TYPE LINE OF fieldname_tab,
*        ls_funds_ctr_data   TYPE fmfunds_ctr_data,
*        ls_ext              TYPE fmfctr_ext,
*        ls_aux_ext          TYPE fmfctr_ext,
*        lt_dfies            TYPE STANDARD TABLE OF dfies,
*        ls_dfies            TYPE dfies,
*        l_field(50),
*        l_field_aux(50).
*
*  FIELD-SYMBOLS:
*       <l_field>       TYPE any,
*        <l_field_aux>  TYPE any.
*
*  GET BADI l_badi_ext_tab.
*
*  CALL FUNCTION 'DDIF_NAMETAB_GET'
*    EXPORTING
*      tabname   = 'FMFCTR_EXT'
*    TABLES
*      dfies_tab = lt_dfies
*    EXCEPTIONS
*      not_found = 1
*      OTHERS    = 2.
*
*  IF sy-subrc = 0.
*    CHECK l_badi_ext_tab IS BOUND.
*
*    CALL BADI l_badi_ext_tab->map_to_rfc
*      CHANGING
*        ct_fields = lt_fields.
*
*    IF lt_fields IS NOT INITIAL.
*      LOOP AT it_funds_ctr_data INTO ls_funds_ctr_data.
*        CLEAR ls_aux_ext.
*        MOVE-CORRESPONDING ls_funds_ctr_data TO ls_ext.
*        LOOP AT lt_dfies INTO ls_dfies.
*          SEARCH lt_fields FOR ls_dfies-fieldname.
*          IF sy-subrc = 0.
*            CONCATENATE 'LS_EXT' '-' ls_dfies-fieldname INTO l_field.
*            CONCATENATE 'LS_AUX_EXT' '-' ls_dfies-fieldname INTO l_field_aux.
*            ASSIGN (l_field) TO <l_field>.
*            ASSIGN COMPONENT ls_dfies-fieldname OF STRUCTURE ls_aux_ext TO <l_field_aux>.
*            IF sy-subrc = 0.
*              <l_field_aux> = <l_field>.
*            ENDIF.
*          ENDIF.
*        ENDLOOP.
*        MOVE-CORRESPONDING ls_aux_ext TO ls_funds_ctr_data.
*        MODIFY it_funds_ctr_data FROM ls_funds_ctr_data.
*      ENDLOOP.
*    ENDIF.
*  ENDIF.

ENDFORM.                    " FUNDS_CTR_DATA_EXTENSION
ENDFORM.
*&---------------------------------------------------------------------*
*& Form fund_ctr_read
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_FM_AREA
*&      --> I_FUND_CTR
*&      <-- NOT_FOUND
*&---------------------------------------------------------------------*
FORM fund_ctr_read  USING    i_fm_area
                            i_funds_ctr
                    CHANGING not_found.

data:  i_fikrs          TYPE fmfctr-fikrs,
                          i_fictr          TYPE fmfctr-fictr,
                          i_spras          TYPE spras, "OPTIONAL
                          i_read_text      TYPE xfeld, "OPTIONAL
                          i_read_hisv      TYPE xfeld, "OPTIONAL
                          et_fmfctr       TYPE fmmd_t_fmfctr_core,
                          et_fmfctrt      TYPE fmmd_t_fmfctrt_core,
                          et_fmhisv       TYPE fmmd_t_fmhisv_core.





*   Select all funds center validity pieces.
    SELECT * FROM fmfctr
      INTO CORRESPONDING FIELDS OF TABLE et_fmfctr
        WHERE fikrs = I_FM_AREA   "i_fikrs
        AND   fictr = i_funds_ctr.

    IF sy-subrc <> 0. "Not Found
*     Finanzstelle &2 im Finanzkreis &1 nicht vorhanden
      not_found = 'X'.
*      MESSAGE e579 WITH i_fikrs i_fictr RAISING not_found.
    ENDIF.

    IF i_read_text = ABAP_TRUE.
*     Select funds center texts with all languages
      SELECT * FROM fmfctrt
        INTO CORRESPONDING FIELDS OF TABLE et_fmfctrt
          WHERE spras = i_spras
          AND   fikrs = i_fikrs
          AND   fictr = i_fictr.
    ENDIF.


    IF i_read_hisv = ABAP_TRUE.
*     Select hierarchy variant assignment
      SELECT * FROM fmhisv
        INTO CORRESPONDING FIELDS OF TABLE et_fmhisv
          WHERE fikrs = i_fikrs
          AND   fistl = i_fictr.
    ENDIF.

ENDFORM.
