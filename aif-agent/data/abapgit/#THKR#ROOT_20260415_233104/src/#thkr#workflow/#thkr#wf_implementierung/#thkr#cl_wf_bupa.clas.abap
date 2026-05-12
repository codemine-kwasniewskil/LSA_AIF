class /THKR/CL_WF_BUPA definition
  public
  final
  create public .

public section.

  class-methods LESEN_SPERREN
    importing
      !IV_BUSINESSPARTNER type BU_PARTNER
    exporting
      !ET_SPERREN type /THKR/TT_WF_BPSPR .
  class-methods NONRELEASEKENNZ_EXXEN
    importing
      !IV_BUSINESSPARTNER type BU_PARTNER
    exporting
      !ET_RETURN type BAPIRET2_T .
  class-methods NONRELEASEKENNZ_ENTEXXEN
    importing
      !IV_BUSINESSPARTNER type BU_PARTNER
    exporting
      !ET_RETURN type BAPIRET2_T .
  class-methods SET_DELETEFLAG
    importing
      !IV_BUSINESSPARTNER type BU_PARTNER
    exporting
      !ET_RETURN type BAPIRET2_T .
  class-methods READ_CHANGEDOCUMENTS
    importing
      !IV_BUSINESSPARTNER type BU_PARTNER
      !IV_WIID type SWW_WIID optional
    exporting
      !ET_CDPOS type TT_CDRED .
  class-methods LFA_SPERRE_EXXEN
    importing
      !IV_BUSINESSPARTNER type BU_PARTNER
    exporting
      !ET_RETURN type BAPIRET2_T .
  class-methods LFA_SPERREENTEXXEN
    importing
      !IV_BUSINESSPARTNER type BU_PARTNER
    exporting
      !ET_RETURN type BAPIRET2_T .
  class-methods DELETE_GP .
  class-methods KNA_SPERREENTEXXEN
    importing
      !IV_BUSINESSPARTNER type BU_PARTNER
    exporting
      !ET_RETURN type BAPIRET2_T .
  class-methods KNA_SPERRE_EXXEN
    importing
      !IV_BUSINESSPARTNER type BU_PARTNER
    exporting
      !ET_RETURN type BAPIRET2_T .
  class-methods GET_AUSNAHMEN
    exporting
      !ET_BPKIND type /THKR/TT_BU_BPKIND
      !ET_BPGROUP type /THKR/TT_BU_BPGROUP .
protected section.

  class-methods GET_DETAIL .
  class-methods GET_BUPA_INSTANCES
    importing
      !IV_BUSINESSPARTNER type BU_PARTNER
    exporting
      !ET_INSTANZEN type /THKR/TT_BUPA_INSTA .
private section.
ENDCLASS.



CLASS /THKR/CL_WF_BUPA IMPLEMENTATION.


  method DELETE_GP.
* Direkt löschen nur, wenn bei der Genehmigung "neuer BUPA"
* abgelehnt wird. Es ist sinnlos, diese GP im System zu behalten







  endmethod.


  METHOD get_ausnahmen.
* lesen der GP-Arten, die keinen WF auslösen sollen

    CLEAR et_bpkind.
    Clear et_bpgroup.

    SELECT value_von
      FROM /thkr/t_wf_param
      INTO TABLE @et_bpkind
      WHERE object = 'NON_WF_BPKIND'.




    SELECT value_von
      FROM /thkr/t_wf_param
      INTO TABLE @et_bpgroup
      WHERE object = 'NON_WF_BPGROUP'.


* Abfrage , ob erfolgreich erfolgt auf der anderen Seite



  ENDMETHOD.


  METHOD get_bupa_instances.
* Lesen aller zugehörigen Instanzen (Adressnummer etc)

    DATA ls_insta  TYPE /thkr/s_bupa_insta.
    DATA ls_data TYPE bapibus1006_central.
    DATA ls_info TYPE bapibus1006_central_info.
    DATA lt_partnerroles TYPE fsbp_bapi_bproles_tty.
    DATA ls_partnerroles  TYPE bapibus1006_bproles.
