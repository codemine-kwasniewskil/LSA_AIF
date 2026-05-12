class /THKR/CL_FUNDCTR_HIER_CRAWLER definition
  public
  create protected .

public section.

  class-methods GET
    importing
      !HIVARNT type FM_HIVARNT
      !FIKRS type FIKRS default '1000'
    returning
      value(SELF) type ref to /THKR/CL_FUNDCTR_HIER_CRAWLER .
  methods CONSTRUCTOR
    importing
      !HIVARNT type FM_HIVARNT
      !FIKRS type FIKRS .
  methods GET_NODE_PATH_UP
    importing
      !FICTR_FROM type FM_FICTR
      !FICTR_TO type FM_FICTR optional
    returning
      value(NODES) type /THKR/T_FICTR .
  methods IS_PARENT_CHILD_RELATION
    importing
      !FICTR_PARENT type FM_FICTR
      !FICTR_CHILD type FM_FICTR
    returning
      value(IS_CORRECT) type ABAP_BOOLEAN .
  methods GET_ALL_NODES_PATH_UP
    importing
      !FICTR_FROM type FM_FICTR
    returning
      value(NODES) type /THKR/T_FICTR .
protected section.

  data HIVARNT type FM_HIVARNT .
  class-data INSTANCE type ref to /THKR/CL_FUNDCTR_HIER_CRAWLER .
  data FIKRS type FIKRS .
  data HIERARCHY type FMFUNDS_CTR_HIVARNT_DB_T .

  methods GET_CHILD
    importing
      !FICTR type FM_FICTR
    returning
      value(CHILD) type FM_FICTR .
  methods GET_PARENT
    importing
      !FICTR type FM_FICTR
    returning
      value(PARENT) type FM_FICTR .
private section.
ENDCLASS.



CLASS /THKR/CL_FUNDCTR_HIER_CRAWLER IMPLEMENTATION.


  METHOD constructor.
    me->hivarnt = hivarnt.
    me->fikrs = fikrs.

    CALL FUNCTION 'FM_HIVARNT_READ_HIERARCHY'
      EXPORTING
        i_fikrs   = me->fikrs
        i_hivarnt = me->hivarnt
*       I_FLG_SORT       = 'X'
      TABLES
        t_fmhisv  = me->hierarchy.

  ENDMETHOD.


  METHOD get.
    IF instance IS NOT BOUND.
      instance = NEW #( hivarnt = hivarnt fikrs = fikrs ).
    ENDIF.
    self = instance.
  ENDMETHOD.


  METHOD GET_ALL_NODES_PATH_UP.
    nodes = VALUE #( ( fictr_from ) ).
    DATA(node) = me->get_parent( fictr_from ).
    WHILE node IS NOT INITIAL.
      nodes = VALUE #( BASE nodes ( node ) ).
      node = me->get_parent( node ).
    ENDWHILE.
  ENDMETHOD.


  METHOD get_child.
    TRY.
        child = me->hierarchy[ fistl = fictr ]-child_st.
      CATCH cx_sy_itab_line_not_found.
        "keep it empty!
    ENDTRY.
  ENDMETHOD.


  METHOD get_node_path_up.
*    nodes = VALUE #( ( fictr_from ) ).
    DATA(all_nodes) = me->get_all_nodes_path_up( fictr_from = fictr_from ).

** Check if target has reached otherwise we return an empty list:
   CHECK line_exists( all_nodes[ table_line = fictr_to ] ).

** lets provide the nodes between:
    LOOP AT all_nodes INTO DATA(node) WHERE table_line <> fictr_from.
      IF node = fictr_to.
        EXIT.
      ENDIF.
      nodes = VALUE #( BASE nodes ( node ) ).
    ENDLOOP.
  ENDMETHOD.


  METHOD GET_PARENT.
    TRY.
        parent = me->hierarchy[ fistl = fictr ]-parent_st.
      CATCH cx_sy_itab_line_not_found.
        "keep it empty!
    ENDTRY.
  ENDMETHOD.


  METHOD is_parent_child_relation.
    IF me->get_child( fictr_parent ) = fictr_child.
      is_correct = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
