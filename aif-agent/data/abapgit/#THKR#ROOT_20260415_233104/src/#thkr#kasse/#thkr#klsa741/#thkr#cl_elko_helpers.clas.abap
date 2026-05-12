class /THKR/CL_ELKO_HELPERS definition
  public
  create public .

public section.

  class-data MESSAGES type BAPIRET2_TAB .

  class-methods CONVERT_STRING
    importing
      !IV_CONVERT_NAME type /THKR/CONVERT_NAME
    returning
      value(RS_CONVERT_STRING) type /THKR/CONVERT_STRING .
  class-methods CHECK_NUMBERS_13
    importing
      !IV_IDENT type XBLNR
    exporting
      !EV_CDIGIT type CDIGIT_PS
      !EV_VALID type BOOLEAN
    raising
      /THKR/CX_ELKO .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_ELKO_HELPERS IMPLEMENTATION.


  METHOD check_numbers_13.
*     Berechnung der Prüfziffer nach DIN ISO 7064, MOD 11,10

    DATA: lv_hold         TYPE i,
          lv_cnt_idx      TYPE i,
          lv_sav_zsum     TYPE i,
          lv_sav_ch_digit TYPE i,
          lv_len_key      TYPE i,
          lv_pruefziffer  TYPE i,
          lv_sav_ch       TYPE c,
          lv_ident        TYPE xblnr.

    CLEAR: ev_valid.

    lv_ident = iv_ident.
    CONDENSE lv_ident.

    lv_len_key = strlen( lv_ident ) - 1.

* Berechnung der Prüfziffer nach Modulo 11
    lv_hold = 10.

    DO lv_len_key TIMES.
      lv_sav_ch = lv_ident+lv_cnt_idx(1).
      IF NOT lv_sav_ch CO '0123456789'.
        IF sy-subrc <> 0.
          DATA(type) = 'W'.
          messages = VALUE #( BASE messages ( id = '/THKR/ELKO' number = 000 type = type message = 'Fehler bei der Ermittlung der Prüfziffer' ) ).
          EXIT.
        ENDIF.
        IF messages IS NOT INITIAL.
          RAISE EXCEPTION TYPE /thkr/cx_elko EXPORTING bapiret2_tab = messages.
        ENDIF.
      ENDIF.
      lv_sav_ch_digit = lv_sav_ch.
      lv_sav_zsum = ( lv_hold + lv_sav_ch_digit ) MOD 10.
      IF lv_sav_zsum = 0.
        lv_sav_zsum = 10.
      ENDIF.
      lv_hold = ( lv_sav_zsum * 2 ) MOD 11.
      lv_cnt_idx = lv_cnt_idx + 1.
    ENDDO.

    IF lv_hold = 1.
      lv_pruefziffer = 0.
    ELSE.
      lv_pruefziffer = 11 - lv_hold.
    ENDIF.

    ev_cdigit = lv_pruefziffer.
    IF lv_ident+lv_len_key = ev_cdigit.
      ev_valid = 'X'.
    ELSE.
      CLEAR ev_valid.
    ENDIF.
  ENDMETHOD.


  METHOD convert_string.
    SELECT SINGLE convert_string FROM /thkr/c_converts INTO rs_convert_string
                                 WHERE convert_name EQ iv_convert_name.
  ENDMETHOD.
ENDCLASS.
