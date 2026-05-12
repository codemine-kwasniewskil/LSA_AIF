*----------------------------------------------------------------------*
***INCLUDE /THKR/LBFW_CONVERSIONSF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form init_event_category2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_event_category2 .

  IF event_category2_texts IS INITIAL.

    SELECT *
      FROM /THKR/C_EVENT
      INTO TABLE event_category2_texts.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_gi_field_separation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_gi_field_separation .

  IF gi_field_separation_texts IS INITIAL.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname   = '/THKR/GI_FIELD_SEPARATION'
        text      = 'X'
      TABLES
        dd07v_tab = gi_field_separation_texts.

    IF sy-subrc <> 0.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form init_PROCESS_TYPE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_process_type .

  IF process_type_texts IS INITIAL.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname   = '/THKR/PROCESS_TYPE'
        text      = 'X'
      TABLES
        dd07v_tab = process_type_texts.

    IF sy-subrc <> 0.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form init_object_type
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_object_type .

  IF object_type_texts IS INITIAL.

    SELECT object_type object_type_description AS description
      INTO CORRESPONDING FIELDS OF TABLE object_type_texts
      FROM /thkr/c_obj.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_DE_RUN1_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_de_run1_status .

  IF de_run1_status_texts IS INITIAL.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname   = '/THKR/DE_RUN1_STATUS'
        text      = 'X'
      TABLES
        dd07v_tab = de_run1_status_texts.

    IF sy-subrc <> 0.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form init_DE_RUN2_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_de_run2_status .

  IF de_run2_status_texts IS INITIAL.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname   = '/THKR/DE_RUN2_STATUS'
        text      = 'X'
      TABLES
        dd07v_tab = de_run2_status_texts.

    IF sy-subrc <> 0.
    ENDIF.

  ENDIF.

ENDFORM.
