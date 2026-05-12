FUNCTION Z_NSI_CHECK_FILE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_PROGNAME) TYPE  SYREPID
*"     VALUE(I_VARIANT) TYPE  VARIANT DEFAULT SPACE
*"     VALUE(I_NAME1) TYPE  EPSFILNAM
*"     VALUE(I_NAME2) TYPE  EPSFILNAM DEFAULT SPACE
*"  EXPORTING
*"     REFERENCE(E_DATENSATZ) TYPE  ZNSI_CHECK_FILE
*"  EXCEPTIONS
*"      EINTRAG_GEFUNDEN
*"      FEHLER_NEUER_EINTRAG
*"----------------------------------------------------------------------

data: l_wa_datensatz like znsi_check_file.

select single * from znsi_check_file into l_wa_datensatz
       where pname = i_progname and name1 = i_name1.

if sy-subrc = 0.
   e_datensatz = l_wa_datensatz.
   raise eintrag_gefunden.
  else.
   e_datensatz-pname = i_progname.
   e_datensatz-name1 = i_name1.
   e_datensatz-datum = sy-datum.
   e_datensatz-uzeit = sy-uzeit.
   e_datensatz-uname = sy-uname.
   e_datensatz-name2 = i_name2.
   e_datensatz-vanam = i_variant.

   insert into znsi_check_file values e_datensatz.

   if sy-subrc NE 0.
      raise fehler_neuer_eintrag.
   endif.
endif.



ENDFUNCTION.
