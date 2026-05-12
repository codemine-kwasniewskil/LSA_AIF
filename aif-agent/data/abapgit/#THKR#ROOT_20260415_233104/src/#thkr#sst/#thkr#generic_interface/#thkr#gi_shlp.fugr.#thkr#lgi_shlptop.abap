FUNCTION-POOL /thkr/gi_shlp.                 "MESSAGE-ID ..

* INCLUDE LZLSA_GI_SHLPD...                  " Local class definition
TYPES ty_field TYPE c LENGTH 30.

DATA: g_filter_id         TYPE /thkr/gi_filter_id,
      g_gi                TYPE REF TO /thkr/cl_gi_appl,
      g_gi_id             TYPE /thkr/gi_id,
      g_gi_mc             TYPE /thkr/gi_mc,
      g_gi_mp_tab         TYPE /thkr/gi_mp_tab,
      g_gi_mp_tab_type    TYPE /thkr/gi_mp_tab_type,
      g_gi_mc_data_source TYPE /thkr/gi_mc_data_source,
      g_tabname           TYPE tabname,
      g_record_id         TYPE /thkr/gi_record_id,
      g_field             TYPE ty_field,
      g_no_prefix         TYPE xfeld,
      g_tables_only       type xfeld.
