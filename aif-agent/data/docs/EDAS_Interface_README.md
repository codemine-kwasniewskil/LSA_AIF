# EDAS Interface Documentation

## Overview
**Interface ID:** EDAS  
**Namespace:** /THKR/  
**Purpose:** Enterprise Data Access Service integration for external data processing  
**Domain:** Enterprise Data Access Services

## AIF Raw Structures

### /THKR/S_AIF_RAW_EDAS
**Purpose:** Raw EDAS data structure for enterprise data access

## AIF SAP Structures

### /THKR/S_AIF_SAP_EDAS
**Purpose:** SAP EDAS structure for processed enterprise data

### /THKR/T_EDAS_0
**Purpose:** EDAS zero-amount records table
```abap
TYPES: BEGIN OF /thkr/t_edas_0,
  kassz TYPE /thkr/dte_kassz,    " Cash Sign
  betrg TYPE wrbtr,              " Amount (zero)
  valut TYPE valut,              " Value Date
  END OF /thkr/t_edas_0.
```

## AIF Actions

### /THKR/AIF_FREMDV_ACT_DEL_ED_0
**Purpose:** Delete EDAS records with zero amounts
**Functionality:**
- Deletes records from `/THKR/T_EDAS_0` table
- Secures financing parameters for SZU
- SZU has no own financing parameters, only reference via Kassenzeichen
- When SZU delivered from EDAS/OASIS, line used later for financing positions

### /THKR/AIF_FREMDV_ACT_WRT_ED_0
**Purpose:** Write EDAS zero-amount records
**Functionality:**
- Stores EDAS records with zero amounts
- Preserves financing parameters for later use
- Maintains EDAS data integrity

### /THKR/AIF_EDAS_ACT_PLZDB
**Purpose:** Process EDAS PLZ database operations
**Functionality:**
- Handles postal code database operations for EDAS
- Manages PLZ data validation and storage

### /THKR/AIF_EDAS_ACT_ZAHL_EIN
**Purpose:** Process EDAS payment entries
**Functionality:**
- Processes payment entry data from EDAS
- Handles payment data validation and processing

### /THKR/AIF_EDAS_ACT_ZPPROT
**Purpose:** Process EDAS payment protocol
**Functionality:**
- Generates payment protocols for EDAS processing
- Maintains audit trails for payment operations

## AIF Mappings

### /THKR/AIF_VMAP_EDAS_KASSZ
**Purpose:** Map EDAS Kassenzeichen
**Functionality:**
- Maps cash sign data for EDAS processing
- Handles Kassenzeichen transformations

### /THKR/AIF_VMAP_EDAS_AMOUNT
**Purpose:** Map EDAS amount data
**Functionality:**
- Maps amount fields for EDAS integration
- Handles currency and amount transformations

## AIF Checks

### /THKR/AIF_EDAS_CHK_DATA_VALID
**Purpose:** Validate EDAS data integrity
**Validation Rules:**
- Validates EDAS data format and content
- Checks data consistency rules
- Ensures EDAS data quality

## Key Integration Points

### EDAS System Integration
- **Enterprise Data Access**: External data retrieval
- **SZU Processing**: Special user processing
- **OASIS Integration**: External system connectivity

### SAP Integration
- **Financing Parameters**: FM integration for financing data
- **Kassenzeichen Management**: Cash sign processing
- **Zero Amount Handling**: Special processing for zero amounts

### File Formats
- **XML Format**: Primary for EDAS data exchange
- **Database Integration**: Direct database access
- **Web Services**: Service-based integration

## Processing Flow

1. **EDAS Data Reception** → Enterprise data from external systems
2. **Data Validation** → EDAS data integrity checks
3. **SZU Processing** → Special user data handling
4. **Financing Parameter Storage** → Secure financing data
5. **Response Generation** → EDAS processing confirmations

## Error Handling

### Error Types
- **Data Validation Errors**: Invalid EDAS data
- **SZU Processing Errors**: Special user processing failures
- **Financing Parameter Errors**: FM integration issues

### Recovery Mechanisms
- **Data Reprocessing**: Failed EDAS data restart
- **SZU Correction**: Special user data correction
- **Parameter Recovery**: Financing parameter restoration</content>
<parameter name="filePath">c:\Users\LukaszKwasniewski\Documents\Claude-Projects\lsa_aif_doc\EDAS_Interface_README.md