class /THKR/CL_PMW_EXIT definition
  public
  final
  create public .

public section.

  class-methods CHECK_TEXT
    importing
      value(IV_GTEXT) type GTEXT optional
    exporting
      value(EV_GTEXT) type GTEXT .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_PMW_EXIT IMPLEMENTATION.


  METHOD check_text.

    DATA: lv_len TYPE i,
          lv_pos TYPE i.
    DATA: lv_gtext TYPE gtext.

    lv_gtext = iv_gtext.

    DO 30 TIMES.
      if sy-index = 1.
        lv_len = 1. lv_pos = 0.
      else.
      lv_pos = lv_pos + 1.
      endif.

      IF lv_gtext+lv_pos(lv_len) CA 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz'.
        CONTINUE.
      ELSEIF lv_gtext+lv_pos(lv_len) CA '0123456789:?,.-()+/'.
        CONTINUE.
      ELSEIF lv_gtext+lv_pos(lv_len) CA 'ÄäÖöÜüß&*$% '.
        CONTINUE.
      ELSE.
        CLEAR: lv_gtext+lv_pos(lv_len).
      ENDIF.

    ENDDO.

    ev_gtext = lv_gtext.

  ENDMETHOD.
ENDCLASS.
