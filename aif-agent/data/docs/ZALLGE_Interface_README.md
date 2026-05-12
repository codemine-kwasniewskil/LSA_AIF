# ZALLGE Interface Documentation

## Overview
**Interface ID:** ZALLGE  
**Namespace:** /THKR/  
**Purpose:** General AIF functions for financial processing and common operations  
**Domain:** General/Common AIF Functions

## AIF Raw Structures

### /THKR/S_AIF_RAW_ZAHLUNGSDATEN
**Purpose:** Raw payment data structure for general processing
```abap
TYPES: BEGIN OF /thkr/s_aif_raw_zahlungsdaten,
  bukrs TYPE bukrs,              " Company Code
  belnr TYPE belnr_d,            " Document Number
  gjahr TYPE gjahr,              " Fiscal Year
  wrbtr TYPE wrbtr,              " Amount
  waers TYPE waers,              " Currency
  END OF /thkr/s_aif_raw_zahlungsdaten.
```

## AIF SAP Structures

### /THKR/S_AIF_SAP
**Purpose:** Main SAP data structure for AIF processing
```abap
TYPES: BEGIN OF /thkr/s_aif_sap,
  header TYPE /thkr/s_aif_bic_header,   " BIC Header
  line TYPE /thkr/t_aif_bic_zeile,      " BIC Lines
  footer TYPE /thkr/s_aif_bic_footer,   " BIC Footer
  common TYPE /thkr/s_aif_common,       " Common Data
  END OF /thkr/s_aif_sap.
```

### /THKR/S_AIF_SAP_AO
**Purpose:** SAP Anordnung (Order) structure
```abap
TYPES: BEGIN OF /thkr/s_aif_sap_ao,
  bukrs TYPE bukrs,                    " Company Code
  gjahr TYPE gjahr,                    " Fiscal Year
  belnr TYPE belnr_d,                  " Document Number
  xblnr TYPE xblnr,                    " Reference Number
  wrbtr TYPE wrbtr,                    " Amount
  END OF /thkr/s_aif_sap_ao.
```

### /THKR/S_AIF_SAP_GP
**Purpose:** SAP Geschäftspartner (Business Partner) structure
```abap
TYPES: BEGIN OF /thkr/s_aif_sap_gp,
  partner TYPE bu_partner,             " Business Partner Number
  name TYPE bu_name1,                  " Name
  stras TYPE stras,                    " Street
  ort01 TYPE ort01,                    " City
  pstlz TYPE pstlz,                    " Postal Code
  END OF /thkr/s_aif_sap_gp.
```

### /THKR/S_AIF_SAP_MB
**Purpose:** SAP Mahnbescheid (Dunning Notice) structure
```abap
TYPES: BEGIN OF /thkr/s_aif_sap_mb,
  bukrs TYPE bukrs,                    " Company Code
  belnr TYPE belnr_d,                  " Document Number
  gjahr TYPE gjahr,                    " Fiscal Year
  mahnstufe TYPE mahnstufe,            " Dunning Level
  END OF /thkr/s_aif_sap_mb.
```

### /THKR/S_AIF_SAP_VR
**Purpose:** SAP Verrechnung (Clearing) structure
```abap
TYPES: BEGIN OF /thkr/s_aif_sap_vr,
  bukrs TYPE bukrs,                    " Company Code
  belnr TYPE belnr_d,                  " Document Number
  gjahr TYPE gjahr,                    " Fiscal Year
  augbl TYPE augbl,                    " Clearing Document
  END OF /thkr/s_aif_sap_vr.
```

## AIF Actions

### /THKR/AIF_ZALLGE_ACT_AO
**Purpose:** Process Anordnungen (orders)
**Functionality:**
- Creates and processes order documents
- Handles AO (Anordnung) business logic

### /THKR/AIF_ZALLGE_ACT_AO_PSOXML
**Purpose:** Process Anordnungen from PSO XML
**Functionality:**
- Processes XML-based order data from PSO system
- Transforms and validates XML structures

### /THKR/AIF_ZALLGE_ACT_AO_WF
**Purpose:** Process Anordnungen with workflow
**Functionality:**
- Handles workflow-integrated order processing
- Manages approval and processing workflows

### /THKR/AIF_ZALLGE_ACT_AO_XML
**Purpose:** Process Anordnungen from XML
**Functionality:**
- Processes XML order data
- Validates XML structure and content

### /THKR/AIF_ZALLGE_ACT_APN
**Purpose:** Process APN (Application Numbers)
**Functionality:**
- Handles application number processing
- Manages APN-related business logic

### /THKR/AIF_ZALLGE_ACT_DEL_PSTAT
**Purpose:** Delete processing status
**Functionality:**
- Removes processing status records
- Cleans up status information

