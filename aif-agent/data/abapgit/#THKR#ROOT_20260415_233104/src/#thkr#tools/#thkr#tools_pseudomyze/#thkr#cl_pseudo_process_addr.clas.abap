CLASS /thkr/cl_pseudo_process_addr DEFINITION
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

    METHODS process_addrs_bp_link
      CHANGING
        !results TYPE /thkr/tools_pseudo_results .
    METHODS process_addrs
      CHANGING
        !results TYPE /thkr/tools_pseudo_results .
    METHODS modify_db
      IMPORTING
        !i_data TYPE data
        !i_db   TYPE tabname .
ENDCLASS.



CLASS /THKR/CL_PSEUDO_PROCESS_ADDR IMPLEMENTATION.


  METHOD /thkr/if_pseudo_process~process_data.

    me->chunk_size = i_chunksize.
    me->testmode   = i_testmode.

    me->process_addrs( CHANGING results = results ).
    me->process_addrs_bp_link( CHANGING results = results ).

  ENDMETHOD.


  METHOD modify_db.
    ASSIGN i_data TO FIELD-SYMBOL(<data>).

    MODIFY (i_db) FROM TABLE @<data>.

  ENDMETHOD.


  METHOD process_addrs.
    DATA(address) = /thkr/cl_pseudo_datasets=>get_addr( ).
    DATA(names) = /thkr/cl_pseudo_datasets=>get_orgs( ).
    DATA(start) = 0.

    WHILE start <> -1.
      SELECT FROM adrc
          FIELDS *
          WHERE name1 <> @abap_false
              ORDER BY PRIMARY KEY
          INTO TABLE @DATA(chunks)
         UP TO @me->chunk_size ROWS OFFSET @start.
      IF sy-subrc  = 0.
        LOOP AT chunks ASSIGNING FIELD-SYMBOL(<wa>).
          "** Lets mix the names
          DATA(new_address) = address[ sy-tabix MOD 19 + 1 ].
          DATA(new_name) = names[ sy-tabix MOD 19 + 1 ].
          <wa> = VALUE #( BASE <wa> name1      = new_name-field1    sort1     = new_name-field1 mc_name1 = new_name-field1
                                    name2      = new_name-field2
                                    name3      = new_name-field3
                                    name4      = new_name-field4
                                    street     = new_address-field1 mc_street = new_address-field1
                                    city1      = new_address-field3 mc_city1  = new_address-field3
                                    post_code1 = new_address-field2 ).
          results = VALUE #( BASE results ( result_key = |{ <wa>-addrnumber }-{ <wa>-date_from }-{ <wa>-date_to }-NAME| fields = new_name ) ).
          results = VALUE #( BASE results ( result_key = |{ <wa>-addrnumber }-{ <wa>-date_from }-{ <wa>-date_to }-ADDRS| fields = new_address ) ).
        ENDLOOP.
        IF me->testmode = abap_false.
          me->modify_db( i_data = chunks i_db = 'ADRC' ).
        ENDIF.
        start += me->chunk_size.
      ELSE.
        "** Stop here:
        start = -1.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.


  METHOD process_addrs_bp_link.
    DATA(address) = /thkr/cl_pseudo_datasets=>get_addr( ).
    DATA(start) = 0.

    WHILE start <> -1.
      SELECT FROM adrc
          FIELDS *
          WHERE name1 = @abap_false  "** In BP linked, PW is empty
          ORDER BY PRIMARY KEY
          INTO TABLE @DATA(chunks)
          UP TO @me->chunk_size ROWS OFFSET @start.
      IF sy-subrc  = 0.
        LOOP AT chunks ASSIGNING FIELD-SYMBOL(<wa>).
          "** Lets mix the names
          DATA(new_address) = address[ sy-tabix MOD 19 + 1 ].
          <wa> = VALUE #( BASE <wa> street     = new_address-field1 mc_street = new_address-field1
                                    city1      = new_address-field3 mc_city1  = new_address-field3
                                    post_code1 = new_address-field2 ).
          results = VALUE #( BASE results ( result_key = |{ <wa>-addrnumber }-{ <wa>-date_from }-{ <wa>-date_to }-ADDRS| fields = new_address ) ).
        ENDLOOP.
        IF me->testmode = abap_false.
          me->modify_db( i_data = chunks i_db = 'ADRC' ).
        ENDIF.
        start += me->chunk_size.
      ELSE.
        "** Stop here:
        start = -1.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.
ENDCLASS.
