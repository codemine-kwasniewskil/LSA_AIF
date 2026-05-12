CLASS /thkr/cl_pseudo_process_bp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES /thkr/if_pseudo_process .

    ALIASES chunk_size
      FOR /thkr/if_pseudo_process~chunk_size .
    ALIASES testmode
      FOR /thkr/if_pseudo_process~testmode .
    ALIASES process
      FOR /thkr/if_pseudo_process~process_data .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS process_grps
      CHANGING
        !results TYPE /thkr/tools_pseudo_results .
    METHODS process_orgs
      CHANGING
        !results TYPE /thkr/tools_pseudo_results .
    METHODS process_person
      CHANGING
        !results TYPE /thkr/tools_pseudo_results .
    METHODS modify_db
      IMPORTING
        !i_data TYPE data .
ENDCLASS.



CLASS /THKR/CL_PSEUDO_PROCESS_BP IMPLEMENTATION.


  METHOD /thkr/if_pseudo_process~process_data.

    me->chunk_size = i_chunksize.
    me->testmode   = i_testmode.

    me->process_person( CHANGING results = results ).

    me->process_orgs( CHANGING results = results ).

    me->process_grps( CHANGING results = results ).

  ENDMETHOD.


  METHOD modify_db.
    ASSIGN i_data TO FIELD-SYMBOL(<data>).

    MODIFY but000 FROM TABLE @<data>.

    COMMIT WORK AND WAIT.
  ENDMETHOD.


  METHOD process_grps.
    DATA(nat_names) = /thkr/cl_pseudo_datasets=>get_orgs( ).
    DATA(start) = 0.

    WHILE start <> -1.
      SELECT FROM but000
          FIELDS *
          WHERE type = 3
          ORDER BY PRIMARY KEY
          INTO TABLE @DATA(chunks) "PACKAGE SIZE @me->chunk_size.
          UP TO @me->chunk_size ROWS OFFSET @start.
      IF sy-subrc  = 0.
        LOOP AT chunks ASSIGNING FIELD-SYMBOL(<but_wa>).
          "** Lets mix the names
          DATA(new_name) = nat_names[ sy-tabix MOD 19 + 1 ].
          <but_wa> = VALUE #( BASE <but_wa> bu_sort1  = new_name-field1 bu_sort2  = new_name-field2
                                            mc_name1  = new_name-field1 mc_name2  = new_name-field2
                                            name_grp1 = new_name-field1 name_grp2 = new_name-field2 ).
          results = VALUE #( BASE results ( result_key = <but_wa>-partner fields = new_name ) ).
        ENDLOOP.
        IF me->testmode = abap_false.
          me->modify_db( i_data = chunks ).
        ENDIF.
        start += me->chunk_size.
      ELSE.
        "** Stop here:
        start = -1.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.


  METHOD process_orgs.
    DATA(nat_names) = /thkr/cl_pseudo_datasets=>get_orgs( ).
    DATA(start) = 0.

    WHILE start <> -1.
      SELECT FROM but000
          FIELDS *
          WHERE type = 2
          ORDER BY PRIMARY KEY
          INTO TABLE @DATA(chunks) "PACKAGE SIZE @me->chunk_size.
          UP TO @me->chunk_size ROWS OFFSET @start.
      IF sy-subrc  = 0.
        LOOP AT chunks ASSIGNING FIELD-SYMBOL(<but_wa>).
          "** Lets mix the names
          DATA(new_name) = nat_names[ sy-tabix MOD 19 + 1 ].
          <but_wa> = VALUE #( BASE <but_wa> bu_sort1  = new_name-field1 bu_sort2  = new_name-field2
                                            mc_name1  = new_name-field1 mc_name2  = new_name-field2
                                            name_org1 = new_name-field1 name_org2 = new_name-field2
                                            name_org3 = new_name-field3 name_org4 = new_name-field4 ).
          results = VALUE #( BASE results ( result_key = <but_wa>-partner fields = new_name ) ).
        ENDLOOP.
        IF me->testmode = abap_false.
          me->modify_db( i_data = chunks ).
        ENDIF.
        start += me->chunk_size.
      ELSE.
        "** Stop here:
        start = -1.
      ENDIF.
    ENDWHILE.

  ENDMETHOD.


  METHOD process_person.
    DATA(nat_names) = /thkr/cl_pseudo_datasets=>get_names( ).
    DATA(start) = 0.

    WHILE start <> -1.
      SELECT FROM but000
          FIELDS *
          WHERE type = 1
          ORDER BY PRIMARY KEY
          INTO TABLE @DATA(chunks) "PACKAGE SIZE @me->chunk_size.
          UP TO @me->chunk_size ROWS OFFSET @start.
      IF sy-subrc  = 0.
        LOOP AT chunks ASSIGNING FIELD-SYMBOL(<but_wa>).
          "** Lets mix the names
          DATA(new_name) = nat_names[ sy-tabix MOD 19 + 1 ].
          <but_wa> = VALUE #( BASE <but_wa> bu_sort1  = new_name-field1 bu_sort2   = new_name-field2
                                            mc_name1  = new_name-field1 mc_name2   = new_name-field2
                                            name_last = new_name-field2 name_first = new_name-field1 ).
          results = VALUE #( BASE results ( result_key = <but_wa>-partner fields = new_name ) ).
        ENDLOOP.
        IF me->testmode = abap_false.
          me->modify_db( i_data = chunks ).
        ENDIF.
        start += me->chunk_size.
      ELSE.
        "** Stop here:
        start = -1.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
