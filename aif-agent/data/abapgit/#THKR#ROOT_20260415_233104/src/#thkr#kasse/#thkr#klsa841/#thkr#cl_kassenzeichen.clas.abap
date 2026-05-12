class /THKR/CL_KASSENZEICHEN definition
  public
  final
  create public .

public section.

  class-methods CHECK
    importing
      value(I_XBLNR) type XBLNR
      value(IS_KASS) type /THKR/T_KASS
    exporting
      !E_PRUEFZIFFER type CHAR1
      !E_RC type NRRETURN .
  class-methods CREATE
    importing
      value(I_FONDS) type FM_FONDS
      value(I_GSBER) type GSBER
      value(I_NRNR) type NRNR
    exporting
      value(E_KAZ) type /THKR/D_KASSENZEICHEN
      value(E_RC) type NRRETURN .
  class-methods GET_PRUEFZIFFER
    importing
      value(I_KAZ) type /THKR/D_KASSENZEICHEN
    exporting
      value(E_PRUEFZIFFER) type /THKR/D_PRUEFZIFFER .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_KASSENZEICHEN IMPLEMENTATION.


  METHOD check.

    DATA: lv_len TYPE i.
    DATA: lv_kaz TYPE /thkr/d_kassenzeichen.
    DATA: lv_xblnr TYPE xblnr.
    DATA: ls_bkpf TYPE bkpf.

    lv_len = strlen( i_xblnr ).
    e_rc = 0.
    CASE lv_len.
      WHEN 13.
        lv_kaz = i_xblnr(12).
        IF lv_kaz CO ' 0123456789'.
          CALL METHOD /thkr/cl_kassenzeichen=>get_pruefziffer
            EXPORTING
              i_kaz         = lv_kaz
            IMPORTING
              e_pruefziffer = e_pruefziffer.
          IF e_pruefziffer <> i_xblnr+12(1).
            e_rc = 1.
          ENDIF.
        ENDIF.
      when others.
        if is_kass is initial.
          e_rc = 4.
        endif.
    ENDCASE.
    IF e_rc = 0.
      IF is_kass IS INITIAL OR is_kass-x_kred = abap_true.
        CLEAR ls_bkpf.
        SELECT SINGLE * FROM bkpf INTO ls_bkpf
         WHERE xblnr = i_xblnr
           AND bstat <> 'V'
           AND bstat <> 'Z'.
        IF sy-subrc = 0.
          SELECT SINGLE xblnr FROM bsik INTO lv_xblnr
                 WHERE bukrs = ls_bkpf-bukrs
                   AND gjahr = ls_bkpf-gjahr
                   AND belnr = ls_bkpf-belnr.
          IF sy-subrc = 0.
            e_rc = 2.
          ELSE.
            SELECT SINGLE xblnr FROM bsak INTO lv_xblnr
                   WHERE bukrs = ls_bkpf-bukrs
                     AND gjahr = ls_bkpf-gjahr
                     AND belnr = ls_bkpf-belnr.
            IF sy-subrc = 0.
              e_rc = 2.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      IF is_kass IS INITIAL OR is_kass-x_debi = abap_true.
        CLEAR ls_bkpf.
        SELECT SINGLE * FROM bkpf INTO ls_bkpf
         WHERE xblnr = i_xblnr
           AND bstat <> 'V'
           AND bstat <> 'Z'.
        IF sy-subrc = 0.
          SELECT SINGLE xblnr FROM bsid INTO lv_xblnr
                 WHERE bukrs = ls_bkpf-bukrs
                   AND gjahr = ls_bkpf-gjahr
                   AND belnr = ls_bkpf-belnr.
          IF sy-subrc = 0.
            e_rc = 2.
          ELSE.
            SELECT SINGLE xblnr FROM bsad INTO lv_xblnr
                   WHERE bukrs = ls_bkpf-bukrs
                     AND gjahr = ls_bkpf-gjahr
                     AND belnr = ls_bkpf-belnr.
            IF sy-subrc = 0.
              e_rc = 2.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
      IF is_kass IS INITIAL OR is_kass-x_ao = abap_true.
        SELECT SINGLE xblnr FROM kblk INTO lv_xblnr
               WHERE xblnr = i_xblnr
                 AND wkapk = 'X'
                 AND fexec = ''.
        IF sy-subrc = 0.
          e_rc = 3.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  method CREATE.
    data: l_kaz_nriv type /thkr/d_kassenzeichen_nriv.
    data: l_kaz type /thkr/d_kassenzeichen.
    data: l_pruefziffer(1).
    data: l_gjahr type gjahr.

    " Die ersten beiden Stellen des Fonds
    " sind die letzten beiden Stellen des Geschäftsjahres
    concatenate '20' i_fonds(2) into l_gjahr.

    " Nächste freie Nummer aus Nummernkreis ziehen
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr                   = i_nrnr
        object                        = '/THKR/KAS'