### /THKR/AIF_ZALLGE_ACT_GP
**Purpose:** Process Geschäftspartner (business partners)
**Functionality:**
- Creates and updates business partner data
- Handles GP master data processing

### /THKR/AIF_ZALLGE_ACT_GP_CHG
**Purpose:** Change Geschäftspartner data
**Functionality:**
- Updates existing business partner information
- Handles change requests for GP data

### /THKR/AIF_ZALLGE_ACT_GP_INS
**Purpose:** Insert Geschäftspartner data
**Functionality:**
- Creates new business partner records
- Handles GP data insertion

### /THKR/AIF_ZALLGE_ACT_GP_PSOXML
**Purpose:** Process GP data from PSO XML
**Functionality:**
- Processes XML business partner data from PSO
- Transforms PSO XML to SAP GP format

### /THKR/AIF_ZALLGE_ACT_GP_XML
**Purpose:** Process GP data from XML
**Functionality:**
- Processes XML business partner data
- Validates and transforms XML structures

### /THKR/AIF_ZALLGE_ACT_IN_PSOXML
**Purpose:** Process incoming PSO XML data
**Functionality:**
- Handles incoming XML data from PSO system
- General XML processing for various data types

### /THKR/AIF_ZALLGE_ACT_KASSZ_KID
**Purpose:** Process Kassenzeichen KI data
**Functionality:**
- Handles KI (Customer) data for Kassenzeichen
- Processes customer-specific cash sign data

### /THKR/AIF_ZALLGE_ACT_MB
**Purpose:** Process Mahnbescheide (dunning notices)
**Functionality:**
- Creates and processes dunning notices
- Handles MB business logic and workflows

### /THKR/AIF_ZALLGE_ACT_MB_PSOXML
**Purpose:** Process MB data from PSO XML
**Functionality:**
- Processes XML dunning data from PSO system
- Transforms PSO XML to SAP MB format

### /THKR/AIF_ZALLGE_ACT_MB_UP
**Purpose:** Update Mahnbescheide
**Functionality:**
- Updates existing dunning notice records
- Handles MB update operations

### /THKR/AIF_ZALLGE_ACT_MB_UP_PSO
**Purpose:** Update MB data from PSO
**Functionality:**
- Updates dunning data from PSO system
- Processes PSO-specific MB updates

### /THKR/AIF_ZALLGE_ACT_OFF
**Purpose:** Turn off actions
**Functionality:**
- Disables AIF action processing
- Used for maintenance and control

### /THKR/AIF_ZALLGE_ACT_PP_PSOXML
**Purpose:** Process PP data from PSO XML
**Functionality:**
- Processes XML PP (Payment Plan?) data from PSO
- Handles payment plan processing

### /THKR/AIF_ZALLGE_ACT_PROC_STAT
**Purpose:** Process status updates
**Functionality:**
- Updates processing status information
- Manages status transitions

### /THKR/AIF_ZALLGE_ACT_PROT_KMER
**Purpose:** Create KMER protocol
**Functionality:**
- Generates protocol logs for KMER processing
- Handles KMER-specific logging

### /THKR/AIF_ZALLGE_ACT_PROT_LST
**Purpose:** Create LST protocol
**Functionality:**
- Generates protocol logs for LST processing
- Handles LST-specific logging

### /THKR/AIF_ZALLGE_ACT_REF_ZW_X
**Purpose:** Process reference ZW_X data
**Functionality:**
- Handles reference data processing for ZW_X
- Manages cross-reference operations

### /THKR/AIF_ZALLGE_ACT_SAVE_TEXT
**Purpose:** Save text data
**Functionality:**
- Saves text information to documents
- Handles text storage operations

### /THKR/AIF_ZALLGE_ACT_SKONT
**Purpose:** Process Skonto (discount) data
**Functionality:**
- Handles discount calculations and processing
- Manages Skonto business logic

### /THKR/AIF_ZALLGE_ACT_SL_PSOXML
**Purpose:** Process SL data from PSO XML
**Functionality:**
- Processes XML SL data from PSO system
- Handles SL-specific processing

### /THKR/AIF_ZALLGE_ACT_STORNO
**Purpose:** Process reversals
**Functionality:**
- Handles document reversal operations
- Manages Storno business logic

### /THKR/AIF_ZALLGE_ACT_STU
**Purpose:** Process Stundungen (deferrals)
**Functionality:**
- Handles payment deferral processing
- Manages Stundung business logic

### /THKR/AIF_ZALLGE_ACT_STU_PSOXM
**Purpose:** Process Stundungen from PSO XML
**Functionality:**
- Processes XML deferral data from PSO
- Transforms PSO XML to SAP Stundung format

