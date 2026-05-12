FUNCTION /thkr/bp_f4if_create_filter.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(IT_CHECK_PARTNERS) TYPE  BUP_PARTNER_GUID_T OPTIONAL
*"     REFERENCE(IV_F4_TYPE) TYPE  CHAR30
*"     REFERENCE(IV_USE_GUID) TYPE  FLAG OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_SELOPTS_PARTNER) TYPE  BUS_PARTNER_RANGE_T
*"     REFERENCE(ET_SELOPTS_GUID) TYPE  BUS_PARTNER_GUID_RANGE_T
*"     REFERENCE(ET_SELOPTS_BUKRS_KNR) TYPE  /THKR/T_BP_BUKRS_RANGE
*"     REFERENCE(ET_SELOPTS_BUKRS_LIEF) TYPE  /THKR/T_BP_BUKRS_RANGE
*"     REFERENCE(ET_SELOPTS_PARTNER_CP) TYPE  PIQ_SELOPT_T
*"     REFERENCE(ET_SELOPTS_PARTNER_HASH) TYPE  /THKR/T_BP_SHLP_HASH
*"  EXCEPTIONS
*"      NO_SELOPTS
*"----------------------------------------------------------------------

  " Lese alle Partner aus
  DATA(lt_partners) = /thkr/cl_bp_general=>read_bp( EXPORTING it_check_partner = it_check_partners iv_use_guid = iv_use_guid ).
  " Berechtigungsprüfung auf Berechtigungsgruppen -> AKTVT: 03 oder F4
*  LOOP AT lt_partners ASSIGNING FIELD-SYMBOL(<fs_group>)
*    WHERE no_auth IS INITIAL
*    GROUP BY <fs_group>-augrp
*    WITHOUT MEMBERS ASSIGNING FIELD-SYMBOL(<fv_augrp>).
*    AUTHORITY-CHECK OBJECT 'B_BUPA_GRP'
*     ID 'ACTVT' FIELD '03'
*     ID 'BEGRU' FIELD <fv_augrp>.
*    IF sy-subrc NE 0.
*      AUTHORITY-CHECK OBJECT 'B_BUPA_GRP'
*        ID 'ACTVT' FIELD 'F4'
*        ID 'BEGRU' FIELD <fv_augrp>.
*    ENDIF.
*    " Wenn keine Berechtigung, markiere als nicht berechtigt
*    IF sy-subrc <> 0.
*      DELETE lt_partners
*        WHERE augrp = <fv_augrp>.
*    ENDIF.
*  ENDLOOP.

  DATA: lv_object TYPE xuobject.

  lv_object = /thkr/cl_auth_check=>get_bupa_object( ).

  IF lt_partners IS NOT INITIAL.

    SELECT DISTINCT gsber, augrp FROM @lt_partners AS partners
      INTO TABLE @DATA(lt_auth).

  ENDIF.

  LOOP AT lt_auth ASSIGNING FIELD-SYMBOL(<fs_auth>).

    DATA(lv_no_auth) = /thkr/cl_auth_check=>check_bupa_object(
                        EXPORTING iv_act = '03'
                        iv_augrp = <fs_auth>-augrp
                        iv_gsber = <fs_auth>-gsber
                        iv_object = lv_object
                         ).

    IF lv_no_auth = abap_true.

      DATA(lv_no_auth2) = /thkr/cl_auth_check=>check_bupa_object(
                        EXPORTING iv_act = 'F4'
                        iv_augrp = <fs_auth>-augrp
                        iv_gsber = <fs_auth>-gsber
                        iv_object = lv_object
                         ).
      IF lv_no_auth2 = abap_true.

        DELETE lt_partners WHERE gsber = <fs_auth>-gsber AND
        augrp = <fs_auth>-augrp.

      ENDIF.

    ENDIF.

  ENDLOOP.
*
*  " Berechtigungsprüfung auf Geschäftsbereiche -> AKTVT: 03 oder F4
*  LOOP AT lt_partners ASSIGNING FIELD-SYMBOL(<fs_group>)
*    WHERE no_auth IS INITIAL
*    GROUP BY <fs_group>-gsber
*    WITHOUT MEMBERS ASSIGNING FIELD-SYMBOL(<fv_gsber>).
*    AUTHORITY-CHECK OBJECT 'Z_BUPA_GSB'
*     ID 'ACTVT'       FIELD '03'
*     ID 'GSBER'  FIELD <fv_gsber>.
*    IF sy-subrc NE 0.
*      AUTHORITY-CHECK OBJECT 'Z_BUPA_GSB'
*       ID 'ACTVT'       FIELD 'F4'
*       ID 'GSBER'  FIELD <fv_gsber>.
*    ENDIF.
*    " Wenn keine Berechtigung, markiere als nicht berechtigt
*    IF sy-subrc NE 0.
*      DELETE lt_partners
*       WHERE gsber = <fv_gsber>.
*    ENDIF.
*  ENDLOOP.
  " Fasse gemeinsame Partner zusammen, aber bewahre die Berechtigung
  " Dafür muss das 'X' in no_auth nach oben sortiert werden, sodass dieses nicht gelöscht wird
  SORT lt_partners
    BY  partner ASCENDING
        no_auth DESCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_partners
    COMPARING partner no_auth.
  " Baue Range Tabelle für Return
  DATA: lv_cp TYPE char24.
*  LOOP AT lt_partners ASSIGNING FIELD-SYMBOL(<fs_partner>)
*    WHERE no_auth EQ ''.
*    CONCATENATE '*' <fs_partner>-partner '*' INTO lv_cp.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = <fs_partner>-partner )
*      TO et_selopts_partner.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = <fs_partner>-partner_guid )
*      TO et_selopts_guid.
*    APPEND VALUE #( sign = 'I' option = 'CP' low = lv_cp )
*      TO et_selopts_partner_cp.
*    CLEAR: lv_cp.
*  ENDLOOP.

  et_selopts_partner = VALUE #(
  FOR l_partners IN lt_partners WHERE ( no_auth = '' ) (
  sign = 'I'
  option = 'EQ'
  low = l_partners-partner
  )
  ).

  et_selopts_guid = VALUE #(
FOR l_partners IN lt_partners WHERE ( no_auth = '' ) (
sign = 'I'
option = 'EQ'
low = l_partners-partner_guid
)
).

  et_selopts_partner_cp = VALUE #(
 FOR l_partners IN lt_partners WHERE ( no_auth = '' ) (
 sign = 'I'
 option = 'CP'
 low = |*{ l_partners-partner }*|
 )
 ).

*   et_selopts_partner_hash = VALUE #(
*  FOR l_partners IN lt_partners WHERE ( no_auth = '' ) (
*  sign = 'I'
*  option = 'CP'
*  low = |*{ l_partners-partner }*|
*  )
*  ).



  " Werfe Fehler, wenn keine Einschränkung vorhanden ist
  IF et_selopts_partner IS SUPPLIED AND lines( et_selopts_partner ) = 0
      OR et_selopts_guid IS SUPPLIED AND lines( et_selopts_guid ) = 0
      OR et_selopts_partner_cp IS SUPPLIED AND lines( et_selopts_partner_cp ) = 0
*      OR et_selopts_partner_hash IS SUPPLIED AND lines( et_selopts_partner_hash ) = 0
    .
    RAISE no_selopts.
  ENDIF.


ENDFUNCTION.
