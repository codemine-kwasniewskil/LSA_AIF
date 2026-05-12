class /THKR/CL_IM_CHANGE_BS_DATA definition
  public
  final
  create public .

public section.

  interfaces IF_EX_FIEB_CHANGE_BS_DATA .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_IM_CHANGE_BS_DATA IMPLEMENTATION.


  METHOD if_ex_fieb_change_bs_data~change_data.
**********************************************************************************
* Der Fuba /THKR/ELKO_GET_POSTING ermittelt anhand von MT940-Umsätzen die passende Buchungsregel.
* Die zu verwendeten Buchungsregeln sin in der Tabelle /THKR/MT940 hinterlegt.
************************************************************************************

    DATA: lv_butxt TYPE butxt_eb,
          lv_vozei TYPE epvoz_eb.

    FIELD-SYMBOLS:
              <fs_febre>  TYPE febre.

*--- nur für MT940-Sätze, die umgeschlüsselt werden müssen
    LOOP AT t_febre ASSIGNING <fs_febre>.
      IF <fs_febre>-kukey = c_febep-kukey AND <fs_febre>-esnum = c_febep-esnum AND <fs_febre>-rsnum = 1.
        lv_butxt = c_febep-butxt.
      ENDIF.
    ENDLOOP.

    IF c_febep-epvoz = 'H'.
      lv_vozei = 'C'.
    ELSE.
      lv_vozei = 'D'.
    ENDIF.

    CALL FUNCTION '/THKR/ELKO_GET_POSTING'
      EXPORTING
        i_vgext = c_febep-vgext
        i_texts = c_febep-texts
        i_vozei = lv_vozei
        i_butxt = lv_butxt
        i_kukey = c_febep-kukey
        i_esnum = c_febep-esnum
      IMPORTING
        e_vgint = c_febep-vgint
        e_intag = c_febep-intag.
  ENDMETHOD.
ENDCLASS.
