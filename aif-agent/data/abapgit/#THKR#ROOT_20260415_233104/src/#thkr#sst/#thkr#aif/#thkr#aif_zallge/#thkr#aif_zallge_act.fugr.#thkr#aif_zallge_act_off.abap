*"----------------------------------------------------------------------
* Gereon Koks  TSI  19.12.2024
*"----------------------------------------------------------------------
* Prüfung ob DB-Updates durchgeführt werden sollen.
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_zallge_act_off.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      OFF
*"----------------------------------------------------------------------
  DATA ls_/aif/t_mvmapval TYPE /aif/t_mvmapval.

  SELECT * FROM /aif/t_mvmapval INTO ls_/aif/t_mvmapval
    WHERE ns         = 'ZALLGE'
      AND vmapname   = 'MAP_ACTION_OFF'
      AND ext_value  = sy-uname.

    APPEND VALUE #( id         = '/THKR/SST'
                     number     = 001
                     type       = 'I'
                     message_v1 = 'Durchführung von DB-Updates für User'
                     message_v2 = sy-uname
                     message_v3  = 'abgeschaltet.' ) TO return_tab.

    RAISE off.
  ENDSELECT.
*"----------------------------------------------------------------------
ENDFUNCTION.
