"Name: \PR:SAPLFMFR\FO:WF_REJECTION\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/PSM_MB_APPROVE.
IF g_f_wfdata-no_dialogue IS INITIAL.
  DATA: lv_wi_id type sww_wiid.
  DATA: lv_obj_key type sww_contob-objkey.
  g_f_wfdata-reason = 'CC'.
  g_f_wfdata-trigger = 'X'.

return.
ENDIF.
ENDENHANCEMENT.