DATA lt_Return type bapiret2_t.

    FIELD-SYMBOLS <fs_partnerroles> TYPE bapibus1006_bproles.

**********************************************

    CALL FUNCTION 'BUPA_CENTRAL_GET_DETAIL'
      EXPORTING
        iv_partner   = iv_businesspartner
*       IV_PARTNER_GUID               =
*       IV_VALID_DATE  = SY-DATUM
*       IV_REQ_MASK  = 'X'
      IMPORTING
        es_data      = ls_data
*       es_data_person = ls_person
*       es_data_organ  = ls_organ
*       es_data_group  = ls_group
        es_data_info = ls_info
*       ev_category  = lv_category
*       ev_group     = lv_group
      .


    ls_insta-objectclas = 'ADRESSE2'.

    CALL FUNCTION 'BUPA_ROLES_GET_2'
      EXPORTING
        iv_partner      = iv_businesspartner
*       IV_PARTNER_GUID =
*       IV_DATE         = SY-DATLO
      TABLES
        et_partnerroles = lt_partnerroles
        et_return       = lt_return.

    IF lt_partnerroles IS NOT INITIAL.

      LOOP AT  lt_partnerroles ASSIGNING <fs_partnerroles>.
        CASE <fs_partnerroles>-partnerrole.
          WHEN 'ZDE02'.

            ls_insta-objectclas = 'DEBI'.
            ls_insta-objectclas = iv_businesspartner.

            APPEND ls_insta  TO et_instanzen.
          WHEN 'ZKR02'.

            ls_insta-objectclas = 'KRED'.
            ls_insta-objectclas = iv_businesspartner.
            APPEND ls_insta  TO et_instanzen.
        ENDCASE.

      ENDLOOP.
    ENDIF.



  ENDMETHOD.


  method GET_DETAIL.



  endmethod.


  method KNA_SPERREENTEXXEN.
* Kunde wird nicht automatisch mit GP gesperrt

DATa ls_kna1 type kna1.

    SELECT SINGLE * FROM kna1
      into @ls_kna1
      WHERE KUNNR = @iv_businesspartner
      AND  loevm NE 'X'.

* Gefunden?

    IF sy-subrc EQ 0.
* Löschen Zentrale Sperre
ls_kna1-SPERR = ' '.
" ls_kna1-AUFSD = ' '.
"ls_kna1-LIFSD = ' '.
"ls_kna1-FAKSD = ' '.
"ls_kna1-CASSD = ' '.

CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
 EXPORTING
   I_KNA1                              = ls_kna1
 EXCEPTIONS
   CLIENT_ERROR                        = 1
   KNA1_INCOMPLETE                     = 2
   KNB1_INCOMPLETE                     = 3
   KNB5_INCOMPLETE                     = 4
   KNVV_INCOMPLETE                     = 5
   KUNNR_NOT_UNIQUE                    = 6
   SALES_AREA_NOT_UNIQUE               = 7
   SALES_AREA_NOT_VALID                = 8
   INSERT_UPDATE_CONFLICT              = 9
   NUMBER_ASSIGNMENT_ERROR             = 10
   NUMBER_NOT_IN_RANGE                 = 11
   NUMBER_RANGE_NOT_EXTERN             = 12
   NUMBER_RANGE_NOT_INTERN             = 13
   ACCOUNT_GROUP_NOT_VALID             = 14
   PARNR_INVALID                       = 15
   BANK_ADDRESS_INVALID                = 16
   TAX_DATA_NOT_VALID                  = 17
   NO_AUTHORITY                        = 18
   COMPANY_CODE_NOT_UNIQUE             = 19
   DUNNING_DATA_NOT_VALID              = 20
   KNB1_REFERENCE_INVALID              = 21
   CAM_ERROR                           = 22
   OTHERS                              = 23
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

    ENDIF.

  endmethod.


  METHOD KNA_SPERRE_EXXEN.
* Kunde wird nicht automatisch mit GP gesperrt

DATa ls_kna1 type kna1.

    SELECT SINGLE * FROM kna1
      into @ls_kna1
      WHERE KUNNR = @iv_businesspartner
      AND  loevm NE 'X'.

