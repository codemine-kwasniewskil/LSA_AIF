class /THKR/CL_MIGR_ANBU_HELPER definition
  public
  final
  create public .

public section.

  class-methods CHECK_CUM_VALUES
    importing
      !CUM_VALUES type TABLE
    returning
      value(IS_EMPTY) type ABAP_BOOL .
  class-methods CHECK_CUM_VALUE
    importing
      !CUM_VALUE type ANY
    returning
      value(IS_EMPTY) type ABAP_BOOL .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_MIGR_ANBU_HELPER IMPLEMENTATION.


  METHOD check_cum_value.

    DATA(data_in) = CORRESPONDING bapi1022_cumval( cum_value ).
    ASSIGN COMPONENT 'AFABE' OF STRUCTURE cum_value TO FIELD-SYMBOL(<afabe>).
    IF ( <afabe> = '01'
        AND data_in-acq_value IS INITIAL
        AND data_in-ord_dep   IS INITIAL
        AND data_in-unp_dep   IS INITIAL )
      OR ( <afabe> = '20'
        AND data_in-acq_value IS INITIAL
        AND data_in-ord_dep   IS INITIAL
        AND data_in-unp_dep   IS INITIAL
        AND data_in-interest  IS INITIAL ) .
      is_empty = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD check_cum_values.

    FIELD-SYMBOLS: <tp> TYPE any.
    DATA(cnt) = 0.
    LOOP AT cum_values ASSIGNING <tp>.
      IF /thkr/cl_migr_anbu_helper=>check_cum_value( cum_value = <tp> ) = abap_true.
        cnt += 1.
      ENDIF.
    ENDLOOP.
    IF cum_values IS INITIAL OR cnt = 2. "" FAREA 01 + 20 is empty!
      is_empty = abap_true.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