*       QUANTITY                      = '1'
        SUBOBJECT                     = i_GSBER
        TOYEAR                        = l_gjahr
*       IGNORE_BUFFER                 = ' '
      IMPORTING
        NUMBER                        = l_kaz_nriv
*       QUANTITY                      =
        RETURNCODE                    = e_rc
      EXCEPTIONS
        INTERVAL_NOT_FOUND            = 1
        NUMBER_RANGE_NOT_INTERN       = 2
        OBJECT_NOT_FOUND              = 3
        QUANTITY_IS_0                 = 4
        QUANTITY_IS_NOT_1             = 5
        INTERVAL_OVERFLOW             = 6
        BUFFER_OVERFLOW               = 7
        OTHERS                        = 8
              .
    IF sy-subrc <> 0.
      e_rc = sy-subrc.
    ENDIF.

    " Das 12-stellige Kassenzeichen wird zusammengebaut (ohne Prüfziffer)
    concatenate i_fonds(2) i_gsber l_kaz_nriv into l_kaz.
    " Die Prüfziffer wird ermittelt
    CALL METHOD /thkr/cl_kassenzeichen=>get_pruefziffer
      EXPORTING
        i_kaz         = l_kaz
      IMPORTING
        e_pruefziffer = l_pruefziffer
        .

    " Das endgültige 13-stellige Kassenzeichen wird zusammengebaut
    concatenate i_fonds(2) i_gsber l_kaz_nriv l_pruefziffer into e_kaz.

  endmethod.


  method GET_PRUEFZIFFER.
    DATA: l_c12_KZ(12) TYPE C,
      l_i_zaehler  TYPE I,
      l_i_SJ       TYPE I,
      l_i_PJ       TYPE I,
      l_i_SJREST   TYPE I,
      l_n1_prfziff type n.

l_c12_KZ = i_kaz.
l_i_zaehler = 0.

WHILE l_i_zaehler < 12.

   IF l_i_zaehler = 0.
      l_i_SJ = l_c12_KZ+l_i_zaehler(1).
      l_i_SJ = 10 + l_i_SJ.
     ELSE.
      l_i_SJ = l_c12_KZ+l_i_zaehler(1).
      l_i_SJ = l_i_PJ + l_i_SJ.
   ENDIF.

   l_i_SJREST = l_i_SJ MOD 10.

   IF l_i_SJREST = 0.
      l_i_SJREST = 10.
   ENDIF.

   l_i_PJ =  ( l_i_SJREST * 2 ) MOD 11.
   l_i_zaehler = l_i_zaehler + 1.

ENDWHILE.

if l_i_PJ <= 1.
   l_n1_prfziff = 0.
  else.
   l_n1_prfziff = 11 - l_i_PJ.
endif.

e_PRUEFZIFFER = l_n1_prfziff.
  endmethod.
ENDCLASS.
