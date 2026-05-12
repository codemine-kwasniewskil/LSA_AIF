# FREMDV Interface Documentation

## Overview
**Interface ID:** FREMDV  
**Namespace:** /THKR/  
**Purpose:** External system integrations for payment confirmations and financial data exchange  
**Domain:** Foreign/External Systems Integration

## AIF Raw Structures

### /THKR/S_AIF_RAW_RUECK
**Purpose:** Raw Rückmeldung (payment confirmation) data structure
```abap
TYPES: BEGIN OF /thkr/s_aif_raw_rueck,
  bukrs TYPE bukrs,           " Company Code
  gjahr TYPE gjahr,           " Fiscal Year
  belnr TYPE belnr_d,         " Accounting Document Number
  buzei TYPE buzei,           " Line Item
  lotkz TYPE lotkz,           " Order Number
  xblnr TYPE xblnr,           " Reference Document Number
  wrbtr TYPE wrbtr,           " Amount
  waers TYPE waers,           " Currency
  bldat TYPE bldat,           " Document Date
  budat TYPE budat,           " Posting Date
  END OF /thkr/s_aif_raw_rueck.
```

### /THKR/S_AIF_RAW_BRUECKE
**Purpose:** Raw bridge data structure for external system communication
```abap
TYPES: BEGIN OF /thkr/s_aif_raw_bruecke,
  kassz TYPE /thkr/dte_kassz,    " Cash Sign
  betrg TYPE wrbtr,              " Amount
  valut TYPE valut,              " Value Date
  END OF /thkr/s_aif_raw_bruecke.
```

## AIF SAP Structures

### /THKR/S_AIF_SAP_RUECK
**Purpose:** SAP Rückmeldung structure for processed payment confirmations
```abap
TYPES: BEGIN OF /thkr/s_aif_sap_rueck,
  bukrs TYPE bukrs,                    " Company Code
  gjahr TYPE gjahr,                    " Fiscal Year
  belnr TYPE belnr_d,                  " Document Number
  buzei TYPE buzei,                    " Line Item
  wrbtr TYPE wrbtr,                    " Amount
  gezahlt TYPE wrbtr,                  " Paid Amount
  offen TYPE wrbtr,                    " Open Amount
  resend TYPE flag,                    " Resend Flag
  sst TYPE /thkr/dte_bu_sst,           " Service Type
  END OF /thkr/s_aif_sap_rueck.
```

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

## AIF Actions

### /THKR/AIF_FREMDV_ACT_DEL_ED_0
**Purpose:** Delete EDAS records with zero amounts
**Functionality:**
- Deletes records from `/THKR/T_EDAS_0` table where `kassz = curr_line-xblnr`
- Must be saved to secure financing parameters for SZU
- SZU has no own financing parameters, only reference via Kassenzeichen
- When SZU delivered from EDAS/OASIS, line used later for financing positions

### /THKR/AIF_FREMDV_ACT_DEL_RK_ER
**Purpose:** Delete error records from Rückmeldung processing
**Functionality:**
- Reads order status from data processing
- If successful (AO_STATUS = S), passes record to police
- If erroneous, empties data line
- Cannot delete from data-rko_polizei-line due to AIF line-wise processing

### /THKR/AIF_FREMDV_ACT_FWD_RK_PO
**Purpose:** Forward Rückmeldung data to police system
**Functionality:**
- Processes successful Rückmeldung records
- Forwards data to police interface for further processing

### /THKR/AIF_FREMDV_ACT_WRITE_FIL
**Purpose:** Write processed data to output files
**Functionality:**
- Creates BIC format output files with header, lines, and footer
- Uses `/THKR/CL_AIF_RUECK` class for output modification
- Generates filename based on header information
- Writes to logical file path `/THKR/AIF_{ifname}_OUT`

### /THKR/AIF_FREMDV_ACT_WRITE_PLZ
**Purpose:** Write PLZ (postal code) data to database
**Functionality:**
- Processes and stores postal code validation data
- Updates PLZ-related database tables

### /THKR/AIF_FREMDV_ACT_WRT_ED_0
**Purpose:** Write EDAS zero-amount records
**Functionality:**
- Stores EDAS records with zero amounts
- Preserves financing parameters for later use

### /THKR/AIF_FREMDV_ACT_WRT_FI_KI
**Purpose:** Write financial KI (customer) data
**Functionality:**
- Processes and stores financial customer data
- Updates KI-related database structures