* Gefunden?

    IF sy-subrc EQ 0.
* Löschen Zentrale Sperre
ls_kna1-SPERR = 'X'.
" ls_kna1-AUFSD = ' '.
"ls_kna1-LIFSD = ' '.
"ls_kna1-FAKSD = ' '.
"ls_kna1-CASSD = ' '.


CALL FUNCTION 'SD_CUSTOMER_MAINTAIN_ALL'
 EXPORTING
   I_KNA1                              = ls_kna1
 EXCEPTIONS
   CLIENT_ERROR                        = 1
   KNA1_INCOMPLETE                     = 2
   KNB1_INCOMPLETE                     = 3
   KNB5_INCOMPLETE                     = 4
   KNVV_INCOMPLETE                     = 5
   KUNNR_NOT_UNIQUE                    = 6
   SALES_AREA_NOT_UNIQUE               = 7
   SALES_AREA_NOT_VALID                = 8
   INSERT_UPDATE_CONFLICT              = 9
   NUMBER_ASSIGNMENT_ERROR             = 10
   NUMBER_NOT_IN_RANGE                 = 11
   NUMBER_RANGE_NOT_EXTERN             = 12
   NUMBER_RANGE_NOT_INTERN             = 13
   ACCOUNT_GROUP_NOT_VALID             = 14
   PARNR_INVALID                       = 15
   BANK_ADDRESS_INVALID                = 16
   TAX_DATA_NOT_VALID                  = 17
   NO_AUTHORITY                        = 18
   COMPANY_CODE_NOT_UNIQUE             = 19
   DUNNING_DATA_NOT_VALID              = 20
   KNB1_REFERENCE_INVALID              = 21
   CAM_ERROR                           = 22
   OTHERS                              = 23
          .
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

    ENDIF.



* TODO Änderungszeiger setzen!!!
  ENDMETHOD.


  METHOD lesen_sperren.
* Lesen der bereits gesetzen Sperren und Rückgabe an WF
* Damit soll sicher gestellt werden, dass diese nicht wieder rückgängig gemacht
* werden beim Entsperren


    DATA ls_sperre TYPE /thkr/t_wf_bpspr.

*    FIELD-SYMBOLS <fs_lfb1> TYPE any .
*    FIELD-SYMBOLS <fs_knb1> TYPE any .
*    FIELD-SYMBOLS <fs_knvv> TYPE any .

    SELECT SINGLE xblck FROM but000
      INTO @ls_sperre-xblck_000
      WHERE partner EQ @iv_businesspartner.

    SELECT SINGLE sperr, sperm, sperz FROM lfa1
      INTO ( @ls_sperre-sperr_lfa,
             @ls_sperre-sperm_lfa,
             @ls_sperre-sperz_lfa )
      WHERE lifnr  EQ @iv_businesspartner.

    SELECT SINGLE aufsd, faksd, lifsd, sperr, sperz FROM kna1
      INTO ( @ls_sperre-aufsd_kna,
             @ls_sperre-faksd_kna,
             @ls_sperre-lifsd_kna,
             @ls_sperre-sperr_kna,
             @ls_sperre-sperz_kna )
      WHERE kunnr  EQ @iv_businesspartner.

    IF ls_sperre IS NOT INITIAL.
      ls_sperre-partner = iv_businesspartner.
      APPEND ls_sperre TO et_sperren.
    ENDIF.


    SELECT   FROM lfb1
            FIELDS bukrs, sperr
            WHERE lifnr  EQ @iv_businesspartner
            INTO   TABLE @DATA(lt_lfb1).

    IF sy-subrc EQ 0.
      LOOP AT lt_lfb1 ASSIGNING FIELD-SYMBOL(<fs_lfb1>).
        ls_sperre-bukrs_lfb = <fs_lfb1>-bukrs.
        ls_sperre-sperr_lfb = <fs_lfb1>-sperr.
        ls_sperre-partner = iv_businesspartner.
        APPEND ls_sperre TO et_sperren.
      ENDLOOP.
    ENDIF.



    SELECT   FROM knb1
            FIELDS bukrs, sperr, zahls
            WHERE kunnr EQ @iv_businesspartner
            INTO   TABLE @DATA(lt_knb1).


    IF sy-subrc EQ 0.
      LOOP AT lt_knb1 ASSIGNING FIELD-SYMBOL(<fs_knb1>).
        ls_sperre-bukrs_knb = <fs_knb1>-bukrs.
        ls_sperre-sperr_knb = <fs_knb1>-sperr.
        ls_sperre-zahls_knb = <fs_knb1>-zahls.
        ls_sperre-partner = iv_businesspartner.
        APPEND ls_sperre TO et_sperren.
      ENDLOOP.
    ENDIF.



    SELECT   FROM knvv
            FIELDS vkorg,
                  vtweg,
                  spart,
                  aufsd,
                  lifsd,
                  faksd
            WHERE kunnr  EQ @iv_businesspartner
            INTO   TABLE @DATA(lt_knvv).

    IF sy-subrc EQ 0.
      LOOP AT lt_knvv ASSIGNING FIELD-SYMBOL(<fs_knvv>).

        CONCATENATE <fs_knvv>-vkorg  <fs_knvv>-vtweg  <fs_knvv>-spart  INTO ls_sperre-key_knvv.
        ls_sperre-aufsd_knv = <fs_knvv>-aufsd.
        ls_sperre-lifsd_knv = <fs_knvv>-lifsd.
        ls_sperre-faksd_knv = <fs_knvv>-faksd.
        ls_sperre-partner = iv_businesspartner.
        APPEND ls_sperre TO et_sperren.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD lfa_sperreentexxen.
