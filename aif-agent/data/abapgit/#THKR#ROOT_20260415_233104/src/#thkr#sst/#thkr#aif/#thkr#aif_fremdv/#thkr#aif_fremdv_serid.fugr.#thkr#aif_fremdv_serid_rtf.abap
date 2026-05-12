TYPES:
  ty_agr_users_tab       TYPE TABLE OF /aif/t_alrt_user,
  ty_ad_smtpadr_tab      TYPE TABLE OF ad_smtpadr,
  ty_mail_recipients_tab TYPE TABLE OF ad_smtpadr.

FUNCTION /thkr/aif_fremdv_serid_rtf.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"----------------------------------------------------------------------
  DATA:
    lv_rtf_string      TYPE string VALUE '{\rtf1\ansi{\fonttbl\f0\fswiss Helvetica;}\f0\pard This is {\b bold} text.\par}',
    lv_recipient_list  TYPE string VALUE 'RCV_LIST_FREMDV_0016',
    lt_mail_recipients TYPE ty_mail_recipients_tab.

  PERFORM get_mails_for_recipient_list USING lv_recipient_list CHANGING lt_mail_recipients.

  CLEAR lt_mail_recipients.
  APPEND 'maximilian.kleissl@t-systems.com' TO lt_mail_recipients.

  PERFORM send_mail2 USING lt_mail_recipients lv_rtf_string.

ENDFUNCTION.

FORM send_mail2 USING it_mail_recipients TYPE ty_mail_recipients_tab iv_rtf_string TYPE string.
*&---------------------------------------------------------------------*
*& Data Declaration
*&---------------------------------------------------------------------*
  DATA : lo_mime_helper TYPE REF TO cl_gbt_multirelated_service,
         lo_bcs         TYPE REF TO cl_bcs,
         lo_doc_bcs     TYPE REF TO cl_document_bcs,
         lo_recipient   TYPE REF TO if_recipient_bcs,
         lt_soli        TYPE TABLE OF soli,
         ls_soli        TYPE soli,
         lv_status      TYPE bcs_rqst,
         lv_attachment  TYPE solix_tab.

  CREATE OBJECT lo_mime_helper.

  DATA(string) = '<!DOCTYPE html PUBLIC “-//IETF//DTD HTML 5.0//EN">'
              && '<HTML><BODY>Hi Dear,<P>Content Section!</P></BODY></HTML>'.

  lt_soli = cl_document_bcs=>string_to_soli( string ).

  " Set the HTML body of the mail
  CALL METHOD lo_mime_helper->set_main_html
    EXPORTING
      content     = lt_soli
      description = 'Test Email'.




* Set the subject of the mail.
  lo_doc_bcs = cl_document_bcs=>create_from_multirelated(
                  i_subject          = 'Subject of the test email'
                  i_importance       = '5'                " 1~High Priority  5~Average priority 9~Low priority
                  i_multirel_service = lo_mime_helper ).

  lo_bcs = cl_bcs=>create_persistent( ).

  lo_bcs->set_document( i_document = lo_doc_bcs ).

* Set the email address
  LOOP AT it_mail_recipients INTO DATA(lv_recipient_mail_address).
    lo_recipient = cl_cam_address_bcs=>create_internet_address(
                    i_address_string =  lv_recipient_mail_address ).

    lo_bcs->add_recipient( i_recipient = lo_recipient ).
  ENDLOOP.

  PERFORM rtf_string_to_binary USING iv_rtf_string CHANGING lv_attachment.
  lo_doc_bcs->add_attachment( i_attachment_type = 'rtf' i_attachment_subject = 'filename' i_att_content_hex = lv_attachment ).


* Change the status.
  lv_status = 'N'.
  TRY.
      CALL METHOD lo_bcs->set_status_attributes
        EXPORTING
          i_requested_status = lv_status.
    CATCH cx_send_req_bcs INTO DATA(lx_send_req_bcs).
      WRITE:/ 'Senden fehlgeschlagen'.
  ENDTRY.

*&---------------------------------------------------------------------*
*& Send the email
*&---------------------------------------------------------------------*
  TRY.
      lo_bcs->send( ).
      COMMIT WORK.
    CATCH cx_bcs INTO DATA(lx_bcs).
      ROLLBACK WORK.
  ENDTRY.
ENDFORM.

