
FUNCTION-POOL /THKR/WF_EVENTFUBAS.             "MESSAGE-ID ..
INCLUDE <cntn01>.
INCLUDE <swfcntn01>.

TYPE-POOLS: swfco.
TYPE-POOLS: swfev.

TYPES: BEGIN OF ty_log_status.
TYPES:   name    TYPE string.
TYPES:   time    TYPE syuzeit.
TYPES:   zonlo   TYPE systzonlo.
TYPES:   duration TYPE int4.
TYPES:   langu   TYPE sy-langu.
TYPES:   excp_name    TYPE string.
TYPES:   excp_t100msg TYPE swf_t100ms.
TYPES: END OF ty_log_status.

*
*CLASS lcl_container DEFINITION.
*  PUBLIC SECTION.
*    CLASS-METHODS get_instance IMPORTING io_container  TYPE REF TO if_swf_cnt_container
*                               RETURNING VALUE(result) TYPE REF TO lcl_container.
*    METHODS get_event_object RETURNING VALUE(result) TYPE sibflporb.
*    METHODS get_event_language RETURNING VALUE(result) TYPE sylangu.
*    METHODS get_event_creator RETURNING VALUE(result) TYPE string.
*    METHODS get_event_id RETURNING VALUE(result) TYPE swe_evtid_guid32.
*    METHODS get_event_log RETURNING VALUE(result) TYPE abap_bool.
*  PRIVATE SECTION.
*    DATA mo_container TYPE REF TO if_swf_cnt_container.
*ENDCLASS.




* INCLUDE /THKR/LEVENTFUBASD...              " Local class definition
