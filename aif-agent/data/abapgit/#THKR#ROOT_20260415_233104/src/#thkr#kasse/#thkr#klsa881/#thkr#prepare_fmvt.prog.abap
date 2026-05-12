*&---------------------------------------------------------------------*
*& Report /THKR/PREPARE_FMVT - 2025-10-15 jseifert
*&---------------------------------------------------------------------*
*&   Über diesen Report werden die Voraussetzungen für den Bestandsüber-
*%   trag der Kassentitel (FMVT) hergestellt
*%   Dazu werden für das jeweilige Senderjahr die Vortragspositionstypen
*%   mit den Ziel-Finanzpositionen aus der Tabelle FMCI in die Tabelle
*%   FMVORTR übertragen
*&---------------------------------------------------------------------*
REPORT /thkr/prepare_fmvt.

TABLES: fmci, fmvortr.

DATA: t_data4fmvortr LIKE TABLE OF  fmvortr    WITH HEADER LINE.

PARAMETERS:       p_fikrs LIKE fmci-fikrs DEFAULT '1000' OBLIGATORY.
PARAMETERS:       p_gjahr LIKE fmci-gjahr OBLIGATORY.
SELECT-OPTIONS:   s_fipex FOR fmci-fipex  DEFAULT '4*' OBLIGATORY.

INITIALIZATION.
  IF s_fipex-low = '4*' AND s_fipex-option <> 'CP'.
    s_fipex-option = 'CP'.
    MODIFY s_fipex INDEX 1.
  ENDIF.

START-OF-SELECTION.

  SELECT ci~fikrs, ci~vptyp, ci~gjahr, ci~fipex
  FROM ( fmci  AS ci )
       WHERE ci~fikrs = @p_fikrs
         AND ci~gjahr = @p_gjahr
         AND ci~fipex IN @s_fipex
         AND ci~vptyp BETWEEN 'AA' AND 'ZZ'
  ORDER BY ci~vptyp
  INTO CORRESPONDING FIELDS OF TABLE @t_data4fmvortr.

  LOOP AT t_data4fmvortr.
    WRITE: / TEXT-001, t_data4fmvortr-vptyp, '/', TEXT-002, t_data4fmvortr-fipex.
  ENDLOOP.

  DELETE
  FROM  fmvortr
  WHERE fikrs = @p_fikrs
    AND gjahr = @p_gjahr
    AND fipex IN @s_fipex
    AND vptyp BETWEEN 'AA' AND 'ZZ'.

  INSERT fmvortr
  FROM   TABLE @t_data4fmvortr.

  COMMIT WORK AND WAIT.
