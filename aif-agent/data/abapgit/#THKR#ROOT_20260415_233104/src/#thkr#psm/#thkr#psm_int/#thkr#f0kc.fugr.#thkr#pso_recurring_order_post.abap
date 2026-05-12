FUNCTION /thkr/pso_recurring_order_post.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(T_PSO_OLD) LIKE  PSO02 STRUCTURE  PSO02
*"     VALUE(I_OKCODE)
*"  TABLES
*"      T_VBKPF_OLD STRUCTURE  VBKPF OPTIONAL
*"      T_VBSEC_OLD STRUCTURE  VBSEC OPTIONAL
*"      T_VBSEG_OLD STRUCTURE  VBSEG OPTIONAL
*"      T_VBSET_OLD STRUCTURE  VBSET OPTIONAL
*"      T_PSO_NEW STRUCTURE  PSO02
*"      T_VBKPF_NEW STRUCTURE  VBKPF
*"      T_VBSEC_NEW STRUCTURE  VBSEC
*"      T_VBSEG_NEW STRUCTURE  VBSEG
*"      T_VBSET_NEW STRUCTURE  VBSET
*"      T_TIBAN STRUCTURE  TIBAN OPTIONAL
*"--------------------------------------------------------------------

* der SAP Std. Baustein benötigt die Daten auch in der Kopfzeile.
  t_pso_new = t_pso_new[ 1 ].
  t_vbkpf_new = t_vbkpf_new[ 1 ].


  CALL FUNCTION 'FI_PSO_RECURRING_ORDER_POST'
    EXPORTING
      t_pso_old   = t_pso_old
      i_okcode    = i_okcode
    TABLES
      t_vbkpf_old = t_vbkpf_old
      t_vbsec_old = t_vbsec_old
      t_vbseg_old = t_vbseg_old
      t_vbset_old = t_vbset_old
      t_pso_new   = t_pso_new
      t_vbkpf_new = t_vbkpf_new
      t_vbsec_new = t_vbsec_new
      t_vbseg_new = t_vbseg_new
      t_vbset_new = t_vbset_new
      t_tiban     = t_tiban.


ENDFUNCTION.