FORM send_mail USING it_mail_recipients TYPE ty_mail_recipients_tab iv_rtf_string TYPE string.
  DATA:     lv_attachment      TYPE solix_tab.
  TRY.
      DATA(lo_document) = cl_document_bcs=>create_document( i_type = 'raw' i_subject = 'Example Subject' ).
      PERFORM rtf_string_to_binary USING iv_rtf_string CHANGING lv_attachment.
      lo_document->add_attachment( i_attachment_type = 'rtf' i_attachment_subject = 'filename' i_att_content_hex = lv_attachment ).
      DATA(lo_send_request) = cl_bcs=>create_persistent( ).
      lo_send_request->set_message_subject( ip_subject = 'Example subject' ).
      lo_send_request->set_document( lo_document ).

      DATA(lo_sender) = cl_cam_address_bcs=>create_internet_address( i_address_string = 'maximilian.kleissl@t-systems.com' ).
      lo_send_request->set_sender( lo_sender ).

      LOOP AT it_mail_recipients INTO DATA(lv_recipient_mail_address).
        DATA(lo_recipient) = cl_cam_address_bcs=>create_internet_address( lv_recipient_mail_address ).
        lo_send_request->add_recipient( i_recipient = lo_recipient i_express = abap_true ).
      ENDLOOP.

      lo_send_request->set_send_immediately( abap_false ).
      WRITE: / lo_send_request->send( i_with_error_screen = abap_true ).
    CATCH cx_root INTO DATA(lo_text).
      WRITE: / 'Fehler: ', lo_text->get_text( ).
  ENDTRY.
ENDFORM.

FORM get_mails_for_recipient_list USING iv_recipient_list TYPE string CHANGING ct_mail_recipients TYPE ty_mail_recipients_tab.
  DATA:
    lt_alrt_user   TYPE TABLE OF /aif/t_alrt_user,
    lt_alrt_role   TYPE TABLE OF /aif/t_alrt_role,
    lt_agr_users   TYPE ty_agr_users_tab,
    lt_alrt_ext    TYPE TABLE OF /aif/t_alrt_ext,
    lt_ext_contact TYPE TABLE OF /aif/ext_contact.

  SELECT uname FROM /aif/t_alrt_user INTO CORRESPONDING FIELDS OF TABLE @lt_alrt_user WHERE recipient = @iv_recipient_list.
  PERFORM add_mails_from_usernames USING lt_alrt_user CHANGING ct_mail_recipients.
  CLEAR lt_alrt_user.

  SELECT agr_name FROM /aif/t_alrt_role INTO CORRESPONDING FIELDS OF TABLE @lt_alrt_role WHERE recipient = @iv_recipient_list.
  IF lt_alrt_role IS NOT INITIAL.
    SELECT uname
      FROM agr_users
      INTO CORRESPONDING FIELDS OF TABLE @lt_alrt_user
      FOR ALL ENTRIES IN @lt_alrt_role
      WHERE agr_name = @lt_alrt_role-agr_name AND from_dat <= @sy-datum AND to_dat >= @sy-datum.
    PERFORM add_mails_from_usernames USING lt_alrt_user CHANGING ct_mail_recipients.
  ENDIF.

  SELECT contact_guid FROM /aif/t_alrt_ext INTO CORRESPONDING FIELDS OF TABLE @lt_alrt_ext WHERE recipient = @iv_recipient_list.
  SELECT smtpadr FROM /aif/ext_contact INTO CORRESPONDING FIELDS OF TABLE @lt_ext_contact FOR ALL ENTRIES IN @lt_alrt_ext WHERE contact_guid = @lt_alrt_ext-contact_guid.
  LOOP AT lt_ext_contact INTO DATA(ls_ext_contact).
    TRANSLATE ls_ext_contact-smtpadr TO LOWER CASE.
    APPEND ls_ext_contact-smtpadr TO ct_mail_recipients[].
  ENDLOOP.


  SORT ct_mail_recipients.
  DELETE ADJACENT DUPLICATES FROM ct_mail_recipients.

ENDFORM.


FORM add_mails_from_usernames USING it_alrt_user TYPE ty_agr_users_tab
      CHANGING t_mail_recipients TYPE ty_ad_smtpadr_tab.

  DATA: lt_return TYPE bapirettab,
        lt_smtp   TYPE TABLE OF bapiadsmtp.

  LOOP AT it_alrt_user INTO DATA(ls_alrt_user).
    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        username = ls_alrt_user-uname
      TABLES
        return   = lt_return
        addsmtp  = lt_smtp.

    LOOP AT lt_smtp INTO DATA(ls_smtp).
      TRANSLATE ls_smtp-e_mail TO LOWER CASE.
      APPEND ls_smtp-e_mail TO t_mail_recipients.
    ENDLOOP.
  ENDLOOP.
ENDFORM.

FORM rtf_string_to_binary USING iv_rtf_string TYPE string CHANGING cv_attachment TYPE solix_tab.

  DATA: lv_rtf_xstring TYPE xstring.

  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
    EXPORTING
      text   = iv_rtf_string
    IMPORTING
      buffer = lv_rtf_xstring
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer     = lv_rtf_xstring
    TABLES
      binary_tab = cv_attachment
    EXCEPTIONS
      OTHERS     = 1.

ENDFORM.
