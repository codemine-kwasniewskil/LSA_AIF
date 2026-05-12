"Name: \PR:SAPLFMFR\FO:WF_APPROVE\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/PSM_MB_APPROVE.
"Wenn Genehmigen, dann den Grund direkt hinterlegen, Popup
  "möchte der Kunde nicht haben
IF g_f_wfdata-no_dialogue IS INITIAL.
  g_f_wfdata-reason = 'AC'.
  g_f_wfdata-trigger = 'X'.
  return.
  ENDIF.

ENDENHANCEMENT.
