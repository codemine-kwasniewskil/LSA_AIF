FUNCTION-POOL /thkr/bfw_conversions.        "MESSAGE-ID ..

* INCLUDE /THKR/LBFW_CONVERSIONSD...         " Local class definition

TYPES: BEGIN OF ty_object_type_text,
         object_type TYPE /thkr/object_type,
         description TYPE /thkr/object_type_description,
       END OF ty_object_type_text.

TYPES: tt_dd07v TYPE TABLE OF dd07v.

DATA: event_category2_texts     TYPE STANDARD TABLE OF /thkr/c_event,
      object_type_texts         TYPE STANDARD TABLE OF ty_object_type_text,
      gi_field_separation_texts TYPE tt_dd07v,
      de_run1_status_texts      TYPE tt_dd07v,
      de_run2_status_texts      TYPE tt_dd07v,
      process_type_texts        TYPE tt_dd07v.