* Lieferant wird nicht automatisch mit GP gesperrt

*DATa lv_lifnr type lifnr.
    DATA: ls_lfa1_old TYPE lfa1,
          ls_lfa1_new TYPE lfa1,
          lv_objid type CDHDR-OBJECTID.

    SELECT SINGLE * FROM lfa1
      INTO @ls_lfa1_old
      WHERE lifnr = @iv_businesspartner
      AND  loevm NE 'X'.

* Gefunden?

    IF sy-subrc EQ 0.

      UPDATE lfa1   SET  sperr = ' ',
                          sperm = ' '
      WHERE   lifnr = @iv_businesspartner.

      IF sy-subrc = 0.
        "Änderungsbelege schreiben
        ls_lfa1_new = ls_lfa1_old.
        ls_lfa1_new-sperr = ' '.
        ls_lfa1_new-sperm = ' '.

        lv_objid = iv_businesspartner.

        CALL FUNCTION 'CHANGEDOCUMENT_OPEN'
          EXPORTING
            objectclass      = 'KRED           '
            objectid         =  lv_objid
*           planned_change_number   = planned_change_number
*           planned_or_real_changes = planned_or_real_changes
          EXCEPTIONS
            sequence_invalid = 1
            OTHERS           = 2.

        CASE sy-subrc.
          WHEN 1. MESSAGE a001(f2) WITH 'SEQUENCE INVALID'.
          WHEN 2. MESSAGE a001(f2) WITH 'OPEN ERROR'.
        ENDCASE.

        CALL FUNCTION 'CHANGEDOCUMENT_SINGLE_CASE'
          EXPORTING
            tablename              = 'LFA1                          '
            workarea_old           = ls_lfa1_old
            workarea_new           = ls_lfa1_new
            change_indicator       = 'U'
            docu_delete            = 'X'
          EXCEPTIONS
            nametab_error          = 1
            open_missing           = 2
            position_insert_failed = 3
            OTHERS                 = 4.
        CASE sy-subrc.
          WHEN 1. MESSAGE a001(f2) WITH 'NAMETAB-ERROR'.
          WHEN 2. MESSAGE a001(f2) WITH 'OPEN MISSING'.
          WHEN 3. MESSAGE a001(f2) WITH 'INSERT ERROR'.
          WHEN 4. MESSAGE a001(f2) WITH 'SINGLE ERROR'.
        ENDCASE.

        CALL FUNCTION 'CHANGEDOCUMENT_CLOSE'
          EXPORTING
            objectclass             = 'KRED           '
            objectid                =  lv_objid
            date_of_change          = sy-datum
            time_of_change          = sy-uzeit
            tcode                   = 'BP'
            username                = sy-uname
            object_change_indicator = 'U'
