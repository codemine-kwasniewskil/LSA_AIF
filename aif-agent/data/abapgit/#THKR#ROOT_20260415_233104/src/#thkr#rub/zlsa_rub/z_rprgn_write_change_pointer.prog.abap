*&---------------------------------------------------------------------*
*& Report Z_RPRGN_WRITE_CHANGE_POINTER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_RPRGN_WRITE_CHANGE_POINTER.

TABLES: p0105.
INCLUDE mppdat00.

*---------------------------------------------------------------------*
*       FORM pa0105_change                                            *
*---------------------------------------------------------------------*
FORM pa0105_change.

  CONSTANTS lco_mem_per TYPE char10 VALUE 'BNAT_PERNR'.

  DATA: act_plvar  LIKE objec-plvar,
        lt_obj_p   LIKE hrobject   OCCURS 0 WITH HEADER LINE,
        lt_p1001   LIKE p1001      OCCURS 0 WITH HEADER LINE,
        lt_changed LIKE hrobjinfty OCCURS 0 WITH HEADER LINE.

  DATA u_pernr TYPE znsi_agr_ur_pernr.

  CHECK p0105-usrty = '0001' OR
        sy-xform EQ 'Z_NSI_AGR_RFC_UR_SET_IT0105'.

* Get active PLVAR
  CALL FUNCTION 'RH_GET_ACTIVE_WF_PLVAR'
       IMPORTING
            act_plvar       = act_plvar
       EXCEPTIONS
            no_active_plvar = 1
            OTHERS          = 2.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

  lt_obj_p-plvar = act_plvar.
  lt_obj_p-otype = 'P'.
  lt_obj_p-objid = p0105-pernr.
  APPEND lt_obj_p.

*--------------------------------------------------------------------*
*  19.09.2024 09:12:52  REPRO-KOE/SCC_00000205:  Logik für BNAT      *
*                       Aufruf aus Z_NSI_AGR_RFC_UR_SET_IT0105       *
*--------------------------------------------------------------------*
  IF sy-xform EQ 'Z_NSI_AGR_RFC_UR_SET_IT0105'.
    IMPORT u_pernr FROM MEMORY ID lco_mem_per.
    DELETE FROM MEMORY ID lco_mem_per.
    IF u_pernr IS INITIAL.
      RETURN.
    ENDIF.
    READ TABLE lt_obj_p[] INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_obj>).
    IF sy-subrc IS INITIAL.
<fs_obj>-objid = u_pernr.
    ENDIF.
  ENDIF.


* Read P--S relation
  REFRESH lt_p1001. CLEAR lt_p1001.
  CALL FUNCTION 'RH_READ_INFTY_1001'
       EXPORTING
            sort            = 'X'
       TABLES
            i1001           = lt_p1001
            objects         = lt_obj_p
       EXCEPTIONS
            nothing_found   = 1
            wrong_condition = 2
            OTHERS          = 3.
  IF sy-subrc = 0.
    LOOP AT lt_p1001
         WHERE rsign = 'B'
           AND relat = '008'
           AND sclas = 'S'.
      lt_changed-plvar = lt_p1001-plvar.
      lt_changed-otype = lt_p1001-sclas.
      lt_changed-objid = lt_p1001-sobid.
      lt_changed-infty = lt_p1001-infty.
      lt_changed-subty = 'A008'.
      lt_changed-begda = lt_p1001-begda.
      lt_changed-endda = lt_p1001-endda.
      append lt_changed.
    ENDLOOP.
  ENDIF.

* Set change pointer
  CALL FUNCTION 'RH_INFTY_CHANGE_PROT'
       TABLES
            changed_objects       = lt_changed
       EXCEPTIONS
            number_range_problems = 1
            OTHERS                = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