### /THKR/AIF_FREMDV_ACT_WRT_RK_ER
**Purpose:** Write Rückmeldung error records
**Functionality:**
- Logs error records during Rückmeldung processing
- Stores error information for analysis and reprocessing

## AIF Mappings

### /THKR/AIF_VMAP_ANTRAGSNUMMER
**Purpose:** Map application numbers from SAP BKPF table
**Input Parameters:**
- `VALUE_IN` = Company Code (BUKRS)
- `VALUE_IN2` = Order Number (LOTKZ)
- `VALUE_IN3` = Cash Sign (XBLNR)
**Functionality:**
```abap
SELECT SINGLE psofn FROM bkpf
 WHERE bukrs = @value_in
   AND lotkz = @value_in2
   AND xblnr = @value_in3
 INTO @value_out.
```

### /THKR/AIF_VMAP_FILENAME_UBH
**Purpose:** Generate UBH filename format
**Functionality:**
- Creates standardized filename for UBH (Überweisung) files
- Follows UBH naming conventions

### /THKR/AIF_VMAP_GENNR
**Purpose:** Map generation numbers
**Functionality:**
- Processes generation number mappings for document processing

### /THKR/AIF_VMAP_IST_BVORG
**Purpose:** Map Ist-BVORG (actual transaction type)
**Functionality:**
- Maps actual transaction types for Rückmeldung processing

### /THKR/AIF_VMAP_IST_LAST_BELNR
**Purpose:** Map last document number for Ist processing
**Functionality:**
- Determines last document number in Ist processing chain

### /THKR/AIF_VMAP_IST_PSOBN
**Purpose:** Map Ist-PSOBN (actual posting number)
**Functionality:**
- Maps actual posting numbers for financial processing

### /THKR/AIF_VMAP_IST_VALUT
**Purpose:** Map Ist-VALUT (actual value date)
**Functionality:**
- Maps actual value dates for payment processing

### /THKR/AIF_VMAP_MWSKZ_BLSA
**Purpose:** Map tax codes for BLSA
**Functionality:**
- Maps tax codes specific to BLSA processing

### /THKR/AIF_VMAP_SKNW_IS_PAID
**Purpose:** Map SKNW payment status
**Functionality:**
- Determines if SKNW (subsequent note) is paid

### /THKR/AIF_VMAP_SOLL_DEC_UBH
**Purpose:** Map Soll decimal values for UBH
**Functionality:**
- Maps decimal values for UBH processing

### /THKR/AIF_VMAP_STRING_TO_HEX
**Purpose:** Convert string to hexadecimal
**Functionality:**
- Converts string values to hexadecimal format

### /THKR/AIF_VMAP_URKASS_REFANTRG
**Purpose:** Map Urkass reference application number
**Functionality:**
- Maps reference application numbers for Urkass processing

## AIF Checks

### /THKR/AIF_FREMDV_CHK_IST_RUECK
**Purpose:** Validate Rückmeldung data based on payment status
**Validation Logic:**
- **Type 'N'**: Only unpaid orders (paid amount = 0.00)
- **Type 'T'**: Partially paid orders OR fully paid orders
- Uses CDS view for delta logic instead of AIF
- Checks if record should be sent based on payment status

## Key Integration Points

### SAP FI/CO Integration
- **BKPF Table**: Document header data
- **BSEG Table**: Document line items
- **Document Types**: Various BLART mappings

### External Systems
- **EDAS**: Enterprise Data Access Service
- **OASIS**: External system for SZU delivery
- **Police Systems**: For successful Rückmeldung forwarding

### File Formats
- **BIC Format**: Banking industry standard
- **XML Format**: For structured data exchange
- **Flat Files**: CSV and fixed-width formats

## Processing Flow

1. **Data Reception** → Raw data from external systems
2. **Initial Validation** → Format and structure checks
3. **Data Mapping** → Transformation to SAP formats
4. **Business Validation** → Payment status and business rules
5. **Action Processing** → Execute business logic
6. **Output Generation** → Create response files

## Error Handling

### Error Types
- **Validation Errors**: Data format violations
- **Processing Errors**: Business logic failures
- **System Errors**: SAP integration failures

### Recovery Mechanisms
- **Reprocessing**: Restart failed messages
- **Error Logging**: Detailed error information storage
- **Delta Processing**: Incremental processing support</content>
<parameter name="filePath">c:\Users\LukaszKwasniewski\Documents\Claude-Projects\lsa_aif_doc\FREMDV_Interface_README.md