### /THKR/AIF_ZALLGE_ACT_ST_PSOXML
**Purpose:** Process ST data from PSO XML
**Functionality:**
- Processes XML ST data from PSO system
- Handles ST-specific processing

### /THKR/AIF_ZALLGE_ACT_UPD_BANK
**Purpose:** Update bank data
**Functionality:**
- Updates bank master data
- Handles bank information changes

### /THKR/AIF_ZALLGE_ACT_UPD_XREF1
**Purpose:** Update XREF1 references
**Functionality:**
- Updates cross-reference data
- Manages XREF1 relationship updates

### /THKR/AIF_ZALLGE_ACT_VR
**Purpose:** Process Verrechnungen (clearings)
**Functionality:**
- Handles clearing operations
- Manages VR business logic

### /THKR/AIF_ZALLGE_ACT_VR_PSOXML
**Purpose:** Process VR data from PSO XML
**Functionality:**
- Processes XML clearing data from PSO
- Transforms PSO XML to SAP VR format

### /THKR/AIF_ZALLGE_ACT_XR_PSOXML
**Purpose:** Process XR data from PSO XML
**Functionality:**
- Processes XML XR data from PSO system
- Handles XR-specific processing

### /THKR/AIF_ZALLGE_IBA_FILE_EX
**Purpose:** Process IBA file extraction
**Functionality:**
- Extracts data from IBA files
- Handles file-based data extraction

## AIF Mappings

### /THKR/AIF_AMAP_AO
**Purpose:** Map Anordnung data
**Functionality:**
- Transforms order data structures
- Handles AO mapping operations

### /THKR/AIF_AMAP_functtest
**Purpose:** Function test mapping
**Functionality:**
- Test mapping functions
- Validates mapping logic

### /THKR/AIF_AMAP_MV
**Purpose:** Map MV (Movement?) data
**Functionality:**
- Transforms movement data structures
- Handles MV mapping operations

### /THKR/AIF_AMAP_PSO_XML_ANORD
**Purpose:** Map PSO XML Anordnungen
**Functionality:**
- Maps XML order data from PSO system
- Transforms PSO XML to SAP format

### /THKR/AIF_AMAP_PSO_XML_AO
**Purpose:** Map PSO XML AO data
**Functionality:**
- Maps XML AO data from PSO system
- Handles AO-specific XML transformations

### /THKR/AIF_AMAP_PSO_XML_AO_MB
**Purpose:** Map PSO XML AO MB data
**Functionality:**
- Maps XML AO MB data from PSO system
- Handles combined AO/MB transformations

### /THKR/AIF_AMAP_PSO_XML_AO_REF
**Purpose:** Map PSO XML AO reference data
**Functionality:**
- Maps XML AO reference data from PSO
- Handles reference data transformations

### /THKR/AIF_AMAP_PSO_XML_AO_STU
**Purpose:** Map PSO XML AO Stundung data
**Functionality:**
- Maps XML AO Stundung data from PSO
- Handles deferral data transformations

### /THKR/AIF_AMAP_PSO_XML_GP
**Purpose:** Map PSO XML GP data
**Functionality:**
- Maps XML business partner data from PSO
- Transforms PSO XML to SAP GP format

### /THKR/AIF_AMAP_PSO_XML_GP_BA
**Purpose:** Map PSO XML GP BA data
**Functionality:**
- Maps XML GP BA data from PSO system
- Handles GP BA specific transformations

### /THKR/AIF_AMAP_PSO_XML_MB
**Purpose:** Map PSO XML MB data
**Functionality:**
- Maps XML dunning data from PSO
- Transforms PSO XML to SAP MB format

### /THKR/AIF_AMAP_PSO_XML_MB_UP
**Purpose:** Map PSO XML MB update data
**Functionality:**
- Maps XML MB update data from PSO
- Handles MB update transformations

### /THKR/AIF_AMAP_PSO_XML_VR
**Purpose:** Map PSO XML VR data
**Functionality:**
- Maps XML clearing data from PSO
- Transforms PSO XML to SAP VR format

### /THKR/AIF_AMAP_STORNO
**Purpose:** Map Storno data
**Functionality:**
- Maps reversal operation data
- Handles Storno transformation logic

### /THKR/AIF_BMAP_IBE
**Purpose:** Map IBE data
**Functionality:**
- Maps IBE-specific data structures
- Handles IBE transformation operations

### /THKR/AIF_BMAP_REFERENCE
**Purpose:** Map reference data
**Functionality:**
- Maps reference relationship data
- Handles cross-reference transformations

### /THKR/AIF_MAP_0013_BUCH_ART
**Purpose:** Map booking type 0013
**Functionality:**
- Maps specific booking type 0013
- Handles booking type transformations

