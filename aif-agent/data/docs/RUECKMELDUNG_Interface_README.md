# RUECKMELDUNG Interface Documentation

## Overview
**Interface ID:** RUECKMELDUNG (0001_001/0001_002)  
**Namespace:** /THKR/  
**Purpose:** Payment confirmations and financial feedback processing  
**Domain:** Rückmeldung (Payment Confirmation) Processing

## AIF Raw Structures

### /THKR/S_AIF_RAW_RUECK
**Purpose:** Raw Rückmeldung data structure
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

## AIF Actions

### /THKR/AIF_FREMDV_ACT_RUECK
**Purpose:** Process Rückmeldung data
**Functionality:**
- Handles payment confirmation processing
- Updates payment status information
- Generates Rückmeldung responses

### /THKR/AIF_FREMDV_ACT_RUECK_VER
**Purpose:** Process Rückmeldung verification
**Functionality:**
- Verifies Rückmeldung data integrity
- Validates payment confirmation data
- Performs consistency checks

## AIF Mappings

### /THKR/AIF_VMAP_RUECK_IST_TYPE
**Purpose:** Map Rückmeldung actual type
**Functionality:**
- Maps actual Rückmeldung type (N/T/G)
- Determines processing logic based on type

### /THKR/AIF_VMAP_RUECK_STATUS
**Purpose:** Map Rückmeldung status
**Functionality:**
- Maps payment status information
- Handles status transformation logic

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
- **Payment Status**: Payment confirmation tracking

### External Systems
- **Payment Systems**: External payment processors
- **Banking Systems**: Bank confirmation interfaces
- **Government Systems**: Public sector payment tracking

### File Formats
- **BIC Format**: Banking industry standard
- **XML Format**: Structured data exchange
- **CSV Format**: Bulk data processing

## Processing Flow

1. **Payment Data Reception** → External payment confirmations
2. **Status Validation** → Payment status verification
3. **Data Mapping** → SAP structure transformation
4. **Business Validation** → Payment rule validation
5. **Status Update** → SAP payment status updates
6. **Response Generation** → Confirmation responses

## Error Handling

### Error Types
- **Payment Validation Errors**: Invalid payment data
- **Status Errors**: Payment status inconsistencies
- **Integration Errors**: SAP update failures

### Recovery Mechanisms
- **Reprocessing**: Failed payment confirmation restart
- **Status Synchronization**: Payment status alignment
- **Manual Correction**: Administrative payment correction</content>
<parameter name="filePath">c:\Users\LukaszKwasniewski\Documents\Claude-Projects\lsa_aif_doc\RUECKMELDUNG_Interface_README.md