*&---------------------------------------------------------------------*
*& Report ZPLE_IST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/ist_rm_check.

DATA sel TYPE bkpf.

SELECT-OPTIONS p_cpu FOR sel-cpudt.
SELECT-OPTIONS p_art FOR sel-blart.
PARAMETERS: p_sst    TYPE /thkr/dte_bu_sst.


SELECT FROM /thkr/cds_aif_ist_rm_sel_v2
   FIELDS *
   WHERE  cpudt IN @p_cpu AND
          blart IN @p_art AND
          xref1_hd = @p_sst
   INTO TABLE @DATA(ist_rm).


cl_salv_table=>factory( IMPORTING r_salv_table = DATA(salv)
                        CHANGING  t_table      = ist_rm ).

salv->display( ).