### /THKR/AIF_MAP_0013_BUCH_KEY
**Purpose:** Map booking key 0013
**Functionality:**
- Maps specific booking key 0013
- Handles booking key transformations

### /THKR/AIF_MAP_AD_TITLE1
**Purpose:** Map address title 1
**Functionality:**
- Maps address title field 1
- Handles title transformations

### /THKR/AIF_MAP_BETR
**Purpose:** Map amount data
**Functionality:**
- Maps amount fields and calculations
- Handles currency and amount transformations

### /THKR/AIF_MAP_CPUTM_FORMAT
**Purpose:** Map CPU time format
**Functionality:**
- Maps CPU time format fields
- Handles time format transformations

### /THKR/AIF_MAP_CUSTOMER_VENDOR
**Purpose:** Map customer/vendor data
**Functionality:**
- Maps customer and vendor relationships
- Handles BP type transformations

### /THKR/AIF_MAP_DATS_FORMAT
**Purpose:** Map date format
**Functionality:**
- Maps date format fields
- Handles date format transformations

### /THKR/AIF_MAP_FILENAME
**Purpose:** Map filename data
**Functionality:**
- Maps filename generation and parsing
- Handles file naming transformations

### /THKR/AIF_MAP_KONT
**Purpose:** Map account data
**Functionality:**
- Maps account number fields
- Handles account transformations

### /THKR/AIF_MAP_NAME
**Purpose:** Map name data
**Functionality:**
- Maps name fields and formats
- Handles name transformations

### /THKR/AIF_MAP_PROC_STATUS
**Purpose:** Map processing status
**Functionality:**
- Maps processing status values
- Handles status transformations

### /THKR/AIF_MAP_SIMPLE_MATH_OP
**Purpose:** Map simple math operations
**Functionality:**
- Maps mathematical calculations
- Handles numeric transformations

### /THKR/AIF_MAP_TIMS_FORMAT
**Purpose:** Map time format
**Functionality:**
- Maps time format fields
- Handles time format transformations

### /THKR/AIF_MAP_WAERS_COMMA
**Purpose:** Map currency with comma
**Functionality:**
- Maps currency amounts with comma separators
- Handles currency format transformations

### /THKR/AIF_MAP_WAERS_MINUS_COM
**Purpose:** Map currency with minus comma
**Functionality:**
- Maps negative currency amounts
- Handles negative currency transformations

### /THKR/AIF_MAP_WAERS_NO_MIN_COM
**Purpose:** Map currency without minus comma
**Functionality:**
- Maps currency amounts without separators
- Handles currency transformations

### /THKR/AIF_VMAP_15_BETR1
**Purpose:** Map 15-digit amount 1
**Functionality:**
- Maps specific 15-digit amount field 1
- Handles precision amount transformations

### /THKR/AIF_VMAP_AD_CITY1
**Purpose:** Map address city 1
**Functionality:**
- Maps address city field 1
- Handles city name transformations

### /THKR/AIF_VMAP_AD_HSNM1
**Purpose:** Map address house number 1
**Functionality:**
- Maps address house number field 1
- Handles house number transformations

### /THKR/AIF_VMAP_AD_STREET
**Purpose:** Map address street
**Functionality:**
- Maps address street field
- Handles street name transformations

### /THKR/AIF_VMAP_ANTRAGSNUMMER
**Purpose:** Map application number
**Functionality:**
- Maps application number fields
- Handles application number transformations

### /THKR/AIF_VMAP_ANE_BELNR
**Purpose:** Map ANE document number
**Functionality:**
- Maps ANE-specific document numbers
- Handles ANE document transformations

### /THKR/AIF_VMAP_ANE_FINANCE
**Purpose:** Map ANE finance data
**Functionality:**
- Maps ANE finance-related fields
- Handles ANE finance transformations

### /THKR/AIF_VMAP_BANKK
**Purpose:** Map bank control key
**Functionality:**
- Maps bank control key fields
- Handles bank key transformations

### /THKR/AIF_VMAP_BANKN
**Purpose:** Map bank account number
**Functionality:**
- Maps bank account number fields
- Handles account number transformations

### /THKR/AIF_VMAP_BANKS
**Purpose:** Map bank country
**Functionality:**
- Maps bank country fields
- Handles country code transformations

### /THKR/AIF_VMAP_BELNR
**Purpose:** Map document number
**Functionality:**
- Maps document number fields
- Handles document number transformations

### /THKR/AIF_VMAP_BELNR_MB
**Purpose:** Map MB document number
**Functionality:**
- Maps dunning document numbers
- Handles MB document transformations

### /THKR/AIF_VMAP_BETRG1_KOR
**Purpose:** Map corrected amount 1
**Functionality:**
- Maps corrected amount field 1
- Handles amount correction transformations

