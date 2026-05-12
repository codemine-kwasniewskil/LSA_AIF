FUNCTION /thkr/bcs_termtable_read.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_CLIENT) TYPE  MANDT DEFAULT SPACE
*"  TABLES
*"      T_REPTERM STRUCTURE  /THKR/KF_REPTERM
*"      T_BUKF_KF STRUCTURE  /THKR/KF_KF OPTIONAL
*"      T_BUKF_KF_T STRUCTURE  /THKR/KF_KF_T OPTIONAL
*"      T_BUKF_KFDSRC STRUCTURE  /THKR/KF_KFDSRC OPTIONAL
*"  EXCEPTIONS
*"      NO_CLIENT
*"----------------------------------------------------------------------

  DATA: l_mandt LIKE t000-mandt.

  CONSTANTS: con_report(2) TYPE c VALUE 'ZB'.


  IF NOT i_client IS INITIAL.
    SELECT SINGLE mandt INTO l_mandt FROM t000 WHERE mandt = i_client.
    IF sy-subrc <> 0.
      RAISE no_client.
    ENDIF.

    SELECT * FROM /THKR/kf_repterm CLIENT SPECIFIED     "#EC CI_GENBUFF
                               INTO TABLE t_repterm
                               WHERE client = i_client.

    IF t_bukf_kf IS REQUESTED.
      SELECT * FROM /THKR/kf_kf CLIENT SPECIFIED        "#EC CI_GENBUFF
                             INTO TABLE t_bukf_kf
                             WHERE client = i_client
                               AND applic = con_report.

    ENDIF.

    IF t_bukf_kf_t IS REQUESTED.
      SELECT * FROM /THKR/kf_kf_t CLIENT SPECIFIED      "#EC CI_GENBUFF
                             INTO TABLE t_bukf_kf_t
                             WHERE client = i_client
                               AND applic = con_report.

    ENDIF.

    IF t_bukf_kfdsrc IS REQUESTED.
      SELECT * FROM /THKR/kf_kfdsrc CLIENT SPECIFIED    "#EC CI_GENBUFF
                             INTO TABLE t_bukf_kfdsrc
                             WHERE client = i_client
                               AND applic = con_report.

    ENDIF.



  ELSE.
    SELECT * FROM /THKR/kf_repterm INTO TABLE t_repterm. "#EC CI_GENBUFF

    IF t_bukf_kf IS REQUESTED.
      SELECT * FROM /THKR/kf_kf INTO TABLE t_bukf_kf    "#EC CI_GENBUFF
                             WHERE applic = con_report.
    ENDIF.

    IF t_bukf_kf_t IS REQUESTED.
      SELECT * FROM /THKR/kf_kf_t INTO TABLE t_bukf_kf_t "#EC CI_GENBUFF
                             WHERE applic = con_report.
    ENDIF.

    IF t_bukf_kfdsrc IS REQUESTED.
      SELECT * FROM /THKR/kf_kfdsrc INTO TABLE t_bukf_kfdsrc "#EC CI_GENBUFF
                             WHERE applic = con_report.
    ENDIF.


  ENDIF.



ENDFUNCTION.
