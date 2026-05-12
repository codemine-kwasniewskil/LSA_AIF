*"----------------------------------------------------------------------
* Gereon Koks  TSI  4.9.2024
*"----------------------------------------------------------------------
* CUSTOMER + VENDOR anhängen.
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_map_customer_vendor .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(RAW_STRUCT)
*"     REFERENCE(RAW_LINE)
*"     REFERENCE(SMAP) TYPE  /AIF/T_SMAP
*"     REFERENCE(INTREC) TYPE  /AIF/T_INTREC
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(OUT_STRUCT)
*"     REFERENCE(DEST_LINE)
*"     REFERENCE(DEST_TABLE)
*"     REFERENCE(APPEND_FLAG) TYPE  C
*"----------------------------------------------------------------------
  DATA: ls_customer_company TYPE /thkr/s_dto_bp_cust_company.
  DATA: ls_vendor_company TYPE /thkr/s_dto_bp_vend_company.

  FIELD-SYMBOLS: <ls_dest_line>  TYPE /thkr/s_dto_bp_create.
  ASSIGN dest_line  TO <ls_dest_line>.
*"----------------------------------------------------------------------
* Customer + Mapping einfügen
*"----------------------------------------------------------------------
  ls_customer_company-bukrs = 'R090'.
  ls_customer_company-akont = '2300000000'.
  ls_customer_company-zuawa = '001'.
*"----------------------------------------------------------------------
  APPEND ls_customer_company TO <ls_dest_line>-customer-t_customer_company.
*"----------------------------------------------------------------------
* Vendor + Mapping einfügen
*"----------------------------------------------------------------------
  ls_vendor_company-bukrs = 'R090'.
  ls_vendor_company-akont = '4500000000'.
  ls_vendor_company-zuawa = '001'.
* Check Flag for Double Invoices or Credit Memos
  ls_vendor_company-reprf = 'X'.
*"----------------------------------------------------------------------
  APPEND ls_vendor_company TO <ls_dest_line>-vendor-t_vendor_company.
*"----------------------------------------------------------------------
ENDFUNCTION.
*"----------------------------------------------------------------------
