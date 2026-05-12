"Name: \FU:PRINT_DUNNING_NOTICE_PDF\SE:END\EI
ENHANCEMENT 0 /THKR/SST_STORE_DUNNING.
*** 1. We save the PDF forms to the target because it will be delivered with FTP.
*** 2. We avoid the M2 print ( per form name ) because the process is gonna be fullfilled by AVVISO
 IF ld_form-name <> '/THKR/NO_PRINT'
AND ls_fp_outputparams-dest      = 'MHN'
AND ls_fp_outputparams-nodialog  = abap_true
AND ls_fp_outputparams-preview   = abap_false.

   DATA file_name TYPE char255.
   DATA msg       TYPE char255.

   DATA(filename) = |{ i_mhnk-laufd }-{ i_mhnk-laufi }-{ i_mhnk-cpdky }|.

   CALL FUNCTION 'FILE_GET_NAME'
     EXPORTING
       logical_filename = '/THKR/AIF_O_0041_001_OUT'
       parameter_1      = |{ filename }.pdf|
     IMPORTING
       file_name        = file_name
     EXCEPTIONS
       file_not_found   = 1
       OTHERS           = 2.
   IF sy-subrc = 0.
     TRY.
         "** Transform to PDF/A
         DATA(pdfa_convert) = NEW cl_fp_conv_pdfa( ).
         DATA(pdfa) = pdfa_convert->run_convert_pdfa( iv_pdf = ls_formoutput-pdf iv_pdfnorm = if_fp_pdf_norm=>pdf_a2b  ).

         OPEN DATASET file_name FOR OUTPUT IN BINARY MODE MESSAGE msg.
         IF sy-subrc = 0.
           TRANSFER pdfa TO file_name.
           CLOSE DATASET file_name.
         ELSE.
           MESSAGE msg TYPE 'E'.
           PERFORM log_symsg.
         ENDIF.

         "** Archive Dunning as well:
         DATA: bin_data   TYPE STANDARD TABLE OF tbl1024.
         CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
           EXPORTING
             buffer     = pdfa
           TABLES
             binary_tab = bin_data.

         CALL FUNCTION 'ARCHIV_CREATE_TABLE'
           EXPORTING
             ar_object                = 'ZMAHNDRUCK'
             object_id                = CONV saeobjid( filename )
             sap_object               = 'FIODUNNING'
             flength                  = CONV num12( lines( bin_data ) * 1024 )
             doc_type                 = 'PDF'
             filename                 = CONV char255( |{ filename }.pdf| )
             descr                    = CONV char_60( filename )
           TABLES
             binarchivobject          = bin_data
           EXCEPTIONS
             error_archiv             = 1
             error_communicationtable = 2
             error_connectiontable    = 3
             error_kernel             = 4
             error_parameter          = 5
             error_user_exit          = 6
             error_mandant            = 7
             blocked_by_policy        = 8
             OTHERS                   = 9.
         IF sy-subrc <> 0.
           MESSAGE 'Archivierung fehlgeschlagen!' TYPE 'I'.
           PERFORM log_symsg.
         ENDIF.

       CATCH cx_fp_conv .
         MESSAGE 'PDF-Erzeugung fehlgeschlagen!' TYPE 'E'.
         PERFORM log_symsg.
     ENDTRY.
   ENDIF.
 ENDIF.
ENDENHANCEMENT.
