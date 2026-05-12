class /THKR/CL_MIGR_GRPS_PROCESSOR definition
  public
  create public .

public section.

  class-methods COSTCENTER_GROUPS
    importing
      !VALUES type /THKR/T_BAPISET_VALUE
      !HIERARCHY type /THKR/T_BAPISET_HIER
      !TESTMODE type ABAP_BOOL
      !KOKRS type KOKRS
    raising
      /THKR/CX_FI_INIT .
  class-methods COSTELEMENT_GROUPS
    importing
      !VALUES type /THKR/T_BAPISET_VALUE
      !HIERARCHY type /THKR/T_BAPISET_HIER
      !TESTMODE type ABAP_BOOL
      !KTOPL type KTOPL
    raising
      /THKR/CX_FI_INIT .
  class-methods INTERNALORDER_GROUPS
    importing
      !VALUES type /THKR/T_BAPISET_VALUE
      !HIERARCHY type /THKR/T_BAPISET_HIER
      !TESTMODE type ABAP_BOOL
    raising
      /THKR/CX_FI_INIT .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_MIGR_GRPS_PROCESSOR IMPLEMENTATION.


  METHOD costcenter_groups.
    DATA setval   TYPE TABLE OF bapi1112_values.
    DATA bapiret  TYPE bapiret2.
    " Convert values:
    LOOP AT values  ASSIGNING FIELD-SYMBOL(<line>).
      setval = VALUE #( BASE setval ( valfrom = <line>-valfrom valto = <line>-valto ) ).
    ENDLOOP.

    IF testmode = abap_false.
      CALL FUNCTION 'BAPI_COSTCENTERGROUP_CREATE'
        EXPORTING
          controllingareaimp = kokrs
        IMPORTING
          return             = bapiret
        TABLES
          hierarchynodes     = hierarchy
          hierarchyvalues    = setval.
      IF bapiret IS NOT INITIAL.
        RAISE EXCEPTION TYPE /thkr/cx_fi_init EXPORTING bapiret2 = bapiret.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD costelement_groups.
    DATA setval   TYPE TABLE OF bapi1113_values.
    DATA bapiret  TYPE bapiret2.
    " Convert values:
    LOOP AT values ASSIGNING FIELD-SYMBOL(<line>).
      setval = VALUE #( BASE setval ( valfrom = <line>-valfrom valto = <line>-valto ) ).
    ENDLOOP.
    IF testmode = abap_false.
      CALL FUNCTION 'BAPI_COSTELEMENTGRP_CREATE'
        EXPORTING
          chartofaccountsimp = ktopl
        IMPORTING
          return             = bapiret
        TABLES
          hierarchynodes     = hierarchy
          hierarchyvalues    = setval.
      IF bapiret IS NOT INITIAL.
        RAISE EXCEPTION TYPE /thkr/cx_fi_init EXPORTING bapiret2 = bapiret.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD internalorder_groups.
    DATA setval   TYPE TABLE OF bapi1117_values.
    DATA bapiret  TYPE bapiret2.
    " Convert values:
    LOOP AT values ASSIGNING FIELD-SYMBOL(<line>).
      setval = VALUE #( BASE setval ( valfrom = <line>-valfrom valto = <line>-valto ) ).
    ENDLOOP.
    IF testmode = abap_false.
      CALL FUNCTION 'BAPI_INTERNALORDRGRP_CREATE'
        IMPORTING
          return          = bapiret
        TABLES
          hierarchynodes  = hierarchy
          hierarchyvalues = setval.
      IF bapiret IS NOT INITIAL.
        RAISE EXCEPTION TYPE /thkr/cx_fi_init EXPORTING bapiret2 = bapiret.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