### /THKR/AIF_VMAP_BLART
**Purpose:** Map document type
**Functionality:**
- Maps document type fields
- Handles document type transformations

### /THKR/AIF_VMAP_BLART_ERST_ZWEI
**Purpose:** Map document type first second
**Functionality:**
- Maps document type for first/second operations
- Handles document type transformations

### /THKR/AIF_VMAP_BLDAT
**Purpose:** Map document date
**Functionality:**
- Maps document date fields
- Handles date transformations

### /THKR/AIF_VMAP_BPEXT_001
**Purpose:** Map BP extension 001
**Functionality:**
- Maps business partner extension 001
- Handles BP extension transformations

### /THKR/AIF_VMAP_BUDAT
**Purpose:** Map posting date
**Functionality:**
- Maps posting date fields
- Handles posting date transformations

### /THKR/AIF_VMAP_BUKRS
**Purpose:** Map company code
**Functionality:**
- Maps company code fields
- Handles company code transformations

### /THKR/AIF_VMAP_BU_BIRTHDT
**Purpose:** Map business partner birth date
**Functionality:**
- Maps BP birth date fields
- Handles birth date transformations

### /THKR/AIF_VMAP_BU_LANGU
**Purpose:** Map business partner language
**Functionality:**
- Maps BP language fields
- Handles language transformations

### /THKR/AIF_VMAP_BU_TYPE
**Purpose:** Map business partner type
**Functionality:**
- Maps BP type fields
- Handles BP type transformations

### /THKR/AIF_VMAP_BVORG
**Purpose:** Map business transaction
**Functionality:**
- Maps business transaction fields
- Handles transaction transformations

### /THKR/AIF_VMAP_BVTYP
**Purpose:** Map business transaction type
**Functionality:**
- Maps business transaction type fields
- Handles transaction type transformations

### /THKR/AIF_VMAP_CENTRALMAP
**Purpose:** Map central mapping
**Functionality:**
- Maps central mapping fields
- Handles central mapping transformations

### /THKR/AIF_VMAP_FILENAME_TO_LOW
**Purpose:** Map filename to lowercase
**Functionality:**
- Maps filename to lowercase format
- Handles filename case transformations

### /THKR/AIF_VMAP_FIPEX
**Purpose:** Map commitment item
**Functionality:**
- Maps commitment item fields
- Handles commitment item transformations

### /THKR/AIF_VMAP_FIPOS
**Purpose:** Map commitment item position
**Functionality:**
- Maps commitment item position fields
- Handles position transformations

### /THKR/AIF_VMAP_FISTL
**Purpose:** Map funds center
**Functionality:**
- Maps funds center fields
- Handles funds center transformations

### /THKR/AIF_VMAP_HKONT
**Purpose:** Map G/L account
**Functionality:**
- Maps G/L account fields
- Handles account transformations

### /THKR/AIF_VMAP_HKONT_UBH
**Purpose:** Map G/L account UBH
**Functionality:**
- Maps G/L account for UBH processing
- Handles UBH account transformations

### /THKR/AIF_VMAP_IBAN
**Purpose:** Map IBAN
**Functionality:**
- Maps IBAN fields
- Handles IBAN transformations

### /THKR/AIF_VMAP_IST_RUECK_FNAME
**Purpose:** Map Ist-Rückmeldung filename
**Functionality:**
- Maps filename for Ist-Rückmeldung
- Handles Rückmeldung filename transformations

### /THKR/AIF_VMAP_IST_RUECK_O0004
**Purpose:** Map Ist-Rückmeldung O0004
**Functionality:**
- Maps O0004 field for Ist-Rückmeldung
- Handles O0004 transformations

### /THKR/AIF_VMAP_IST_XML_FNAME
**Purpose:** Map Ist XML filename
**Functionality:**
- Maps filename for Ist XML processing
- Handles XML filename transformations

### /THKR/AIF_VMAP_LAND1
**Purpose:** Map country
**Functionality:**
- Maps country fields
- Handles country transformations

### /THKR/AIF_VMAP_MABER
**Purpose:** Map dunning area
**Functionality:**
- Maps dunning area fields
- Handles dunning area transformations

### /THKR/AIF_VMAP_MB_REFERENCENR
**Purpose:** Map MB reference number
**Functionality:**
- Maps reference number for MB processing
- Handles MB reference transformations

### /THKR/AIF_VMAP_MONAT
**Purpose:** Map month
**Functionality:**
- Maps month fields
- Handles month transformations

### /THKR/AIF_VMAP_MWSKZ
**Purpose:** Map tax code
**Functionality:**
- Maps tax code fields
- Handles tax code transformations