*NO_CHANGE_POINTERS           = NO_CHANGE_POINTERS
          EXCEPTIONS
            header_insert_failed    = 1
            object_invalid          = 2
            open_missing            = 3
            no_position_inserted    = 4
            OTHERS                  = 5.

        CASE sy-subrc.
          WHEN 1. MESSAGE a001(f2) WITH 'INSERT HEADER FAILED'.
          WHEN 2. MESSAGE a001(f2) WITH 'OBJECT INVALID'.
          WHEN 3. MESSAGE a001(f2) WITH 'OPEN MISSING'.
          WHEN 5. MESSAGE a001(f2) WITH 'CLOSE ERROR'.
        ENDCASE.

      ENDIF.

    ENDIF.


  ENDMETHOD.


  METHOD lfa_sperre_exxen.
* Lieferant wird nicht automatisch mit GP gesperrt
* Es gibt keinen FuBa für Ändern, deswegen leider hart auf der Tabelle

*DATA lv_lifnr type lifnr.
    DATA: ls_lfa1_new TYPE lfa1,
          ls_lfa1_old TYPE lfa1,
          lv_objid    TYPE cdhdr-objectid.


    SELECT SINGLE * FROM lfa1
      INTO @ls_lfa1_old
      WHERE lifnr = @iv_businesspartner
      AND  loevm NE 'X'.

* Gefunden?

    IF sy-subrc EQ 0.

      UPDATE lfa1   SET  sperr = 'X',
                         sperm = 'X'
      WHERE   lifnr = @iv_businesspartner.
      IF sy-subrc = 0.
        "Änderungsbelege schreiben
        ls_lfa1_new = ls_lfa1_old.
        ls_lfa1_new-sperr = 'X'.
        ls_lfa1_new-sperm = 'X'.

        lv_objid = iv_businesspartner.
        CALL FUNCTION 'CHANGEDOCUMENT_OPEN'
          EXPORTING
            objectclass      = 'KRED           '
            objectid         = lv_objid
*           planned_change_number   = planned_change_number
*           planned_or_real_changes = planned_or_real_changes
          EXCEPTIONS
            sequence_invalid = 1
            OTHERS           = 2.

        CASE sy-subrc.
          WHEN 1. MESSAGE a001(f2) WITH 'SEQUENCE INVALID'.
          WHEN 2. MESSAGE a001(f2) WITH 'OPEN ERROR'.
        ENDCASE.

        CALL FUNCTION 'CHANGEDOCUMENT_SINGLE_CASE'
          EXPORTING
            tablename              = 'LFA1                          '
            workarea_old           = ls_lfa1_old
            workarea_new           = ls_lfa1_new
            change_indicator       = 'U'
            docu_delete            = 'X'
          EXCEPTIONS
            nametab_error          = 1
            open_missing           = 2
            position_insert_failed = 3
            OTHERS                 = 4.
        CASE sy-subrc.
          WHEN 1. MESSAGE a001(f2) WITH 'NAMETAB-ERROR'.
          WHEN 2. MESSAGE a001(f2) WITH 'OPEN MISSING'.
          WHEN 3. MESSAGE a001(f2) WITH 'INSERT ERROR'.
          WHEN 4. MESSAGE a001(f2) WITH 'SINGLE ERROR'.
        ENDCASE.

        CALL FUNCTION 'CHANGEDOCUMENT_CLOSE'
          EXPORTING
            objectclass             = 'KRED           '
            objectid                = lv_objid
            date_of_change          = sy-datum
            time_of_change          = sy-uzeit
            tcode                   = 'BP'
            username                = sy-uname
            object_change_indicator = 'U'
