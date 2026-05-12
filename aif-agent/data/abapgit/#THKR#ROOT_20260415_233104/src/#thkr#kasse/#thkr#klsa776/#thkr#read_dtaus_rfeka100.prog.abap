*&---------------------------------------------------------------------*
*& Report /THKR/READ_DTAUS_RFEKA100
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/read_dtaus_rfeka100.
DATA: files TYPE TABLE OF epsfili.

INCLUDE rfebka03.

PARAMETERS: p_path  TYPE feb_path DEFAULT 'Z_DTA_REC' OBLIGATORY.
PARAMETERS: p_anwnd TYPE anwnd_ebko DEFAULT '0001' OBLIGATORY.
PARAMETERS: p_flnm  TYPE char60.

** Get full path
SELECT SINGLE FROM feb_filepath
  FIELDS directory
        ,filename
  WHERE path = @p_path
  INTO @DATA(path).

REPLACE ALL OCCURRENCES OF '<SYSID>'  IN path WITH sy-sysid IGNORING CASE.
REPLACE ALL OCCURRENCES OF '<CLIENT>' IN path WITH sy-mandt IGNORING CASE.
REPLACE ALL OCCURRENCES OF '<HOST>'   IN path WITH sy-host IGNORING CASE. "2890906

IF p_flnm IS NOT INITIAL.
  files = VALUE #( ( name = p_flnm ) ).
ELSEIF path-filename IS NOT INITIAL.
  files = VALUE #( ( name = path-filename ) ).
ELSE.
  CALL FUNCTION 'EPS_GET_DIRECTORY_LISTING'
    EXPORTING
      dir_name = CONV epsdirnam( path-directory )
    TABLES
      dir_list = files
    EXCEPTIONS
      OTHERS   = 1.
ENDIF.

LOOP AT files INTO DATA(file).
** Fill parameter from include
  auszugfile = |{ path-directory }/{ file-name }|.
  anwnd = p_anwnd.

  PERFORM dtaus_disk(rfeka100).
  MESSAGE s002(/THKR/ELKO) WITH s_kukey-low.

ENDLOOP.