### /THKR/AIF_VMAP_MWSKZ_NEU
**Purpose:** Map new tax code
**Functionality:**
- Maps new tax code fields
- Handles new tax code transformations

### /THKR/AIF_VMAP_NO_GAP
**Purpose:** Map no gap
**Functionality:**
- Maps no gap fields
- Handles gap-free transformations

### /THKR/AIF_VMAP_PSOFN
**Purpose:** Map PSO number
**Functionality:**
- Maps PSO number fields
- Handles PSO number transformations

### /THKR/AIF_VMAP_PSOTY
**Purpose:** Map PSO type
**Functionality:**
- Maps PSO type fields
- Handles PSO type transformations

### /THKR/AIF_VMAP_PSO_XML_AD_TIT1
**Purpose:** Map PSO XML address title 1
**Functionality:**
- Maps XML address title 1 from PSO
- Handles PSO XML title transformations

### /THKR/AIF_VMAP_PSO_XML_AOBTYPE
**Purpose:** Map PSO XML AO business type
**Functionality:**
- Maps XML AO business type from PSO
- Handles PSO XML AO type transformations

### /THKR/AIF_VMAP_PSO_XML_BPEXT
**Purpose:** Map PSO XML BP extension
**Functionality:**
- Maps XML BP extension from PSO
- Handles PSO XML BP extension transformations

### /THKR/AIF_VMAP_PSO_XML_BPEXT_B
**Purpose:** Map PSO XML BP extension B
**Functionality:**
- Maps XML BP extension B from PSO
- Handles PSO XML BP extension B transformations

### /THKR/AIF_VMAP_PSO_XML_BU_TYPE
**Purpose:** Map PSO XML business type
**Functionality:**
- Maps XML business type from PSO
- Handles PSO XML business type transformations

### /THKR/AIF_VMAP_PSO_XML_IBAN
**Purpose:** Map PSO XML IBAN
**Functionality:**
- Maps XML IBAN from PSO
- Handles PSO XML IBAN transformations

### /THKR/AIF_VMAP_PSO_XML_KBLART
**Purpose:** Map PSO XML document type
**Functionality:**
- Maps XML document type from PSO
- Handles PSO XML document type transformations

### /THKR/AIF_VMAP_PSO_XML_NAME
**Purpose:** Map PSO XML name
**Functionality:**
- Maps XML name from PSO
- Handles PSO XML name transformations

### /THKR/AIF_VMAP_PSO_XML_PSOAC
**Purpose:** Map PSO XML PSO account
**Functionality:**
- Maps XML PSO account from PSO
- Handles PSO XML account transformations

### /THKR/AIF_VMAP_PSO_XML_PSOIN
**Purpose:** Map PSO XML PSO input
**Functionality:**
- Maps XML PSO input from PSO
- Handles PSO XML input transformations

### /THKR/AIF_VMAP_PSO_XML_PSOMO
**Purpose:** Map PSO XML PSO module
**Functionality:**
- Maps XML PSO module from PSO
- Handles PSO XML module transformations

### /THKR/AIF_VMAP_PSO_XML_SST_BA
**Purpose:** Map PSO XML SST BA
**Functionality:**
- Maps XML SST BA from PSO
- Handles PSO XML SST BA transformations

### /THKR/AIF_VMAP_SEPA_VAL_TO_DAT
**Purpose:** Map SEPA value to date
**Functionality:**
- Maps SEPA value to date format
- Handles SEPA date transformations

### /THKR/AIF_VMAP_TITLE
**Purpose:** Map title
**Functionality:**
- Maps title fields
- Handles title transformations

### /THKR/AIF_VMAP_TITLE_CSV
**Purpose:** Map title CSV
**Functionality:**
- Maps title for CSV format
- Handles CSV title transformations

### /THKR/AIF_VMAP_TXT_PROT_KASSZ
**Purpose:** Map text protocol Kassenzeichen
**Functionality:**
- Maps text protocol for Kassenzeichen
- Handles protocol text transformations

### /THKR/AIF_VMAP_WAERS
**Purpose:** Map currency
**Functionality:**
- Maps currency fields
- Handles currency transformations

### /THKR/AIF_VMAP_WRBTR
**Purpose:** Map amount
**Functionality:**
- Maps amount fields
- Handles amount transformations

### /THKR/AIF_VMAP_WRBTR2
**Purpose:** Map amount 2
**Functionality:**
- Maps amount field 2
- Handles amount 2 transformations

### /THKR/AIF_VMAP_WRBTR2_COM
**Purpose:** Map amount 2 with comma
**Functionality:**
- Maps amount 2 with comma separator
- Handles comma amount transformations

### /THKR/AIF_VMAP_WRBTR_BIENE_01
**Purpose:** Map amount Biene 01
**Functionality:**
- Maps amount for Biene 01 processing
- Handles Biene amount transformations