*NO_CHANGE_POINTERS           = NO_CHANGE_POINTERS
          EXCEPTIONS
            header_insert_failed    = 1
            object_invalid          = 2
            open_missing            = 3
            no_position_inserted    = 4
            OTHERS                  = 5.

        CASE sy-subrc.
          WHEN 1. MESSAGE a001(f2) WITH 'INSERT HEADER FAILED'.
          WHEN 2. MESSAGE a001(f2) WITH 'OBJECT INVALID'.
          WHEN 3. MESSAGE a001(f2) WITH 'OPEN MISSING'.
          WHEN 5. MESSAGE a001(f2) WITH 'CLOSE ERROR'.
        ENDCASE.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  method NONRELEASEKENNZ_ENTEXXEN.


Data ls_data type BAPIBUS1006_CENTRAL.
data ls_datax type BAPIBUS1006_CENTRAL_X.



CALL FUNCTION 'BUPA_CENTRAL_GET_DETAIL'
 EXPORTING
   IV_PARTNER                    = IV_BUSINESSPARTNER
*   IV_PARTNER_GUID               =
*   IV_VALID_DATE                 = SY-DATUM
*   IV_REQ_MASK                   = 'X'
 IMPORTING
   ES_DATA                       = ls_data
   .
clear ls_data-CENTRALBLOCK .
clear ls_data-NOTRELEASED.
ls_datax-CENTRALBLOCK =  /THKR/CL_WF_CONSTANTS=>gc_x..
ls_datax-NOTRELEASED =  /THKR/CL_WF_CONSTANTS=>gc_x..

CALL FUNCTION 'BUPA_CENTRAL_CHANGE'
 EXPORTING
   IV_PARTNER                       = iv_businesspartner
   IS_DATA                          = ls_Data
   IS_DATA_X                        = ls_Datax
 TABLES
   ET_RETURN                        = et_return
          .


  endmethod.


  method NONRELEASEKENNZ_EXXEN.



Data ls_data type BAPIBUS1006_CENTRAL.
data ls_datax type BAPIBUS1006_CENTRAL_X.



CALL FUNCTION 'BUPA_CENTRAL_GET_DETAIL'
 EXPORTING
   IV_PARTNER                    = IV_BUSINESSPARTNER
*   IV_PARTNER_GUID               =
*   IV_VALID_DATE                 = SY-DATUM
*   IV_REQ_MASK                   = 'X'
 IMPORTING
   ES_DATA                       = ls_data
   .


ls_data-NOTRELEASED = /THKR/CL_WF_CONSTANTS=>gc_x.
ls_datax-NOTRELEASED = /THKR/CL_WF_CONSTANTS=>gc_x.
ls_data-CENTRALBLOCK = /THKR/CL_WF_CONSTANTS=>gc_x.
ls_datax-CENTRALBLOCK = /THKR/CL_WF_CONSTANTS=>gc_x.


CALL FUNCTION 'BUPA_CENTRAL_CHANGE'
 exPORTING
   IV_PARTNER                       = iv_businesspartner
   IS_DATA                          = ls_Data
   IS_DATA_X                        = ls_Datax
 TABLES
   ET_RETURN                        = et_return
          .


  endmethod.


  method READ_CHANGEDOCUMENTS.
* Lesen der zum BUPA zugehörigen Instanzen






*Ermitteln Datum/Uhrzeit der WF-Erstellung




* Lesen der Änderungszeiger





  endmethod.


  METHOD set_deleteflag.



    DATA ls_data TYPE bapibus1006_central.
    DATA ls_datax TYPE bapibus1006_central_x.


    CALL FUNCTION 'BUPA_CENTRAL_GET_DETAIL'
      EXPORTING
        iv_partner = iv_businesspartner
*       IV_PARTNER_GUID               =
*       IV_VALID_DATE                 = SY-DATUM
*       IV_REQ_MASK                   = 'X'
      IMPORTING
        es_data    = ls_data.

    ls_data-centralarchivingflag =  /thkr/cl_wf_constants=>gc_x.
    ls_datax-centralarchivingflag = /thkr/cl_wf_constants=>gc_x.


    CALL FUNCTION 'BUPA_CENTRAL_CHANGE'
      EXPORTING
        iv_partner = iv_businesspartner
        is_data    = ls_data
        is_data_x  = ls_datax
      TABLES
        et_return  = et_return.


  ENDMETHOD.
ENDCLASS.
