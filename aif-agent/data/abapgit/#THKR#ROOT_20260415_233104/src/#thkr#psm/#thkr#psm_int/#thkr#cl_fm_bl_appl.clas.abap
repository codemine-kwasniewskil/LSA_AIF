class /THKR/CL_FM_BL_APPL definition
  public
  final
  create public .

public section.

  class-methods GET_BBELEG_DATA
    importing
      !IS_BELEG type /THKR/S_BUDGET_BELEG_DATA
    returning
      value(R_BELEG) type /THKR/DTO_PSM_AS_KEY .
  class-methods CREATE_BBELEG
    importing
      !IS_BELEG type /THKR/S_BUDGET_BELEG_HEADER
      !IT_BELEG_ITEMS type /THKR/T_BUDGET_BELEG_ITEM
    returning
      value(R_BELEG) type /THKR/DTO_PSM_AS_KEY .
  class-methods GET_BBELEG_VERSION
    importing
      !IV_FIKRS type FIKRS
      !IV_GJAHR type GJAHR
      !IV_FIPEX type FM_FIPEX
      !IV_BUDCAT type BUKU_BUDCAT
    returning
      value(RV_VERSION) type BUKU_VERSION .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_FM_BL_APPL IMPLEMENTATION.


  METHOD CREATE_BBELEG.
    DATA: ls_header TYPE bapi_0050_header.
    DATA: lt_items TYPE TABLE OF bapi_0050_item.
    DATA: lt_return TYPE bapiret2_t.

    ls_header = CORRESPONDING #( is_beleg ).
    lt_items  = CORRESPONDING #( it_beleg_items ).

    CALL FUNCTION 'BAPI_0050_CREATE'
      EXPORTING
        header_data    = ls_header
        testrun        = abap_false
      IMPORTING
        fmarea         = r_beleg-fm_area
        documentyear   = r_beleg-docyear
        documentnumber = r_beleg-docnr
      TABLES
        item_data      = lt_items
        return         = lt_return.
  ENDMETHOD.


  METHOD get_bbeleg_data.
    CLEAR: r_beleg.
    SELECT SINGLE *
      FROM fmbh
      INNER JOIN fmbl ON fmbh~fm_area = fmbl~fm_area AND
                         fmbh~docyear = fmbl~docyear AND
                         fmbh~docnr   = fmbl~docnr
      WHERE fmbh~revstate is INITIAL AND
            fmbh~fm_area  = @is_beleg-fikrs AND
            fmbh~docyear  = @is_beleg-gjahr AND
            fmbl~cmmtitem = @is_beleg-fipex AND
            fmbl~funcarea = @is_beleg-fkber AND
            fmbl~fund     = @is_beleg-fincode AND
            fmbh~version  = @is_beleg-version AND
            fmbl~budcat   = @is_beleg-budcat

      INTO CORRESPONDING FIELDS OF @r_beleg           .
  ENDMETHOD.


  METHOD get_bbeleg_version.
    SELECT version
    FROM fmbh
    INNER JOIN fmbl ON fmbh~fm_area = fmbl~fm_area AND
                       fmbh~docyear = fmbl~docyear AND
                       fmbh~docnr   = fmbl~docnr
    INTO TABLE @DATA(lt_version)
    WHERE fmbh~fm_area    = @iv_fikrs AND
          fmbh~docyear    = @iv_gjahr AND
          fmbl~cmmtitem   = @iv_fipex AND
          fmbl~budcat     = @iv_budcat.

    DELETE lt_version WHERE version NP 'NT*'.

    DATA(lv_index) = lines( lt_version ) + 1.
    rv_version = |NT{ lv_index }|.
  ENDMETHOD.
ENDCLASS.