### /THKR/AIF_VMAP_WRBTR_BI_KID_01
**Purpose:** Map amount Biene KID 01
**Functionality:**
- Maps amount for Biene KID 01 processing
- Handles Biene KID amount transformations

### /THKR/AIF_VMAP_WRBTR_CSV
**Purpose:** Map amount CSV
**Functionality:**
- Maps amount for CSV format
- Handles CSV amount transformations

### /THKR/AIF_VMAP_WRBTR_KOR
**Purpose:** Map corrected amount
**Functionality:**
- Maps corrected amount fields
- Handles amount correction transformations

### /THKR/AIF_VMAP_XEZER
**Purpose:** Map payment method
**Functionality:**
- Maps payment method fields
- Handles payment method transformations

### /THKR/AIF_VMAP_ZLSCH
**Purpose:** Map payment method supplement
**Functionality:**
- Maps payment method supplement fields
- Handles payment supplement transformations

## AIF Checks

### /THKR/AIF_ZALLGE_CHK_AO
**Purpose:** Check Anordnung data
**Validation Rules:**
- Validates order data integrity
- Checks AO business rules

### /THKR/AIF_ZALLGE_CHK_AUSAO_REF
**Purpose:** Check outgoing AO reference
**Validation Rules:**
- Validates outgoing order references
- Checks reference data integrity

### /THKR/AIF_ZALLGE_CHK_BANKL_IST
**Purpose:** Check bank data for Ist processing
**Validation Rules:**
- Validates bank data for actual processing
- Checks bank information integrity

### /THKR/AIF_ZALLGE_CHK_BELNR_STO
**Purpose:** Check document number for reversal
**Validation Rules:**
- Validates document numbers for reversal operations
- Checks document status for Storno

### /THKR/AIF_ZALLGE_CHK_BP_EXISTS
**Purpose:** Check business partner existence
**Validation Rules:**
- Validates business partner existence in SAP
- Checks BP master data integrity

### /THKR/AIF_ZALLGE_CHK_BP_FOR_MB
**Purpose:** Check business partner for dunning
**Validation Rules:**
- Validates BP data for dunning notice processing
- Checks BP dunning eligibility

### /THKR/AIF_ZALLGE_CHK_BTYPE_I_FI
**Purpose:** Check business type for FI interface
**Validation Rules:**
- Validates business type for FI integration
- Checks FI interface compatibility

### /THKR/AIF_ZALLGE_CHK_BTYPE_SST
**Purpose:** Check business type for SST
**Validation Rules:**
- Validates business type for SST processing
- Checks SST compatibility

### /THKR/AIF_ZALLGE_CHK_BTYPE_SUPP
**Purpose:** Check business type for supplier
**Validation Rules:**
- Validates business type for supplier processing
- Checks supplier data integrity

### /THKR/AIF_ZALLGE_CHK_BUKRS
**Purpose:** Check company code
**Validation Rules:**
- Validates company code existence
- Checks company code authorization

### /THKR/AIF_ZALLGE_CHK_BU_TYPE_O
**Purpose:** Check business type outgoing
**Validation Rules:**
- Validates business type for outgoing processing
- Checks outgoing data integrity

### /THKR/AIF_ZALLGE_CHK_BU_TYPE_S
**Purpose:** Check business type incoming
**Validation Rules:**
- Validates business type for incoming processing
- Checks incoming data integrity

### /THKR/AIF_ZALLGE_CHK_FEB_EXIST
**Purpose:** Check FEB document existence
**Validation Rules:**
- Validates FEB document existence
- Checks electronic bank statement data

### /THKR/AIF_ZALLGE_CHK_FEB_NE
**Purpose:** Check FEB document not equal
**Validation Rules:**
- Validates FEB document differences
- Checks electronic bank statement variations

### /THKR/AIF_ZALLGE_CHK_GP_KBLK
**Purpose:** Check GP data against KBLK
**Validation Rules:**
- Validates GP data against contract data
- Checks GP contract relationships

### /THKR/AIF_ZALLGE_CHK_GP_PSO02
**Purpose:** Check GP data for PSO02
**Validation Rules:**
- Validates GP data for PSO02 processing
- Checks PSO02 compatibility

### /THKR/AIF_ZALLGE_CHK_INTERFACE
**Purpose:** Check interface data
**Validation Rules:**
- Validates interface data integrity
- Checks interface processing rules

### /THKR/AIF_ZALLGE_CHK_MB_POS_EX
**Purpose:** Check MB position exists
**Validation Rules:**
- Validates dunning notice position existence
- Checks MB position data integrity

### /THKR/AIF_ZALLGE_CHK_MB_POS_NE
**Purpose:** Check MB position not equal
**Validation Rules:**
- Validates dunning notice position differences
- Checks MB position variations

### /THKR/AIF_ZALLGE_CHK_MB_UP_BEL
**Purpose:** Check MB update document
**Validation Rules:**
- Validates MB update document data
- Checks document update eligibility

### /THKR/AIF_ZALLGE_CHK_PRC_CHAIN
**Purpose:** Check processing chain
**Validation Rules:**
- Validates processing chain integrity
- Checks processing sequence rules

### /THKR/AIF_ZALLGE_CHK_PSO_CPD
**Purpose:** Check PSO CPD data
**Validation Rules:**
- Validates PSO CPD data integrity
- Checks CPD processing rules

### /THKR/AIF_ZALLGE_CHK_PSO_INTF
**Purpose:** Check PSO interface data
**Validation Rules:**
- Validates PSO interface data
- Checks PSO interface compatibility

### /THKR/AIF_ZALLGE_CHK_PSO_KBLNR
**Purpose:** Check PSO document number
**Validation Rules:**
- Validates PSO document number
- Checks document number integrity

### /THKR/AIF_ZALLGE_CHK_PSO_NO_MB
**Purpose:** Check PSO no MB data
**Validation Rules:**
- Validates PSO data without MB processing
- Checks non-MB PSO data integrity

### /THKR/AIF_ZALLGE_CHK_REPROC
**Purpose:** Check reprocessing eligibility
**Validation Rules:**
- Validates reprocessing requirements
- Checks reprocessing business rules

### /THKR/AIF_ZALLGE_CHK_SST_BETR3
**Purpose:** Check SST amount 3
**Validation Rules:**
- Validates SST amount field 3
- Checks amount data integrity

### /THKR/AIF_ZALLGE_CHK_STKZ_ADDR
**Purpose:** Check tax number address
**Validation Rules:**
- Validates tax number against address
- Checks tax number address consistency

### /THKR/AIF_ZALLGE_CHK_STUNDUNG
**Purpose:** Check deferral data
**Validation Rules:**
- Validates payment deferral data
- Checks deferral business rules

### /THKR/AIF_ZALLGE_CHK_UBE_EXIST
**Purpose:** Check transfer document existence
**Validation Rules:**
- Validates transfer document existence
- Checks transfer document data

### /THKR/AIF_ZALLGE_CHK_V1_EQ_V2
**Purpose:** Check value 1 equals value 2
**Validation Rules:**
- Validates value equality checks
- Checks data consistency rules

### /THKR/AIF_ZALLGE_CHK_VR_NEEDED
**Purpose:** Check clearing needed
**Validation Rules:**
- Validates clearing requirement
- Checks clearing business rules

### /THKR/AIF_ZALLGE_CHK_VR_N_NEED
**Purpose:** Check clearing not needed
**Validation Rules:**
- Validates non-clearing scenarios
- Checks clearing exclusion rules

### /THKR/AIF_ZALLGE_CHK_WRBTR
**Purpose:** Check amount data
**Validation Rules:**
- Validates amount field data
- Checks amount business rules

### /THKR/AIF_ZALLGE_CHK_ZWEIT
**Purpose:** Check secondary data
**Validation Rules:**
- Validates secondary data integrity
- Checks secondary processing rules

## Key Integration Points

### SAP FI/CO Integration
- **BKPF/BSEG**: Document processing
- **Business Partners**: GP master data
- **Funds Management**: FM commitment items

### SAP BP Integration
- **Business Partner Management**: GP processing
- **Address Data**: Address validation
- **Bank Data**: Bank account management

### External Systems
- **PSO System**: XML data exchange
- **EDAS**: Enterprise data access
- **OASIS**: External processing system

### File Formats
- **XML Format**: Primary for PSO integration
- **BIC Format**: Banking standard format
- **CSV Format**: Data exchange format

## Processing Flow

1. **Data Reception** → Various input formats (XML, files, direct API)
2. **Structure Validation** → Format and structure checks
3. **Business Validation** → Complex business rule validation
4. **Data Transformation** → Mapping to SAP formats
5. **Action Processing** → Execute specific business logic
6. **Output Generation** → Create SAP documents and responses

## Error Handling

### Error Types
- **Validation Errors**: Business rule violations
- **System Errors**: SAP integration failures
- **Data Errors**: Format and structure issues
- **Processing Errors**: Business logic failures

### Recovery Mechanisms
- **Reprocessing**: Failed message restart
- **Manual Correction**: Administrative data correction
- **Status Updates**: Processing status management
- **Logging**: Comprehensive error logging</content>
<parameter name="filePath">c:\Users\LukaszKwasniewski\Documents\Claude-Projects\lsa_aif_doc\ZALLGE_Interface_README.md